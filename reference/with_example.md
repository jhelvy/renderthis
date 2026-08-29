# Try renderthis functions with an example

This function primarily exists to ensure that the examples in this
package are readable. But you can also use `with_example()` to try out
the various output functions.

## Usage

``` r
with_example(
  example,
  code,
  clean = TRUE,
  requires_packages = NULL,
  requires_chrome = FALSE
)
```

## Arguments

- example:

  The name of the example file, currently only `"slides.Rmd"`.

- code:

  The code expression to evaluate. You can use the example as an input
  by referencing it directly, e.g. `from = "slides.Rmd"`.

- clean:

  Should the example file and any extra files be cleaned up when the
  function exits? The default is `TRUE`, but if you want to inspect the
  output you should set to `FALSE`.

## Value

Invisibly returns the path to the temp directory where the example was
created when `clean = FALSE`, otherwise invisibly returns the output
from evaluating `expr`.

## Examples

``` r
with_example("slides.Rmd", {
    to_html("slides.Rmd")
})
#> ℹ Rendering slides.Rmd into slides.html
#> ✔ Rendering slides.Rmd into slides.html ... done
#> 

print(with_example("slides.Rmd", getwd()))
#> [1] "/tmp/RtmplB2hJG/file28ac55b0e8d4"
```
