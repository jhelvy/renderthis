# Build hierarchy is html, pdf / png, gif / pptx.
# - build_pdf() creates the pdf from the html file, so if the input is
#   a .Rmd file, it calls build_html() to create the html file, then builds
#   the pdf. If the input is a html file, it just builds the pdf.
# - build_gif() creates the gif from the pdf file, so if the input is
#   a .Rmd file, it calls build_pdf() (which calls build_html()) to create the
#   html and pdf files, then builds the gif file. If the input is a html file,
#   it calls build_pdf() to create the the pdf before building the gif file.
#   If the input is the pdf, it just builds the gif from the pdf.
# - build_pptx() creates the pptx from the pdf file, so if the input is
#   a .Rmd file, it calls build_pdf() (which calls build_html()) to create the
#   html and pdf files, then builds the pptx file. If the input is a html file,
#   it calls build_pdf() to create the the pdf before building the pptx file.
#   If the input is the pdf, it just builds the pptx from the pdf.
# - build_thumbnail() creates the png from the html file, so if the input is
#   a .Rmd file, it calls build_html() to create the html file, then builds
#   the png. If the input is a html file, it just builds the png.

#' Build xaringan slides to multiple outputs.
#'
#' Build xaringan slides to multiple outputs. Options are `"html"`, `"pdf"`,
#' `"gif"`, `"pptx"`, and `"thumbnail"` (a png image of the first slide).
#' Note: If you want to include "complex" slides (e.g. slides with panelsets
#' or other html widgets or advanced features), or you want to include partial
#' (continuation) slides, then use `build_pdf()` with `complex_slides = TRUE`
#' and / or `partial_slides = TRUE` to build the pdf first, then use
#' `build_all()`.
#' @param input Path to Rmd file of xaringan slides.
#' @param include A vector of the different output types to build. Options are
#' `"html"`, `"pdf"`, `"gif"`, `"pptx"`, and `"thumbnail"` (a png image of the
#' first slide). Defaults to `c("html", "pdf", "gif", "pptx", "thumbnail")`.
#' @param exclude A vector of the different output types to NOT build. Options
#' are `"html"`, `"pdf"`, `"gif"`, `"pptx"`, and `"thumbnail"` (a png image of
#' the first slide). Defaults to `NULL`, in which case all all output types
#' are rendered.
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
build_all <- function(input, include = c("html", "pdf", "gif", "pptx", "thumbnail"), exclude = NULL) {
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

    # each step requires the format of the previous step
    # html -> pdf -> gif / pptx
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
    if (do_htm) build_html(input)
    if (do_pdf) build_pdf(input_html)
    if (do_gif) build_gif(input_pdf)
    if (do_ppt) build_pptx(input_pdf)
    if (do_thm) build_thumbnail(input_html)

    invisible(input)
}
