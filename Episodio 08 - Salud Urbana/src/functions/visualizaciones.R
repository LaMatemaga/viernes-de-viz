#-----------------------------------------------------------------------------
# visualizaciones.R
#-----------------------------------------------------------------------------
#   Sterling styling, boxplots de cobertura, and PNG/SVG export.
#-----------------------------------------------------------------------------

# --- Tipografías -------------------------------------------------------------
# Los alias los registra registrar_fuentes_sterling() en fuentes.R.
# Reparto tipográfico de Sterling:
#   --sterling-font-display -> Fraunces        (título)
#   --font-sans (= Inter)   -> Inter           (subtítulo)
#   --sterling-font-mono    -> JetBrains Mono  (ejes, valores, pie)
FUENTE_TITULO <- "Fraunces (proyecto)"
FUENTE_SUB    <- "Inter (proyecto)"
FUENTE_TEXTO  <- "JetBrains Mono (proyecto)"

# --- Paleta Sterling (canónica, LaMatemaga/sterling) -------------------------
# Voces categóricas light: --sterling-cat-1..8
sterling_cat <- c(
  Violet = "#9A79E7", Teal  = "#25A08D", Orchid = "#D45AC7", Amber = "#E4A43A",
  Blue   = "#5A83D7", Coral = "#E87864", Moss   = "#96AB51", Payne = "#536B78"
)
# --sterling-legend-1..8: la misma voz, oscurecida para texto sobre papel
sterling_legend <- c(
  Violet = "#6945B8", Teal = "#147568", Orchid = "#A43A99", Amber = "#855700",
  Blue = "#365DA5", Coral = "#A94230", Moss = "#5D6F19", Payne = "#445762"
)

paper     <- "#F6F3FB"  # --sterling-paper
panel     <- "#FBF9FE"  # --sterling-surface
tinta     <- "#241A3D"  # --sterling-text
tinta_sec <- "#5C5178"  # --sterling-muted
retic     <- "#D9D1E6"  # --sterling-grid
borde     <- "#CFC5DE"  # --sterling-edge

# Pesos ópticos de SterlingBoxPlot (visualStyle.ts)
stroke_mark     <- 0.7   # stroke.mark = 2 px
stroke_emphasis <- 0.9   # stroke.emphasis = 2.5 px
opacidad_caja   <- 0.28  # opacity.interval

# Las dos primeras voces: teal para hospitales, orquídea para farmacias. La
# densidad no es un servicio, así que usa Payne, la voz neutra de la paleta.
paleta_servicio <- c(
  "Hospitales" = unname(sterling_cat["Teal"]),
  "Farmacias"  = unname(sterling_cat["Orchid"])
)
paleta_con_densidad <- c(
  paleta_servicio,
  "Densidad" = unname(sterling_cat["Payne"])
)
tinta_serie <- c(
  "Hospitales" = unname(sterling_legend["Teal"]),
  "Farmacias"  = unname(sterling_legend["Orchid"]),
  "Densidad"   = unname(sterling_legend["Payne"])
)
ORDEN_SERIES <- names(paleta_con_densidad)

# --- Pie editorial -----------------------------------------------------------
source_line <- "Fuente: GHS-UCDB R2024A, Comisión Europea / TidyTuesday (2026-09-29)"
credit_line <- "Hecho durante #ViernesDeVisualizaciones por La Matemaga."
nota_outliers <- "Bigotes a 1.5 × IQR; atípicos no dibujados"
# gridtext colapsa &emsp;, así que el separador lleva un punto medio visible.
sep_inline <- " &nbsp;·&nbsp; "

# --- Etiquetas del dataset ---------------------------------------------------
# GC_DEV_WIG_2025 usa estas cuatro clases del Banco Mundial, en este orden.
NIVELES_INGRESO <- c(
  "High income"  = "Ingreso alto",
  "Upper Middle" = "Ingreso medio-alto",
  "Lower Middle" = "Ingreso medio-bajo",
  "Low income"   = "Ingreso bajo"
)

