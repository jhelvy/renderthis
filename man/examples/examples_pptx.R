if (
    nzchar(pagedown::find_chrome()) &&
    requireNamespace("officer", quietly = TRUE)
) {
    with_example("slides.Rmd", {
        # Render pptx from Rmd, html, pdf, or direct URL
        to_pptx("slides.Rmd")
    })
}

