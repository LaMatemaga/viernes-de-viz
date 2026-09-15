# Episodio 07 — Índice Cappuccino

Cuánto tiene que trabajar un barista para pagarse un capuchino pequeño, a partir de `cafe` y `cappuccino_index` (James Hoffmann / TidyTuesday).

El índice de cada país está en minutos. Las láminas cubren la relación salario–precio, los extremos (5 más altos y 5 más bajos, con n ≥ 10), los mapas, la magnitud de los extremos con un waffle horizontal, un ridgeline de los países con mayor y menor dispersión, y la relación índice–dispersión.

A partir de este episodio los paquetes se fijan con [`renv`](https://rstudio.github.io/renv/). `main.R` **no** llama `install.packages()`.

## Primera vez en esta carpeta

```r
renv::restore()
```

Eso instala exactamente lo que está en `renv.lock` dentro de la librería del proyecto.

## Cómo correrlo

Desde esta carpeta:

```r
source("main.R")
```

Las figuras van a `output/`. Las tipografías se cargan desde `fonts/` en la raíz del repositorio (Fraunces, Inter, JetBrains Mono).

Para el reporte en PDF hay un segundo export en SVG editable:

```r
source("linkedin.R")
```

Ese script reconstruye las mismas láminas con `main.R` (sin rehacer los PNG) y las guarda en `output/svg/`.

## Datos

TidyTuesday 2026-09-08. El índice oficial es `sum(precio) / sum(salario) * 60`. En `country`, Nueva Zelanda y Sudáfrica traen un espacio de no separación (U+00A0); `main.R` lo sustituye por un espacio normal.

Para los boxplots, el ridgeline y el cálculo de la desviación estándar se excluyen valores atípicos dentro de cada país con la regla de Tukey: valores menores que `Q1 - 1.5 × IQR` o mayores que `Q3 + 1.5 × IQR`. El índice oficial por país no se recalcula.

## Salidas

Para cada lámina (`salario_precio`, `extremos`, `mapa_index`, `mapa_std`, `waffle`, `ridgeline_std`, `index_dispersion`):

| Sufijo | Uso |
|---|---|
| `_master.png` | Master 12×8 a 300 ppi |
| `_1x1.png` | Cuadrado 1080×1080 |
| `_4x5.png` | Instagram 1080×1350 |
| `_9x16.png` | Historia 1080×1920 |
| `_1.91x1.png` | X / LinkedIn 1200×628 |

En las versiones 1×1, 4×5 y 9×16, `mapa_index` incluye el waffle y `mapa_std` incluye el ridgeline como contexto debajo del mapa.

`linkedin.R` repite en `output/svg/` solo los tres formatos que se editan para el reporte: `_master.svg`, `_1x1.svg` y `_1.91x1.svg`. El texto queda como texto editable y las familias se escriben con su nombre real (`Fraunces`, `Inter`, `JetBrains Mono`), así que hay que tenerlas instaladas en el sistema para abrirlas en Illustrator.

## Estructura

```
main.R
linkedin.R            # export en SVG para editar en Illustrator
renv.lock
.Rprofile
output/
  svg/
src/
  install_load_packages.R
  toolkit.R
  functions/
    log_message.R
    fuentes.R
    visualizaciones.R   # estilo Sterling, constructoras y guardar_png()
```
