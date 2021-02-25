#' Build xaringan slides to multiple outputs.
#'
#' Build xaringan slides to multiple outputs. Options are `"html"`, `"pdf"`,
#' `"gif"`, `"pptx"`, `"png"`, and `"social"`. See each individual
#' build_*() function for details about each output type.
#' @param input Path to Rmd file of xaringan slides.
#' @param include A vector of the different output types to build. Options are
#' `"html"`, `"pdf"`, `"gif"`, `"pptx"`, `"png"`, and `"social"`.
#' Defaults to `c("html", "pdf", "gif", "pptx", "png", "social")`.
#' @param exclude A vector of the different output types to NOT build. Options
#' are `"html"`, `"pdf"`, `"gif"`, `"pptx"`, `"png"`, and `"social"`.
#' Defaults to `NULL`, in which case all all output types are built.
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
#' @param density Resolution of the resulting png files used in the png, gif,
#' and pptx output types file. Defaults to `"72x72"`.
#' @param slides A vector of the slide number(s) to return for the png output.
#' Defaults to `1`, returning only the title slide. You can get a zip
#' file of all the slides as pngs by setting `slides = "all"`).
#' @param fps Frames per second of the gif file.
#' @export
#' @examples
#' \dontrun{
#' # Builds every output by default
#' build_all("slides.Rmd")
#'
#' # Both of these build html, pdf, and gif outputs
#' build_all("slides.Rmd", include = c("html", "pdf", "gif"))
#' build_all("slides.Rmd", exclude = c("pptx", "png", "social"))
#' }
build_all <- function(
    input,
    include = c("html", "pdf", "gif", "pptx", "png", "social"),
    exclude = NULL,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1,
    density = "72x72",
    slides = 1,
    fps = 1
    ) {
    # Check that input file has the correct extension
    assert_path_ext(input, "rmd")

    # Build input and output paths
    paths <- build_paths(input, output_file = NULL)

    # Build hierarchy:
    #
    # Rmd
    #  |
    #  |--> social (png)
    #  |
    #  |--> html
    #        |
    #        |--> pdf
    #              |
    #              |--> png
    #                    |
    #                    |--> gif
    #                    |
    #                    |--> pptx
    #
    # currently calling a step out of order will create the intermediate steps
    # if at some point intermediate files are removed if not requested, the
    # logic here will need to be changed.

    include <- match.arg(include, several.ok = TRUE)
    do_soc <- ("social" %in% include) && (! "social" %in% exclude)
    do_htm <- ("html" %in% include) && (! "html" %in% exclude)
    do_pdf <- ("pdf" %in% include) && (! "pdf" %in% exclude)
    do_png <- ("png" %in% include) && (! "png" %in% exclude)
    do_gif <- ("gif" %in% include) && (! "gif" %in% exclude)
    do_ppt <- ("pptx" %in% include) && (! "pptx" %in% exclude)

    if (!fs::file_exists(paths$input$pdf) || do_htm) {
        # If the PDF doesn't exist or we're updating the html file,
        # then we need to also update the PDF if we are going to
        # built to png, gif, or pptx outputs
        if (do_png | do_gif | do_ppt) {
            do_pdf <- TRUE
        }
    }

    if (do_pdf && !fs::file_exists(paths$input$html)) {
        # to make a PDF, we need the html file
        do_htm <- TRUE
    }

    # Do each step in order to ensure updates propagate
    # (or we use the current version of the required build step)
    if (do_soc) {
        build_social(
            input = paths$input$rmd,
            output_file = paths$output$social)
    }
    if (do_htm) {
        build_html(
            input = paths$input$rmd,
            output_file = paths$output$html)
    }
    if (do_pdf) {
        build_pdf(
            input = paths$input$html,
            output_file = paths$output$pdf,
            complex_slides = complex_slides,
            partial_slides = partial_slides,
            delay = delay)
    }
    if (do_png) {
        build_png(
            input = paths$input$pdf,
            output_file = paths$output$png,
            density = density,
            slides = slides
        )
    }
    if (do_gif) {
        build_gif(
            input = paths$input$pdf,
            output_file = paths$output$gif,
            density = density,
            fps = fps)
    }
    if (do_ppt) {
        build_pptx(
            input = paths$input$pdf,
            output_file = paths$output$pptx,
            density = density)
    }

    invisible(input)
}
