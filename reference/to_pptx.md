# Render slides as a PowerPoint file.

Render slides as a `.pptx` file. The function renders to the PDF and
then converts it into PNG images that are inserted on each slide in the
PowerPoint file.

## Usage

``` r
to_pptx(
  from,
  to = NULL,
  density = 100,
  slides = "all",
  complex_slides = FALSE,
  partial_slides = FALSE,
  delay = 1,
  keep_intermediates = FALSE,
  ratio = NULL
)
```

## Arguments

- from:

  Path to an `.Rmd`, `.qmd`, `.html`, `.pdf` file, or a URL. If `from`
  is a URL to slides on a website, you must provide the full URL ending
  in `".html"`.

- to:

  Name of the output `.pptx` file.

- density:

  Resolution of the resulting PNGs in each slide file. Defaults to
  `100`.

- slides:

  A numeric or integer vector of the slide number(s) to include in the
  pptx, or one of `"all"`, `"first"`, or `"last"`. Negative integers
  select which slides *not* to include. Defaults to `"all"`, in which
  case all slides are included.

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

- ratio:

  PowerPoint slides aspect ratio. Possible values are `"4:3"` or
  `"16:9"`. Default to `NULL`, in which case the ratio will be guessed
  from the slides.

## Value

Slides are rendered as a pptx file.

## Examples

``` r
with_example("slides.Rmd", requires_chrome = TRUE, requires_packages = "officer", {
    # Render pptx from Rmd, html, pdf, or direct URL
    to_pptx("slides.Rmd")
})
#> ℹ Rendering slides.Rmd into renderthis_28ac1c5694c3.html
#> ✔ Rendering slides.Rmd into renderthis_28ac1c5694c3.html ... done
#> 
#> ℹ Rendering renderthis_28ac1c5694c3.html into renderthis_28ac712adda7.pdf
#> ✔ Rendering renderthis_28ac1c5694c3.html into renderthis_28ac712adda7.pdf ... d…
#> 
#> ℹ Removed temporary renderthis_28ac1c5694c3.html
#> ℹ Rendering renderthis_28ac712adda7.pdf into slides.pptx
#> ✔ Rendering renderthis_28ac712adda7.pdf into slides.pptx ... done
#> 
#> ℹ Removed temporary renderthis_28ac712adda7.pdf
```
