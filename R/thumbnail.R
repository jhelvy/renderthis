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

    # Check input and output files have correct extensions
    assert_path_ext(input, c("rmd", "html"), arg = "input")
    output_file <- check_output_file(input, output_file, "png")

    input <- fs::path_abs(input)

    if (test_path_ext(input, "rmd")) {
        build_html(
          input = input,
          output_file = fs::path_ext_set(output_file, "html")
        )
        input <- fs::path_ext_set(input, "html")
    }

    # Append "_thumbnail.png" to output_file name
    output_file <- fs::path_ext_set(
        paste0(
            fs::path_ext_remove(output_file),
            "_thumbnail"),
        "png"
    )

    print_build_status(input, output_file)

    pagedown::chrome_print(
        input  = input,
        output = output_file,
        format = "png")
}
