# Build hierarchy is html, pdf / png, gif / pptx.
# - build_pdf() creates the pdf from the html file, so if the input is
#   a .Rmd file, it calls build_html() to create the html file, then builds
#   the pdf. If the input is a html file, it just builds the pdf.
# - build_gif() creates the gif from the pdf file, so if the input is
#   a .Rmd file, it calls build_pdf() (which calls build_html()) to create the
#   html and pdf files, then builds the gif file. If the input is a html file,
#   it calls build_pdf() to create the the pdf before building the gif file.
#   If the input is the pdf, it just builds the gif from the pdf.
# - build_pptx() creates the pptx from the pdf file, so if the input is
#   a .Rmd file, it calls build_pdf() (which calls build_html()) to create the
#   html and pdf files, then builds the pptx file. If the input is a html file,
#   it calls build_pdf() to create the the pdf before building the pptx file.
#   If the input is the pdf, it just builds the pptx from the pdf.
# - build_thumbnail() creates the png from the html file, so if the input is
#   a .Rmd file, it calls build_html() to create the html file, then builds
#   the png. If the input is a html file, it just builds the png.

#' Build xaringan slides to multiple outputs.
#'
#' Build xaringan slides to multiple outputs. Options are `"html"`, `"pdf"`,
#' `"gif"`, `"pptx"`, and `"thumbnail"` (a png image of the first slide).
#' Note: If you want to include "complex" slides (e.g. slides with panelsets
#' or other html widgets or advanced features), or you want to include partial
#' (continuation) slides, then use `build_pdf()` with `complex_slides = TRUE`
#' and / or `partial_slides = TRUE` to build the pdf first, then use
#' `build_all()`.
#' @param input Path to Rmd file of xaringan slides.
#' @param include A vector of the different output types to build. Options are
#' `"html"`, `"pdf"`, `"gif"`, `"pptx"`, and `"thumbnail"` (a png image of the
#' first slide). Defaults to `c("html", "pdf", "gif", "pptx", "thumbnail")`.
#' @param exclude A vector of the different output types to NOT build. Options
#' are `"html"`, `"pdf"`, `"gif"`, `"pptx"`, and `"thumbnail"` (a png image of
#' the first slide). Defaults to `NULL`, in which case all all output types
#' are rendered.
#' @export
#' @examples
#' \dontrun{
#' # Builds every output by default
#' build_all("slides.Rmd")
#'
#' # Choose which output types to include
#' build_all("slides.Rmd", include = c("html", "pdf", "gif"))
#'
#' # Choose which output types to exclude
#' build_all("slides.Rmd", exclude = c("pptx", "thumbnail"))
#' }
build_all <- function(input, include = c("html", "pdf", "gif", "pptx", "thumbnail"), exclude = NULL) {
    assert_path_ext(input, "rmd")
    input <- fs::path_abs(input)
    input_html <- fs::path_ext_set(input, "html")
    input_pdf <- fs::path_ext_set(input, "pdf")

    include <- match.arg(include, several.ok = TRUE)
    do_htm <- ("html" %in% include) && (! "html" %in% exclude)
    do_pdf <- ("pdf" %in% include) && (! "pdf" %in% exclude)
    do_gif <- ("gif" %in% include) && (! "gif" %in% exclude)
    do_ppt <- ("pptx" %in% include) && (! "pptx" %in% exclude)
    do_thm <- ("thumbnail" %in% include) && (! "thumbnail" %in% exclude)

    # each step requires the format of the previous step
    # html -> pdf -> gif / pptx
    #
    # currently calling a step out of order will create the intermediate steps
    # if at some point intermediate files are removed if not requested, the
    # logic here will need to be changed.

    if (do_gif && (!fs::file_exists(input_pdf) || do_htm)) {
        # to make a gif we need the PDF file
        # or if we update the HTML, we should also update the PDF for the gif
        do_pdf <- TRUE
    }
    if (do_ppt && (!fs::file_exists(input_pdf) || do_htm)) {
        # to make a pptx we need the PDF file
        # or if we update the HTML, we should also update the PDF for the pptx
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
    if (do_ppt) build_pptx(input_pdf)
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
    input_file_html <- fs::path_file(fs::path_ext_set(input, "html"))

    cli::cli_process_start(
        "Building {.file {input_file_html}} from {.path {fs::path_file(input)}}",
        on_exit = "done"
    )
    rmarkdown::render(
        input = input,
        output_file = output_file,
        output_format = 'xaringan::moon_reader',
        quiet = TRUE
    )
}

#' Print xaringan slides to PDF.
#'
#' Prints xaringan slides to a PDF file. For "complex" slides (e.g. slides
#' with panelsets or other html widgets or advanced features), set
#' `complex_slides = TRUE` (defaults to `FALSE`). To include partial
#' (continuation) slides, set `partial_slides = TRUE` (defaults to `FALSE`).
#' For either `complex_slides = TRUE` or `partial_slides = TRUE`, a local
#' installation of Chrome is required.
#' @param input Path to Rmd or html file of xaringan slides.
#' @param output_file The name of the output file. If `NULL` (the default) then
#' the output filename will be based on filename for the input file.
#' If a filename is provided, a path to the output file can also be provided.
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
#' @export
#' @examples
#' \dontrun{
#' # Build simple pdf from Rmd or html file
#' build_pdf("slides.Rmd")
#' build_pdf("slides.html")
#'
#' # Build simple pdf from Rmd or html file and include
#' # partial (continuation) slides
#' build_pdf("slides.Rmd", partial_slides = TRUE)
#' build_pdf("slides.html", partial_slides = TRUE)
#'
#' # Build "complex" xaringan slides to pdf from Rmd or html file
#' build_pdf("slides_complex.Rmd", complex_slides = TRUE)
#' build_pdf("slides_complex.html", complex_slides = TRUE)
#'
#' # Build "complex" xaringan slides to pdf from Rmd or html file and include
#' # partial (continuation) slides
#' build_pdf(input = "slides_complex.Rmd",
#'           output_file = "slides_complex_partial.pdf",
#'           complex_slides = TRUE,
#'           partial_slides = TRUE)
#' build_pdf(input = "slides_complex.html",
#'           output_file = "slides_complex_partial.pdf",
#'           complex_slides = TRUE,
#'           partial_slides = TRUE)
#' }
build_pdf <- function(
  input,
  output_file = NULL,
  complex_slides = FALSE,
  partial_slides = FALSE,
  delay = 1
) {
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

    if (complex_slides | partial_slides) {
        build_pdf_complex(input, output_file, partial_slides, delay)
    } else {
        build_pdf_simple(input, output_file)
    }
}

#' Print "simple" xaringan slides to PDF
#'
#' Prints "simple" xaringan slides - those without panelsets or other html
#' widgets or advanced features, and also slides without partial slides.
#'
#' @param input Path to Rmd or html file of xaringan slides.
#' @param output_file The name of the output file. If `NULL` (the default) then
#' the output filename will be based on filename for the input file.
#' If a filename is provided, a path to the output file can also be provided.
build_pdf_simple <- function(input, output_file) {
    cli::cli_process_start(
        "Building {.file {fs::path_file(output_file)}} from {.path {fs::path_file(input)}}",
        on_exit = "done"
    )
    pagedown::chrome_print(
        input  = input,
        output = output_file)
}

# build_pdf_complex() was previously xaringan_to_pdf(), added by gadenbuie
# in v0.0.2. He also posted it on his blog here:
# https://www.garrickadenbuie.com/blog/print-xaringan-chromote/

#' Print "complex" xaringan slides to PDF
#'
#' Prints "complex" xaringan slides (e.g. slides with panelsets or other html
#' widgets or advanced features) to a PDF file. Requires a local installation
#' of Chrome.
#'
#' @param input Path to Rmd or html file of xaringan slides.
#' @param output_file The name of the output file. If `NULL` (the default) then
#' the output filename will be based on filename for the input file.
#' If a filename is provided, a path to the output file can also be provided.
#' @param partial_slides Should partial (continuation) slides be
#' included in the output? If `FALSE`, the default, only the complete slide
#' is included in the PDF.
#' @param delay Seconds of delay between advancing to and printing
#' a new slide.
build_pdf_complex <- function(input, output_file, partial_slides, delay) {
  if (!requireNamespace("chromote", quietly = TRUE)) {
    stop("`chromote` is required: devtools::install_github('rstudio/chromote')")
  }
  if (!requireNamespace("pdftools", quietly = TRUE)) {
    stop("`pdftools` is required: install.packages('pdftools')")
  }

  is_url <- grepl("^(ht|f)tp", tolower(input))

  if (is.null(output_file)) {
    if (is_url) {
      output_file <- fs::path_ext_set(fs::path_file(input), "pdf")
    } else {
      output_file <- fs::path_ext_set(input, "pdf")
    }
  }

  if (!is_url && !grepl("^file://", input)) {
    if (!tolower(fs::path_ext(input)) %in% c("htm", "html")) {
      stop("`input` must be the HTML version of the slides.")
    }
    input <- paste0("file://", fs::path_abs(input))
  }

  b <- chromote::ChromoteSession$new()
  on.exit(b$close(), add = TRUE)

  b$Page$navigate(input, wait_ = TRUE)
  b$Page$loadEventFired()

  has_remark <- b$Runtime$evaluate("typeof slideshow !== 'undefined'")$result$value
  if (!has_remark) {
    stop("Input does not appear to be xaringan slides: ", input)
  }

  current_slide <- function() {
    x <- b$Runtime$evaluate("slideshow.getCurrentSlideIndex()")$result$value
    as.integer(x) + 1L
  }

  slide_is_continuation <- function() {
    b$Runtime$evaluate(
      "document.querySelector('.remark-visible').matches('.has-continuation')"
    )$result$value
  }

  hash_current_slide <- function() {
    digest::digest(b$Runtime$evaluate(
      "document.querySelector('.remark-visible').innerHTML"
    )$result$value)
  }

  get_ratio <- function() {
    r <- b$Runtime$evaluate('slideshow.getRatio()')$result$value
    r <- lapply(strsplit(r, ":"), as.integer)
    width <- r[[1]][1]
    height <- r[[1]][2]
    page_width <- 8/width * width
    list(
      width = as.integer(908 * width / height),
      height = 681L,
      page = list(width = page_width, height = page_width * height / width)
    )
  }

  slide_size <- get_ratio()

  expected_slides <- as.integer(
    b$Runtime$evaluate("slideshow.getSlideCount()")$result$value
  )

  max_slides <- expected_slides * 4

  b$Browser$setWindowBounds(1, bounds = list(
    width = slide_size$width,
    height = slide_size$height
  ))

  b$Emulation$setEmulatedMedia("print")
  b$Runtime$evaluate(paste0(
    "let style = document.createElement('style')\n",
    "style.innerText = '@media print { ",
    ".remark-slide-container:not(.remark-visible){ display:none; }",
    if (partial_slides) " .has-continuation { display: block }",
    "}'\n",
    "document.head.appendChild(style)"
  ))

  cli::cli_process_start(
    "Building {.file {fs::path_file(output_file)}} from {.path {fs::path_file(input)}}",
    on_exit = "done"
  )

  pb <- progress::progress_bar$new(
    format = "Slide :slide (:part) [:bar] Eta: :eta",
    total = expected_slides
  )

  idx_slide <- current_slide()
  last_hash <- ""
  idx_part <- 0L
  pdf_files <- c()
  for (i in seq_len(max_slides)) {
    if (i > 1) {
      b$Input$dispatchKeyEvent(
        "rawKeyDown",
        windowsVirtualKeyCode = 39,
        code = "ArrowRight",
        key = "ArrowRight",
        wait_ = TRUE
      )
    }

    if (current_slide() == idx_slide) {
      step <- 0L
      idx_part <- idx_part + 1L
    } else {
      step <- 1L
      idx_part <- 1L
    }
    idx_slide <- current_slide()
    pb$tick(step, tokens = list(slide = idx_slide, part = idx_part))

    if (!isTRUE(partial_slides) && slide_is_continuation()) next
    Sys.sleep(delay)

    this_hash <- hash_current_slide()
    if (identical(last_hash, this_hash)) break
    last_hash <- this_hash

    pdf_file_promise <- b$Page$printToPDF(
      landscape = TRUE,
      printBackground = TRUE,
      paperWidth = 12,
      paperHeight = 9,
      marginTop = 0,
      marginRight = 0,
      marginBottom = 0,
      marginLeft = 0,
      pageRanges = "1",
      preferCSSPageSize = TRUE,
      wait_ = FALSE
    )$then(function(value) {
      filename <- tempfile(fileext = ".pdf")
      writeBin(jsonlite::base64_dec(value$data), filename)
      filename
    })
    pdf_files <- c(pdf_files, b$wait_for(pdf_file_promise))
  }

  pdftools::pdf_combine(pdf_files, output = output_file)
  fs::file_delete(pdf_files)

  invisible(output_file)
}

#' Build xaringan slides as gif file.
#'
#' Build xaringan slides as gif file. Note: If you want to include "complex"
#' slides (e.g. slides with panelsets or other html widgets or advanced
#' features), or you want to include partial (continuation) slides, then use
#' `build_pdf()` with `complex_slides = TRUE` and / or `partial_slides = TRUE`
#' to build the pdf first, then use `build_gif()` with the pdf as the input.
#' @param input Path to Rmd, html, or pdf file of xaringan slides.
#' @param output_file Name of the output gif file.
#' @param density Resolution of the resulting gif file.
#' @param fps Frames per second of the resulting gif file.
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
    cli::cli_process_start(
        "Building {.file {fs::path_file(output_file)}} from {.path {fs::path_file(input)}}",
        on_exit = "done"
    )
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
    cli::cli_process_start(
        "Building {.file {fs::path_file(output_file)}} from {.path {fs::path_file(input)}}",
        on_exit = "done"
    )
    pagedown::chrome_print(
        input  = input,
        output = output_file,
        format = "png")
}

