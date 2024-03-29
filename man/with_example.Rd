% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/with_example.R
\name{with_example}
\alias{with_example}
\title{Try renderthis functions with an example}
\usage{
with_example(
  example,
  code,
  clean = TRUE,
  requires_packages = NULL,
  requires_chrome = FALSE
)
}
\arguments{
\item{example}{The name of the example file, currently only \code{"slides.Rmd"}.}

\item{code}{The code expression to evaluate. You can use the example as an
input by referencing it directly, e.g. \code{from = "slides.Rmd"}.}

\item{clean}{Should the example file and any extra files be cleaned up when
the function exits? The default is \code{TRUE}, but if you want to inspect the
output you should set to \code{FALSE}.}
}
\value{
Invisibly returns the path to the temp directory where the example
was created when \code{clean = FALSE}, otherwise invisibly returns the output
from evaluating \code{expr}.
}
\description{
This function primarily exists to ensure that the examples in this package
are readable. But you can also use \code{with_example()} to try out the various
output functions.
}
\examples{
with_example("slides.Rmd", {
    to_html("slides.Rmd")
})

print(with_example("slides.Rmd", getwd()))
}
\keyword{internal}
