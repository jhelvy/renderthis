#' Creates the html of the xaringan Rmd file.
#' @param input The Rmd file to build.
#' @param output_file The name of the path to the saved html file.
#' @export
build_html <- function(input, output_file = NULL) {
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
    if (grepl(".Rmd", input)) {
        pdf <- build_temp_pdf(input)
        root <- getPaths(input)
        file.copy(from = pdf, to = )
    } else {
        pagedown::chrome_print(
            input  = input,
            output = output_file)
    }
}

getPaths <- function(input) {


}

#' Creates a PDF of the xaringan Rmd file.
#' @param input The Rmd file to convert to a PDF.
build_temp_pdf <- function(input) {
    # Create a temporary directory and copy the Rmd file there
    folder <- tempdir()
    rmdPath <- file.path(folder, 'temp.Rmd')
    file.copy(from = input, to = rmdPath)
    # Build html as temp file, then build pdf as temp file
    html <- rmarkdown::render(
        input = rmdPath,
        output_file =  file.path(folder, 'temp.html'))
    pdf <- pagedown::chrome_print(
        input  = html,
        output = file.path(folder, 'temp.pdf'))
    return(pdf)
}

#' Creates a PNG thumbnail image of the first slide in the xaringan Rmd file
#' or html file.
#' @param input The Rmd or html file.
#' @param output_file The name of the path to the saved PNG file.
#' @export
build_thumbnail <- function(input, output_file = NULL) {
    if (grepl(".Rmd", input)) {
        input <- rmarkdown::render(
            input = input,
            output_file = tempfile(fileext = '.html'),
            output_format = 'xaringan::moon_reader')
    }
    pagedown::chrome_print(
        input  = input,
        output = output_file,
        format = "png")
}

#' Creates a GIF image of the xaringan Rmd, html, or PDF file.
#' or html file.
#' @param input The Rmd, html, or PDF file.
#' @param output_file The name of the path to the saved GIF file.
#' @param density Resolution of the resulting GIF file.
#' @export
build_gif <- function(input, output_file = NULL, density = "72x72") {
    if (grepl(".Rmd", input) | grepl(".html", input)) {
        input <- xaringanBuilder::build_pdf(
            input = input,
            output_file = tempfile(fileext = '.html'))
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
