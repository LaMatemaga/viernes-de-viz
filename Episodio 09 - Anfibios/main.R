#-----------------------------------------------------------------------------
# main.R
#-----------------------------------------------------------------------------
#   Core script for the project. It loads packages via renv, sources utility
#   functions, and executes the main data processing workflow.
#
#   La historia del episodio: por definir. Ranas y sapos (orden Anura) de
#   AmphibiaWeb. Preguntas sugeridas por TidyTuesday: familias con más especies,
#   países con más especies nativas, estatus IUCN por familia o región.
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
output_path <- "output/"
dir.create(output_path, showWarnings = FALSE)
fuentes <- registrar_fuentes_sterling()
logs <- log_message(paste0("Fuentes registradas desde ", fuentes$root), logs, type="info")



#-----------------------------------------------------------------------------
# Load data
#-----------------------------------------------------------------------------

logs <- log_message("Loading TidyTuesday dataset...", logs, type="info")
tuesdata <- tidytuesdayR::tt_load("2026-10-13")
logs <- log_message("Loaded TidyTuesday dataset.", logs, type="info")

# frogs_and_toads_amphibiaweb.csv: un renglón por especie de Anura. Los campos
# de texto libre (description, life_history, trends_and_threats...) son largos;
# isocc e intro_isocc traen códigos ISO de país separados por " | ".
df_anfibios <- tuesdata$frogs_and_toads_amphibiaweb

logs <- log_message(
  paste0(
    "Especies: ", nrow(df_anfibios), " en ",
    n_distinct(df_anfibios$family), " familias."
  ),
  logs, type = "info"
)



#-----------------------------------------------------------------------------
# Main Data Processing Workflow
#-----------------------------------------------------------------------------

# TODO: explorar faltantes, familias, países (isocc) y estatus (interntnl_status).



#-----------------------------------------------------------------------------
# Visualizaciones
#-----------------------------------------------------------------------------

# TODO: construir las láminas en src/functions/visualizaciones.R.



#-----------------------------------------------------------------------------
# End of main.R
#-----------------------------------------------------------------------------
