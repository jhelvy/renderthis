#' Build xaringan slides as pptx file.
#'
#' Build xaringan slides as a pptx file. The function builds to the pdf and
#' then converts it into png images that are inserted on each slide in the
#' pptx file.
#'
#' @param input Path to a Rmd file, html file, pdf file, or a url. If the input
#'   is a url to xaringan slides on a website, you must provide the full url
#'   ending in ".html".
#' @param output_file Name of the output pptx file.
#' @param density Resolution of the resulting pngs in each slide file. Defaults
#'   to `100`.
#' @param slides A vector of the slide number(s) to include in the pptx.
#'   Defaults to `NULL`, in which case all slides are included.
#' @param complex_slides For "complex" slides (e.g. slides with panelsets or
#'   other html widgets or advanced features), set `complex_slides = TRUE`.
#'   Defaults to `FALSE`. This will use the {chromote} package to iterate
#'   through the slides at a pace set by the `delay` argument. Requires a local
#'   installation of Chrome.
#' @param partial_slides Should partial (continuation) slides be included in the
#'   output? If `FALSE`, the default, only the complete slide is included in the
#'   PDF.
#' @param delay Seconds of delay between advancing to and printing a new slide.
#'   Only used if `complex_slides = TRUE` or `partial_slides = TRUE`.
#' @inheritParams build_png
#'
#' @examples
#' \dontrun{
#' # Build pptx from Rmd, html, pdf, or url
#' build_pptx("slides.Rmd")
#' build_pptx("slides.html")
#' build_pptx("slides.pdf")
#' build_pptx("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")
#' }
#'
#' @export
build_pptx <- function(
    input,
    output_file = NULL,
    density = 100,
    slides = NULL,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1,
    keep_intermediates = FALSE
) {
    if (!requireNamespace("officer", quietly = TRUE)) {
        stop("`officer` is required: install.packages('officer')")
    }

    if (is.null(output_file)) {
        output_file <- path_from(input, "pptx")
    }

    # Check input and output files have correct extensions
    assert_path_ext(input, c("rmd", "html", "pdf"))
    assert_path_ext(output_file, "pptx")

    # Build html and / or pdf (if input is not pdf)
    step_pdf <- input
    if (!test_path_ext(input, "pdf")) {
        step_pdf <- path_from(output_file, "pdf", temporary = !keep_intermediates)
        build_pdf(
            input,
            step_pdf,
            complex_slides = complex_slides,
            partial_slides = partial_slides,
            delay = delay,
            keep_intermediates = keep_intermediates
        )
    }

    # Build pptx from pdf
    proc <- cli_build_start(step_pdf, output_file)
    imgs <- pdf_to_imgs(step_pdf, density)

    # Keep only selected slides by number
    if (!is.null(slides)) {
        imgs <- imgs[slides]
    }

    # Build the pptx
    doc <- get_pptx_template(imgs[1])
    for (i in 1:length(imgs)) {
        png_path <- magick::image_write(imgs[i], tempfile(fileext = ".png"))
        doc <- officer::add_slide(
            doc,
            layout = "Blank",
            master = "Office Theme"
        )
        doc <- officer::ph_with(
            doc,
            value = officer::external_img(png_path),
            location = officer::ph_location_fullsize()
        )
    }

    cli::cli_process_done(proc)
    print(doc, output_file)
}

get_pptx_template <- function(png) {
    dims <- magick::image_info(png)
    ar <- floor(100*(dims$width / dims$height))
    if (ar == 177) {
        file <- "16-9.pptx"
    } else {
        file <- "4-3.pptx"
    }
    template <- system.file(
        "extdata", file, package = "xaringanBuilder", mustWork = TRUE)
    officer::read_pptx(template)
}
