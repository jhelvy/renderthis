#' Build png thumbnail image of first slide.
#'
#' Build png thumbnail image of first xaringan slide. Requires a local
#' installation of Chrome.
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

    # Check if Chrome is installed
    assert_chrome_installed()

    # Check input and output files have correct extensions
    assert_path_ext(input, c("rmd", "html"), arg = "input")
    output_null <- is.null(output_file)
    output_file <- check_output_file(input, output_file, "png")

    # Create full file paths from root
    input <- fs::path_abs(input)
    output_file <- fs::path_abs(output_file)

    # Build
    if (test_path_ext(input, "rmd")) {
        build_html(
          input = input,
          output_file = fs::path_ext_set(output_file, "html")
        )
        input <- fs::path_ext_set(input, "html")
    }

    # Append "_thumbnail" to output_file name if not provided by user
    if (output_null) {
        output_file <- append_to_file_path(output_file, "_thumbnail")
    }

    print_build_status(input, output_file)

    pagedown::chrome_print(
        input  = input,
        output = output_file,
        format = "png")
}
