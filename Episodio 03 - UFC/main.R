##-----------------------------------------------------------------------------
# main.R
#-----------------------------------------------------------------------------
#   Core script for the project. It installs and loads necessary packages,
#   sources utility functions, and executes the main data processing workflow.
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Load required libraries and source utility functions
#-----------------------------------------------------------------------------

source(file.path("src", "install_load_packages.R"))
source(file.path("src", "toolkit.R"))
logs <- log_message("Loaded required packages and sourced utility functions.", c(), type="info")



#-----------------------------------------------------------------------------
#  Set up paths and parameters
#-----------------------------------------------------------------------------
logs <- log_message("Set up paths and parameters.", logs, type="info")



#-----------------------------------------------------------------------------
# Main Data Processing Workflow
#-----------------------------------------------------------------------------

tuesdata <- tidytuesdayR::tt_load("2026-07-07")
ufc_athletes <- tuesdata$ufc_athletes
ufc_fights <- tuesdata$ufc_fights
ufc_rankings_dataset <- tuesdata$ufc_rankings_dataset
ufcstats_data <- tuesdata$ufcstats_data
ultimate_ufc_dataset <- tuesdata$ultimate_ufc_dataset
logs <- log_message("Loaded TidyTuesday UFC datasets.", logs, type="info")

# evaluar_calidad_datos(tuesdata)  # auditoría interactiva de calidad
crear_visualizaciones(tuesdata)

logs <- log_message("Data processing workflow completed successfully.", logs, type="info")



#-----------------------------------------------------------------------------
# End of main.R
#-----------------------------------------------------------------------------
