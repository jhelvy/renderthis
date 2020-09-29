# Build html from Rmd file
build_html(here::here("test", "slides.Rmd"))

# Build pdf from Rmd or html file
build_pdf(here::here("test", "slides.Rmd"))
build_pdf(here::here("test", "slides.html"))

# Build gif from Rmd, html, or pdf file
build_gif(here::here("test", "slides.Rmd"))
build_gif(here::here("test", "slides.html"))
build_gif(here::here("test", "slides.pdf"))

# Build first slide thumbnail from Rmd or html file
build_thumbnail(here::here("test", "slides.Rmd"))
build_thumbnail(here::here("test", "slides.html"))

# Build html, pdf, gif, and thumbnail of first slide from Rmd file
build_all(here::here("test", "slides.Rmd"))
