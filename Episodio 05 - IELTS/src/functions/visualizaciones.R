#-----------------------------------------------------------------------------
# visualizaciones.R
#-----------------------------------------------------------------------------
#   Sterling palette, project fonts, editorial grob, and PNG export helpers.
#-----------------------------------------------------------------------------

## Plotting
# 1. Definir los colores base que proporcionaste
# Escala divergente de Sterling. Cada tono es un token de la paleta, sin
# interpolar colores nuevos. El centro queda entre las bandas 6 y 6.5, que es
# el mismo punto de referencia utilizado para separar las barras a cada lado.
sterling <- c(
  "#4D357A", "#7B59BC", "#9A79E7", "#B69AF2", "#D5C3F6", "#F1ECFA",
  "#E4F4EF", "#5EC9AE", "#25A08D", "#1E796C", "#1B675D", "#164D47"
)

paleta_final <- sterling[12:1]

# Definir tipografías -------------------------------------------------------
# Las fuentes están incluidas en el proyecto: no se descargan de Google para
# que el gráfico sea reproducible y conserve el mismo aspecto en otro equipo.
font_file <- "Fraunces-VariableFont_SOFT,WONK,opsz,wght.ttf"
font_root <- if (file.exists(font_file)) {
  "."
} else if (file.exists(file.path("..", "fonts", font_file))) {
  file.path("..", "fonts")
} else if (file.exists(file.path("..", font_file))) {
  ".."
} else {
  stop("No se encontraron los archivos de tipografía en fonts/ ni en la carpeta del proyecto.")
}

font_fraunces <- normalizePath(file.path(font_root, font_file))
font_jetbrains <- normalizePath(file.path(
  font_root, "JetBrainsMono-VariableFont_wght.ttf"
))

sysfonts::font_add(
  family = "Fraunces",
  regular = font_fraunces,
  bold = font_fraunces
)
sysfonts::font_add(
  family = "JetBrains Mono",
  regular = font_jetbrains,
  bold = font_jetbrains
)

showtext_opts(dpi = 300)
showtext_auto()

crear_grob_editorial <- function(plot) {
  plot_grob <- ggplotGrob(plot)
  caption_index <- which(plot_grob$layout$name == "caption")

  plot_grob$grobs[[caption_index]] <- grid::grobTree(
    grid::textGrob(
      source_line,
      x = grid::unit(0, "npc"), y = grid::unit(0.5, "npc"),
      just = c("left", "center"),
      gp = grid::gpar(fontfamily = "JetBrains Mono", fontsize = 8, col = "#5C5178")
    ),
    grid::textGrob(
      credit_line,
      x = grid::unit(1, "npc"), y = grid::unit(0.5, "npc"),
      just = c("right", "center"),
      gp = grid::gpar(fontfamily = "JetBrains Mono", fontsize = 8, col = "#5C5178")
    )
  )

  plot_grob
}

guardar_png <- function(plot, nombre, ancho_px, alto_px, resolucion = 96) {
  # showtext debe usar la misma resolución que el lienzo; de lo contrario las
  # tipografías conservan la escala del master de 300 ppi en formatos sociales.
  showtext_opts(dpi = resolucion)
  ragg::agg_png(
    filename = nombre,
    width = ancho_px,
    height = alto_px,
    units = "px",
    res = resolucion,
    background = "#FBF9FE"
  )
  on.exit(grDevices::dev.off(), add = TRUE)

  grid::grid.newpage()
  grid::grid.draw(crear_grob_editorial(plot))
}

#-----------------------------------------------------------------------------
# End of visualizaciones.R
#-----------------------------------------------------------------------------
