
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
