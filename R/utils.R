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

    if (!check_chrome_installed()) {
        stop(
            "This function requires a local installation of the Chrome ",
            "browser. You can also use other browsers based on Chromium, ",
            "such as Chromium itself, Edge, Vivaldi, Brave, or Opera.",
            call. = FALSE
        )
    }
}

check_chrome_installed <- function() {
    assert_chromote()

    tryCatch(
        !is.null(chromote::find_chrome()),
        error = function(e) FALSE
    )
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
            if (!fs::file_exists(path_new)) return()
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

slides_arg_validate <- function(slides, imgs = NULL) {
    if (is.null(slides)) {
        slides <- "all"
    }

    if (is.character(slides)) {
        slides <- tryCatch(
            match.arg(tolower(slides), c("all", "first", "last")),
            error = function(err) {
                stop(
                    '`slides` should be one of "all", "first", "last" ',
                    "or an integer vector of slide indices"
                )
            }
        )
    } else {
        if (!is.numeric(slides)) {
            stop("`slides` must be numeric slide indices")
        }
        if (any(slides < 0) && any(slides > 0)) {
            stop(
                "`slides` must be negative slide indices to drop ",
                "or positive indices of slides to keep"
            )
        }
        if (!isTRUE(all.equal(slides, as.integer(slides), tolerance = .Machine$double.eps))) {
            stop("`slides` must be integer slide indices")
        }

        slides <- sort(unique(as.integer(slides)), decreasing = any(slides < 0))

        if (any(slides == 0)) {
            warning("Ignoring `slide` number 0, `slides` must be all positive or negative integers")
            slides <- slides[slides != 0]
        }

        if (!length(slides)) {
            stop("No slides were selected")
        }
    }

    if (is.null(imgs)) {
        return(slides)
    }

    if (identical(slides, "all")) {
        return(seq_along(imgs))
    } else if (identical(slides, "first")) {
        return(1L)
    } else if (identical(slides, "last")) {
        return(length(imgs))
    }

    slides_oob <- slides[!abs(slides) %in% seq_along(imgs)]
    if (length(slides_oob)) {
        slides <- setdiff(slides, slides_oob)
        if (length(slides)) {
            warning(
                "Some values of `slides` were out of range for this presentation: ",
                paste(slides_oob, collapse = ", ")
            )
        } else {
            stop(
                "All values of `slides` were out of range for this presentation: ",
                paste(slides_oob, collapse = ", ")
            )
        }
    }

    seq_along(imgs)[slides]
}
