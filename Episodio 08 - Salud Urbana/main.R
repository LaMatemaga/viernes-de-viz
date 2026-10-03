#-----------------------------------------------------------------------------
# main.R
#-----------------------------------------------------------------------------
#   Core script for the project. It loads packages via renv, sources utility
#   functions, and executes the main data processing workflow.
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
# Main Data Processing Workflow
#-----------------------------------------------------------------------------

logs <- log_message("Loading TidyTuesday dataset...", logs, type="info")
tuesdata <- tidytuesdayR::tt_load("2026-09-29")
logs <- log_message("Loaded TidyTuesday dataset.", logs, type="info")

# health.csv: un renglón por centro urbano del GHS-UCDB, con el conteo de
# hospitales y farmacias, su densidad por km2, el valor per cápita y la
# población que vive a menos de 1 km de cada tipo de servicio.
df_salud <- tuesdata$health %>%
  rename(
    id                    = ID_UC_G0,
    ciudad                = GC_UCN_MAI_2025,
    pais                  = GC_CNT_GAD_2025,
    area_km2              = GC_UCA_KM2_2025,
    poblacion             = GC_POP_TOT_2025,
    grupo_ingreso         = GC_DEV_WIG_2025,
    region_onu            = GC_DEV_USR_2025,
    hospitales            = HL_FCL_HOS_2024,
    farmacias             = HL_FCL_PHA_2024,
    hospitales_km2        = HL_FDE_HOS_2024,
    farmacias_km2         = HL_FDE_PHA_2024,
    hospitales_per_capita = HL_FPC_HOS_2025,
    farmacias_per_capita  = HL_FPC_PHA_2025,
    pob_cerca_hospital    = HL_POP_HOS_2025,
    pob_cerca_farmacia    = HL_POP_PHA_2025,
    share_cerca_hospital  = HL_SHP_HOS_2025,
    share_cerca_farmacia  = HL_SHP_PHA_2025
  )

logs <- log_message(
  paste0(
    "Centros urbanos: ", nrow(df_salud), " en ",
    n_distinct(df_salud$pais), " países."
  ),
  logs, type = "info"
)

# Conteos faltantes por columna, para decidir qué filtros aplica cada lámina.
faltantes <- df_salud %>%
  summarise(across(everything(), \(x) sum(is.na(x)))) %>%
  pivot_longer(everything(), names_to = "columna", values_to = "n_faltantes") %>%
  filter(n_faltantes > 0) %>%
  arrange(desc(n_faltantes))

if (nrow(faltantes) > 0) {
  logs <- log_message(
    paste0(
      "Columnas con faltantes: ",
      paste0(faltantes$columna, " (", faltantes$n_faltantes, ")", collapse = ", ")
    ),
    logs, type = "info"
  )
}

# Las láminas por país agregan los conteos; per cápita se recalcula sobre el
# total agregado y no como promedio de los valores por ciudad.
df_pais <- df_salud %>%
  group_by(pais) %>%
  summarise(
    n_centros             = n(),
    poblacion             = sum(poblacion, na.rm = TRUE),
    area_km2              = sum(area_km2, na.rm = TRUE),
    hospitales            = sum(hospitales, na.rm = TRUE),
    farmacias             = sum(farmacias, na.rm = TRUE),
    grupo_ingreso         = first(grupo_ingreso),
    region_onu            = first(region_onu),
    .groups = "drop"
  ) %>%
  mutate(
    hospitales_100k = hospitales / poblacion * 1e5,
    farmacias_100k  = farmacias / poblacion * 1e5
  )

# Para el mapa se agrupa por polígono de maps, no por país de GADM: Cyprus y
# Northern Cyprus comparten polígono y si no se agregan el join los duplica.
df_region <- df_pais %>%
  mutate(region = recodificar_region(pais)) %>%
  group_by(region) %>%
  summarise(
    poblacion  = sum(poblacion),
    area_km2   = sum(area_km2),
    hospitales = sum(hospitales),
    farmacias  = sum(farmacias),
    .groups = "drop"
  ) %>%
  mutate(
    hospitales_100k = hospitales / poblacion * 1e5,
    farmacias_100k  = farmacias / poblacion * 1e5
  )

world_map <- map_data("world")
map_salud <- world_map %>%
  left_join(df_region, by = "region")

paises_sin_mapa <- setdiff(df_region$region, unique(world_map$region))
if (length(paises_sin_mapa) > 0) {
  logs <- log_message(
    paste("Países sin polígono en maps:", paste(paises_sin_mapa, collapse = ", ")),
    logs, type = "warning"
  )
}

logs <- log_message("Data processing workflow completed successfully.", logs, type="info")



#-----------------------------------------------------------------------------
# Visualizaciones
#-----------------------------------------------------------------------------



#-----------------------------------------------------------------------------
# End of main.R
#-----------------------------------------------------------------------------
