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
#' @param slides A vector of the slide number(s) to return for the png output.
#'   Defaults to `1`, returning only the title slide. To return a zip file of
#'   all the slides as pngs, set `slides = NULL`).
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

    if (is.null(slides) || identical(tolower(slides), "all")) {
        slides <- "all"
    } else {
        stopifnot(
            "`slides` must be slide numeric slide indices" = is.numeric(slides),
            "`slides` must be slide indices >= 1" = slides > 0,
            "`slides` must be integer slide indices" = all.equal(
                slides, as.integer(slides), tolerance = .Machine$double.eps
            )
        )
        slides <- sort(unique(as.integer(slides)))
    }
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
    if (identical(slides, "all")) {
        slides <- seq_along(imgs)
    }
    slides_oob <- slides[!slides %in% seq_along(imgs)]
    if (length(slides_oob)) {
        slides <- setdiff(slides, slides_oob)
        if (length(slides)) {
            warning(
                "Some values of `slides` were out of range for this presentation: ",
                paste(slides_oob, collapse = ", ")
            )
        } else {
            stop(
                "All values of `slides` were out of range for this presentation: ",
                paste(slides_oob, collapse = ", ")
            )
        }
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
    assert_path_ext(input, c("rmd", "html"))
    assert_path_ext(output_file, "png")

    # Build input and output paths
    paths <- build_paths(input, output_file)

    # Build html (if input is rmd)
    if (test_path_ext(input, "rmd")) {
        build_html(paths$input$rmd, paths$output$html)
    }

    # Build png from html
    input <- paths$input$html
    output_file <- paths$output$thumbnail
    proc <- cli_build_start(input, output_file, on_exit = "done")
    tryCatch({
      pagedown::chrome_print(
        input  = input,
        output = output_file,
        format = "png")
    }, error = cli_build_failed(proc))
}