# Bloques de GC_DEV_USR_2025 que se comparan entre sí. Ojo: en la clasificación
# de la ONU, "Oceania" son las islas del Pacífico y excluye Australia y Nueva
# Zelanda, que forman su propia región.
NIVELES_BLOQUE <- c(
  "Europe"                    = "Europa",
  "Northern America"          = "Norteamérica",
  "Australia and New Zealand" = "Australia y N. Zelanda"
)

# El eje discreto dibuja el primer nivel abajo, así que se invierten para que
# la categoría de mayor ingreso quede arriba.
factor_ordenado <- function(x, niveles) {
  factor(unname(niveles[x]), levels = rev(unname(niveles)))
}

# --- Formato de números ------------------------------------------------------
# HL_SHP_* ya viene en porcentaje (0–100), no como proporción.
marcas_pct <- function(x) {
  ifelse(is.na(x), "", paste0(formatC(x, format = "f", digits = 0), " %"))
}

marcas_numero <- function(x) {
  ifelse(is.na(x), "", formatC(x, format = "f", digits = 0, big.mark = " "))
}

marca_inline <- function(etiqueta, color_marca, color_texto) {
  paste0(
    "<span style='color:", color_marca, "'>■</span> ",
    "<span style='color:", color_texto, "'>", etiqueta, "</span>"
  )
}

# --- Temas -------------------------------------------------------------------
tema_titulos <- function() {
  ggplot2::theme(
    plot.background  = ggplot2::element_rect(fill = paper, color = NA),
    panel.background = ggplot2::element_rect(fill = panel, color = NA),
    plot.title = ggplot2::element_text(
      family = FUENTE_TITULO, size = 22, face = "bold", color = tinta,
      margin = ggplot2::margin(t = 8, b = 10)
    ),
    plot.subtitle = ggplot2::element_text(
      family = FUENTE_SUB, size = 11, color = tinta_sec,
      hjust = 0, margin = ggplot2::margin(t = 4, b = 26)
    ),
    plot.caption = ggplot2::element_text(
      family = FUENTE_TEXTO, size = 8, color = tinta_sec, hjust = 0,
      margin = ggplot2::margin(t = 34, b = 4)
    ),
    plot.title.position   = "plot",
    plot.caption.position = "plot",
    plot.margin = ggplot2::margin(34, 32, 22, 32)
  )
}

# El subtítulo lleva la leyenda inline, así que se renderiza como markdown.
tema_subtitulo_inline <- function() {
  ggplot2::theme(
    plot.subtitle = ggtext::element_markdown(
      family = FUENTE_SUB, size = 11, color = tinta_sec,
      hjust = 0, lineheight = 1.35,
      margin = ggplot2::margin(t = 4, b = 26)
    )
  )
}

tema_sterling <- function(grilla = "y") {
  t <- ggplot2::theme_minimal(base_family = FUENTE_TEXTO) +
    tema_titulos() +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      axis.title = ggplot2::element_text(
        family = FUENTE_TEXTO, size = 10, color = tinta,
        margin = ggplot2::margin(t = 12, r = 12)
      ),
      axis.text  = ggplot2::element_text(family = FUENTE_TEXTO, size = 9, color = tinta_sec),
      axis.ticks = ggplot2::element_line(color = borde)
    )
  if (identical(grilla, "x")) {
    t <- t + ggplot2::theme(
      panel.grid.major.x = ggplot2::element_line(color = retic, linewidth = 0.3),
      panel.grid.major.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank()
    )
  } else {
    t <- t + ggplot2::theme(
      panel.grid.major = ggplot2::element_line(color = retic, linewidth = 0.3)
    )
  }
  t
}

# --- Boxplots de cobertura ---------------------------------------------------
# Las dos láminas comparan la misma medida (share de población a menos de 1 km)
# cambiando solo la variable del eje vertical, así que comparten constructora.
# datos debe venir de alargar_cobertura(): un renglón por ciudad y servicio.
# La leyenda se arma desde la paleta, así que aparece la serie de densidad solo
# en la lámina que la lleva.
subtitulo_cobertura <- function(detalle = NULL, paleta = paleta_servicio) {
  segunda_linea <- if (is.null(detalle)) {
    nota_outliers
  } else {
    paste(detalle, nota_outliers, sep = sep_inline)
  }

  marcas <- vapply(
    names(paleta),
    function(serie) marca_inline(serie, paleta[[serie]], tinta_serie[[serie]]),
    character(1)
  )

  paste0(
    paste(marcas, collapse = sep_inline),
    "<br>",
    segunda_linea
  )
}

