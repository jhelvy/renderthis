#' Build png image of first xaringan slide for sharing on social media.
#' Requires a local installation of Chrome.
#' @param input Path to Rmd file of xaringan slides.
#' @param output_file The name of the output file. If using NULL then
#' the output filename will be based on filename for the input file.
#' If a filename is provided, a path to the output file can also be provided.
#' @export
#' @examples
#' \dontrun{
#' # Build png image of first xaringan slide from Rmd file
#' # for sharing on social media
#' build_social("slides.Rmd")
#' }
#'
build_social <- function(input, output_file = NULL) {
    if (!requireNamespace("webshot2", quietly = TRUE)) {
        stop(
            "`webshot2` is required: ",
            'remotes::install_github("rstudio/webshot2")'
        )
    }

    # Check input and output files have correct extensions
    assert_path_ext(input, "rmd", arg = "input")
    output_file <- check_output_file(input, output_file, "png")
    input <- fs::path_abs(input)

    # Append "_social.png" to output_file name
    output_file <- fs::path_ext_set(
        paste0(
            fs::path_ext_remove(output_file),
            "_social"),
        "png"
    )

    print_build_status(input, output_file)

    webshot2::rmdshot(
        doc = input,
        file = output_file,
        vheight = 600,
        vwidth = 600 * 191 / 100,
        rmd_args = list(
            output_options = list(
                nature = list(ratio = "191:100"),
                self_contained = TRUE
            )
        )
    )
}
