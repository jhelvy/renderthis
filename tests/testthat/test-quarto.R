test_that("[quarto] to_html() output in input directory", {
    skip_if_not_quarto()

    local_test_example_dir("slides", "quarto-basic")
    suppressMessages(to_html("slides.qmd"))

    expect_true(fs::file_exists("slides.html"))
    expect_true(fs::dir_exists("slides_files"))
})

test_that("[quarto] to_html() self-contained output in input directory", {
    skip_if_not_quarto()

    local_test_example_dir("slides", "quarto-basic")
    suppressMessages(to_html("slides.qmd", self_contained = TRUE))

    expect_true(fs::file_exists("slides.html"))
    expect_false(fs::dir_exists("slides_files"))
})

test_that("[quarto] to_html() output in sub-directory", {
    skip_if_not_quarto()

    local_test_example_dir("slides", "quarto-basic", copy_to = "slides")

    fs::dir_create("output")
    suppressMessages(
        expect_message(
            to_html("slides/slides.qmd", "output/slides.html"),
            "self_contained = TRUE"
        )
    )

    expect_true(fs::file_exists("output/slides.html"))
    expect_false(fs::dir_exists("output/slides_files"))
})

test_that("[quarto] to_html() output in parent directory", {
    skip_if_not_quarto()

    local_test_example_dir("slides", "quarto-basic", copy_to = "slides")
    suppressMessages(
        expect_message(
            to_html("slides/slides.qmd", "slides.html"),
            "self_contained = TRUE"
        )
    )

    expect_true(fs::file_exists("slides.html"))
    expect_false(fs::dir_exists("slides_files"))
})

test_that("[quarto] to_html() output in totally different directory", {
    skip_if_not_quarto()

    local_test_example_dir("slides", "quarto-basic", copy_to = "slides")
    tmpdir_out <- withr::local_tempdir()

    suppressMessages(
        expect_message(
            to_html("slides/slides.qmd", fs::path(tmpdir_out, "slides.html")),
            "self_contained = TRUE"
        )
    )

    expect_true(fs::file_exists(fs::path(tmpdir_out, "slides.html")))
})

test_that("[quarto] to_pdf()", {
    skip_if_not_quarto()
    skip_if_not_chrome_installed()

    local_test_example_dir("slides", "quarto-basic")
    suppressMessages(to_pdf("slides.qmd"))

    expect_true(fs::file_exists("slides.html"))
    expect_true(fs::file_exists("slides.pdf"))
})

test_that("[quarto] to_pdf() with complex slides is not available", {
    skip_if_not_quarto()
    skip_if_not_chrome_installed()

    local_test_example_dir("slides", "quarto-basic")
    expect_error(to_pdf("slides.qmd", complex_slides = TRUE))
    expect_error(to_pdf("slides.qmd", partial_slides = TRUE))
})

test_that("[quarto] to_png()", {
    skip_if_not_quarto()
    skip_if_not_chrome_installed()

    local_test_example_dir("slides", "quarto-basic")
    suppressMessages(to_png("slides.qmd", keep_intermediates = TRUE))

    expect_true(fs::file_exists("slides.png"))
    expect_true(fs::file_exists("slides.html"))
    expect_true(fs::file_exists("slides.pdf"))
})

test_that("[quarto] to_gif()", {
    skip_if_not_quarto()
    skip_if_not_chrome_installed()

    local_test_example_dir("slides", "quarto-basic")
    suppressMessages(to_gif("slides.qmd"))

    expect_true(fs::file_exists("slides.gif"))
})

test_that("[quarto] to_mp4()", {
    skip_if_not_installed("av")
    skip_if_not_quarto()
    skip_if_not_chrome_installed()

    local_test_example_dir("slides", "quarto-basic")
    suppressMessages(to_mp4("slides.qmd", keep_intermediates = TRUE))

    expect_true(fs::file_exists("slides.mp4"))
    expect_true(fs::file_exists("slides.html"))
    expect_true(fs::file_exists("slides.pdf"))
})

test_that("[quarto] to_pptx()", {
    skip_if_not_installed("officer")
    skip_if_not_quarto()
    skip_if_not_chrome_installed()

    local_test_example_dir("slides", "quarto-basic")
    suppressMessages(to_pptx("slides.qmd"))

    expect_true(fs::file_exists("slides.pptx"))
})
