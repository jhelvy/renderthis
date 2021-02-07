print_build_status <- function(input, output_file) {
    cli::cli_process_start(
        "Building {.file {fs::path_file(output_file)}} from {.path {fs::path_file(input)}}",
        on_exit = "done"
    )
}

test_path_ext <- function(path, expected_ext) {
    tolower(fs::path_ext(path)) %in% expected_ext
}

assert_path_ext <- function(path, expected_ext, arg = "input") {
    if (!test_path_ext(path, expected_ext)) {
        expected_ext <- paste0(".", expected_ext, collapse = ", ")
        stop("`", arg, "` must have extension: ", expected_ext, call. = FALSE)
    }
}
