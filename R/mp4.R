#' Build xaringan slides as a mp4 video file.
#'
#' Build xaringan slides as a mp4 video file. The function builds to the pdf,
#' converts each slide in the pdf to a png, and then converts the deck of
#' png files to a mp4 video file.
#'
#' @param input Path to a Rmd file, html file, pdf file, or a url. If the input
#'   is a url to xaringan slides on a website, you must provide the full url
#'   ending in ".html".
#' @param output_file Name of the output mp4 file.
#' @param slides A numeric or integer vector of the slide number(s) to include
#'   in the mp4, or one of `"all"`, `"first"`, or `"last"`. Negative integers
#'   select which slides _not_ to include. Defaults to `"all"`, in which case
#'   all slides are included.
#' @param fps Frames per second of the resulting mp4 file.
#' @inheritParams to_png
#' @inheritParams to_pdf
#'
#' @examples
#' \dontrun{
#' # Build mp4 from Rmd, html, pdf, or url
#' to_mp4("slides.Rmd")
#' to_mp4("slides.html")
#' to_mp4("slides.pdf")
#' to_mp4("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")
#' }
#'
#' @export
to_mp4 <- function(
    input,
    output_file = NULL,
    density = 100,
    slides = "all",
    fps = 1,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1,
    keep_intermediates = FALSE
) {
    if (!requireNamespace("av", quietly = TRUE)) {
      stop("`av` is required: install.packages('av')")
    }

    if (is.null(output_file)) {
        output_file <- path_from(input, "mp4")
    }

    # Check input and output files have correct extensions
    assert_path_ext(input, c("rmd", "html", "pdf"))
    assert_path_ext(output_file, "mp4")

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

    # Build mp4 from pdf
    proc <- cli_build_start(step_pdf, output_file)
    imgs <- pdf_to_imgs(step_pdf, density)
    slides <- slides_arg_validate(slides, imgs)

    temp_folder <- withr::local_tempdir()
    png_root <- path_from(output_file, "png", dir = temp_folder)
    png_paths <- append_to_file_path(png_root, paste0("_", slides))

    for (i in seq_along(slides)) {
        magick::image_write(imgs[slides[i]], png_paths[i])
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