# --- Eje secundario de densidad ----------------------------------------------
# ggplot2 solo admite ejes secundarios derivados del primario, así que la
# densidad se reescala al dominio 0–100 del porcentaje y el eje de arriba
# deshace la transformación. El techo es 6 000 hab/km2 para que los cortes
# (0, 1 500, 3 000, 4 500, 6 000) caigan justo sobre los del eje primario
# (0, 25, 50, 75, 100 %) y las dos retículas coincidan.
DENSIDAD_MAX <- 6000
FACTOR_DENSIDAD <- DENSIDAD_MAX / 100

eje_densidad <- function() {
  ggplot2::sec_axis(
    ~ . * FACTOR_DENSIDAD,
    name = "Densidad de población (hab/km²)",
    breaks = seq(0, DENSIDAD_MAX, by = DENSIDAD_MAX / 4),
    labels = marcas_numero
  )
}

alargar_cobertura <- function(datos, con_densidad = FALSE) {
  columnas <- c("share_cerca_hospital", "share_cerca_farmacia")

  if (con_densidad) {
    datos <- dplyr::mutate(
      datos,
      densidad = .data$poblacion / .data$area_km2 / FACTOR_DENSIDAD
    )
    columnas <- c(columnas, "densidad")
  }

  datos %>%
    tidyr::pivot_longer(
      dplyr::all_of(columnas),
      names_to = "servicio", values_to = "cobertura"
    ) %>%
    dplyr::filter(!is.na(.data$cobertura)) %>%
    dplyr::mutate(
      servicio = dplyr::recode(
        .data$servicio,
        "share_cerca_hospital" = "Hospitales",
        "share_cerca_farmacia" = "Farmacias",
        "densidad" = "Densidad"
      ),
      servicio = factor(
        .data$servicio,
        levels = ORDEN_SERIES[ORDEN_SERIES %in% .data$servicio]
      )
    )
}

DODGE_COBERTURA <- 0.72

# Cada caja tiene su propio n, porque la cobertura de datos de farmacias es muy
# distinta a la de hospitales. La etiqueta va en un canal a la derecha del
# panel: varios bigotes llegan a 100 % y ahí chocarían con los números.
X_ETIQUETA_N <- 104

