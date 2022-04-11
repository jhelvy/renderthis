rm(list = ls())
.rs.restartR()

# Create the documentation for the package
devtools::document()

# Install the package
devtools::install(force = TRUE)

# Build the pkgdown site
pkgdown::build_site()

# Check package
devtools::check()
devtools::check_win_release()
devtools::check_win_devel()
devtools::check_rhub()

# Install from github
remotes::install_github('jhelvy/renderthis')

# Load the package and view the summary
library(renderthis)
help(package='renderthis')

# Submit to CRAN
devtools::release(check = TRUE)
