#' Build xaringan slides as html file.
#'
#' Build xaringan slides as html file. Essentially the same thing as
#' `rmarkdown::render()` with `output_format = "xaringan::moon_reader"`
#'
#' @param input Path to Rmd file of xaringan slides.
#' @param output_file The name of the output file. If using NULL then the output
#'   filename will be based on filename for the input file. If a filename is
#'   provided, a path to the output file can also be provided.
#'
#' @examples
#' \dontrun{
#' # Build html from Rmd file
#' build_html("slides.Rmd")
#' }
#'
#' @export
build_html <- function(input, output_file = NULL) {
    # Check input and output files have correct extensions
    assert_path_ext(input, "rmd")
    assert_path_ext(output_file, "html")

    # Build input and output paths
    if (is.null(output_file)) {
        output_file <- path_new(input, "html")
    }

    input <- fs::path_abs(input)
    output_file <- fs::path_abs(output_file)

    # Build html from rmd
    proc <- cli_build_start(input, output_file, on_exit = "done")
    tryCatch({
        withr::local_dir(fs::path_dir(input))
        rmarkdown::render(
            input = fs::path_file(input),
            output_file = fs::path_rel(output_file, fs::path_dir(input)),
            output_format = 'xaringan::moon_reader',
            quiet = TRUE
        )
    },
        error = cli_build_failed(proc)
    )
}