#' Build xaringan slides as pptx file.
#'
#' Build xaringan slides as pptx file. Note: If you want to include "complex"
#' slides (e.g. slides with panelsets or other html widgets or advanced
#' features), or you want to include partial (continuation) slides, then use
#' `build_pdf()` with `complex_slides = TRUE` and / or `partial_slides = TRUE`
#' to build the pdf first, then use build_gif() with the pdf as the input.
#' @param input Path to Rmd, html, or pdf file of xaringan slides.
#' @param output_file Name of the output pptx file.
#' @param density Resolution of the resulting pptx file.
#' @export
#' @examples
#' \dontrun{
#' # Build gif from Rmd, html, or pdf file
#' build_pptx("slides.Rmd")
#' build_pptx("slides.html")
#' build_pptx("slides.pdf")
#' }
build_pptx <- function(input, output_file = NULL, density = "72x72") {
    if (!requireNamespace("officer", quietly = TRUE)) {
        stop("`officer` is required: install.packages('officer')")
    }

    assert_path_ext(input, c("rmd", "html", "pdf"))
    input <- fs::path_abs(input)

    if (test_path_ext(input, c("rmd", "html"))) {
        build_pdf(input, output_file)
        input <- fs::path_ext_set(input, "pdf")
    }

    if (is.null(output_file)) {
        output_file <- fs::path_ext_set(input, "pptx")
    } else if (test_path_ext(output_file, "pptx")) {
        stop("`output_file` should be NULL or have .pptx extension")
    }
    cli::cli_process_start(
        "Building {.file {fs::path_file(output_file)}} from {.path {fs::path_file(input)}}",
        on_exit = "done"
    )
    pdf <- magick::image_read(input, density = density)
    pngs <- magick::image_convert(pdf, 'png')

    doc <- officer::read_pptx()
    for (i in 1:length(pngs)) {
        png_path <- magick::image_write(
            pngs[i], tempfile(fileext = ".png"))
        doc <- officer::add_slide(
            doc,
            layout = "Blank",
            master = "Office Theme"
        )
        doc <- officer::ph_with(
            doc,
            value = officer::external_img(png_path),
            location = officer::ph_location_fullsize()
        )
    }

    print(doc, output_file)
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
