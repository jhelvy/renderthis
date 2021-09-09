
#' Build handout from xaringan slides
#'
#' Builds a presentation handout as an `.Rmd` and `.html` file from a set of
#' xaringan slides. The handout extracts a thumbnail preview for each slide in
#' the input, as well as the slide content and presenter notes. The final output
#' is an `.html` file that's suitable for publishing or printing. The output
#' also includes the `.Rmd` file used to create the handout so that you can
#' edit the content as needed and can re-render the handout without having to
#' call `build_handout()` again.
#'
#' @param output_dir The directory where the slide handout, preview images and
#'   other slide data will be stored. Because many files are included in the
#'   `build_handout()` output, a directory is required. If the directory exists
#'   it will be overwritten.
#' @param include A character vector of sections to include in the handout:
#'
#'   - `"preview"`: a preview image of the slide
#'   - `"content"`: the content extracted from the slide, discarding most
#'     problematic content types, but including images if `include_images` is
#'     `TRUE`.
#'   - `"notes"`: the presenter notes from the slide
#'   - `"lines"`: a lined notes area
#' @param include_images Should images be included in the slide `content`
#'   section? The default is `FALSE` to keep mostly the text content of each
#'   slide.
#' @inheritParams build_pdf
#'
#' @export
build_handout <- function(
    input,
    output_dir = NULL,
    include = c("preview", "content", "notes"),
    keep_intermediates = FALSE,
    partial_slides = FALSE,
    include_images = FALSE
) {
    include <- match.arg(include, c("preview", "content", "notes", "lines"), TRUE)

    # Check if Chrome is installed
    assert_chrome_installed()

    assert_path_exists(input)

    # Check input and output files have correct extensions
    if (!is_url(input)) {
        assert_path_ext(input, c("rmd", "html"))
    }

    if (is.null(output_dir)) {
        output_dir <- basename(input)
    }

    if (is.null(keep_intermediates)) {
        keep_intermediates <- in_same_directory(input, output_dir)
    }

    # Build html (if input is rmd)
    step_html <- input
    if (test_path_ext(input, "rmd")) {
        step_html <- path_from(output_dir, "html", temporary = !keep_intermediates)
        build_html(input, step_html)
    }

    # Render handout in temp directory... there are lots of files!
    handout_dir <- withr::local_tempdir()
    handout_html <- path_from(input, "html", dir = handout_dir)
    proc <- cli_build_start(basename(handout_html), output_dir, on_exit = "done")

    withr::with_dir(handout_dir, {
        slides_imgs <- build_pdf_complex(
            input = step_html,
            output_file = "slides",
            partial_slides = TRUE, # always get images of partials, filter later
            bundle_pdf_slides = FALSE
        )

        slides_imgs <- pdf_slides_to_images("slides/", !keep_intermediates)

        slides_meta <- get_slide_meta(
            input = step_html,
            slides_imgs = slides_imgs,
            partial_slides = partial_slides,
            include_images = include_images
        )

        saveRDS(slides_meta, "slides.rds")

        tryCatch(
            handout_render_template(
                slides_meta = slides_meta,
                output_file = handout_html,
                include = include,
                partial_slides = partial_slides
            ),
            error = cli_build_failed(proc)
        )
    })

    if (fs::dir_exists(output_dir)) {
        fs::dir_delete(output_dir)
    }
    fs::dir_copy(handout_dir, output_dir)
    output_dir
}

