#-----------------------------------------------------------------------------
# visualizaciones.R
#-----------------------------------------------------------------------------
#   Exploratory UFC plots: advantages, betting vs rankings, red-corner premium.
#-----------------------------------------------------------------------------

crear_visualizaciones <- function(tuesdata) {
  # ==============================================================================
  # 0. PREPARACIÓN COMÚN
  # ==============================================================================

  ultimate <- tuesdata$ultimate_ufc_dataset

  # Odds americanos → probabilidad implícita
  american_to_prob <- function(odds) {
    if_else(odds < 0, -odds / (-odds + 100), 100 / (odds + 100))
  }

  df <- ultimate |>
    mutate(
      red_wins       = winner == "Red",
      p_red_implied  = american_to_prob(r_odds),
      p_blue_implied = american_to_prob(b_odds),
      # Normalizar elimina el vig de la casa
      p_red_norm     = p_red_implied / (p_red_implied + p_blue_implied),
      odds_favor_red = p_red_norm > 0.5
    )

  # Paleta y estilo compartidos
  ROJO  <- "#C0392B"
  AZUL  <- "#2980B9"
  GRIS  <- "gray40"
  FUENTE <- "Fuente: {fightr} · TidyTuesday 2026-07-07"

  tema_base <- theme_minimal(base_size = 13) +
    theme(
      plot.title    = element_text(face = "bold", size = 15),
      plot.subtitle = element_text(color = "gray30", size = 11, margin = margin(b = 12)),
      plot.caption  = element_text(color = "gray50", size = 9),
      panel.grid.minor = element_blank()
    )


  # ==============================================================================
  # 1. ¿QUÉ VENTAJAS PREDICEN GANAR?
  # ==============================================================================
  # Dumbbell plot: punto rojo = win rate cuando Rojo tiene la ventaja,
  #                punto azul = win rate cuando NO la tiene.
  # El gap entre puntos muestra el "efecto" de cada ventaja.
  # ==============================================================================

  # Función auxiliar: tasa de victoria dado un vector lógico de "tiene ventaja"
  win_rate_dado <- function(cond_vec, outcome_vec) {
    tiene <- cond_vec & !is.na(cond_vec) & !is.na(outcome_vec)
    mean(outcome_vec[tiene], na.rm = TRUE)
  }

  # Definir ventajas y sus condiciones
  ventajas <- tibble(
    etiqueta = c(
      "Mayor alcance (reach)",
      "Más alto",
      "Más joven",
      "Más victorias acumuladas",
      "Favorito por odds"
    ),
    cond_si  = list(
      df$reach_dif > 0,
      df$height_dif > 0,
      df$age_dif < 0,      # age_dif < 0 → Rojo más joven
      df$win_dif > 0,
      df$p_red_norm > 0.5
    )
  ) |>
    mutate(
      wr_con    = map_dbl(cond_si, win_rate_dado, outcome_vec = df$red_wins),
      wr_sin    = map_dbl(cond_si, \(cond) win_rate_dado(!cond, df$red_wins)),
      diferencia = wr_con - wr_sin,
      etiqueta  = fct_reorder(etiqueta, diferencia)
    )

  viz1 <- ggplot(ventajas) +
    geom_vline(xintercept = 0.5, linetype = "dashed", color = GRIS, linewidth = 0.7) +
    # Segmento que une los dos puntos
    geom_segment(
      aes(x = wr_sin, xend = wr_con, y = etiqueta, yend = etiqueta),
      color = "gray75", linewidth = 2
    ) +
    # Punto azul: sin ventaja
    geom_point(aes(x = wr_sin, y = etiqueta), color = AZUL, size = 5) +
    # Punto rojo: con ventaja
    geom_point(aes(x = wr_con, y = etiqueta), color = ROJO, size = 5) +
    # Etiquetas de porcentaje
    geom_text(aes(x = wr_con, y = etiqueta,
                  label = percent(wr_con, accuracy = 0.1)),
              color = ROJO, hjust = -0.35, size = 3.5) +
    geom_text(aes(x = wr_sin, y = etiqueta,
                  label = percent(wr_sin, accuracy = 0.1)),
              color = AZUL, hjust = 1.35, size = 3.5) +
    # Leyenda manual en el subtítulo
    annotate("text", x = 0.50, y = 0.4,
             label = "— sin ventaja (azul)     con ventaja (rojo) —",
             color = GRIS, size = 3.2, fontface = "italic") +
    scale_x_continuous(
      labels = percent_format(accuracy = 1),
      limits = c(0.35, 0.75),
      breaks = seq(0.35, 0.75, 0.05)
    ) +
    labs(
      title    = "¿Qué ventajas realmente predicen ganar?",
      subtitle = "Tasa de victoria del luchador ROJO cuando tiene (●) o no tiene (●) cada ventaja",
      x        = "Tasa de victoria del luchador rojo",
      y        = NULL,
      caption  = FUENTE
    ) +
    tema_base

  print(viz1)
  # ggsave("viz1_ventajas.png", viz1, width = 9, height = 5.5, dpi = 180)


  # ==============================================================================
  # 2. ¿LAS APUESTAS SABEN ALGO QUE LOS RANKINGS NO?
  # ==============================================================================
  # Cuatro barras según si odds y récord de victorias coinciden o discrepan.
  # Pregunta clave: cuando discrepan, ¿quién acierta más?
  #
  # Proxy de "ranking":  win_dif > 0 → Rojo tiene más victorias acumuladas.
  # Nota: si el dataset incluye columnas de ranking divisional real
  #       (p.ej. r_Heavyweight, b_Heavyweight), reemplaza win_dif > 0 por
  #       la columna correspondiente a weight_class de cada pelea.
  # ==============================================================================

  df_viz2 <- df |>
    filter(!is.na(red_wins), !is.na(odds_favor_red), !is.na(win_dif)) |>
    mutate(
      record_favor_red = win_dif > 0,
      cuadrante = case_when(
        odds_favor_red  &  record_favor_red  ~ "Acuerdo:\nambos favorecen\na Rojo",
        odds_favor_red  & !record_favor_red  ~ "Discrepan:\nOdds→Rojo\nRécord→Azul",
        !odds_favor_red &  record_favor_red  ~ "Discrepan:\nOdds→Azul\nRécord→Rojo",
        TRUE                                 ~ "Acuerdo:\nambos favorecen\na Azul"
      ),
      cuadrante = factor(cuadrante, levels = c(
        "Acuerdo:\nambos favorecen\na Rojo",
        "Discrepan:\nOdds→Rojo\nRécord→Azul",
        "Discrepan:\nOdds→Azul\nRécord→Rojo",
        "Acuerdo:\nambos favorecen\na Azul"
      )),
      color_cuadrante = case_when(
        cuadrante == "Acuerdo:\nambos favorecen\na Rojo"  ~ ROJO,
        cuadrante == "Acuerdo:\nambos favorecen\na Azul"  ~ AZUL,
        TRUE                                               ~ "gray60"
      )
    ) |>
    group_by(cuadrante, color_cuadrante) |>
    summarise(n = n(), wr = mean(red_wins), .groups = "drop") |>
    mutate(
      etiqueta_n  = paste0("n = ", comma(n)),
      etiqueta_wr = percent(wr, accuracy = 0.1)
    )

  viz2 <- ggplot(df_viz2, aes(x = cuadrante, y = wr, fill = cuadrante)) +
    geom_col(width = 0.55, show.legend = FALSE) +
    geom_hline(yintercept = 0.5, linetype = "dashed", color = GRIS, linewidth = 0.7) +
    # Win rate encima de la barra
    geom_text(aes(label = etiqueta_wr), vjust = -0.6, fontface = "bold", size = 4.5) +
    # n debajo del nombre del eje
    geom_text(aes(y = 0.02, label = etiqueta_n),
              vjust = 0, color = "white", fontface = "italic", size = 3.3) +
    scale_fill_manual(values = c(
      "Acuerdo:\nambos favorecen\na Rojo"  = ROJO,
      "Discrepan:\nOdds→Rojo\nRécord→Azul" = "#D98880",
      "Discrepan:\nOdds→Azul\nRécord→Rojo" = "#7FB3D3",
      "Acuerdo:\nambos favorecen\na Azul"  = AZUL
    )) +
    scale_y_continuous(
      labels = percent_format(accuracy = 1),
      limits = c(0, 0.82),
      breaks = seq(0, 0.8, 0.1)
    ) +
    annotate("text", x = 2.5, y = 0.52,
             label = "50 % (sin ventaja de esquina)",
             color = GRIS, size = 3, hjust = 0, fontface = "italic") +
    labs(
      title    = "¿Las apuestas saben algo que los rankings no?",
      subtitle = "Tasa de victoria del luchador ROJO según si odds y récord coinciden o discrepan",
      x        = NULL,
      y        = "Tasa de victoria del luchador rojo",
      caption  = paste0(FUENTE, "\nProxy de ranking: diferencia en victorias acumuladas (win_dif)")
    ) +
    tema_base

  print(viz2)
  # ggsave("viz2_apuestas_vs_ranking.png", viz2, width = 10, height = 6, dpi = 180)


  # ==============================================================================
  # 3. ¿HAY UNA PRIMA POR ESQUINA ROJA?
  # ==============================================================================
  # Curva de calibración: si el mercado estuviera perfectamente calibrado,
  # la curva roja seguiría la diagonal (y = x).
  # Un desplazamiento sistemático hacia arriba → prima por ser rojo.
  # ==============================================================================

  df_viz3 <- df |>
    filter(!is.na(p_red_norm), !is.na(red_wins)) |>
    mutate(bin = cut(p_red_norm,
                     breaks        = seq(0, 1, by = 0.05),
                     include.lowest = TRUE,
                     right          = FALSE)) |>
    group_by(bin) |>
    summarise(
      n       = n(),
      p_mid   = mean(p_red_norm),
      wr      = mean(red_wins),
      se      = sqrt(wr * (1 - wr) / n),
      .groups = "drop"
    ) |>
    filter(n >= 5)   # descartar bins con muy pocas peleas

  # Calcular la prima promedio (diferencia media entre curva y diagonal)
  prima_promedio <- df_viz3 |>
    summarise(prima = weighted.mean(wr - p_mid, n)) |>
    pull(prima)

  viz3 <- ggplot(df_viz3, aes(x = p_mid, y = wr)) +
    # Diagonal de calibración perfecta
    geom_abline(slope = 1, intercept = 0,
                linetype = "dashed", color = GRIS, linewidth = 0.8) +
    # Banda de confianza 95 %
    geom_ribbon(
      aes(ymin = pmax(0, wr - 1.96 * se),
          ymax = pmin(1, wr + 1.96 * se)),
      fill = ROJO, alpha = 0.15
    ) +
    # Curva observada
    geom_line(color = ROJO, linewidth = 1.3) +
    geom_point(aes(size = n), color = ROJO, alpha = 0.85) +
    # Anotación de la prima promedio
    annotate("text",
             x = 0.72, y = 0.18,
             label = sprintf("Prima promedio\n%+.1f pp",
                             prima_promedio * 100),
             color = ROJO, size = 3.8, fontface = "bold", hjust = 0) +
    annotate("text",
             x = 0.18, y = 0.26,
             label = "Calibración perfecta\n(y = x)",
             color = GRIS, size = 3.2, fontface = "italic", hjust = 0) +
    scale_x_continuous(
      labels = percent_format(accuracy = 1),
      limits = c(0, 1), breaks = seq(0, 1, 0.1)
    ) +
    scale_y_continuous(
      labels = percent_format(accuracy = 1),
      limits = c(0, 1), breaks = seq(0, 1, 0.1)
    ) +
    scale_size_continuous(
      range = c(2, 8),
      name  = "Peleas en el bin"
    ) +
    labs(
      title    = "¿Hay una prima por esquina roja?",
      subtitle = "Si la curva está sobre la diagonal → Rojo gana más de lo que predicen las odds",
      x        = "Probabilidad implícita de Rojo (odds del mercado, normalizada)",
      y        = "Tasa de victoria real de Rojo",
      caption  = FUENTE
    ) +
    tema_base +
    theme(legend.position = "right")

  print(viz3)
  # ggsave("viz3_prima_roja.png", viz3, width = 9, height = 7, dpi = 180)
}

#-----------------------------------------------------------------------------
# End of visualizaciones.R
#-----------------------------------------------------------------------------
