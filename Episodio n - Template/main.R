#-----------------------------------------------------------------------------
# main.R
#-----------------------------------------------------------------------------
#   Core script for the project. It loads packages via renv, sources utility
#   functions, and executes the main data processing workflow.
#
#   La historia del episodio: por definir. Carreras universitarias, salario
#   de entrada y exposición a la IA (TidyTuesday 2026-10-20). Preguntas
#   sugeridas: carreras a la vez seguras y bien pagadas, exposición de
#   lenguaje frente a imagen, y si los campos amplios se agrupan.
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
tuesdata <- tidytuesdayR::tt_load("2026-10-20")
logs <- log_message("Loaded TidyTuesday dataset.", logs, type="info")

# ai_salary_majors: una fila por carrera (CIP de 4 dígitos). Salario mediano
# al año y a los cuatro años, AIOE total / lenguaje / imagen, percentil 0–100,
# y conteos de ocupaciones, instituciones y egresados.
df_carreras <- tuesdata$ai_salary_majors

# major_occupations: el cruce carrera → ocupación (SOC) que está detrás del
# promedio de exposición de cada carrera.
df_ocupaciones <- tuesdata$major_occupations

logs <- log_message(
  paste0(
    "Carreras: ", nrow(df_carreras), " en ",
    dplyr::n_distinct(df_carreras$broad_field_short), " campos. ",
    "Ocupaciones enlazadas: ", nrow(df_ocupaciones), "."
  ),
  logs, type = "info"
)



#-----------------------------------------------------------------------------
# Main Data Processing Workflow
#-----------------------------------------------------------------------------

# El AIOE está estandarizado (media 0, desviación 1). Un valor alto mide
# exposición, no automatización: la IA también puede asistir el trabajo.
# ai_exposure_percentile es el rango 0–100 entre estas 285 carreras.

# Carreras a la vez poco expuestas y bien pagadas, y las expuestas y mal pagadas.

# Exposición de tareas de lenguaje frente a tareas de imagen.

# Si Ingeniería, Salud, Negocios y Humanidades se agrupan.



#-----------------------------------------------------------------------------
# Visualizaciones
#-----------------------------------------------------------------------------

# Láminas por definir. Cada una vive como función en src/functions/visualizaciones.R
# y se exporta desde aquí hacia output/.

if (!exists("exportar_png")) exportar_png <- TRUE

if (exportar_png) {
  # exportar_laminas(p_lamina, "slug", output_path)
  logs <- log_message("Sin láminas que exportar todavía.", logs, type = "info")
}



#-----------------------------------------------------------------------------
# End of main.R
#-----------------------------------------------------------------------------
