#-----------------------------------------------------------------------------
# visualizaciones.R
#-----------------------------------------------------------------------------
#   Tema Sterling, paleta por área y las cuatro gráficas del episodio.
#-----------------------------------------------------------------------------

# --- Tipografías -------------------------------------------------------------
# Los alias los registra registrar_fuentes_sterling() en fuentes.R.
#   Fraunces (proyecto)        -> título
#   Inter (proyecto)           -> subtítulo
#   JetBrains Mono (proyecto)  -> ejes, valores, pie, etiquetas
FUENTE_TITULO <- "Fraunces (proyecto)"
FUENTE_SUB    <- "Inter (proyecto)"
FUENTE_TEXTO  <- "JetBrains Mono (proyecto)"

# --- Paleta Sterling (canónica, LaMatemaga/sterling) -------------------------
# Los tokens de Tailwind van de 100 a 950. createTailwindSterlingPalette()
# usa el 500 como marca categórica y el 700 como texto de leyenda.
# sterlingRamp() no recorre la escala entera: se queda en 200–800 (siete
# pasos). El 100 casi desaparece sobre el panel y 900–950 apenas se
# separan en luminancia, así que no son saltos de color.

# Tokens de superficie: --sterling-paper (lienzo), surface (panel), text,
# muted (texto secundario), grid y edge (marcas de eje).
paper     <- "#F6F3FB"
panel     <- "#FBF9FE"
tinta     <- "#241A3D"
tinta_sec <- "#5C5178"
retic     <- "#D9D1E6"
borde     <- "#CFC5DE"

# Cada voz, en el orden 200, 300, 400, 500, 600, 700, 800.
RAMPA_200_800 <- list(
  "Oficios y tecnologías" = c(
    "#A6DFCE", "#5EC9AE", "#44B49D", "#25A08D", "#218C7C", "#1E796C", "#1B675D"
  ),
  "Salud" = c(
    "#F9C2B6", "#F29A88", "#ED8976", "#E87864", "#DC6A55", "#BE5C4B", "#A14F42"
  ),
  "Artes" = c(
    "#F2BAE9", "#E88BDD", "#DE73D2", "#D45AC7", "#C653BC", "#AC4AA4", "#93428C"
  ),
  "Ingeniería y arquitectura" = c(
    "#BACBF1", "#86A8E8", "#7195E0", "#5A83D7", "#4F73C6", "#4666AF", "#3D5A99"
  ),
  "Ciencias y cómputo" = c(
    "#D5C3F6", "#B69AF2", "#A889ED", "#9A79E7", "#8E68D8", "#7B59BC", "#684AA1"
  ),
  "Negocios y derecho" = c(
    "#F8DAA3", "#F2C46D", "#EBB454", "#E4A43A", "#D39A32", "#B7822A", "#9B6B23"
  ),
  "Letras y sociedad" = c(
    "#D4DDAA", "#B7C974", "#A6BA62", "#96AB51", "#879347", "#747F3E", "#616C35"
  )
)

# Payne, la voz neutra. El 200 (#D0DCE2) se confunde con la retícula;
# el contexto usa el 300, que sigue siendo claro.
PAYNE_200_800 <- c(
  "#D0DCE2", "#B7C8D1", "#8BA0AB", "#607986", "#536B78", "#475C68", "#3A4E59"
)
PAYNE_CLARO <- PAYNE_200_800[[2]]

# Marca categórica: el paso 500 de cada voz.
color_area <- vapply(RAMPA_200_800, function(pasos) pasos[[4]], character(1))

# Cinco ritmos, de claro a oscuro: 200, 400, 500, 700, 800.
# El 500 es la marca del área y el 700 es el tono de leyenda.
PASOS_RITMO <- c(1L, 3L, 4L, 6L, 7L)

tonos_ritmo <- function(nombre_area, niveles) {
  pasos <- RAMPA_200_800[[nombre_area]][PASOS_RITMO]
  if (length(pasos) != length(niveles)) {
    stop("El ritmo salarial no tiene cinco niveles.", call. = FALSE)
  }
  setNames(pasos, niveles)
}

# --sterling-period: el punto final del título.
color_punto <- "#7C5CE0"

con_punto <- function(titulo, color = color_punto) {
  paste0(titulo, "<span style='color:", color, "'>.</span>")
}

