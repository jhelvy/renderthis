#' Build xaringan slides as pptx file.
#'
#' Build xaringan slides as a pptx file. The function builds to the pdf and
#' then converts it into png images that are inserted on each slide in the
#' pptx file.
#' @param input Path to a Rmd file, html file, pdf file, or a url.
#' If the input is a url to xaringan slides on a website, you must provide the
#' full url ending in ".html".
#' @param output_file Name of the output pptx file.
#' @param density Resolution of the resulting pngs in each slide file.
#' Defaults to `100`.
#' @param slides A vector of the slide number(s) to include in the pptx.
#' Defaults to `NULL`, in which case all slides are included.
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
#' # Build pptx from Rmd, html, pdf, or url
#' build_pptx("slides.Rmd")
#' build_pptx("slides.html")
#' build_pptx("slides.pdf")
#' build_pptx("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")
#' }
build_pptx <- function(
    input,
    output_file = NULL,
    density = 100,
    slides = NULL,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1
) {
    if (!requireNamespace("officer", quietly = TRUE)) {
        stop("`officer` is required: install.packages('officer')")
    }

    # Check input and output files have correct extensions
    assert_path_ext(input, c("rmd", "html", "pdf"))
    assert_path_ext(output_file, "pptx")

    # Build input and output paths
    paths <- build_paths(input, output_file)

    # Build html and / or pdf (if input is not pdf)
    if (!test_path_ext(input, "pdf")) {
        build_to_pdf(input, paths, complex_slides, partial_slides, delay)
        paths <- build_paths(input = paths$output$pdf, output_file)
    }

    # Build pptx from pdf
    input <- paths$input$pdf
    output_file <- paths$output$pptx
    proc <- cli_build_start(input, output_file)
    pngs <- pdf_to_imgs(input, density)

    # Keep only selected slides by number
    if (!is.null(slides)) {
        pngs <- pngs[slides]
    }

    # Build the pptx
    doc <- get_pptx_template(pngs[1])
    for (i in 1:length(pngs)) {
        png_path <- magick::image_write(
            pngs[i], tempfile(fileext = ".png"))
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
    return(officer::read_pptx(template))
}
