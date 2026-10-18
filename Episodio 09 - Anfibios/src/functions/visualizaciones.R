#-----------------------------------------------------------------------------
# visualizaciones.R
#-----------------------------------------------------------------------------
#   Árboles taxonómicos circulares de AmphibiaWeb y exportación Sterling.
#-----------------------------------------------------------------------------

# --- Identidad visual --------------------------------------------------------
FUENTE_TITULO <- "Fraunces (proyecto)"
FUENTE_SUB    <- "Inter (proyecto)"
FUENTE_TEXTO  <- "JetBrains Mono (proyecto)"

paper     <- "#F6F3FB"
panel     <- "#FBF9FE"
tinta     <- "#241A3D"
tinta_sec <- "#5C5178"
retic     <- "#D9D1E6"
payne     <- "#536B78"  # --sterling-cat-8

# La paleta no identifica una familia concreta: alterna las seis voces
# categóricas Sterling para separar ramas vecinas sin requerir 57 colores.
paleta_familias <- c(
  "Violet" = "#9A79E7",
  "Teal"   = "#25A08D",
  "Orchid" = "#D45AC7",
  "Amber"  = "#E4A43A",
  "Blue"   = "#5A83D7",
  "Coral"  = "#E87864"
)
# --sterling-cat-* en modo print: un paso más oscuros que los colores light,
# pero sin llegar a los tonos de leyenda, que serían demasiado pesados en ramas.
paleta_aristas <- c(
  "Violet" = "#8E68D8",
  "Teal"   = "#218C7C",
  "Orchid" = "#C653BC",
  "Amber"  = "#D39A32",
  "Blue"   = "#4F73C6",
  "Coral"  = "#DC6A55"
)

source_line <- "Fuente: AmphibiaWeb / TidyTuesday (2026-10-13)"
credit_line <- "Hecho durante #ViernesDeVisualizaciones por La Matemaga."
PREFIJO <- "anfibios"

tema_arbol <- function() {
  ggplot2::theme_void(base_family = FUENTE_TEXTO) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = paper, color = NA),
      panel.background = ggplot2::element_rect(fill = panel, color = NA),
      plot.title = ggplot2::element_text(
        family = FUENTE_TITULO, face = "bold", size = 22, color = tinta,
        margin = ggplot2::margin(t = 8, b = 8)
      ),
      plot.subtitle = ggplot2::element_text(
        family = FUENTE_SUB, size = 11, color = tinta_sec,
        margin = ggplot2::margin(b = 16)
      ),
      plot.caption = ggplot2::element_text(
        family = FUENTE_TEXTO, size = 8, color = tinta_sec, hjust = 0,
        margin = ggplot2::margin(t = 16, b = 4)
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      plot.margin = ggplot2::margin(28, 48, 20, 32)
    )
}

# --- Árbol taxonómico --------------------------------------------------------
# `ape::as.phylo.formula()` arma un cladograma a partir de columnas anidadas.
# No infiere parentesco ni longitudes de rama: la taxonomía es la estructura.
construir_arbol_taxonomico <- function(datos, niveles) {
  datos_arbol <- dplyr::mutate(
    datos,
    dplyr::across(dplyr::all_of(niveles), as.factor)
  )
  formula_arbol <- stats::as.formula(
    paste("~", paste(niveles, collapse = "/"))
  )
  # collapse = FALSE conserva los rangos de un solo descendiente. Si se
  # colapsaran, una familia monotípica quedaría más cerca del centro que
  # las demás. Cada arista vale 1: un anillo por nivel taxonómico.
  arbol <- ape::as.phylo(formula_arbol, data = datos_arbol, collapse = FALSE)
  arbol$edge.length <- rep(1, nrow(arbol$edge))
  arbol
}

asignar_colores_familia <- function(datos) {
  familias <- sort(unique(datos$familia))
  asignacion <- stats::setNames(
    rep(names(paleta_familias), length.out = length(familias)),
    familias
  )

  dplyr::mutate(
    datos,
    color_anillo = unname(asignacion[.data$familia])
  )
}

