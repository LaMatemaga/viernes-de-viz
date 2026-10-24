#-----------------------------------------------------------------------------
# main.R
#-----------------------------------------------------------------------------
#   Core script for the project. It loads packages via renv, sources utility
#   functions, and executes the main data processing workflow.
#
#   Carreras universitarias, salario de entrada y exposición a la IA
#   (TidyTuesday 2026-10-20). Siete áreas por tipo de trabajo, y el salto
#   salarial del año 1 al 4 frente a la inflación.
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Load required libraries and source utility functions
#-----------------------------------------------------------------------------

source(file.path("src", "install_load_packages.R"))
source(file.path("src", "toolkit.R"))
logs <- log_message("Loaded required packages and sourced utility functions.", c(), type="info")



#-----------------------------------------------------------------------------
#  Set up paths and parameters
#-----------------------------------------------------------------------------
output_path <- "output/"
dir.create(output_path, showWarnings = FALSE)
fuentes <- registrar_fuentes_sterling()
logs <- log_message(paste0("Fuentes registradas desde ", fuentes$root), logs, type="info")



#-----------------------------------------------------------------------------
# Load data
#-----------------------------------------------------------------------------

logs <- log_message("Loading TidyTuesday dataset...", logs, type="info")
tuesdata <- tidytuesdayR::tt_load("2026-10-20")
logs <- log_message("Loaded TidyTuesday dataset.", logs, type="info")

# ai_salary_majors: una fila por carrera (CIP de 4 dígitos). Salario mediano
# al año y a los cuatro años, AIOE total / lenguaje / imagen, percentil 0–100,
# y conteos de ocupaciones, instituciones y egresados.
df_carreras <- tuesdata$ai_salary_majors

# major_occupations: el cruce carrera → ocupación (SOC) que está detrás del
# promedio de exposición de cada carrera.
df_ocupaciones <- tuesdata$major_occupations

logs <- log_message(
  paste0(
    "Carreras: ", nrow(df_carreras), " en ",
    dplyr::n_distinct(df_carreras$broad_field_short), " campos. ",
    "Ocupaciones enlazadas: ", nrow(df_ocupaciones), "."
  ),
  logs, type = "info"
)



#-----------------------------------------------------------------------------
# Main Data Processing Workflow
#-----------------------------------------------------------------------------

# El AIOE está estandarizado (media 0, desviación 1). Un valor alto mide
# exposición, no automatización: la IA también puede asistir el trabajo.
# ai_exposure_percentile es el rango 0–100 entre estas 285 carreras.

df_carreras <- df_carreras %>%
                    rename(salary_1y_median = median_starting_salary,
                           salary_4y_median = median_salary_4yr)

# El salario va en z para compartir unidades con el AIOE y poder usar los
# mismos límites en ambos ejes. Se estandariza entre estas 285 carreras,
# así que su 0 es la carrera promedio de la muestra.
df_carreras <- df_carreras %>%
                    mutate(salary_1y_median_norm     = scale(salary_1y_median),
                           salary_4y_median_norm     = scale(salary_4y_median),
                           salary_change_pct         = (salary_4y_median-salary_1y_median)/salary_1y_median,
                           salary_log_dollar_change  = (salary_4y_median - salary_1y_median) *
                                                       log(salary_4y_median / salary_1y_median))

# salary_log_dollar_change = (s4 - s1) * log(s4 / s1). log(s4 / s1) es la
# diferencia de logaritmos: una duplicación pesa igual en cualquier
# salario de partida. Multiplicarla por el salto en dólares pide que la
# brecha neta también sea grande.
# El círculo se lee por su área, no por el diámetro: scale_size_area().
# Flannery (1971, Cartographica) midió que el tamaño aparente de un
# círculo es cerca del área real^0.87; Stevens (1957, Psychological
# Review) es la ley de potencia de la que sale ese exponente. La
# corrección de Flannery, dibujar el área como valor^1.14, no entra
# en esta cifra.

# Inflación de referencia: CPI-U del BLS, promedio de ciudad de EE. UU.,
# índices anuales 2015 (237.017) a 2025 (321.943). En esos 10 años la
# tasa compuesta es 3.1% al año. Los tres años del salto salarial dan
# (1.031)^3 - 1 = 9.6%. Quien crece menos que eso pierde poder de compra.
# Entre 9.6% y 13.5% no hay carreras, así que una banda de un par de
# puntos arriba de la inflación saldría vacía. "Queda igual" cierra en
# 15%, justo después del racimo que apenas se despega (enfermería, 14.8%).
# Luego, la mitad más y el doble del salario.
INFLACION_3A <- (1.031)^3 - 1

