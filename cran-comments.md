## Test environments
* local R installation, R 4.4.1
* win-builder (devel and release)

## R CMD check results
0 errors | 0 warnings | 0 notes

## Notes
This is a resubmission. 

The package was previously archived because it uses Quarto 
(via the 'quarto' package) without declaring it in `SystemRequirements`. 
This release declares the Quarto command line tool in `SystemRequirements`. 
Tests and examples that require Quarto are skipped when the Quarto CLI tool 
is not available.

This release also fixes two errors that surfaced with newer versions of
dependencies:

* An error when rendering self-contained HTML, caused by a `return()` inside a
  `withr::defer()` block, which withr (>= 3.0.0) no longer supports.
* An error in `to_pdf(complex_slides = TRUE)`, caused by a hard-coded Chrome
  window id.
