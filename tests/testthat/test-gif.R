test_that("build_gif() simple", {
    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    quiet_cli(
        build_gif("slides.Rmd")
    )

    expect_true(fs::file_exists("slides.gif"))
    expect_false(fs::file_exists("slides.pdf"))
    expect_false(fs::file_exists("slides.html"))

    gif_info <- magick::image_info(magick::image_read("slides.gif"))
    # three slides, one image each
    expect_equal(nrow(gif_info), 3)
    # that are all gifs
    expect_setequal(gif_info$format, "GIF")
    # the basic slides are 4:3 plus or minus a few pixels
    expect_equal(gif_info$height[[1]] / gif_info$width[[1]], 3/4, tolerance = 0.01)
})

test_that("build_gif() keeps intermediates", {
    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    quiet_cli(
        build_gif("slides.Rmd", "test.gif", keep_intermediates = TRUE, density = 200)
    )

    expect_true(fs::file_exists("test.gif"))
    expect_true(fs::file_exists("test.pdf"))
    expect_true(fs::file_exists("test.html"))

    gif_info <- magick::image_info(magick::image_read("test.gif"))
    # three slides, one image each
    expect_equal(nrow(gif_info), 3)
    # that are all gifs
    expect_setequal(gif_info$format, "GIF")
    # the basic slides are 4:3 plus or minus a few pixels
    expect_equal(gif_info$height[[1]] / gif_info$width[[1]], 3/4, tolerance = 0.01)
})

test_that("build_gif() only includes `slides`", {
    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    fs::dir_create("gif/demo.gif")
    quiet_cli(
        build_gif("slides.Rmd", "gif/demo.gif", keep_intermediates = TRUE, slides = c(1, 3))
    )

    expect_true(fs::file_exists("gif/demo.gif"))
    expect_true(fs::file_exists("gif/demo.pdf"))
    expect_true(fs::file_exists("gif/demo.html"))

    gif_info <- magick::image_info(magick::image_read("gif/demo.gif"))
    # two slides (not three!), one image each
    expect_equal(nrow(gif_info), 2)
    # that are all gifs
    expect_setequal(gif_info$format, "GIF")
    # the basic slides are 4:3 plus or minus a few pixels
    expect_equal(gif_info$height[[1]] / gif_info$width[[1]], 3/4, tolerance = 0.01)
})
