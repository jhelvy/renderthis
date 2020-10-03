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
#' # Build html, pdf, gif, and thumbnail of first slide from Rmd file
#' build_all(here::here("test", "slides.Rmd"))
build_all <- function(input, include = c("html", "pdf", "gif", "thumbnail")) {
    paths <- get_paths(input)
    if (! paths$extension %in% c("Rmd", "rmd")) {
        stop("input must have .Rmd extension")
    }
    # If html is in include, then build it first and build everything else
    # from it
    html <- "html" %in% include
    pdf <- "pdf" %in% include
    gif <- "gif" %in% include
    thumbnail <- "thumbnail" %in% include
    if (html) {
        build_html(input)
        if (pdf) {
            build_pdf(paths$html)
            if (gif) {
                build_gif(paths$pdf)
            }
        } else if (gif) {
            build_gif(paths$html)
        }
        if (thumbnail) {
            build_thumbnail(paths$html)
        }
    # If html is not in include, check to build pdf next since it will
    # build the html
    } else if (pdf) {
        build_pdf(paths$html)
        if (gif) {
            build_gif(paths$pdf)
        }
        if (thumbnail) {
            build_thumbnail(paths$html)
        }
    } else if (gif) {
        build_gif(input)
        if (thumbnail) {
            build_thumbnail(paths$html)
        }
    } else if (thumbnail) {
        build_thumbnail(input)
    }
}

