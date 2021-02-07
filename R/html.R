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
    assert_path_ext(input, "rmd")
    input <- fs::path_abs(input)
    input_file_html <- fs::path_file(fs::path_ext_set(input, "html"))

    cli::cli_process_start(
        "Building {.file {input_file_html}} from {.path {fs::path_file(input)}}",
        on_exit = "done"
    )
    rmarkdown::render(
        input = input,
        output_file = output_file,
        output_format = 'xaringan::moon_reader',
        quiet = TRUE
    )
}