df_carreras <- df_carreras %>%
  mutate(
    ritmo_salarial = case_when(
      is.na(salary_change_pct)     ~ NA_character_,
      salary_change_pct < INFLACION_3A ~ "Pierde poder adquisitivo",
      salary_change_pct < 0.15    ~ "Queda igual",
      salary_change_pct < 0.50    ~ "Le gana a la inflación",
      salary_change_pct < 1       ~ "Crece fuerte",
      TRUE                         ~ "Se duplica"
    ),
    ritmo_salarial = ordered(
      ritmo_salarial,
      levels = c(
        "Pierde poder adquisitivo",
        "Queda igual",
        "Le gana a la inflación",
        "Crece fuerte",
        "Se duplica"
      )
    )
  )


# Siete áreas por tipo de trabajo, no STEM contra el resto. Interdisciplinary
# no entra entero: ese cajón CIP mezcla cómputo, salud y letras.
area_por_campo <- c(
  "Construction Trades"       = "Oficios y tecnologías",
  "Precision Production"      = "Oficios y tecnologías",
  "Mechanic & Repair Tech"    = "Oficios y tecnologías",
  "Culinary & Personal Svc"   = "Oficios y tecnologías",
  "Transportation"            = "Oficios y tecnologías",
  "Parks & Recreation"        = "Oficios y tecnologías",
  "Agriculture"               = "Oficios y tecnologías",
  "Natural Resources"         = "Oficios y tecnologías",
  "Homeland Security"         = "Oficios y tecnologías",
  "Engineering Tech"          = "Oficios y tecnologías",
  "Military Tech"             = "Oficios y tecnologías",
  "Science Tech"              = "Oficios y tecnologías",
  "Communications Tech"       = "Oficios y tecnologías",
  "Health Professions"        = "Salud",
  "Visual & Performing Arts"  = "Artes",
  "Engineering"               = "Ingeniería y arquitectura",
  "Architecture"              = "Ingeniería y arquitectura",
  "Computer Science"          = "Ciencias y cómputo",
  "Mathematics & Statistics"  = "Ciencias y cómputo",
  "Physical Sciences"         = "Ciencias y cómputo",
  "Biological Sciences"       = "Ciencias y cómputo",
  "Business"                  = "Negocios y derecho",
  "Legal"                     = "Negocios y derecho",
  "Public Administration"     = "Negocios y derecho",
  "Education"                 = "Letras y sociedad",
  "Communication"             = "Letras y sociedad",
  "English"                   = "Letras y sociedad",
  "History"                   = "Letras y sociedad",
  "Foreign Languages"         = "Letras y sociedad",
  "Philosophy & Religion"     = "Letras y sociedad",
  "Theology & Religion"       = "Letras y sociedad",
  "Area & Ethnic Studies"     = "Letras y sociedad",
  "Psychology"                = "Letras y sociedad",
  "Social Sciences"           = "Letras y sociedad",
  "Library Science"           = "Letras y sociedad",
  "Family & Consumer Sci"     = "Letras y sociedad"
)

area_interdisciplinaria <- c(
  "Marine Sciences"                                   = "Ciencias y cómputo",
  "Systems Science and Theory"                        = "Ciencias y cómputo",
  "Cognitive Science"                                 = "Ciencias y cómputo",
  "Human Computer Interaction"                        = "Ciencias y cómputo",
  "Natural Sciences"                                  = "Ciencias y cómputo",
  "Biological and Physical Sciences"                  = "Ciencias y cómputo",
  "Mathematics and Computer Science"                  = "Ciencias y cómputo",
  "Computational Science"                             = "Ciencias y cómputo",
  "Nutrition Sciences"                                = "Salud",
  "Human Biology"                                     = "Salud",
  "Gerontology"                                       = "Salud",
  "Sustainability Studies"                            = "Oficios y tecnologías",
  "Maritime Studies"                                  = "Oficios y tecnologías",
  "Historic Preservation and Conservation"            = "Letras y sociedad",
  "Classical and Ancient Studies"                     = "Letras y sociedad",
  "Behavioral Sciences"                               = "Letras y sociedad",
  "Biopsychology"                                     = "Letras y sociedad",
  "Intercultural/Multicultural and Diversity Studies" = "Letras y sociedad",
  "Cultural Studies/Critical Theory and Analysis"     = "Letras y sociedad",
  "Science, Technology and Society"                   = "Letras y sociedad",
  "Peace Studies and Conflict Resolution"             = "Letras y sociedad",
  "International/Globalization Studies"               = "Letras y sociedad"
)

# Este orden es el de las crestas, las barras y la leyenda de cuadrantes.
# Los colores van por nombre, así que reordenar aquí no los cambia.
niveles_area <- c(
  "Oficios y tecnologías",
  "Salud",
  "Artes",
  "Ingeniería y arquitectura",
  "Ciencias y cómputo",
  "Negocios y derecho",
  "Letras y sociedad"
)

