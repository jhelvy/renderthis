test_that("to_html() output in input directory", {
    skip_if_not_chrome_installed()
    skip_if_not_installed("webshot2")

    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)
    suppressMessages(
        to_social("slides.Rmd")
    )

    expect_true(fs::file_exists("slides_social.png"))

    fs::dir_create("social")
    suppressMessages(
        to_social("slides.Rmd", "social/social.png")
    )
    expect_true(fs::file_exists("social/social.png"))
    expect_equal_images("slides_social.png", "social/social.png")
})
