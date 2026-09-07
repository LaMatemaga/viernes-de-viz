##-----------------------------------------------------------------------------
# main.R
#-----------------------------------------------------------------------------
#   Core script for the project. It installs and loads necessary packages,
#   sources utility functions, and executes the main data processing workflow.
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
logs <- log_message("Set up paths and parameters.", logs, type="info")



#-----------------------------------------------------------------------------
# Main Data Processing Workflow
#-----------------------------------------------------------------------------

tuesdata <- tidytuesdayR::tt_load("2026-08-18")
demo_by_first_language <- tuesdata$demo_by_first_language
demo_by_nationality <- tuesdata$demo_by_nationality
demo_by_reasons <- tuesdata$demo_by_reasons
performance_by_first_language <- tuesdata$performance_by_first_language
performance_by_nationality <- tuesdata$performance_by_nationality
logs <- log_message("Loaded TidyTuesday IELTS datasets.", logs, type="info")

mexico24 <- demo_by_nationality %>% filter(year == "2024-2025" & type == "Academic" & nationality == "Mexico")
sum(mexico24$percent)

latam_countries <- c(
  "Argentina", "Bolivia", "Brasil", "Chile", "Colombia", "Costa Rica",
  "Cuba", "Ecuador", "El Salvador", "Guatemala", "Haití", "Honduras",
  "Mexico", "Nicaragua", "Panama", "Paraguay", "Peru", "República Dominicana",
  "Uruguay", "Venezuela", "Guadalupe", "Guayana Francesa", "Martinica",
  "Puerto Rico", "San Bartolome", "San Martín"
)
IELTS_nationality <- demo_by_nationality %>% pull(nationality) %>% unique()
latam_countries <- intersect(IELTS_nationality, latam_countries)

latam_IELTS <- demo_by_nationality %>%
  filter((year == "2024-2025" | year == "2023-2024") & type == "General_Training" & (nationality %in% latam_countries))

niveles_correctos <- c("<4", "4", "4.5", "5", "5.5", "6", "6.5", "7", "7.5", "8", "8.5", "9")

latam_IELTS_divergente <- latam_IELTS %>%
  mutate(
    band = factor(band, levels = niveles_correctos),
    perc_plot = if_else(band %in% c("<4", "4", "4.5", "5", "5.5", "6"), -percent, percent)
  )

source_line <- "Fuente: IELTS / TidyTuesday (2026-08-18)"
credit_line <- "Hecho durante #ViernesDeVisualizaciones por La Matemaga."
title_line <- "Resultados del IELTS en Latinoamérica"

p1 <- ggplot(latam_IELTS, aes(x = nationality, y = percent, fill = band)) +
  coord_flip() +
  geom_bar(stat = "identity") + facet_grid(year ~ .)

p2 <- ggplot(latam_IELTS_divergente, aes(x = nationality, y = perc_plot, fill = band)) +
  coord_flip() +
  geom_bar(stat = "identity") + facet_grid(year ~ .)

if (interactive()) {
  print(p1)
  print(p2)
}

p3 <- ggplot(latam_IELTS_divergente, aes(x = nationality, y = perc_plot, fill = band)) +
  coord_flip() +
  geom_col(data = ~ subset(., perc_plot < 0), position = "stack") +
  geom_col(data = ~ subset(., perc_plot >= 0), position = position_stack(reverse = TRUE)) +
  facet_grid(year ~ .) +
  geom_hline(yintercept = 0, color = "#5C5178", linewidth = 0.35) +
  scale_y_continuous(
    breaks = seq(-0.5, 0.5, by = 0.1),
    labels = function(x) scales::label_percent(accuracy = 1)(abs(x))
  ) +
  scale_fill_manual(values = paleta_final) +
  labs(
    title = title_line,
    subtitle = "Distribución proporcional de bandas por país y año",
    x = "Nacionalidad",
    y = "Porcentaje",
    fill = "Banda",
    caption = source_line
  ) +
  theme_minimal(base_family = "JetBrains Mono") +
  theme(
    plot.background = element_rect(fill = "#FBF9FE", color = NA),
    panel.background = element_rect(fill = "#FFFFFF", color = NA),
    panel.grid.major = element_line(color = "#D9D1E6", linewidth = 0.3),
    panel.grid.minor = element_blank(),
    strip.background = element_rect(fill = "#E2DBF0", color = NA),
    strip.text = element_text(family = "JetBrains Mono", size = 10, color = "#241A3D"),
    plot.title = element_text(
      family = "Fraunces", size = 22, face = "bold", color = "#241A3D",
      margin = margin(t = 8, b = 10)
    ),
    plot.subtitle = element_text(
      family = "JetBrains Mono", size = 11, color = "#5C5178",
      margin = margin(t = 4, b = 28)
    ),
    plot.caption = element_text(
      family = "JetBrains Mono", size = 8, color = "#5C5178", hjust = 0,
      margin = margin(t = 34, b = 4)
    ),
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.margin = margin(34, 32, 22, 32),
    panel.spacing.y = grid::unit(12, "pt"),
    axis.title.x = element_text(family = "JetBrains Mono", size = 10, color = "#241A3D"),
    axis.title.y = element_text(
      family = "JetBrains Mono", size = 10, color = "#241A3D",
      margin = margin(r = 20)
    ),
    axis.text = element_text(family = "JetBrains Mono", size = 9, color = "#5C5178"),
    axis.ticks = element_line(color = "#CFC5DE"),
    legend.background = element_rect(fill = "#FBF9FE", color = NA),
    legend.key = element_rect(fill = "#FBF9FE", color = NA),
    legend.title = element_text(family = "JetBrains Mono", size = 10, color = "#241A3D"),
    legend.text = element_text(family = "JetBrains Mono", size = 9, color = "#5C5178")
  )

guardar_png(p3, file.path(output_path, "grafico_ielts_tipografias.png"), 3600, 2400, resolucion = 300)
guardar_png(p3, file.path(output_path, "grafico_ielts_1x1_1080x1080.png"), 1080, 1080)
guardar_png(p3, file.path(output_path, "grafico_ielts_instagram_4x5_1080x1350.png"), 1080, 1350)
guardar_png(p3, file.path(output_path, "grafico_ielts_historia_9x16_1080x1920.png"), 1080, 1920)
guardar_png(p3, file.path(output_path, "grafico_ielts_x_linkedin_1.91x1_1200x628.png"), 1200, 628)

logs <- log_message("Data processing workflow completed successfully.", logs, type="info")



#-----------------------------------------------------------------------------
# End of main.R
#-----------------------------------------------------------------------------
