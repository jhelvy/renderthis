#' Build xaringan slides as multiple outputs, including html, pdf, gif, and thumbnail of first slide.
#' @param input Path to Rmd file of xaringan slides.
#' @param include A vector of the different output types to build, including "html", "pdf", "gif", and "thumbnail".
#' @export
#' @examples
#' # Build html, pdf, gif, and thumbnail of first slide from Rmd file
#' build_all(here::here("test", "slides.Rmd"))
build_all <- function(input, include = c("html", "pdf", "gif", "thumbnail")) {
    if (! file.exists(input)) {
        return(NULL)
    }
    paths <- get_paths(input)
    if (paths$extension != "Rmd") {
        stop("input must have .Rmd extension")
    }
    # If html is in include, then build it first and build everything else
    # from it
    if ("html" %in% include) {
        build_html(input)
        if ("thumnail" %in% include) {
            build_thumbnail(paths$html)
        }
        if ("pdf" %in% include) {
            build_pdf(paths$html)
            if ("gif" %in% include) {
                build_gif(paths$pdf)
            }
        } else if ("gif" %in% include) {
                build_gif(paths$html)
        }
    # If html is not in include, check to build pdf next since it will
    # build the html
    } else if ("pdf" %in% include) {
        build_pdf(paths$html)
        if ("gif" %in% include) {
            build_gif(paths$pdf)
        }
        if ("thumnail" %in% include) {
            build_thumbnail(paths$html)
        }
    } else if ("gif" %in% include) {
        build_gif(input)
        if ("thumnail" %in% include) {
            build_thumbnail(paths$html)
        }
    } else if ("thumnail" %in% include) {
        build_thumbnail(input)
    }
}

#' Returns a named list of the split full path into its components.
#' @param input Path to Rmd file of xaringan slides.
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

#' Build xaringan slides as html file.
#' @param input Path to Rmd file of xaringan slides.
#' @param output_file Name of the output html file.
#' @examples
#' # Build html from Rmd file
#' build_html(here::here("test", "slides.Rmd"))
build_html <- function(input, output_file = NULL) {
    if (! file.exists(input)) {
        return(NULL)
    }
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
#' # Build pdf from Rmd or html file
#' build_pdf(here::here("test", "slides.Rmd"))
#' build_pdf(here::here("test", "slides.html"))
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

#' Build png thumbnail image of first xaringan slide.
#' @param input Path to Rmd or html file of xaringan slides.
#' @param output_file Name of the output png file.
#' @export
#' @examples
#' # Build first slide thumbnail from Rmd or html file
#' build_thumbnail(here::here("test", "slides.Rmd"))
#' build_thumbnail(here::here("test", "slides.html"))
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

#' Build xaringan slides as gif file.
#' @param input Path to Rmd, html, or pdf file of xaringan slides.
#' @param output_file Name of the output gif file.
#' @param density Resolution of the resulting gif file.
#' @param fps Frames per second.
#' @export
#' @examples
#' # Build gif from Rmd, html, or pdf file
#' build_gif(here::here("test", "slides.Rmd"))
#' build_gif(here::here("test", "slides.html"))
#' build_gif(here::here("test", "slides.pdf"))
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
