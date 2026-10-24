#-----------------------------------------------------------------------------
# visualizaciones.R
#-----------------------------------------------------------------------------
#   Estilo Sterling, gráficas del episodio y exportación a output/.
#-----------------------------------------------------------------------------

# --- Tipografías -------------------------------------------------------------
# Los alias los registra registrar_fuentes_sterling() en fuentes.R.
#   Fraunces (proyecto)        -> título
#   Inter (proyecto)           -> subtítulo
#   JetBrains Mono (proyecto)  -> ejes, valores, pie

# --- Paleta Sterling ---------------------------------------------------------
# Papel, panel, tinta, tinta secundaria y retícula.
# Voces categóricas para los campos o las series de este episodio.

# --- Pie editorial -----------------------------------------------------------
# source_line: College Scorecard, AIOE (Felten, Raj y Seamans, 2021) / TidyTuesday (2026-10-20)
# credit_line: Hecho durante #ViernesDeVisualizaciones por La Matemaga.

# --- Temas -------------------------------------------------------------------
# tema_sterling(): títulos, subtítulo, caption y márgenes.

# --- Gráficas ----------------------------------------------------------------
# Una función por lámina. Reciben el data frame ya procesado en main.R.

# --- Exportación -------------------------------------------------------------
# exportar_laminas(plot, slug, output_path): PNG master y recortes.
# exportar_vectorial(): SVG para Illustrator, si hace falta.

#-----------------------------------------------------------------------------
# End of visualizaciones.R
#-----------------------------------------------------------------------------
