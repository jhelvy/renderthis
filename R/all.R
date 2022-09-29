#' Build slides to multiple outputs.
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Build slides to multiple outputs. Options are `"html"`, `"social"` `"pdf"`,
#' `"png"`, `"gif"`, `"mp4"`, and `"pptx"`. See each individual build_*()
#' function for details about each output type.
#'
#' @param input Path to an `.Rmd` or `.qmd` file of slides.
#' @param include A vector of the different output types to build. Options are
#'   `"html"`, `"social"`, `"pdf"`, `"png"`, `"gif"`, `"mp4"`, and `"pptx"`.
#'   Defaults to `c("html", "social", "pdf", "png", "gif", "mp4", "pptx")`.
#' @param exclude A vector of the different output types to NOT build. Options
#'   are `"html"`, `"social"`, `"pdf"`, `"png"`, `"gif"`, `"mp4"`, and `"pptx"`.
#'   Defaults to `NULL`, in which case all all output types are built.
#' @inheritParams to_png
#' @inheritParams to_pdf
#' @inheritParams to_mp4
#'
#' @return Builds slides to multiple output formats.
#'
#' @example man/examples/examples_all.R
#'
#' @export
build_all <- function(
    input,
    include = c("html", "social", "pdf", "png", "gif", "mp4", "pptx"),
    exclude = NULL,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1,
    density = 100,
    slides = "all",
    fps = 1
) {
    lifecycle::deprecate_warn("0.1.0", "build_all()")

    # Check that input file has the correct extension
    assert_path_ext(input, c("rmd", "qmd"))

    # Build hierarchy:
    #
    # Rmd
    #  |
    #  |--> social (png)
    #  |
    #  |--> html
    #        |
    #        |--> pdf
    #              |
    #              |--> png
    #                    |
    #                    |--> gif
    #                    |
    #                    |--> mp4
    #                    |
    #                    |--> pptx
    #
    # currently calling a step out of order will create the intermediate steps
    # if at some point intermediate files are removed if not requested, the
    # logic here will need to be changed.

    # Excluded outputs beat included outputs (since it's a stronger signal)
    include <- setdiff(match.arg(include, several.ok = TRUE), exclude)

    # If the user didn't specifically ask for html or pdf, then they're temp
    step_html <- path_from(input, "html", temporary = !"html" %in% include)
    step_pdf <- path_from(input, "pdf", temporary = !"pdf" %in% include)

    deriv_from_html <- c("pdf", "png", "gif", "mp4", "pptx")
    req_html <- length(intersect(include, deriv_from_html)) > 0
    req_pdf <- length(intersect(include, deriv_from_html[-1])) > 0

    # Do each step in order to ensure updates propagate
    # (or we use the current version of the required build step)
    if ("social" %in% include) {
        to_social(
            from = input,
            to = path_from(input, "social")
        )
        if (identical("social", include)) {
            return()
        }
    }
    if ("html" %in% include || req_html) {
        to_html(from = input, to = step_html)
    }
    if ("pdf" %in% include || req_pdf) {
        to_pdf(
            from = step_html,
            to = step_pdf,
            complex_slides = complex_slides,
            partial_slides = partial_slides,
            delay = delay
        )
    }
    if ("png" %in% include) {
        to_png(
            from = step_pdf,
            to = path_from(input, "png"),
            density = density,
            slides = slides
        )
    }
    if ("gif" %in% include) {
        to_gif(
            from = step_pdf,
            to = path_from(input, "gif"),
            density = density,
            fps = fps
        )
    }
    if ("mp4" %in% include) {
        to_mp4(
            from = step_pdf,
            to = path_from(input, "mp4"),
            density = density,
            fps = fps
        )
    }
    if ("pptx" %in% include) {
        to_pptx(
            from = step_pdf,
            to = path_from(input, "pptx"),
            density = density
        )
    }

    invisible(input)
}
