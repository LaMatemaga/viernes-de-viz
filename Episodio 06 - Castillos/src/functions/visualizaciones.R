#-----------------------------------------------------------------------------
# visualizaciones.R
#-----------------------------------------------------------------------------
#   Sterling styling, continent bar charts, editorial grobs, and PNG export.
#-----------------------------------------------------------------------------

# --- Tipografías -------------------------------------------------------------
# systemfonts es el motor nativo de ragg: el escalado tipográfico sale correcto
# a cualquier resolución sin sincronizar showtext_opts(dpi = ...) a mano.
font_file <- "Fraunces-VariableFont_SOFT,WONK,opsz,wght.ttf"
font_root <- if (file.exists(font_file)) {
  "."
} else if (file.exists(file.path("..", font_file))) {
  ".."
} else {
  stop("No se encontraron los archivos de tipografía en la carpeta del proyecto.")
}

# Se registran con un alias propio, no con el nombre real de la familia:
# register_font() se niega a pisar una familia ya instalada en el sistema
# ("A system font with that family name already exists"). Con alias, el
# archivo del proyecto siempre gana, tengas o no la fuente instalada, y el
# gráfico se ve igual en cualquier equipo.
# Reparto tipográfico de Sterling:
#   --sterling-font-display -> Fraunces        (título)
#   --font-sans (= Inter)   -> Inter           (subtítulo; .sterling-figure__
#                                               subtitle no fija familia y
#                                               hereda la sans del contenedor)
#   --sterling-font-mono    -> JetBrains Mono  (ejes, valores, pie)
FUENTE_TITULO <- "Fraunces (proyecto)"
FUENTE_SUB    <- "Inter (proyecto)"
FUENTE_TEXTO  <- "JetBrains Mono (proyecto)"

registrar <- function(alias, archivo) {
  ruta <- normalizePath(file.path(font_root, archivo), mustWork = TRUE)
  register_font(alias, plain = ruta, bold = ruta)
}

registrar(FUENTE_TITULO, font_file)
registrar(FUENTE_SUB,   "Inter-VariableFont_opsz,wght.ttf")
registrar(FUENTE_TEXTO, "JetBrainsMono-VariableFont_wght.ttf")

# --- Paleta Sterling (canónica, LaMatemaga/sterling) -------------------------
# Escala CATEGÓRICA (--sterling-cat-1..8, modo light): el tipo de construcción
# es nominal. El ramp divergente (--sterling-div-*) del episodio de IELTS
# codifica distancia respecto a un centro, que aquí no significa nada.
sterling_cat <- c(
  Violet = "#9A79E7", Teal  = "#25A08D", Orchid = "#D45AC7", Amber = "#E4A43A",
  Blue   = "#5A83D7", Coral = "#E87864", Moss   = "#96AB51", Payne = "#536B78"
)

# Variante print (--sterling-cat-* modo print), por si alguna va a papel.
sterling_cat_print <- c(
  Violet = "#8E68D8", Teal  = "#218C7C", Orchid = "#C653BC", Amber = "#D39A32",
  Blue   = "#4F73C6", Coral = "#DC6A55", Moss   = "#879347", Payne = "#607986"
)

# Tokens de superficie
paper     <- "#F6F3FB"  # --sterling-paper  (lienzo exterior)
panel     <- "#FBF9FE"  # --sterling-surface (área de trazado)
tinta     <- "#241A3D"  # --sterling-text
tinta_sec <- "#5C5178"  # --sterling-muted
retic     <- "#D9D1E6"  # --sterling-grid
borde     <- "#CFC5DE"  # --sterling-edge

paleta_categoria <- c(
  castle   = unname(sterling_cat["Violet"]),
  palace   = unname(sterling_cat["Teal"]),
  fortress = unname(sterling_cat["Orchid"]),
  ruin     = unname(sterling_cat["Amber"])
)
etiquetas_categoria <- c(
  castle = "Castillo", palace = "Palacio",
  fortress = "Fortaleza", ruin = "Ruina"
)

# --sterling-legend-1..4: mismos matices, oscurecidos para que el texto sea
# legible sobre fondo claro. Son los que corresponden cuando la leyenda es
# texto y no muestra de color.
sterling_legend <- c(
  castle = "#6945B8", palace = "#147568",
  fortress = "#A43A99", ruin = "#855700"
)


