#-----------------------------------------------------------------------------
# install_load_packages.R
#-----------------------------------------------------------------------------
#   This script installs and loads required R packages.
#-----------------------------------------------------------------------------

packages <- c("tidytuesdayR", "dplyr", "tidyverse", "showtext", "ragg", "ggplot2", "scales", "sysfonts")

install.packages(setdiff(packages, rownames(installed.packages())), dependencies = TRUE)
lapply(packages, library, character.only = TRUE)
rm(packages)

#-----------------------------------------------------------------------------
# End of install_load_packages.R
#-----------------------------------------------------------------------------
