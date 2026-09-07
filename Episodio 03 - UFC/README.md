# Episodio 03 — UFC

Visualizaciones exploratorias con el dataset de UFC de TidyTuesday (`2026-07-07`, paquete `{fightr}`).

Tres preguntas, las tres sobre la esquina **roja**:

1. **¿Qué ventajas predicen ganar?** Dumbbell: tasa de victoria cuando Rojo tiene (o no) alcance, altura, juventud, récord o favoritismo en las odds.
2. **¿Las apuestas saben algo que los rankings no?** Barras según si odds y récord de victorias coinciden o discrepan.
3. **¿Hay una prima por esquina roja?** Curva de calibración: victoria real contra la probabilidad implícita del mercado.

## Cómo correrlo

Desde esta carpeta:

```r
source("main.R")
```

Eso carga los datos con `tidytuesdayR` y llama `crear_visualizaciones()`. Las figuras se imprimen en una sesión interactiva; los `ggsave()` siguen comentados en el código.

Para la auditoría de calidad (no modifica los datos; imprime hallazgos y decisiones pendientes):

```r
source("src/install_load_packages.R")
source("src/toolkit.R")
tuesdata <- tidytuesdayR::tt_load("2026-07-07")
evaluar_calidad_datos(tuesdata)
```

## Datos

TidyTuesday 2026-07-07:

- `ufc_athletes`
- `ufc_fights`
- `ufc_rankings_dataset`
- `ufcstats_data`
- `ultimate_ufc_dataset` — el que usan las gráficas

## Estructura

```
main.R
src/
  install_load_packages.R
  toolkit.R
  functions/
    log_message.R
    visualizaciones.R   # crear_visualizaciones()
    data_quality.R      # evaluar_calidad_datos()
```
