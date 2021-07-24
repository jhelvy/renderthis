# Install from github
# remotes::install_github('jhelvy/xaringanBuilder')
library(xaringanBuilder)

# Build an html file from a Rmd file
build_html("slides.Rmd")

# Build pdf from Rmd, html, or url
build_pdf("slides.Rmd")
build_pdf("slides.html")
build_pdf("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")

# Build gif from Rmd, html, pdf, or url
build_gif("slides.Rmd")
build_gif("slides.html")
build_gif("slides.pdf")
build_gif("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")

# Build mp4 from Rmd, html, pdf, or url
build_mp4("slides.Rmd")
build_mp4("slides.html")
build_mp4("slides.pdf")
build_mp4("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")

# Build pptx from Rmd, html, pdf, or url
# (pptx contains slides of png images of each rendered xaringan slide)
build_pptx("slides.Rmd")
build_pptx("slides.html")
build_pptx("slides.pdf")
build_pptx("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")

# By default, a png of only the first slide is built
build_png("slides.Rmd", output_file = "title_slide.png")
build_png("slides.html", output_file = "title_slide.png")
build_png("slides.pdf", output_file = "title_slide.png")
build_png("https://jhelvy.github.io/xaringanBuilder/reference/figures/slides.html")

# Use the `slides` argument to control which slides get build into pngs
build_png("slides.pdf", output_file = "first_slide.png", slides = "first")
build_png("slides.pdf", output_file = "last_slide.png", slides = "last")
build_png("slides.pdf", slides = c(1, 3, 5)) # Choose subsets of slides
build_png("slides.pdf", slides = -1) # Negative indices remove slides
build_png("slides.pdf", slides = "all")

# Build png image of first xaringan slide from Rmd file
# sized for sharing on social media
build_social("slides.Rmd", output_file = "title_social.png")

# Use `build_all()` to build all output types from a Rmd file:
build_all("slides.Rmd") # Builds every output by default

# Use the `include` or `exclude` arguments to control which output types to
# include or exclude. Both of these build html, pdf, and gif outputs
build_all("slides.Rmd", include = c("html", "pdf", "gif"))
build_all("slides.Rmd", exclude = c("social", "png", "mp4", "pptx"))

# "Complex" slides

# "Complex" slides are slides that contain panelsets or other html
# widgets / advanced features that might not render well as a pdf. To render
# these, set `complex_slides = TRUE`. **Note**: This option requires the
# chromote and pdftools packages.
build_pdf(
    input = "slides.html",
    output_file = "slides_complex.pdf",
    complex_slides = TRUE
)

# Partial / incremental slides

# For pdf, png, gif, and pptx output types, if you want to build a new slide
# for each increment on incremental slides set `partial_slides = TRUE`.
# **Note**: This option requires the chromote and pdftools packages.
build_pdf(
    input = "slides.html",
    output_file = "slides_partial.pdf",
    partial_slides = TRUE
)