SUPERFICIE_BASE <- list(
  paper = paper, panel = panel, retic = retic, borde = borde,
  tinta = tinta, tinta_sec = tinta_sec
)

con_tono <- function(color, referencia) {
  hcl <- farver::decode_colour(color, to = "hcl")
  hcl[, "h"] <- farver::decode_colour(referencia, to = "hcl")[, "h"]
  farver::encode_colour(hcl, from = "hcl")
}

# Cada token de superficie de Sterling (paper, surface, grid, edge, text,
# muted) conserva su luminancia y croma y toma el tono del 500 del área.
# Así la lámina entera se tiñe del área sin perder el contraste de Sterling:
# el título queda en el text teñido, más oscuro que el 800 de la rampa.
# El punto del título usa el tono de "Queda igual" (400), que es el
# primero de la leyenda que se distingue bien del fondo.
superficie_area <- function(nombre_area) {
  rampa <- RAMPA_200_800[[nombre_area]]
  superficie <- lapply(SUPERFICIE_BASE, con_tono, referencia = rampa[[4]])
  superficie$punto <- rampa[[PASOS_RITMO[[2]]]]
  superficie
}

# --- Temas -------------------------------------------------------------------
# Título, subtítulo y pie son cajas de ggtext: hacen salto de línea al ancho
# de cada formato (el mismo texto cabe en 9x16 y en 1.91x1) y leen HTML
# para el punto de color. Con position = "plot" se alinean con el borde de
# la lámina y no con el panel, que se mueve según el eje y.
tema_titulos <- function(superficie = SUPERFICIE_BASE) {
  ggplot2::theme(
    plot.background  = ggplot2::element_rect(fill = superficie$paper, color = NA),
    panel.background = ggplot2::element_rect(fill = superficie$panel, color = NA),
    plot.title = ggtext::element_textbox_simple(
      family = FUENTE_TITULO, size = 22, face = "bold", color = superficie$tinta,
      lineheight = 1.1, halign = 0,
      padding = ggplot2::unit(c(0, 0, 0, 0), "pt"),
      margin = ggplot2::margin(t = 8, b = 10)
    ),
    plot.subtitle = ggtext::element_textbox_simple(
      family = FUENTE_SUB, size = 11, color = superficie$tinta_sec,
      lineheight = 1.35, halign = 0,
      padding = ggplot2::unit(c(0, 0, 0, 0), "pt"),
      margin = ggplot2::margin(t = 4, b = 26)
    ),
    plot.caption = ggtext::element_textbox_simple(
      family = FUENTE_TEXTO, size = 8, color = superficie$tinta_sec,
      lineheight = 1.25, halign = 0,
      padding = ggplot2::unit(c(0, 0, 0, 0), "pt"),
      margin = ggplot2::margin(t = 20, b = 4)
    ),
    plot.title.position   = "plot",
    plot.caption.position = "plot",
    plot.margin = do.call(ggplot2::margin, as.list(MARGEN_LAMINA))
  )
}

# En puntos. componer_diapositiva() también lo usa para alinear sus columnas.
MARGEN_LAMINA <- c(t = 34, r = 32, b = 22, l = 32)

