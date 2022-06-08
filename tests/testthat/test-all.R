test_that("to_all() from basic slides.Rmd", {
    skip_if_not_chrome_installed()
    skip_if_not_installed("av")
    skip_if_not_installed("officer")
    skip_if_not_installed("webshot2")

    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    suppressMessages(
        to_all("slides.Rmd", slides = NULL)
    )

    expect_true(fs::file_exists("slides.html"))
    expect_true(fs::file_exists("slides.pdf"))
    expect_true(fs::file_exists("slides.zip"))
    expect_true(fs::file_exists("slides.gif"))
    expect_true(fs::file_exists("slides.mp4"))
    expect_true(fs::file_exists("slides.pptx"))
})

test_that("to_all() from basic slides.Rmd with a few excluded formats", {
    skip_if_not_chrome_installed()
    skip_if_not_installed("av")
    skip_if_not_installed("officer")
    skip_if_not_installed("webshot2")

    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    suppressMessages(
        to_all("slides.Rmd", slides = NULL, exclude = c("html", "pdf", "png"))
    )

    expect_false(fs::file_exists("slides.html"))
    expect_false(fs::file_exists("slides.pdf"))
    expect_false(fs::file_exists("slides.zip"))
    expect_true(fs::file_exists("slides.gif"))
    expect_true(fs::file_exists("slides.mp4"))
    expect_true(fs::file_exists("slides.pptx"))
})
