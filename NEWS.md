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
