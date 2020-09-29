# Build html from Rmd file
build_html(here::here("test", "demo.Rmd"))

# Build PDF from Rmd file
build_pdf(here::here("test", "demo.Rmd"))

# Build PDF from html file
build_pdf(here::here("test", "demo.html"))

# Build first slide thumbnail from Rmd file
build_thumbnail(here::here("test", "demo.Rmd"))

# Build first slide thumbnail from html file
build_thumbnail(here::here("test", "demo.html"))
