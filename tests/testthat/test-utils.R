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

    shouldnt_be_null <- NULL
    expect_error(
        assert_path_ext(shouldnt_be_null, "pdf"),
        "must be a path with extension pdf"
    )

    expect_silent(assert_path_ext(input, "html"))
    expect_silent(assert_path_ext(output_file, "mp4"))
    expect_silent(assert_path_ext(url, "html"))
})

test_that("assert_path_exists() stops if the path doesn't exist", {
    withr::local_dir(withr::local_tempdir())

    input <- "slides.html"
    url <- "http://example.com/slides"
    input_dir <- "slides_dir"

    expect_error(assert_path_exists(input), "doesn't exist")
    expect_error(assert_path_exists(input_dir), "doesn't exist")
    expect_error(assert_path_exists(input_dir, dir_ok = TRUE), "doesn't exist")
    expect_error(assert_path_exists(NULL), "must be a path")
    expect_silent(assert_path_exists(url))

    fs::file_create(input)
    fs::dir_create(input_dir)
    expect_silent(assert_path_exists(input))
    expect_error(assert_path_exists(input_dir), "doesn't exist")
    expect_silent(assert_path_exists(input_dir, dir_ok = TRUE))
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

    path_from_temp <- function(path, to_ext, dir = NULL) {
        # temporarily create the file in a function context
        file <- path_from(path, to_ext, temporary = TRUE, dir = dir)
        files_dir <- paste0(fs::path_ext_remove(file), "_files")
        fs::file_create(file)
        if (to_ext == "html") {
            fs::dir_create(files_dir)
        }
        list(
            file = file,
            existed = unname(fs::file_exists(file)),
            files_dir = files_dir,
            dir_existed = unname(fs::dir_exists(files_dir))
        )
    }

    res <- quiet_cli(
        path_from_temp(path = "slides.html", to_ext = "pdf")
    )
    expect_match(res$file, tmpdir, fixed = TRUE)
    expect_match(res$file, "xaringanBuilder_")
    expect_match(res$file, "pdf$")
    expect_true(res$existed)
    expect_false(fs::file_exists(res$file))

    # even when the dir is somewhere else
    tmpdir2 <- fs::path_abs(withr::local_tempdir())
    res <- quiet_cli(
        path_from_temp(path = "slides.html", to_ext = "pdf", dir = tmpdir2)
    )
    expect_match(res$file, tmpdir2, fixed = TRUE)
    expect_match(res$file, "xaringanBuilder_")
    expect_match(res$file, "pdf$")
    expect_true(res$existed)
    expect_false(fs::file_exists(res$file))

    # removes supporting files when producing HTML
    res <- quiet_cli(
        path_from_temp(path = "slides.rmd", to_ext = "html")
    )
    expect_match(res$file, tmpdir, fixed = TRUE)
    expect_match(res$file, "xaringanBuilder_")
    expect_match(res$file, "html$")
    expect_true(res$existed)
    expect_true(res$dir_existed)
    expect_false(fs::file_exists(res$file))
    expect_false(fs::file_exists(res$files_dir))
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
