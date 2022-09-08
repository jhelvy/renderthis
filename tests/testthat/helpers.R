expect_equal_images <- function(x, y) {
    expect_equal(
        magick::image_compare_dist(
            image = magick::image_read(x),
            reference_image = magick::image_read(y),
            metric = "AE"
        )$distortion,
        0.0,
        tolerance = 0.1
    )
}

local_test_example_dir <- function(..., copy_to = NULL) {
    # Copies a test example directory into a temporary directory that is removed
    # when exiting the parent environment, e.g. when the test completes
    test_example <- fs::path_abs(test_path(...))

    tmpdir <- withr::local_tempdir(.local_envir = parent.frame())
    withr::local_dir(tmpdir, .local_envir = parent.frame())

    if (!is.null(copy_to)) {
        fs::dir_create(copy_to)
        fs::dir_copy(test_example, copy_to, overwrite = TRUE)
    } else {
        fs::dir_copy(test_example, ".", overwrite = TRUE)
    }

    invisible(tmpdir)
}

skip_if_not_chrome_installed <- function() {
    skip_on_cran()
    skip_if_not(check_chrome_installed(), "Chrome is not installed")
}

skip_if_not_pandoc <- function() {
    skip_if_not(rmarkdown::pandoc_available())
}

skip_if_not_quarto <- function() {
    skip_if_not(!is.null(quarto::quarto_path()), "quarto binary not available")
    skip_if_not_pandoc()
}
