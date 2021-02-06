
# Setup --------------

# Install from github
# remotes::install_github('jhelvy/xaringanBuilder')
library(xaringanBuilder)

# Set directory to example folder:
setwd(here::here("inst", "example"))

# Examples with "simple" slides --------------

# Build all from Rmd file
build_all("slides.Rmd") # Builds every output by default
# Choose which output types to include
build_all("slides.Rmd", include = c("html", "pdf", "gif"))
# Choose which output types to exclude
build_all("slides.Rmd", exclude = c("pptx", "thumbnail"))

# Build html from Rmd file
build_html("slides.Rmd")

# Build pdf from Rmd or html file
build_pdf("slides.Rmd")
build_pdf("slides.html")

# Build gif from Rmd, html, or pdf file
build_gif("slides.Rmd")
build_gif("slides.html")
build_gif("slides.pdf")

# Build pptx from Rmd, html, or pdf file
build_pptx("slides.Rmd")
build_pptx("slides.html")
build_pptx("slides.pdf")

# Build png of first slide "thumbnail" from Rmd or html file
build_thumbnail("slides.Rmd")
build_thumbnail("slides.html")

# Examples with "complex" or partial slides --------------
# These are slides that have panelsets or other html widgets / advanced
# features, or it's slides where you want to include partial (continuation)
# slides

# Build simple slides to pdf from Rmd or html file and include partial slides
build_pdf("slides.Rmd", partial_slides = TRUE)
build_pdf("slides.html", partial_slides = TRUE)

# Build "complex" slides to pdf from Rmd or html file
build_pdf("slides_complex.Rmd", complex_slides = TRUE)
build_pdf("slides_complex.html", complex_slides = TRUE)

# Build "complex" xaringan slides to pdf from Rmd or html file and include
# partial (continuation) slides
build_pdf(
    input = "slides_complex.Rmd",
    output_file = "slides_complex_partial.pdf",
    complex_slides = TRUE,
    partial_slides = TRUE
)
build_pdf(
    input = "slides_complex.html",
    output_file = "slides_complex_partial.pdf",
    complex_slides = TRUE,
    partial_slides = TRUE
)

