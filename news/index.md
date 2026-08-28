# Changelog

## renderthis 0.2.2

- Declares `SystemRequirements` for the Quarto command line tool, which
  is used via the quarto package to render `.qmd` slides.
- Fixes an error when rendering self-contained HTML (and any format
  built from it) caused by a
  [`return()`](https://rdrr.io/r/base/function.html) inside a
  [`withr::defer()`](https://withr.r-lib.org/reference/defer.html)
  block, which withr 3.0.0 no longer supports.
- Fixes `to_pdf(complex_slides = TRUE)` looking up the Chrome window by
  a hard-coded window id, which failed with recent versions of Chrome.
- Rasterizes PDFs with ImageMagick’s own renderer (Ghostscript) where it
  is available, rather than always going through pdftools and poppler.
  Recent poppler builds segfault intermittently while rendering, which
  crashed the whole R session. Where poppler is still needed, it now
  runs in a separate process and is retried, so a crash surfaces as an
  ordinary error instead.
- Waits longer for Chrome when printing slides to PDF. The 30 second
  default in pagedown was not always enough on slow machines, which
  surfaced as a “Failed to generate output in 30 seconds (timeout)”
  error. The wait is now 120 seconds and can be changed with the
  `renderthis.chrome_timeout` option.

## renderthis 0.2.1

- The `ratio` argument was added to the
  [`to_pptx()`](https://jhelvy.github.io/renderthis/reference/to_pptx.md)
  function ([\#66](https://github.com/jhelvy/renderthis/issues/66)) to
  allow users to specify the powerpoint slide aspect ratio.

## renderthis 0.2.0

CRAN release: 2022-09-24

- Addresses several previous issues related to a note about a Crashpad
  file being generated from CI checks on Ubuntu.
- Implements initial support for rendering Quarto revealjs
  presentations.

## renderthis 0.1.1

- Fixes a bug ([\#63](https://github.com/jhelvy/renderthis/issues/63))
  by checking that the path returned by find_chrome() actually exists.

## renderthis 0.1.0

CRAN release: 2022-07-13

- Initial version, most functionality copied / modified from v0.0.9 of
  xaringanBuilder
- Added a `NEWS.md` file to track changes to the package.
