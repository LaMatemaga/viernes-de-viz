#-----------------------------------------------------------------------------
# linkedin.R
#-----------------------------------------------------------------------------
#   Segundo export de las mismas láminas, ahora en SVG editable en Illustrator
#   para armar el reporte de historia de datos en PDF.
#   Solo salen el cuadrado y los apaisados: los verticales son para historias
#   y se quedan en main.R.
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Reusar los datos y las láminas de main.R
#-----------------------------------------------------------------------------

# main.R carga paquetes, registra fuentes, procesa los datos y construye las
# láminas. Los PNG ya los hace ese script, aquí solo interesan los SVG.
exportar_png <- FALSE
source("main.R")

output_svg <- file.path(output_path, "svg")
dir.create(output_svg, showWarnings = FALSE, recursive = TRUE)
logs <- log_message(paste0("Exportando SVG en ", output_svg), logs, type = "info")



#-----------------------------------------------------------------------------
# Export vectorial
#-----------------------------------------------------------------------------

for (lam in laminas) {
  # Las láminas de proporción fija necesitan su relleno para no quedar
  # centradas a media altura en el formato cuadrado.
  cuadrado <- if (is.null(lam$espacios)) {
    NULL
  } else {
    componer_con_espacio(lam$plot, lam$espacios[["1x1"]])
  }
  exportar_svg(lam$plot, lam$slug, output_svg, plot_1x1 = cuadrado)
  logs <- log_message(paste0("Exportado SVG: ", lam$slug), logs, type = "info")
}

for (lam in laminas_mapa) {
  # En apaisado el mapa va solo y en cuadrado lleva su gráfica de contexto,
  # con las mismas proporciones que el PNG.
  exportar_svg(
    lam$mapa, lam$slug, output_svg,
    plot_1x1 = componer_mapa_contexto(
      lam$mapa, lam$contexto,
      alturas = lam$alturas,
      espacio_inferior = lam$espacios[["1x1"]]
    )
  )
  logs <- log_message(paste0("Exportado SVG: ", lam$slug), logs, type = "info")
}

logs <- log_message("SVG exportados para edición en Illustrator.", logs, type = "info")



#-----------------------------------------------------------------------------
# End of linkedin.R
#-----------------------------------------------------------------------------
