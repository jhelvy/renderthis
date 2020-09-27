#' Compares if two values are almost equal.
#' @param d1 the first value
#' @param d2 the second value
#' @param epsilon the acceptable difference between d1 and d2 to determine equal
#' @export
almostEqual <- function(n1, n2, threshold = 0.00001) {
    return(abs(n1 - n2) <= threshold)
}
