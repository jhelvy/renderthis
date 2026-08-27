# renderthis

## Overview

## Render HTML

Render an HTML file from an `.Rmd` file of xaringan slides or `.qmd` of
Quarto revealjs slides:

``` r

to_html(from = "slides.Rmd")
to_html(from = "slides.qmd")
```

## Render PDF

Input can be an `.Rmd` file, `.qmd` file, `.html` file, or url:

``` r

to_pdf(from = "slides.Rmd")
to_pdf(from = "slides.qmd")
to_pdf(from = "slides.html")
to_pdf(from = "https://jhelvy.github.io/renderthis/example/slides.html")
```

**Note**: Rendering the PDF requires a [local installation of Google
Chrome](https://jhelvy.github.io/renderthis/articles/renderthis-setup.html#local-chrome-installation)

## Render GIF

Input can be an `.Rmd` file, `.qmd` file, `.html` file, `.pdf` file, or
url:

``` r

to_gif(from = "slides.Rmd")
to_gif(from = "slides.qmd")
to_gif(from = "slides.html")
to_gif(from = "slides.pdf")
to_gif(from = "https://jhelvy.github.io/renderthis/example/slides.html")
```

Example:

![](https://jhelvy.github.io/renderthis/example/slides.gif)

## Render MP4

Input can be an `.Rmd` file, `.qmd` file, `.html` file, `.pdf` file, or
url:

``` r

to_mp4(from = "slides.Rmd")
to_mp4(from = "slides.qmd")
to_mp4(from = "slides.html")
to_mp4(from = "slides.pdf")
to_mp4(from = "https://jhelvy.github.io/renderthis/example/slides.html")
```

## Render PPTX

Creates a pptx file where each slide contains a png image of each slide.
While you won’t be able to edit the content in the png(s) from
Powerpoint, you can at least annotate it.

(See the [slidex](https://github.com/datalorax/slidex) package by
@datalorax to do the opposite: pptx –\> xaringan!)

Input can be an `.Rmd` file, `.qmd` file, `.html` file, `.pdf` file, or
url:

``` r

to_pptx(from = "slides.Rmd")
to_pptx(from = "slides.qmd")
to_pptx(from = "slides.html")
to_pptx(from = "slides.pdf")
to_pptx(from = "https://jhelvy.github.io/renderthis/example/slides.html")
```

## Render PNG

Render png image(s) of some or all slides. Use the `slides` argument to
determine which slides to include (defaults to `1`, returning just the
first slide).

Input can be an `.Rmd` file, `.qmd` file, `.html` file, `.pdf` file, or
url:

``` r

# By default, a png of only the first slide is built
to_png(from = "slides.Rmd", to = "title_slide.png")
to_png(from = "slides.qmd", to = "title_slide.png")
to_png(from = "slides.html", to = "title_slide.png")
to_png(from = "slides.pdf", to = "title_slide.png")
to_png(from = 
  "https://jhelvy.github.io/renderthis/example/slides.html",
  to = "title_slide.png"
)

# Use the `slides` argument to control which slides get rendered into pngs
to_png(from = "slides.pdf", to = "first_slide.png", slides = "first")
to_png(from = "slides.pdf", to = "last_slide.png", slides = "last")
to_png(from = "slides.pdf", slides = c(1, 3, 5)) # Choose subsets of slides
to_png(from = "slides.pdf", slides = -1) # Negative indices remove slides
to_png(from = "slides.pdf", slides = "all")
```

Example:

![](https://jhelvy.github.io/renderthis/example/title_slide.png)

## Render Social

Render a png of the first slide from an `.Rmd` file of xaringan slides
(Quarto slides not yet supported). Image is sized for sharing on social
media (e.g. Twitter).

``` r

to_social(from = "slides.Rmd")
```

**Note**: This option requires the
[chromote](https://github.com/rstudio/chromote) and
[pdftools](https://github.com/ropensci/pdftools) packages.

Example:

![](https://jhelvy.github.io/renderthis/example/title_social.png)

## “Complex” slides and partial / incremental slides

“Complex” slides are slides that contain
[panelsets](https://pkg.garrickadenbuie.com/xaringanExtra/#/panelset) or
other html widgets / advanced features that might not render well as a
pdf. To render these on each slide, set `complex_slides = TRUE`.

If you want to render a new slide for each increment on [incremental
slides](https://slides.yihui.org/xaringan/incremental.html#1), set
`partial_slides = TRUE`.

These options are available as options in any of the functions that
depend on rendering the pdf:

- [`to_pdf()`](https://jhelvy.github.io/renderthis/reference/to_pdf.md)
- [`to_png()`](https://jhelvy.github.io/renderthis/reference/to_png.md)
- [`to_gif()`](https://jhelvy.github.io/renderthis/reference/to_gif.md)
- [`to_mp4()`](https://jhelvy.github.io/renderthis/reference/to_mp4.md)
- [`to_pptx()`](https://jhelvy.github.io/renderthis/reference/to_pptx.md)

**Note**: These options require the
[chromote](https://github.com/rstudio/chromote) and
[pdftools](https://github.com/ropensci/pdftools) packages.
