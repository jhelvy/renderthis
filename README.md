
<!-- README.md is generated from README.Rmd. Please edit that file -->

# renderthis <a href='https://jhelvy.github.io/renderthis/'><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/jhelvy/renderthis/workflows/R-CMD-check/badge.svg)](https://github.com/jhelvy/renderthis/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/renderthis)](https://CRAN.R-project.org/package=renderthis)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

This package contains functions for rendering slides to different
formats, including html, pdf, png, gif, pptx, and mp4, as well as a
‘social’ output, a png of the first slide re-sized for sharing on social
media.

## Installation

You can install the current version of renderthis from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("jhelvy/renderthis")
```

Some output formats require additional packages, and each format will
provide instructions about how to install any missing dependencies. You
can also choose to install renderthis with all of its dependencies:

``` r
# install.packages("remotes")
remotes::install_github("jhelvy/renderthis", dependencies = TRUE)
```

**Note**: To get the most out of renderthis, we recommend installing the
package **with dependencies** and making sure that you have a [local
installation of Google
Chrome](https://jhelvy.github.io/renderthis/articles/renderthis-setup.html#local-chrome-installation).

## Usage

Use renderthis to render slides to different formats. Here is a diagram
of the render hierarchy:

    Rmd
        |
        |--> social (png)
        |
        |--> html
              |
              |--> pdf
                    |
                    |--> png
                          |
                          |--> gif
                          |
                          |--> mp4
                          |
                          |--> pptx

To use renderthis, first load the package:

``` r
library(renderthis)
```

All of the package functions follow a common pattern:

-   All functions use `to_*()` to render slides to a desired format
    (e.g., `to_pdf()`).
-   All functions use the `from` and `to` arguments:
    -   The `from` argument is required and can be a full or local path
        to the input file.
    -   The `to` argument is optional. If provided, it can be a full or
        local path to the output file, and it must end in an appropriate
        extension (e.g. `slides.gif` for `to_gif()`). If it is not
        provided, the output file name will be determined based on the
        `from` argument.

You can render all of the examples below from
[here](https://github.com/jhelvy/renderthis/tree/master/inst/example)

### Render HTML

Render an html file from a Rmd file of xaringan slides:

``` r
to_html(from = "slides.Rmd")
```

### Render PDF

Input can be a Rmd file, html file, or url:

``` r
to_pdf(from = "slides.Rmd")
to_pdf(from = "slides.html")
to_pdf(from = "https://jhelvy.github.io/renderthis/reference/figures/slides.html")
```

**Note**: Rendering the PDF requires a [local installation of Google
Chrome](https://jhelvy.github.io/renderthis/articles/renderthis-setup.html#local-chrome-installation)

### Render GIF

Input can be a Rmd file, html file, pdf file, or url:

``` r
to_gif(from = "slides.Rmd")
to_gif(from = "slides.html")
to_gif(from = "slides.pdf")
to_gif(from = "https://jhelvy.github.io/renderthis/reference/figures/slides.html")
```

Example:

<img src="man/figures/slides.gif" width=500>

### Render MP4

Input can be a Rmd file, html file, pdf file, or url:

``` r
to_mp4(from = "slides.Rmd")
to_mp4from = ("slides.html")
to_mp4(from = "slides.pdf")
to_mp4(from = "https://jhelvy.github.io/renderthis/reference/figures/slides.html")
```

### Render PPTX

Creates a pptx file where each slide contains a png image of each slide.
While you won’t be able to edit the content from Powerpoint, you can at
least annotate it.

(See the [slidex](https://github.com/datalorax/slidex) package by
@datalorax to do the opposite: pptx –\> xaringan!)

Input can be a Rmd file, html file, pdf file, or url:

``` r
to_pptx(from = "slides.Rmd")
to_pptx(from = "slides.html")
to_pptx(from = "slides.pdf")
to_pptx(from = "https://jhelvy.github.io/renderthis/reference/figures/slides.html")
```

### Render PNG

Render png image(s) of some or all slides. Use the `slides` argument to
determine which slides to include (defaults to `1`, returning just the
first slide).

Input can be a Rmd file, html file, pdf file, or url:

``` r
# By default, a png of only the first slide is built
to_png(from = "slides.Rmd", to = "title_slide.png")
to_png(from = "slides.html", to = "title_slide.png")
to_png(from = "slides.pdf", to = "title_slide.png")
to_png(from = 
  "https://jhelvy.github.io/renderthis/reference/figures/slides.html",
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

<img src="man/figures/title_slide.png" width=500>

### Render Social

Render a png of the first slide from an Rmd file. Image is sized for
sharing on social media (e.g. Twitter).

``` r
to_social(from = "slides.Rmd")
```

**Note**: This option requires the
[chromote](https://github.com/rstudio/chromote) and
[pdftools](https://github.com/ropensci/pdftools) packages.

Example:

<img src="man/figures/slides_social.png" width=500>

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

-   `to_pdf()`
-   `to_png()`
-   `to_gif()`
-   `to_mp4()`
-   `to_pptx()`

**Note**: These options require the
[chromote](https://github.com/rstudio/chromote) and
[pdftools](https://github.com/ropensci/pdftools) packages.

## Author, Version, and License Information

-   Authors: [John Paul Helveston](http://www.jhelvy.com/) (*aut*,
    *cre*, *cph*) & [Garrick
    Aden-Buie](https://www.garrickadenbuie.com/) (*aut*)
-   Date First Written: Originally as
    [{xaringanBuilder}](https://github.com/jhelvy/xaringanBuilder) on
    *September 27, 2020*
-   License:
    [MIT](https://github.com/jhelvy/renderthis/blob/master/LICENSE.md)

## Citation Information

If you use this package in a publication, I would greatly appreciate it
if you cited it. You can get the citation information by typing
`citation("renderthis")` into R:

To cite renderthis in publications use:

Helveston, John Paul and Aden-Buie, Garrick (2021). renderthis: Render
slides to different formats.

A BibTeX entry for LaTeX users is

@Manual{, title = {renderthis: Render slides to different formats.},
author = {{Helveston} and John Paul and {Aden-Buie} and {Garrick}}, year
= {2021}, note = {R package version 0.0.1}, url =
{<https://jhelvy.github.io/renderthis/>}, }
