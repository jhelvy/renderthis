
<!-- README.md is generated from README.Rmd. Please edit that file -->

# renderthis <a href='https://jhelvy.github.io/renderthis/'><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/jhelvy/renderthis/workflows/R-CMD-check/badge.svg)](https://github.com/jhelvy/renderthis/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/renderthis)](https://CRAN.R-project.org/package=renderthis)
[![Lifecycle:
stable](https://lifecycle.r-lib.org/articles/figures/lifecycle-stable.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

This package contains functions for rendering xaringan slides to
different formats, including html, pdf, png, gif, pptx, and mp4, as well
as a ‘social’ output, a png of the first slide re-sized for sharing on
social media.

**Looking for xaringanBuilder?** The package formerly known as
xaringanBuilder is now **renderthis**. If you need to install
xaringanBuilder under the previous package name, [see the instructions
below](#installing-xaringanbuilder).

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

Because many users will not need all output formats, several outputs
require additional packages that are suggested dependencies and aren’t
installed by default unless requested as described above. The table
below lists the packages required for each output type:

| Output        | Requires                                                   |
|:--------------|:-----------------------------------------------------------|
| PDF (simple)  | Google Chrome (for [pagedown](https://pagedown.rbind.io/)) |
| PDF (complex) | [chromote](https://rstudio.github.io/chromote/)            |
| PNG           | Requires PDF                                               |
| GIF           | Requires PDF                                               |
| MP4           | [av](https://docs.ropensci.org/av/)                         |
| PPTX          | [officer](https://ardata-fr.github.io/officeverse/)        |
| Social        | [chromote](https://rstudio.github.io/chromote/)            |

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

-   All functions start with `to_*()` to render slides to a desired
    format (e.g., `to_pdf()`).
-   All functions have a required `from` argument which should be set to
    the full or local path to the input file.
-   All functions have an optional `to` argument. If provided, it can be
    a full or local path to the output file, and it must end in an
    appropriate extension (e.g. `slides.gif` for `to_gif()`). If it is
    not provided, the output file name will be determined based on the
    `from` argument.

Learn more about renderthis in the [Get Started
article](https://jhelvy.github.io/renderthis/articles/renderthis.html).

## Author and License Information

-   Authors: [John Paul Helveston](https://www.jhelvy.com/) (*aut*,
    *cre*, *cph*) & [Garrick
    Aden-Buie](https://www.garrickadenbuie.com/) (*aut*)
-   Date First Written: Originally as {xaringanBuilder} on *September
    27, 2020*
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

## Installing xaringanBuilder

You can install the xaringanBuilder package as it was just prior to the
name change with:

``` r
remotes::install_github("jhelvy/renderthis@v0.0.9")
```

Even though the install command mentions `renderthis`, the package will
be installed as xaringanBuilder.
