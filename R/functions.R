#' Creates the html of the xaringan Rmd file.
#' @param input The Rmd file to build.
#' @param output_file The name of the path to the saved html file.
#' @export
build_html <- function(input, output_file = NULL) {
    if (! file.exists(input)) {
        return(NULL)
    }
    rmarkdown::render(
        input = input,
        output_file = output_file,
        output_format = 'xaringan::moon_reader')
}

#' Creates a PDF of the xaringan Rmd file or html file.
#' @param input The Rmd or html file.
#' @param output_file The name of the path to the saved PDF file.
#' @export
build_pdf <- function(input, output_file = NULL) {
    if (! file.exists(input)) {
        return(NULL)
    }
    paths <- get_paths(input)
    if (paths$extension == "Rmd") {
        build_html(input, output_file)
        input <- paths$html
    }
    if (is.null(output_file)) {
        output_file <- paths$pdf
    }
    pagedown::chrome_print(
        input  = input,
        output = output_file)
}

#' Returns a named list of the split full path into its components
#' @param input The path to a file.
#' @export
get_paths <- function(input) {
    if (! file.exists(input)) {
        return(NULL)
    }
    paths <- DescTools::SplitPath(input)
    paths$html <- paste0(paths$fullpath, paths$filename, ".html")
    paths$pdf <- paste0(paths$fullpath, paths$filename, ".pdf")
    paths$png <- paste0(paths$fullpath, paths$filename, ".png")
    paths$gif <- paste0(paths$fullpath, paths$filename, ".gif")
    return(paths)
}

#' Creates a PNG thumbnail image of the first slide in the xaringan Rmd file
#' or html file.
#' @param input The Rmd or html file.
#' @param output_file The name of the path to the saved PNG file.
#' @export
build_thumbnail <- function(input, output_file = NULL) {
    if (! file.exists(input)) {
        return(NULL)
    }
    paths <- get_paths(input)
    if (paths$extension == "Rmd") {
        build_html(input, output_file)
        input <- paths$html
    }
    if (is.null(output_file)) {
        output_file <- paths$png
    }
    pagedown::chrome_print(
        input  = input,
        output = output_file,
        format = "png")
}

#' Creates a GIF image of the xaringan Rmd, html, or PDF file.
#' or html file.
#' @param input Path to the Rmd, html, or PDF file.
#' @param output_file The name of the path to the saved GIF file.
#' @param density Resolution of the resulting GIF file.
#' @param fps Frames per second.
#' @export
build_gif <- function(input, output_file = NULL, density = "72x72", fps = 1) {
    if (! file.exists(input)) {
        return(NULL)
    }
    paths <- get_paths(input)
    if ((paths$extension == "Rmd") | (paths$extension == "html")) {
        build_pdf(input, output_file)
        input <- paths$pdf
    }
    if (is.null(output_file)) {
        output_file <- paths$gif
    }
    pdf <- magick::image_read(input, density = density)
    pngs <- list()
    for (i in 1:length(pdf)) {
        pngs[[i]] <- magick::image_convert(pdf[i], 'png')
    }
    pngs_joined <- magick::image_join(pngs)
    pngs_animated <- magick::image_animate(pngs_joined, fps = 1)

    magick::image_write(pngs_animated, output_file)
}