# --- Formato de números ------------------------------------------------------
# 1.4M / 666.3K / 20.4K. formatC en vez de round para que el .0 no se pierda y
# la columna de etiquetas conserve el mismo ancho.
marcas <- function(x) {
  ifelse(
    is.na(x), "",
    ifelse(abs(x) >= 1e6, paste0(formatC(x / 1e6, format = "f", digits = 1), "M"),
           ifelse(abs(x) >= 1e3, paste0(formatC(x / 1e3, format = "f", digits = 1), "K"),
                  formatC(x, format = "f", digits = 0)))
  )
}

# En el eje el decimal solo es ruido: 200K se lee mejor que 200.0K.
marcas_eje <- function(x) sub("\\.0(?=[MK]$)", "", marcas(x), perl = TRUE)

# --- Eje izquierdo de ancho constante ----------------------------------------
# JetBrains Mono es monoespaciada: si toda etiqueta tiene el mismo número de
# caracteres ocupa el mismo ancho en píxeles, y el panel arranca en la misma
# coordenada en las cinco gráficas.
ANCHO_ETIQUETA <- 34

encajar <- function(x, w = ANCHO_ETIQUETA) {
  x <- ifelse(nchar(x) > w, paste0(substr(x, 1, w - 1), "\u2026"), x)
  formatC(x, width = w)   # width positivo = rellena por la izquierda
}

# --- Pie editorial y leyenda -------------------------------------------------
source_line <- "Fuente: Wikidata / TidyTuesday (2026-09-01)"
credit_line <- "Hecho durante #ViernesDeVisualizaciones por La Matemaga."

