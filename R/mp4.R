#' Build xaringan slides as a mp4 video file.
#'
#' Build xaringan slides as a mp4 video file. The function builds to the pdf,
#' converts each slide in the pdf to a png, and then converts the deck of
#' png files to a mp4 video file.
#' @param input Path to a Rmd file, html file, pdf file, or a url.
#' If the input is a url to xaringan slides on a website, you must provide the
#' full url ending in ".html".
#' @param output_file Name of the output mp4 file.
#' @param density Resolution of the resulting pngs in each slide file.
#' Defaults to `100`.
#' @param slides A vector of the slide number(s) to include in the mp4.
#' Defaults to `NULL`, in which case all slides are included.
#' @param fps Frames per second of the resulting mp4 file.
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
#' # Build mp4 from Rmd, html, pdf, or url
#' build_mp4("slides.Rmd")
#' build_mp4("slides.html")
#' build_mp4("slides.pdf")
#' build_mp4("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")
#' }
build_mp4 <- function(
    input,
    output_file = NULL,
    density = 100,
    slides = NULL,
    fps = 1,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1
) {
    # Check input and output files have correct extensions
    assert_path_ext(input, c("rmd", "html", "pdf"))
    assert_path_ext(output_file, "mp4")

    # Build input and output paths
    paths <- build_paths(input, output_file)

    # Build html and / or pdf (if input is not pdf)
    if (!test_path_ext(input, "pdf")) {
        build_to_pdf(input, paths, complex_slides, partial_slides, delay)
        paths <- build_paths(input = paths$output$pdf, output_file)
    }

    # Build mp4 from pdf
    input <- paths$input$pdf
    output_file <- paths$output$mp4
    proc <- cli_build_start(input, output_file)
    pngs <- pdf_to_imgs(input, density)

    # Keep only selected slides by number
    if (!is.null(slides)) {
        pngs <- pngs[slides]
    }

    temp_folder <- tempdir()
    png_root <- fs::path_ext_set(fs::path_file(output_file), "png")
    png_paths <- c()
    for (i in seq(length(pngs))) {
        png_name <- append_to_file_path(png_root, paste0("_", i))
        png_path <- magick::image_write(
            pngs[i], fs::path(temp_folder, png_name))
        png_paths <- c(png_paths, png_path)
    }

    res <- av::av_encode_video(
        input = png_paths,
        output = output_file,
        framerate = fps,
        # vfilter argument added to avoid divisible by 2 error, see:
        # https://github.com/ropensci/av/issues/2
        vfilter = "scale=trunc(iw/2)*2:trunc(ih/2)*2"
    )
    cli::cli_process_done(proc)
    res
}
