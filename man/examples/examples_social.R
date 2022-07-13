if (requireNamespace("webshot2", quietly = TRUE) && interactive()) {
    with_example("slides.Rmd", {
        # Render png image of first slide from Rmd file
        # sized for sharing on social media
        to_social("slides.Rmd")
    })
}
