# Viernes de Visualizaciones

Series de gráficos de [La Matemaga](https://www.lamatemaga.com), hechos cada viernes a partir de datos de [TidyTuesday](https://github.com/rfordatascience/tidytuesday).

Cada carpeta `Episodio …` es un proyecto de R independiente. Corre el script desde esa carpeta, no desde la raíz.

## Episodios

| Episodio | Tema | TidyTuesday |
|---|---|---|
| [03 — UFC](Episodio%2003%20-%20UFC/) | Ventajas, apuestas y esquina roja | 2026-07-07 |
| [05 — IELTS](Episodio%2005%20-%20IELTS/) | Bandas del IELTS en Latinoamérica | 2026-08-18 |
| [06 — Castillos](Episodio%2006%20-%20Castillos/) | Patrimonio arquitectónico más visto en Wikipedia | 2026-09-01 |

## Cómo correr un episodio

Desde la carpeta del episodio, en R:

```r
source("main.R")
```

O en la terminal:

```bash
Rscript main.R
```

`main.R` instala los paquetes que falten, carga las funciones de `src/` y genera las figuras.

## Estructura de cada episodio

```
main.R
output/          # PNG (ignorados por git)
src/
  install_load_packages.R
  toolkit.R
  functions/
```

- `src/install_load_packages.R` instala y carga los paquetes del episodio.
- `src/toolkit.R` hace `source()` de todo lo que hay en `src/functions/`.
- El flujo del análisis vive en `main.R`.
- Las figuras se escriben en `output/` y no se versionan (`.gitignore` ignora `*.png`).

## Tipografías

Los archivos `.ttf` de Fraunces, Inter y JetBrains Mono están en esta carpeta. Los episodios 05 y 06 los buscan primero en su propio directorio y, si no están, en el directorio padre (aquí).

Los gráficos de esos episodios usan la paleta y el sistema tipográfico [Sterling](https://www.lamatemaga.com/sterling).
