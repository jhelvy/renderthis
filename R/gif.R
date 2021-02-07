#' Build xaringan slides as gif file.
#'
#' Build xaringan slides as gif file. Note: If you want to include "complex"
#' slides (e.g. slides with panelsets or other html widgets or advanced
#' features), or you want to include partial (continuation) slides, then use
#' `build_pdf()` with `complex_slides = TRUE` and / or `partial_slides = TRUE`
#' to build the pdf first, then use `build_gif()` with the pdf as the input.
#' @param input Path to Rmd, html, or pdf file of xaringan slides.
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
    assert_path_ext(input, c("rmd", "html", "pdf"))
    input <- fs::path_abs(input)

    if (test_path_ext(input, c("rmd", "html"))) {
        build_pdf(
            input = input_html,
            complex_slides = complex_slides,
            partial_slides = partial_slides,
            delay = delay)
        input <- fs::path_ext_set(input, "pdf")
    }

    output_file <- check_output_file(input, output_file, "gif")

    print_build_status(input, output_file)

    pngs <- pdf_to_pngs(input, density)
    pngs_joined <- magick::image_join(pngs)
    pngs_animated <- magick::image_animate(pngs_joined, fps = fps)
    magick::image_write(pngs_animated, output_file)
}
