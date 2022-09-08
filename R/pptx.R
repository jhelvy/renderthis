#' Render slides as a PowerPoint file.
#'
#' Render slides as a `.pptx` file. The function renders to the PDF and
#' then converts it into PNG images that are inserted on each slide in the
#' PowerPoint file.
#'
#' @param to Name of the output `.pptx` file.
#' @param slides A numeric or integer vector of the slide number(s) to include
#'   in the pptx, or one of `"all"`, `"first"`, or `"last"`. Negative integers
#'   select which slides _not_ to include. Defaults to `"all"`, in which case
#'   all slides are included.
#' @inheritParams to_gif
#' @inheritParams to_png
#' @inheritParams to_pdf
#'
#' @return Slides are rendered as a pptx file.
#'
#' @example man/examples/examples_pptx.R
#'
#' @export
to_pptx <- function(
    from,
    to = NULL,
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

    input <- from
    output_file <- to

    if (is.null(output_file)) {
        output_file <- path_from(input, "pptx")
    }

    # Check input and output files have correct extensions
    assert_path_ext(output_file, "pptx", arg = "to")

    # Render html and / or pdf (if input is not pdf)
    step_pdf <- input
    if (!test_path_ext(input, "pdf")) {
        step_pdf <- path_from(output_file, "pdf", temporary = !keep_intermediates)
        to_pdf(
            from = input,
            to = step_pdf,
            complex_slides = complex_slides,
            partial_slides = partial_slides,
            delay = delay,
            keep_intermediates = keep_intermediates
        )
    }

    # Render pptx from pdf
    proc <- cli_build_start(step_pdf, output_file)
    imgs <- pdf_to_imgs(step_pdf, density)
    slides <- slides_arg_validate(slides, imgs)

    # Keep only selected slides by number
    if (!is.null(slides)) {
        imgs <- imgs[slides]
    }

    # Render the pptx
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
        "extdata", file, package = "renderthis", mustWork = TRUE)
    officer::read_pptx(template)
}
