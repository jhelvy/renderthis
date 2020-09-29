library(xaringanBuilder)

# Build html from Rmd file
build_html(here::here("example", "slides.Rmd"))

# Build pdf from Rmd or html file
build_pdf(here::here("example", "slides.Rmd"))
build_pdf(here::here("example", "slides.html"))

# Build gif from Rmd, html, or pdf file
build_gif(here::here("example", "slides.Rmd"))
build_gif(here::here("example", "slides.html"))
build_gif(here::here("example", "slides.pdf"))

# Build first slide thumbnail from Rmd or html file
build_thumbnail(here::here("example", "slides.Rmd"))
build_thumbnail(here::here("example", "slides.html"))

# Build html, pdf, gif, and thumbnail of first slide from Rmd file
build_all(here::here("example", "slides.Rmd"))
