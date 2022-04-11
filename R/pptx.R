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
#' @param slides A numeric or integer vector of the slide number(s) to include
#'   in the pptx, or one of `"all"`, `"first"`, or `"last"`. Negative integers
#'   select which slides _not_ to include. Defaults to `"all"`, in which case
#'   all slides are included.
#' @inheritParams to_png
#' @inheritParams to_pdf
#'
#' @examples
#' \dontrun{
#' # Build pptx from Rmd, html, pdf, or url
#' to_pptx("slides.Rmd")
#' to_pptx("slides.html")
#' to_pptx("slides.pdf")
#' to_pptx("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")
#' }
#'
#' @export
to_pptx <- function(
    input,
    output_file = NULL,
    density = 100,
    slides = "all",
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
        to_pdf(
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
    slides <- slides_arg_validate(slides, imgs)

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
