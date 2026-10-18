# Episodio 09 — Anfibios

Ranas y sapos (orden Anura) del mundo, a partir de `frogs_and_toads_amphibiaweb` ([AmphibiaWeb](https://amphibiaweb.org) / [TidyTuesday 2026-10-13](https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-10-13)). Curaduría: Ntobeko Sosibo.

El episodio dibuja una filogenia circular de las especies con coincidencia
exacta en el árbol fechado de Jetz y Pyron.

Los paquetes se fijan con [`renv`](https://rstudio.github.io/renv/). `main.R` **no** llama `install.packages()`.

## Primera vez en esta carpeta

```r
renv::restore()
```

Después, desde esta carpeta:

```r
source("main.R")
```

## Datos

Un renglón por especie. Columnas con más probabilidad de servir:

| Columna | Qué es |
|---|---|
| `family`, `subfamily`, `genus`, `specificepithet` | Taxonomía |
| `isocc` | Códigos ISO de los países del rango nativo, separados por ` \| ` |
| `intro_isocc` | Países donde la especie fue introducida |
| `interntnl_status` | Estatus de conservación internacional (IUCN) |
| `trends_and_threats` | Amenazas y tendencia poblacional (texto libre) |

Preguntas que propone TidyTuesday: familias con más especies, países con más especies nativas, estatus IUCN por familia o región.

Ojo: el CSV de TidyTuesday sale de un XML de AmphibiaWeb que se descargó a mano, porque el sitio bloquea descargas automáticas. Los campos de texto traen valores múltiples unidos con ` | `.

## Filogenia

`main.R` descarga una vez el consenso fechado de 10 000 árboles de Jetz y
Pyron (2018), publicado en [Zenodo](https://doi.org/10.5061/dryad.cc3n6j5).
El archivo queda en `data/` como caché local y está ignorado por git.

No se resuelven sinónimos taxonómicos: de las 8 018 especies de AmphibiaWeb,
5 366 (66.9 %) coinciden exactamente con las puntas del consenso y son las que
entran al gráfico. Las longitudes de rama representan tiempo evolutivo
estimado; no se sustituyen por los niveles taxonómicos del CSV.

## Estructura

```
main.R
renv.lock
.Rprofile
data/       # caché local de la filogenia, ignorada por git
output/
src/
  install_load_packages.R
  toolkit.R
  functions/
    log_message.R
    fuentes.R
    visualizaciones.R
```
