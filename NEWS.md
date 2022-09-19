# renderthis 0.2.0

- Adjusted some of the examples so that the ones that require Chrome do not run on CRAN.
- Added initial support for rendering quarto revealjs slides by allowing `to_html()` to call `quarto::quarto_render()`.

# renderthis 0.1.1

- Fixes a bug (#63) by checking that the path returned by find_chrome() actually exists.

# renderthis 0.1.0

* Initial version, most functionality copied / modified from v0.0.9 of xaringanBuilder
* Added a `NEWS.md` file to track changes to the package.
