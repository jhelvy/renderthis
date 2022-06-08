#' Build xaringan slides to multiple outputs.
#'
#' Build xaringan slides to multiple outputs. Options are `"html"`
#' ([to_html()]), `"social"` ([to_social()]), `"pdf"` ([to_pdf()]), `"png"`
#' ([to_png()]), `"gif"` ([to_gif()]), `"mp4"` ([to_mp4()]), and `"pptx"`
#' ([to_pptx()]).
#'
#' @param from Path to Rmd file of xaringan slides.
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
#' @examples
#' \dontrun{
#' # Builds every output by default
#' to_all("slides.Rmd")
#'
#' # Both of these build html, pdf, and gif outputs
#' to_all("slides.Rmd", include = c("html", "pdf", "gif"))
#' to_all("slides.Rmd", exclude = c("social", "png", "mp4", "pptx"))
#' }
#'
#' @export
to_all <- function(
    from,
    include = c("html", "social", "pdf", "png", "gif", "mp4", "pptx"),
    exclude = NULL,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1,
    density = 100,
    slides = "all",
    fps = 1
) {
    # Check that input file has the correct extension
    assert_path_ext(from, "rmd")

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
    step_html <- path_from(from, "html", temporary = !"html" %in% include)
    step_pdf <- path_from(from, "pdf", temporary = !"pdf" %in% include)

    deriv_from_html <- c("pdf", "png", "gif", "mp4", "pptx")
    req_html <- length(intersect(include, deriv_from_html)) > 0
    req_pdf <- length(intersect(include, deriv_from_html[-1])) > 0

    # Do each step in order to ensure updates propagate
    # (or we use the current version of the required build step)
    if ("social" %in% include) {
        build_social(
            from = from,
            to = path_from(from, "social")
        )
        if (identical("social", include)) {
            return()
        }
    }
    if ("html" %in% include || req_html) {
        build_html(from = from, to = step_html)
    }
    if ("pdf" %in% include || req_pdf) {
        build_pdf(
            from = step_html,
            to = step_pdf,
            complex_slides = complex_slides,
            partial_slides = partial_slides,
            delay = delay
        )
    }
    if ("png" %in% include) {
        build_png(
            from = step_pdf,
            to = path_from(from, "png"),
            density = density,
            slides = slides
        )
    }
    if ("gif" %in% include) {
        build_gif(
            from = step_pdf,
            to = path_from(from, "gif"),
            density = density,
            fps = fps
        )
    }
    if ("mp4" %in% include) {
        build_mp4(
            from = step_pdf,
            to = path_from(from, "mp4"),
            density = density,
            fps = fps
        )
    }
    if ("pptx" %in% include) {
        build_pptx(
            from = step_pdf,
            to = path_from(from, "pptx"),
            density = density
        )
    }

    invisible(from)
}
