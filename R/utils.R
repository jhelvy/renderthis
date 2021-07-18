assert_path_ext <- function(path, expected_ext, arg = NULL) {
    if (is.null(arg)) arg <- deparse(substitute(path))
    if (is.null(path)) {
        stop("`", arg, "` must be a path with extension ", expected_ext, call. = FALSE)
    }
    if (!test_path_ext(path, expected_ext)) {
        expected_ext <- paste0(".", expected_ext, collapse = ", ")
        stop("`", arg, "` must have extension: ", expected_ext, call. = FALSE)
    }
}

test_path_ext <- function(path, expected_ext) {
    tolower(fs::path_ext(path)) %in% expected_ext
}

assert_path_exists <- function(path, arg = NULL, dir_ok = FALSE) {
    if (is.null(arg)) arg <- deparse(substitute(path))

    if (is.null(path)) {
        stop("`", arg, "` must be a path", call. = FALSE)
    }

    if (
        is_url(path) ||
        (dir_ok && fs::dir_exists(path)) ||
        # don't count directories if !dir_ok
        (!fs::is_dir(path) && fs::file_exists(path))
    ) {
        return()
    }

    stop("`", arg, "` doesn't exist: ", path, call. = FALSE)
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

path_from <- function(path, to_ext, temporary = FALSE, dir = NULL) {
    path_is_url <- is_url(path)
    temporary <- isTRUE(temporary)

    if (identical(tolower(to_ext), "url")) {
        if (path_is_url) {
            return(path)
        }
        temporary <- FALSE
    }

    if (is.null(dir)) {
        dir <-
            if (path_is_url) {
                warning("No `dir` provided, using working directory.")
                fs::path_wd()
            } else {
                fs::path_dir(fs::path_abs(path))
            }
    }

    path_abs <- if (!path_is_url) fs::path_abs(path)
    path_file <-
        if (temporary) {
            fs::path_file(fs::file_temp("xaringanBuilder_"))
        } else {
            fs::path_file(path)
        }

    path_new <- switch(
        tolower(to_ext),
        social = fs::path(
            dir,
            append_to_file_path(fs::path_ext_set(path_file, "png"), "_social")
        ),
        url = fs::path(dir, path_file),
        html = ,
        pdf = ,
        png = ,
        gif = ,
        pptx = ,
        mp4 = ,
        zip = fs::path(dir, fs::path_ext_set(path_file, to_ext)),
        stop("Unsupported file type: ", to_ext)
    )

    path_new <- fs::path_abs(path_new)

    if (to_ext == "url") {
        path_new <- paste0("file://", path_new)
    }

    if (temporary) {
        # when the calling function exits, delete the temp file
        path_new_rel <- fs::path_rel(path_new, fs::path_wd())
        msg <- cli::format_inline(
            "Removed temporary {.file {path_new_rel}}", .envir = environment()
        )
        withr::defer({
            unlink(path_new)
            if (tolower(to_ext) == "html" && temporary) {
                # clean up supporting files for temp HTML
                support_dir <- paste0(fs::path_ext_remove(path_new), "_files")
                if (fs::dir_exists(support_dir)) {
                    fs::dir_delete(support_dir)
                }
            }
            cli::cli_alert_info(msg)
        }, envir = parent.frame())
    }

    path_new
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

in_same_directory <- function(x, y) {
    if (is_url(x) || is_url(y)) {
        return(FALSE)
    }
    paths <- fs::path_abs(c(x, y))
    common <- fs::path_common(paths)
    all(common == fs::path_dir(paths))
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
    input <- fs::path_rel(input, start = fs::path_wd())
    output <- fs::path_rel(output_file, start = fs::path_wd())

    # prepare the message right now in this environment, because we'll attach
    # the cli_process to the parent frame, where input and output don't exist
    msg <- cli::format_inline(
        "Building {.file {input}} into {.field {output}}",
        .envir = environment()
    )

    cli::cli_process_start(msg, on_exit = on_exit, .envir = parent.frame())
}

cli_build_failed <- function(id) {
  function(err) {
    cli::cli_process_failed(id)
    stop(err)
  }
}

pdf_to_imgs <- function(input, density) {
    magick::image_read_pdf(input, density = density)
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
