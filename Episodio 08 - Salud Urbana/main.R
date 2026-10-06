#-----------------------------------------------------------------------------
# main.R
#-----------------------------------------------------------------------------
#   Core script for the project. It loads packages via renv, sources utility
#   functions, and executes the main data processing workflow.
#
#   La historia del episodio: qué parte de la población urbana vive a menos de
#   1 km de un hospital o una farmacia, abierto por grupo de ingreso y
#   contrastando el urbanismo europeo con el de Norteamérica y Oceanía anglo.
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

# Una ciudad entra al análisis si trae al menos cuatro de estas seis medidas.
COLUMNAS_CLAVE <- c(
  "area_km2", "poblacion", "hospitales", "farmacias",
  "pob_cerca_hospital", "pob_cerca_farmacia"
)
MIN_COLUMNAS_CLAVE <- 4



#-----------------------------------------------------------------------------
# Load data
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



#-----------------------------------------------------------------------------
# Main Data Processing Workflow
#-----------------------------------------------------------------------------

# Más de la mitad de las ciudades no trae dato de farmacias, así que conviene
# ver el tamaño del hueco antes de filtrar.
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

df_ciudad <- df_salud %>%
  mutate(completitud = rowSums(!is.na(pick(all_of(COLUMNAS_CLAVE))))) %>%
  filter(completitud >= MIN_COLUMNAS_CLAVE)

logs <- log_message(
  paste0(
    "Ciudades con al menos ", MIN_COLUMNAS_CLAVE, " de ",
    length(COLUMNAS_CLAVE), " medidas clave: ", nrow(df_ciudad),
    " de ", nrow(df_salud), "."
  ),
  logs, type = "info"
)

# La unidad de análisis es la ciudad, no el país: Norteamérica son solo dos
# países y un boxplot por país se quedaría sin casos. share_cerca_* ya viene en
# porcentaje, así que se usa tal cual y no se recalcula.
df_cobertura <- df_ciudad %>%
  filter(!is.na(grupo_ingreso)) %>%
  mutate(nivel_ingreso = factor_ordenado(grupo_ingreso, NIVELES_INGRESO)) %>%
  select(ciudad, pais, region_onu, nivel_ingreso,
         share_cerca_hospital, share_cerca_farmacia) %>%
  alargar_cobertura()

# Para el contraste de urbanismo solo entran ciudades de ingreso alto, para que
# la comparación entre bloques no mezcle niveles de desarrollo distintos.
df_bloques_base <- df_ciudad %>%
  filter(
    region_onu %in% names(NIVELES_BLOQUE),
    grupo_ingreso == "High income"
  ) %>%
  mutate(bloque = factor_ordenado(region_onu, NIVELES_BLOQUE)) %>%
  select(ciudad, pais, bloque, poblacion, area_km2,
         share_cerca_hospital, share_cerca_farmacia)

df_bloques <- alargar_cobertura(df_bloques_base)

# La misma lámina con una tercera caja: la densidad de población, que es la
# explicación más probable de la brecha entre bloques.
df_bloques_densidad <- alargar_cobertura(df_bloques_base, con_densidad = TRUE)

logs <- log_message("Data processing workflow completed successfully.", logs, type="info")



#-----------------------------------------------------------------------------
# Visualizaciones
#-----------------------------------------------------------------------------

# Los grupos chicos no se ven en la lámina pero cambian cómo se lee: las
# ciudades de ingreso bajo con dato de farmacias son unas decenas.
logs <- log_message(
  paste0(
    "Ciudades por grupo y servicio: ",
    df_cobertura %>%
      count(nivel_ingreso, servicio) %>%
      mutate(etiqueta = paste0(nivel_ingreso, "/", servicio, " ", n)) %>%
      pull(etiqueta) %>%
      paste(collapse = ", ")
  ),
  logs, type = "info"
)

# La mediana de cobertura de hospitales baja conforme sube el ingreso: 37 % en
# ingreso medio-bajo contra 23 % en ingreso alto. No es una relación causal, y
# pesa que las ciudades de ingreso bajo son más densas.
p_ingreso <- grafica_cobertura(
  df_cobertura,
  grupo = "nivel_ingreso",
  titulo = "Las ciudades más ricas son las que viven más lejos de un hospital",
  etiqueta_y = NULL
)

# Entre ciudades de ingreso alto, la mediana europea (29 %) más que duplica la
# norteamericana (12 %); en farmacias la brecha casi desaparece.
p_bloques <- grafica_cobertura(
  df_bloques,
  grupo = "bloque",
  titulo = "Europa vive al doble de cerca de un hospital que Norteamérica",
  detalle = "Solo ciudades de ingreso alto",
  etiqueta_y = NULL
)

# Copia de la lámina anterior con la densidad como tercera caja. La caja gris se
# lee en el eje de arriba, no en el de porcentaje.
p_bloques_densidad <- grafica_cobertura(
  df_bloques_densidad,
  grupo = "bloque",
  titulo = "La ciudad europea es más densa, y el hospital queda más cerca",
  detalle = paste(
    "Solo ciudades de ingreso alto",
    "La densidad se lee en el eje de arriba",
    sep = sep_inline
  ),
  etiqueta_y = NULL,
  paleta = paleta_con_densidad,
  eje_secundario = eje_densidad()
)

laminas <- list(
  list(plot = p_ingreso, slug = "cobertura_ingreso", espacios = NULL),
  list(plot = p_bloques, slug = "cobertura_bloques", espacios = NULL),
  list(plot = p_bloques_densidad, slug = "cobertura_bloques_densidad", espacios = NULL)
)

if (!exists("exportar_png")) exportar_png <- TRUE

if (exportar_png) {
  for (lam in laminas) {
    if (interactive()) print(lam$plot)
    exportar_laminas(lam$plot, lam$slug, output_path, espacios = lam$espacios)
    logs <- log_message(paste0("Exportadas láminas: ", lam$slug), logs, type = "info")
  }

  logs <- log_message("Visualizations exported successfully.", logs, type="info")
}



#-----------------------------------------------------------------------------
# End of main.R
#-----------------------------------------------------------------------------
