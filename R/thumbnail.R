#' Build png thumbnail image of first xaringan slide.
#' @param input Path to Rmd or html file of xaringan slides.
#' @param output_file Name of the output png file.
#' @export
#' @examples
#' \dontrun{
#' # Build first slide thumbnail from Rmd or html file
#' build_thumbnail("slides.Rmd")
#' build_thumbnail("slides.html")
#' }
build_thumbnail <- function(input, output_file = NULL) {
    assert_path_ext(input, c("rmd", "html"))
    input <- fs::path_abs(input)

    if (test_path_ext(input, "rmd")) {
        build_html(input, output_file)
        input <- fs::path_ext_set(input, "html")
    }
    if (is.null(output_file)) {
        output_file <- fs::path_ext_set(input, "png")
    } else if (test_path_ext(output_file, "png")) {
        stop("output_file should be NULL or have .png extension")
    }

    print_build_status(input, output_file)

    pagedown::chrome_print(
        input  = input,
        output = output_file,
        format = "png")
}