asignar_colores_circulares <- function(arbol, datos_puntas) {
  # El orden y de ggtree es el orden angular en el layout circular. Las familias
  # del árbol son clados contiguos, de modo que se pueden colorear como un ciclo.
  orden <- ggtree::ggtree(arbol, layout = "circular")$data %>%
    dplyr::filter(.data$isTip) %>%
    dplyr::arrange(.data$y) %>%
    dplyr::pull(.data$label) %>%
    (\(puntas) datos_puntas$familia[match(puntas, datos_puntas$tip_label)])() %>%
    unique()

  voces <- names(paleta_familias)
  asignacion <- character(length(orden))

  for (i in seq_along(orden)) {
    asignacion[i] <- voces[(i - 1) %% length(voces) + 1]
  }

  # Cierra el círculo sin repetir el color de la primera familia. Con seis
  # voces, siempre queda al menos una alternativa distinta de ambas vecinas.
  if (asignacion[length(asignacion)] == asignacion[1]) {
    asignacion[length(asignacion)] <- setdiff(
      voces, c(asignacion[length(asignacion) - 1], asignacion[1])
    )[1]
  }

  names(asignacion) <- orden
  asignacion
}

grafica_arbol_circular <- function(
    arbol, datos_puntas, titulo, subtitulo, etiquetar_puntas = FALSE
) {
  datos_puntas <- asignar_colores_familia(datos_puntas) %>%
    dplyr::select(.data$tip_label, dplyr::everything())

  # groupOTU añade la columna color_rama al objeto phylo; ggtree la usa para
  # colorear las ramas. Las puntas deben coincidir exactamente con tip.label.
  grupos <- split(datos_puntas$tip_label, datos_puntas$color_anillo)
  arbol_coloreado <- ggtree::groupOTU(
    arbol, grupos, group_name = "color_rama"
  )

  p <- ggtree::ggtree(
    arbol_coloreado,
    ggplot2::aes(color = color_rama),
    layout = "circular",
    branch.length = "none",
    linewidth = 0.3
  ) +
    ggplot2::scale_color_manual(values = paleta_familias, guide = "none")

  if (etiquetar_puntas) {
    p <- p + ggtree::geom_tiplab2(
      ggplot2::aes(angle = angle),
      family = FUENTE_TEXTO, size = 2.4, color = tinta,
      offset = 0.5, align = TRUE, linesize = 0.2
    )
  }

  p +
    ggtreeExtra::geom_fruit(
      data = datos_puntas,
      geom = geom_col,
      mapping = ggplot2::aes(
        y = tip_label, x = log1p(n_especies), fill = color_anillo
      ),
      orientation = "y",
      offset = 0.05,
      pwidth = 0.32,
      axis.params = list(
        axis = "x",
        title = "Especies por punta (log1p)",
        title.size = 2.8,
        text.size = 2.4,
        line.size = 0.25
      )
    ) +
    ggplot2::scale_fill_manual(values = paleta_familias, guide = "none") +
    ggplot2::labs(
      title = titulo,
      subtitle = subtitulo,
      caption = paste(source_line, credit_line, sep = "  ·  ")
    ) +
    tema_arbol()
}