df_carreras <- df_carreras %>%
  mutate(
    area = if_else(
      broad_field_short == "Interdisciplinary",
      unname(area_interdisciplinaria[field_of_study]),
      unname(area_por_campo[broad_field_short])
    ),
    area = factor(area, levels = niveles_area)
  )

if (anyNA(df_carreras$area)) {
  stop("Hay carreras sin área asignada.", call. = FALSE)
}

if (anyDuplicated(df_carreras$cip4) > 0) {
  stop("cip4 repetido en df_carreras.", call. = FALSE)
}

# El área es de la carrera (cip4). df_ocupaciones no trae broad_field_short
# y un mismo cip4 reúne varios field_of_study de 6 dígitos, distintos del
# título en df_carreras. Reaplicar el lookup por nombre partiría una carrera
# en varias áreas, así que las ocupaciones heredan el área ya asignada.
df_ocupaciones <- df_ocupaciones %>%
  mutate(cip4 = as.character(cip4)) %>%
  left_join(
    df_carreras %>%
      mutate(cip4 = as.character(cip4)) %>%
      distinct(cip4, area),
    by = "cip4"
  )

if (anyNA(df_ocupaciones$area)) {
  stop("Hay ocupaciones sin área. El cruce con df_carreras es por cip4.", call. = FALSE)
}

areas_desalineadas <- df_ocupaciones %>%
  distinct(cip4, area) %>%
  anti_join(
    df_carreras %>% mutate(cip4 = as.character(cip4)) %>% distinct(cip4, area),
    by = c("cip4", "area")
  )

if (nrow(areas_desalineadas) > 0 ||
    n_distinct(df_ocupaciones$cip4) != n_distinct(df_carreras$cip4)) {
  stop("El área por cip4 no coincide entre df_carreras y df_ocupaciones.", call. = FALSE)
}

logs <- log_message(
  paste0(
    "Área heredada en ", nrow(df_ocupaciones), " ocupaciones y ",
    n_distinct(df_ocupaciones$cip4), " carreras."
  ),
  logs, type = "info"
)

#-----------------------------------------------------------------------------
# Visualizaciones
#-----------------------------------------------------------------------------

# Nombres de archivo en ASCII: Windows y iOS codifican los acentos de forma
# distinta (NFC contra NFD) y los espacios se escapan en las URL.
slugs_area <- c(
  "Oficios y tecnologías"     = "area_oficios",
  "Salud"                     = "area_salud",
  "Artes"                     = "area_artes",
  "Ingeniería y arquitectura" = "area_ingenieria",
  "Ciencias y cómputo"        = "area_ciencias",
  "Negocios y derecho"        = "area_negocios",
  "Letras y sociedad"         = "area_letras"
)

# cuadrado = TRUE: el panel es un plano z contra z y se dibuja cuadrado en
# todos los formatos (ver guardar_png). Las crestas y las barras ocupan
# el lienzo entero.
laminas_del_idioma <- function(idioma) {
  c(
    list(
      list(plot = grafica_exposicion(df_ocupaciones, idioma), slug = "exposicion", cuadrado = FALSE),
      list(plot = grafica_egresados(df_carreras, idioma), slug = "egresados", cuadrado = FALSE),
      list(plot = grafica_cuadrantes(df_carreras, idioma), slug = "cuadrantes", cuadrado = TRUE)
    ),
    lapply(niveles_area, function(nombre) {
      list(
        plot = grafica_area(df_carreras, nombre, idioma),
        slug = slugs_area[[nombre]],
        cuadrado = TRUE
      )
    })
  )
}

laminas <- setNames(lapply(IDIOMAS, laminas_del_idioma), IDIOMAS)

# Para iterar sin escribir los 100 PNG: exportar_png <- FALSE antes de
# source("main.R"). Las gráficas quedan en `laminas`.
if (!exists("exportar_png")) exportar_png <- TRUE

if (exportar_png) {
  for (idioma in IDIOMAS) {
    for (lam in laminas[[idioma]]) {
      # La vista previa en el panel es solo en español; el inglés comparte
      # el mismo diseño.
      if (interactive() && idioma == "es") print(lam$plot)
      exportar_laminas(lam$plot, lam$slug, output_path, idioma, cuadrado = lam$cuadrado)
      logs <- log_message(
        paste0("Exportadas láminas: ", lam$slug, " (", idioma, ")"),
        logs, type = "info"
      )
    }
  }

  logs <- log_message("Visualizations exported successfully.", logs, type = "info")
}

#-----------------------------------------------------------------------------
# End of main.R
#-----------------------------------------------------------------------------
