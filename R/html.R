#' Build xaringan slides as html file.
#'
#' Build xaringan slides as html file. Essentially the same thing as
#' `rmarkdown::render()` with `output_format = "xaringan::moon_reader"`
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
    assert_io_paths(input, "rmd", output_file, "html")

    # Build input and output paths
    paths <- build_paths(input, output_file)
    input <- paths$input$rmd
    output_file <- paths$output$html

    # Build html from rmd
    proc <- print_build_status(input, output_file, on_exit = "done")
    tryCatch(
        rmarkdown::render(
            input = input,
            output_file = output_file,
            output_format = 'xaringan::moon_reader',
            quiet = TRUE
        ),
        error = function(err) {
            cli::cli_process_failed(proc)
            stop(err)
        }
    )
}
