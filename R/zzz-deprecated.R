#' Deprecated Build Functions
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' \pkg{renderthis}, under the name \pkg{xaringanBuilder}, previously provided
#' the same functionality using `build_` functions. To be consistent with the
#' new package name, these function names have also been changed.
#'
#' * `build_html()` is now [to_html()]
#' * `build_pdf()` is now [to_pdf()]
#' * `build_png()` is now [to_png()]
#' * `build_gif()` is now [to_gif()]
#' * `build_mp4()` is now [to_mp4()]
#' * `build_pptx()` is now [to_pptx()]
#' * `build_social()` is now [to_social()]
#'
#' @param ... Parameters passed to the new `to_*()` function
#' @return See the corresponding new function for the appropriate return value.
#'
#' @name deprecated-build
#' @keywords internal
NULL

deprecate_function <- function(old, new) {
    function(...) {
        lifecycle::deprecate_warn(
            when = "0.1.0",
            what = sprintf("%s()", old),
            with = sprintf("%s()", new)
        )
        do.call(new, list(...), envir = parent.frame())
    }
}

#' @rdname deprecated-build
#' @export
build_html <- deprecate_function("build_html", "to_html")

#' @rdname deprecated-build
#' @export
build_pdf <- deprecate_function("build_pdf", "to_pdf")

#' @rdname deprecated-build
#' @export
build_png <- deprecate_function("build_png", "to_png")

#' @rdname deprecated-build
#' @export
build_gif <- deprecate_function("build_gif", "to_gif")

#' @rdname deprecated-build
#' @export
build_mp4 <- deprecate_function("build_mp4", "to_mp4")

#' @rdname deprecated-build
#' @export
build_pptx <- deprecate_function("build_pptx", "to_pptx")

#' @rdname deprecated-build
#' @export
build_social <- deprecate_function("build_social", "to_social")
