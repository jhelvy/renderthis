% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pdf.R
\name{to_pdf}
\alias{to_pdf}
\title{Render slides as PDF file.}
\usage{
to_pdf(
  from,
  to = NULL,
  complex_slides = FALSE,
  partial_slides = FALSE,
  delay = 1,
  keep_intermediates = NULL
)
}
\arguments{
\item{from}{Path to an \code{.Rmd}, \code{.qmd}, \code{.html} file, or a URL. If \code{from} is a
URL to slides on a website, you must provide the full URL ending in
\code{".html"}.}

\item{to}{The name of the output \code{.pdf} file. If \code{NULL} (the default) then
the output filename will be based on filename for the \code{from} file. If a
filename is provided, a path to the output file can also be provided.}

\item{complex_slides}{For "complex" slides (e.g. slides with panelsets or
other html widgets or advanced features), set \code{complex_slides = TRUE}.
Defaults to \code{FALSE}. This will use the {chromote} package to iterate
through the slides at a pace set by the \code{delay} argument. Requires a local
installation of Chrome.}

\item{partial_slides}{Should partial (continuation) slides be included in the
output? If \code{FALSE}, the default, only the complete slide is included in the
PDF.}

\item{delay}{Seconds of delay between advancing to and printing a new slide.
Only used if \code{complex_slides = TRUE} or \code{partial_slides = TRUE}.}

\item{keep_intermediates}{Should we keep the intermediate HTML file? Only
relevant if the \code{from} file is an \code{.Rmd} file. Default is \code{TRUE}
if the \code{to} file is written into the same directory as the \code{from} argument,
otherwise the intermediate file isn't kept.}
}
\value{
Slides are rendered as a \code{.pdf} file.
}
\description{
Render slides as a PDF file. Requires a local installation of Chrome.
If you set \code{complex_slides = TRUE} or \code{partial_slides = TRUE}, you will also
need to install the {chromote} and {pdftools} packages.
}
\examples{
with_example("slides.Rmd", requires_chrome = TRUE, {
    # Render pdf from Rmd, html, or direct URL
    to_pdf("slides.Rmd")
})
}
