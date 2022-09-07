with_example("slides.Rmd", requires_chrome = TRUE, requires_packages = "webshot2", {
    # Render png image of first slide from Rmd file
    # sized for sharing on social media
    to_social("slides.Rmd")
})
