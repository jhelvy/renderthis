if (
    requireNamespace("av", quietly = TRUE) &&
    nzchar(pagedown::find_chrome())
) {
    with_example("slides.Rmd", {
        # Render mp4 from Rmd, html, pdf
        to_mp4("slides.Rmd")
        to_mp4("slides.html")
        to_mp4("slides.pdf")

        # You can also render directly from a URL
        to_mp4("https://jhelvy.github.io/renderthis/example/slides.html")
    })
}
