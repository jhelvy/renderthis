# Build hierarchy is html, pdf / png, gif.
# - build_pdf() creates the pdf from the html file, so if the input is
#   a .Rmd file, it calls build_html() to create the html file, then builds
#   the pdf. If the input is a html file, it just builds the pdf.
# - build_gif() creates the gif from the pdf file, so if the input is
#   a .Rmd file, it calls build_pdf() (which calls build_html()) to create the
#   html and pdf files, then builds the gif file. If the input is a html file,
#   it calls build_pdf() to create the the pdf before building the gif file.
#   If the input is the pdf, it just builds the gif from the pdf.
# - build_thumbnail() creates the png from the html file, so if the input is
#   a .Rmd file, it calls build_html() to create the html file, then builds
#   the png. If the input is a html file, it just builds the png.

#' Build xaringan slides as multiple outputs, including html, pdf, gif, and thumbnail of first slide.
#' @param input Path to Rmd file of xaringan slides.
#' @param include A vector of the different output types to build, including "html", "pdf", "gif", and "thumbnail".
#' @export
#' @examples
#' \dontrun{
#' # Build html, pdf, gif, and thumbnail of first slide from Rmd file
#' build_all("slides.Rmd")
#' }
build_all <- function(input, include = c("html", "pdf", "gif", "thumbnail")) {
    assert_path_ext(input, "rmd")
    input <- fs::path_abs(input)
    input_html <- fs::path_ext_set(input, "html")
    input_pdf <- fs::path_ext_set(input, "pdf")

    include <- match.arg(include, several.ok = TRUE)
    do_htm <- "html" %in% include
    do_pdf <- "pdf" %in% include
    do_gif <- "gif" %in% include
    do_thm <- "thumbnail" %in% include

    # each step requires the format of the previous step
    # html -> pdf -> gif
    #
    # currently calling a step out of order will create the intermediate steps
    # if at some point intermediate files are removed if not requested, the
    # logic here will need to be changed.

    if (do_gif && (!fs::file_exists(input_pdf) || do_htm)) {
        # to make a gif we need the PDF file
        # or if we update the HTML, we should also update the PDF for the gif
        do_pdf <- TRUE
    }
    if ((do_pdf || do_thm) && !fs::file_exists(input_html)) {
        # to make a PDF or thumbnail we need the html file
        do_htm <- TRUE
    }

    # Do each step in order to ensure updates propagate
    # (or we use the current version of the required build step)
    if (do_htm) build_html(input)
    if (do_pdf) build_pdf(input_html)
    if (do_gif) build_gif(input_pdf)
    if (do_thm) build_thumbnail(input_html)

    invisible(input)
}

#' Build xaringan slides as html file.
#' @param input Path to Rmd file of xaringan slides.
#' @param output_file The name of the output file. If using NULL then
#' the output filename will be based on filename for the input file.
#' If a filename is provided, a path to the output file can also be provided.
#' @export
#' @examples
#' \dontrun{
#' # Build html from Rmd file
#' build_html("slides.Rmd")
#' }
build_html <- function(input, output_file = NULL) {
    assert_path_ext(input, "rmd")
    input <- fs::path_abs(input)

    rmarkdown::render(
        input = input,
        output_file = output_file,
        output_format = 'xaringan::moon_reader')
}

#' Build xaringan slides as pdf file.
#' @param input Path to Rmd or html file of xaringan slides.
#' @param output_file Name of the output pdf file.
#' @export
#' @examples
#' \dontrun{
#' # Build pdf from Rmd or html file
#' build_pdf("slides.Rmd")
#' build_pdf("slides.html")
#' }
build_pdf <- function(input, output_file = NULL) {
    assert_path_ext(input, c("rmd", "html"))
    input <- fs::path_abs(input)

    if (test_path_ext(input, "rmd")) {
        build_html(input, output_file)
        input <- fs::path_ext_set(input, "html")
    }
    if (is.null(output_file)) {
        output_file <- fs::path_ext_set(input, "pdf")
    } else if (!test_path_ext(output_file, "pdf")) {
        stop("output_file should be NULL or have .pdf extension")
    }
    pagedown::chrome_print(
        input  = input,
        output = output_file)
}

#' Build xaringan slides as gif file.
#' @param input Path to Rmd, html, or pdf file of xaringan slides.
#' @param output_file Name of the output gif file.
#' @param density Resolution of the resulting gif file.
#' @param fps Frames per second.
#' @export
#' @examples
#' \dontrun{
#' # Build gif from Rmd, html, or pdf file
#' build_gif("slides.Rmd")
#' build_gif("slides.html")
#' build_gif("slides.pdf")
#' }
build_gif <- function(input, output_file = NULL, density = "72x72", fps = 1) {
    assert_path_ext(input, c("rmd", "html", "pdf"))
    input <- fs::path_abs(input)

    if (test_path_ext(input, c("rmd", "html"))) {
        build_pdf(input, output_file)
        input <- fs::path_ext_set(input, "pdf")
    }

    if (is.null(output_file)) {
        output_file <- fs::path_ext_set(input, "gif")
    } else if (test_path_ext(output_file, "gif")) {
        stop("`output_file` should be NULL or have .gif extension")
    }
    pdf <- magick::image_read(input, density = density)
    pngs <- magick::image_convert(pdf, 'png')
    pngs_joined <- magick::image_join(pngs)
    pngs_animated <- magick::image_animate(pngs_joined, fps = fps)
    magick::image_write(pngs_animated, output_file)
}

#' Build png thumbnail image of first xaringan slide.
#' @param input Path to Rmd or html file of xaringan slides.
#' @param output_file Name of the output png file.
#' @export
#' @examples
#' \dontrun{
#' # Build first slide thumbnail from Rmd or html file
#' build_thumbnail("slides.Rmd")
#' build_thumbnail("slides.html")
#' }
build_thumbnail <- function(input, output_file = NULL) {
    assert_path_ext(input, c("rmd", "html"))
    input <- fs::path_abs(input)

    if (test_path_ext(input, "rmd")) {
        build_html(input, output_file)
        input <- fs::path_ext_set(input, "html")
    }
    if (is.null(output_file)) {
        output_file <- fs::path_ext_set(input, "png")
    } else if (test_path_ext(output_file, "png")) {
        stop("output_file should be NULL or have .png extension")
    }
    pagedown::chrome_print(
        input  = input,
        output = output_file,
        format = "png")
}

test_path_ext <- function(path, expected_ext) {
    tolower(fs::path_ext(path)) %in% expected_ext
}

assert_path_ext <- function(path, expected_ext, arg = "input") {
    if (!test_path_ext(path, expected_ext)) {
        expected_ext <- paste0(".", expected_ext, collapse = ", ")
        stop("`", arg, "` must have extension: ", expected_ext, call. = FALSE)
    }
}
