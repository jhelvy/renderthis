
<!-- README.md is generated from README.Rmd. Please edit that file -->

# renderthis <a href='https://jhelvy.github.io/renderthis/'><img src='man/figures/logo.png' align="right" height="139" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/jhelvy/renderthis/workflows/R-CMD-check/badge.svg)](https://github.com/jhelvy/renderthis/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/renderthis)](https://CRAN.R-project.org/package=renderthis)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
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

## Usage

You can render all of the examples below from
[here](https://github.com/jhelvy/renderthis/tree/master/inst/example)

Learn more about renderthis in the [Get Started
article](https://jhelvy.github.io/renderthis/articles/renderthis.html).

## Author and License Information

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

## Installing xaringanBuilder

You can install the xaringanBuilder package as it was just prior to the
name change with:

``` r
remotes::install_github("jhelvy/renderthis@v0.0.9")
```

Even though the install command mentions `renderthis`, the package will
be installed as xaringanBuilder.
