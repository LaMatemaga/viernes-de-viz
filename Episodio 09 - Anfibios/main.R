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

# Jetz y Pyron (2018) publicaron 10 000 árboles de anfibios fechados. Se usa
# su consenso, que conserva las longitudes de rama; el archivo se descarga una
# vez y queda como caché local. No se resuelven sinónimos automáticamente:
# entran únicamente los nombres binomiales que coinciden de forma exacta.
URL_FILOGENIA <- paste0(
  "https://zenodo.org/api/records/4963859/files/",
  "amph_shl_new_Consensus_7238.tre/content"
)
ruta_datos <- "data"
ruta_filogenia <- file.path(ruta_datos, "amph_shl_new_Consensus_7238.tre")

if (!file.exists(ruta_filogenia)) {
  dir.create(ruta_datos, showWarnings = FALSE)
  logs <- log_message("Descargando filogenia fechada de Jetz y Pyron...", logs, type = "info")
  utils::download.file(URL_FILOGENIA, ruta_filogenia, mode = "wb", quiet = TRUE)
}

arbol_completo <- ape::read.tree(ruta_filogenia)

df_filogenia <- df_anfibios %>%
  transmute(
    familia = .data$family,
    tip_label = paste(.data$genus, str_to_lower(.data$specificepithet), sep = "_")
  ) %>%
  filter(.data$tip_label %in% arbol_completo$tip.label) %>%
  distinct(.data$tip_label, .keep_all = TRUE)

arbol_filogenetico <- ape::keep.tip(arbol_completo, df_filogenia$tip_label)

logs <- log_message(
  paste0(
    "Filogenia fechada: ", nrow(df_filogenia), " de ", nrow(df_anfibios),
    " especies coinciden exactamente (",
    round(100 * nrow(df_filogenia) / nrow(df_anfibios), 1), " %)."
  ),
  logs, type = "info"
)

#-----------------------------------------------------------------------------
# Visualizaciones
#-----------------------------------------------------------------------------

# Lámina 0. Cada rango taxonómico es un anillo: todas las familias a la
# misma distancia del centro, luego todos los géneros, luego las especies.
df_taxonomia <- dplyr::transmute(
  df_filogenia,
  familia = .data$familia,
  genero = sub("_.*$", "", .data$tip_label),
  especie = .data$tip_label
)
arbol_taxonomico <- construir_arbol_taxonomico(
  df_taxonomia, c("familia", "genero", "especie")
)

p_sin_distancias <- grafica_filogenia_circular(
  arbol_taxonomico,
  df_filogenia,
  titulo = "Familia, género y especie quedan a la misma distancia",
  subtitulo = "La taxonomía ordena el árbol, todavía sin tiempo evolutivo"
)

# Lámina 1. El árbol de la vida aporta las distancias: el radio es tiempo.
p_filogenia <- grafica_filogenia_circular(
  arbol_filogenetico,
  df_filogenia,
  titulo = "Un solo árbol reúne a 5 366 anfibios",
  subtitulo = "El árbol de la vida (Jetz y Pyron, 2018) hace que cada rama mida tiempo evolutivo"
)

# Lámina 2. Hylidae, Strabomantidae, Bufonidae y Microhylidae suman 2 130
# especies, el 39.7 % de las que entran al árbol. Sin anillos de guía.
p_familias <- grafica_filogenia_circular(
  arbol_filogenetico,
  df_filogenia,
  titulo = "Hylidae, Strabomantidae, Bufonidae y Microhylidae\nreúnen dos de cada cinco especies",
  subtitulo = "Cada barra es una familia y cubre el arco de su clado",
  anillo_familias = TRUE
)

# Lámina 3. La mediana es 35 especies por familia. Las 11 familias con más
# de 150 especies suman 3 679, el 68.6 % del árbol.
p_familias_guias <- grafica_filogenia_circular(
  arbol_filogenetico,
  df_filogenia,
  titulo = "Hylidae llega a 633 especies y la mediana es de 35",
  subtitulo = "Las familias con más de 150 especies reúnen el 69 % del total",
  anillo_familias = TRUE,
  guias_barras = TRUE,
  pwidth_barras = 0.70
)

# Lámina 4. 19 familias superan las 100 especies y suman 4 634, el 86.4 %.
familias_numerosas <- df_filogenia %>%
  dplyr::count(.data$familia, name = "n_especies") %>%
  dplyr::filter(.data$n_especies > 100) %>%
  dplyr::pull(.data$familia)

df_numerosas <- dplyr::filter(df_filogenia, .data$familia %in% familias_numerosas)
arbol_numerosas <- ape::keep.tip(arbol_filogenetico, df_numerosas$tip_label)

p_familias_100 <- grafica_filogenia_circular(
  arbol_numerosas,
  df_numerosas,
  titulo = "Sólo 19 familias con más de 100 especies reúnen el 86 %",
  subtitulo = "El resto de las familias queda fuera de esta lámina",
  anillo_familias = TRUE,
  guias_barras = TRUE,
  pwidth_barras = 0.70,
  umbral_etiquetas = 100
)

if (!exists("exportar_png")) exportar_png <- TRUE

if (exportar_png) {
  if (interactive()) {
    print(p_sin_distancias)
    print(p_filogenia)
    print(p_familias)
    print(p_familias_guias)
    print(p_familias_100)
  }

  exportar_laminas(p_sin_distancias, "filogenia_sin_distancias", output_path)
  exportar_laminas(p_filogenia, "filogenia_especies", output_path)
  exportar_laminas(p_familias, "filogenia_familias", output_path)
  exportar_laminas(p_familias_guias, "filogenia_familias_guias", output_path)
  exportar_laminas(p_familias_100, "filogenia_familias_100", output_path)
  logs <- log_message("Exportadas las cinco láminas filogenéticas.", logs, type = "info")
}


#-----------------------------------------------------------------------------
# End of main.R
#-----------------------------------------------------------------------------
