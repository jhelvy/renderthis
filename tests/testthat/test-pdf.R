test_that("to_pdf() simple", {
    skip_if_not_chrome_installed()

    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "partial-slides"), tmpdir, overwrite = TRUE)
    withr::local_dir(tmpdir)

    suppressMessages(
        to_pdf("partial.Rmd")
    )
    expect_true(fs::file_exists("partial.pdf"))
    expect_true(fs::file_exists("partial.html"))

    skip_if_not_installed("pdftools")
    pdf_info <- pdftools::pdf_info("partial.pdf")
    expect_equal(pdf_info$pages, 4)
})

test_that("to_pdf() simple, other directory", {
    skip_if_not_chrome_installed()

    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "partial-slides"), tmpdir, overwrite = TRUE)
    withr::local_dir(tmpdir)

    fs::dir_create("pdf")
    suppressMessages(
        to_pdf("partial.Rmd", "pdf/out.pdf")
    )
    expect_true(fs::file_exists("pdf/out.pdf"))
    expect_false(fs::file_exists("partial.html"))

    skip_if_not_installed("pdftools")
    pdf_info <- pdftools::pdf_info("pdf/out.pdf")
    expect_equal(pdf_info$pages, 4)
})

test_that("to_pdf() complex slides", {
    skip_if_not_chrome_installed()
    skip_if_not_installed("pdftools")

    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "partial-slides"), tmpdir, overwrite = TRUE)
    withr::local_dir(tmpdir)

    suppressMessages(
        to_pdf("partial.Rmd", complex_slides = TRUE)
    )

    expect_true(fs::file_exists("partial.pdf"))
    expect_true(fs::file_exists("partial.html"))

    pdf_info <- pdftools::pdf_info("partial.pdf")
    expect_equal(pdf_info$pages, 4)
})

test_that("to_pdf() partial slides", {
    skip_if_not_chrome_installed()
    skip_if_not_installed("pdftools")

    tmpdir <- withr::local_tempdir()
    fs::dir_copy(test_path("slides", "partial-slides"), tmpdir, overwrite = TRUE)
    withr::local_dir(tmpdir)

    fs::dir_create("pdf")
    suppressMessages(
        to_pdf("partial.Rmd", "pdf/slides.pdf", partial_slides = TRUE)
    )

    expect_true(fs::file_exists("pdf/slides.pdf"))
    expect_false(fs::file_exists("partial.html"))

    pdf_info <- pdftools::pdf_info("pdf/slides.pdf")
    expect_equal(pdf_info$pages, 5)
})
