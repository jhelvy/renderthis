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

    if (is.null(output_file)) {
        output_file <- path_from(input, "social")
    }

    # Check input and output files have correct extensions
    assert_path_ext(input, "rmd")
    assert_path_ext(output_file, "png")

    # Build a temporary html file for the slide snapshot
    # We used to use `webshot2::rmdshot()` but this way we have more control
    step_html <- path_from(input, "html", temporary = TRUE)
    cli::cli_alert_info("Building a temporary html for social image")
    build_html(
        input = input,
        output_file = step_html,
        self_contained = TRUE,
        rmd_args = list(
            output_options = list(nature = list(ratio = "191:100"))
        )
    )

    # Build png from rmd
    proc <- cli_build_start(step_html, output_file, on_exit = "done")
    tryCatch({
        webshot2::webshot(
            url = path_from(step_html, "url"),
            file = output_file,
            vheight = 600,
            vwidth = 600 * 191 / 100
        )},
        error = cli_build_failed(proc)
    )
}
