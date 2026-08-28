# Render slides as PDF file.

Render slides as a PDF file. Requires a local installation of Chrome. If
you set `complex_slides = TRUE` or `partial_slides = TRUE`, you will
also need to install the chromote and pdftools packages.

## Usage

``` r
to_pdf(
  from,
  to = NULL,
  complex_slides = FALSE,
  partial_slides = FALSE,
  delay = 1,
  keep_intermediates = NULL
)
```

## Arguments

- from:

  Path to an `.Rmd`, `.qmd`, `.html` file, or a URL. If `from` is a URL
  to slides on a website, you must provide the full URL ending in
  `".html"`.

- to:

  The name of the output `.pdf` file. If `NULL` (the default) then the
  output filename will be based on filename for the `from` file. If a
  filename is provided, a path to the output file can also be provided.

- complex_slides:

  For "complex" slides (e.g. slides with panelsets or other html widgets
  or advanced features), set `complex_slides = TRUE`. Defaults to
  `FALSE`. This will use the chromote package to iterate through the
  slides at a pace set by the `delay` argument. Requires a local
  installation of Chrome.

- partial_slides:

  Should partial (continuation) slides be included in the output? If
  `FALSE`, the default, only the complete slide is included in the PDF.

- delay:

  Seconds of delay between advancing to and printing a new slide. Only
  used if `complex_slides = TRUE` or `partial_slides = TRUE`.

- keep_intermediates:

  Should we keep the intermediate HTML file? Only relevant if the `from`
  file is an `.Rmd` file. Default is `TRUE` if the `to` file is written
  into the same directory as the `from` argument, otherwise the
  intermediate file isn't kept.

## Value

Slides are rendered as a `.pdf` file.

## Details

Rendering waits up to 120 seconds for Chrome to print the slides. Set
the `renderthis.chrome_timeout` option to a different number of seconds
for decks that need longer.

## Examples

``` r
with_example("slides.Rmd", requires_chrome = TRUE, {
    # Render pdf from Rmd, html, or direct URL
    to_pdf("slides.Rmd")
})
#> ℹ Rendering slides.Rmd into slides.html
#> ✔ Rendering slides.Rmd into slides.html ... done
#> 
#> ℹ Rendering slides.html into slides.pdf
#> ✔ Rendering slides.html into slides.pdf ... done
#> 
```
