# Build slides to multiple outputs.

**\[deprecated\]**

Build slides to multiple outputs. Options are `"html"`, `"social"`
`"pdf"`, `"png"`, `"gif"`, `"mp4"`, and `"pptx"`. See each individual
build\_\*() function for details about each output type.

## Usage

``` r
build_all(
  input,
  include = c("html", "social", "pdf", "png", "gif", "mp4", "pptx"),
  exclude = NULL,
  complex_slides = FALSE,
  partial_slides = FALSE,
  delay = 1,
  density = 100,
  slides = "all",
  fps = 1
)
```

## Arguments

- input:

  Path to an `.Rmd` or `.qmd` file of slides.

- include:

  A vector of the different output types to build. Options are `"html"`,
  `"social"`, `"pdf"`, `"png"`, `"gif"`, `"mp4"`, and `"pptx"`. Defaults
  to `c("html", "social", "pdf", "png", "gif", "mp4", "pptx")`.

- exclude:

  A vector of the different output types to NOT build. Options are
  `"html"`, `"social"`, `"pdf"`, `"png"`, `"gif"`, `"mp4"`, and
  `"pptx"`. Defaults to `NULL`, in which case all all output types are
  built.

- complex_slides:

  For "complex" slides (e.g. slides with panelsets or other html widgets
  or advanced features), set `complex_slides = TRUE`. Defaults to
  `FALSE`. This will use the chromote package to iterate through the
  slides at a pace set by the `delay` argument. Requires a local
  installation of Chrome.

- partial_slides:

  Should partial (continuation) slides be included in the output? If
  `FALSE`, the default, only the complete slide is included in the PDF.

- delay:

  Seconds of delay between advancing to and printing a new slide. Only
  used if `complex_slides = TRUE` or `partial_slides = TRUE`.

- density:

  Resolution of the resulting PNGs in each slide file. Defaults to
  `100`.

- slides:

  A numeric or integer vector of the slide number(s) to render as PNG
  files , or one of `"all"`, `"first"`, or `"last"`. Negative integers
  select which slides *not* to include. If more than one slide are
  included, PNGs will be returned as a ZIP file. Defaults to `"all"`, in
  which case all slides are included.

- fps:

  Frames per second of the resulting `.mp4` file.

## Value

Builds slides to multiple output formats.

## Examples

``` r
if (interactive()) {
    # Both of these build html and pdf outputs
    # (PDF outputs require Google Chrome for {pagedown})
    with_example("slides.Rmd", requires_chrome = TRUE, {
        build_all("slides.Rmd", include = c("html", "pdf"))
    })
}
```
