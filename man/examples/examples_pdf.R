if (nzchar(pagedown::find_chrome())) {
    with_example("slides.Rmd", {
        # Render pdf from Rmd, html, or url
        to_pdf("slides.Rmd")
        to_pdf("slides.html")
        to_pdf("https://jhelvy.github.io/renderthis/reference/figures/slides.html")

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

        # Render a pdf of "complex" slides
        to_pdf("slides_complex.Rmd", complex_slides = TRUE)
        to_pdf("slides_complex.html", complex_slides = TRUE)

        # Render a pdf of "complex" slides and include partial
        # (continuation) slides
        to_pdf(from = "slides_complex.Rmd",
            to = "slides_complex_partial.pdf",
            complex_slides = TRUE,
            partial_slides = TRUE)
        to_pdf(from = "slides_complex.html",
            to = "slides_complex_partial.pdf",
            complex_slides = TRUE,
            partial_slides = TRUE)
    })
}
