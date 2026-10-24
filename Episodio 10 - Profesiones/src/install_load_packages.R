#-----------------------------------------------------------------------------
# install_load_packages.R
#-----------------------------------------------------------------------------
#   Restore the renv lockfile if needed, then load required packages.
#   This episode does not call install.packages().
#   Paquetes nuevos: agregarlos aquí y en DESCRIPTION, luego renv::snapshot().
#   renv está en modo "explicit": el lockfile solo sigue lo que declara
#   DESCRIPTION, aunque el código lo llame con ::.
#-----------------------------------------------------------------------------

# Solo dplyr se usa sin prefijo (verbos y %>%). El resto se llama con
# paquete::función, así que library() solo confirma que está instalado.
# farver, gtable y tibble llegan como dependencias de ggplot2, pero el
# código los usa directamente y por eso van declarados.
packages <- c(
  "tidytuesdayR",
  "dplyr",
  "tibble",
  "ggplot2",
  "ggridges",
  "ggtext",
  "scales",
  "farver",
  "gtable",
  "ragg",
  "systemfonts"
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
