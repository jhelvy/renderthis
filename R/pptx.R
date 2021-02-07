#' Build xaringan slides as pptx file.
#'
#' Build xaringan slides as pptx file. Note: If you want to include "complex"
#' slides (e.g. slides with panelsets or other html widgets or advanced
#' features), or you want to include partial (continuation) slides, then use
#' `build_pdf()` with `complex_slides = TRUE` and / or `partial_slides = TRUE`
#' to build the pdf first, then use build_gif() with the pdf as the input.
#' @param input Path to Rmd, html, or pdf file of xaringan slides.
#' @param output_file Name of the output pptx file.
#' @param density Resolution of the resulting pptx file.
#' @export
#' @examples
#' \dontrun{
#' # Build gif from Rmd, html, or pdf file
#' build_pptx("slides.Rmd")
#' build_pptx("slides.html")
#' build_pptx("slides.pdf")
#' }
build_pptx <- function(input, output_file = NULL, density = "72x72") {
    if (!requireNamespace("officer", quietly = TRUE)) {
        stop("`officer` is required: install.packages('officer')")
    }

    assert_path_ext(input, c("rmd", "html", "pdf"))
    input <- fs::path_abs(input)

    if (test_path_ext(input, c("rmd", "html"))) {
        build_pdf(input, output_file)
        input <- fs::path_ext_set(input, "pdf")
    }

    if (is.null(output_file)) {
        output_file <- fs::path_ext_set(input, "pptx")
    } else if (test_path_ext(output_file, "pptx")) {
        stop("`output_file` should be NULL or have .pptx extension")
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
