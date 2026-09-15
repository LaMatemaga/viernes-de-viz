#-----------------------------------------------------------------------------
# visualizaciones.R
#-----------------------------------------------------------------------------
#   Sterling styling, Cappuccino Index charts, editorial grobs, and PNG export.
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

paper     <- "#F6F3FB"  # --sterling-paper
panel     <- "#FBF9FE"  # --sterling-surface
tinta     <- "#241A3D"  # --sterling-text
tinta_sec <- "#5C5178"  # --sterling-muted
retic     <- "#D9D1E6"  # --sterling-grid
borde     <- "#CFC5DE"  # --sterling-edge
superficie_na <- "#D0DCE2"  # --sterling-ramp-8-1, Payne tenue
MAP_XLIM  <- c(-165, 180)
MAP_RATIO <- 1.3

# --sterling-seq-1..10: magnitud ordenada (índice, desviación)
sterling_seq <- c(
  "#F1ECFA", "#D5C3F6", "#B69AF2", "#A889ED", "#9A79E7",
  "#8E68D8", "#7B59BC", "#684AA1", "#563C87", "#4D357A"
)
sterling_ramp_amber <- c(
  "#F8DAA3", "#F2C46D", "#EBB454", "#E4A43A",
  "#D39A32", "#B7822A", "#9B6B23"
)

# Pesos ópticos de SterlingBoxPlot (visualStyle.ts)
stroke_mark     <- 0.7   # stroke.mark = 2 px
stroke_emphasis <- 0.9   # stroke.emphasis = 2.5 px
opacidad_caja   <- 0.28  # opacity.interval

# Primeras dos voces: violeta = hallazgo (más minutos), teal = contraste.
paleta_grupo <- c(
  "Más bajo" = unname(sterling_cat["Teal"]),
  "Más alto" = unname(sterling_cat["Violet"])
)
# --sterling-legend-2 y --sterling-legend-1
sterling_legend <- c(
  Violet = "#6945B8", Teal = "#147568", Orchid = "#A43A99", Amber = "#855700",
  Blue = "#365DA5", Coral = "#A94230", Moss = "#5D6F19", Payne = "#445762",
  "Más bajo" = "#147568", "Más alto" = "#6945B8"
)

# --- Pie editorial -----------------------------------------------------------
source_line <- "Fuente: James Hoffmann / TidyTuesday (2026-09-08)"
credit_line <- "Hecho durante #ViernesDeVisualizaciones por La Matemaga."
nota_muestra <- "Países con n ≥ 10"
nota_outliers <- "Sin atípicos por país con regla 1.5 × IQR"
sep_inline <- "&emsp;&emsp;"

# --- Formato de números ------------------------------------------------------
marcas_min <- function(x) {
  ifelse(is.na(x), "", formatC(x, format = "f", digits = 0))
}

marca_inline <- function(etiqueta, color_marca, color_texto) {
  paste0(
    "<span style='color:", color_marca, "'>■</span> ",
    "<span style='color:", color_texto, "'>", etiqueta, "</span>"
  )
}

tema_subtitulo_inline <- function() {
  ggplot2::theme(
    plot.subtitle = ggtext::element_markdown(
      family = FUENTE_SUB, size = 11, color = tinta_sec,
      hjust = 0, lineheight = 1.35,
      margin = ggplot2::margin(t = 4, b = 26)
    )
  )
}

