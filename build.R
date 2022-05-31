rm(list = ls())
.rs.restartR()

# Load package
devtools::load_all()

# Create the documentation for the package
devtools::document()

# Install the package
devtools::install(force = TRUE)

# Build the pkgdown site1
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
help(package = 'renderthis')

# Submit to CRAN
devtools::release(check = TRUE)

to_handout("https://matt-dray.github.io/targets-dsfest/", "test/")