# Con usar_distancias = TRUE el radio es el tiempo evolutivo de la filogenia
# fechada. En FALSE se conserva la topología y todas las ramas valen lo mismo.
grafica_filogenia_circular <- function(
    arbol, datos_puntas, titulo, subtitulo, anillo_familias = FALSE,
    guias_barras = FALSE, pwidth_barras = 0.28, usar_distancias = TRUE,
    umbral_etiquetas = 150
) {
  asignacion <- asignar_colores_circulares(arbol, datos_puntas)
  familias <- names(asignacion)
  color_por_familia <- stats::setNames(
    unname(paleta_familias[asignacion]),
    familias
  )
  color_arista_por_familia <- stats::setNames(
    unname(paleta_aristas[asignacion]),
    familias
  )

  # Cada familia recibe una de las seis voces Sterling. groupOTU propaga el color
  # desde las puntas a las ramas de su clado cuando el árbol lo conserva.
  arbol_coloreado <- ggtree::groupOTU(
    arbol,
    split(datos_puntas$tip_label, datos_puntas$familia),
    group_name = "familia"
  )

  p <- ggtree::ggtree(
    arbol_coloreado,
    layout = "circular",
    branch.length = if (usar_distancias) "branch.length" else "none",
    color = NA,
    linewidth = 0
  )

  # Las cuñas empiezan en el ancestro común más reciente de cada familia.
  # Así el centro conserva el blanco del papel y el color solo vive dentro
  # del clado correspondiente. Se dibujan únicamente si el clado contiene
  # exactamente las puntas de esa familia: una familia no monofilética
  # abarcaría indebidamente las especies de otras familias.
  nodos_familias <- vapply(
    split(datos_puntas$tip_label, datos_puntas$familia),
    function(puntas) {
      if (length(puntas) < 2) return(NA_integer_)
      nodo <- ape::getMRCA(arbol, puntas)
      if (length(nodo) != 1) return(NA_integer_)

      puntas_del_clado <- ape::extract.clade(arbol, nodo)$tip.label
      if (setequal(puntas_del_clado, puntas)) nodo else NA_integer_
    },
    integer(1)
  )

  for (familia in names(nodos_familias)) {
    if (is.na(nodos_familias[[familia]])) next
    p <- p + ggtree::geom_hilight(
      node = nodos_familias[[familia]],
      fill = color_por_familia[[familia]],
      color = NA,
      alpha = 0.10,
      extend = 0,
      linewidth = 0
    )
  }

  p <- p +
    ggtree::geom_tree(
      ggplot2::aes(color = familia),
      linewidth = 0.16
    ) +
    ggtree::geom_tippoint(
      ggplot2::aes(fill = familia),
      shape = 21,
      color = NA,
      size = 0.46,
      alpha = 0.9
    )

  if (anillo_familias) {
    # La posición y es la mediana de las puntas de una familia en el círculo:
    # así queda una barra por familia, centrada sobre el arco de su clado.
    posiciones_puntas <- datos_puntas %>%
      dplyr::inner_join(
        dplyr::filter(p$data, .data$isTip) %>%
          dplyr::select(label, y),
        by = c("tip_label" = "label")
      )

    resumen_familias <- posiciones_puntas %>%
      dplyr::group_by(.data$familia) %>%
      dplyr::summarise(
        n_especies = dplyr::n(),
        ancho = max(.data$y) - min(.data$y) + 1,
        .groups = "drop"
      ) %>%
      dplyr::left_join(
        posiciones_puntas %>%
          dplyr::group_by(.data$familia) %>%
          dplyr::summarise(
            tip_label = .data$tip_label[
              which.min(abs(.data$y - stats::median(.data$y)))
            ],
            .groups = "drop"
          ),
        by = "familia"
      ) %>%
      # Evita colisionar con la columna familia que groupOTU ya añadió al árbol.
      dplyr::transmute(
        label = .data$tip_label,
        n_especies = .data$n_especies,
        ancho = .data$ancho,
        familia_barra = .data$familia,
        etiqueta = paste0(.data$familia, "\n", .data$n_especies, " especies")
      )

    # geom_fruit decide si hay guías mirando la expresión, no el valor. Pasar
    # `if (...) NULL` cuenta como argumento y dibuja anillos grises por defecto.
    if (guias_barras) {
      p <- p + ggtreeExtra::geom_fruit(
        data = resumen_familias,
        geom = geom_col,
        mapping = ggplot2::aes(
          y = label, x = n_especies, fill = familia_barra, width = ancho
        ),
        orientation = "y",
        offset = 0.06,
        pwidth = pwidth_barras,
        # ggtreeExtra consume `size` (no `linewidth`) al dibujar estas guías.
        grid.params = list(
          color = payne, size = 0.3, alpha = 0.55, linetype = "dotted"
        ),
        axis.params = list(
          axis = "none",
          # El mayor valor es 633 (Hylidae); el dominio fijo hace que los
          # anillos representen 200, 400 y 600 especies de forma consistente.
          limits = c(0, 700),
          nbreak = 4
        )
      )
    } else {
      p <- p + ggtreeExtra::geom_fruit(
        data = resumen_familias,
        geom = geom_col,
        mapping = ggplot2::aes(
          y = label, x = n_especies, fill = familia_barra, width = ancho
        ),
        orientation = "y",
        offset = 0.06,
        pwidth = pwidth_barras
      )
    }

    if (guias_barras) {
      # ggtreeExtra 1.22 descarta linetype en grid.params. La penúltima capa
      # que geom_fruit añade es justo la guía; se ajusta aquí para conservar
      # anillos punteados en lugar de sus líneas sólidas por defecto.
      capa_guias <- length(p$layers) - 1
      p$layers[[capa_guias]]$aes_params$colour <- payne
      p$layers[[capa_guias]]$aes_params$linewidth <- 0.3
      p$layers[[capa_guias]]$aes_params$alpha <- 0.55
      p$layers[[capa_guias]]$aes_params$linetype <- "dotted"

      # ggtree arranca el círculo en las 3 (start -pi/2, sentido horario).
      # El eje vertical positivo, las 12, cae a un cuarto del recorrido angular.
      y_superior <- -0.6 + 0.25 * (max(p$data$y, na.rm = TRUE) + 1.2)
      radios <- sort(unique(
        p$layers[[capa_guias]]$data$x[p$layers[[capa_guias]]$data$x > 1e-8]
      ))
      cortes <- pretty(c(0, resumen_familias$n_especies), n = 4)
      cortes <- cortes[cortes > 0 & cortes <= 700]
      desplazamiento <- p$layers[[capa_guias]]$position$hexpand

      p <- p + ggplot2::geom_label(
        data = data.frame(
          x = radios + desplazamiento,
          y = y_superior,
          etiqueta = cortes
        ),
        ggplot2::aes(x = x, y = y, label = etiqueta),
        inherit.aes = FALSE,
        family = FUENTE_TEXTO,
        size = 2.5,
        color = tinta,
        fill = panel,
        linewidth = 0,
        label.padding = ggplot2::unit(0.12, "lines"),
        hjust = 0.5,
        vjust = 0.5
      )

      # La etiqueta se ancla al extremo de su barra. En el árbol completo el
      # corte son 150 especies; en un subconjunto puede bajar para nombrar
      # a todas las familias que quedaron.
      p <- p + ggtreeExtra::geom_fruit(
        data = dplyr::filter(resumen_familias, .data$n_especies > umbral_etiquetas),
        geom = geom_text,
        mapping = ggplot2::aes(
          y = label, x = n_especies, label = etiqueta
        ),
        orientation = "y",
        offset = 0.06,
        # Es una pista compacta sobre el mismo anillo; reservar un anillo
        # completo para texto reduciría en exceso el árbol dentro de la lámina.
        pwidth = 0.18,
        hjust = 0.5,
        size = 2.4,
        family = FUENTE_TEXTO,
        color = tinta,
        lineheight = 0.85
      )
    }
  }

  p <- p +
    ggplot2::scale_color_manual(
      values = color_arista_por_familia, na.value = retic, guide = "none"
    ) +
    ggplot2::scale_fill_manual(values = color_por_familia, guide = "none") +
    ggplot2::labs(
      title = titulo,
      subtitle = subtitulo,
      caption = paste(source_line, credit_line, sep = "  ·  ")
    ) +
    tema_arbol()

  if (guias_barras) {
    # El margen del tema separa el panel del lienzo. Esta expansión solo
    # recorta el aire entre el círculo y el borde interior del panel.
    p <- p + ggplot2::scale_x_continuous(
      expand = ggplot2::expansion(mult = c(0, 0.02))
    )
  }

  p
}

