#' Render slides as html file.
#'
#' Render xaringan or Quarto slides as an html file. In generally, it is the
#' same thing as [rmarkdown::render()] or [quarto::quarto_render()] except that
#' the `self_contained` option is forced to `TRUE` if the HTML file is built
#' into a directory other than the one containing `from`.
#'
#' @param from Path to an `.Rmd` or `.qmd` file.
#' @param to The name of the output file. If using `NULL` then the
#'   output file name will be based on file name for the `from` file. If a file
#'   name is provided, a path to the output file can also be provided.
#' @param self_contained Should the output file be a self-contained HTML file
#'   where all images, CSS and JavaScript are included directly in the output
#'   file? This option, when `TRUE`, provides you with a single HTML file that
#'   you can share with others, but it may be very large. This feature is
#'   enabled by default when the `to` file is written in a directory other
#'   than the one containing the `from` R Markdown file.
#' @param render_args A list of arguments passed to [rmarkdown::render()] or
#'   [quarto::quarto_render()].
#'
#' @return Slides are rendered as an `.html` file.
#'
#' @example man/examples/examples_html.R
#'
#' @export
to_html <- function(from, to = NULL, self_contained = FALSE, render_args = NULL) {

    input <- from
    output_file <- to

    assert_path_exists(input)

    if (is.null(output_file)) {
        output_file <- path_from(input, "html")
    }

    # Check input and output files have correct extensions
    assert_path_ext(input, c("rmd", "qmd"), arg = "from")
    assert_path_ext(output_file, "html", arg = "to")

    input <- fs::path_abs(input)
    output_file <- fs::path_abs(output_file)

    if (test_path_ext(input, "rmd")) {
        render_args <- build_html_rmd_args(input, output_file, self_contained, render_args)
        self_contained <- render_args$output_options$self_contained
        render_fn <- rmarkdown::render
    } else {
        render_args <- build_html_qmd_args(input, output_file, self_contained, render_args)
        self_contained <- "--self-contained" %in% render_args$pandoc_args
        render_fn <- quarto::quarto_render
    }

    # Render html from rmd
    #
    # If the output isn't in the same directory, we turn on self contained and
    # render the html file to a temporary file in the source input directory.
    # Then, we move the temp file to wherever it should be. Otherwise, rmarkdown
    # and pandoc fight each other over paths (wd/input/output)
    proc <- cli_build_start(input, output_file, on_exit = "done")
    tryCatch({
        withr::local_dir(fs::path_dir(input))

        if (self_contained) {
            # path_from() returns an absolute path
            temp_output_file <- path_from(
                fs::path_file(render_args$output_file), "html", temporary = TRUE
            )
            # discard the path directory so that rmd/qmd is rendered into source dir
            render_args$output_file <- fs::path_file(temp_output_file)
            # and then move the output into the right place at the end
            withr::defer(
                fs::file_move(render_args$output_file, output_file),
                priority = "first"
            )
        }

        do.call(render_fn, render_args)
    },
        error = cli_build_failed(proc)
    )

    invisible(output_file)
}

build_html_rmd_args <- function(input, output_file, self_contained = FALSE, rmd_args = NULL) {
    rmd_args <- c(list(), rmd_args)
    rmd_args$input <- fs::path_file(input)
    rmd_args$output_file <- fs::path_file(output_file)

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

build_html_qmd_args <- function(input, output_file, self_contained = FALSE, qmd_args = NULL) {
    qmd_args <- c(list(), qmd_args)
    qmd_args$input <- fs::path_file(input)
    qmd_args$output_file <- fs::path_file(output_file)

    self_contained <-
        isTRUE(self_contained) ||
        self_contained_is_required(input, output_file)

    if (self_contained) {
        # TODO: this argument is deprecated in latest pandoc, we should check
        # for pandoc version and pick best version
        qmd_args$pandoc_args <- c("--self-contained")
    }

    if (is.null(qmd_args$quiet)) {
        qmd_args$quiet <- TRUE
    }

    qmd_args
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
