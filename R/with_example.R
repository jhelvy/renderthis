#' Try renderthis functions with an example
#'
#' This function primarily exists to ensure that the examples in this package
#' are readable. But you can also use `with_example()` to try out the various
#' output functions.
#'
#' @example man/examples/examples_with-example.R
#'
#' @param example The name of the example file, currently only `"slides.Rmd"`.
#' @param code The code expression to evaluate. You can use the example as an
#'   input by referencing it directly, e.g. `from = "slides.Rmd"`.
#' @param clean Should the example file and any extra files be cleaned up when
#'   the function exits? The default is `TRUE`, but if you want to inspect the
#'   output you should set to `FALSE`.
#'
#' @return Invisibly returns the path to the temp directory where the example
#'   was created when `clean = FALSE`, otherwise invisibly returns the output
#'   from evaluating `expr`.
#'
#' @keywords internal
#' @export
with_example <- function(
    example,
    code,
    clean = TRUE,
    requires_packages = NULL,
    requires_chrome = FALSE
) {
    if (!interactive()) {
        in_pkgdown <- identical(Sys.getenv("IN_PKGDOWN"), "true")
        in_ci <- nzchar(Sys.getenv("CI", ""))
        if (!(in_pkgdown || in_ci)) {
            return(invisible())
        }
    }

    if (isTRUE(requires_chrome)) {
        requires_packages <- c(requires_packages, "chromote")
    }
    if (!is.null(requires_packages)) {
        pkg_is_avail <- vapply(requires_packages, requireNamespace, logical(1), quietly = TRUE)
        pkgs_miss <- requires_packages[!pkg_is_avail]
        if (length(pkgs_miss)) {
            cli::cli_inform("This example requires the packages {.pkg {pkgs_miss}}.")
            return(invisible())
        }
    }
    if (isTRUE(requires_chrome)) {
        if (!check_chrome_installed()) {
            cli::cli_inform("This example requires {.strong Google Chrome}.")
            return(invisible())
        }
    }

    examples <- dir(system.file("example", package = "renderthis"))
    example <- match.arg(tolower(example), choices = tolower(examples))
    example <- examples[tolower(example) == tolower(examples)]
    example <- system.file("example", example, package = "renderthis")

    # Get a temp directory that might be cleaned up on exit
    dir <-
        if (isTRUE(clean)) {
            withr::local_tempdir()
        } else {
            fs::file_temp("renderthis")
        }

    # Ensure the directory exists and then temporarily move into it
    fs::dir_create(dir)
    withr::local_dir(dir)

    # Copy the example into the temp dir
    path <- fs::file_copy(example, fs::path_file(example))

    # evaluate the expression here, muffling errors as needed
    res <- tryCatch(force(code), error = identity)

    if (inherits(res, "error")) {
        message("Error running example: ", conditionMessage(res))
        return(invisible(NULL))
    }

    invisible(if (isTRUE(clean)) res else dir)
}
