#-----------------------------------------------------------------------------
# data_quality.R
#-----------------------------------------------------------------------------
#   Interactive data-quality audit for the TidyTuesday UFC datasets.
#-----------------------------------------------------------------------------

evaluar_calidad_datos <- function(tuesdata) {
  ufc_athletes <- tuesdata$ufc_athletes
  ufc_fights   <- tuesdata$ufc_fights
  ufc_rankings <- tuesdata$ufc_rankings_dataset
  ufcstats     <- tuesdata$ufcstats_data
  ultimate     <- tuesdata$ultimate_ufc_dataset

  # ==============================================================================
  # UTILIDADES
  # ==============================================================================

  separador <- function(titulo) {
    cat("\n", strrep("=", 70), "\n")
    cat(" ", toupper(titulo), "\n")
    cat(strrep("=", 70), "\n\n")
  }

  subseccion <- function(titulo) {
    cat("\n---", titulo, "---\n")
  }

  pct <- function(n, total) sprintf("%d  (%.1f%%)", n, 100 * n / total)


  # ==============================================================================
  # 1. DIMENSIONES Y TIPOS DE COLUMNA
  # ==============================================================================

  separador("1. Dimensiones y tipos")

  datasets <- list(
    ufc_athletes = ufc_athletes,
    ufc_fights   = ufc_fights,
    ufc_rankings = ufc_rankings,
    ufcstats     = ufcstats,
    ultimate     = ultimate
  )

  imap(datasets, function(df, nombre) {
    cat(sprintf("\n[%s]  %d filas × %d columnas\n", nombre, nrow(df), ncol(df)))
    print(map_chr(df, \(x) class(x)[1]))
  })

  # ¿Qué hacer? Verifica que los tipos coincidan con el diccionario de datos.
  # Puntos de atención identificados:
  #   - ufc_athletes$wins / losses / draws  →  character  (¿deberían ser numeric?)
  #   - ufc_rankings$date                   →  character  (¿debería ser Date?)
  #   - ufc_fights$time / ufc_athletes$average_fight_time → Period (lubridate)
  #   - ultimate$date                       →  character  (¿debería ser Date?)


  # ==============================================================================
  # 2. VALORES FALTANTES (NA)
  # ==============================================================================

  separador("2. Valores faltantes por columna")

  resumen_nas <- function(df, nombre) {
    cat(sprintf("\n[%s]\n", nombre))
    nas <- df |>
      summarise(across(everything(), \(x) sum(is.na(x)))) |>
      pivot_longer(everything(), names_to = "variable", values_to = "n_na") |>
      mutate(pct_na = round(100 * n_na / nrow(df), 1)) |>
      filter(n_na > 0) |>
      arrange(desc(pct_na))

    if (nrow(nas) == 0) {
      cat("  Sin NAs.\n")
    } else {
      print(nas, n = Inf)
    }
  }

  walk2(datasets, names(datasets), resumen_nas)

  # ¿Qué hacer?
  #   - Variables con >50% NA: ¿las excluyes o las conservas con cautela?
  #   - Variables con <5%  NA: ¿imputas, eliminas filas o dejas como está?
  #   - Columnas como nickname / fighting_style / trains_at son "where available"
  #     según el diccionario → NAs esperados. ¿Necesitas bandera booleana?


  # ==============================================================================
  # 3. DUPLICADOS
  # ==============================================================================

  separador("3. Duplicados")

  # --- 3a. Filas completamente duplicadas ---
  walk2(datasets, names(datasets), function(df, nombre) {
    n_dup <- sum(duplicated(df))
    cat(sprintf("[%s]  filas duplicadas: %s\n", nombre, pct(n_dup, nrow(df))))
  })

  # --- 3b. Duplicados por clave natural esperada ---
  subseccion("Claves naturales")

  # ufc_athletes: ¿un atleta aparece más de una vez?
  ufc_athletes |>
    count(name, sort = TRUE) |>
    filter(n > 1) |>
    { \(x) cat(sprintf("[ufc_athletes] nombres repetidos: %d\n", nrow(x))); print(head(x, 15)) }()

  # ufc_fights: ¿una pelea duplicada por fight_url?
  ufc_fights |>
    count(fight_url, sort = TRUE) |>
    filter(n > 1) |>
    { \(x) cat(sprintf("[ufc_fights] fight_url repetidos: %d\n", nrow(x))); print(head(x, 10)) }()

  # ufc_rankings: ¿mismo luchador, misma fecha, mismo peso dos veces?
  ufc_rankings |>
    count(date, weightclass, fighter, sort = TRUE) |>
    filter(n > 1) |>
    { \(x) cat(sprintf("[ufc_rankings] combinaciones fecha+peso+luchador duplicadas: %d\n", nrow(x))); print(head(x, 10)) }()

  # ufcstats: ¿nombre repetido?
  ufcstats |>
    count(name, sort = TRUE) |>
    filter(n > 1) |>
    { \(x) cat(sprintf("[ufcstats] nombres repetidos: %d\n", nrow(x))); print(head(x, 10)) }()

  # ¿Qué hacer?
  #   - Nombres repetidos en athletes/ufcstats pueden ser homónimos o datos sucios.
  #   - ¿Eliminas duplicados exactos? ¿Agregas un ID único?


  # ==============================================================================
  # 4. RANGOS Y VALORES FUERA DE LO ESPERADO
  # ==============================================================================

  separador("4. Rangos numéricos")

  # --- 4a. ufc_athletes ---
  subseccion("ufc_athletes — atributos físicos")

  ufc_athletes |>
    select(age, height, weight, reach, leg_reach) |>
    pivot_longer(-name) |>
    group_by(name = name_col) |>
    summarise(
      .groups = "drop",
      n_valid = sum(!is.na(value)),
      min     = min(value, na.rm = TRUE),
      p25     = quantile(value, .25, na.rm = TRUE),
      mediana = median(value, na.rm = TRUE),
      p75     = quantile(value, .75, na.rm = TRUE),
      max     = max(value, na.rm = TRUE)
    )
  # Nota: corrección de variable de agrupación abajo

  ufc_athletes |>
    select(name, age, height, weight, reach, leg_reach) |>
    pivot_longer(everything()) |>
    group_by(name) |>
    summarise(
      n_valid = sum(!is.na(value)),
      min     = min(value, na.rm = TRUE),
      mediana = median(value, na.rm = TRUE),
      max     = max(value, na.rm = TRUE),
      .groups = "drop"
    ) |>
    print()

  # Posibles outliers en atributos físicos
  cat("\nPosibles outliers (altura fuera de 55–85 pulgadas ≈ 4'7\"–7'1\"):\n")
  ufc_athletes |>
    filter(!is.na(height), height < 55 | height > 85) |>
    select(name, weight_class, height)  |>
    print()

  cat("\nPosibles outliers (peso fuera de 90–300 lbs):\n")
  ufc_athletes |>
    filter(!is.na(weight), weight < 90 | weight > 300) |>
    select(name, weight_class, weight) |>
    print()

  # --- 4b. Proporciones: deben estar entre 0 y 1 ---
  subseccion("ufc_athletes — proporciones (esperado: 0–1)")

  props_athletes <- c(
    "sig_str_defense", "takedown_defense",
    "standing_pct", "clinch_percent", "ground_percent",
    "ko_tko_percent", "dec_percent", "sub_percent"
  )

  ufc_athletes |>
    select(name, all_of(props_athletes)) |>
    pivot_longer(-name) |>
    filter(!is.na(value), (value < 0 | value > 1)) |>
    { \(x) {
      cat(sprintf("Filas con proporciones fuera de [0,1]: %d\n", nrow(x)))
      print(x)
    }}()

  # ¿Están expresadas como porcentaje (0–100) en lugar de proporción (0–1)?
  cat("\nRango observado de sig_str_defense:\n")
  summary(ufc_athletes$sig_str_defense)

  # --- 4c. ufcstats — proporciones ---
  subseccion("ufcstats — proporciones (esperado: 0–1)")

  props_stats <- c("str_acc", "str_def", "td_acc", "td_def")

  ufcstats |>
    select(name, all_of(props_stats)) |>
    pivot_longer(-name) |>
    filter(!is.na(value), (value < 0 | value > 1)) |>
    { \(x) {
      cat(sprintf("Filas con proporciones fuera de [0,1]: %d\n", nrow(x)))
      print(x)
    }}()

  # --- 4d. ufc_fights — rondas ---
  subseccion("ufc_fights — rondas (esperado: 1–5)")

  ufc_fights |>
    count(round) |>
    print()

  cat("\nPeleas con round fuera de 1–5:\n")
  ufc_fights |>
    filter(!is.na(round), (round < 1 | round > 5)) |>
    select(event_name, f1_name, f2_name, round) |>
    print()

  # --- 4e. ufc_rankings — rank ---
  subseccion("ufc_rankings — rank (esperado: 0=campeón, 1–15)")

  ufc_rankings |>
    count(rank) |>
    arrange(rank) |>
    print()

  cat("\nRanks fuera de 0–15:\n")
  ufc_rankings |>
    filter(!is.na(rank), (rank < 0 | rank > 15)) |>
    select(date, weightclass, fighter, rank) |>
    print()

  # ¿Qué hacer?
  #   - Proporciones >1: ¿están en escala 0–100 y hay que dividir entre 100?
  #   - Outliers físicos: ¿error de captura o conversión de unidades?
  #   - Ranks >15: ¿son expansiones de divisiones o suciedad?


  # ==============================================================================
  # 5. CONSISTENCIA DE CATEGORÍAS
  # ==============================================================================

  separador("5. Consistencia de categorías")

  # --- 5a. Resultados de pelea ---
  subseccion("ufc_fights — f1_result / f2_result (esperado: W / L / D / NC)")

  cat("f1_result:\n"); print(count(ufc_fights, f1_result, sort = TRUE))
  cat("\nf2_result:\n"); print(count(ufc_fights, f2_result, sort = TRUE))

  # ¿Hay peleas donde ambos ganan o ambos pierden? (incoherencia lógica)
  ufc_fights |>
    filter(!is.na(f1_result), !is.na(f2_result)) |>
    filter((f1_result == "W" & f2_result == "W") |
           (f1_result == "L" & f2_result == "L")) |>
    { \(x) cat(sprintf("\nPeleas con resultado imposible (WW o LL): %d\n", nrow(x))) }()

  # --- 5b. Métodos de victoria ---
  subseccion("ufc_fights — method")
  ufc_fights |>
    count(method, sort = TRUE) |>
    print(n = Inf)

  # --- 5c. Status de atletas ---
  subseccion("ufc_athletes — status")
  ufc_athletes |>
    count(status, sort = TRUE) |>
    print()

  # --- 5d. Stance en ufcstats ---
  subseccion("ufcstats — stance")
  ufcstats |>
    count(stance, sort = TRUE) |>
    print()

  # --- 5e. Clases de peso ---
  subseccion("Clases de peso por dataset")

  cat("[ufc_athletes]:\n"); ufc_athletes |> count(weight_class, sort = TRUE) |> print(n = Inf)
  cat("\n[ufc_fights]:\n");  ufc_fights   |> count(weight_class, sort = TRUE) |> print(n = Inf)
  cat("\n[ufc_rankings]:\n"); ufc_rankings |> count(weightclass, sort = TRUE) |> print(n = Inf)
  cat("\n[ultimate]:\n");    ultimate     |> count(weight_class, sort = TRUE) |> print(n = Inf)

  # ¿Qué hacer?
  #   - ¿Estandarizas los nombres de clases de peso entre datasets?
  #   - ¿Hay categorías con typos o variantes ("Welterweight" vs "welterweight")?
  #   - ¿Cuántos NAs hay en weight_class?


  # ==============================================================================
  # 6. CONSISTENCIAS LÓGICAS ENTRE COLUMNAS
  # ==============================================================================

  separador("6. Consistencias lógicas")

  # --- 6a. ufc_athletes: porcentajes de método de victoria suman ~100%? ---
  subseccion("ufc_athletes — ko_tko_pct + dec_pct + sub_pct ≈ 100%?")

  ufc_athletes |>
    filter(!is.na(ko_tko_percent), !is.na(dec_percent), !is.na(sub_percent)) |>
    mutate(suma_pct = ko_tko_percent + dec_percent + sub_percent) |>
    summarise(
      min_suma  = min(suma_pct),
      mediana   = median(suma_pct),
      max_suma  = max(suma_pct),
      n_no_suma = sum(abs(suma_pct - 1) > 0.02)  # tolerancia 2%
    ) |>
    print()

  # --- 6b. ufc_athletes: porcentajes de posición suman ~100%? ---
  subseccion("ufc_athletes — standing_pct + clinch_percent + ground_percent ≈ 100%?")

  ufc_athletes |>
    filter(!is.na(standing_pct), !is.na(clinch_percent), !is.na(ground_percent)) |>
    mutate(suma_pos = standing_pct + clinch_percent + ground_percent) |>
    summarise(
      min_suma  = min(suma_pos),
      mediana   = median(suma_pos),
      max_suma  = max(suma_pos),
      n_no_suma = sum(abs(suma_pos - 1) > 0.02)
    ) |>
    print()

  # --- 6c. sig_strikes_landed <= sig_strikes_attempted ---
  subseccion("ufc_athletes — ¿aterrizados > intentados?")

  ufc_athletes |>
    filter(!is.na(sig_strikes_landed), !is.na(sig_strikes_attempted),
           sig_strikes_landed > sig_strikes_attempted) |>
    select(name, sig_strikes_landed, sig_strikes_attempted) |>
    { \(x) cat(sprintf("Filas donde landed > attempted: %d\n", nrow(x))); print(x) }()

  # --- 6d. ufcstats: str_acc ≈ wins / (wins + losses)? No, pero checar coherencia ---
  subseccion("ufcstats — registros negativos (wins / losses / draws / nc)")

  ufcstats |>
    filter(if_any(c(wins, losses, draws, nc), \(x) !is.na(x) & x < 0)) |>
    select(name, wins, losses, draws, nc) |>
    { \(x) cat(sprintf("Filas con conteos negativos: %d\n", nrow(x))); print(x) }()

  # --- 6e. ultimate: winner debe ser "Red" o "Blue" ---
  subseccion("ultimate — valores de 'winner'")

  ultimate |>
    count(winner, sort = TRUE) |>
    print()

  # ¿Qué hacer?
  #   - Si las proporciones no suman 1: ¿hay una categoría "other" implícita?
  #   - ¿Los NAs en 'winner' son peleas sin decisión (NC, Draw)?


  # ==============================================================================
  # 7. FECHAS
  # ==============================================================================

  separador("7. Fechas")

  # --- ufc_fights$date ---
  subseccion("ufc_fights — date")
  cat("Rango:\n")
  cat(sprintf("  Min: %s\n", min(ufc_fights$date, na.rm = TRUE)))
  cat(sprintf("  Max: %s\n", max(ufc_fights$date, na.rm = TRUE)))
  cat(sprintf("  NAs: %d\n", sum(is.na(ufc_fights$date))))

  # Fechas en el futuro (respecto a hoy)?
  cat(sprintf("  Fechas > hoy (%s): %d\n", Sys.Date(),
      sum(ufc_fights$date > Sys.Date(), na.rm = TRUE)))

  # --- ufc_rankings$date (es character, no Date) ---
  subseccion("ufc_rankings — date (tipo character — ¿convertir a Date?)")
  cat("Valores únicos de muestra:\n")
  print(head(sort(unique(ufc_rankings$date)), 10))

  # Intentar parsear como Date
  prueba_fecha <- suppressWarnings(as.Date(ufc_rankings$date))
  cat(sprintf("NAs al convertir a Date: %d de %d\n",
      sum(is.na(prueba_fecha)), nrow(ufc_rankings)))

  # --- ufc_athletes$octagon_debut ---
  subseccion("ufc_athletes — octagon_debut")
  cat(sprintf("  Min: %s\n", min(ufc_athletes$octagon_debut, na.rm = TRUE)))
  cat(sprintf("  Max: %s\n", max(ufc_athletes$octagon_debut, na.rm = TRUE)))
  cat(sprintf("  NAs: %d de %d\n", sum(is.na(ufc_athletes$octagon_debut)), nrow(ufc_athletes)))

  # --- ufcstats$dob ---
  subseccion("ufcstats — dob (fecha de nacimiento)")
  cat(sprintf("  Min: %s\n", min(ufcstats$dob, na.rm = TRUE)))
  cat(sprintf("  Max: %s\n", max(ufcstats$dob, na.rm = TRUE)))
  cat(sprintf("  NAs: %d de %d\n", sum(is.na(ufcstats$dob)), nrow(ufcstats)))

  # Edades implícitas fuera de rango razonable (15–65 años)
  edades <- as.numeric(Sys.Date() - ufcstats$dob) / 365.25
  cat("\nEdades implícitas fuera de 15–65 años:\n")
  ufcstats |>
    mutate(edad_calc = as.numeric(Sys.Date() - dob) / 365.25) |>
    filter(!is.na(edad_calc), edad_calc < 15 | edad_calc > 65) |>
    select(name, dob, edad_calc) |>
    print()

  # ¿Qué hacer?
  #   - ufc_rankings$date: ¿convertirla a Date?
  #   - ultimate$date:     ¿ídem?
  #   - DOBs extrañas:     ¿error de captura o luchador retirado muy mayor?


  # ==============================================================================
  # 8. UNIONES ENTRE DATASETS (cobertura)
  # ==============================================================================

  separador("8. Cobertura entre datasets")

  # ¿Cuántos luchadores de ufc_athletes aparecen en ufcstats?
  athletes_names <- ufc_athletes |> pull(name) |> unique()
  stats_names    <- ufcstats     |> pull(name) |> unique()

  cat(sprintf("Atletas en ufc_athletes:             %d\n", length(athletes_names)))
  cat(sprintf("Atletas en ufcstats:                 %d\n", length(stats_names)))
  cat(sprintf("En athletes pero NO en ufcstats:     %d\n",
      length(setdiff(athletes_names, stats_names))))
  cat(sprintf("En ufcstats  pero NO en athletes:    %d\n",
      length(setdiff(stats_names, athletes_names))))
  cat(sprintf("En ambos:                            %d\n",
      length(intersect(athletes_names, stats_names))))

  # Muestra de nombres solo en uno de los dos (¿variantes de escritura?)
  cat("\nEjemplos en athletes pero no en ufcstats (primeros 15):\n")
  print(head(setdiff(athletes_names, stats_names), 15))

  cat("\nEjemplos en ufcstats pero no en athletes (primeros 15):\n")
  print(head(setdiff(stats_names, athletes_names), 15))

  # ¿Qué hacer?
  #   - Diferencias pueden ser por variaciones en el nombre (tildes, apodos).
  #   - ¿Necesitas unir estos datasets? ¿Vale la pena limpiar los nombres o
  #     usas la URL como llave en fights/athletes?


  # ==============================================================================
  # 9. RESUMEN EJECUTIVO DE DECISIONES PENDIENTES
  # ==============================================================================

  separador("9. Resumen: decisiones que debes tomar")

  decisiones <- c(
    "1. [TIPOS]       ufc_athletes$wins/losses/draws son character. ¿Convertir a numeric?",
    "2. [TIPOS]       ufc_rankings$date y ultimate$date son character. ¿Convertir a Date?",
    "3. [NAs]         Variables 'where available' (nickname, fighting_style, etc.): ¿flag booleano o dejar NA?",
    "4. [NAs]         ¿Eliminas filas con NA en variables clave para tu análisis?",
    "5. [DUPLICADOS]  Nombres repetidos en athletes/ufcstats: ¿homónimos o duplicados sucios?",
    "6. [RANGOS]      Proporciones fuera de [0,1]: ¿están en escala 0–100 y hay que dividir?",
    "7. [RANGOS]      Outliers físicos (altura/peso): ¿error de captura o unidades mixtas?",
    "8. [CATEGORÍAS]  Clases de peso inconsistentes entre datasets: ¿estandarizas o no unes?",
    "9. [LÓGICA]      Proporciones de método de victoria que no suman 1: ¿categoría faltante?",
    "10.[LÓGICA]      NAs en 'winner' en ultimate: ¿draws/NC o datos faltantes reales?",
    "11.[UNIONES]     Luchadores sin match entre athletes y ufcstats: ¿limpias nombres o aceptas pérdida?"
  )

  cat(paste(decisiones, collapse = "\n"), "\n")
}

#-----------------------------------------------------------------------------
# End of data_quality.R
#-----------------------------------------------------------------------------
