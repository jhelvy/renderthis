#' Build xaringan slides as a gif file.
#'
#' Build xaringan slides as a gif video file. The function builds to the pdf,
#' converts each slide in the pdf to a png, and then converts the deck of
#' png files to a gif file.
#' @param input Path to a Rmd file, html file, pdf file, or a url.
#' If the input is a url to xaringan slides on a website, you must provide the
#' full url ending in ".html".
#' @param output_file Name of the output gif file.
#' @param density Resolution of the resulting pngs in each slide file.
#' Defaults to `100`.
#' @param slides A vector of the slide number(s) to include in the gif.
#' Defaults to `NULL`, in which case all slides are included.
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
#' # Build gif from Rmd, html, pdf, or url
#' build_gif("slides.Rmd")
#' build_gif("slides.html")
#' build_gif("slides.pdf")
#' build_gif("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")
#' }
build_gif <- function(
    input,
    output_file = NULL,
    density = 100,
    slides = NULL,
    fps = 1,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1
) {
    # Check input and output files have correct extensions
    assert_path_ext(input, c("rmd", "html", "pdf"))
    assert_path_ext(output_file, "gif")

    # Build input and output paths
    paths <- build_paths(input, output_file)

    # Build html and / or pdf (if input is not pdf)
    if (!test_path_ext(input, "pdf")) {
        build_to_pdf(input, paths, complex_slides, partial_slides, delay)
        paths <- build_paths(input = paths$output$pdf, output_file)
    }

    # Build gif from pdf
    input <- paths$input$pdf
    output_file <- paths$output$gif
    proc <- cli_build_start(input, output_file)
    pngs <- pdf_to_imgs(input, density)

    # Keep only selected slides by number
    if (!is.null(slides)) {
        pngs <- pngs[slides]
    }

    # Build the gif
    pngs_joined <- magick::image_join(pngs)
    pngs_animated <- magick::image_animate(pngs_joined, fps = fps)
    res <- magick::image_write(pngs_animated, output_file)

    cli::cli_process_done(proc)
    res
}
