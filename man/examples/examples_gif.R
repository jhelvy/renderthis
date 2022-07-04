if (nzchar(pagedown::find_chrome())) {
    with_example("slides.Rmd", {
        # Render gif from Rmd, html, pdf
        to_gif("slides.Rmd", keep_intermediates = TRUE)
        to_gif("slides.html")
        to_gif("slides.pdf")

        # You can also render directly from a URL
        to_gif("https://jhelvy.github.io/renderthis/example/slides.html")
    })
}
