#' Print xaringan slides to PDF
#'
#' Prints xaringan slides to a PDF file, even complicated slides
#' with panelsets or other html widgets or advanced features.
#' Requires a local installation of Chrome.
#'
#' @param input Path to Rmd or html file of xaringan slides.
#' @param output_file The name of the output file. If using NULL then
#' the output filename will be based on filename for the input file.
#' If a filename is provided, a path to the output file can also be provided.
#' @param delay Seconds of delay between advancing to and printing
#'   a new slide.
#' @param include_partial_slides Should partial (continuation) slides be
#' included in the output? If `FALSE`, the default, only the complete slide
#' is included in the PDF.
#' @export
#' @examples
#' \dontrun{
#' # Build pdf from Rmd or html file
#' xaringan_to_pdf("slides_complex.html")
#' xaringan_to_pdf(input = "slides_complex.html",
#'                 output_file = "slides_complex_partial.pdf",
#'                 include_partial_slides = TRUE)
#' }
xaringan_to_pdf <- function(
  input,
  output_file = NULL,
  delay = 1,
  include_partial_slides = FALSE
) {
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
    if (include_partial_slides) " .has-continuation { display: block }",
    "}'\n",
    "document.head.appendChild(style)"
  ))

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

    if (!isTRUE(include_partial_slides) && slide_is_continuation()) next
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
