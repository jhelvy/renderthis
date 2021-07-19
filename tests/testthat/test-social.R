test_that("build_html() output in input directory", {
    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)
    quiet_cli(
        build_social("slides.Rmd")
    )

    expect_true(fs::file_exists("slides_social.png"))

    fs::dir_create("social")
    quiet_cli(
        build_social("slides.Rmd", "social/social.png")
    )
    expect_true(fs::file_exists("social/social.png"))
    expect_equal_images("slides_social.png", "social/social.png")
})
