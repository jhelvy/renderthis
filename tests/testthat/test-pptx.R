test_that("to_pptx() simple from pdf", {
    skip_if_not_installed("officer")

    tmpdir <- withr::local_tempdir()
    fs::file_copy(test_path("slides", "basic.pdf"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    suppressMessages(
        to_pptx("basic.pdf", "slides.pptx")
    )

    expect_true(fs::file_exists("slides.pptx"))

    expect_equal(
        nrow(officer::pptx_summary(officer::read_pptx("slides.pptx"))),
        3 # three slides
    )

    slide_size <- officer::slide_size(officer::read_pptx("slides.pptx"))
    expect_equal(slide_size$width / slide_size$height, 4/3)
})

test_that("to_pptx() simple from Rmd", {
    skip_if_not_installed("officer")
    skip_if_not_chrome_installed()

    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    suppressMessages(
        to_pptx("slides.Rmd")
    )

    expect_true(fs::file_exists("slides.pptx"))
    expect_false(fs::file_exists("slides.pdf"))
    expect_false(fs::file_exists("slides.html"))

    expect_equal(
        nrow(officer::pptx_summary(officer::read_pptx("slides.pptx"))),
        3 # three slides
    )

    slide_size <- officer::slide_size(officer::read_pptx("slides.pptx"))
    expect_equal(slide_size$width / slide_size$height, 4/3)
})


test_that("to_pptx() widescreen", {
    skip_if_not_installed("officer")

    tmpdir <- withr::local_tempdir()
    fs::file_copy(test_path("slides", "basic-wide.pdf"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    suppressMessages(
        to_pptx(
            "basic-wide.pdf",
            "widescreen.pptx",
            slides = 1:2,
            complex_slides = TRUE,
            keep_intermediates = FALSE
        )
    )

    expect_true(fs::file_exists("widescreen.pptx"))

    expect_equal(
        nrow(officer::pptx_summary(officer::read_pptx("widescreen.pptx"))),
        2 # three slides
    )

    slide_size <- officer::slide_size(officer::read_pptx("widescreen.pptx"))
    expect_equal(slide_size$width / slide_size$height, 16/9)
})
