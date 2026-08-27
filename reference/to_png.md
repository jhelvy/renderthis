# Render slides as PNG file(s).

Render PNG image(s) of slides. The function renders to the PDF and then
converts it into PNG files of each slide. The slide numbers defined by
the `slides` argument are saved (defaults to `1`, returning only the
title slide). If `length(slides) > 1`, it will return the PNG files in a
ZIP file. You can also get a ZIP file of all the slides as PNGs by
setting `slides = "all"`).

## Usage

``` r
to_png(
  from,
  to = NULL,
  density = 100,
  slides = 1,
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

  Name of the output `.png` or `.zip` file.

- density:

  Resolution of the resulting PNGs in each slide file. Defaults to
  `100`.

- slides:

  A numeric or integer vector of the slide number(s) to render as PNG
  files , or one of `"all"`, `"first"`, or `"last"`. Negative integers
  select which slides *not* to include. If more than one slide are
  included, PNGs will be returned as a ZIP file. Defaults to `"all"`, in
  which case all slides are included.

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

Slides are rendered as a `.png` file (single) or `.zip` file of multiple
`.png` files.

## Examples

``` r
with_example("slides.Rmd", requires_chrome = TRUE, {
    # By default a png of only the first slide is built
    to_png("slides.Rmd", keep_intermediates = TRUE)

    # or render a zip file of multiple or all slides (`slides = "all"`)
    to_png("slides.pdf", slides = c(1, 3, 5))
})
#> ℹ Rendering slides.Rmd into slides.html
#> ✔ Rendering slides.Rmd into slides.html ... done
#> 
#> ℹ Rendering slides.html into slides.pdf
#> ✔ Rendering slides.html into slides.pdf ... done
#> 
#> ℹ Rendering slides.pdf into slides.png
#> ✔ Rendering slides.pdf into slides.png ... done
#> 
#> ℹ Rendering slides.pdf into slides.zip
#> ✔ Rendering slides.pdf into slides.zip ... done
#> 
```
