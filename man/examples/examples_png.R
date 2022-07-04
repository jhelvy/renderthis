if (nzchar(pagedown::find_chrome())) {
    with_example("slides.Rmd", {
        # By default a png of only the first slide is built
        to_png("slides.Rmd")
        to_png("slides.html")
        to_png("slides.pdf")

        # or render a zip file of multiple or all slides
        to_png("slides.pdf", slides = c(1, 3, 5))
        to_png("slides.pdf", slides = "all")

        # You can also render directly from a URL
        to_png("https://jhelvy.github.io/renderthis/reference/figures/slides.html")
    })
}
