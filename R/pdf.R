#' Render slides as PDF file.
#'
#' Render slides as a PDF file. Requires a local installation of Chrome.
#' If you set `complex_slides = TRUE` or `partial_slides = TRUE`, you will also
#' need to install the {chromote} and {pdftools} packages.
#'
#' @param from Path to an `.Rmd`, `.qmd`, `.html` file, or a URL. If `from` is a
#'   URL to slides on a website, you must provide the full URL ending in
#'   `".html"`.
#' @param to The name of the output `.pdf` file. If `NULL` (the default) then
#'   the output filename will be based on filename for the `from` file. If a
#'   filename is provided, a path to the output file can also be provided.
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
#' @param keep_intermediates Should we keep the intermediate HTML file? Only
#'   relevant if the `from` file is an `.Rmd` file. Default is `TRUE`
#'   if the `to` file is written into the same directory as the `from` argument,
#'   otherwise the intermediate file isn't kept.
#'
#' @return Slides are rendered as a `.pdf` file.
#'
#' @example man/examples/examples_pdf.R
#'
#' @export
to_pdf <- function(
    from,
    to = NULL,
    complex_slides = FALSE,
    partial_slides = FALSE,
    delay = 1,
    keep_intermediates = NULL
) {
    # Check if Chrome is installed
    assert_chrome_installed()

    input <- from
    output_file <- to

    assert_path_exists(input)

    complex_slides <- complex_slides || partial_slides

    if (complex_slides && test_path_ext(input, "qmd")) {
        cli::cli_abort(c(
            "Complex PDF rendering is currently only available for xaringan slides in {.path .Rmd} documents.",
            "x" = "{.strong input}: {.val {input}}"
        ))
    }

    if (is.null(output_file)) {
        output_file <- path_from(input, "pdf")
    }

    # Check input and output files have correct extensions
    assert_path_ext(output_file, "pdf", arg = "to")

    if (is.null(keep_intermediates)) {
        keep_intermediates <- in_same_directory(input, output_file)
    }

    # Render html (if input is rmd)
    step_html <- input
    if (!test_path_ext(input, "html")) {
        step_html <- path_from(output_file, "html", temporary = !keep_intermediates)
        to_html(from = input, to = step_html)
    }

    # Render pdf from html
    if (complex_slides) {
        to_pdf_complex(path_from(step_html, "url"), output_file, partial_slides, delay)
    } else {
        assert_path_ext(input, c("qmd", "rmd", "html"), arg = "from")
        to_pdf_simple(step_html, output_file)
    }
}

to_pdf_simple <- function(input, output_file = NULL) {
    proc <- cli_build_start(input, output_file, on_exit = "done")
    tryCatch({
        pagedown::chrome_print(
            input  = input,
            output = output_file
        )
    },
        error = cli_build_failed(proc)
    )
}

# to_pdf_complex() was previously xaringan_to_pdf(), added by gadenbuie
# in v0.0.2. He also posted it on his blog here:
# https://www.garrickadenbuie.com/blog/print-xaringan-chromote/

to_pdf_complex <- function(input, output_file, partial_slides, delay) {
  if (!requireNamespace("chromote", quietly = TRUE)) {
    stop("`chromote` is required: devtools::install_github('rstudio/chromote')")
  }
  if (!requireNamespace("pdftools", quietly = TRUE)) {
    stop("`pdftools` is required: install.packages('pdftools')")
  }

  b <- chromote::ChromoteSession$new()
  on.exit(b$close(), add = TRUE)

  b$Page$navigate(input, wait_ = TRUE)
  b$Page$loadEventFired()

  has_remark <- b$Runtime$evaluate("typeof slideshow !== 'undefined'")$result$value
  if (!has_remark) {
    stop("Input does not appear to be xaringan or quarto slides: ", input)
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

  proc <- cli_build_start(input, output_file)

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

  cli::cli_process_done(proc)
  invisible(output_file)
}
