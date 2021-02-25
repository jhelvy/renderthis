
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.com/jhelvy/xaringanBuilder.svg?branch=master)](https://travis-ci.com/jhelvy/xaringanBuilder)
<!-- badges: end -->

## xaringanBuilder <img src="man/figures/hex_sticker.png" align="right" width="200"/>

Build xaringan slides to multiple output formats:

-   html
-   pdf
-   gif
-   pptx
-   png (convert some or all slides to png files; useful for generating
    Youtube thumbnails, for example)
-   social: png image of first slide sized for social media sharing
    (e.g. Twitter)

## Installation

You can install the current version of xaringanBuilder from GitHub:

    # install.packages("remotes")
    remotes::install_github("jhelvy/xaringanBuilder")

## Usage

The xaringan Rmd files used in all examples below can be found
[here](https://github.com/jhelvy/xaringanBuilder/tree/master/inst/example)

    library(xaringanBuilder)

### Input - Output

All `build_**()` functions use the `input` and `output_file` arguments.

The `input` argument is required and can be a full or local path to the
input file (a Rmd, html, or pdf file), or a url to a set of xaringan
slides on the web.

The `output_file` argument is optional. It can be a full or local path
to the output file, and it must end in an appropriate extension
(e.g. `slides.gif` for `build_gif()`). If it is not provided, the output
file name will be determined based on the `input` argument.

### Build HTML

Build an html file from a Rmd file:

    build_html("slides.Rmd")

### Build PDF

Input can be a Rmd file, html file, or url:

    build_pdf("slides.Rmd")
    build_pdf("slides.html")
    build_pdf("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")

**Note**: Building the PDF requires a local installation of Google
Chrome

### Build GIF

Input can be a Rmd file, html file, pdf file, or url:

    build_gif("slides.Rmd")
    build_gif("slides.html")
    build_gif("slides.pdf")
    build_gif("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")

Example:

<img src="man/figures/slides.gif" width=500>

### Build PPTX

Creates a pptx file where each slide contains a png image of each
xaringan slide. While you won’t be able to edit the xaringan content
from Powerpoint, you can at least annotate it.

(See the [slidex](https://github.com/datalorax/slidex) package by
@datalorax to do the opposite: pptx –&gt; xaringan!)

Input can be a Rmd file, html file, pdf file, or url:

    build_pptx("slides.Rmd")
    build_pptx("slides.html")
    build_pptx("slides.pdf")
    build_pptx("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")

### Build PNG

Build png image(s) of some or all slides. Useful for generating Youtube
thumbnails, for example.

Input can be a Rmd file, html file, pdf file, or url:

    # By default, a png of only the first slide is built
    build_png("slides.Rmd")
    build_png("slides.html")
    build_png("slides.pdf")
    build_png("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")

    # Build zip file of multiple or all slides
    build_png("slides.pdf", slides = c(1, 3, 5))
    build_png("slides.pdf", slides = "all")

Example:

<img src="man/figures/slides.png" width=500>

### Build Social

Build a png of the first slide from a Rmd file. Image is sized for
sharing on social media (e.g. Twitter).

    build_social("slides.Rmd")

**Note**: This option requires the
[chromote](https://github.com/rstudio/chromote) and
[pdftools](https://github.com/ropensci/pdftools) packages.

Example:

<img src="man/figures/slides_social.png" width=500>

### Build All Output Types

Use `build_all()` to build all output types from a Rmd file:

    # Builds every output by default
    build_all("slides.Rmd")

Use the `include` or `exclude` arguments to control which output types
to include or exclude:

    # Both of these build html, pdf, and gif outputs
    build_all("slides.Rmd", include = c("html", "pdf", "gif"))
    build_all("slides.Rmd", exclude = c("pptx", "png", "social"))

## “Complex” slides

“Complex” slides are slides that contain
[panelsets](https://pkg.garrickadenbuie.com/xaringanExtra/#/panelset) or
other html widgets / advanced features that might not render well as a
pdf. To render these, set `complex_slides = TRUE` in `build_pdf()`,
`build_png()`, `build_gif()`, `build_pptx()`, or `build_all()`.

For example:

    build_pdf("slides_complex.Rmd", complex_slides = TRUE)
    build_pdf("slides_complex.html", complex_slides = TRUE)

**Note**: This option requires the
[chromote](https://github.com/rstudio/chromote) and
[pdftools](https://github.com/ropensci/pdftools) packages.

## Partial / incremental slides

For pdf, gif, and pptx output types, if you want to build a new slide
for each increment on [incremental
slides](https://slides.yihui.org/xaringan/incremental.html#1), set
`partial_slides = TRUE` in `build_pdf()`, `build_png()`, `build_gif()`,
`build_pptx()`, or `build_all()`.

For example:

    build_pdf("slides.Rmd", partial_slides = TRUE)
    build_pdf("slides.html", partial_slides = TRUE)

**Note**: This option requires the
[chromote](https://github.com/rstudio/chromote) and
[pdftools](https://github.com/ropensci/pdftools) packages.

## Build hierarchy

Some output types depend on intermediate output types (e.g. to build a
pdf from a Rmd file, you first have to build the html file). Here is a
diagram of the build hierarchy:

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
                       |--> pptx

## Local Chrome installation requirement

Building the PDF requires a local installation on Chrome, which may not
be available (e.g. on a computing cluster). If you are unable to install
Chrome, the recommended workflow is to build intermediate output formats
and use an alternative method for building the PDF.

For example, to build a pptx from a Rmd file without Chrome, you could:

1.  Build the html with `build_html("slides.Rmd")`
2.  Use vscode remote and vscode-preview-server extension to open the
    html on a local machine (preferrably with Chrome installed)
3.  Save to pdf on Chrome
4.  Build the pptx with `build_pptx("slides.pdf")`

## Author, Version, and License Information

-   Author: *John Paul Helveston*
    [www.jhelvy.com](http://www.jhelvy.com/)
-   Date First Written: *September 27, 2020*
-   Most Recent Update: February 25, 2021
-   License:
    [MIT](https://github.com/jhelvy/xaringanBuilder/blob/master/LICENSE.md)

## Citation Information

If you use this package in a publication, I would greatly appreciate it
if you cited it. You can get the citation information by typing
`citation("xaringanBuilder")` into R:

To cite xaringanBuilder in publications use:

John Paul Helveston (2021). xaringanBuilder: Functions for building
xaringan slides to different outputs.

A BibTeX entry for LaTeX users is

@Manual{, title = {xaringanBuilder: Functions for building xaringan
slides to different outputs.}, author = {John Paul Helveston}, year =
{2021}, note = {R package version 0.0.6}, url =
{<https://jhelvy.github.io/xaringanBuilder/>}, }