# grilla = "x" es para barras horizontales: solo quedan las líneas
# verticales, que son las que se leen contra el largo de la barra.
tema_sterling <- function(grilla = "y", superficie = SUPERFICIE_BASE) {
  retic <- superficie$retic
  borde <- superficie$borde
  tinta <- superficie$tinta
  tinta_sec <- superficie$tinta_sec
  t <- ggplot2::theme_minimal(base_family = FUENTE_TEXTO) +
    tema_titulos(superficie) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      axis.title = ggplot2::element_text(
        family = FUENTE_TEXTO, size = 10, color = tinta,
        margin = ggplot2::margin(t = 12, r = 12)
      ),
      axis.text  = ggplot2::element_text(family = FUENTE_TEXTO, size = 9, color = tinta_sec),
      axis.ticks = ggplot2::element_line(color = borde),
      legend.title = ggplot2::element_text(family = FUENTE_TEXTO, size = 10, color = tinta),
      legend.text  = ggplot2::element_text(family = FUENTE_TEXTO, size = 9, color = tinta_sec)
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

# El AIOE ya viene en z contra todas las ocupaciones del índice, así que
# su 0 no es el promedio de estas carreras (aquí la media es 0.75). El
# salario se estandariza en main.R con scale(), entre las 285 carreras.
# El cruce en el origen es el eje. Las líneas del panel (x = -4, y = -4)
# no se pintan: el axis.line de ggplot cae sobre el límite de la escala.
# Las del origen van en negro, más oscuras que la tinta, para que lean
# como ejes y no como retícula.
# Los límites ±4 son simétricos para que el origen quede al centro del
# panel cuadrado y los cuatro cuadrantes midan lo mismo.
# scale_size_area(): ver la nota de Flannery en main.R.
con_ejes_origen <- function(p) {
  p +
    ggplot2::geom_hline(
      yintercept = 0, color = "black", linewidth = 0.4, inherit.aes = FALSE
    ) +
    ggplot2::geom_vline(
      xintercept = 0, color = "black", linewidth = 0.4, inherit.aes = FALSE
    ) +
    ggplot2::scale_size_area(guide = "none") +
    ggplot2::scale_x_continuous(
      limits = c(-4, 4), breaks = seq(-4, 4, by = 0.5),
      labels = solo_enteros, expand = c(0, 0)
    ) +
    ggplot2::scale_y_continuous(
      limits = c(-4, 4), breaks = seq(-4, 4, by = 0.5),
      labels = solo_enteros, expand = c(0, 0)
    )
}

# La retícula va cada 0.5, pero rotular cada línea ("-3.5", "-3.0"...)
# satura el eje. Solo los enteros llevan número.
solo_enteros <- function(x) {
  ifelse(abs(x - round(x)) < 1e-9, sprintf("%.0f", x), "")
}

# --- Casos que se señalan en los siete planos --------------------------------
# Las llaves de tx$etiqueta son las mismas en ambos idiomas, así que la
# selección de carreras no depende del idioma.
CARRERAS_CON_MOTIVO <- names(TEXTOS$es$etiqueta)

MIN_ETIQUETAS <- 6

# Respaldo para una carrera que entra por relleno sin etiqueta propia: el
# nombre original hasta la primera coma, sin traducir.
nombre_etiqueta <- function(campo, tx) {
  corto <- sub(",.*", "", campo)
  ifelse(campo %in% names(tx$etiqueta), unname(tx$etiqueta[campo]), corto)
}

# Si la lista no llega a seis en un área, se completa con las carreras
# de más egresados.
casos_a_senalar <- function(parte) {
  con_dato <- parte %>%
    filter(!is.na(.data$salary_log_dollar_change), !is.na(.data$salario_z))
  elegidas <- con_dato %>%
    filter(
      .data$field_of_study %in% CARRERAS_CON_MOTIVO |
        .data$ritmo_salarial == "Pierde poder adquisitivo"
    )
  faltan <- MIN_ETIQUETAS - nrow(elegidas)
  if (faltan > 0) {
    elegidas <- bind_rows(
      elegidas,
      con_dato %>%
        anti_join(elegidas, by = "field_of_study") %>%
        slice_max(.data$n_graduates, n = faltan, with_ties = FALSE)
    )
  }
  elegidas
}

# Las etiquetas van en una columna fuera del racimo, a la derecha (o a la
# izquierda si el punto cae del otro lado del eje). Las alturas son
# ranuras fijas que saltan la franja del eje y = 0. Se reparten en el
# mismo orden vertical que los puntos, así que las líneas no se cruzan.
# Las columnas en ±1.75 quedan justo fuera del racimo de puntos, y la
# separación de 0.45 deja aire entre líneas aun en el panel del 1.91x1.
RANURAS_ETIQUETA <- c(seq(3.5, 0.35, by = -0.45), seq(-0.35, -3.5, by = -0.45))
X_COLUMNA_DERECHA <- 1.75
X_COLUMNA_IZQUIERDA <- -1.75

# y viene de mayor a menor. Programación dinámica: la etiqueta i ocupa una
# ranura más baja que la i - 1, y la suma de desplazamientos es mínima.
asignar_ranuras <- function(y, ranuras = RANURAS_ETIQUETA) {
  n <- length(y)
  m <- length(ranuras)
  if (n > m) {
    stop("Hay más etiquetas que ranuras en el plano.", call. = FALSE)
  }
  costo <- matrix(Inf, n, m)
  previo <- matrix(NA_integer_, n, m)
  costo[1, ] <- abs(y[1] - ranuras)
  for (i in seq_len(n)[-1]) {
    for (j in i:m) {
      k <- which.min(costo[i - 1, seq_len(j - 1)])
      costo[i, j] <- costo[i - 1, k] + abs(y[i] - ranuras[j])
      previo[i, j] <- k
    }
  }
  salida <- numeric(n)
  j <- which.min(costo[n, ])
  for (i in n:1) {
    salida[i] <- ranuras[j]
    if (i > 1) j <- previo[i, j]
  }
  salida
}

ubicar_llamadas <- function(puntos) {
  if (nrow(puntos) == 0) {
    return(puntos)
  }
  puntos %>%
    mutate(lado = if_else(.data$ai_exposure < 0, "izq", "der")) %>%
    group_by(.data$lado) %>%
    arrange(desc(.data$salario_z), .by_group = TRUE) %>%
    mutate(
      y_etq = asignar_ranuras(.data$salario_z),
      x_etq = if_else(.data$lado == "der", X_COLUMNA_DERECHA, X_COLUMNA_IZQUIERDA),
      hjust = if_else(.data$lado == "der", 0, 1),
      x_texto = .data$x_etq + if_else(.data$hjust == 0, 0.08, -0.08)
    ) %>%
    ungroup()
}

# --- 1. Densidad de exposición por área --------------------------------------
# Cada cresta es la densidad de las ocupaciones enlazadas a las carreras
# del área, no de las carreras: muestra a qué empleos lleva. Mismo rango -4..4 que los planos para que la exposición
# se lea igual en todas las láminas. Sin contorno: las crestas se enciman y
# el borde las vuelve un enredo de líneas.
grafica_exposicion <- function(datos, idioma = "es") {
  tx <- TEXTOS[[idioma]]
  ggplot2::ggplot(datos, ggplot2::aes(x = .data$ai_exposure, y = .data$area, fill = .data$area)) +
    ggridges::geom_density_ridges(color = NA, alpha = 0.9) +
    ggplot2::geom_vline(xintercept = 0, color = "black", linewidth = 0.4) +
    ggplot2::scale_fill_manual(values = color_area, drop = FALSE) +
    ggplot2::scale_x_continuous(
      limits = c(-4, 4), breaks = seq(-4, 4, by = 1), expand = c(0, 0)
    ) +
    ggplot2::scale_y_discrete(labels = tx$nombre_area) +
    ggplot2::labs(
      title = con_punto(tx$exposicion_titulo),
      subtitle = tx$exposicion_subtitulo,
      x = tx$eje_x,
      y = NULL,
      caption = pie_fuente(tx)
    ) +
    tema_sterling() +
    ggplot2::theme(legend.position = "none")
}

# --- 2. Egresados por área ---------------------------------------------------
# Barras horizontales: los nombres de área se leen completos sin girarlos.
grafica_egresados <- function(datos, idioma = "es") {
  tx <- TEXTOS[[idioma]]
  ggplot2::ggplot(datos, ggplot2::aes(.data$area, weight = .data$n_graduates, fill = .data$area)) +
    ggplot2::geom_bar() +
    ggplot2::coord_flip() +
    ggplot2::scale_fill_manual(values = color_area, drop = FALSE) +
    ggplot2::scale_x_discrete(labels = tx$nombre_area) +
    ggplot2::scale_y_continuous(labels = scales::label_number(big.mark = tx$separador_miles)) +
    ggplot2::labs(
      title = con_punto(tx$egresados_titulo),
      subtitle = tx$egresados_subtitulo,
      x = NULL,
      y = tx$egresados_eje,
      caption = pie_fuente(tx)
    ) +
    tema_sterling(grilla = "x") +
    ggplot2::theme(legend.position = "none")
}

# --- 3. Cuadrantes -----------------------------------------------------------
# Exposición como temperatura: cerca de la IA es frío (pantalla), lejos es
# cálido (lo material). Salario de entrada como profundidad: arranque alto
# es un tinte más denso. Ningún tono es verde ni rojo para no leerse como
# bueno o malo.
# Fondo: el 200 de cada voz al 30 %, apenas teñido para que los puntos de
# área sigan mandando. Rótulo: el 700, salvo el ámbar, que en el 700 queda
# en 3:1 contra su fondo (los otros tres van de 3.7:1 a 6:1); el 800 sube
# a 4:1. Los rótulos describen la posición en los ejes, sin juzgarla.
CUADRANTES <- tibble::tibble(
  xmin = c(-4, 0, -4, 0),
  xmax = c(0, 4, 0, 4),
  ymin = c(0, 0, -4, -4),
  ymax = c(4, 4, 0, 0),
  x = c(-3.85, 3.85, -3.85, 3.85),
  y = c(3.85, 3.85, -3.85, -3.85),
  hjust = c(0, 1, 0, 1),
  vjust = c(1, 1, 0, 0),
  fondo = c(
    RAMPA_200_800[["Salud"]][[1]],
    RAMPA_200_800[["Ingeniería y arquitectura"]][[1]],
    RAMPA_200_800[["Negocios y derecho"]][[1]],
    PAYNE_200_800[[1]]
  ),
  opacidad = c(0.3, 0.3, 0.3, 0.3),
  tono = c(
    RAMPA_200_800[["Salud"]][[6]],
    RAMPA_200_800[["Ingeniería y arquitectura"]][[6]],
    RAMPA_200_800[["Negocios y derecho"]][[7]],
    PAYNE_200_800[[6]]
  )
)

grafica_cuadrantes <- function(datos, idioma = "es") {
  tx <- TEXTOS[[idioma]]
  con_ejes_origen(
    ggplot2::ggplot(
      datos,
      ggplot2::aes(
        .data$ai_exposure,
        as.numeric(.data$salary_1y_median_norm),
        size = .data$salary_log_dollar_change
      )
    ) +
      ggplot2::annotate(
        "rect",
        xmin = CUADRANTES$xmin, xmax = CUADRANTES$xmax,
        ymin = CUADRANTES$ymin, ymax = CUADRANTES$ymax,
        fill = CUADRANTES$fondo, alpha = CUADRANTES$opacidad
      ) +
      ggplot2::annotate(
        "text",
        x = CUADRANTES$x, y = CUADRANTES$y, label = tx$cuadrantes_etiquetas,
        hjust = CUADRANTES$hjust, vjust = CUADRANTES$vjust,
        color = CUADRANTES$tono, family = FUENTE_TITULO, fontface = "bold",
        size = 3.4, lineheight = 1.05
      ) +
      # shape 16: círculo sólido sin contorno. alpha < 1 deja ver los
      # puntos encimados del racimo.
      ggplot2::geom_point(ggplot2::aes(color = .data$area), shape = 16, alpha = 0.9)
  ) +
    ggplot2::scale_color_manual(
      values = color_area,
      labels = tx$nombre_area,
      drop = FALSE,
      name = tx$cuadrantes_leyenda,
      guide = ggplot2::guide_legend(override.aes = list(size = 3.5, alpha = 1))
    ) +
    ggplot2::labs(
      title = con_punto(tx$cuadrantes_titulo),
      subtitle = paste(tx$cuadrantes_subtitulo, tx$tamano, tx$ejes),
      x = tx$eje_x,
      y = tx$eje_y,
      caption = pie_fuente(tx)
    ) +
    tema_sterling() +
    ggplot2::theme(axis.line = ggplot2::element_blank(), aspect.ratio = 1)
}

# --- 4. Un plano por área ----------------------------------------------------
# Copia del plano de cuadrantes: mismos límites, mismos tamaños y todos
# los puntos. El área en foco recorre su rampa; el resto queda en Payne
# claro para situar los datos. El contexto se dibuja primero para que el
# foco quede encima. El subtítulo abre con la lectura del área (textos.R)
# y después explica cómo leer el plano.
grafica_area <- function(datos, nombre_area, idioma = "es", inflacion = INFLACION_3A) {
  tx <- TEXTOS[[idioma]]
  niveles <- levels(datos$ritmo_salarial)
  plano <- datos %>%
    mutate(salario_z = as.numeric(.data$salary_1y_median_norm))
  foco <- plano %>% filter(.data$area == nombre_area)
  contexto <- plano %>% filter(.data$area != nombre_area)
  llamadas <- ubicar_llamadas(casos_a_senalar(foco)) %>%
    mutate(etiqueta = nombre_etiqueta(.data$field_of_study, tx))

  conteo <- table(factor(foco$ritmo_salarial, levels = niveles, ordered = FALSE))
  etiquetas_ritmo <- paste0(tx$ritmo[niveles], " (", as.integer(conteo[niveles]), ")")
  superficie <- superficie_area(nombre_area)

  con_ejes_origen(
    ggplot2::ggplot(
      plano,
      ggplot2::aes(
        .data$ai_exposure,
        .data$salario_z,
        size = .data$salary_log_dollar_change
      )
    ) +
      ggplot2::geom_point(
        data = contexto,
        color = PAYNE_CLARO,
        shape = 16,
        alpha = 0.9
      ) +
      ggplot2::geom_point(
        data = foco,
        ggplot2::aes(color = .data$ritmo_salarial),
        shape = 16,
        alpha = 0.95,
        show.legend = TRUE
      )
  ) +
    ggplot2::geom_segment(
      data = llamadas,
      ggplot2::aes(
        x = .data$ai_exposure,
        y = .data$salario_z,
        xend = .data$x_etq,
        yend = .data$y_etq
      ),
      inherit.aes = FALSE,
      color = superficie$tinta_sec,
      linewidth = 0.3
    ) +
    ggplot2::geom_text(
      data = llamadas,
      ggplot2::aes(
        x = .data$x_texto,
        y = .data$y_etq,
        label = .data$etiqueta,
        hjust = .data$hjust
      ),
      inherit.aes = FALSE,
      family = FUENTE_TEXTO,
      size = 2.7,
      vjust = 0.5,
      color = superficie$tinta
    ) +
    ggplot2::scale_color_manual(
      values = tonos_ritmo(nombre_area, niveles),
      breaks = niveles,
      labels = etiquetas_ritmo,
      drop = FALSE,
      na.translate = FALSE,
      name = tx$area_leyenda,
      guide = ggplot2::guide_legend(override.aes = list(size = 3.5, alpha = 1))
    ) +
    ggplot2::labs(
      title = con_punto(tx$nombre_area[[nombre_area]], superficie$punto),
      subtitle = paste0(
        tx$insight[[nombre_area]], "<br><br>",
        paste(tx$area_guia(inflacion), tx$tamano, tx$ejes)
      ),
      x = tx$eje_x,
      y = tx$eje_y,
      caption = pie_fuente(tx)
    ) +
    ggplot2::coord_cartesian(clip = "off") +
    tema_sterling(superficie = superficie) +
    ggplot2::theme(
      axis.line = ggplot2::element_blank(),
      aspect.ratio = 1,
      legend.box.spacing = ESPACIO_LEYENDA_AREA
    )
}

# Las etiquetas largas ("Ciencias de la computación") rebasan x = 4 y
# ocupan este hueco antes de la leyenda.
ESPACIO_LEYENDA_AREA <- grid::unit(0.7, "in")

# --- Exportación -------------------------------------------------------------
PREFIJO <- "profesiones"

# Duplica los píxeles y la densidad para que el encuadre no cambie: un
# 1080×1080 a 96 ppp pasa a 2160×2160 a 192 ppp.
ESCALA_EXPORTACION <- 2

# Los formatos de redes se definen en píxeles (Instagram muestra a 1080 de
# ancho). A 96 ppp un punto tipográfico ocupa lo mismo que en CSS
# (1 pt = 1.33 px), y los tamaños del tema valen igual en los cuatro.
# El master es de 12 × 8 pulgadas a 300 ppp, para presentación o impresión.
FORMATOS_LAMINA <- list(
  list(nombre = "master", ancho = 3600, alto = 2400, resolucion = 300),
  list(nombre = "1x1",    ancho = 1080, alto = 1080, resolucion = 96),
  list(nombre = "4x5",    ancho = 1080, alto = 1350, resolucion = 96),
  list(nombre = "9x16",   ancho = 1080, alto = 1920, resolucion = 96),
  list(nombre = "1.91x1", ancho = 1200, alto = 628,  resolucion = 96)
)

# El sufijo de idioma evita confundir las dos versiones fuera de su carpeta,
# por ejemplo en el carrete del teléfono.
ruta_lamina <- function(output_path, slug, formato, idioma) {
  carpeta <- file.path(output_path, idioma, formato)
  dir.create(carpeta, showWarnings = FALSE, recursive = TRUE)
  file.path(carpeta, paste0(PREFIJO, "_", slug, "_", formato, "_", idioma, ".png"))
}

# Con aspect.ratio, grid centra la tabla entera en el lienzo y el título
# se va con ella. Aquí el panel recibe el cuadrado más grande que cabe, en
# pulgadas. Lo que sobra a lo ancho se reparte a ambos lados de la gráfica
# y lo que sobra a lo alto queda arriba del pie.
# La holgura, en pulgadas, es un respiro extra entre el panel y el pie.
HOLGURA_PANEL <- 0.1

cuadrar_panel <- function(gt, ancho_in, alto_in) {
  i <- which(gt$layout$name == "panel")
  fila <- gt$layout$t[i]
  col <- gt$layout$l[i]
  fijo_ancho <- grid::convertWidth(sum(gt$widths[-col]), "in", valueOnly = TRUE)
  fijo_alto <- grid::convertHeight(sum(gt$heights[-fila]), "in", valueOnly = TRUE)
  lado <- min(ancho_in - fijo_ancho, alto_in - fijo_alto) - HOLGURA_PANEL

  gt$widths[col] <- grid::unit(lado, "in")
  gt$heights[fila] <- grid::unit(lado, "in")
  gt$respect <- FALSE

  # Centra el panel, no el bloque: el eje y ocupa ancho a la izquierda.
  n <- ncol(gt)
  izquierda <- grid::convertWidth(sum(gt$widths[2:(col - 1)]), "in", valueOnly = TRUE)
  derecha <- grid::convertWidth(sum(gt$widths[(col + 1):(n - 1)]), "in", valueOnly = TRUE)
  sobra <- ancho_in - fijo_ancho - lado
  relleno_izq <- max(0, (sobra + derecha - izquierda) / 2)
  relleno_der <- max(0, sobra - relleno_izq)
  gt <- gtable::gtable_add_cols(gt, grid::unit(relleno_der, "in"), pos = n - 1)
  gt <- gtable::gtable_add_cols(gt, grid::unit(relleno_izq, "in"), pos = 1)
  textos <- gt$layout$name %in% c("title", "subtitle", "caption")
  gt$layout$l[textos] <- 2
  gt$layout$r[textos] <- ncol(gt) - 1

  fila_pie <- gt$layout$t[gt$layout$name == "caption"]
  gt <- gtable::gtable_add_rows(gt, grid::unit(1, "null"), pos = fila_pie - 1)

  gt
}

# En formatos verticales y 1x1 la leyenda a la derecha le quita ancho al
# panel y lo descentra. Abajo, en tres columnas, cabe en 1080 px.
leyenda_abajo <- function(plot) {
  plot +
    ggplot2::guides(
      colour = ggplot2::guide_legend(
        ncol = 3, override.aes = list(size = 3.5, alpha = 1)
      )
    ) +
    ggplot2::theme(
      legend.position = "bottom",
      legend.justification = "left",
      legend.title.position = "top",
      legend.box.spacing = grid::unit(14, "pt")
    )
}

# En master (1.5) y 1.91x1 el cuadrado a todo lo alto deja una franja
# libre a la izquierda: ahí van título, subtítulo, leyenda y pie, como en
# una diapositiva. El corte en 1.3 separa esos dos del 1x1 y los
# verticales. La separación entre columnas va en pulgadas.
PROPORCION_DIAPOSITIVA <- 1.3
SEPARACION_COLUMNAS <- 0.5

grob_de <- function(gt, nombre) {
  gt$grobs[[which(gt$layout$name == nombre)]]
}

componer_diapositiva <- function(plot, ancho_in, alto_in) {
  margen <- MARGEN_LAMINA / 72
  alto_util <- alto_in - margen[["t"]] - margen[["b"]]

  completo <- ggplot2::ggplotGrob(
    plot + ggplot2::theme(legend.margin = ggplot2::margin(0, 0, 0, 0))
  )
  titulo <- grob_de(completo, "title")
  subtitulo <- grob_de(completo, "subtitle")
  pie <- grob_de(completo, "caption")
  leyenda <- grob_de(completo, "guide-box-right")

  grafica <- ggplot2::ggplotGrob(
    plot +
      ggplot2::labs(title = NULL, subtitle = NULL, caption = NULL) +
      ggplot2::theme(
        legend.position = "none",
        plot.margin = ggplot2::margin(0, 0, 0, 0)
      )
  )
  i <- which(grafica$layout$name == "panel")
  fila <- grafica$layout$t[i]
  col <- grafica$layout$l[i]
  fijo_ancho <- grid::convertWidth(sum(grafica$widths[-col]), "in", valueOnly = TRUE)
  fijo_alto <- grid::convertHeight(sum(grafica$heights[-fila]), "in", valueOnly = TRUE)
  lado <- alto_util - fijo_alto - HOLGURA_PANEL
  grafica$widths[col] <- grid::unit(lado, "in")
  grafica$heights[fila] <- grid::unit(lado, "in")
  grafica$respect <- FALSE
  ancho_grafica <- lado + fijo_ancho
  ancho_columna <- ancho_in - margen[["l"]] - margen[["r"]] -
    ancho_grafica - SEPARACION_COLUMNAS

  pulgadas <- function(x) grid::unit(x, "in")

  grid::grid.newpage()
  grid::pushViewport(grid::viewport(
    x = pulgadas(ancho_in - margen[["r"]]), y = pulgadas(margen[["b"]]),
    width = pulgadas(ancho_grafica), height = pulgadas(alto_util),
    just = c("right", "bottom")
  ))
  grid::grid.draw(grafica)
  grid::popViewport()

  # Las cajas de texto miden su alto con el ancho del viewport vigente.
  grid::pushViewport(grid::viewport(
    x = pulgadas(margen[["l"]]), y = pulgadas(margen[["b"]]),
    width = pulgadas(ancho_columna), height = pulgadas(alto_util),
    just = c("left", "bottom")
  ))
  alto_de <- function(g) grid::convertHeight(grid::grobHeight(g), "in", valueOnly = TRUE)
  ancho_de <- function(g) grid::convertWidth(grid::grobWidth(g), "in", valueOnly = TRUE)
  dibujar_en <- function(g, y, alto, ancho = 1, unidad_ancho = "npc", just = "top") {
    grid::pushViewport(grid::viewport(
      x = 0, y = pulgadas(y), width = grid::unit(ancho, unidad_ancho),
      height = pulgadas(alto), just = c("left", just)
    ))
    grid::grid.draw(g)
    grid::popViewport()
  }

  y <- alto_util
  for (g in list(titulo, subtitulo)) {
    h <- alto_de(g)
    dibujar_en(g, y, h)
    y <- y - h
  }
  dibujar_en(leyenda, y, alto_de(leyenda), ancho_de(leyenda), "in")
  dibujar_en(pie, 0, alto_de(pie), just = "bottom")
  grid::popViewport()
}

# La diapositiva deja lienzo sin plot.background entre columnas: ese hueco
# toma el fondo del dispositivo.
fondo_de <- function(plot) {
  ggplot2::calc_element("plot.background", ggplot2::complete_theme(plot$theme))$fill
}

# ragg lee las familias registradas con systemfonts. El dispositivo de
# Windows no, y por eso print() en el panel avisa que no encuentra la fuente.
guardar_png <- function(plot, nombre, ancho_px, alto_px, resolucion = 96, cuadrado = FALSE) {
  ragg::agg_png(
    nombre, width = ancho_px, height = alto_px, units = "px",
    res = resolucion, background = fondo_de(plot)
  )
  on.exit(grDevices::dev.off(), add = TRUE)
  if (!cuadrado) {
    print(plot)
    return(invisible(nombre))
  }
  if (ancho_px / alto_px > PROPORCION_DIAPOSITIVA) {
    componer_diapositiva(plot, ancho_px / resolucion, alto_px / resolucion)
    return(invisible(nombre))
  }

  # Con la leyenda abajo el panel puede quedar centrado a lo ancho.
  grid::grid.newpage()
  grid::grid.draw(cuadrar_panel(
    ggplot2::ggplotGrob(leyenda_abajo(plot)),
    ancho_px / resolucion, alto_px / resolucion
  ))
  invisible(nombre)
}

exportar_laminas <- function(plot, slug, output_path, idioma, cuadrado = FALSE) {
  for (formato in FORMATOS_LAMINA) {
    guardar_png(
      plot,
      ruta_lamina(output_path, slug, formato$nombre, idioma),
      formato$ancho * ESCALA_EXPORTACION,
      formato$alto * ESCALA_EXPORTACION,
      formato$resolucion * ESCALA_EXPORTACION,
      cuadrado = cuadrado
    )
  }
}
