#' Render slides as a GIF file.
#'
#' Render slides as a GIF video file. The function renders to the PDF,
#' converts each slide in the PDF to a PNG, and then converts the deck of
#' PNG files to a GIF file.
#'
#' @param from Path to an `.Rmd`, `.qmd`, `.html`, `.pdf` file, or a URL. If
#'   `from` is a URL to slides on a website, you must provide the full URL
#'   ending in `".html"`.
#' @param to Name of the output `.gif` file.
#' @param density Resolution of the resulting PNGs in each slide file. Defaults
#'   to `100`.
#' @param slides A numeric or integer vector of the slide number(s) to include
#'   in the GIF, or one of `"all"`, `"first"`, or `"last"`. Negative integers
#'   select which slides _not_ to include. Defaults to `"all"`, in which case
#'   all slides are included.
#' @param fps Frames per second in the animated GIF.
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
#' @inheritParams to_png
#'
#' @return Slides are rendered as a `.gif` file.
#'
#' @example man/examples/examples_gif.R
#'
#' @export
to_gif <- function(
    from,
    to = NULL,
    density = 100,
    slides = "all",
    fps = 1,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1,
    keep_intermediates = FALSE
) {

    input <- from
    output_file <- to

    if (is.null(output_file)) {
        output_file <- path_from(input, "gif")
    }

    # Check input and output files have correct extensions
    assert_path_ext(output_file, "gif", arg = "to")

    # Render html and / or pdf (if input is not pdf)
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

    # Render gif from pdf
    proc <- cli_build_start(step_pdf, output_file)
    imgs <- pdf_to_imgs(step_pdf, density)
    slides <- slides_arg_validate(slides, imgs)

    # Keep only selected slides by number
    imgs <- imgs[slides]

    # Render the gif
    imgs_joined <- magick::image_join(imgs)
    imgs_animated <- magick::image_animate(imgs_joined, fps = fps)
    res <- magick::image_write(imgs_animated, output_file)

    cli::cli_process_done(proc)
    res
}
