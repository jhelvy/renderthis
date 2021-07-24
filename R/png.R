#' Build xaringan slides as png file(s).
#'
#' Build png image(s) of xaringan slides. The function builds to the pdf and
#' then converts it into png files of each slide. The slide numbers defined by
#' the `slides` argument are saved (defaults to `1`, returning only the title
#' slide). If `length(slides) > 1`, it will return the png files in a zip file.
#' You can also get a zip file of all the slides as pngs by setting `slides =
#' "all"`).
#'
#' @param input Path to a Rmd file, html file, pdf file, or a url. If the input
#'   is a url to xaringan slides on a website, you must provide the full url
#'   ending in ".html".
#' @param output_file Name of the output png or zip file.
#' @param density Resolution of the resulting pngs in each slide file. Defaults
#'   to `100`.
#' @param slides A numeric or integer vector of the slide number(s) to build
#'   as png files , or one of `"all"`, `"first"`, or `"last"`. Negative integers
#'   select which slides _not_ to include. If more than one slide are included,
#'   pngs will be returned as a zip file. Defaults to `"all"`, in which case
#'   all slides are included.
#' @inheritParams build_pdf
#' @param keep_intermediates Should we keep the intermediate files used to build
#'   the final output? The default is `FALSE`.
#'
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
#'
#' @export
build_png <- function(
    input,
    output_file = NULL,
    density = 100,
    slides = 1,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1,
    keep_intermediates = FALSE
) {
    assert_path_exists(input)
    keep_intermediates <- isTRUE(keep_intermediates)

    if (is.null(output_file)) {
        output_file <- path_from(input, "png")
    }

    # If user requested more than one slide, force output to a .zip file
    slides <- slides_arg_validate(slides)
    if (length(slides) > 1 || slides == "all") {
        output_file <- path_from(output_file, "zip")
    }

    # Check input and output files have correct extensions
    assert_path_ext(input, c("rmd", "html", "pdf"))
    assert_path_ext(output_file, c("png", "zip"))

    # Build html and / or pdf (if input is not pdf)
    step_pdf <- input
    if (!test_path_ext(input, "pdf")) {
        step_pdf <- path_from(output_file, "pdf", temporary = !keep_intermediates)
        build_pdf(
            input = input,
            output_file = step_pdf,
            complex_slides = complex_slides,
            partial_slides = partial_slides,
            delay = delay,
            keep_intermediates = keep_intermediates
        )
    }

    # Build png from pdf
    imgs <- pdf_to_imgs(step_pdf, density)
    # Check slides arg again to make sure all slides are in range
    slides <- slides_arg_validate(slides, imgs)

    proc <- cli_build_start(step_pdf, output_file, on_exit = "done")
    tryCatch({
        if (length(slides) > 1) {
            zip_pngs(imgs, slides, output_file)
        } else {
            magick::image_write(imgs[slides], output_file)
        }
    },
        error = cli_build_failed(proc)
    )
}

zip_pngs <- function(imgs, slides, output_file) {
    tmpdir <- withr::local_tempdir()
    png_root <- path_from(output_file, "png", dir = tmpdir)
    png_paths <- append_to_file_path(png_root, paste0("_", slides))

    for (i in seq_along(slides)) {
        magick::image_write(imgs[slides[i]], png_paths[i])
    }

    zip::zip(output_file, files = fs::path_file(png_paths), root = tmpdir)
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

    if (is.null(output_file)) {
        output_file <- path_from(input, "png")
    }

    # Check input and output files have correct extensions
    assert_path_ext(input, c("rmd", "html"))
    assert_path_ext(output_file, "png")

    # Build html (if input is rmd)
    step_html <- input
    if (test_path_ext(input, "rmd")) {
        step_html <- path_from(input, "html", temporary = TRUE)
        build_html(input, step_html)
    }

    # Build png from html
    proc <- cli_build_start(step_html, output_file, on_exit = "done")
    tryCatch({
      pagedown::chrome_print(
        input  = input,
        output = output_file,
        format = "png")
    }, error = cli_build_failed(proc))
}
