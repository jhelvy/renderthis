test_that("to_gif() simple from .Rmd", {
    skip_if_not_chrome_installed()

    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    suppressMessages(
        to_gif("slides.Rmd")
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

test_that("to_gif() simple from pdf", {
    tmpdir <- withr::local_tempdir()
    fs::file_copy(test_path("slides", "basic.pdf"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    suppressMessages(
        to_gif("basic.pdf")
    )

    expect_false(fs::file_exists("basic.html"))

    gif_info <- magick::image_info(magick::image_read("basic.gif"))
    # three slides, one image each
    expect_equal(nrow(gif_info), 3)
    # that are all gifs
    expect_setequal(gif_info$format, "GIF")
    # the basic slides are 4:3 plus or minus a few pixels
    expect_equal(gif_info$height[[1]] / gif_info$width[[1]], 3/4, tolerance = 0.01)
})

test_that("to_gif() keeps intermediates", {
    skip_if_not_chrome_installed()

    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    suppressMessages(
        to_gif("slides.Rmd", "test.gif", keep_intermediates = TRUE, density = 200)
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

test_that("to_gif() only includes `slides`", {
    tmpdir <- withr::local_tempdir()
    fs::file_copy(test_path("slides", "basic.pdf"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    fs::dir_create("gif")
    suppressMessages(
        to_gif("basic.pdf", "gif/demo.gif", keep_intermediates = TRUE, slides = c(1, 3))
    )

    expect_true(fs::file_exists("gif/demo.gif"))

    gif_info <- magick::image_info(magick::image_read("gif/demo.gif"))
    # two slides (not three!), one image each
    expect_equal(nrow(gif_info), 2)
    # that are all gifs
    expect_setequal(gif_info$format, "GIF")
    # the basic slides are 4:3 plus or minus a few pixels
    expect_equal(gif_info$height[[1]] / gif_info$width[[1]], 3/4, tolerance = 0.01)

    expect_error(suppressMessages(
        to_gif("basic.pdf", slides = FALSE)
    ))
    expect_error(suppressMessages(
        to_gif("basic.pdf", slides = 4)
    ))
})
