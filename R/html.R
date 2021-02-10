#' Build xaringan slides as html file.
#' @param input Path to Rmd file of xaringan slides.
#' @param output_file The name of the output file. If using NULL then
#' the output filename will be based on filename for the input file.
#' If a filename is provided, a path to the output file can also be provided.
#' @export
#' @examples
#' \dontrun{
#' # Build html from Rmd file
#' build_html("slides.Rmd")
#' }
build_html <- function(input, output_file = NULL) {
    # Check input and output files have correct extensions
    assert_path_ext(input, "rmd", arg = "input")
    output_file <- check_output_file(input, output_file, "html")

    # Create full file paths from root
    input <- fs::path_abs(input)
    output_file <- fs::path_abs(output_file)

    # Build
    print_build_status(input, output_file)
    rmarkdown::render(
        input = input,
        output_file = output_file,
        output_format = 'xaringan::moon_reader',
        quiet = TRUE
    )
}
