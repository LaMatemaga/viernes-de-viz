#-----------------------------------------------------------------------------
# install_load_packages.R
#-----------------------------------------------------------------------------
#   Restore the renv lockfile if needed, then load required packages.
#   This episode does not call install.packages().
#-----------------------------------------------------------------------------

packages <- c(
  "tidytuesdayR",
  "tidyverse",
  "ggplot2",
  "scales",
  "ragg",
  "svglite",
  "maps",
  "systemfonts",
  "waffle",
  "ggridges",
  "patchwork",
  "ggtext"
)

missing <- setdiff(packages, rownames(installed.packages()))
if (length(missing) > 0 && file.exists("renv.lock") && requireNamespace("renv", quietly = TRUE)) {
  renv::restore(prompt = FALSE)
  missing <- setdiff(packages, rownames(installed.packages()))
}

if (length(missing) > 0) {
  stop(
    paste0(
      "Faltan paquetes: ", paste(missing, collapse = ", "), ".\n",
      "Desde esta carpeta corre renv::restore(). ",
      "main.R no instala paquetes por su cuenta."
    ),
    call. = FALSE
  )
}

invisible(lapply(packages, library, character.only = TRUE))
rm(packages, missing)

#-----------------------------------------------------------------------------
# End of install_load_packages.R
#-----------------------------------------------------------------------------
