# Episodio 08 — Salud Urbana

Hospitales y farmacias en los centros urbanos del mundo, a partir de `health` (GHS-UCDB R2024A, Comisión Europea / TidyTuesday).

Carpeta recién inicializada: `main.R` ya carga, renombra y agrega los datos, pero todavía no hay láminas. Las constructoras van al final de `src/functions/visualizaciones.R` y se registran en las listas `laminas` y `laminas_mapa` de `main.R`.

Los paquetes se fijan con [`renv`](https://rstudio.github.io/renv/). `main.R` **no** llama `install.packages()`.

## Primera vez en esta carpeta

```r
renv::restore()
```

Eso instala exactamente lo que está en `renv.lock` dentro de la librería del proyecto. Si agregas un paquete, apúntalo en `DESCRIPTION` y en `src/install_load_packages.R`, y corre `renv::snapshot()`: el proyecto usa `snapshot.type = "explicit"`, así que el lockfile se arma desde los `Imports` de `DESCRIPTION`.

## Cómo correrlo

Desde esta carpeta:

```r
source("main.R")
```

Las figuras van a `output/`. Las tipografías se cargan desde `fonts/` en la raíz del repositorio (Fraunces, Inter, JetBrains Mono).

## Datos

TidyTuesday 2026-09-29, un renglón por centro urbano. `main.R` renombra las columnas al español:

| Original | En `main.R` | Qué es |
|---|---|---|
| `GC_UCN_MAI_2025` | `ciudad` | Nombre principal del centro urbano |
| `GC_CNT_GAD_2025` | `pais` | País (nombres de GADM) |
| `GC_UCA_KM2_2025` | `area_km2` | Área del centro urbano |
| `GC_POP_TOT_2025` | `poblacion` | Población total |
| `GC_DEV_WIG_2025` | `grupo_ingreso` | Grupo de ingreso del Banco Mundial |
| `GC_DEV_USR_2025` | `region_onu` | Región ODS de la ONU |
| `HL_FCL_HOS_2024` / `HL_FCL_PHA_2024` | `hospitales` / `farmacias` | Conteo |
| `HL_FDE_HOS_2024` / `HL_FDE_PHA_2024` | `hospitales_km2` / `farmacias_km2` | Densidad por km² |
| `HL_FPC_HOS_2025` / `HL_FPC_PHA_2025` | `hospitales_per_capita` / `farmacias_per_capita` | Per cápita |
| `HL_POP_HOS_2025` / `HL_POP_PHA_2025` | `pob_cerca_hospital` / `pob_cerca_farmacia` | Población a menos de 1 km |
| `HL_SHP_HOS_2025` / `HL_SHP_PHA_2025` | `share_cerca_hospital` / `share_cerca_farmacia` | Proporción de la población a menos de 1 km |

`main.R` deja tres tablas: `df_salud` por centro urbano, `df_pais` por país de GADM y `df_region` por polígono de `maps` para el mapa. En las dos agregadas, `hospitales_100k` y `farmacias_100k` se calculan sobre el total agregado, no como promedio de los valores por ciudad.

Los nombres de país vienen de GADM y doce no empatan con `maps::map_data("world")`; las equivalencias están en `recodificar_region()` dentro de `visualizaciones.R` y `main.R` avisa en el log si aparece alguno nuevo. Northern Cyprus comparte polígono con Cyprus, y de Trinidad and Tobago solo se dibuja Trinidad.

De las 11 422 ciudades, 9 026 no traen dato de farmacias y 5 185 no traen dato de hospitales, así que cada lámina tiene que decidir su propio filtro. `main.R` lista los faltantes por columna en el log.

## Preguntas del dataset

- ¿Qué centro urbano o país tiene más hospitales o farmacias per cápita?
- ¿Los centros urbanos de mayor ingreso tienen más densidad de hospitales?
- ¿Las ciudades con más hospitales también tienen más farmacias, o son cosas independientes?
- ¿Hay ciudades bien servidas por farmacias pero no por hospitales, o al revés?

## Salidas

Para cada lámina, con prefijo `salud_` (la constante `PREFIJO` en `visualizaciones.R`):

| Sufijo | Uso |
|---|---|
| `_master.png` | Master 12×8 a 300 ppi |
| `_1x1.png` | Cuadrado 1080×1080 |
| `_4x5.png` | Instagram 1080×1350 |
| `_9x16.png` | Historia 1080×1920 |
| `_1.91x1.png` | X / LinkedIn 1200×628 |

`exportar_vectorial()` saca los mismos formatos editables en SVG (`_master`, `_1x1`, `_1.91x1`) si hace falta armar un reporte en Illustrator.

## Estructura

```
main.R
renv.lock
.Rprofile
output/
src/
  install_load_packages.R
  toolkit.R
  functions/
    log_message.R
    fuentes.R
    visualizaciones.R   # estilo Sterling, composición y exportación
```