# --- Exportación -------------------------------------------------------------
# En los formatos verticales el círculo no puede estirarse. Sin este relleno
# ggplot lo centra y deja un hueco igual arriba y abajo del panel.
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
      plot.margin = ggplot2::margin(28, 48, 8, 32)
    )

  patchwork::wrap_plots(
    list(plot_limpio, panel_papel()),
    ncol = 1,
    heights = c(1, espacio_inferior)
  ) +
    patchwork::plot_annotation(
      caption = paste(source_line, credit_line, sep = "  ·  "),
      theme = ggplot2::theme(
        plot.background = ggplot2::element_rect(fill = paper, color = NA),
        plot.caption = ggplot2::element_text(
          family = FUENTE_TEXTO, size = 8, color = tinta_sec, hjust = 0,
          margin = ggplot2::margin(t = 8, b = 4)
        ),
        plot.caption.position = "plot",
        plot.margin = ggplot2::margin(0, 48, 16, 32)
      )
    )
}

# El círculo cabe en un cuadrado del ancho de la lámina. Lo que sobra en
# vertical se reserva abajo para que el título y el árbol queden juntos.
espacio_vertical <- function(ancho_px, alto_px) {
  proporcion <- alto_px / ancho_px
  if (proporcion <= 1.05) return(NULL)
  alto_grafica <- 1.08
  papel <- proporcion - alto_grafica
  if (papel <= 0) return(NULL)
  papel / alto_grafica
}

ruta_lamina <- function(output_path, slug, formato) {
  file.path(output_path, paste0(PREFIJO, "_", slug, "_", formato, ".png"))
}

# Con coord_polar, grid centra un bloque cuadrado en el lienzo ancho. El título
# viaja con ese bloque, así que no llega al borde. Aquí el panel ocupa todo el
# ancho entre título y pie, el fondo claro es ese rectángulo y el árbol se
# dibuja en el cuadrado más grande que cabe dentro, centrado.
tiene_null <- function(unidad) {
  any(grepl("null", as.character(unidad), fixed = TRUE))
}

