# Render slides as a GIF file.

Render slides as a GIF video file. The function renders to the PDF,
converts each slide in the PDF to a PNG, and then converts the deck of
PNG files to a GIF file.

## Usage

``` r
to_gif(
  from,
  to = NULL,
  density = 100,
  slides = "all",
  fps = 1,
  complex_slides = FALSE,
  partial_slides = FALSE,
  delay = 1,
  keep_intermediates = FALSE
)
```

## Arguments

- from:

  Path to an `.Rmd`, `.qmd`, `.html`, `.pdf` file, or a URL. If `from`
  is a URL to slides on a website, you must provide the full URL ending
  in `".html"`.

- to:

  Name of the output `.gif` file.

- density:

  Resolution of the resulting PNGs in each slide file. Defaults to
  `100`.

- slides:

  A numeric or integer vector of the slide number(s) to include in the
  GIF, or one of `"all"`, `"first"`, or `"last"`. Negative integers
  select which slides *not* to include. Defaults to `"all"`, in which
  case all slides are included.

- fps:

  Frames per second in the animated GIF.

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

  Should we keep the intermediate files used to render the final output?
  The default is `FALSE`.

## Value

Slides are rendered as a `.gif` file.

## Examples

``` r
with_example("slides.Rmd", requires_chrome = TRUE, {
    # Render gif from Rmd, html, pdf, or direct URL
    to_gif("slides.Rmd")
})
#> ℹ Rendering slides.Rmd into renderthis_28686ff46937.html
#> ✔ Rendering slides.Rmd into renderthis_28686ff46937.html ... done
#> 
#> ℹ Rendering renderthis_28686ff46937.html into renderthis_286860d4734.pdf
#> ✔ Rendering renderthis_28686ff46937.html into renderthis_286860d4734.pdf ... do…
#> 
#> ℹ Removed temporary renderthis_28686ff46937.html
#> ℹ Rendering renderthis_286860d4734.pdf into slides.gif
#> ✔ Rendering renderthis_286860d4734.pdf into slides.gif ... done
#> 
#> ℹ Removed temporary renderthis_286860d4734.pdf
```
