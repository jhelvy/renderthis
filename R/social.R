# build_social() was inspired by this function from gadenbuie's blog:
# https://www.garrickadenbuie.com/blog/sharing-xaringan-slides/#the-perfect-share-image-ratio

#' Build png image of first slide sized for social media sharing.
#'
#' Build png image of first xaringan slide for sharing on social media.
#' Requires a local installation of Chrome as well as the {webshot2} package:
#' `remotes::install_github("rstudio/webshot2")`.
#' @param input Path to Rmd file of xaringan slides.
#' @param output_file The name of the output file. If using NULL then
#' the output filename will be based on filename for the input file.
#' If a filename is provided, a path to the output file can also be provided.
#' @export
#' @examples
#' \dontrun{
#' # Build png image of first xaringan slide from Rmd file
#' # sized for sharing on social media
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

    # Check if Chrome is installed
    assert_chrome_installed()

    # Check input and output files have correct extensions
    assert_path_ext(input, "rmd")
    assert_path_ext(output_file, "png")

    # Build input and output paths
    paths <- build_paths(input, output_file)
    input <- paths$input$rmd
    output_file <- paths$output$social

    # Build png from rmd
    proc <- cli_build_start(input, output_file, on_exit = "done")
    tryCatch({
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
        )},
        error = cli_build_failed(proc)
    )
}