#' Build xaringan slides as html file.
#' @param input Path to Rmd file of xaringan slides.
#' @param output_file The name of the output file. If using NULL then
#' the output filename will be based on filename for the input file.
#' If a filename is provided, a path to the output file can also be provided.
#' @export
#' @examples
#' # Build html from Rmd file
#' build_html(here::here("test", "slides.Rmd"))
build_html <- function(input, output_file = NULL) {
    paths <- get_paths(input)
    if (! paths$extension %in% c("Rmd", "rmd")) {
        stop("input must have .Rmd extension")
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
    paths <- get_paths(input)
    if (! paths$extension %in% c("Rmd", "rmd", "html")) {
        stop("input must have .Rmd or .html extension")
    }
    if (paths$extension %in% c("Rmd", "rmd")) {
        build_html(input, output_file)
        input <- paths$html
    }
    if (is.null(output_file)) {
        output_file <- paths$pdf
    } else if (get_paths(output_file)$extension != "pdf") {
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
#' # Build gif from Rmd, html, or pdf file
#' build_gif(here::here("test", "slides.Rmd"))
#' build_gif(here::here("test", "slides.html"))
#' build_gif(here::here("test", "slides.pdf"))
build_gif <- function(input, output_file = NULL, density = "72x72", fps = 1) {
    paths <- get_paths(input)
    if (! paths$extension %in% c("Rmd", "rmd", "html", "pdf")) {
        stop("input must have .Rmd, .html, or .pdf extension")
    }
    if (paths$extension %in% c("Rmd", "rmd", "html")) {
        build_pdf(input, output_file)
        input <- paths$pdf
    }
    if (is.null(output_file)) {
        output_file <- paths$gif
    } else if (get_paths(output_file)$extension != "gif") {
        stop("output_file should be NULL or have .gif extension")
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
#' # Build first slide thumbnail from Rmd or html file
#' build_thumbnail(here::here("test", "slides.Rmd"))
#' build_thumbnail(here::here("test", "slides.html"))
build_thumbnail <- function(input, output_file = NULL) {
    paths <- get_paths(input)
    if (! paths$extension %in% c("Rmd", "rmd", "html")) {
        stop("input must have .Rmd or .html extension")
    }
    if (paths$extension %in% c("Rmd", "rmd")) {
        build_html(input, output_file)
        input <- paths$html
    }
    if (is.null(output_file)) {
        output_file <- paths$png
    } else if (get_paths(output_file)$extension != "png") {
        stop("output_file should be NULL or have .png extension")
    }
    pagedown::chrome_print(
        input  = input,
        output = output_file,
        format = "png")
}

#' Returns a named list of the split full path into its components.
#' @param input Path to Rmd file of xaringan slides.
get_paths <- function(input) {
    paths      <- SplitPath(input)
    paths$html <- paste0(paths$fullpath, paths$filename, ".html")
    paths$pdf  <- paste0(paths$fullpath, paths$filename, ".pdf")
    paths$png  <- paste0(paths$fullpath, paths$filename, ".png")
    paths$gif  <- paste0(paths$fullpath, paths$filename, ".gif")
    return(paths)
}

#' Split a full path in its components. This is specifically an issue
#' in Windows and not really interesting for other OSs. Modified
#' from DescTools::SplitPath()
#' @param path a path
#' @param last.is.file logical, determining if the basename should be
#' interpreted as filename or as last directory. If set to NULL (default),
#' the last entry will be interpreted if the last character is either \ or
#' / and as filename else.
SplitPath <- function(path, last.is.file=NULL) {
    if(is.null(last.is.file)){
        # if last sign is delimiter / or \ read path as dirname
        last.is.file <- (length(grep(pattern="[/\\]$", path)) == 0)
    }
    path <- normalizePath(path, mustWork = FALSE)
    lst <- list()
    lst$normpath <- path
    if (.Platform$OS.type == "windows") {
        lst$drive <- regmatches(path,
            regexpr("^([[:alpha:]]:)|(\\\\[[:alnum:]]+)", path))
        lst$dirname <- gsub(pattern=lst$drive, x=dirname(path), replacement="")
    } else {
        lst$drive <- NA
        lst$dirname <- dirname(path)
    }
    lst$dirname <- paste(lst$dirname, "/", sep="")
    lst$fullfilename <- basename(path)
    lst$fullpath <- paste0(BlankIfNA(lst$drive), lst$dirname)
    lst$filename <- gsub(pattern="(.*)\\.(.*)$", "\\1",lst$fullfilename)
    # use the positive lookbehind here
    lst$extension <- StrExtract(
        pattern = "(?<=\\.)[^\\.]+$", lst$fullfilename, perl=TRUE)
    # see also tools::file_path_sans_ext() and tools::file_ext()
    # but has a less general regex
    if(!last.is.file){
        lst$dirname <- paste0(lst$dirname, lst$fullfilename, "/")
        lst$extension <- lst$filename <- lst$fullfilename <- NA
    }
    return(lst)
}

#' Replace NAs in a numeric vector x with 0. This function has the same logic
#' as the zeroifnull function in SQL. NAIfZero() does replace zeros with NA.
#' BlankIfNA() and NAIfBlank() do the same, but for character vectors.
#' Copied directly from DescTools::BlankIfNA()
#' @param x the vector x, whose NAs should be overwritten with 0s.
#' @param blank a character to be used for "blank". Default is an empty string ("").
BlankIfNA <- function(x, blank="") {
    #  same as zeroifnull but with characters
    replace(x, is.na(x), blank)
}

#' Extract a part of a string, defined as regular expression.
#' Copied directly from DescTools::StrExtract()
#' @param x a character vector where matches are sought, or an object which
#' can be coerced by as.character to a character vector.
#' @param pattern character string containing a regular expression (or
#' character string for fixed = TRUE) to be matched in the given character
#' vector. Coerced by as.character to a character string if possible.
#' If a character vector of length 2 or more is supplied, the first
#' element is used with a warning. Missing values are not allowed.
#' @param ... the dots are passed to the the internally used function
#' regexpr(), which allows to use e.g. Perl-like regular expressions.
StrExtract <- function(x, pattern, ...) {
    # example regmatches
    ## Match data from regexpr()
    m <- regexpr(pattern, x, ...)
    regmatches(x, m)

    res <- rep(NA_character_, length(m))
    res[ZeroIfNA(m)>0] <- regmatches(x, m)
    res
}

#' Replace NAs in a numeric vector x with 0. This function has the same
#' logic as the zeroifnull function in SQL. NAIfZero() does replace
#' zeros with NA. BlankIfNA() and NAIfBlank() do the same, but for
#' character vectors. Copied directly from DescTools::ZeroIfNA()
#' @param x the vector x, whose NAs should be overwritten with 0s.
ZeroIfNA <- function(x) {
    #  same as zeroifnull in SQL
    replace(x, is.na(x), 0L)
}