handout_render_template <- function(
    slides_meta,
    output_file,
    include = c("preview", "content", "notes"),
    partial_slides = FALSE
) {
    if (is.character(slides_meta)) {
        stopifnot(fs::file_exists(slides_meta))
        slides_meta <- readRDS(slides_meta)
    }

    include <- match.arg(include, c("preview", "content", "notes", "lines"), TRUE)

    handout_tmpl <- system.file("template", "handout.Rmd", package = "xaringanBuilder")
    assert_path_ext(output_file, "html")
    handout_rmd <- fs::path_ext_set(fs::path_file(output_file), "Rmd")

    if (!isTRUE(partial_slides)) {
        slides_meta$content <- slides_meta$content[!slides_meta$content$continued, ]
    }

    if (!"preview" %in% include) {
        slides_meta$content$preview_image <- FALSE
    }

    if (!"content" %in% include) {
        slides_meta$content$content_md <- FALSE
    }

    if (!"notes" %in% include) {
        slides_meta$content$notes <- FALSE
    }

    # process the slides into markdown content
    slide_content <- mapply(
        handout_slide_md,
        content = slides_meta$content$content_md,
        notes = slides_meta$content$notes,
        preview_image = slides_meta$content$preview_image,
        index = slides_meta$content$id_slide,
        lined_notes_area = "lines" %in% include,
        SIMPLIFY = TRUE,
        USE.NAMES = FALSE
    )
    slide_content <- paste0("\n:", trimws(slide_content, "right"), ":\n", collapse = "\n\n")

    output_dir <- fs::path_abs(fs::path_dir(output_file))
    fs::dir_create(output_dir)
    withr::local_dir(output_dir)

    # write the slide content into the handout template Rmd file
    handout_tmpl <- readLines(handout_tmpl)
    handout_tmpl <- whisker::whisker.render(
        handout_tmpl,
        list(
            title = slides_meta$title,
            authors = paste0('"', slides_meta$authors, '"', collapse = ", "),
            content = slide_content
        )
    )
    writeLines(handout_tmpl, handout_rmd)

    # render the handout into html
    res <- rmarkdown::render(
        basename(handout_rmd),
        output_file = basename(output_file),
        quiet = TRUE,
        envir = new.env(parent = globalenv())
    )

    if (identical(parent.frame(), globalenv())) {
        withr::defer(utils::browseURL(output_file), priority = "last")
    }

    invisible(res)
}

pdf_slides_to_images <- function(dir, clean_pdfs = TRUE) {
    slides_imgs <- data.frame(
        slide_pdf = fs::dir_ls(dir, regexp = "pdf$"),
        stringsAsFactors = FALSE,
        row.names = NULL
    )

    slides_imgs$id_slide <- as.integer(
        sub("slide-(\\d+)-\\d+[.]pdf", "\\1", basename(slides_imgs$slide_pdf))
    )

    pb <- cli::cli_progress_bar("Building slide images", total = nrow(slides_imgs), )

    slides_imgs$preview_image <- slides_imgs$slide_pdf

    for (idx in seq_along(slides_imgs$slide_pdf)) {
        pdf <- slides_imgs$slide_pdf[idx]
        img <- magick::image_read_pdf(pdf, pages = 1, density = 100)
        path <- fs::path_ext_set(pdf, "jpg")
        magick::image_write(img, path)
        if (isTRUE(clean_pdfs)) {
            fs::file_delete(pdf)
        }
        cli::cli_progress_update(id = pb)
        slides_imgs$preview_image[idx] <- path
    }

    cli::cli_progress_done(pb)
    cli::cli_alert_success("Prepared slide images")
    slides_imgs
}

get_slide_meta <- function(
    input,
    slides_imgs = NULL,
    partial_slides = FALSE,
    include_images = FALSE
) {
    meta <- get_presenter_notes(
        input = input,
        partial_slides = partial_slides,
        include_images = include_images
    )
    if (!is.null(slides_imgs)) {
        meta$content <- merge(meta$content, slides_imgs, by = "id_slide")
    }

    meta$content$content_md <- vapply(meta$content$content, html2md, character(1))
    meta$content$notes_html <- vapply(meta$content$notes, md2html, character(1))

    meta$url <- input

    meta$authors <- vapply(
        Filter(x = meta$meta, function(x) identical(x$name, "author")),
        `[[`, character(1), "content"
    )

    meta
}