# --- Nombres de país → maps::map_data("world") --------------------------------
recodificar_region <- function(country) {
  dplyr::recode(
    country,
    "Czechia" = "Czech Republic",
    "UAE" = "United Arab Emirates",
    "Kazakstan" = "Kazakhstan",
    "North Macedonia" = "North Macedonia",
    .default = country
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

tema_mapa <- function() {
  ggplot2::theme_void(base_family = FUENTE_TEXTO) +
    tema_titulos() +
    ggplot2::theme(
      legend.position = "right",
      legend.justification = "center",
      legend.title = ggplot2::element_text(
        family = FUENTE_TEXTO, size = 10, color = tinta,
        margin = ggplot2::margin(b = 8)
      ),
      legend.text = ggplot2::element_text(
        family = FUENTE_TEXTO, size = 9, color = tinta_sec
      ),
      legend.margin = ggplot2::margin(l = 10)
    )
}

# --- Leyenda en subtítulo (extremos, densidad) --------------------------------
grob_leyenda <- function(
    tamano = 11,
    paleta = paleta_grupo,
    tinta_leyenda = sterling_legend
) {
  em    <- tamano
  lado  <- grid::unit(0.48 * em, "pt")
  radio <- grid::unit(0.06 * em, "pt")
  hueco <- grid::unit(0.30 * em, "pt")
  gp_txt <- function(col) {
    grid::gpar(fontfamily = FUENTE_SUB, fontsize = tamano, col = col)
  }

  piezas <- list()
  nms <- names(paleta)
  for (i in seq_along(nms)) {
    k <- nms[[i]]
    if (i > 1) {
      piezas <- c(piezas, list(list(tipo = "texto", txt = "  \u00b7  ", col = tinta_sec)))
    }
    piezas <- c(piezas, list(
      list(tipo = "marca", col = paleta[[k]]),
      list(tipo = "hueco"),
      list(tipo = "texto", txt = k, col = tinta_leyenda[[k]])
    ))
  }

  anchos <- lapply(piezas, function(p) {
    if (p$tipo == "texto") grid::grobWidth(grid::textGrob(p$txt, gp = gp_txt(p$col)))
    else if (p$tipo == "marca") lado
    else hueco
  })
  total <- Reduce(`+`, anchos)
  y_txt <- grid::unit(1, "npc") - grid::unit(4, "pt")

  grobs <- list()
  previos <- grid::unit(0, "pt")
  for (i in seq_along(piezas)) {
    p <- piezas[[i]]
    x <- grid::unit(1, "npc") - total + previos
    if (p$tipo == "texto") {
      grobs <- c(grobs, list(grid::textGrob(
        p$txt, x = x, y = y_txt, just = c("left", "top"), gp = gp_txt(p$col)
      )))
    } else if (p$tipo == "marca") {
      grobs <- c(grobs, list(grid::roundrectGrob(
        x = x, y = y_txt - grid::unit(0.22 * em, "pt"),
        width = lado, height = lado, r = radio,
        just = c("left", "top"), gp = grid::gpar(fill = p$col, col = NA)
      )))
    }
    previos <- previos + anchos[[i]]
  }
  do.call(grid::grobTree, grobs)
}

# --- Constructor de gráficas -------------------------------------------------
grafica_salario_precio <- function(datos) {
  ggplot2::ggplot(datos, ggplot2::aes(hourly_wage_gbp, price_gbp)) +
    ggplot2::geom_point(
      color = unname(sterling_cat["Violet"]), alpha = 0.66, size = 2.1
    ) +
    ggplot2::scale_x_continuous(labels = scales::label_number(prefix = "£")) +
    ggplot2::scale_y_continuous(labels = scales::label_number(prefix = "£")) +
    ggplot2::labs(
      title = "El salario no explica el precio del capuchino",
      subtitle = paste(
        "Cada punto es una cafetería",
        nota_muestra,
        sep = sep_inline
      ),
      x = "Salario por hora (GBP)",
      y = "Precio del capuchino (GBP)",
      caption = source_line
    ) +
    tema_sterling("y") +
    tema_subtitulo_inline()
}

grafica_extremos <- function(datos) {
  subtitulo <- paste0(
    paste(
      "Índice en los 5 países con mayor y menor valor",
      marca_inline(
        "Más alto",
        paleta_grupo[["Más alto"]], sterling_legend[["Más alto"]]
      ),
      marca_inline(
        "Más bajo",
        paleta_grupo[["Más bajo"]], sterling_legend[["Más bajo"]]
      ),
      sep = sep_inline
    ),
    "<br>",
    paste(nota_muestra, nota_outliers, sep = sep_inline)
  )

  ggplot2::ggplot(datos, ggplot2::aes(country, index_min, fill = grupo, color = grupo)) +
    ggplot2::geom_boxplot(
      width = 0.55,
      coef = 1.5,
      staplewidth = 0.45,
      outliers = FALSE,
      linewidth = stroke_mark,
      median.linewidth = stroke_emphasis
    ) +
    ggplot2::coord_flip(clip = "off") +
    ggplot2::scale_y_continuous(labels = marcas_min) +
    ggplot2::scale_fill_manual(
      values = scales::alpha(paleta_grupo, opacidad_caja),
      drop = FALSE, guide = "none"
    ) +
    ggplot2::scale_color_manual(values = paleta_grupo, drop = FALSE, guide = "none") +
    ggplot2::labs(
      title = "Dónde un capuchino cuesta más minutos de trabajo",
      subtitle = subtitulo,
      x = NULL,
      y = "Minutos de trabajo para un capuchino",
      caption = source_line
    ) +
    tema_sterling("x") +
    tema_subtitulo_inline() +
    ggplot2::theme(
      axis.text.y = ggplot2::element_text(
        family = FUENTE_TEXTO, size = 9, color = tinta, hjust = 1,
        margin = ggplot2::margin(r = 12)
      )
    )
}

capa_mapa <- function(
    datos, fill, guia = "none", colores = sterling_seq,
    nombre_leyenda = NULL
) {
  datos <- dplyr::filter(datos, .data$region != "Antarctica")
  ggplot2::ggplot(
    datos,
    ggplot2::aes(x = long, y = lat, group = group, fill = .data[[fill]])
  ) +
    ggplot2::geom_polygon(color = borde, linewidth = 0.15) +
    ggplot2::scale_fill_gradientn(
      colours = colores, na.value = superficie_na,
      labels = marcas_min, name = nombre_leyenda, guide = guia
    ) +
    ggplot2::coord_fixed(ratio = MAP_RATIO, xlim = MAP_XLIM, expand = FALSE)
}

grafica_mapa <- function(
    datos, fill, titulo, subtitulo, nombre_leyenda,
    colores = sterling_seq
) {
  capa_mapa(
    datos, fill, guia = "colorbar", colores = colores,
    nombre_leyenda = nombre_leyenda
  ) +
    ggplot2::labs(
      title = titulo,
      subtitle = subtitulo,
      caption = source_line,
      fill = nombre_leyenda
    ) +
    tema_mapa() +
    tema_subtitulo_inline() +
    ggplot2::guides(
      fill = ggplot2::guide_colorbar(
        barwidth = grid::unit(0.45, "lines"),
        barheight = grid::unit(10, "lines"),
        title.position = "top",
        title.hjust = 0
      )
    )
}

# País = clase en el eje vertical y color = país. Cada cuadro es un minuto.
# Las facetas en filas forman tiras horizontales para colocarlas bajo el mapa.
grafica_waffle <- function(
    n_alto, n_bajo, pais_alto, pais_bajo, contexto = FALSE,
    color_alto = unname(sterling_cat["Teal"]),
    color_bajo = unname(sterling_cat["Orchid"]),
    texto_alto = unname(sterling_legend["Teal"]),
    texto_bajo = unname(sterling_legend["Orchid"])
) {
  n_alto <- as.integer(round(n_alto))
  n_bajo <- as.integer(round(n_bajo))
  n_rows <- if (isTRUE(contexto)) 3L else 8L
  veces <- max(1L, as.integer(round(n_alto / n_bajo)))

  pal_fill <- stats::setNames(
    c(color_alto, color_bajo),
    c(pais_alto, pais_bajo)
  )
  subtitulo <- paste(
    "Cada cuadro representa un minuto",
    marca_inline(
      paste0(pais_alto, "&nbsp;", n_alto, " min"),
      pal_fill[[pais_alto]], texto_alto
    ),
    marca_inline(
      paste0(pais_bajo, "&nbsp;", n_bajo, " min"),
      pal_fill[[pais_bajo]], texto_bajo
    ),
    paste0(pais_alto, " requiere ", veces, " veces más"),
    "Países con n ≥ 10",
    sep = sep_inline
  )

  df <- tibble::tibble(
    country = c(pais_alto, pais_bajo),
    minutos = c(n_alto, n_bajo)
  ) %>%
    dplyr::mutate(
      country = factor(.data$country, levels = c(pais_alto, pais_bajo)),
      etiqueta = paste0(.data$country, " · ", .data$minutos, " min"),
      etiqueta = factor(
        .data$etiqueta,
        levels = paste0(c(pais_alto, pais_bajo), " · ", c(n_alto, n_bajo), " min")
      )
    )

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(values = .data$minutos, fill = .data$country)
  ) +
    waffle::geom_waffle(
      n_rows = n_rows, flip = FALSE, color = paper, size = 0.35
    ) +
    ggplot2::facet_grid(etiqueta ~ ., switch = "y") +
    ggplot2::scale_fill_manual(values = pal_fill, guide = "none") +
    ggplot2::scale_x_discrete(expand = c(0, 0)) +
    ggplot2::scale_y_discrete(expand = c(0, 0)) +
    ggplot2::coord_equal(expand = FALSE, clip = "on") +
    ggplot2::labs(
      title = paste0(
        pais_alto, " requiere ", veces, " veces más trabajo que ", pais_bajo
      ),
      subtitle = subtitulo,
      x = NULL,
      y = NULL,
      caption = source_line
    ) +
    tema_sterling("y") +
    tema_subtitulo_inline() +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = paper, color = NA),
      panel.grid = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      panel.spacing.y = grid::unit(9, "pt"),
      strip.background = ggplot2::element_blank(),
      strip.text = ggplot2::element_blank()
    )

  if (isTRUE(contexto)) {
    p <- p +
      ggplot2::labs(title = NULL, subtitle = NULL, caption = NULL) +
      ggplot2::theme(plot.margin = ggplot2::margin(0, 0, 4, 0))
  }
  p
}

