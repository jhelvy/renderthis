# Render png image of first slide sized for social media sharing.

Render png image of first slide for sharing on social media. Requires a
local installation of Chrome as well as the webshot2 package:
`remotes::install_github("rstudio/webshot2")`.

## Usage

``` r
to_social(from, to = NULL)
```

## Arguments

- from:

  Path to Rmd file of input media (e.g., xaringan slides).

- to:

  The name of the output file. If using NULL then the output filename
  will be based on filename for the `from` file. If a filename is
  provided, a path to the output file can also be provided.

## Value

Slides are rendered as a png file.

## Examples

``` r
if (interactive()) {
    with_example("slides.Rmd", requires_chrome = TRUE, requires_packages = "webshot2", {
        # Render png image of first slide from Rmd file
        # sized for sharing on social media
        to_social("slides.Rmd")
    })
}
```
