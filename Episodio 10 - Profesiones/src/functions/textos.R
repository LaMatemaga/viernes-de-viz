#-----------------------------------------------------------------------------
# textos.R
#-----------------------------------------------------------------------------
#   Todo el texto visible de las láminas, en español y en inglés.
#-----------------------------------------------------------------------------

IDIOMAS <- c("es", "en")

# Los nombres de área y de ritmo salarial en los datos son las llaves en
# español. Cada idioma solo cambia cómo se muestran.
# Las áreas son una agrupación propia de broad_field_short, sin nombre
# original en inglés: los nombres en inglés traducen los nuestros.
# Números: en español, espacio como separador de miles y espacio antes de
# % (norma SI, que la RAE adopta); en inglés, coma y % pegado.
# El texto de las láminas es afirmativo en ambos idiomas: describe lo que
# hay, sin contrastes de "X, no Y".

# Lectura cualitativa de cada área contra las demás carreras: egresados,
# mediana de exposición y de salario de entrada, y ritmo salarial. Se
# redactó con los datos de 2026-10-20 y hay que revisarla si cambian.
TEXTOS <- list(
  es = list(
    nombre_area = c(
      "Oficios y tecnologías"     = "Oficios y tecnologías",
      "Salud"                     = "Salud",
      "Artes"                     = "Artes",
      "Ingeniería y arquitectura" = "Ingeniería y arquitectura",
      "Ciencias y cómputo"        = "Ciencias y cómputo",
      "Negocios y derecho"        = "Negocios y derecho",
      "Letras y sociedad"         = "Letras y sociedad"
    ),
    ritmo = c(
      "Pierde poder adquisitivo" = "Pierde poder adquisitivo",
      "Queda igual"              = "Queda igual",
      "Le gana a la inflación"   = "Le gana a la inflación",
      "Crece fuerte"             = "Crece fuerte",
      "Se duplica"               = "Se duplica"
    ),
    fuente = paste(
      "Fuente: College Scorecard y AIOE (Felten, Raj y Seamans, 2021)",
      "/ TidyTuesday (2026-10-20)."
    ),
    credito = "Hecho durante #ViernesDeVisualizaciones por La Matemaga.",
    eje_x = "Exposición a la IA (z)",
    eje_y = "Salario de entrada (z)",
    tamano = "Un círculo más grande es un sueldo que creció más del primer al cuarto año.",
    ejes = "Las líneas negras marcan el promedio de cada eje.",
    exposicion_titulo = "Exposición a la IA por área",
    exposicion_subtitulo = paste(
      "Cada cresta muestra los empleos a los que lleva cada área.",
      "Más a la derecha, la IA alcanza más tareas del empleo.",
      "La línea negra marca el promedio de los empleos de EE. UU."
    ),
    egresados_titulo = "Egresados por área",
    egresados_subtitulo = "Cada barra suma los egresados de las carreras del área.",
    egresados_eje = "Egresados",
    separador_miles = " ",
    cuadrantes_titulo = "Exposición, salario de entrada y salto a cuatro años",
    cuadrantes_subtitulo = paste(
      "Cada círculo es una carrera universitaria en EE. UU.",
      "Más a la derecha, más expuestos a la IA están sus empleos.",
      "Más arriba, mejor sueldo al egresar."
    ),
    cuadrantes_leyenda = "Área",
    cuadrantes_etiquetas = c(
      "Menos expuesto a la IA\nMayor salario de entrada",
      "Más expuesto a la IA\nMayor salario de entrada",
      "Menos expuesto a la IA\nMenor salario de entrada",
      "Más expuesto a la IA\nMenor salario de entrada"
    ),
    area_leyenda = "Ritmo salarial (carreras)",
    area_guia = function(inflacion) {
      paste(
        "En color, las carreras del área. En gris, las demás.",
        "Un tono más oscuro es un sueldo que creció más rápido del primer al cuarto año.",
        paste0("La inflación de esos tres años fue de ", sprintf("%.1f", 100 * inflacion), " %.")
      )
    },
    insight = c(
      "Oficios y tecnologías" = paste(
        "Es el área menos expuesta a la IA.",
        "Reúne desde oficios manuales hasta técnicos en computación.",
        "Su sueldo de entrada supera al de la carrera típica, pero crece despacio."
      ),
      "Salud" = paste(
        "Es de las áreas con más egresados y sus empleos están poco expuestos a la IA.",
        "El sueldo de entrada es modesto y muy desigual entre carreras.",
        "Aquí está la mayor cantidad de carreras que duplican su sueldo en cuatro años."
      ),
      "Artes" = paste(
        "Es el área con menos egresados y el sueldo de entrada más bajo.",
        "Sus empleos están poco expuestos a la IA.",
        "Todas sus carreras crecen fuerte en los primeros años."
      ),
      "Ingeniería y arquitectura" = paste(
        "Paga el mejor sueldo de entrada de todas las áreas.",
        "Sus empleos están muy expuestos a la IA, y casi todos por igual.",
        "Como arranca alto, es el área cuyo sueldo crece más despacio."
      ),
      "Ciencias y cómputo" = paste(
        "Sus empleos están muy expuestos a la IA.",
        "Las carreras de cómputo arrancan entre los mejores sueldos.",
        "La mayoría de sus carreras crece fuerte en los primeros cuatro años."
      ),
      "Negocios y derecho" = paste(
        "Es el área con más egresados y sus empleos están muy expuestos a la IA.",
        "Su sueldo arranca un poco arriba de la carrera típica y crece parejo.",
        "Ninguna de sus carreras se queda atrás ni duplica su sueldo."
      ),
      "Letras y sociedad" = paste(
        "Aquí están la docencia y la psicología.",
        "Es la segunda área con más egresados y la más expuesta a la IA.",
        "Su sueldo de entrada está abajo de la carrera típica.",
        "Aun así, la mayoría de sus carreras crece fuerte en cuatro años."
      )
    ),
    # El público es de desarrollo, datos, matemáticas y educación, así que
    # esas carreras entran siempre. El resto entra por un motivo: muchos
    # egresados, relevancia social, o un sueldo de entrada notablemente
    # alto o bajo.
    # Las llaves son el field_of_study exacto de los datos. En español la
    # etiqueta es el nombre habitual de la carrera en México ("Terapia de
    # lenguaje" para Communication Disorders).
    etiqueta = c(
      # Oficios y tecnologías
      "Criminal Justice and Corrections" = "Justicia penal",
      "Sports, Kinesiology, and Physical Education/Fitness" = "Educación física",
      "Natural Resources Conservation and Research" = "Conservación ambiental",
      "Electrical/Electronic Engineering Technologies/Technicians" = "Técnico en electrónica",
      "Construction Engineering Technology/Technician" = "Técnico en construcción",
      "Computer Engineering Technologies/Technicians" = "Técnico en computación",
      "International Agriculture" = "Agricultura internacional",
      # Salud
      "Registered Nursing, Nursing Administration, Nursing Research and Clinical Nursing" = "Enfermería",
      "Health and Medical Administrative Services" = "Administración en salud",
      "Public Health" = "Salud pública",
      "Clinical/Medical Laboratory Science/Research and Allied Professions" = "Laboratorio clínico",
      "Health Professions Education, Ethics, and Humanities" = "Docencia y ética en salud",
      "Medical Illustration and Informatics" = "Informática médica",
      "Communication Disorders Sciences and Services" = "Terapia de lenguaje",
      # Artes
      "Fine and Studio Arts" = "Artes plásticas",
      "Design and Applied Arts" = "Diseño",
      "Drama/Theatre Arts and Stagecraft" = "Teatro",
      "Film/Video and Photographic Arts" = "Cine y fotografía",
      "Music" = "Música",
      "Dance" = "Danza",
      # Ingeniería y arquitectura
      "Mechanical Engineering" = "Ing. mecánica",
      "Electrical, Electronics, and Communications Engineering" = "Ing. eléctrica y electrónica",
      "Civil Engineering" = "Ing. civil",
      "Computer Engineering" = "Ing. en computación",
      "Chemical Engineering" = "Ing. química",
      "Industrial Engineering" = "Ing. industrial",
      "Architecture" = "Arquitectura",
      # Ciencias y cómputo
      "Mathematics and Computer Science" = "Matemáticas y cómputo",
      "Computer Science" = "Ciencias de la computación",
      "Computer and Information Sciences, General" = "Informática",
      "Statistics" = "Estadística",
      "Applied Mathematics" = "Matemáticas aplicadas",
      "Computer Programming" = "Programación",
      "Mathematics" = "Matemáticas",
      "Biology, General" = "Biología",
      # Negocios y derecho
      "Management Sciences and Quantitative Methods" = "Métodos cuantitativos",
      "Management Information Systems and Services" = "Sistemas de información",
      "Accounting and Related Services" = "Contaduría",
      "Finance and Financial Management Services" = "Finanzas",
      "Marketing" = "Mercadotecnia",
      "Business Administration, Management and Operations" = "Administración",
      "Social Work" = "Trabajo social",
      # Letras y sociedad
      "Economics" = "Economía",
      "Bilingual, Multilingual, and Multicultural Education" = "Educación bilingüe",
      "Teacher Education and Professional Development, Specific Subject Areas" = "Docencia por materia",
      "Special Education and Teaching" = "Educación especial",
      "Teacher Education and Professional Development, Specific Levels and Methods" = "Formación docente",
      "Educational Administration and Supervision" = "Gestión escolar",
      "Psychology, General" = "Psicología",
      "Educational Assessment, Evaluation, and Research" = "Evaluación educativa",
      "Philosophy" = "Filosofía"
    )
  ),
  en = list(
    nombre_area = c(
      "Oficios y tecnologías"     = "Trades and technology",
      "Salud"                     = "Health",
      "Artes"                     = "Arts",
      "Ingeniería y arquitectura" = "Engineering and architecture",
      "Ciencias y cómputo"        = "Science and computing",
      "Negocios y derecho"        = "Business and law",
      "Letras y sociedad"         = "Humanities and society"
    ),
    ritmo = c(
      "Pierde poder adquisitivo" = "Loses purchasing power",
      "Queda igual"              = "Holds steady",
      "Le gana a la inflación"   = "Beats inflation",
      "Crece fuerte"             = "Grows strongly",
      "Se duplica"               = "Doubles"
    ),
    fuente = paste(
      "Source: College Scorecard and AIOE (Felten, Raj & Seamans, 2021)",
      "/ TidyTuesday (2026-10-20)."
    ),
    credito = "Made during #ViernesDeVisualizaciones by La Matemaga.",
    eje_x = "AI exposure (z)",
    eje_y = "Starting salary (z)",
    tamano = "A larger circle is a salary that grew more from the first to the fourth year.",
    ejes = "The black lines mark the average on each axis.",
    exposicion_titulo = "AI exposure by area",
    exposicion_subtitulo = paste(
      "Each ridge shows the jobs each area leads to.",
      "Further right, AI reaches more of the job's tasks.",
      "The black line marks the average across US jobs."
    ),
    egresados_titulo = "Graduates by area",
    egresados_subtitulo = "Each bar adds up the graduates of the area's majors.",
    egresados_eje = "Graduates",
    separador_miles = ",",
    cuadrantes_titulo = "Exposure, starting salary and the four-year jump",
    cuadrantes_subtitulo = paste(
      "Each circle is a college major in the US.",
      "Further right, its jobs are more exposed to AI.",
      "Higher up, a better salary at graduation."
    ),
    cuadrantes_leyenda = "Area",
    cuadrantes_etiquetas = c(
      "Less exposed to AI\nHigher starting salary",
      "More exposed to AI\nHigher starting salary",
      "Less exposed to AI\nLower starting salary",
      "More exposed to AI\nLower starting salary"
    ),
    area_leyenda = "Salary growth (majors)",
    area_guia = function(inflacion) {
      paste(
        "In color, the area's majors. In gray, all the others.",
        "A darker shade is a salary that grew faster from the first to the fourth year.",
        paste0("Inflation over those three years was ", sprintf("%.1f", 100 * inflacion), "%.")
      )
    },
    insight = c(
      "Oficios y tecnologías" = paste(
        "It is the area least exposed to AI.",
        "It ranges from manual trades to computer technicians.",
        "Its starting salary beats the typical major's, but it grows slowly."
      ),
      "Salud" = paste(
        "It is among the areas with the most graduates, and its jobs are less exposed to AI.",
        "Starting salaries are modest and very uneven across majors.",
        "It has the most majors that double their salary in four years."
      ),
      "Artes" = paste(
        "It has the fewest graduates and the lowest starting salary.",
        "Its jobs are less exposed to AI.",
        "All of its majors grow strongly in the first years."
      ),
      "Ingeniería y arquitectura" = paste(
        "It pays the highest starting salary of any area.",
        "Its jobs are highly exposed to AI, almost all to the same degree.",
        "Since it starts high, its salary grows the slowest."
      ),
      "Ciencias y cómputo" = paste(
        "Its jobs are highly exposed to AI.",
        "Computing majors start among the highest salaries.",
        "Most of its majors grow strongly in the first four years."
      ),
      "Negocios y derecho" = paste(
        "It has the most graduates, and its jobs are highly exposed to AI.",
        "Its salary starts slightly above the typical major's and grows evenly.",
        "None of its majors falls behind or doubles its salary."
      ),
      "Letras y sociedad" = paste(
        "Teaching and psychology are here.",
        "It has the second most graduates and is the area most exposed to AI.",
        "Its starting salary is below the typical major's.",
        "Even so, most of its majors grow strongly within four years."
      )
    ),
    # Recortes del nombre original de College Scorecard, sin pasar por el
    # español. Hasta unos 24 caracteres: en el 1.91x1 el panel mide unas
    # 5 pulgadas y la columna de etiquetas no debe rebasar el lienzo.
    etiqueta = c(
      # Oficios y tecnologías
      "Criminal Justice and Corrections" = "Criminal justice",
      "Sports, Kinesiology, and Physical Education/Fitness" = "Kinesiology and PE",
      "Natural Resources Conservation and Research" = "Natural res. conservation",
      "Electrical/Electronic Engineering Technologies/Technicians" = "Electrical eng. tech.",
      "Construction Engineering Technology/Technician" = "Construction eng. tech.",
      "Computer Engineering Technologies/Technicians" = "Computer eng. tech.",
      "International Agriculture" = "International agriculture",
      # Salud
      "Registered Nursing, Nursing Administration, Nursing Research and Clinical Nursing" = "Registered nursing",
      "Health and Medical Administrative Services" = "Health admin. services",
      "Public Health" = "Public health",
      "Clinical/Medical Laboratory Science/Research and Allied Professions" = "Clinical lab science",
      "Health Professions Education, Ethics, and Humanities" = "Health professions ed.",
      "Medical Illustration and Informatics" = "Med. illus./informatics",
      "Communication Disorders Sciences and Services" = "Communication disorders",
      # Artes
      "Fine and Studio Arts" = "Fine and studio arts",
      "Design and Applied Arts" = "Design and applied arts",
      "Drama/Theatre Arts and Stagecraft" = "Drama and theatre arts",
      "Film/Video and Photographic Arts" = "Film, video and photo.",
      "Music" = "Music",
      "Dance" = "Dance",
      # Ingeniería y arquitectura
      "Mechanical Engineering" = "Mechanical eng.",
      "Electrical, Electronics, and Communications Engineering" = "Elec./electronics eng.",
      "Civil Engineering" = "Civil eng.",
      "Computer Engineering" = "Computer eng.",
      "Chemical Engineering" = "Chemical eng.",
      "Industrial Engineering" = "Industrial eng.",
      "Architecture" = "Architecture",
      # Ciencias y cómputo
      "Mathematics and Computer Science" = "Math and computer science",
      "Computer Science" = "Computer science",
      "Computer and Information Sciences, General" = "Computer & info. sciences",
      "Statistics" = "Statistics",
      "Applied Mathematics" = "Applied mathematics",
      "Computer Programming" = "Computer programming",
      "Mathematics" = "Mathematics",
      "Biology, General" = "Biology",
      # Negocios y derecho
      "Management Sciences and Quantitative Methods" = "Management sciences",
      "Management Information Systems and Services" = "Management info. systems",
      "Accounting and Related Services" = "Accounting",
      "Finance and Financial Management Services" = "Finance",
      "Marketing" = "Marketing",
      "Business Administration, Management and Operations" = "Business administration",
      "Social Work" = "Social work",
      # Letras y sociedad
      "Economics" = "Economics",
      "Bilingual, Multilingual, and Multicultural Education" = "Bilingual education",
      "Teacher Education and Professional Development, Specific Subject Areas" = "Teacher ed. (subjects)",
      "Special Education and Teaching" = "Special education",
      "Teacher Education and Professional Development, Specific Levels and Methods" = "Teacher ed. (levels)",
      "Educational Administration and Supervision" = "Educational admin.",
      "Psychology, General" = "Psychology",
      "Educational Assessment, Evaluation, and Research" = "Educational assessment",
      "Philosophy" = "Philosophy"
    )
  )
)

local({
  llaves <- lapply(TEXTOS, function(tx) {
    list(sort(names(tx)), sort(names(tx$etiqueta)), names(tx$nombre_area), names(tx$ritmo), names(tx$insight))
  })
  if (!identical(llaves$es, llaves$en)) {
    stop("TEXTOS$es y TEXTOS$en no tienen las mismas llaves.", call. = FALSE)
  }
})

pie_fuente <- function(tx) {
  paste(tx$fuente, tx$credito, sep = "<br>")
}
