#' Render slides as PNG file(s).
#'
#' Render PNG image(s) of slides. The function renders to the PDF and
#' then converts it into PNG files of each slide. The slide numbers defined by
#' the `slides` argument are saved (defaults to `1`, returning only the title
#' slide). If `length(slides) > 1`, it will return the PNG files in a ZIP file.
#' You can also get a ZIP file of all the slides as PNGs by setting `slides =
#' "all"`).
#'
#' @param to Name of the output `.png` or `.zip` file.
#' @param density Resolution of the resulting PNGs in each slide file. Defaults
#'   to `100`.
#' @param slides A numeric or integer vector of the slide number(s) to render
#'   as PNG files , or one of `"all"`, `"first"`, or `"last"`. Negative integers
#'   select which slides _not_ to include. If more than one slide are included,
#'   PNGs will be returned as a ZIP file. Defaults to `"all"`, in which case
#'   all slides are included.
#' @inheritParams to_gif
#' @inheritParams to_pdf
#' @param keep_intermediates Should we keep the intermediate files used to
#'   render the final output? The default is `FALSE`.
#'
#' @return Slides are rendered as a `.png` file (single) or `.zip` file of
#'   multiple `.png` files.
#'
#' @example man/examples/examples_png.R
#'
#' @export
to_png <- function(
    from,
    to = NULL,
    density = 100,
    slides = 1,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1,
    keep_intermediates = FALSE
) {

    input <- from
    output_file <- to

    assert_path_exists(input)
    keep_intermediates <- isTRUE(keep_intermediates)

    if (is.null(output_file)) {
        output_file <- path_from(input, "png")
    }

    # Check if slides argument is valid before proceeding
    slides <- slides_arg_validate(slides)

    # Check input and output files have correct extensions
    assert_path_ext(output_file, c("png", "zip"), arg = "from")

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

    # Render png from pdf
    imgs <- pdf_to_imgs(step_pdf, density)

    # Check slides arg again to make sure all slides are in range
    slides <- slides_arg_validate(slides, imgs)

    # If user requested more than one slide, force output to a .zip file
    if (length(slides) > 1 || slides == "all") {
        output_file <- path_from(output_file, "zip")
    }

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
