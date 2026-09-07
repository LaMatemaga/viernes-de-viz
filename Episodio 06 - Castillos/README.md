# Episodio 06 — Castillos

Patrimonio arquitectónico más popular en Wikipedia, por continente, a partir de `world_castles` (Wikidata / TidyTuesday).

Cada lámina muestra los 5 sitios con más vistas anuales en ese continente (castillo, palacio, fortaleza o ruina). La lámina global toma el más visto de cada continente. El eje de vistas comparte el mismo tope en las seis gráficas.

## Cómo correrlo

Desde esta carpeta:

```r
source("main.R")
```

Las figuras nuevas se guardan en `output/`. Las tipografías (Fraunces, Inter y JetBrains Mono) están en `fonts/` en la raíz del repositorio.

## Datos

TidyTuesday 2026, semana 35 (`2026-09-01`). El join de ISO → país en español y continente está en `src/functions/paises_iso_continente.R`. El ISO de Namibia se corrige a `'NA'` antes del join.

## Salidas

Para cada región (`africa`, `america`, `asia`, `europa`, `oceania`, `global`):

| Sufijo | Uso |
|---|---|
| `_master.png` | Master 12×8 a 300 ppi |
| `_1x1.png` | Cuadrado 1080×1080 |
| `_4x5.png` | Instagram 1080×1350 |
| `_9x16.png` | Historia 1080×1920 |
| `_1.91x1.png` | X / LinkedIn 1200×628 |

## Estructura

```
main.R
src/
  install_load_packages.R
  toolkit.R
  functions/
    log_message.R
    paises_iso_continente.R
    visualizaciones.R   # estilo Sterling, grafica_continente(), guardar_png()
```
