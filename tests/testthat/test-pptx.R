test_that("build_pptx() simple", {
    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    quiet_cli(
        build_pptx("slides.Rmd")
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

test_that("build_pptx() wide-angle", {
    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    quiet_cli(
        build_html("slides.Rmd", "widescreen.html", rmd_args = list(
            output_options = list(nature = list(ratio = "16:9"))
        ))
    )

    quiet_cli(
        build_pptx(
            "widescreen.html",
            "widescreen.pptx",
            slides = 1:2,
            complex_slides = TRUE,
            keep_intermediates = TRUE
        )
    )

    expect_true(fs::file_exists("widescreen.pptx"))
    expect_true(fs::file_exists("widescreen.pdf"))
    expect_true(fs::file_exists("widescreen.html"))

    expect_equal(
        nrow(officer::pptx_summary(officer::read_pptx("widescreen.pptx"))),
        2 # three slides
    )

    slide_size <- officer::slide_size(officer::read_pptx("widescreen.pptx"))
    expect_equal(slide_size$width / slide_size$height, 16/9)
})
