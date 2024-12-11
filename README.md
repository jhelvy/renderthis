
<!-- README.md is generated from README.Rmd. Please edit that file -->

# renderthis <a href='https://jhelvy.github.io/renderthis/'><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/jhelvy/renderthis/workflows/R-CMD-check/badge.svg)](https://github.com/jhelvy/renderthis/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/renderthis)](https://CRAN.R-project.org/package=renderthis)
[![Lifecycle:
stable](https://lifecycle.r-lib.org/articles/figures/lifecycle-stable.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

This package contains functions for rendering [R
Markdown](https://rmarkdown.rstudio.com) and
[Quarto](https://quarto.org) documents — priamrily
[xaringan](https://slides.yihui.org/xaringan/) or
[revealjs](https://quarto.org/docs/presentations/revealjs/) slides — to
different formats, including HTML, PDF, PNG, GIF, PPTX, and MP4, as well
as a ‘social’ output, a png of the first slide re-sized for sharing on
social media.

**Looking for xaringanBuilder?** The `renderthis` package was previously
called `xaringanBuilder`. We updated the name as the package evolved
(see [this blog
post](https://www.jhelvy.com/blog/2022-06-28-introducing-renderthis/)
detailing the package’s history) If you need to install
`xaringanBuilder` under the previous package name, [see the instructions
below](#installing-xaringanbuilder).

## Installation

**Note**: To get the most out of renderthis, we recommend installing the
package **with dependencies** and making sure that you have a local
installation of Google Chrome. See the
[Setup](https://jhelvy.github.io/renderthis/articles/renderthis-setup.html)
page for details.

Since `renderthis` is temporarily not on CRAN (we’ll eventually get it
back up), you can install it from GitHub with:

``` r
# install.packages("pak")
pak::pak("jhelvy/renderthis")
```

Some output formats require additional packages, and each format will
provide instructions about how to install any missing dependencies. You
can also choose to install `renderthis` with all of its dependencies:

``` r
# From GitHub
pak::pak("jhelvy/renderthis", dependencies = TRUE)
```

## Usage

Use renderthis to render slides to different formats. Here is a diagram
of the render hierarchy:

    Rmd / qmd
     |
     |--> social (png, from Rmd only)
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

- All functions start with `to_*()` to render slides to a desired format
  (e.g., `to_pdf()`).
- All functions have a required `from` argument which should be set to
  the full or local path to the input file.
- All functions have an optional `to` argument. If provided, it can be a
  full or local path to the output file, and it must end in an
  appropriate extension (e.g. `slides.gif` for `to_gif()`). If it is not
  provided, the output file name will be determined based on the `from`
  argument.

Learn more about renderthis in the [Get Started
article](https://jhelvy.github.io/renderthis/articles/renderthis.html).

## Author and License Information

- Authors: [John Paul Helveston](https://www.jhelvy.com/) (*aut*, *cre*,
  *cph*) & [Garrick Aden-Buie](https://www.garrickadenbuie.com/) (*aut*)
- Date First Written: Originally as {xaringanBuilder} on *September 27,
  2020*
- License:
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

## Installing xaringanBuilder

If you want, you can still install the `xaringanBuilder` package as it
was just prior to the name change with:

``` r
remotes::install_github("jhelvy/renderthis@v0.0.9")
```

Even though the install command mentions `renderthis`, the package will
be installed as xaringanBuilder.
