assert_io_paths <- function(input, input_ext, output_file, output_file_ext) {
    assert_path_ext(input, input_ext, arg = "input")
    if (!is.null(output_file)) {
        assert_path_ext(output_file, output_file_ext, arg = "output_file")
    }
}

assert_path_ext <- function(path, expected_ext, arg) {
    if (!test_path_ext(path, expected_ext)) {
        expected_ext <- paste0(".", expected_ext, collapse = ", ")
        stop("`", arg, "` must have extension: ", expected_ext, call. = FALSE)
    }
}

test_path_ext <- function(path, expected_ext) {
    return(tolower(fs::path_ext(path)) %in% expected_ext)
}

assert_chrome_installed <- function() {
    assert_chromote()

    chromePath <- NULL
    error <- paste0(
        "This function requires a local installation of the Chrome ",
        "browser. You can also use other browsers based on Chromium, ",
        "such as Chromium itself, Edge, Vivaldi, Brave, or Opera.")
    tryCatch({
      chromePath <- chromote::find_chrome()
      },
      error = function(e) { message(error) }
    )
    if (is.null(chromePath)) {
        stop(error)
    }
}

assert_chromote <- function() {
    if (!requireNamespace("chromote", quietly = TRUE)) {
        stop("`chromote` is required: remotes::install_github('rstudio/chromote')")
    }
    if (utils::packageVersion("chromote") < package_version("0.0.0.9003")) {
        warning("Please upgrade `chromote` to version 0.0.0.9003 or later.")
    }
}

build_paths <- function(input, output_file = NULL) {
    # Build input paths
    if (is_url(input)) {
      input_root <- fs::path_abs(fs::path_file(input))
      input_html <- input
      input_url  <- input
    } else {
      input_root <- fs::path_abs(input)
      input_html <- fs::path_ext_set(input_root, "html")
      input_url  <- paste0("file://", input_html)
    }
    input_rmd <- input_root
    input_pdf <- fs::path_ext_set(input_root, "pdf")

    # Build output_file paths
    if (is.null(output_file)) {
      if (is_url(input)) {
        output_root <- fs::path_abs(fs::path_file(input))
      } else {
        output_root <- fs::path_abs(input)
      }
    } else {
      output_root <- fs::path_abs(output_file)
    }
    output_html <- fs::path_ext_set(output_root, "html")
    output_pdf  <- fs::path_ext_set(output_root, "pdf")
    output_gif  <- fs::path_ext_set(output_root, "gif")
    output_pptx <- fs::path_ext_set(output_root, "pptx")
    output_mp4  <- fs::path_ext_set(output_root, "mp4")
    output_zip  <- fs::path_ext_set(output_root, "zip")
    output_png  <- fs::path_ext_set(output_root, "png")
    output_social <- output_png
    # Append "_social" to png outputs
    if (is.null(output_file)) {
      output_social <- append_to_file_path(output_png, "_social")
    }

    # Return path list
    return(list(
      input = list(
        url  = input_url,
        html = input_html,
        rmd  = input_rmd,
        pdf  = input_pdf
      ),
      output = list(
        html   = output_html,
        pdf    = output_pdf,
        gif    = output_gif,
        pptx   = output_pptx,
        mp4    = output_mp4,
        zip    = output_zip,
        png    = output_png,
        social = output_social
      )
    ))
}

is_url <- function(input) {
  return(grepl("^(ht|f)tp", tolower(input)))
}

append_to_file_path <- function(path, s) {
    # Appends s to path before the extension, e.g.
    # path:    "file.png"
    # s:       "_social"
    # returns: "file_social.png"
    return(
        fs::path_ext_set(
            paste0(fs::path_ext_remove(path), s),
            fs::path_ext(path)
        )
    )
}

cli_build_start <- function(input, output_file, on_exit = "failed") {
    input <- fs::path_file(input)
    output <- fs::path_file(output_file)
    cli::cli_process_start(
        paste0("Building ", output, " from ", input),
        on_exit = on_exit,
        .envir = parent.frame()
    )
}

cli_build_failed <- function(id) {
  function(err) {
    cli::cli_process_failed(id)
    stop(err)
  }
}

pdf_to_pngs <- function(input, density) {
    return(magick::image_read_pdf(input, density = density))
}

build_to_pdf <- function(
  input,
  paths,
  complex_slides,
  partial_slides,
  delay
) {
    if (test_path_ext(input, "rmd")) {
        build_pdf(
          input = paths$input$rmd,
          output_file = paths$output$pdf,
          complex_slides, partial_slides, delay)
    } else if (test_path_ext(input, "html")) {
        build_pdf(
          input = input,
          output_file = paths$output$pdf,
          complex_slides, partial_slides, delay)
    }
}
