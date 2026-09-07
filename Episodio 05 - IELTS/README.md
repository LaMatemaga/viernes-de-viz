# Episodio 05 — IELTS

Distribución de bandas del IELTS General Training en países de Latinoamérica, 2023–2024 y 2024–2025.

El gráfico principal es una barra divergente: las bandas de 6.0 e inferiores van a la izquierda; 6.5 y superiores, a la derecha. La paleta es la escala divergente de Sterling.

## Cómo correrlo

Desde esta carpeta:

```r
source("main.R")
```

Las figuras nuevas se guardan en `output/`. Las tipografías (Fraunces y JetBrains Mono) deben estar en esta carpeta o en la raíz del repositorio.

## Datos

TidyTuesday 2026-08-18. El gráfico usa `demo_by_nationality`, filtrado a tipo `General_Training` y a las nacionalidades latinoamericanas que aparecen en el dataset.

## Salidas

| Archivo | Uso |
|---|---|
| `output/grafico_ielts_tipografias.png` | Master 12×8 a 300 ppi |
| `output/grafico_ielts_1x1_1080x1080.png` | Cuadrado |
| `output/grafico_ielts_instagram_4x5_1080x1350.png` | Instagram |
| `output/grafico_ielts_historia_9x16_1080x1920.png` | Historia / stories |
| `output/grafico_ielts_x_linkedin_1.91x1_1200x628.png` | X / LinkedIn |

## Estructura

```
main.R
src/
  install_load_packages.R
  toolkit.R
  functions/
    log_message.R
    visualizaciones.R   # paleta, fuentes, crear_grob_editorial(), guardar_png()
```
