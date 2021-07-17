test_that("assert_path_ext() stops if path has incorrect extension", {
    input <- "slides.html"
    output_file <- "slides.mp4"
    url <- "http://example.com/slides.html"

    expect_error(
        assert_path_ext(input, "pdf"),
        "`input`.+[.]pdf"
    )

    expect_error(
        assert_path_ext(output_file, "png"),
        "`output_file`.+[.]png"
    )

    expect_error(
        assert_path_ext(output_file, "gif", arg = "something_else"),
        "`something_else`.+[.]gif"
    )

    expect_error(
        assert_path_ext(url, "pptx"),
        "`url`.+[.]pptx"
    )

    expect_silent(assert_path_ext(input, "html"))
    expect_silent(assert_path_ext(output_file, "mp4"))
    expect_silent(assert_path_ext(url, "html"))
})

test_that("path_from() in current directory", {
    expect_equal(
        path_from("slides.html", "html"),
        fs::path_abs("slides.html")
    )

    expect_equal(
        paste0(path_from("slides.html", "url")),
        paste0("file://", fs::path_abs("slides.html"))
    )

    expect_equal(
        path_from("slides.pdf", "pdf"),
        fs::path_abs("slides.pdf")
    )

    expect_equal(
        path_from("slides.html", "PDF"),
        fs::path_abs("slides.PDF")
    )

    expect_equal(
        path_from("slides.png", "html"),
        fs::path_abs("slides.html")
    )

    expect_warning(
        expect_equal(
            path_from("http://example.com/slides.html", "pptx"),
            fs::path_abs("slides.pptx")
        )
    )

    expect_equal(
        path_from("slides.html", "social"),
        fs::path_abs("slides_social.png")
    )
})

test_that("path_from() in other directory", {
    expect_equal(
        path_from("slides.html", "html", dir = fs::path_temp()),
        fs::path_temp("slides.html")
    )

    expect_equal(
        paste0(path_from("slides.html", "url", dir = fs::path_temp())),
        paste0("file://", fs::path_temp("slides.html"))
    )

    expect_equal(
        path_from("slides.pdf", "pdf", dir = fs::path_temp()),
        fs::path_temp("slides.pdf")
    )

    expect_equal(
        path_from("slides.png", "html", dir = fs::path_temp()),
        fs::path_temp("slides.html")
    )

    expect_equal(
        path_from("http://example.com/slides.html", "pptx", dir = fs::path_temp()),
        fs::path_temp("slides.pptx")
    )

    expect_equal(
        path_from("slides.html", "social", dir = fs::path_temp()),
        fs::path_temp("slides_social.png")
    )
})

test_that("path_from() removes temp files when the calling function exits", {
    tmpdir <- fs::path_abs(withr::local_tempdir())
    withr::local_dir(tmpdir)

    path_from_temp <- function(...) {
        # temporarily create the file in a function context
        file <- path_from(..., temporary = TRUE)
        fs::file_create(file)
        list(file = file, existed = unname(fs::file_exists(file)))
    }

    res <- path_from_temp(path = "slides.html", to_ext = "pdf")
    expect_match(res$file, tmpdir, fixed = TRUE)
    expect_match(res$file, "xaringanBuilder_")
    expect_match(res$file, "pdf$")
    expect_true(res$existed)
    expect_false(fs::file_exists(res$file))

    # even when the dir is somewhere else
    tmpdir2 <- fs::path_abs(withr::local_tempdir())
    res <- path_from_temp(path = "slides.html", to_ext = "pdf", dir = tmpdir2)
    expect_match(res$file, tmpdir2, fixed = TRUE)
    expect_match(res$file, "xaringanBuilder_")
    expect_match(res$file, "pdf$")
    expect_true(res$existed)
    expect_false(fs::file_exists(res$file))
})

test_that("in_same_directory() detects files in the same directory", {
    expect_true(in_same_directory("slides.html", "slides.pdf"))
    expect_true(in_same_directory("example/slides.html", "example/slides.pdf"))

    expect_false(in_same_directory("../slides.html", "slides.pdf"))
    expect_false(in_same_directory("slides.html", "../slides.pdf"))
    expect_false(in_same_directory("example/slides.html", "slides.pdf"))
    expect_false(in_same_directory("http://example.com/slides.html", "slides.pdf"))
    expect_false(in_same_directory("slides.pdf", "http://example.com/slides.html"))
})
