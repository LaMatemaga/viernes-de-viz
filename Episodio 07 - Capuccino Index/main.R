##-----------------------------------------------------------------------------
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
tuesdata <- tidytuesdayR::tt_load("2026-09-08")
logs <- log_message("Loaded TidyTuesday dataset.", logs, type="info")

# El índice oficial está en minutos: sum(precio) / sum(salario) * 60.
# En cafe hay espacios de no separación (U+00A0) en New Zealand y South Africa.
df_cafe <- tuesdata$cafe %>%
  mutate(
    country = gsub("\u00a0", " ", country),
    index_min = price_gbp / hourly_wage_gbp * 60
  )

df_capuccino <- tuesdata$cappuccino_index %>%
  mutate(country = gsub("\u00a0", " ", country))

n_paises <- n_distinct(df_capuccino$country)
df_capuccino <- df_capuccino %>% filter(n >= 10)
df_cafe <- df_cafe %>% filter(country %in% df_capuccino$country)
logs <- log_message(
  paste0(
    "Se excluyeron ", n_paises - n_distinct(df_capuccino$country),
    " países con muestra menor a diez; quedan ",
    n_distinct(df_capuccino$country), "."
  ),
  logs, type = "info"
)

# Para las distribuciones y la variabilidad se excluyen, dentro de cada país,
# los valores fuera de [Q1 - 1.5 * IQR, Q3 + 1.5 * IQR].
df_cafe_sin_outliers <- df_cafe %>%
  group_by(country) %>%
  mutate(
    q1_index = quantile(index_min, 0.25, na.rm = TRUE),
    q3_index = quantile(index_min, 0.75, na.rm = TRUE),
    iqr_index = q3_index - q1_index,
    outlier_iqr = !is.na(index_min) & (
      index_min < q1_index - 1.5 * iqr_index |
        index_min > q3_index + 1.5 * iqr_index
    )
  ) %>%
  ungroup()

n_outliers_iqr <- sum(df_cafe_sin_outliers$outlier_iqr)
df_cafe_sin_outliers <- df_cafe_sin_outliers %>%
  filter(!outlier_iqr) %>%
  select(-q1_index, -q3_index, -iqr_index, -outlier_iqr)

logs <- log_message(
  paste0(
    "Se excluyeron ", n_outliers_iqr,
    " valores atípicos según la regla de 1.5 × IQR por país ",
    "para distribuciones y variabilidad."
  ),
  logs, type = "info"
)

variacion <- df_cafe_sin_outliers %>%
  group_by(country) %>%
  summarise(std = sd(index_min, na.rm = TRUE), .groups = "drop")

df_capuccino <- df_capuccino %>%
  left_join(variacion, by = "country")

r_pearson <- cor(df_capuccino$index, df_capuccino$std, use = "complete.obs")

violin_max <- df_capuccino %>% slice_max(order_by = index, n = 5)
violin_min <- df_capuccino %>% slice_min(order_by = index, n = 5)
violin_df  <- bind_rows(
  violin_min %>% mutate(grupo = "Más bajo"),
  violin_max %>% mutate(grupo = "Más alto")
)

box_capuccino <- violin_df %>%
  left_join(df_cafe_sin_outliers, by = "country") %>%
  mutate(
    country = factor(country, levels = violin_df$country[order(violin_df$index)]),
    grupo = factor(grupo, levels = c("Más bajo", "Más alto"))
  )

world_map <- map_data("world")
df_capuccino <- df_capuccino %>%
  mutate(region = recodificar_region(country))

map_cappuccino <- world_map %>%
  left_join(df_capuccino, by = "region")

paises_sin_mapa <- setdiff(df_capuccino$region, unique(world_map$region))
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

pais_max <- df_capuccino %>% slice_max(order_by = index, n = 1, with_ties = FALSE)
pais_min <- df_capuccino %>% slice_min(order_by = index, n = 1, with_ties = FALSE)
pais_std_max <- df_capuccino %>% slice_max(order_by = std, n = 1, with_ties = FALSE)
pais_std_min <- df_capuccino %>% slice_min(order_by = std, n = 1, with_ties = FALSE)

