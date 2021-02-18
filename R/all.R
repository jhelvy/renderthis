#' Build xaringan slides to multiple outputs.
#'
#' Build xaringan slides to multiple outputs. Options are `"html"`, `"pdf"`,
#' `"gif"`, `"pptx"`, `"thumbnail"`, and `"social"`.
#' @param input Path to Rmd file of xaringan slides.
#' @param include A vector of the different output types to build. Options are
#' `"html"`, `"pdf"`, `"gif"`, `"pptx"`, and `"thumbnail"` (a png image of the
#' first slide). Defaults to `c("html", "pdf", "gif", "pptx", "thumbnail")`.
#' @param exclude A vector of the different output types to NOT build. Options
#' are `"html"`, `"pdf"`, `"gif"`, `"pptx"`, and `"thumbnail"` (a png image of
#' the first slide). Defaults to `NULL`, in which case all all output types
#' are rendered.
#' @param complex_slides For "complex" slides (e.g. slides with panelsets or
#' other html widgets or advanced features), set `complex_slides = TRUE`.
#' Defaults to `FALSE`. This will use the {chromote} package to iterate through
#' the slides at a pace set by the `delay` argument. Requires a local
#' installation of Chrome.
#' @param partial_slides Should partial (continuation) slides be
#' included in the output? If `FALSE`, the default, only the complete slide
#' is included in the PDF.
#' @param delay Seconds of delay between advancing to and printing
#' a new slide. Only used if `complex_slides = TRUE` or `partial_slides =
#' TRUE`.
#' @export
#' @examples
#' \dontrun{
#' # Builds every output by default
#' build_all("slides.Rmd")
#'
#' # Choose which output types to include
#' build_all("slides.Rmd", include = c("html", "pdf", "gif"))
#'
#' # Choose which output types to exclude
#' build_all("slides.Rmd", exclude = c("pptx", "thumbnail"))
#' }
build_all <- function(
    input,
    include = c("html", "pdf", "gif", "pptx", "thumbnail", "social"),
    exclude = NULL,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1
    ) {
    assert_path_ext(input, "rmd")
    input <- fs::path_abs(input)
    input_html <- fs::path_ext_set(input, "html")
    input_pdf <- fs::path_ext_set(input, "pdf")

    include <- match.arg(include, several.ok = TRUE)
    do_htm <- ("html" %in% include) && (! "html" %in% exclude)
    do_pdf <- ("pdf" %in% include) && (! "pdf" %in% exclude)
    do_gif <- ("gif" %in% include) && (! "gif" %in% exclude)
    do_ppt <- ("pptx" %in% include) && (! "pptx" %in% exclude)
    do_thm <- ("thumbnail" %in% include) && (! "thumbnail" %in% exclude)
    do_soc <- ("social" %in% include) && (! "social" %in% exclude)

    # Build hierarchy:
    #
    # Rmd
    #  |
    #  |--> social (png)
    #  |
    #  |--> html
    #        |
    #        |--> thumbnail (png)
    #        |
    #        |--> pdf
    #              |
    #              |--> gif
    #              |
    #              |--> pptx
    #
    # currently calling a step out of order will create the intermediate steps
    # if at some point intermediate files are removed if not requested, the
    # logic here will need to be changed.

    if (do_gif && (!fs::file_exists(input_pdf) || do_htm)) {
        # to make a gif we need the PDF file
        # or if we update the HTML, we should also update the PDF for the gif
        do_pdf <- TRUE
    }
    if (do_ppt && (!fs::file_exists(input_pdf) || do_htm)) {
        # to make a pptx we need the PDF file
        # or if we update the HTML, we should also update the PDF for the pptx
        do_pdf <- TRUE
    }
    if ((do_pdf || do_thm) && !fs::file_exists(input_html)) {
        # to make a PDF or thumbnail we need the html file
        do_htm <- TRUE
    }

    # Do each step in order to ensure updates propagate
    # (or we use the current version of the required build step)
    if (do_soc) build_html(input)
    if (do_htm) build_html(input)
    if (do_thm) build_thumbnail(input_html)
    if (do_pdf) {
        build_pdf(
            input = input_html,
            complex_slides = complex_slides,
            partial_slides = partial_slides,
            delay = delay)
    }
    if (do_gif) build_gif(input_pdf)
    if (do_ppt) build_pptx(input_pdf)

    invisible(input)
}
