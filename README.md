## xaringanBuilder

Build xaringan slides into different formats:
- html
- pdf
- gif
- png thumbnail of first slide

## Installation

Install from github:
```
remotes::install_github("jhelvy/xaringanBuilder")
```

## Usage
```
library(xaringanBuilder)
```

Build html from Rmd file:
```
build_html("slides.Rmd")
```

Build pdf from Rmd or html file:
```
build_pdf("slides.Rmd")
build_pdf("slides.html")
```

Build gif from Rmd, html, or pdf file:
```
build_gif("slides.Rmd")
build_gif("slides.html")
build_gif("slides.pdf")
```

Build first slide thumbnail from Rmd or html file:
```
build_thumbnail("slides.Rmd")
build_thumbnail("slides.html")
```

Build html, pdf, gif, and thumbnail of first slide from Rmd file
```
build_all("slides.Rmd", include = c("html", "pdf", "gif", "thumbnail"))
```