alinear_panel_rectangular <- function(gt) {
  if (!inherits(gt, "gtable") || !isTRUE(gt$respect)) return(gt)

  lay <- gt$layout
  indice_panel <- which(lay$name == "panel")
  if (length(indice_panel) != 1) return(gt)

  celda <- lay[indice_panel, , drop = FALSE]
  col_izq <- celda$l - 1
  if (col_izq < 1 || !tiene_null(gt$widths[col_izq])) return(gt)

  gt$widths[col_izq] <- grid::unit(0, "cm")
  fila_bajo <- celda$t + 1
  if (fila_bajo <= length(gt$heights) && tiene_null(gt$heights[fila_bajo])) {
    gt$heights[fila_bajo] <- grid::unit(0, "cm")
  }
  gt$respect <- FALSE

  vp <- gt$grobs[[indice_panel]]$vp
  if (inherits(vp, "viewport")) {
    vp$width <- grid::unit(1, "snpc")
    vp$height <- grid::unit(1, "snpc")
    gt$grobs[[indice_panel]]$vp <- vp
  }

  gt <- gtable::gtable_add_grob(
    gt,
    grid::rectGrob(gp = grid::gpar(fill = panel, col = NA)),
    t = celda$t,
    b = celda$b,
    l = celda$l,
    r = celda$r,
    name = "panel-fondo-ancho",
    z = celda$z - 1,
    clip = "off"
  )
  gt
}

# El texto de las etiquetas está en milímetros. En el master y en el 1.91:1
# el círculo es más bajo, así que la misma letra se ve enorme. Ahí se deja al
# 80 % y al 70 % del tamaño original. Título, subtítulo y pie no cambian.
escalar_texto <- function(grob, factor) {
  if (inherits(grob, "gTree") && !is.null(grob$children)) {
    grob$children <- lapply(
      grob$children, escalar_texto, factor = factor
    )
  }
  if (!is.null(grob$gp$fontsize)) {
    grob$gp$fontsize <- grob$gp$fontsize * factor
  }
  grob
}

reducir_leyenda <- function(gt, factor) {
  if (factor >= 0.98) return(gt)
  excluir <- c("title", "subtitle", "caption")
  for (i in seq_along(gt$grobs)) {
    if (gt$layout$name[i] %in% excluir) next
    gt$grobs[[i]] <- escalar_texto(gt$grobs[[i]], factor)
  }
  gt
}

guardar_png <- function(
    plot, nombre, ancho_px, alto_px, resolucion = 96, factor_leyenda = 1
) {
  ragg::agg_png(
    nombre, width = ancho_px, height = alto_px, units = "px",
    res = resolucion, background = paper
  )
  on.exit(grDevices::dev.off(), add = TRUE)
  gt <- if (inherits(plot, "patchwork")) {
    patchwork::patchworkGrob(plot)
  } else {
    ggplot2::ggplotGrob(plot)
  }
  if (ancho_px >= alto_px) gt <- alinear_panel_rectangular(gt)
  gt <- reducir_leyenda(gt, factor_leyenda)
  grid::grid.draw(gt)
}

# Solo este episodio. Duplica los píxeles y la densidad para que el encuadre
# no cambie: un 1080×1080 a 96 ppp pasa a 2160×2160 a 192 ppp.
ESCALA_EXPORTACION <- 2

exportar_laminas <- function(plot, slug, output_path) {
  formatos <- list(
    list(nombre = "master", ancho = 3600, alto = 2400, resolucion = 300, leyenda = 0.80),
    list(nombre = "1x1", ancho = 1080, alto = 1080, resolucion = 96, leyenda = 1),
    list(nombre = "4x5", ancho = 1080, alto = 1350, resolucion = 96, leyenda = 1),
    list(nombre = "9x16", ancho = 1080, alto = 1920, resolucion = 96, leyenda = 1),
    list(nombre = "1.91x1", ancho = 1200, alto = 628, resolucion = 96, leyenda = 0.70)
  )

  for (formato in formatos) {
    ancho <- formato$ancho * ESCALA_EXPORTACION
    alto <- formato$alto * ESCALA_EXPORTACION
    espacio <- espacio_vertical(ancho, alto)
    lamina <- if (is.null(espacio)) plot else componer_con_espacio(plot, espacio)
    guardar_png(
      lamina,
      ruta_lamina(output_path, slug, formato$nombre),
      ancho,
      alto,
      formato$resolucion * ESCALA_EXPORTACION,
      formato$leyenda
    )
  }
}

#-----------------------------------------------------------------------------
# End of visualizaciones.R
#-----------------------------------------------------------------------------
