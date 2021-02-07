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
#' @export
#' @examples
#' \dontrun{
#' # Build gif from Rmd, html, or pdf file
#' build_gif("slides.Rmd")
#' build_gif("slides.html")
#' build_gif("slides.pdf")
#' }
build_gif <- function(input, output_file = NULL, density = "72x72", fps = 1) {
    assert_path_ext(input, c("rmd", "html", "pdf"))
    input <- fs::path_abs(input)

    if (test_path_ext(input, c("rmd", "html"))) {
        build_pdf(input, output_file)
        input <- fs::path_ext_set(input, "pdf")
    }

    if (is.null(output_file)) {
        output_file <- fs::path_ext_set(input, "gif")
    } else if (test_path_ext(output_file, "gif")) {
        stop("`output_file` should be NULL or have .gif extension")
    }
    cli::cli_process_start(
        "Building {.file {fs::path_file(output_file)}} from {.path {fs::path_file(input)}}",
        on_exit = "done"
    )
    pdf <- magick::image_read(input, density = density)
    pngs <- magick::image_convert(pdf, 'png')
    pngs_joined <- magick::image_join(pngs)
    pngs_animated <- magick::image_animate(pngs_joined, fps = fps)
    magick::image_write(pngs_animated, output_file)
}
