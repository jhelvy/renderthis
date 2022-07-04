if (nzchar(pagedown::find_chrome())) {
    with_example("slides.Rmd", {
        # Render gif from Rmd, html, pdf, or direct URL
        to_gif("slides.Rmd")
    })
}
