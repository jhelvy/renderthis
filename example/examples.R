# Install from GitHub
# remotes::install_github('jhelvy/renderthis')
library(renderthis)

# Always use the packaged example slides
file.copy(
    system.file("example", "slides.Rmd", package = "renderthis"),
    "slides.Rmd"
)

url <- "https://jhelvy.github.io/renderthis/reference/figures/slides.html"

# Render an html file from a Rmd file
to_html(from = "slides.Rmd")

# Render pdf from url, Rmd, or html
to_pdf(from = "slides.html")

# Render gif from url, Rmd, html, or pdf
to_gif(from = "slides.pdf")

# Render mp4 from url, Rmd, html, or pdf
to_mp4(from = "slides.pdf")

# Render pptx from url Rmd, html, or pdf
# (pptx contains slides of png images of each rendered xaringan slide)
to_pptx(from = "slides.pdf")

# By default, a png of only the first slide is rendered
to_png(from = "slides.pdf", to = "title_slide.png")

# Render png image of first xaringan slide from Rmd file
# sized for sharing on social media
to_social(from = "slides.Rmd", to = "title_social.png")

# "Complex" slides

# "Complex" slides are slides that contain panelsets or other html
# widgets / advanced features that might not render well as a pdf. To render
# these, set `complex_slides = TRUE`. **Note**: This option requires the
# chromote and pdftools packages.
to_pdf(
    from = "slides.html",
    to = "slides_complex.pdf",
    complex_slides = TRUE
)

# Partial / incremental slides

# For pdf, png, gif, and pptx output types, if you want to render a new slide
# for each increment on incremental slides set `partial_slides = TRUE`.
# **Note**: This option requires the chromote and pdftools packages.
to_pdf(
    from = "slides.html",
    to = "slides_partial.pdf",
    partial_slides = TRUE
)