grafica_cobertura <- function(
    datos, grupo, titulo, detalle = NULL, etiqueta_y = NULL,
    paleta = paleta_servicio, eje_secundario = ggplot2::waiver()
) {
  etiquetas_n <- datos %>%
    dplyr::count(.data[[grupo]], .data$servicio, name = "n") %>%
    dplyr::mutate(etiqueta = paste0("(N = ", marcas_numero(.data$n), ")"))

  ggplot2::ggplot(
    datos,
    ggplot2::aes(
      x = .data$cobertura, y = .data[[grupo]],
      fill = .data$servicio, color = .data$servicio
    )
  ) +
    ggplot2::geom_boxplot(
      width = 0.62,
      coef = 1.5,
      staplewidth = 0.45,
      outliers = FALSE,
      linewidth = stroke_mark,
      median.linewidth = stroke_emphasis,
      position = ggplot2::position_dodge(width = DODGE_COBERTURA)
    ) +
    ggplot2::geom_text(
      data = etiquetas_n,
      ggplot2::aes(
        x = X_ETIQUETA_N, y = .data[[grupo]], label = .data$etiqueta,
        color = .data$servicio, group = .data$servicio
      ),
      inherit.aes = FALSE,
      position = ggplot2::position_dodge(width = DODGE_COBERTURA),
      hjust = 0, vjust = 0.5, family = FUENTE_TEXTO, size = 3
    ) +
    ggplot2::scale_x_continuous(
      labels = marcas_pct, breaks = seq(0, 100, by = 25),
      expand = ggplot2::expansion(mult = c(0.02, 0.02)),
      sec.axis = eje_secundario
    ) +
    ggplot2::scale_fill_manual(
      values = scales::alpha(paleta, opacidad_caja), guide = "none"
    ) +
    ggplot2::scale_color_manual(values = paleta, guide = "none") +
    # clip = "off" deja que las etiquetas de n vivan fuera del panel; el margen
    # derecho del tema les abre el espacio.
    ggplot2::coord_cartesian(xlim = c(0, 100), clip = "off") +
    ggplot2::labs(
      title = titulo,
      subtitle = subtitulo_cobertura(detalle, paleta),
      x = "Población de la ciudad a menos de 1 km del servicio",
      y = etiqueta_y,
      caption = source_line
    ) +
    tema_sterling("x") +
    tema_subtitulo_inline() +
    ggplot2::theme(
      axis.text.y = ggplot2::element_text(
        family = FUENTE_TEXTO, size = 9, color = tinta, hjust = 1,
        margin = ggplot2::margin(r = 12)
      ),
      # El eje heredaría los márgenes del de abajo, que apuntan al lado opuesto.
      axis.title.x.top = ggplot2::element_text(
        family = FUENTE_TEXTO, size = 10, color = tinta,
        margin = ggplot2::margin(b = 10)
      ),
      axis.text.x.top = ggplot2::element_text(
        family = FUENTE_TEXTO, size = 9, color = tinta_sec,
        margin = ggplot2::margin(b = 6)
      ),
      plot.margin = ggplot2::margin(34, 104, 22, 32)
    )
}

# --- Composición de láminas --------------------------------------------------
# Relleno del color del papel para empujar el contenido hacia arriba cuando el
# panel tiene proporción fija y no puede estirarse en los formatos verticales.
panel_papel <- function() {
  ggplot2::ggplot() +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = paper, color = NA),
      panel.background = ggplot2::element_rect(fill = paper, color = NA)
    )
}

componer_con_espacio <- function(plot, espacio_inferior) {
  plot_limpio <- plot +
    ggplot2::labs(caption = NULL) +
    ggplot2::theme(
      plot.caption = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(34, 0, 2, 0)
    )

  patchwork::wrap_plots(
    list(plot_limpio, panel_papel()),
    ncol = 1,
    heights = c(1, espacio_inferior)
  ) +
    patchwork::plot_annotation(
      caption = source_line,
      theme = ggplot2::theme(
        plot.background = ggplot2::element_rect(fill = paper, color = NA),
        plot.caption = ggplot2::element_text(
          family = FUENTE_TEXTO, size = 8, color = tinta_sec,
          hjust = 0, margin = ggplot2::margin(t = 10, b = 4)
        ),
        plot.caption.position = "plot",
        plot.margin = ggplot2::margin(0, 32, 22, 32)
      )
    )
}

# --- Exportación -------------------------------------------------------------
PREFIJO <- "salud"

ruta_lamina <- function(output_path, slug, formato, extension) {
  file.path(
    output_path,
    paste0(PREFIJO, "_", slug, "_", formato, ".", extension)
  )
}

# El pie lleva la fuente a la izquierda y el crédito a la derecha, que ggplot
# no sabe hacer con un solo element_text.
crear_grob_editorial <- function(plot) {
  g <- if (inherits(plot, "patchwork")) {
    patchwork::patchworkGrob(plot)
  } else {
    ggplot2::ggplotGrob(plot)
  }

  idx <- which(g$layout$name == "caption")
  if (length(idx) == 1) {
    g$grobs[[idx]] <- grid::grobTree(
      grid::textGrob(
        source_line, x = grid::unit(0, "npc"), y = grid::unit(0.5, "npc"),
        just = c("left", "center"),
        gp = grid::gpar(fontfamily = FUENTE_TEXTO, fontsize = 8, col = tinta_sec)
      ),
      grid::textGrob(
        credit_line, x = grid::unit(1, "npc"), y = grid::unit(0.5, "npc"),
        just = c("right", "center"),
        gp = grid::gpar(fontfamily = FUENTE_TEXTO, fontsize = 8, col = tinta_sec)
      )
    )
  }
  g
}

