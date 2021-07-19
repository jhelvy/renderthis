#' Build xaringan slides as html file.
#'
#' Build xaringan slides as html file. Essentially the same thing as
#' [rmarkdown::render()] with `output_format = "xaringan::moon_reader"`,
#' except that the `self_contained` option is forced to `TRUE` if the HTML file
#' is built into a directory other than the one containing `input`.
#'
#' @param input Path to Rmd file of xaringan slides.
#' @param output_file The name of the output file. If using `NULL` then the
#'   output file name will be based on file name for the input file. If a file
#'   name is provided, a path to the output file can also be provided.
#' @param self_contained Should the output file be a self-contained HTML file
#'   where all images, CSS and JavaScript are included directly in the output
#'   file? This option, when `TRUE`, provides you with a single HTML file that
#'   you can share with others, but it may be very large. This feature is
#'   enabled by default when the `output_file` is written in a directory other
#'   than the one containing the `input` R Markdown file.
#' @param rmd_args A list of arguments passed to [rmarkdown::render()].
#'
#' @examples
#' \dontrun{
#' # Build html from Rmd file
#' build_html("slides.Rmd")
#' }
#'
#' @export
build_html <- function(input, output_file = NULL, self_contained = FALSE, rmd_args = NULL) {
    assert_path_exists(input)

    if (is.null(output_file)) {
        output_file <- path_from(input, "html")
    }

    # Check input and output files have correct extensions
    assert_path_ext(input, "rmd")
    assert_path_ext(output_file, "html")

    input <- fs::path_abs(input)
    output_file <- fs::path_abs(output_file)

    rmd_args <- build_html_rmd_args(input, output_file, self_contained, rmd_args)

    # Build html from rmd
    proc <- cli_build_start(input, output_file, on_exit = "done")
    tryCatch({
        withr::local_dir(fs::path_dir(input))
        do.call(rmarkdown::render, rmd_args)
    },
        error = cli_build_failed(proc)
    )
}

build_html_rmd_args <- function(input, output_file, self_contained = FALSE, rmd_args = NULL) {
    rmd_args <- c(list(), rmd_args)
    rmd_args$input <- fs::path_file(input)
    rmd_args$output_file <- fs::path_rel(output_file, fs::path_dir(input))
    if (is.null(rmd_args$output_options)) {
        rmd_args$output_options <- list()
    }
    rmd_args$output_options$self_contained <-
        isTRUE(self_contained) || self_contained_is_required(input, output_file)
    if (is.null(rmd_args$quiet)) {
        rmd_args$quiet <- TRUE
    }
    rmd_args
}

self_contained_is_required <- function(input, output_file) {
    if (in_same_directory(input, output_file)) {
        return(FALSE)
    }
    cli::cli_alert_warning(
        paste(
            "Rendering slides with {.code self_contained = TRUE} since",
            "{.code output_file} is not in the same directory as {.code input}."
        ),
        wrap = TRUE
    )
    TRUE
}