get_presenter_notes <- function(input, partial_slides = FALSE, include_images = FALSE) {
    assert_chromote()

    input <- path_from(input, "url")

    cli::cli_process_start("Getting slide content and presenter notes")

    b <- chromote::ChromoteSession$new()
    on.exit(b$close(), add = TRUE)
    # on.exit(b$parent$stop(), add = TRUE)

    b$Page$navigate(input, wait_ = TRUE)
    b$Page$loadEventFired()

    has_remark <- b$Runtime$evaluate("typeof slideshow !== 'undefined'")$result$value
    if (!has_remark) {
        stop("Input does not appear to be xaringan slides: ", input)
    }

    res <- b$Runtime$evaluate(
        paste0(
            "slideshow",
            ".getSlides()",
            ".map(function(el) {\n",
            "  return {",
            "    continued: el.properties.continued,\n",
            "    class: el.properties.class,\n",
            "    notes: el.notes,\n",
            "    content: JSON.stringify(el.content)",
            "  }",
            "})"
        ),
        returnByValue = TRUE
    )$result$value

    meta <- b$Runtime$evaluate(
        paste0(
            'Array.from(document.getElementsByTagName("meta"))',
            ".map(el => [...el.attributes]",
            "  .map(attr => ({[attr.name]: attr.value}))",
            "  .reduce((acc, item) => ({...acc, ...item}), {})",
            ")"
        ),
        returnByValue = TRUE
    )$result$value

    title <- b$Runtime$evaluate("document.title", returnByValue = TRUE)$result$value

    res <- lapply(res, function(x) {
        x$notes <- trimws(paste(x$notes, collapse = "\n"))
        x$content <- trimws(paste(x$content, collapse = "\n"))
        if (is.null(x$class)) {
            x$class <- NA_character_
        }
        as.data.frame(x, stringsAsFactors = FALSE)
    })
    res <- do.call("rbind", res)
    class(res) <- c("tbl_df", "tbl", "data.frame")

    # remark puts `continued: true` on slides that _continue_ the previous slide
    # but we'd rather have `continued` indicate that a slide _is continued_ on
    # the *next* slide, so we are going to reverse the meaning by `lead(1)`.
    res$continued <- res$continued == "true"
    res$continued <- c(res$continued[-1], FALSE)

    res$id_slide <- seq_len(nrow(res))
    if (isTRUE(partial_slides)) {
        # try to get notes down to the notes that are particular to each partial slide
        res$prev_notes <- c("", res$notes[-length(res$notes)])
        res$notes <-
            vapply(seq_len(nrow(res)), FUN.VALUE = character(1), function(idx) {
                x <- res[idx, ]
                if (!x$continued || !nzchar(x$prev_notes)) {
                    return(x$notes)
                }
                trimws(sub(x$prev_notes, "", x$notes, fixed = TRUE))
            })
        res$prev_notes <- NULL
    }
    res$content <- rewrite_all_content(res$content, input, include_images)

    cli::cli_process_done()
    list(content = res, meta = meta, title = title)
}

rewrite_all_content <- function(content, input_url, include_images = FALSE) {
    # content starts as JSON...
    content <- lapply(content, jsonlite::fromJSON, simplifyVector = FALSE)
    # that contains html in remark's particular style...
    content <- lapply(content, rewrite_remark_content)
    # blended with markdown
    content <- vapply(content, paste, collapse = "", character(1))
    html <- lapply(content, commonmark::markdown_html)

    # Read each slide fragment as HTML and do some basic sanitization
    html <- lapply(html, function(x) {
        if (trimws(x) == "") return("")
        x <- xml2::read_html(x)
        # remove web things, images, html-widgets
        bad_nodes <- xml2::xml_find_all(x, paste0(
            "//", c(
                "title", "textarea", "style", "xmp", "iframe", "noembed",
                "noframes", "script", "plaintext",
                if (!include_images) c("img", "figure", "svg")
            ),
            collapse = " | "
        ))
        xml2::xml_remove(bad_nodes)
        html_widgets <- xml2::xml_find_all(
            x, "descendant-or-self::*[(@class and contains(concat(' ', normalize-space(@class), ' '), ' html-widget '))]"
        )
        xml2::xml_remove(html_widgets)

        # rewrite relative URLs as absolute URLs relative to original url of slides
        x <- make_urls_absolute(x, "href", input_url)
        x <- make_urls_absolute(x, "src", input_url)

        # get back just inner slide html
        x <- xml2::xml_find_first(x, "//body")
        x <- xml2::xml_children(x)
        paste(as.character(x), collapse = "\n")
    })
    unlist(html)
}

