if (nzchar(pagedown::find_chrome())) {
    with_example("slides.Rmd", {
        # Render pdf from Rmd, html, or url
        to_pdf("slides.Rmd")
        to_pdf("slides.html")
        to_pdf("https://jhelvy.github.io/renderthis/example/slides.html")

        # Render a pdf with partial (continuation) slides
        to_pdf("slides.Rmd", partial_slides = TRUE)
        to_pdf("slides.html", partial_slides = TRUE)
    })
}

if (
    requireNamespace("chromote", quietly = TRUE) &&
    nzchar(chromote::find_chrome())
) {
    with_example("slides.Rmd", {
        # Render a pdf with partial (continuation) slides
        to_pdf("slides.Rmd", partial_slides = TRUE)
        to_pdf("slides.html", partial_slides = TRUE)
    })
}
