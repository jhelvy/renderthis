if (interactive()) {
    # Both of these build html and pdf outputs
    # (PDF outputs require Google Chrome for {pagedown})
    with_example("slides.Rmd", requires_chrome = TRUE, {
        build_all("slides.Rmd", include = c("html", "pdf"))
    })
}
