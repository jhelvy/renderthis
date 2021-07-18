test_that("build_html() output in input directory", {
    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)
    quiet_cli(build_html("slides.Rmd"))

    expect_true(fs::file_exists("slides.html"))
    expect_true(fs::dir_exists("slides_files"))
})

test_that("build_html() self-contained output in input directory", {
    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)
    quiet_cli(build_html("slides.Rmd", self_contained = TRUE))

    expect_true(fs::file_exists("slides.html"))
    expect_false(fs::dir_exists("slides_files"))
})

test_that("build_html() output in other directory", {
    tmpdir <- withr::local_tempdir()
    fs::dir_copy(
        test_path("slides", "basic"),
        fs::path(tmpdir, "slides"),
        overwrite = TRUE
    )

    withr::local_dir(tmpdir)
    fs::dir_create("output")
    quiet_cli(
        expect_message(
            build_html("slides/slides.Rmd", "output/slides.html"),
            "self_contained = TRUE"
        )
    )

    expect_true(fs::file_exists("output/slides.html"))
    expect_false(fs::dir_exists("output/slides_files"))
})