grafica_ridgeline_std <- function(
    datos, pais_alto, pais_bajo, contexto = FALSE,
    color_alto = unname(sterling_cat["Blue"]),
    color_bajo = unname(sterling_cat["Coral"]),
    texto_alto = unname(sterling_legend["Blue"]),
    texto_bajo = unname(sterling_legend["Coral"])
) {
  pal_fill <- stats::setNames(
    c(color_bajo, color_alto),
    c(pais_bajo, pais_alto)
  )
  datos <- dplyr::mutate(
    datos,
    country = factor(.data$country, levels = c(pais_bajo, pais_alto))
  )
  # La densidad se extiende unos dos anchos de banda más allá del máximo, así
  # que la etiqueta se coloca después de ese tramo para no cruzar la cola.
  ancho_banda <- 12
  resumen <- datos %>%
    dplyr::group_by(.data$country) %>%
    dplyr::summarise(
      std = stats::sd(.data$index_min),
      x = max(.data$index_min) + 2.6 * ancho_banda,
      .groups = "drop"
    ) %>%
    dplyr::mutate(
      y = as.numeric(.data$country) + 0.14,
      label = paste0("σ = ", formatC(.data$std, digits = 1, format = "f"), " min")
    )
  std_alto <- resumen$std[resumen$country == pais_alto]
  std_bajo <- resumen$std[resumen$country == pais_bajo]
  subtitulo <- paste0(
    paste(
      "Desviación estándar entre cafeterías",
      marca_inline(
        paste0(pais_alto, "&nbsp;", formatC(std_alto, digits = 0, format = "f"), " min"),
        pal_fill[[pais_alto]], texto_alto
      ),
      marca_inline(
        paste0(pais_bajo, "&nbsp;", formatC(std_bajo, digits = 1, format = "f"), " min"),
        pal_fill[[pais_bajo]], texto_bajo
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

  p <- ggplot2::ggplot(
    datos,
    ggplot2::aes(
      x = .data$index_min, y = .data$country,
      fill = .data$country, color = .data$country
    )
  ) +
    ggridges::geom_density_ridges(
      alpha = opacidad_caja, linewidth = stroke_emphasis,
      scale = 0.9, rel_min_height = 0.005, bandwidth = ancho_banda
    ) +
    ggplot2::geom_text(
      data = resumen,
      ggplot2::aes(
        x = .data$x, y = .data$y, label = .data$label, color = .data$country
      ),
      inherit.aes = FALSE, hjust = 0, vjust = 0,
      family = FUENTE_TEXTO, size = 3.2
    ) +
    ggplot2::scale_fill_manual(values = pal_fill, guide = "none") +
    ggplot2::scale_color_manual(values = pal_fill, guide = "none") +
    ggplot2::scale_x_continuous(
      labels = marcas_min,
      expand = ggplot2::expansion(mult = c(0.05, 0.14))
    ) +
    ggplot2::labs(
      title = paste0(
        pais_alto, " tiene la mayor variabilidad y ", pais_bajo, " la menor"
      ),
      subtitle = subtitulo,
      x = "Minutos de trabajo para un capuchino",
      y = NULL,
      caption = source_line
    ) +
    tema_sterling("x") +
    tema_subtitulo_inline() +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank()
    )

  if (isTRUE(contexto)) {
    p <- p +
      ggplot2::labs(title = NULL, subtitle = NULL, caption = NULL) +
      ggplot2::theme(plot.margin = ggplot2::margin(0, 0, 4, 0))
  }
  p
}

grafica_index_std <- function(datos, r) {
  ggplot2::ggplot(datos, ggplot2::aes(index, std)) +
    ggplot2::geom_smooth(
      method = "lm", formula = y ~ x, se = FALSE,
      color = unname(sterling_cat["Violet"]),
      linewidth = stroke_emphasis, alpha = 0.9
    ) +
    ggplot2::geom_point(
      color = unname(sterling_cat["Violet"]), alpha = 0.66, size = 2.6
    ) +
    ggplot2::scale_x_continuous(labels = marcas_min) +
    ggplot2::scale_y_continuous(labels = marcas_min) +
    ggplot2::labs(
      title = "A mayor índice, mayor dispersión entre cafeterías",
      subtitle = paste0(
        "Correlación de Pearson&nbsp;&nbsp;r = ",
        formatC(r, format = "f", digits = 3),
        sep_inline,
        marca_inline(
          "Línea de ajuste",
          unname(sterling_cat["Violet"]),
          unname(sterling_legend["Más alto"])
        ),
        "<br>Países con n ≥ 10",
        sep_inline,
        nota_outliers
      ),
      x = "Índice Cappuccino (minutos)",
      y = "Desviación estándar (minutos)",
      caption = source_line
    ) +
    tema_sterling("y") +
    tema_subtitulo_inline()
}

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

componer_mapa_contexto <- function(
    mapa, contexto, alturas = c(3.2, 0.9), espacio_inferior = 0
) {
  mapa_limpio <- mapa +
    ggplot2::labs(caption = NULL) +
    ggplot2::theme(
      plot.caption = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(34, 0, 2, 0)
    )

  paneles <- list(mapa_limpio, contexto)
  proporciones <- alturas
  if (espacio_inferior > 0) {
    paneles <- c(paneles, list(panel_papel()))
    proporciones <- c(proporciones, espacio_inferior)
  }

  patchwork::wrap_plots(paneles, ncol = 1, heights = proporciones) +
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
crear_grob_editorial <- function(plot, leyenda = FALSE) {
  g <- if (inherits(plot, "patchwork")) {
    patchwork::patchworkGrob(plot)
  } else {
    ggplot2::ggplotGrob(plot)
  }

  if (!identical(leyenda, FALSE)) {
    i_sub <- which(g$layout$name == "subtitle")
    if (length(i_sub) == 1) {
      grob_leg <- if (is.list(leyenda)) {
        grob_leyenda(
          paleta = leyenda$paleta,
          tinta_leyenda = leyenda$tinta_leyenda
        )
      } else {
        grob_leyenda()
      }
      g$grobs[[i_sub]] <- grid::grobTree(g$grobs[[i_sub]], grob_leg)
    }
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

guardar_png <- function(plot, nombre, ancho_px, alto_px, resolucion = 96, leyenda = FALSE) {
  ragg::agg_png(
    nombre, width = ancho_px, height = alto_px, units = "px",
    res = resolucion, background = paper
  )
  on.exit(grDevices::dev.off(), add = TRUE)
  grid::grid.newpage()
  grid::grid.draw(crear_grob_editorial(plot, leyenda = leyenda))
}

# espacios: relleno inferior por formato para las láminas de proporción fija,
# que si no quedarían centradas a media altura en los formatos verticales.
exportar_laminas <- function(plot, slug, output_path, leyenda = FALSE, espacios = NULL) {
  para_formato <- function(clave) {
    if (is.null(espacios) || is.na(espacios[clave])) plot
    else componer_con_espacio(plot, espacios[[clave]])
  }

  guardar_png(plot, file.path(output_path, paste0("cappuccino_", slug, "_master.png")), 3600, 2400, resolucion = 300, leyenda = leyenda)
  guardar_png(para_formato("1x1"),  file.path(output_path, paste0("cappuccino_", slug, "_1x1.png")),  1080, 1080, leyenda = leyenda)
  guardar_png(para_formato("4x5"),  file.path(output_path, paste0("cappuccino_", slug, "_4x5.png")),  1080, 1350, leyenda = leyenda)
  guardar_png(para_formato("9x16"), file.path(output_path, paste0("cappuccino_", slug, "_9x16.png")), 1080, 1920, leyenda = leyenda)
  guardar_png(plot, file.path(output_path, paste0("cappuccino_", slug, "_1.91x1.png")), 1200, 628,  leyenda = leyenda)
}

# --- Exportación vectorial (Illustrator) -------------------------------------
# Los alias de systemfonts viajan al SVG tal cual y ningún editor los resuelve,
# así que en el archivo se reescriben con el nombre real de cada familia.
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
  svglite::svglite(
    nombre,
    width = ancho_px / resolucion,
    height = alto_px / resolucion,
    bg = paper,
    fix_text_size = FALSE
  )
  # El archivo se termina de escribir al cerrar el dispositivo, así que las
  # familias se reescriben después.
  tryCatch({
    grid::grid.newpage()
    grid::grid.draw(crear_grob_editorial(plot))
  }, finally = grDevices::dev.off())
  renombrar_fuentes_svg(nombre)
}

# Solo los formatos que se editan para el reporte: cuadrado y apaisados.
# Los verticales quedan fuera porque son para historias, no para el PDF.
exportar_svg <- function(plot, slug, output_path, plot_1x1 = NULL) {
  destino <- function(sufijo) {
    file.path(output_path, paste0("cappuccino_", slug, "_", sufijo, ".svg"))
  }
  guardar_svg(plot, destino("master"), 3600, 2400, resolucion = 300)
  guardar_svg(plot, destino("1.91x1"), 1200, 628)
  guardar_svg(
    if (is.null(plot_1x1)) plot else plot_1x1,
    destino("1x1"), 1080, 1080
  )
}

exportar_laminas_mapa_contexto <- function(
    mapa, contexto, slug, output_path, alturas = c(3.2, 0.9),
    espacios = c(`1x1` = 1.2, `4x5` = 2.3, `9x16` = 5.2)
) {
  # El master y el formato apaisado ya aprovechan bien la geometría del mapa.
  guardar_png(mapa, file.path(output_path, paste0("cappuccino_", slug, "_master.png")), 3600, 2400, resolucion = 300)
  guardar_png(mapa, file.path(output_path, paste0("cappuccino_", slug, "_1.91x1.png")), 1200, 628)

  # En formatos cuadrados y verticales, mapa y contexto forman un bloque superior.
  # El espacio residual queda debajo y no separa artificialmente ambos gráficos.
  compuesto_1x1 <- componer_mapa_contexto(
    mapa, contexto, alturas, espacios[["1x1"]]
  )
  compuesto_4x5 <- componer_mapa_contexto(
    mapa, contexto, alturas, espacios[["4x5"]]
  )
  compuesto_9x16 <- componer_mapa_contexto(
    mapa, contexto, alturas, espacios[["9x16"]]
  )
  guardar_png(compuesto_1x1, file.path(output_path, paste0("cappuccino_", slug, "_1x1.png")),  1080, 1080)
  guardar_png(compuesto_4x5, file.path(output_path, paste0("cappuccino_", slug, "_4x5.png")),  1080, 1350)
  guardar_png(compuesto_9x16, file.path(output_path, paste0("cappuccino_", slug, "_9x16.png")), 1080, 1920)
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

ruta_lamina <- function(output_path, slug, formato, extension) {
  file.path(
    output_path,
    paste0("cappuccino_", slug, "_", formato, ".", extension)
  )
}

guardar_svg <- function(plot, nombre, ancho_px, alto_px, resolucion = 96) {
  local({
    svglite::svglite(
      nombre,
      width = ancho_px / resolucion, height = alto_px / resolucion,
      bg = paper,
      # Sin textLength cada texto queda editable en lugar de estirado al ancho.
      fix_text_size = FALSE
    )
    on.exit(grDevices::dev.off(), add = TRUE)
    grid::grid.newpage()
    grid::grid.draw(crear_grob_editorial(plot))
  })
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

exportar_vectorial_mapa_contexto <- function(
    mapa, contexto, slug, output_path, alturas = c(3.2, 0.9),
    espacios = c(`1x1` = 1.2)
) {
  guardar_svg(mapa, ruta_lamina(output_path, slug, "master", "svg"), 3600, 2400, resolucion = 300)
  guardar_svg(mapa, ruta_lamina(output_path, slug, "1.91x1", "svg"), 1200, 628)
  guardar_svg(
    componer_mapa_contexto(mapa, contexto, alturas, espacios[["1x1"]]),
    ruta_lamina(output_path, slug, "1x1", "svg"), 1080, 1080
  )
}

#-----------------------------------------------------------------------------
# End of visualizaciones.R
#-----------------------------------------------------------------------------
