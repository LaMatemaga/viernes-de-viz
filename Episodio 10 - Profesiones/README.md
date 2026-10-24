# Episodio 10 — Profesiones

Carreras universitarias, salario de entrada y exposición a la IA, a partir de [TidyTuesday 2026-10-20](https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-10-20). Curaduría: Tony Galvan, Golden Dome Data Science.

El conjunto junta tres fuentes al nivel de la carrera (CIP de 4 dígitos): salarios del [College Scorecard](https://collegescorecard.ed.gov/data/) (mediana a un año de graduarse, licenciatura), exposición ocupacional a la IA del índice [AIOE](https://github.com/AIOE-Data/AIOE) de Felten, Raj y Seamans (2021), y el cruce [CIP–SOC](https://nces.ed.gov/ipeds/cipcode/resources.aspx) de NCES/BLS. Son 285 carreras. La correlación entre salario de entrada y exposición es casi nula (r ≈ 0.01).

El AIOE está estandarizado (media 0, desviación 1). Un valor alto no significa que el trabajo vaya a automatizarse: la IA también puede asistir la tarea. `ai_exposure_percentile` es el rango de 0 a 100 entre estas 285 carreras.

Los paquetes se fijan con [`renv`](https://rstudio.github.io/renv/). El lockfile es el mismo entorno que el episodio 09.

## Primera vez en esta carpeta

Abre `Episodio 10 - Profesiones.Rproj` y restaura la librería:

```r
renv::restore()
```

Eso instala lo que está en `renv.lock`. El proyecto usa `snapshot.type = "explicit"`: si agregas un paquete, apúntalo en `DESCRIPTION` y corre `renv::snapshot()`.

## Datos

```r
tuesdata <- tidytuesdayR::tt_load("2026-10-20")
ai_salary_majors <- tuesdata$ai_salary_majors
major_occupations <- tuesdata$major_occupations
```

| Archivo | Qué es |
|---|---|
| `ai_salary_majors` | Una fila por carrera: salario, exposición (total, lenguaje e imagen) y conteos |
| `major_occupations` | Cruce carrera → ocupación, con el AIOE de cada ocupación |

Preguntas que propone TidyTuesday: carreras a la vez poco expuestas y bien pagadas, lenguaje frente a imagen, y si Ingeniería, Salud, Negocios y Humanidades se agrupan.

## Estructura

```
main.R
renv.lock
.Rprofile
DESCRIPTION
output/
src/
  install_load_packages.R
  toolkit.R
  functions/
    log_message.R
    fuentes.R
    visualizaciones.R
```
