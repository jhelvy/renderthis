# Render slides as html file.

Render xaringan or Quarto slides as an html file. In generally, it is
the same thing as
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
or
[`quarto::quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.html)
except that the `self_contained` option is forced to `TRUE` if the HTML
file is built into a directory other than the one containing `from`.

## Usage

``` r
to_html(from, to = NULL, self_contained = FALSE, render_args = NULL)
```

## Arguments

- from:

  Path to an `.Rmd` or `.qmd` file.

- to:

  The name of the output file. If using `NULL` then the output file name
  will be based on file name for the `from` file. If a file name is
  provided, a path to the output file can also be provided.

- self_contained:

  Should the output file be a self-contained HTML file where all images,
  CSS and JavaScript are included directly in the output file? This
  option, when `TRUE`, provides you with a single HTML file that you can
  share with others, but it may be very large. This feature is enabled
  by default when the `to` file is written in a directory other than the
  one containing the `from` R Markdown file.

- render_args:

  A list of arguments passed to
  [`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
  or
  [`quarto::quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.html).

## Value

Slides are rendered as an `.html` file.

## Examples

``` r
with_example("slides.Rmd", {
    # Render html from Rmd file
    to_html("slides.Rmd")
})
#> ℹ Rendering slides.Rmd into slides.html
#> ✔ Rendering slides.Rmd into slides.html ... done
#> 
```
