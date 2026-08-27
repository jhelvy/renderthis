# Deprecated Build Functions

**\[deprecated\]**

renderthis, under the name xaringanBuilder, previously provided the same
functionality using `build_` functions. To be consistent with the new
package name, these function names have also been changed.

- `build_html()` is now
  [`to_html()`](https://jhelvy.github.io/renderthis/reference/to_html.md)

- `build_pdf()` is now
  [`to_pdf()`](https://jhelvy.github.io/renderthis/reference/to_pdf.md)

- `build_png()` is now
  [`to_png()`](https://jhelvy.github.io/renderthis/reference/to_png.md)

- `build_gif()` is now
  [`to_gif()`](https://jhelvy.github.io/renderthis/reference/to_gif.md)

- `build_mp4()` is now
  [`to_mp4()`](https://jhelvy.github.io/renderthis/reference/to_mp4.md)

- `build_pptx()` is now
  [`to_pptx()`](https://jhelvy.github.io/renderthis/reference/to_pptx.md)

- `build_social()` is now
  [`to_social()`](https://jhelvy.github.io/renderthis/reference/to_social.md)

**Argument names.** Note that the `input` and `output_file` arguments of
these functions have also been renamed. They are now named `from` and
`to`.

## Usage

``` r
build_html(...)

build_pdf(...)

build_png(...)

build_gif(...)

build_mp4(...)

build_pptx(...)

build_social(...)
```

## Arguments

- ...:

  Parameters passed to the new `to_*()` function

## Value

See the corresponding new function for the appropriate return value.
