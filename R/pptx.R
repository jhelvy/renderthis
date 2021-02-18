#' Build xaringan slides as pptx file.
#'
#' Build xaringan slides as pptx file from a Rmd, html, or pdf file. The
#' function builds to the pdf and then inserts a png image of each slide
#' as a new slide in a pptx file.
#' @param input Path to Rmd, html, or pdf file of xaringan slides.
#' @param output_file Name of the output pptx file.
#' @param density Resolution of the resulting pptx file.
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
#' # Build gif from Rmd, html, or pdf file
#' build_pptx("slides.Rmd")
#' build_pptx("slides.html")
#' build_pptx("slides.pdf")
#' }
build_pptx <- function(
    input,
    output_file = NULL,
    density = "72x72",
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1
    ) {
    if (!requireNamespace("officer", quietly = TRUE)) {
        stop("`officer` is required: install.packages('officer')")
    }
    # Check input and output files have correct extensions
    assert_path_ext(input, c("rmd", "html", "pdf"), arg = "input")
    output_file <- check_output_file(input, output_file, "pptx")

    # Create full file paths from root
    input <- fs::path_abs(input)
    output_file <- fs::path_abs(output_file)

    # Build
    if (test_path_ext(input, c("rmd", "html"))) {
        build_pdf(
            input = input,
            output_file = fs::path_ext_set(output_file, "pdf"),
            complex_slides = complex_slides,
            partial_slides = partial_slides,
            delay = delay)
        input <- fs::path_ext_set(input, "pdf")
    }

    print_build_status(input, output_file)

    pngs <- pdf_to_pngs(input, density)

    doc <- officer::read_pptx()
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

    print(doc, output_file)
}
