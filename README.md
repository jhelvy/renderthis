
<!-- README.md is generated from README.Rmd. Please edit that file -->

## xaringanBuilder <img src="images/hex_sticker.png" align="right" width="200"/>

Build xaringan slides into the following formats:

  - html
  - pdf
  - gif
  - png thumbnail of first slide

## Installation

Install from github:

    remotes::install_github("jhelvy/xaringanBuilder")

## Usage

    library(xaringanBuilder)

Build html from Rmd file ([view example html
slides](https://jhelvy.github.io/xaringanBuilder/inst/example/slides.html)):

    build_html("slides.Rmd")

Build pdf from Rmd or html file ([view example pdf
slides](https://jhelvy.github.io/xaringanBuilder/inst/example/slides.pdf)):

    build_pdf("slides.Rmd")
    build_pdf("slides.html")

Build gif from Rmd, html, or pdf file:

    build_gif("slides.Rmd")
    build_gif("slides.html")
    build_gif("slides.pdf")

Example:

<img src="images/slides.gif" width=600>

Build first slide thumbnail from Rmd or html file:

    build_thumbnail("slides.Rmd")
    build_thumbnail("slides.html")

Example:

<img src="images/slides.png" width=600>

Build everything (html, pdf, gif, and thumbnail of first slide) from Rmd
file:

    build_all("slides.Rmd", include = c("html", "pdf", "gif", "thumbnail"))

## Author, Version, and License Information

  - Author: *John Paul Helveston*
    [www.jhelvy.com](http://www.jhelvy.com/)
  - Date First Written: *September 27, 2020*
  - Most Recent Update: December 06 2020
  - License:
    [MIT](https://github.com/jhelvy/xaringanBuilder/blob/master/LICENSE.md)
  - [Latest
    Release](https://github.com/jhelvy/xaringanBuilder/releases/latest):
    0.0.1

## Citation Information

If you use this package for in a publication, I would greatly appreciate
it if you cited it. You can get the citation information by typing
`citation("xaringanBuilder")` into R:

To cite package ‘xaringanBuilder’ in publications use:

John Helveston (2020). xaringanBuilder: Functions for building xaringan
slides as pdfs, pngs, and gifs.. R package version 0.1.0.

A BibTeX entry for LaTeX users is

@Manual{, title = {xaringanBuilder: Functions for building xaringan
slides as pdfs, pngs, and gifs.}, author = {John Helveston}, year =
{2020}, note = {R package version 0.1.0}, }
