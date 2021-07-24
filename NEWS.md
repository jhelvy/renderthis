# xaringanBuilder 0.0.9

## Bigger changes

* Added a new argument `keep_intermediates` to all `build_*()` functions downstream from `build_html()`. When `FALSE`, intermediate files required to build the final output are removed when the output is produced. (@gadenbuie #33)
* Improved internal handling of file paths when the input and output files have different base names and directories, using `path_from()` (superceding previous `build_paths()`). (@gadenbuie #33, #30)
* `build_html()` gains `self_contained` and `rmd_args` arguments that are passed to `rmarkdown::render()` and can be used to override the options in the YAML header of the slides document. (@gadenbuie #33)
* `build_html()` now sets `self_contained = TRUE` automatically when the output `.html` file won't be saved to the same directory as the input `.Rmd`. (@gadenbuie #29, #33)
* The `slides` argument now accepts `"all"`, `"first"`, or `"last"` to build the first, last or all slides. `slides` also accepts negative slide indices to exclude slides, e.g. `-1:-3` excludes the first three slides. (@gadenbuie #33)
* Dependencies that are used for only one type of output were made suggested dependencies to improve the installation experience for the majority of users. Install `xaringanBuilder` with `dependencies = TRUE` for full installation. (@gadenbuie #33)

## Smaller changes

* Moved {pdftools} back to Suggests (only used for complex PDFs)

# xaringanBuilder 0.0.8

## Bigger changes

* Added `slides` argument to `build_mp4()`, `build_gif()`, and `build_pptx()` to better control which slides to include in each output format.
* Updated cli messaging to more accurately track with actually build process, including build errors.
* Fixed issue where intermediate paths would break if input and output file names were different.

## Smaller changes

* Added {pdftools} to Imports
* Added version requirement to {magick}
* Changed `magick::image_read()` to `magick::image_read_pdf()` inside `pdf_to_png()`
* Modified the `print_build_status()` to use `paste0()`...was causing a bug using glue syntax.

# xaringanBuilder 0.0.7

* Added `build_mp4()`; closes issue #11
* Added pptx templates for 4-3 & 16-9 aspect ratios; closes issue #15

# xaringanBuilder 0.0.6

* Depreciated `build_thumbnail()` and added `build_png()` as an improved replacement.
* `build_png()` fixes part of issue #15 so that the png aspect ratio matches that of the xaringan slides.
* `build_png()` also has options for changing the png density and building more than just the title slide (can build pngs of some or all slides using the `slides` argument).
* All documentation and examples updated to match new features.
* New example slides made to demonstrate new features.

# xaringanBuilder 0.0.5

* Major improvements to how paths are handled by adding the build_paths() function (not exported). Now you can use a url to build to any output types except for social and html (which both require starting from the Rmd file).
* Added build_to_pdf() function (not exported) as an internal helper to build from a Rmd or html file to the pdf.
* Added `assert_chrome_installed()` for issue #12

# xaringanBuilder 0.0.4

* Added `build_social()` for making a png of the first slides sized for sharing on social media.
* Fixed `output_file` path bug - needed to update to using full paths from root just like with the `input` argument.

# xaringanBuilder 0.0.3

* Integrated the functionality of the `xaringan_to_pdf()` function into the `build_pdf()` function.
* Fixed output_file path check bug - intermediate file building had wrong paths

# xaringanBuilder 0.0.2

* Added new functions:
  - `xaringan_to_pdf()`: Builds to pdf for slides that include complex slides (e.g. with panelsets)
  - `build_pptx()`: Builds to pptx format.
* Added new contributors: Garrick Aden-Buie and Bryan Shalloway.
* Revised examples for new functions, and reduced example sizes.

# xaringanBuilder 0.0.1

* Added a `NEWS.md` file to track changes to the package.
