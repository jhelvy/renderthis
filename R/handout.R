#' @export
build_handout <- function(
    input,
    output_dir = NULL,
    keep_intermediates = FALSE,
    partial_slides = FALSE,
    include_images = FALSE
) {
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
    proc <- cli_build_start("handout.Rmd", output_dir, on_exit = "done")

    # Render handout in temp directory... there are lots of files!
    handout_dir <- withr::local_tempdir()

    handout_rmd_tmpl <- system.file("template", "handout.Rmd", package = "xaringanBuilder")
    handout_html <- path_from(input, "html", dir = handout_dir)
    fs::file_copy(handout_rmd_tmpl, fs::path(handout_dir, "handout.Rmd"))

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

        saveRDS(slides_meta, "meta.rds")

        if (!isTRUE(partial_slides)) {
            slides_meta$content <- slides_meta$content[!slides_meta$content$continued, ]
        }

        tryCatch(
            rmarkdown::render(
                "handout.Rmd",
                output_file = basename(handout_html),
                params = slides_meta,
                quiet = TRUE
            ),
            error = cli_build_failed(proc)
        )
        fs::file_delete("handout.Rmd")
    })

    if (fs::dir_exists(output_dir)) {
        fs::dir_delete(output_dir)
    }
    fs::dir_copy(handout_dir, output_dir)
    output_dir
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

    slides_imgs$slide_path <- slides_imgs$slide_pdf

    for (idx in seq_along(slides_imgs$slide_pdf)) {
        pdf <- slides_imgs$slide_pdf[idx]
        img <- magick::image_read_pdf(pdf, pages = 1, density = 100)
        path <- fs::path_ext_set(pdf, "jpg")
        magick::image_write(img, path)
        if (isTRUE(clean_pdfs)) {
            fs::file_delete(pdf)
        }
        cli::cli_progress_update(id = pb)
        slides_imgs$slide_path[idx] <- path
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

    res$continued <- res$continued == "true"
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
