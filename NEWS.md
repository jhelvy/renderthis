# renderthis 0.2.2

- Declares `SystemRequirements` for the Quarto command line tool, which is used via the quarto package to render `.qmd` slides.
- Fixes an error when rendering self-contained HTML (and any format built from it) caused by a `return()` inside a `withr::defer()` block, which withr 3.0.0 no longer supports.
- Fixes `to_pdf(complex_slides = TRUE)` looking up the Chrome window by a hard-coded window id, which failed with recent versions of Chrome.

# renderthis 0.2.1

- The `ratio` argument was added to the `to_pptx()` function (#66) to allow users to specify the powerpoint slide aspect ratio.

# renderthis 0.2.0

- Addresses several previous issues related to a note about a Crashpad file being generated from CI checks on Ubuntu.
- Implements initial support for rendering Quarto revealjs presentations.

# renderthis 0.1.1

- Fixes a bug (#63) by checking that the path returned by find_chrome() actually exists.

# renderthis 0.1.0

* Initial version, most functionality copied / modified from v0.0.9 of xaringanBuilder
* Added a `NEWS.md` file to track changes to the package.
