# Episodio 08 — Salud Urbana

Qué parte de la población de una ciudad vive a menos de 1 km de un hospital o una farmacia, a partir de `health` (GHS-UCDB R2024A, Comisión Europea / TidyTuesday).

La historia está en dos boxplots: la cobertura por grupo de ingreso del país, y el contraste entre el urbanismo europeo y el de Norteamérica y Oceanía anglo. Los mapas coropléticos se probaron y se descartaron porque no agregaban nada sobre los boxplots.

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
| `HL_SHP_HOS_2025` / `HL_SHP_PHA_2025` | `share_cerca_hospital` / `share_cerca_farmacia` | Porcentaje de la población a menos de 1 km |

**Los `share_*` ya vienen en porcentaje (0–100)**, no como proporción, así que se usan tal cual y no se recalculan desde `pob_cerca_* / poblacion`.

La unidad de análisis es la ciudad, no el país: Norteamérica son solo dos países y un boxplot por país se quedaría sin casos. `main.R` deja `df_ciudad` (filtrada), `df_cobertura` (formato largo por ciudad y servicio) y `df_bloques` (el contraste de urbanismo).

De las 11 422 ciudades, 9 026 no traen dato de farmacias y 5 185 no traen dato de hospitales. `df_ciudad` conserva las que tienen al menos 4 de 6 medidas clave (`COLUMNAS_CLAVE`), y quedan 6 387.

Como cada servicio tiene su propia cobertura de datos, **cada caja lleva su `(N = x)` anotado a la derecha del panel**, con el color de su servicio. Así se ve en la lámina que en ingreso bajo hay 383 ciudades con dato de hospitales pero solo 47 con dato de farmacias, y esa caja se lee con cuidado. Las etiquetas viven fuera del panel con `coord_cartesian(clip = "off")` y el margen derecho del tema les abre el espacio, porque varios bigotes llegan a 100 % y ahí chocarían.

## Qué dicen las láminas

`cobertura_ingreso`: la mediana de población a menos de 1 km de un hospital **baja** conforme sube el ingreso del país, de 37 % en ingreso medio-bajo a 23 % en ingreso alto. No es una relación causal; pesa que las ciudades de ingreso bajo son más densas y que el registro de servicios en OSM no es homogéneo.

`cobertura_bloques`: entre ciudades de ingreso alto, la mediana europea (29 %) más que duplica la norteamericana (12 %), con Australia y Nueva Zelanda en medio (18 %). En farmacias la brecha casi desaparece (16 % contra 14 %).

`cobertura_bloques_densidad`: la misma lámina con una tercera caja, la densidad de población, que es la explicación más probable de esa brecha. La mediana europea es de 3 333 hab/km² contra 1 992 de Norteamérica y 1 685 de Australia y N. Zelanda, y el orden de los tres bloques es el mismo que en cercanía a un hospital.

`ggplot2` solo admite ejes secundarios derivados del primario, así que la densidad se reescala al dominio 0–100 del porcentaje (`FACTOR_DENSIDAD`) y el eje de arriba deshace la transformación. El techo es 6 000 hab/km² a propósito: así los cortes del eje secundario (0, 1 500, 3 000, 4 500, 6 000) caen justo sobre los del primario (0, 25, 50, 75, 100 %) y las dos retículas coinciden en vez de cruzarse. El bigote superior de la densidad llega a 5 820, así que nada se recorta.

Ojo con las regiones de la ONU: **`Oceania` son las islas del Pacífico y excluye Australia y Nueva Zelanda**, que forman la región `Australia and New Zealand`. Los bloques del contraste están en `NIVELES_BLOQUE`.

## Salidas

Tres láminas con prefijo `salud_` (la constante `PREFIJO` en `visualizaciones.R`): `cobertura_ingreso`, `cobertura_bloques` y `cobertura_bloques_densidad`. Las tres salen de la misma constructora, `grafica_cobertura()`, cambiando la variable del eje vertical y, en la última, la paleta (`paleta_con_densidad`) y el eje secundario (`eje_densidad()`):

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
