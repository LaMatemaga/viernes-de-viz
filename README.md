# Viernes de Visualizaciones

Series de gráficos de [La Matemaga](https://www.lamatemaga.com), hechos cada viernes a partir de datos de [TidyTuesday](https://github.com/rfordatascience/tidytuesday).

Cada carpeta `Episodio …` es un proyecto de R independiente. Corre el script desde esa carpeta, no desde la raíz. Hay **un solo git** en esta carpeta padre.

## Episodios

| Episodio | Tema | TidyTuesday |
|---|---|---|
| [03 — UFC](Episodio%2003%20-%20UFC/) | Ventajas, apuestas y esquina roja | 2026-07-07 |
| [05 — IELTS](Episodio%2005%20-%20IELTS/) | Bandas del IELTS en Latinoamérica | 2026-08-18 |
| [06 — Castillos](Episodio%2006%20-%20Castillos/) | Patrimonio arquitectónico más visto en Wikipedia | 2026-09-01 |
| [07](Episodio%2007/) | Próximo viernes (plantilla) | — |

## Cómo correr un episodio

En RStudio, abre el `.Rproj` **de esa carpeta** (File → Open Project). Así el working directory no queda en el Escritorio.

Desde la carpeta del episodio, en R:

```r
source("main.R")
```

O en la terminal:

```bash
Rscript main.R
```

Los episodios 03–06 instalan paquetes que falten con `install.packages()`. A partir del 07 se usa [`renv`](https://rstudio.github.io/renv/): `renv::restore()` y no hay instalación automática al correr `main.R`.

## Estructura de cada episodio

```
Episodio ….Rproj
main.R
output/          # PNG (ignorados por git)
src/
  install_load_packages.R
  toolkit.R
  functions/
```

- `src/install_load_packages.R` carga los paquetes del episodio.
- `src/toolkit.R` hace `source()` de todo lo que hay en `src/functions/`.
- El flujo del análisis vive en `main.R`.
- Las figuras se escriben en `output/` y no se versionan.

## Tipografías

Fraunces, Inter y JetBrains Mono (Google Fonts) están en [`fonts/`](fonts/). Los episodios 05 y 06 las buscan en la carpeta del episodio, luego en `../fonts/`. El 07 solo usa `fonts/` en la raíz.