guardar_png <- function(plot, nombre, ancho_px, alto_px, resolucion = 96) {
  ragg::agg_png(
    nombre, width = ancho_px, height = alto_px, units = "px",
    res = resolucion, background = paper
  )
  on.exit(grDevices::dev.off(), add = TRUE)
  grid::grid.newpage()
  grid::grid.draw(crear_grob_editorial(plot))
}

# espacios: relleno inferior por formato para las láminas de proporción fija,
# que si no quedarían centradas a media altura en los formatos verticales.
exportar_laminas <- function(plot, slug, output_path, espacios = NULL) {
  para_formato <- function(clave) {
    if (is.null(espacios) || is.na(espacios[clave])) plot
    else componer_con_espacio(plot, espacios[[clave]])
  }

  guardar_png(plot, ruta_lamina(output_path, slug, "master", "png"), 3600, 2400, resolucion = 300)
  guardar_png(para_formato("1x1"),  ruta_lamina(output_path, slug, "1x1", "png"),  1080, 1080)
  guardar_png(para_formato("4x5"),  ruta_lamina(output_path, slug, "4x5", "png"),  1080, 1350)
  guardar_png(para_formato("9x16"), ruta_lamina(output_path, slug, "9x16", "png"), 1080, 1920)
  guardar_png(plot, ruta_lamina(output_path, slug, "1.91x1", "png"), 1200, 628)
}

# --- Exportación vectorial para Illustrator ----------------------------------
# Illustrator resuelve las tipografías por su nombre instalado, no por el alias
# que registra fuentes.R, así que el SVG se reescribe con los nombres reales.
FUENTES_SVG <- c(
  "Fraunces (proyecto)"       = "Fraunces",
  "Inter (proyecto)"          = "Inter",
  "JetBrains Mono (proyecto)" = "JetBrains Mono"
)

renombrar_fuentes_svg <- function(ruta) {
  svg <- readLines(ruta, warn = FALSE, encoding = "UTF-8")
  for (alias in names(FUENTES_SVG)) {
    svg <- gsub(alias, FUENTES_SVG[[alias]], svg, fixed = TRUE)
  }
  writeLines(svg, ruta, useBytes = TRUE)
}

# fix_text_size = FALSE deja el texto con sus métricas reales: en Illustrator se
# puede reescribir sin que se estire para conservar el ancho original.
guardar_svg <- function(plot, nombre, ancho_px, alto_px, resolucion = 96) {
  local({
    svglite::svglite(
      nombre,
      width = ancho_px / resolucion, height = alto_px / resolucion,
      bg = paper,
      fix_text_size = FALSE
    )
    on.exit(grDevices::dev.off(), add = TRUE)
    grid::grid.newpage()
    grid::grid.draw(crear_grob_editorial(plot))
  })
  # El archivo se termina de escribir al cerrar el dispositivo, así que las
  # familias se reescriben después.
  renombrar_fuentes_svg(nombre)
  invisible(nombre)
}

# Solo cuadrado y apaisados: los verticales son para historias y se quedan en
# PNG. espacios sigue la convención de exportar_laminas().
exportar_vectorial <- function(plot, slug, output_path, espacios = NULL) {
  cuadrado <- if (is.null(espacios) || is.na(espacios["1x1"])) {
    plot
  } else {
    componer_con_espacio(plot, espacios[["1x1"]])
  }

  guardar_svg(plot, ruta_lamina(output_path, slug, "master", "svg"), 3600, 2400, resolucion = 300)
  guardar_svg(cuadrado, ruta_lamina(output_path, slug, "1x1", "svg"), 1080, 1080)
  guardar_svg(plot, ruta_lamina(output_path, slug, "1.91x1", "svg"), 1200, 628)
}

#-----------------------------------------------------------------------------
# End of visualizaciones.R
#-----------------------------------------------------------------------------
