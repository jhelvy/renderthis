#' Build xaringan slides as png file(s).
#'
#' Build png image(s) of xaringan slides. The function builds to the pdf and
#' then converts it into png files of each slide. The slide numbers defined
#' by the `slides` argument are saved (defaults to `1`, returning only the
#' title slide). If `length(slides) > 1`, it will return the png files in a
#'  zip file. You can also get a zip file of all the slides as pngs by setting
#' `slides = "all"`).
#' @param input Path to a Rmd file, html file, pdf file, or a url.
#' If the input is a url to xaringan slides on a website, you must provide the
#' full url ending in ".html".
#' @param output_file Name of the output png or zip file.
#' @param density Resolution of the resulting pngs in each slide file.
#' Defaults to `100`.
#' @param slides A vector of the slide number(s) to return for the png output.
#' Defaults to `1`, returning only the title slide. To return a zip
#' file of all the slides as pngs, set `slides = NULL`).
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
#' # By default, a png of only the first slide is built
#' build_png("slides.Rmd")
#' build_png("slides.html")
#' build_png("slides.pdf")
#' build_png("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")
#'
#' # Build zip file of multiple or all slides
#' build_png("slides.pdf", slides = c(1, 3, 5))
#' build_png("slides.pdf", slides = "all")
#' }
build_png <- function(
    input,
    output_file = NULL,
    density = 100,
    slides = 1,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1
) {
    # Check input and output files have correct extensions
    assert_io_paths(
        input, c("rmd", "html", "pdf"),
        output_file, c("png", "zip")
    )

    # Build input and output paths
    paths <- build_paths(input, output_file)

    # Build html and / or pdf (if input is not pdf)
    if (!test_path_ext(input, "pdf")) {
        build_to_pdf(input, paths, complex_slides, partial_slides, delay)
    }

    # Build png from pdf
    input <- paths$input$pdf
    output_file <- paths$output$png
    if ((length(slides) > 1) | (slides == "all")) {
      output_file <- paths$output$zip
    }
    print_build_status(input, output_file)
    pngs <- pdf_to_pngs(input, density)
    if (is.null(slides)) {
      zip_pngs(pngs, seq_len(length(pngs)), output_file)
    } else if (length(slides) > 1) {
      zip_pngs(pngs, slides, output_file)
    } else {
      magick::image_write(pngs[slides], output_file)
    }
}

zip_pngs <- function(pngs, slides, output_file) {
  png_paths <- c()
  png_names <- c()
  temp_folder <- tempdir()
  png_root <- fs::path_ext_set(fs::path_file(output_file), "png")
  for (slide in slides) {
    png_name <- append_to_file_path(png_root, paste0("_", slide))
    png_path <- magick::image_write(
      pngs[slide], fs::path(temp_folder, png_name))
    png_paths <- c(png_paths, png_path)
    png_names <- c(png_names, png_name)
  }
  zip::zip(output_file, files = png_names, root = temp_folder)
}

#' Build png thumbnail image of first slide.
#'
#' Build png thumbnail image of first xaringan slide. Requires a local
#' installation of Chrome.
#' @param input Path to a Rmd file or html file / url of xaringan slides. If
#'  the input is a url to xaringan slides on a website, you must provide the
#'  full url ending in ".html".
#' @param output_file Name of the output png file.
#' @export
#' @examples
#' \dontrun{
#' # Build first slide thumbnail from Rmd or html file
#' build_thumbnail("slides.Rmd")
#' build_thumbnail("slides.html")
#' }
build_thumbnail <- function(input, output_file = NULL) {
    # v0.0.5
    .Deprecated("build_png")

    # Check if Chrome is installed
    assert_chrome_installed()

    # Check input and output files have correct extensions
    assert_io_paths(input, c("rmd", "html"), output_file, "png")

    # Build input and output paths
    paths <- build_paths(input, output_file)

    # Build html (if input is rmd)
    if (test_path_ext(input, "rmd")) {
        build_html(paths$input$rmd, paths$output$html)
    }

    # Build png from html
    input <- paths$input$html
    output_file <- paths$output$thumbnail
    print_build_status(input, output_file)
    pagedown::chrome_print(
        input  = input,
        output = output_file,
        format = "png")
}
