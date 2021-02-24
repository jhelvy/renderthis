#' Build xaringan slides as gif file.
#'
#' Build xaringan slides as a gif file. The function builds to the pdf and
#' then converts it to a gif.
#' @param input Path to a Rmd, html, or pdf file, or a url of xaringan slides.
#' If the input is a url to xaringan slides on a website, you must provide the
#' full url ending in ".html".
#' @param output_file Name of the output gif file.
#' @param density Resolution of the resulting gif file.
#' @param fps Frames per second of the resulting gif file.
#' @param complex_slides For "complex" slides (e.g. slides with panelsets or
#' other html widgets or advanced features), set `complex_slides = TRUE`.
#' Defaults to `FALSE`. This will use the {chromote} package to iterate through
#' the slides at a pace set by the `delay` argument. Requires a local
#' installation of Chrome.
#' @param partial_slides Should partial (continuation) slides be
#' included in the output? If `FALSE`, the default, only the complete slide
#' is included in the PDF.
#' @param delay Seconds of delay between advancing to and printing
#' a new slide. Only used if `complex_slides = TRUE` or `partial_slides =
#' TRUE`.
#' @export
#' @examples
#' \dontrun{
#' # Build gif from Rmd, html, or pdf file
#' build_gif("slides.Rmd")
#' build_gif("slides.html")
#' build_gif("slides.pdf")
#' }
build_gif <- function(
    input,
    output_file = NULL,
    density = "72x72",
    fps = 1,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1
) {
    # Check input and output files have correct extensions
    assert_io_paths(input, c("rmd", "html", "pdf"), output_file, "gif")

    # Build input and output paths
    paths <- build_paths(input, output_file)

    # Build html and / or pdf (if input is not pdf)
    if (!test_path_ext(input, "pdf")) {
        build_to_pdf(input, paths, complex_slides, partial_slides, delay)
    }

    # Build gif from pdf
    input <- paths$input$pdf
    output_file <- paths$output$gif
    print_build_status(input, output_file)
    pngs <- pdf_to_pngs(input, density)
    pngs_joined <- magick::image_join(pngs)
    pngs_animated <- magick::image_animate(pngs_joined, fps = fps)
    magick::image_write(pngs_animated, output_file)
}