subtitulo_index <- paste0(
  paste(
    "Índice Cappuccino 2026",
    marca_inline(
      paste0(pais_max$country, "&nbsp;", round(pais_max$index), " min"),
      unname(sterling_cat["Teal"]), unname(sterling_legend["Teal"])
    ),
    marca_inline(
      paste0(pais_min$country, "&nbsp;", round(pais_min$index), " min"),
      unname(sterling_cat["Orchid"]), unname(sterling_legend["Orchid"])
    ),
    paste0(pais_max$country, " requiere ", round(pais_max$index / pais_min$index), " veces más"),
    sep = sep_inline
  ),
  "<br>Países con n ≥ 10"
)
subtitulo_std <- paste0(
  paste(
    "Desviación estándar entre cafeterías",
    marca_inline(
      paste0(pais_std_max$country, "&nbsp;", round(pais_std_max$std), " min"),
      unname(sterling_cat["Blue"]), unname(sterling_legend["Blue"])
    ),
    marca_inline(
      paste0(pais_std_min$country, "&nbsp;", formatC(pais_std_min$std, digits = 1, format = "f"), " min"),
      unname(sterling_cat["Coral"]), unname(sterling_legend["Coral"])
    ),
    sep = sep_inline
  ),
  "<br>",
  paste(
    "Países con n ≥ 10",
    nota_outliers,
    sep = sep_inline
  )
)

p_salario <- grafica_salario_precio(df_cafe)
p_extremos <- grafica_extremos(box_capuccino)
p_mapa_index <- grafica_mapa(
  map_cappuccino,
  fill = "index",
  titulo = "Minutos de trabajo para pagar un capuchino",
  subtitulo = subtitulo_index,
  nombre_leyenda = "Minutos"
)
p_mapa_std <- grafica_mapa(
  map_cappuccino,
  fill = "std",
  titulo = "Variabilidad de los minutos de trabajo para pagar un capuchino",
  subtitulo = subtitulo_std,
  nombre_leyenda = "Desv. est.",
  colores = sterling_ramp_amber
)
p_index_std <- grafica_index_std(df_capuccino, r_pearson)

p_waffle <- grafica_waffle(
  pais_max$index, pais_min$index, pais_max$country, pais_min$country
)
p_waffle_contexto <- grafica_waffle(
  pais_max$index, pais_min$index, pais_max$country, pais_min$country,
  contexto = TRUE
)

df_ridgeline <- df_cafe_sin_outliers %>%
  filter(country %in% c(pais_std_max$country, pais_std_min$country))
p_ridgeline <- grafica_ridgeline_std(
  df_ridgeline, pais_std_max$country, pais_std_min$country
)
p_ridgeline_contexto <- grafica_ridgeline_std(
  df_ridgeline, pais_std_max$country, pais_std_min$country,
  contexto = TRUE
)

laminas <- list(
  list(plot = p_salario,    slug = "salario_precio", espacios = NULL),
  list(plot = p_extremos,   slug = "extremos",       espacios = NULL),
  # El waffle tiene proporción fija y se limita por la altura del panel: el
  # relleno solo cubre el sobrante para que no pierda ancho.
  list(
    plot = p_waffle, slug = "waffle",
    espacios = c(`1x1` = 0.15, `4x5` = 0.75, `9x16` = 1.55)
  ),
  list(plot = p_ridgeline,  slug = "ridgeline_std",  espacios = NULL),
  list(plot = p_index_std,  slug = "index_dispersion", espacios = NULL)
)

laminas_mapa <- list(
  list(
    mapa = p_mapa_index, contexto = p_waffle_contexto, slug = "mapa_index",
    alturas = c(3.2, 0.9),
    espacios = c(`1x1` = 1.2, `4x5` = 2.3, `9x16` = 5.2)
  ),
  list(
    mapa = p_mapa_std, contexto = p_ridgeline_contexto, slug = "mapa_std",
    alturas = c(3.2, 1.2),
    espacios = c(`1x1` = 0.7, `4x5` = 1.9, `9x16` = 4.8)
  )
)

# linkedin.R reutiliza este script para construir las mismas láminas y sacarlas
# en SVG, así que puede pedir que no se rehagan los PNG.
if (!exists("exportar_png")) exportar_png <- TRUE

if (exportar_png) {
  for (lam in laminas_mapa) {
    exportar_laminas_mapa_contexto(
      lam$mapa, lam$contexto, lam$slug, output_path,
      alturas = lam$alturas, espacios = lam$espacios
    )
  }
  logs <- log_message(
    "Exportados los mapas con contexto en formatos cuadrados y verticales.",
    logs, type = "info"
  )

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
