Open `examples.Rproj` to open RStudio, then open `examples.R` to run different examples of building slides to different output types.

The main two xaringan slide files are:

- `slides.Rmd`
- `slides_complex.Rmd`

Both contain the same example slides, including [incremental slides](https://slides.yihui.org/xaringan/incremental.html#1), except that `slides_complex.Rmd` has an additional slide with a [panelset](https://pkg.garrickadenbuie.com/xaringanExtra/#/panelset). If you want the panelset slide to render to a separate slide for each panel, set `complex_slides = TRUE` in `build_pdf()`, `build_gif()`, `build_pptx()`, or `build_all()`.
