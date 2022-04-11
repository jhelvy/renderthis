test_that("to_png() handles bad inputs", {
    pdf_slides <- test_path("slides", "basic.pdf")

    # Detect errors
    expect_error(to_png("foo.Rmd"), "doesn't exist")

    expect_error(suppressMessages(
        to_png(pdf_slides, slides = 4)
    ), "out of range")
})

test_that("to_png() from .Rmd doesn't keep intermediates by default", {
    skip_if_not_chrome_installed()

    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    # Normal operation, save a single slide to png
    suppressMessages(
        to_png("slides.Rmd", "title-slide.png", slides = 1)
    )
    expect_true(fs::file_exists("title-slide.png"))
    expect_false(fs::file_exists("slides.html"))
    expect_false(fs::dir_exists("slides_files"))
    expect_false(fs::file_exists("slides.pdf"))
})

test_that("to_png() from basic.pdf", {
    tmpdir <- withr::local_tempdir()
    fs::file_copy(
        test_path("slides", "basic.pdf"),
        fs::path(tmpdir, "slides.pdf"),
        overwrite = TRUE
    )

    withr::local_dir(tmpdir)

    # Saving several slides automatically chooses .zip
    suppressMessages(
        to_png("slides.pdf", slides = 2:3)
    )
    expect_true(fs::file_exists("slides.zip"))
    pngs <- zip::zip_list("slides.zip")
    expect_equal(pngs$filename, c("slides_2.png", "slides_3.png"))
})

test_that("to_png() chooses .zip even if .png is given", {
    skip_if_not_chrome_installed()

    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "basic"), tmpdir, overwrite = TRUE)

    withr::local_dir(tmpdir)

    # Saving all slides also chooses .zip even if .png is given
    # Also test keep_intermediates = TRUE (and use in next test)
    suppressMessages(
        to_png("slides.Rmd", "pics.png", slides = "all", keep_intermediates = TRUE)
    )
    expect_true(fs::file_exists("pics.zip"))
    pngs <- zip::zip_list("pics.zip")
    expect_equal(pngs$filename, c("pics_1.png", "pics_2.png", "pics_3.png"))
    expect_true(fs::file_exists("pics.html"))
    expect_true(fs::dir_exists("pics_files"))
    expect_true(fs::file_exists("pics.pdf"))

    # build slide 3 png from the HTML
    suppressMessages(
        to_png("pics.html", "slide-3-html.png", slides = 3)
    )
    expect_true(fs::file_exists("slide-3-html.png"))

    # build slide 3 png from the PDF file
    suppressMessages(
        to_png("pics.pdf", "slide-3-pdf.png", slides = 3)
    )
    expect_true(fs::file_exists("slide-3-pdf.png"))

    # Both versions of slide 3 should be the same
    expect_equal_images("slide-3-pdf.png", "slide-3-html.png")

    suppressMessages(
        expect_warning(
            to_png("pics.pdf", "pics.png", slides = 3:4)
        )
    )
})
