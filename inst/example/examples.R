# Install from github
# remotes::install_github('jhelvy/xaringanBuilder')
library(xaringanBuilder)

# Build All Output Types --------------

# Use `build_all()` to build all output types from a Rmd file:
build_all("slides.Rmd") # Builds every output by default

# Use the `include` or `exclude` arguments to control which output types to
# include or exclude. Both of these build html, pdf, and gif outputs
build_all("slides.Rmd", include = c("html", "pdf", "gif"))
build_all("slides.Rmd", exclude = c("pptx", "thumbnail"))

# Build an html file from a Rmd file --------------
build_html("slides.Rmd")

# Build a pdf file from a Rmd or html file --------------
build_pdf("slides.Rmd")
build_pdf("slides.html")

# Build a gif file from a Rmd, html, or pdf file --------------
build_gif("slides.Rmd")
build_gif("slides.html")
build_gif("slides.pdf")

# Build a pptx file from a Rmd, html or pdf file --------------
# pptx contains slides of png images of each rendered xaringan slide)
build_pptx("slides.Rmd")
build_pptx("slides.html")
build_pptx("slides.pdf")

# Build a "thumbnail" png image of first slide from a Rmd or html file -----
build_thumbnail("slides.Rmd")
build_thumbnail("slides.html")

# "Complex" slides --------------

# "Complex" slides are slides that contain panelsets or other html
# widgets / advanced features that might not render well as a pdf. To render
# these, set `complex_slides = TRUE` in `build_pdf()`, `build_gif()`,
# `build_pptx()`, or `build_all()`. **Note**: This option requires a local
# installation of Google Chrome as well as the chromote package.
build_pdf(input = "slides_complex.Rmd",
          output_file = "slides_complex.pdf",
          complex_slides = TRUE)
build_pdf(input = "slides_complex.html",
          output_file = "slides_complex.pdf",
          complex_slides = TRUE)

# Partial / incremental slides --------------

# For pdf, gif, and pptx output types, if you want to build a new slide for
# each increment on incremental slides set `partial_slides = TRUE` in
# `build_pdf()`, `build_gif()`, `build_pptx()`, or `build_all()`. **Note**:
# This option requires a local installation of Google Chrome as well as the
# chromote package.
build_pdf(input = "slides.Rmd",
          output_file = "slides_partial.pdf",
          partial_slides = TRUE)
build_pdf(input = "slides.html",
          output_file = "slides_partial.pdf",
          partial_slides = TRUE)