rewrite_remark_content <- function(x) {
    if (is.character(x) || is.logical(x)) return(x)
    if (is.list(x) && all(vapply(x, is.character, logical(1)))) {
        x <- paste(unlist(x), collapse = "")
    } else {
        x <- lapply(x, rewrite_remark_content)
    }
    if (is.list(x) && length(setdiff(c("block", "class", "content"), names(x))) == 0) {
        if (isTRUE(x$block)) {
            x <- paste0(x$content, collapse = "")
            x <- paste0("\n", x, "\n")
        } else {
            x <- paste(x$content, collapse = " ")
        }
    }
    gsub("\n{2,}", "\n\n", x)
}

make_urls_absolute <- function(x, attr = "href", url) {
    x_attr <- rvest::html_nodes(x, paste0("[", attr, "]"))
    x_attr_value <- xml2::url_absolute(xml2::xml_attr(x_attr, attr), url)
    xml2::xml_set_attr(x_attr, attr, x_attr_value)
    x
}

pandoc_convert <- function(x, from = "markdown", to = "html5") {
    if (!rmarkdown::pandoc_available() || is.na(x) || all(!nzchar(x))) {
        return(x)
    }
    withr::with_tempfile("txt", fileext = ".txt", {
        writeLines(x, txt)
        rmarkdown::pandoc_convert(txt, from = from, to = to, output = txt)
        paste(readLines(txt, warn = FALSE), collapse = "\n")
    })
}

md2html <- function(x) {
    pandoc_convert(x, "markdown", "html5")
}

html2md <- function(x) {
    pandoc_convert(x, "html", "markdown")
}

md_fenced_div <- function(text, attr = NULL) {
    text <- trimws(paste(text, collapse = "\n"))
    attr <- if (!is.null(attr)) {
        paste0(" {", paste(attr, collapse = " "), "}")
    } else ""
    sprintf(":::%s\n%s\n:::\n", attr, text)
}

handout_slide_md <- function(content, notes, preview_image, index, lined_notes_area = FALSE) {
    is_not_used <- function(x) is.null(x) || identical(x, FALSE)

    div_lined_notes <- '\n\n<div class="slide-lined-notes"></div>'

    preview_image <- if (is_not_used(preview_image)) "" else {
        md_fenced_div(
            attr = ".slide-image",
            sprintf('<img src="%s" alt="Slide %s preview">', preview_image, index)
        )
    }

    content <- if (is_not_used(content)) "" else {
        md_fenced_div(content, ".slide-content")
    }

    notes <- if(is_not_used(notes)) "" else {
        if (isTRUE(lined_notes_area) && !nzchar(preview_image) && nzchar(content)) {
            # If content but no preview image, nest lined notes area in with notes
            notes <- paste0(notes, div_lined_notes)
            # but then don't add the lined notes area again later
            lined_notes_area <- FALSE
        }
        md_fenced_div(notes, ".slide-notes")
    }

    text <- paste0(content, notes)

    if (isTRUE(lined_notes_area)) {
        text <- paste0(text, div_lined_notes)
    }

    md_fenced_div(
        attr = ".slide",
        paste0(
            preview_image,
            "\n",
            if (nzchar(text)) {
                md_fenced_div(text, c(".slide-text", 'data-external="1"'))
            }
        )
    )
}

handout_css <- function() {
    handout_css_file <- fs::path_package("xaringanBuilder", "template", "handout.css")
    handout_css <- paste(readLines(handout_css_file), collapse = "\n")
    meta <- list(head = sprintf("<style>%s</style>", handout_css))

    htmltools::tagList(
        htmltools::htmlDependency(
          name = "xaringanBuilder-handout",
          version = "0.0.1",
          package = "xaringanBuilder",
          src = "template",
          stylesheet = "handout.css",
          all_files = FALSE
        )
    )
}
