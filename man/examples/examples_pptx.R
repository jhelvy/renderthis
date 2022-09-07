with_example("slides.Rmd", requires_chrome = TRUE, requires_packages = "officer", {
    # Render pptx from Rmd, html, pdf, or direct URL
    to_pptx("slides.Rmd")
})
