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

tuesdata <- tidytuesdayR::tt_load(2026, week = 35)
world_castles <- tuesdata$world_castles
logs <- log_message("Loaded TidyTuesday world_castles dataset.", logs, type="info")

world_castles$iso[world_castles$country == "Namibia"] <- "NA"
world_castles <- left_join(world_castles, paises_iso_continente, by = join_by(iso == iso)) %>%
  mutate(name = trimws(gsub("\\s*\\([^)]*\\)", "", name)))
paises_NA <- world_castles %>% filter(is.na(continent)) %>% select(country, iso)
if (dim(paises_NA)[1] == 0) {
  rm(paises_NA)
}

world_castles$category <- factor(
  world_castles$category,
  levels = c("castle", "palace", "fortress", "ruin")
)
world_castles$etiqueta <- paste0(
  encajar(world_castles$name), "\n", encajar(world_castles$pais)
)

continentes <- c("América", "Asia", "África", "Oceanía", "Europa", "global")
top_vistas <- list()

for (c in seq_along(continentes)) {
  cont <- continentes[c]

  top_vistas[[c]] <- list()
  top_vistas[[c]]$continente <- cont
  if (cont == "global") {
    top_vistas[[c]]$data <- bind_rows(
      lapply(top_vistas[seq_len(c - 1)], function(x) slice_head(x$data, n = 1))
    ) %>%
      arrange(desc(pageviews))
  } else {
    top_vistas[[c]]$data <- world_castles %>%
      filter(continent == cont, !is.na(pageviews)) %>%
      slice_max(order_by = pageviews, n = 5) %>%
      arrange(desc(pageviews))
  }
  top_vistas[[c]]$grafica <- grafica_continente(top_vistas[[c]]$data, cont)

  if (interactive()) print(top_vistas[[c]]$grafica)
}

for (c in seq_along(continentes)) {
  p <- top_vistas[[c]]$grafica
  s <- slug[[continentes[c]]]
  guardar_png(p, file.path(output_path, paste0("castillos_", s, "_master.png")), 3600, 2400, resolucion = 300)
  guardar_png(p, file.path(output_path, paste0("castillos_", s, "_1x1.png")),    1080, 1080)
  guardar_png(p, file.path(output_path, paste0("castillos_", s, "_4x5.png")),    1080, 1350)
  guardar_png(p, file.path(output_path, paste0("castillos_", s, "_9x16.png")),   1080, 1920)
  guardar_png(p, file.path(output_path, paste0("castillos_", s, "_1.91x1.png")), 1200, 628)
}

logs <- log_message("Data processing workflow completed successfully.", logs, type="info")



#-----------------------------------------------------------------------------
# End of main.R
#-----------------------------------------------------------------------------
