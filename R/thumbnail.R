#' Build png thumbnail image of first slide.
#'
#' Build png thumbnail image of first xaringan slide. Requires a local
#' installation of Chrome.
#' @param input Path to a Rmd file or html file / url of xaringan slides. If
#'  the input is a url to xaringan slides on a website, you must provide the
#'  full url ending in ".html".
#' @param output_file Name of the output png file.
#' @export
#' @examples
#' \dontrun{
#' # Build first slide thumbnail from Rmd or html file
#' build_thumbnail("slides.Rmd")
#' build_thumbnail("slides.html")
#' }
build_thumbnail <- function(input, output_file = NULL) {

    # Check if Chrome is installed
    assert_chrome_installed()

    # Check input and output files have correct extensions
    assert_io_paths(input, c("rmd", "html"), output_file, "png")

    # Build input and output paths
    paths <- build_paths(input, output_file)

    # Build html (if input is rmd)
    if (test_path_ext(input, "rmd")) {
        build_html(paths$input$rmd, paths$output$html)
    }

    # Build png from html
    input <- paths$input$html
    output_file <- paths$output$thumbnail
    print_build_status(input, output_file)
    pagedown::chrome_print(
        input  = input,
        output = output_file,
        format = "png")
}
