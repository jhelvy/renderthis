if (
    nzchar(pagedown::find_chrome()) &&
    requireNamespace("officer", quietly = TRUE)
) {
    with_example("slides.Rmd", {
        # Render pptx from Rmd, html, pdf, or url
        to_pptx("slides.Rmd", keep_intermediates = TRUE)
        to_pptx("slides.html")
        to_pptx("slides.pdf")

        # You can also render directly from a URL
        to_pptx("https://jhelvy.github.io/renderthis/example/slides.html")
    })
}

