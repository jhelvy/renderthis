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

#' Creates a html of the xaringan Rmd file.
#' @param input The Rmd file to convert to a html.
build_temp_html <- function(input, folder = NULL) {
    if (is.null(folder)) {
        folder <- tempdir()
    }
    # Copy the Rmd file to temp folder
    rmdPath <- file.path(folder, 'temp.Rmd')
    file.copy(from = input, to = rmdPath)
    # Build html as temp file
    html <- rmarkdown::render(
        input = rmdPath,
        output_file =  file.path(folder, 'temp.html'))
    return(html)
}

#' Creates a PDF of the xaringan Rmd file or html file.
#' @param input The Rmd or html file.
#' @param output_file The name of the path to the saved PDF file.
#' @export
build_pdf <- function(input, output_file = NULL) {
    if (! file.exists(input)) {
        return(NULL)
    }
    paths <- DescTools::SplitPath(input)
    if (paths$extension == "Rmd") {
        pdf <- build_temp_pdf(input)
        filename <- paste0(paths$fullpath, paths$filename, ".pdf")
        file.copy(from = pdf, to = filename)
    } else if (is.null(output_file)) {
        pagedown::chrome_print(input = input)
    } else {
        pagedown::chrome_print(
            input  = input,
            output = output_file)
    }
}

#' Creates a PDF of the xaringan Rmd file.
#' @param input The Rmd file to convert to a PDF.
build_temp_pdf <- function(input) {
    folder <- tempdir()
    html <- build_temp_html(input, folder)
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
    if (! file.exists(input)) {
        return(NULL)
    }
    paths <- DescTools::SplitPath(input)
    if (paths$extension == "Rmd") {
        thumbnail <- build_temp_thumbnail(input)
        filename <- paste0(paths$fullpath, paths$filename, ".png")
        file.copy(from = html, to = filename)
    } else if (is.null(output_file)) {
        pagedown::chrome_print(input = input, format = "png")
    } else {
        pagedown::chrome_print(
            input  = input,
            output = output_file,
            format = "png")
    }
}

#' Creates a html of the xaringan Rmd file.
#' @param input The Rmd file to compile to a html file.
build_temp_thumbnail <- function(input) {
    folder <- tempdir()
    html <- build_temp_html(input, folder)
    thumbnail <- pagedown::chrome_print(
        input  = input,
        output = file.path(folder, 'temp.png'),
        format = "png")
    return(thumbnail)
}

#' Creates a GIF image of the xaringan Rmd, html, or PDF file.
#' or html file.
#' @param input Path to the Rmd, html, or PDF file.
#' @param output_file The name of the path to the saved GIF file.
#' @param density Resolution of the resulting GIF file.
#' @export
build_gif <- function(input, output_file = NULL, density = "72x72") {
    if (! file.exists(input)) {
        return(NULL)
    }
    paths <- DescTools::SplitPath(input)
    if (paths$extension == "Rmd") {
        pdf <- build_temp_pdf(input)
    } else if (paths$extension == "html") {
        pdf <- build_temp_pdf(input)
    }
    pdf <- magick::image_read(input, density = density)
    build_gif_from_pdf(input, output_file, density)
}

#' Creates a GIF image of the xaringan PDF file.
#' or html file.
#' @param pdf The PDF file to convert to a GIF.
#' @param output_file The name of the path to the saved GIF file.
#' @param density Resolution of the resulting GIF file.
#' @export
build_gif_from_pdf <- function(pdf, output_file = NULL, density = "72x72") {
    if (! file.exists(input)) {
        return(NULL)
    }
    pngs <- list()
    for (i in 1:length(pdf)) {
        pngs[[i]] <- magick::image_convert(pdf[i], 'png')
    }
    pngs_joined <- magick::image_join(pngs)
    pngs_animated <- magick::image_animate(pngs_joined, fps = 1)
    magick::image_write(pngs_animated, output_file)
}
