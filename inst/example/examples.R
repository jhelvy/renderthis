# Install from github
# remotes::install_github('jhelvy/renderthis')
library(renderthis)

url <- "https://jhelvy.github.io/renderthis/reference/figures/slides.html"

# Render an html file from a Rmd file
to_html("slides.Rmd")

# Render pdf from url, Rmd, or html
to_pdf(url)
to_pdf("slides.Rmd")
to_pdf("slides.html")

# Render gif from url, Rmd, html, or pdf
to_gif(url)
to_gif("slides.Rmd")
to_gif("slides.html")
to_gif("slides.pdf")

# Render mp4 from url, Rmd, html, or pdf
to_mp4(url)
to_mp4("slides.Rmd")
to_mp4("slides.html")
to_mp4("slides.pdf")

# Render pptx from url Rmd, html, or pdf
# (pptx contains slides of png images of each rendered xaringan slide)
to_pptx(url)
to_pptx("slides.Rmd")
to_pptx("slides.html")
to_pptx("slides.pdf")

# By default, a png of only the first slide is built
to_png(url, output_file = "title_slide.png")
to_png("slides.Rmd", output_file = "title_slide.png")
to_png("slides.html", output_file = "title_slide.png")
to_png("slides.pdf", output_file = "title_slide.png")

# Use the `slides` argument to control which slides get rendered into pngs
to_png("slides.pdf", output_file = "first_slide.png", slides = "first")
to_png("slides.pdf", output_file = "last_slide.png", slides = "last")
to_png("slides.pdf", slides = c(1, 3, 5)) # Choose subsets of slides
to_png("slides.pdf", slides = -1) # Negative indices remove slides
to_png("slides.pdf", slides = "all")

# Render png image of first xaringan slide from Rmd file
# sized for sharing on social media
to_social("slides.Rmd", output_file = "title_social.png")

# "Complex" slides

# "Complex" slides are slides that contain panelsets or other html
# widgets / advanced features that might not render well as a pdf. To render
# these, set `complex_slides = TRUE`. **Note**: This option requires the
# chromote and pdftools packages.
to_pdf(
    input = "slides.html",
    output_file = "slides_complex.pdf",
    complex_slides = TRUE
)

# Partial / incremental slides

# For pdf, png, gif, and pptx output types, if you want to render a new slide
# for each increment on incremental slides set `partial_slides = TRUE`.
# **Note**: This option requires the chromote and pdftools packages.
to_pdf(
    input = "slides.html",
    output_file = "slides_partial.pdf",
    partial_slides = TRUE
)
