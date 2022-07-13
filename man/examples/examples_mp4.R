if (requireNamespace("av", quietly = TRUE)) {
    with_example("slides.Rmd", {
        # Render mp4 from Rmd, html, pdf, or direct URL
        to_mp4("slides.Rmd")
    })
}