# Leyenda como grob de textos coloreados, anclada al borde derecho. Se arma con
# textGrob y no con ggtext: gridtext calcula el acomodo con las métricas de
# grid, así que si algo intercepta el dibujado de texto (showtext, por ejemplo)
# los tramos se encinan unos sobre otros. Con textGrob eso no puede pasar.
grob_leyenda <- function(tamano = 11) {
  em    <- tamano                        # 1em en puntos
  lado  <- grid::unit(0.48 * em, "pt")   # rect 8/12 dentro de un box de .72em
  radio <- grid::unit(0.06 * em, "pt")   # rx = 1 en el viewBox de 12
  hueco <- grid::unit(0.30 * em, "pt")   # gap del .sterling-inline-legend__item
  
  gp_txt <- function(col) grid::gpar(fontfamily = FUENTE_SUB, fontsize = tamano, col = col)
  
  # La marca se rellena con el color de barra (--sterling-cat-*) y el texto usa
  # el tono oscurecido (--sterling-legend-*), que es lo que Sterling hace: el
  # cuadro tiene que casar con la barra, el texto tiene que ser legible.
  piezas <- list()
  for (i in seq_along(etiquetas_categoria)) {
    k <- names(etiquetas_categoria)[i]
    if (i > 1) piezas <- c(piezas, list(list(tipo = "texto", txt = "  \u00b7  ", col = tinta_sec)))
    piezas <- c(piezas, list(
      list(tipo = "marca", col = paleta_categoria[[k]]),
      list(tipo = "hueco"),
      list(tipo = "texto", txt = etiquetas_categoria[[k]], col = sterling_legend[[k]])
    ))
  }
  
  anchos <- lapply(piezas, function(p) {
    if (p$tipo == "texto") grid::grobWidth(grid::textGrob(p$txt, gp = gp_txt(p$col)))
    else if (p$tipo == "marca") lado
    else hueco
  })
  total <- Reduce(`+`, anchos)
  
  # Se ancla al tope de la fila menos el margen superior del subtítulo, no a
  # 0.5 npc: esa fila incluye el margen inferior y la leyenda quedaría flotando
  # debajo del texto en vez de en su misma línea.
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

TOPE_COMUN <- 1500000  # tope compartido: hace comparables las cinco láminas

# --- Constructor de gráfica --------------------------------------------------
grafica_continente <- function(datos, continente) {
  
  if (continente == "global") {
    datos <- datos %>%
      mutate(etiqueta = paste0(encajar(name), "\n", encajar(paste0(pais, "\n", continent))))
  }
  
  datos <- datos %>%
    mutate(etiqueta = factor(etiqueta, levels = rev(etiqueta)))
  
  ggplot(datos, aes(x = etiqueta, y = pageviews, fill = category)) +
    geom_col(width = 0.72) +
    geom_text(
      aes(label = marcas(pageviews)),
      hjust = -0.15, family = FUENTE_TEXTO, size = 2.9, color = tinta_sec
    ) +
    coord_flip(clip = "off") +
    scale_y_continuous(
      labels = marcas_eje,
      limits = c(0, TOPE_COMUN),
      breaks = seq(0, TOPE_COMUN, by = 200000),
      expand = expansion(mult = c(0, 0))
    ) +
    scale_fill_manual(values = paleta_categoria, drop = FALSE, guide = "none") +
    labs(
      title = if (continente == "global") {
        "Patrimonio arquitectónico mundial más popular en Wikipedia"
      } else {
        paste0("Patrimonio arquitectónico de ", continente,
               " más popular en Wikipedia")
      },
      # Solo el texto: la leyenda se inyecta después como grob alineado a la
      # derecha, en la misma línea (ver crear_grob_editorial).
      subtitle = if (continente == "global") {
        "El más popular de cada continente"
      } else {
        paste0(nrow(datos), " sitios con más vistas anuales")
      },
      x = NULL,
      y = "Vistas en Wikipedia",
      caption = source_line
    ) +
    theme_minimal(base_family = FUENTE_TEXTO) +
    theme(
      plot.background    = element_rect(fill = paper, color = NA),
      panel.background   = element_rect(fill = panel, color = NA),
      panel.grid.major.x = element_line(color = retic, linewidth = 0.3),
      panel.grid.major.y = element_blank(),
      panel.grid.minor   = element_blank(),
      
      plot.title = element_text(
        family = FUENTE_TITULO, size = 22, face = "bold", color = tinta,
        margin = margin(t = 8, b = 10)
      ),
      plot.subtitle = element_text(
        family = FUENTE_SUB, size = 11, color = tinta_sec,
        hjust = 0, margin = margin(t = 4, b = 26)
      ),
      plot.caption = element_text(
        family = FUENTE_TEXTO, size = 8, color = tinta_sec, hjust = 0,
        margin = margin(t = 34, b = 4)
      ),
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      plot.margin = margin(34, 32, 22, 32),
      
      axis.title.x = element_text(
        family = FUENTE_TEXTO, size = 10, color = tinta,
        margin = margin(t = 12)
      ),
      # hjust = 1 pega la etiqueta al eje; el relleno monoespaciado por la
      # izquierda mantiene el mismo ancho de caja, así que el panel sigue
      # arrancando en la misma coordenada en las cinco láminas.
      axis.text.y = element_text(
        family = FUENTE_TEXTO, size = 8, color = tinta,
        hjust = 1, lineheight = 1.15, margin = margin(r = 12)
      ),
      axis.text.x  = element_text(family = FUENTE_TEXTO, size = 9, color = tinta_sec),
      axis.ticks.x = element_line(color = borde),
      axis.ticks.y = element_blank()
    )
}

# --- Exportación -------------------------------------------------------------
crear_grob_editorial <- function(plot) {
  g <- ggplotGrob(plot)
  
  # La leyenda se cuelga del borde derecho de la misma fila del subtítulo,
  # conservando el texto que ya trae a la izquierda.
  i_sub <- which(g$layout$name == "subtitle")
  g$grobs[[i_sub]] <- grid::grobTree(g$grobs[[i_sub]], grob_leyenda())
  
  idx <- which(g$layout$name == "caption")
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
  g
}

guardar_png <- function(plot, nombre, ancho_px, alto_px, resolucion = 96) {
  agg_png(nombre, width = ancho_px, height = alto_px, units = "px",
          res = resolucion, background = paper)
  on.exit(grDevices::dev.off(), add = TRUE)
  grid::grid.newpage()
  grid::grid.draw(crear_grob_editorial(plot))
}

slug <- c("América" = "america", "Asia" = "asia", "África" = "africa",
          "Oceanía" = "oceania", "Europa" = "europa", "global" = "global")

#-----------------------------------------------------------------------------
# End of visualizaciones.R
#-----------------------------------------------------------------------------
