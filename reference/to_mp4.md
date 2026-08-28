# Render slides as an MP4 video file.

Render slides as an MP4 video file. The function renders to the pdf,
converts each slide in the pdf to a png, and then converts the deck of
png files to a MP4 video file.

## Usage

``` r
to_mp4(
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

  Name of the output `.mp4` file.

- density:

  Resolution of the resulting PNGs in each slide file. Defaults to
  `100`.

- slides:

  A numeric or integer vector of the slide number(s) to include in the
  mp4, or one of `"all"`, `"first"`, or `"last"`. Negative integers
  select which slides *not* to include. Defaults to `"all"`, in which
  case all slides are included.

- fps:

  Frames per second of the resulting `.mp4` file.

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

Slides are rendered as an `.mp4` file.

## Examples

``` r
with_example("slides.Rmd", requires_chrome = TRUE, requires_packages = "av", {
    # Render mp4 from Rmd, html, pdf, or direct URL
    to_mp4("slides.Rmd")
})
#> ℹ Rendering slides.Rmd into renderthis_2889580e1298.html
#> ✔ Rendering slides.Rmd into renderthis_2889580e1298.html ... done
#> 
#> ℹ Rendering renderthis_2889580e1298.html into renderthis_288935b2cfc6.pdf
#> ✔ Rendering renderthis_2889580e1298.html into renderthis_288935b2cfc6.pdf ... d…
#> 
#> ℹ Removed temporary renderthis_2889580e1298.html
#> ℹ Rendering renderthis_288935b2cfc6.pdf into slides.mp4
#> ✔ Rendering renderthis_288935b2cfc6.pdf into slides.mp4 ... done
#> 
#> ℹ Removed temporary renderthis_288935b2cfc6.pdf
```
