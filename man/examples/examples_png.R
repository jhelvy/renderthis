with_example("slides.Rmd", requires_chrome = TRUE, {
    # By default a png of only the first slide is built
    to_png("slides.Rmd", keep_intermediates = TRUE)

    # or render a zip file of multiple or all slides (`slides = "all"`)
    to_png("slides.pdf", slides = c(1, 3, 5))
})
