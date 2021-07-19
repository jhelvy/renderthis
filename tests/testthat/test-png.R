test_that("build_png() output in input directory", {
    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    # Detect errors
    expect_error(build_png("foo.Rmd"), "doesn't exist")
    expect_error(build_png("slides.Rmd", slides = "three"))
    expect_error(build_png("slides.Rmd", slides = 0), ">= 1")
    expect_error(build_png("slides.Rmd", slides = -1), ">= 1")
    expect_error(build_png("slides.Rmd", slides = 1:4 + 0.5), "integer")
    expect_error(quiet_cli(
        build_png("slides.Rmd", slides = 4)
    ), "out of range")

    # Normal operation, save a single slide to png
    quiet_cli(
        build_png("slides.Rmd", "title-slide.png", slides = 1)
    )
    expect_true(fs::file_exists("title-slide.png"))
    expect_false(fs::file_exists("slides.html"))
    expect_false(fs::dir_exists("slides_files"))
    expect_false(fs::file_exists("slides.pdf"))

    # Saving several slides automatically chooses .zip
    quiet_cli(
        build_png("slides.Rmd", slides = 2:3)
    )
    expect_true(fs::file_exists("slides.zip"))
    pngs <- zip::zip_list("slides.zip")
    expect_equal(pngs$filename, c("slides_2.png", "slides_3.png"))
    expect_false(fs::file_exists("slides.html"))
    expect_false(fs::dir_exists("slides_files"))
    expect_false(fs::file_exists("slides.pdf"))

    # Saving all slides also chooses .zip even if .png is given
    # Also test keep_intermediates = TRUE (and use in next test)
    quiet_cli(
        build_png("slides.Rmd", "pics.png", slides = "all", keep_intermediates = TRUE)
    )
    expect_true(fs::file_exists("pics.zip"))
    pngs <- zip::zip_list("pics.zip")
    expect_equal(pngs$filename, c("pics_1.png", "pics_2.png", "pics_3.png"))
    expect_true(fs::file_exists("pics.html"))
    expect_true(fs::dir_exists("pics_files"))
    expect_true(fs::file_exists("pics.pdf"))

    # build slide 3 png from the HTML
    quiet_cli(
        build_png("pics.html", "slide-3-html.png", slides = 3)
    )
    expect_true(fs::file_exists("slide-3-html.png"))

    # build slide 3 png from the PDF file
    quiet_cli(
        build_png("pics.pdf", "slide-3-pdf.png", slides = 3)
    )
    expect_true(fs::file_exists("slide-3-pdf.png"))

    # Both versions of slide 3 should be the same
    expect_equal_images("slide-3-pdf.png", "slide-3-html.png")

    quiet_cli(
        expect_warning(
            build_png("pics.pdf", "pics.png", slides = 3:4)
        )
    )
})
