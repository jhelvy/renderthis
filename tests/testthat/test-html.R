test_that("to_html() output in input directory", {
    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)
    suppressMessages(to_html("slides.Rmd"))

    expect_true(fs::file_exists("slides.html"))
    expect_true(fs::dir_exists("slides_files"))
})

test_that("to_html() self-contained output in input directory", {
    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)
    suppressMessages(to_html("slides.Rmd", self_contained = TRUE))

    expect_true(fs::file_exists("slides.html"))
    expect_false(fs::dir_exists("slides_files"))
})

test_that("to_html() output in sub-directory", {
    tmpdir <- withr::local_tempdir()
    fs::dir_copy(
        test_path("slides", "basic"),
        fs::path(tmpdir, "slides"),
        overwrite = TRUE
    )

    withr::local_dir(tmpdir)
    fs::dir_create("output")
    suppressMessages(
        expect_message(
            to_html("slides/slides.Rmd", "output/slides.html"),
            "self_contained = TRUE"
        )
    )

    expect_true(fs::file_exists("output/slides.html"))
    expect_false(fs::dir_exists("output/slides_files"))
})

test_that("to_html() output in parent directory", {
    tmpdir <- withr::local_tempdir()

    fs::dir_copy(
        test_path("slides", "basic"),
        fs::path(tmpdir, "slides"),
        overwrite = TRUE
    )

    withr::local_dir(tmpdir)
    suppressMessages(
        expect_message(
            to_html("slides/slides.Rmd", "slides.html"),
            "self_contained = TRUE"
        )
    )

    expect_true(fs::file_exists("slides.html"))
    expect_false(fs::dir_exists("slides_files"))
})

test_that("to_html() output in totally different directory", {
    tmpdir <- withr::local_tempdir()

    fs::dir_copy(
        test_path("slides", "basic"),
        fs::path(tmpdir, "slides"),
        overwrite = TRUE
    )

    withr::local_dir(tmpdir)
    tmpdir_out <- withr::local_tempdir()

    suppressMessages(
        expect_message(
            to_html("slides/slides.Rmd", fs::path(tmpdir_out, "slides.html")),
            "self_contained = TRUE"
        )
    )

    expect_true(fs::file_exists(fs::path(tmpdir_out, "slides.html")))
})
