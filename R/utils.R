print_build_status <- function(input, output_file) {
    cli::cli_process_start(
        "Building {.file {fs::path_file(output_file)}} from {.path {fs::path_file(input)}}",
        on_exit = "done"
    )
}

test_path_ext <- function(path, expected_ext) {
    tolower(fs::path_ext(path)) %in% expected_ext
}

assert_path_ext <- function(path, expected_ext, arg) {
    if (!test_path_ext(path, expected_ext)) {
        expected_ext <- paste0(".", expected_ext, collapse = ", ")
        stop("`", arg, "` must have extension: ", expected_ext, call. = FALSE)
    }
}

pdf_to_pngs <- function(input, density) {
    pdf <- magick::image_read(input, density = density)
    pngs <- magick::image_convert(pdf, 'png')
    return(pngs)
}

check_output_file <- function(input, output_file, ext) {
    if (is.null(output_file)) {
        return(fs::path_ext_set(input, ext))
    }
    assert_path_ext(output_file, ext, arg = "output_file")
    return(output_file)
}
