if (nzchar(pagedown::find_chrome())) {
    with_example("slides.Rmd", {
        # Render pdf from Rmd, html, or direct URL
        to_pdf("slides.Rmd")
    })
}
