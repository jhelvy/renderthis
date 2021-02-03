
<!-- README.md is generated from README.Rmd. Please edit that file -->

## xaringanBuilder <img src="man/figures/hex_sticker.png" align="right" width="200"/>

Build xaringan slides into the following formats:

-   html
-   pdf
-   gif
-   pptx
-   png “thumbnail” of first slide

## Installation

Install from github:

    remotes::install_github("jhelvy/xaringanBuilder")

## Usage

    library(xaringanBuilder)

### All output types

Build all output types from Rmd file - control outputs with `include`
argument:

    build_all("slides.Rmd", include = c("html", "pdf", "gif", "pptx", "thumbnail"))

### HTML

Build html from Rmd file ([view example html
slides](https://jhelvy.github.io/xaringanBuilder/inst/example/slides.html)):

    build_html("slides.Rmd")

### PDF

Build pdf from Rmd or html file ([view example pdf
slides](https://jhelvy.github.io/xaringanBuilder/inst/example/slides.pdf)):

    build_pdf("slides.Rmd")
    build_pdf("slides.html")

### GIF

Build gif from Rmd, html, or pdf file:

    build_gif("slides.Rmd")
    build_gif("slides.html")
    build_gif("slides.pdf")

Example:

<img src="man/figures/slides.gif" width=600>

### PPTX

Build pptx from Rmd, html or pdf file ([view example pptx
slides](https://jhelvy.github.io/xaringanBuilder/inst/example/slides.pptx)):

    build_pptx("slides.Rmd")
    build_pptx("slides.html")
    build_pptx("slides.pdf")

### Thumbnail

Build first slide png “thumbnail” from Rmd or html file:

    build_thumbnail("slides.Rmd")
    build_thumbnail("slides.html")

Example:

<img src="man/figures/slides.png" width=600>

## Author, Version, and License Information

-   Author: *John Paul Helveston*
    [www.jhelvy.com](http://www.jhelvy.com/)
-   Date First Written: *September 27, 2020*
-   Most Recent Update: February 03 2021
-   License:
    [MIT](https://github.com/jhelvy/xaringanBuilder/blob/master/LICENSE.md)

## Citation Information

If you use this package in a publication, I would greatly appreciate it
if you cited it. You can get the citation information by typing
`citation("xaringanBuilder")` into R:

To cite xaringanBuilder in publications use:

John Paul Helveston (2020). xaringanBuilder: Functions for building
xaringan slides to different outputs.

A BibTeX entry for LaTeX users is

@Manual{, title = {xaringanBuilder: Functions for building xaringan
slides to different outputs.}, author = {John Paul Helveston}, year =
{2020}, note = {R package version 0.0.1}, url =
{<https://jhelvy.github.io/xaringanBuilder/>}, }
