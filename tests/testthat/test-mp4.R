test_that("to_gif() builds an mp4", {
    skip_if_not_installed("av")

    tmpdir <- withr::local_tempdir()
    fs::file_copy(test_path("slides", "basic.pdf"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    suppressMessages(
        to_mp4("basic.pdf", "basic.mp4", fps = 0.5, slides = 1:2)
    )

    expect_true(fs::file_exists("basic.mp4"))
    expect_length(fs::dir_ls(regexp = "png$"), 0)

    mp4_info <- av::av_video_info("basic.mp4")
    expect_equal(mp4_info$video$framerate, 0.5)
    expect_equal(mp4_info$video$width / mp4_info$video$height, 4/3, tolerance = 0.01)

    frames <- magick::image_info(magick::image_read_video("basic.mp4", fps = 0.5))
    expect_equal(nrow(frames), 2)
})

test_that("to_gif() builds a widescreen mp4", {
    skip_if_not_installed("av")

    tmpdir <- withr::local_tempdir()
    fs::file_copy(test_path("slides", "basic-wide.pdf"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    suppressMessages(
        to_mp4("basic-wide.pdf")
    )

    expect_true(fs::file_exists("basic-wide.mp4"))
    expect_length(fs::dir_ls(regexp = "png$"), 0)

    mp4_info <- av::av_video_info("basic-wide.mp4")
    expect_equal(mp4_info$video$framerate, 1)
    expect_equal(mp4_info$video$width / mp4_info$video$height, 16/9, tolerance = 0.01)

    frames <- magick::image_info(magick::image_read_video("basic-wide.mp4", fps = 1))
    expect_equal(nrow(frames), 3)
})
