#-----------------------------------------------------------------------------
# fuentes.R
#-----------------------------------------------------------------------------
#   Resolve and register Sterling fonts from the repo-level fonts/ folder.
#-----------------------------------------------------------------------------

ruta_fuentes <- function() {
  candidatos <- c(
    file.path("..", "fonts"),
    "fonts"
  )
  for (dir in candidatos) {
    if (file.exists(file.path(dir, "Fraunces-VariableFont_SOFT,WONK,opsz,wght.ttf"))) {
      return(normalizePath(dir, winslash = "/", mustWork = TRUE))
    }
  }
  stop(
    "No se encontraron las tipografías. Deben estar en fonts/ en la raíz del repositorio.",
    call. = FALSE
  )
}

registrar_fuentes_sterling <- function() {
  root <- ruta_fuentes()
  registrar <- function(alias, archivo) {
    ruta <- normalizePath(file.path(root, archivo), mustWork = TRUE)
    systemfonts::register_font(alias, plain = ruta, bold = ruta)
  }

  FUENTE_TITULO <- "Fraunces (proyecto)"
  FUENTE_SUB    <- "Inter (proyecto)"
  FUENTE_TEXTO  <- "JetBrains Mono (proyecto)"

  registrar(FUENTE_TITULO, "Fraunces-VariableFont_SOFT,WONK,opsz,wght.ttf")
  registrar(FUENTE_SUB,   "Inter-VariableFont_opsz,wght.ttf")
  registrar(FUENTE_TEXTO, "JetBrainsMono-VariableFont_wght.ttf")

  list(
    titulo = FUENTE_TITULO,
    sub    = FUENTE_SUB,
    texto  = FUENTE_TEXTO,
    root   = root
  )
}

#-----------------------------------------------------------------------------
# End of fuentes.R
#-----------------------------------------------------------------------------
