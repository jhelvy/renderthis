library(roxygen2)

# Load all functions for testing
devtools::load_all()

# Create the documentation for the package
devtools::document()

# Install the package
devtools::install(force = TRUE)

# Load the package and view the summary
library(xaringanBuilder)
help(package='xaringanBuilder')

# Install from github
# remotes::install_github('jhelvy/xaringanBuilder')
