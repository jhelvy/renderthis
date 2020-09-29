library(roxygen2)

# Load all functions for testing
devtools::load_all()

# Create the documentation for the package
devtools::document()

# Install the package from source files
devtools::install(force = TRUE)

# Install from github
remotes::install_github('jhelvy/xaringanBuilder')

# Load the package and view the summary
library(xaringanBuilder)
help(package='xaringanBuilder')
