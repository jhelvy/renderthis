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

skip_if_not_chrome_installed <- function() {
    skip_if_not(check_chrome_installed(), "Chrome is not installed")
}
