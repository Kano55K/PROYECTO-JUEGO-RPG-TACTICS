## P-001 — Qué significa "afines" en la muerte en el grupo
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T04
- **Fecha:** 03/10/2026
- **Fuente:** `Sistema.md` 5.2, fila "Muere o es comida otra criatura del grupo: −2 a todas las sueltas (−4 si eran afines)"
- **Duda:** ¿"afines" significa que la especie de la que murió y la de cada suelta se llevan "bien" (10.8), evaluado suelta por suelta, o se usa la afinidad de combate de 10.3 (relación "bien" y además adyacentes en el tablero)?
- **Caso que la dispara:** el Maestro huye y muere una Rodauva caída. Quedan sueltas otra Rodauva (Rodauva–Rodauva: bien), un Surcón (Rodauva–Surcón: bien) y una Ocarra leal (Rodauva–Ocarra: sin relación). ¿La Ocarra recibe −2 o −4?
- **Opciones:** A) solo la relación de especie, suelta por suelta: Rodauva −4, Surcón −4, Ocarra −2. B) afinidad de combate (10.3): −4 solo a las que se llevan bien con la muerta y estaban adyacentes a ella al morir; el resto, −2. — Recomendación técnica: A (no depende de la posición, y la muerte por huida o derrota ocurre con el combate ya terminado).
- **Bloquea:** no. El esquema `lealtad` guarda los dos números (`eventos.muerte_en_el_grupo` y `eventos.muerte_en_el_grupo_afines`); la regla se programa en T10.
- **Mientras tanto:** solo están los campos en el esquema; no hay código que elija entre −2 y −4.
- **Respuesta:** `Sistema.md` 5.2 v1.1 (03/10/2026): opción A. "Afines" es la relación de especie (10.8), mirada suelta por suelta: −4 a cada suelta cuya especie se lleve bien con la de la muerta; −2 al resto. La posición no cuenta. En el caso: Rodauva −4, Surcón −4, Ocarra −2. Además, regla nueva: todos los cambios de lealtad de un combate (o de una noche) se suman y el total se recorta a 0–10 una sola vez. Se aplica en T10.
- **Cerrada en:** T10

## P-002 — Afines de la atacante comida por el Maestro
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T04
- **Fecha:** 03/10/2026
- **Fuente:** `Sistema.md` 5.2, filas "Muere o es comida otra criatura del grupo: −2 a todas las sueltas (−4 si eran afines)" y "El Maestro se come a una criatura que lo atacó: Solo −2 a todas las sueltas (sin el −3 extra)"; 9.3
- **Duda:** cuando el Maestro se come a la atacante, ¿las sueltas afines a ella reciben −2 como todas, o −4 como en cualquier muerte en el grupo?
- **Caso que la dispara:** una Ocarra ataca de noche, es derrotada y el Maestro se la come. Quedan sueltas una Rodauva y otra Ocarra; si la otra Ocarra fuera afín a la atacante, ¿recibe −2 o −4?
- **Opciones:** A) −2 a todas, sin excepción ("solo −2 a todas"). B) −2 a todas y −4 a las afines (la fila de muerte en el grupo sigue aplicando; "solo" quita únicamente el −3 extra). — Recomendación técnica: A (es la lectura literal).
- **Bloquea:** no. `tablas/lealtad.json` guarda `eventos.comer_atacante: -2` y `eventos.muerte_en_el_grupo_afines: -4`; la regla se programa en T10.
- **Mientras tanto:** solo están los datos; no hay código que elija.
- **Respuesta:** `Sistema.md` 5.2 v1.1 (03/10/2026): opción A. −2 en total a todas las sueltas, incluidas sus afines; reemplaza a la fila de muerte en el grupo y no suma el −3 extra. Se aplica en T30.
- **Cerrada en:** T30

## P-003 — Tramos de obediencia y estados de lealtad
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T04
- **Fecha:** 03/10/2026
- **Fuente:** `Sistema.md` 5.4, tabla de obediencia (filas "≥ umbral de rescate", "4 hasta umbral − 1", "≤ 3"), y 5.1 (Desleal 0–1, Dudosa 2–3, Neutral 4 hasta umbral − 1)
- **Duda:** ¿los tramos de obediencia de 5.4 son los mismos cortes que los estados de lealtad de 5.1 (aplicados a la obediencia), o son umbrales propios que se pueden ajustar por separado?
- **Caso que la dispara:** si un ajuste de balance mueve Neutral de 5.1 a "desde 5", ¿una criatura con obediencia 4 pasa al tramo "≤ 3" (+10 Encono, +20 cobardía, ataca a la rival aliada) o sigue en el tramo normal?
- **Opciones:** A) mismos cortes: el código lee el límite de `tablas/lealtad.json` (`dudosa_hasta`) y se quita `obediencia.baja.hasta` de `tablas/combate.json`. B) umbrales propios: queda `obediencia.baja.hasta: 3` en `tablas/combate.json`. — Recomendación técnica: A (la fila de 5.4 repite la de 5.1 y así cada número vive en un solo archivo).
- **Bloquea:** no. Hoy los dos valen 3 y dan el mismo resultado.
- **Mientras tanto:** `tablas/combate.json` guarda `obediencia.baja.hasta: 3` citando 5.4; no hay código que lo lea todavía.
- **Respuesta:** `Sistema.md` 5.4 v1.1 (03/10/2026): opción A. Los tramos de obediencia usan los mismos cortes que los estados de lealtad de 5.1 (piso de Neutral y umbral de rescate); cada número en un solo dato. Se aplica en T14, que quita `obediencia.baja.hasta` de `tablas/combate.json`.
- **Cerrada en:** T14

## P-004 — Lealtad de "leal" y "Neutral" en los escenarios
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T04
- **Fecha:** 03/10/2026
- **Fuente:** `Sistema.md` 11.9, columna Configuración (B: "Rodauva Neutral (5)"; F: "Rodauva leal", "Ocarra Neutral"; E: "Surcón leal"; G: tribu sin número)
- **Duda:** ¿se confirman lealtad 8 para "leal" y 5 para "Neutral" donde 11.9 no da el número?
- **Caso que la dispara:** F pide "Rodauva leal" y "Ocarra Neutral" sin número; con la balanza en 2 (umbral 7) cualquier valor de 7 a 10 es leal y de 4 a 6 es Neutral. En H (umbral 8), un 7 dejaría de ser leal.
- **Opciones:** A) 8 y 5, valores provisorios que fijó el Arquitecto (8 sigue leal con la balanza en 5). B) otros valores. — Recomendación técnica: A.
- **Bloquea:** no
- **Mientras tanto:** los 11 escenarios usan 8 y 5.
- **Respuesta:** `Sistema.md` 11.9 v1.1 (03/10/2026): opción A. Leal 8, Neutral 5. Ya está en los datos (T04).
- **Cerrada en:** T05

## P-005 — El Maestro en todos los escenarios
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T04
- **Fecha:** 03/10/2026
- **Fuente:** `Sistema.md` 11.9, columna Configuración de D y E (no nombran al Maestro) y "Reglas de los escenarios"
- **Duda:** ¿se confirma que el Maestro está en todos los escenarios con sus valores iniciales (balanza 2, Poder 1, Regeneración 1, vida y maná completos, hambre 3) salvo lo que 11.9 indica?
- **Caso que la dispara:** D dice "Ocarra + Zancajunco contra Surcón + Rodauva" y E "Rodauva leal, Rodauva Neutral y Surcón contra el Tasajero", sin el Maestro. Sin él no hay Lanzadera (D) ni "Maestro al lado" (E), que es lo que miden.
- **Opciones:** A) Maestro con sus valores iniciales en todos, valor provisorio que fijó el Arquitecto. B) D y/o E sin Maestro. — Recomendación técnica: A.
- **Bloquea:** no
- **Mientras tanto:** el Maestro está en los 11, con valores iniciales salvo F (vida 6), G (maná de entrada 4), H (balanza 5 y Poder 3) y `d_rivales_balanza4` (balanza 4).
- **Respuesta:** `Sistema.md` 11.9 v1.1 (03/10/2026): opción A. El Maestro está en los 11 escenarios con sus valores iniciales, salvo F, G, H y `d_rivales_balanza4`. Ya está en los datos (T04).
- **Cerrada en:** T05

## P-006 — Hambre del Maestro en D Hambriento
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T04
- **Fecha:** 03/10/2026
- **Fuente:** `Sistema.md` 11.9, fila D ("Hambre 3 y 6")
- **Duda:** en `d_rivales_hambriento`, ¿solo las criaturas tienen hambre 6, o también el Maestro?
- **Caso que la dispara:** con el Maestro en 6 (Hambriento) regenera maná solo en rondas pares (2.2) y la Lanzadera para separarlas cuesta más; la variante dejaría de aislar el efecto de la obediencia.
- **Opciones:** A) solo las criaturas en 6; el Maestro en 3 (valor provisorio que fijó el Arquitecto). B) todos en 6. — Recomendación técnica: A.
- **Bloquea:** no
- **Mientras tanto:** Ocarra y Zancajunco con hambre 6; Maestro con hambre 3.
- **Respuesta:** `Sistema.md` 11.9 v1.1 (03/10/2026): opción A. Hambre 6 solo en las criaturas; el Maestro en 3. Ya está en los datos (T04).
- **Cerrada en:** T05

## P-007 — Posiciones iniciales de los escenarios
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T04
- **Fecha:** 03/10/2026
- **Fuente:** `Sistema.md` 11.9, "Reglas de los escenarios" ("todos usan posiciones fijas") y 11.3 (despliegue: tribu en las 2 filas de su borde, salvajes en las 2 opuestas)
- **Duda:** ¿se confirman las posiciones iniciales propuestas (tribu en filas 6–7, salvajes en 0–1; la atacante de G en [3,4])?
- **Caso que la dispara:** se revisaron con la IA de 11.8 y el jugador quieto. Coordenadas `[x, y]`, `y = 0` arriba. Motivo de cada una:
  - **A:** M [3,7], Rodauva [4,7], Ocarra [4,0]. Copia del ejemplo de `Arquitectura.md` A.2.
  - **B:** M [3,6], Rodauva [4,7], Ocarras [0,0] y [7,1]. Con las del borrador ([1,0] y [6,0]) la IA las deja adyacentes en la ronda 1 y el incidente sale gratis. Así llegan en diagonal sin tocarse (ronda 1: [3,0] y [4,1]; ronda 2: [3,3] y [4,4]) y la Lanzadera las junta con 1 paso del Maestro.
  - **C y H:** M [3,6], Rodauva [2,6], Ocarra [3,7], Zancajunco [4,6], Tasajero [3,0]. El Tasajero pega en la Cuenta de la ronda 1 (meta de 2 o 3 rondas) y va por la Rodauva; ella actúa antes de la Cuenta, así que su suerte es decisión del jugador. Ocarra detrás del Maestro, en diagonal al Zancajunco. H repite C.
  - **D (3 variantes):** M [3,6], Ocarra [3,7], Zancajunco [4,7], Surcón [3,1], Rodauva [4,1]. Las rivales empiezan adyacentes: el riesgo de incidente se ve desde el primer turno, y separarlas (o no) es la primera decisión. Separadas, la alarma "menos del 20% con algún incidente" podía saltar solo porque nunca se juntan.
  - **E (2 variantes):** M [4,6], Rodauva leal [6,6], Rodauva Neutral [6,7], Surcón [4,7], Tasajero [0,0]. Con el Tasajero en [3,0] la primera tirada de cobardía cae en la ronda 1, antes de que el Maestro pueda moverse (Vel 6 contra 5). Con el Tasajero en la esquina opuesta, la primera tirada es en la ronda 2, con la formación que eligió el jugador.
  - **F:** M [3,6] (vida 6), Rodauva [3,7], Ocarra [4,7], Zancajunco [3,0], Surcón [4,1]. El borrador de Sistemas, sin cambios: el Zancajunco llega a [3,4] en la ronda 1 y en la ronda 2 su golpe de 6 tumba al Maestro, salvo que se lo bloquee o se encone con la Ocarra.
  - **G:** M [3,6], Rodauva [2,6], Zancajunco [4,6], Ocarra atacante [3,4]. La atacante no es salvaje y acaba de golpear al Maestro dormido: queda a distancia 2 en línea con él, como en el borrador del Arquitecto. Es la única enemiga fuera de las filas 0–1.
- **Opciones:** A) confirmar las posiciones (valores provisorios propuestos por Claude Code y aprobados por el Arquitecto). B) cambiar las de algún escenario. — Recomendación técnica: A.
- **Bloquea:** no
- **Mientras tanto:** los 11 archivos usan estas posiciones; el panel (T31) las podrá cambiar.
- **Respuesta:** `Sistema.md` 11.9 v1.1 (03/10/2026): opción A. Posiciones aprobadas como provisorias. Ante una alarma de 11.9, primero se descarta que la causa sea la posición; después se toca la regla. Ya está en los datos (T04).
- **Cerrada en:** T05

## P-008 — El Maestro en el toggle de afines contra la cobardía
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T04
- **Fecha:** 03/10/2026
- **Fuente:** `Sistema.md` 10.6, PROPUESTA del toggle ("cada afín adyacente resta −10 puntos, máximo −20, mínimo 5%") y 10.3 ("el Maestro es afín de toda criatura con obediencia ≥ umbral de rescate")
- **Duda:** con el toggle activo, ¿el Maestro adyacente a una criatura leal cuenta también como "afín adyacente" (−10 más), además de su −10 propio de "el Maestro está adyacente"?
- **Caso que la dispara:** escenario E con el toggle, balanza 2: Rodauva leal con solo el Maestro al lado. Si cuenta dos veces: 25 − 10 − 10 = 5%. Si no: 25 − 10 = 15%.
- **Opciones:** A) no cuenta como afín para el toggle: solo su −10 de 10.6. B) cuenta las dos veces. — Recomendación técnica: A (el toggle anticipa la barra de zozobra entre criaturas; el Maestro ya tiene su fila).
- **Bloquea:** no (se programa en T19)
- **Mientras tanto:** la `_nota` de `e_cobardia_afines` no da ese número y remite a esta pregunta.
- **Respuesta:** `Sistema.md` 10.6 v1.1 (03/10/2026): opción A. El Maestro no cuenta como afín adyacente para el toggle: solo su −10 propio. En el caso: 15%. Se aplica en T19.
- **Cerrada en:** T19

## P-009 — Objetivo de la Ocarra en las Pruebas A y B
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T04
- **Fecha:** 03/10/2026
- **Fuente:** `Sistema.md` 11.6 (Prueba A: "Ocarra: Maestro 20 → 16"; Prueba B: "el Maestro recibe 8 por ronda") contra 11.8 (desempates: remate → menos vida actual → más cercana)
- **Duda:** ¿11.6 es solo una cuenta de referencia y en el juego manda la IA de 11.8, aunque la Ocarra vaya por la Rodauva en vez de por el Maestro?
- **Caso que la dispara:** en `a_dia_1` (posiciones del ejemplo de A.2), la Ocarra en [4,0] no alcanza a nadie en la ronda 1; en la ronda 2 elige a la Rodauva (8 de vida, menos que el Maestro) y la tumba en dos golpes. En B, las dos Ocarras van primero por la Rodauva. La tabla de 11.6 supone que pegan al Maestro desde la ronda 1.
- **Opciones:** A) manda 11.8; 11.6 es referencia de daño y la decisión de A (sellar al 50% o arriesgar) sigue en pie. B) A y B necesitan otras posiciones o una regla para que la Ocarra pegue al Maestro. — Recomendación técnica: A.
- **Bloquea:** no
- **Mientras tanto:** `a_dia_1` queda copiado tal cual del ejemplo de A.2.
- **Respuesta:** `Sistema.md` 11.6 v1.1 (03/10/2026): opción A. Manda la IA de 11.8; 11.6 es referencia de daño. Hay que actualizar la `_nota` de `a_dia_1.json`: la apuesta es la Rodauva, no la vida del Maestro. Se aplica en T05.
- **Cerrada en:** T05

## P-010 — Criterio (2) de T05: pergaminos de las Ocarras de B
- **Estado:** CERRADA
- **Para:** ARQUITECTO
- **Tarea:** T05
- **Fecha:** 04/10/2026
- **Fuente:** `Arquitectura.md` B.2, fila T05, criterio (2) ("las dos Ocarras de B son independientes: […] y tienen pergaminos distintos") contra la misma fila ("las salvajes no [ocupan pergamino]") y `Sistema.md` 3.2 (ocupa pergamino cada criatura de la tribu)
- **Duda:** ¿el criterio (2) debe comprobar que las dos Ocarras de B *no* tienen pergamino, ya que son salvajes?
- **Caso que la dispara:** en `b_muro` las dos Ocarras (`ocarra_s1`, `ocarra_s2`) son enemigas salvajes: por 3.2 ninguna ocupa pergamino, así que no pueden tener "pergaminos distintos".
- **Opciones:** A) en (2) se comprueba la independencia de la vida y que ninguna tiene pergamino; que criaturas distintas tengan pergaminos distintos ya lo cubre el criterio (4) en G. B) el criterio (2) usa otro escenario con dos criaturas de la misma especie en la tribu. — Recomendación técnica: A.
- **Bloquea:** no
- **Mientras tanto:** manda `Sistema.md` 3.2: las salvajes no tienen pergamino. El test (2) (`pruebas/unidades/test_plantel.gd`) comprueba que la vida es independiente y que las dos quedan sin pergamino.
- **Respuesta:** Arquitecto (04/10/2026): opción A. Error del criterio: las salvajes no tienen pergamino (`Sistema.md` 3.2); el test (2) queda como está. La independencia de pergaminos se prueba con las dos Rodauvas de la tribu de E: nuevo test (8) de T05 en `Arquitectura.md` v0.10.
- **Cerrada en:** T06 (test (8) de T05, `pruebas/unidades/test_plantel.gd`)

## P-011 — Empate de Velocidad entre dos enemigas
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T07
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.3, fila Empates (desempata tribu contra enemigas, Maestro contra criaturas y criaturas de la tribu entre sí, pero no dos enemigas entre sí). Es la S-14 de `Arquitectura.md` 10.5
- **Duda:** dos enemigas con la misma Velocidad, ¿actúan en el orden de la lista `enemigas` del escenario?
- **Caso que la dispara:** escenario B: `ocarra_s1` y `ocarra_s2`, las dos con Velocidad 7.
- **Opciones:** A) orden de la lista `enemigas` (como el orden de la tribu). B) otra regla (por ejemplo, la más cercana al Maestro primero). — Recomendación técnica: A (lectura declarada del Arquitecto, S-14).
- **Bloquea:** no
- **Mientras tanto:** programado con A en `nucleo/combate/cola_iniciativa.gd`; test (5) de T07 (`pruebas/combate/test_cola_iniciativa.gd`). Si Sistemas elige otra regla, cambia un desempate y ese test.
- **Respuesta:** `Sistema.md` 11.3 v1.2 (04/10/2026): opción A. Entre enemigas con la misma Velocidad, el orden de la lista `enemigas` del escenario. En 0b, los encuentros generados ordenan la lista según la columna Composición de 11.6. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T12 (sin cambios de código)

## P-012 — Unidad que deja de poder actuar a mitad de ronda
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T07
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.5 (la caída "no actúa"; la salvaje en 0 "huye del tablero") y 11.3 (fila Criatura invocada)
- **Duda:** si una unidad queda caída, es guardada o sale del tablero después de armada la cola, ¿pierde todos sus turnos restantes de esa ronda, incluida la Cuenta del Tasajero si huye después de su Caza?
- **Caso que la dispara:** escenario C: el Tasajero actúa en Caza (8), baja a ≤ 25% y huye antes de su Cuenta (3). Lectura literal: la Cuenta se saltea.
- **Opciones:** A) se saltean todas sus entradas restantes de la ronda. B) otra regla para algún caso. — Recomendación técnica: A (lectura literal).
- **Bloquea:** no
- **Mientras tanto:** programado con A: al avanzar, la cola saltea las entradas de unidades que no están sueltas o no tienen posición (hoy "fuera del tablero" = sin posición; la huida de salvajes llega en su tarea). Tests (6b) de T07.
- **Respuesta:** `Sistema.md` 11.3 v1.2 (04/10/2026): opción A. La unidad que cae, es guardada, huye o sale del tablero pierde todas sus entradas restantes de la ronda; el Tasajero que huye en Caza no juega la Cuenta. Decisión que genera: tumbarlo o hacerlo huir antes de la Cuenta le quita el segundo golpe. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T12 (sin cambios de código)

## P-013 — Velocidad del Maestro en la cola
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T07
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.2 ("su Movimiento, Alcance y Velocidad no dependen de [la balanza]") y 11.5 (si el Maestro cae, el combate termina en el acto)
- **Duda:** ¿la Velocidad del Maestro es siempre la de `maestro.json` (5), sin ningún modificador en 0a (hambre, enfermedad, balanza), y el Maestro entra en la cola en todas las rondas?
- **Caso que la dispara:** escenario D Hambriento o un Maestro en balanza 5: la cola lo pone igual con Velocidad 5.
- **Opciones:** A) sí, siempre 5 y siempre en la cola. B) algún estado la modifica. — Recomendación técnica: A (lectura literal).
- **Bloquea:** no
- **Mientras tanto:** programado con A; el Maestro nunca se saltea porque si cae el combate termina (lo resuelve otra tarea).
- **Respuesta:** `Sistema.md` 11.2 v1.2 (04/10/2026): opción A. En 0a la Velocidad del Maestro es siempre la de `maestro.json` (5); ningún estado (hambre, enfermedad, quebranto, balanza) la modifica, y entra en la cola en todas las rondas. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T12 (sin cambios de código)

## P-014 — Moverse después de erizarse
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T08
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.2, fila Rodauva ("Erizarse (acción): hasta su próximo turno […] no se mueve") y 11.3, fila Turno de una unidad ("1 movimiento y 1 acción, en cualquier orden"). Es la S-15 de `Arquitectura.md` 10.5
- **Duda:** si la Rodauva se eriza antes de usar su movimiento, ¿puede moverse después en el mismo turno?
- **Caso que la dispara:** Rodauva de la tribu en [2,6], al empezar su turno se eriza; después intenta moverse a [1,6].
- **Opciones:** A) no: erizarse cierra el movimiento que quede (si ya se había movido, vale). B) sí: el "no se mueve" empieza después de su turno. — Recomendación técnica: A (lectura declarada del Arquitecto, S-15).
- **Bloquea:** no
- **Mientras tanto:** programado con A en `nucleo/combate/turno.gd` (mover se rechaza con motivo `ERIZADA`); tests (7a) y (7b) de T08 (`pruebas/combate/test_turno.gd`). Si Sistemas elige B, cambia una condición y el test (7a).
- **Respuesta:** `Sistema.md` 11.2 y 11.3 v1.2 (04/10/2026): opción A. Erizarse cierra el movimiento que quede: se puede mover y después erizarse, no al revés. Decisión que genera: la Rodauva elige dónde plantarse antes de cerrarse. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T12 (sin cambios de código)

## P-015 — Terminar el turno sin usar la acción es "esperar"
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T08
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 10.2 ("No la corta: […] esperar") y 11.3, fila Turno de una unidad (acciones: "… Erizarse, esperar"). Es la S-16 (no figura todavía en la copia de `Arquitectura.md` 10.5 del repositorio)
- **Duda:** ¿terminar el turno sin usar la acción (con o sin movimiento) cuenta como la acción "esperar"?
- **Caso que la dispara:** la Ocarra de la tribu se mueve y cierra el turno sin atacar, entre dos golpes aliados al mismo objetivo.
- **Opciones:** A) sí: se registra "esperar"; no corta la cadena (el corte de cadena es de T16). B) "esperar" es una acción aparte y terminar sin acción es otra cosa. — Recomendación técnica: A (lectura declarada del Arquitecto, S-16).
- **Bloquea:** no
- **Mientras tanto:** programado con A: `terminar` sin haber usado la acción devuelve `espero = true` en `ResultadoAccion` (`nucleo/combate/turno.gd`); test (10) de T08. T16 lo usa para la cadena.
- **Respuesta:** `Sistema.md` 10.2 y 11.3 v1.2 (04/10/2026): opción A. Terminar el turno sin usar la acción (con o sin movimiento) es esperar y no corta la cadena. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T12 (sin cambios de código)

## P-016 — Saciado y enfermedades de las enemigas en el daño
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T09
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 7.1 ("Cada ser (el Maestro y cada criatura suelta) tiene un valor de Hambre") y 8.2. Es la S-17 de `Arquitectura.md` 10.5
- **Duda:** las salvajes, el Tasajero y la atacante nocturna, ¿reciben el +25% de Saciado o el −25% por enfermedad en su daño?
- **Caso que la dispara:** una Ocarra salvaje (los escenarios no le dan hambre, y el modelo lo deja en 0, que sería Saciado) pega al Maestro: ¿4 o 5? La atacante nocturna del escenario G trae hambre 9.
- **Opciones:** A) no: pegan con su Daño base, sus rasgos y los aportes que les toquen. B) sí, con el hambre y las enfermedades que traigan. — Recomendación técnica: A (lectura declarada del Arquitecto, S-17; coincide con 11.6: dos golpes de la Ocarra salvaje tumban a la Rodauva).
- **Bloquea:** no
- **Mientras tanto:** programado con A en `nucleo/combate/danio.gd` (hambre y enfermedades solo para el Maestro y la tribu); test (11) de T09 (`pruebas/combate/test_danio.gd`). Si Sistemas elige B, cambia una condición y ese test.
- **Respuesta:** `Sistema.md` 8.2, 9.2 y 11.4 v1.2 (04/10/2026): opción A. Saciado y enfermedades son solo del Maestro y la tribu. Las enemigas (salvajes, Tasajero, atacante nocturna, también en su golpe inicial) pegan con su Daño base, sus rasgos y los aportes de combate. En el caso: 4. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T12 (sin cambios de código)

## P-017 — Daño negativo tras los porcentajes y bonos planos
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T09
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.4 (pasos 2 a 4) y 8.4 ("Redondeo hacia abajo. El daño nunca baja de 1")
- **Duda:** si los porcentajes suman menos de −100% y el daño queda por debajo de 0 tras el paso 2, ¿los bonos planos del paso 3 se suman sobre ese valor negativo (el único recorte es el mínimo del paso 4)?
- **Caso que la dispara:** el Zancajunco (4) con 3 enfermedades (−75%) ataca a una Rodauva erizada (−50%) en su primer ataque (+2): 4 × (−25%) = −1, +2 = **1**. Si se recorta a 0 antes de los planos: 0 + 2 = **2**.
- **Opciones:** A) sin recorte intermedio: −1 + 2 = 1. B) recortar a 0 tras el paso 2: 2. — Recomendación técnica: A (lectura literal de 11.4 y de `Arquitectura.md` B.2, T09: "piso explícito").
- **Bloquea:** no
- **Mientras tanto:** programado con A en `nucleo/combate/danio.gd`; tests (8) y (10) de T09 (`pruebas/combate/test_danio.gd`: −125% sobre 2 da −1). Si Sistemas elige B, se agrega un recorte en `Danio` (no en `Porcentajes`) y cambia el test (8).
- **Respuesta:** `Sistema.md` 11.4 v1.2 (04/10/2026): opción A. Sin recorte intermedio: los planos se suman sobre el valor negativo y el único recorte es el mínimo final. En el caso: −1 + 2 = 1. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T12 (sin cambios de código)

## P-018 — La caída bloquea el paso y la línea de Alcance 2
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T10
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.5, Reglas de la caída ("queda en su casilla y la ocupa" y "no participa de ninguna relación") y 11.3, fila Alcance 2 ("nunca por encima de una enemiga")
- **Duda:** una unidad caída, ¿bloquea el paso y la línea de Alcance 2 de la otra banda igual que si estuviera de pie?
- **Caso que la dispara:** la Ocarra atacante nocturna cae en [3,5]; la Ocarra de la tribu en [3,6] quiere golpear a una salvaje en [3,4] por encima de ella, o el Maestro quiere pasar por [3,5]. Lectura literal: no puede (la caída ocupa la casilla y es enemiga).
- **Opciones:** A) sí: bloquea como de pie (no se pasa por encima ni a través de una caída enemiga; por una aliada sí). B) no: la casilla está ocupada (nadie termina ahí), pero no corta la línea ni el paso. — Recomendación técnica: A (lectura literal; es lo que ya hace `Tablero` desde T06, que cuenta a las caídas como ocupantes).
- **Bloquea:** no
- **Mientras tanto:** programado con A, sin cambios en `nucleo/combate/tablero.gd`. Si Sistemas elige B, `Tablero` deja de contar a las caídas para el paso y la línea (no para terminar el movimiento) y se agrega un test.
- **Respuesta:** `Sistema.md` 11.3 v1.2 (04/10/2026): opción A. La caída bloquea el paso y la línea de Alcance 2 de la otra banda como si estuviera de pie; por una caída propia se pasa. Decisión que genera: una caída propia sigue cubriendo; guardarla libera la casilla y abre el paso. Ya programado así (`Tablero`, T06): no cambia código ni tests.
- **Cerrada en:** T12 (sin cambios de código)

## P-019 — Nombres de motivo de lealtad en el resultado
- **Estado:** CERRADA
- **Para:** ARQUITECTO
- **Tarea:** T10
- **Fecha:** 04/10/2026
- **Fuente:** `datos/_esquemas/resultado.schema.json`, `lealtad_cambios.motivo` (Arquitectura.md A.7), frente a `datos/tablas/lealtad.json`, `eventos`, y `combate.json`, `lealtad_por_victoria`
- **Duda:** ¿el `motivo` de `lealtad_cambios` del resultado usa los nombres de evento de `lealtad.json` (más `victoria`), o T12 traduce los del acumulador a los del esquema actual?
- **Caso que la dispara:** el resultado admite `victoria`, `muerte_en_el_grupo`, `rescate`, `perdon`, `comida`; `lealtad.json` nombra sus eventos `muerte_en_el_grupo`, `muerte_en_el_grupo_afines`, `rescate`, `perdon_a_leales`, `comer_atacante`. En el ejemplo de 5.2, el −4 del Surcón por la Rodauva muerta se anota como `muerte_en_el_grupo_afines`, que el esquema del resultado no admite.
- **Opciones:** A) el enum del resultado pasa a las claves de `lealtad.json` más `victoria`. B) se deja el esquema y T12 traduce (`muerte_en_el_grupo_afines` → `muerte_en_el_grupo`, `perdon_a_leales` → `perdon`, `comer_atacante` → `comida`). — Recomendación técnica: A (un solo nombre por evento, el del dato que da el número).
- **Bloquea:** no (hoy nadie serializa el cierre; lo hace T12)
- **Mientras tanto:** `AcumuladorLealtad` anota las claves de `lealtad.json` y `"victoria"` para el +1 (`nucleo/combate/cierre.gd`). Sin cambios en `resultado.schema.json`.
- **Respuesta:** Respuesta: Arquitecto, 04/10/2026: opción A con un ajuste. El motivo es la clave de tablas/lealtad.json eventos. El +1 por victoria pasa de combate.json a lealtad.json eventos.victoria. Se aplica en T12 (Arquitectura.md 10.5, v0.16).
- **Cerrada en:** T12 (sesión 2: motivo = clave de `eventos`; +1 en `eventos.victoria`)

## P-020 — Objetivo sin remate: cercana o menos vida primero
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T11
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.8, paso 5 ("la más cercana que pueda alcanzar; si empatan, la de menos vida") frente a la tabla de desempates ("Objetivo: Remate → menos vida actual → más cercana → la que actúa antes en la cola"). Es la S-19 de `Arquitectura.md` 10.5
- **Duda:** cuando ninguna objetivo se puede tumbar, ¿se elige primero por cercanía y después por vida (paso 5), o primero por vida y después por cercanía (tabla)?
- **Caso que la dispara:** la Ocarra salvaje alcanza a la Rodauva (6 de vida, a 1) y al Maestro (5 de vida, a 2) y no tumba a ninguno. Con el paso 5 va por la Rodauva; con la tabla, por el Maestro.
- **Opciones:** A) la tabla rige el remate (menos vida → cercana → cola) y el paso 5 la elección sin remate (cercana → menos vida → cola). B) una sola regla para los dos casos. — Recomendación técnica: A (lectura declarada del Arquitecto, S-19).
- **Bloquea:** no
- **Mientras tanto:** programado con A en `nucleo/combate/ia/ia_salvaje.gd` (`_DESEMPATE_REMATE` y `_DESEMPATE_CERCANA`); test (4) de T11 (`pruebas/combate/ia/test_ia_salvaje.gd`). Si Sistemas elige B, cambia una constante y el caso (a) del test (4).
- **Respuesta:** `Sistema.md` 11.8 v1.2 (04/10/2026): opción A. Con remate: menos vida → más cercana → cola. Sin remate: más cercana → menos vida → cola. La tabla de desempates de 11.8 ahora tiene las dos filas. Motivo: sin remate manda la posición, y el que va adelante recibe (incluido el Maestro, Pilar 1). En el caso: la Rodauva. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T12 (sin cambios de código)

## P-021 — "La que actúa antes en la cola" cuando una ya actuó
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T11
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.8, tabla de desempates ("→ la que actúa antes en la cola")
- **Duda:** el último desempate, ¿mira el orden de la ronda entera (también las que ya actuaron en esta ronda) o solo el de las que todavía no actuaron?
- **Caso que la dispara:** la Ocarra salvaje (Velocidad 7) actúa después de la Ocarra de la tribu (7, la tribu gana el empate) y antes que la Rodauva (6). Las dos están a la misma distancia y con la misma vida. Con la ronda entera, va por la Ocarra de la tribu (ya actuó); contando solo las que faltan, por la Rodauva.
- **Opciones:** A) la ronda entera, por la primera entrada de cada unidad (el orden de la cola no cambia en la ronda). B) solo las que todavía no actuaron (la "próxima en actuar"); las que ya actuaron van después. — Recomendación técnica: A (lectura literal).
- **Bloquea:** no
- **Mientras tanto:** programado con A en `IASalvaje._orden` (`nucleo/combate/ia/ia_salvaje.gd`); la unidad que no está en la cola va al final (en 0a no pasa). Si Sistemas elige B, cambia esa función y se agrega un caso al test (4).
- **Respuesta:** `Sistema.md` 11.8 v1.2 (04/10/2026): opción A. El orden de la ronda entera, por la primera entrada de cada unidad, haya actuado o no. En el caso: la Ocarra de la tribu. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T12 (sin cambios de código)

## P-022 — Una caída adyacente y Erizarse
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T11
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.8, paso 3 ("tiene una enemiga **adyacente**"), y 11.5, Reglas de la caída ("no participa de ninguna relación")
- **Duda:** para que la salvaje se erice, ¿cuenta una unidad de la tribu **caída** como "enemiga adyacente"?
- **Caso que la dispara:** la Rodauva salvaje con 3 de 8 de vida tiene al lado solo a la Rodauva de la tribu caída. Si cuenta, se eriza; si no, sigue la lista (se acerca a otra o la ataca).
- **Opciones:** A) no: solo las enemigas de pie (una caída no es objetivo ni amenaza). B) sí: cualquier unidad enemiga en una casilla adyacente. — Recomendación técnica: A.
- **Bloquea:** no
- **Mientras tanto:** programado con A en `IASalvaje._paso_erizarse` (usa `_enemigas_de_pie`). Si Sistemas elige B, cambia esa condición y se agrega un caso al test (7).
- **Respuesta:** `Sistema.md` 11.8 v1.2 (04/10/2026): opción A. Solo cuenta una enemiga de pie: una caída adyacente no hace erizarse. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T12 (sin cambios de código)

## P-023 — Posición null de una guardada y DESPLIEGUE_NO_IMPLEMENTADO
- **Estado:** CERRADA
- **Para:** ARQUITECTO
- **Tarea:** T12
- **Fecha:** 04/10/2026
- **Fuente:** `Arquitectura.md` B.2, fila T12 ("Un escenario con alguna `posicion: null` se rechaza con el motivo `DESPLIEGUE_NO_IMPLEMENTADO`"), frente a A.2 (`posicion: null` = la ubica el jugador en el despliegue) y al esquema `escenario`, donde una criatura `guardada` va con `posicion: null` porque no ocupa casilla
- **Duda:** ¿el rechazo alcanza solo a las unidades que van al tablero (Maestro, tribu suelta y enemigas), o a cualquier `posicion: null`, también la de una guardada?
- **Caso que la dispara:** la variante de C que pide `Sistema.md` 11.9 (Rodauva guardada; hoy se haría desde el panel de T31): la guardada viene con `posicion: null`. Con la lectura literal, el escenario se rechaza.
- **Opciones:** A) solo el Maestro, las sueltas de la tribu y las enemigas; una guardada con `null` es válida. B) cualquier `null`. — Recomendación técnica: A (una guardada no se despliega).
- **Bloquea:** no
- **Mientras tanto:** programado con A (decidido con el usuario al aprobar el plan) en `nucleo/combate/contexto_combate.gd`; test (9) de T12 (`pruebas/combate/test_combate.gd`) con los dos casos. Si se elige B, cambia una condición y ese test.
- **Respuesta:** Arquitecto, 04/10/2026: opción A. DESPLIEGUE_NO_IMPLEMENTADO alcanza solo a las unidades que van al tablero (el Maestro, las sueltas de la tribu y las enemigas). Una guardada con posicion: null es válida porque no ocupa casilla (A.2, T06). La redacción de T12 en B.2 estaba mal y se corrigió en Arquitectura.md v0.18. Ya programado así: no cambia código ni tests. Se cierra en T12, sesión 2.
- **Cerrada en:** T12 (sin cambios de código)

## P-024 — Destino de la atacante nocturna caída si el combate termina en derrota
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T12
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 9.3 y 11.5. Es la S-20 de `Arquitectura.md` 10.5
- **Duda:** si un combate nocturno termina en derrota (cae el Maestro) con la atacante ya caída, ¿su destino queda pendiente para después del rescate, o sigue otra regla?
- **Caso que la dispara:** en un combate nocturno con más de una enemiga, la atacante cae y después otra enemiga tumba al Maestro. En 0a no pasa: en G la atacante es la única enemiga, y si cae se gana.
- **Opciones:** A) queda pendiente (`atacante_pendiente` = su id) con cualquier desenlace. B) otra regla (huye, queda libre o muere). — Recomendación técnica: A (lectura literal, ya programada).
- **Bloquea:** no (se necesita antes de T30)
- **Mientras tanto:** programado con A en `nucleo/combate/resultado_combate.gd`, `ResultadoCombate.armar`: toma la criatura `ATACANTE_NOCTURNA` en estado `CAIDA` sin mirar `cierre.fin`, con un comentario que remite a esta pregunta y a S-20. Test: `pruebas/combate/test_contrato.gd`, `test_resultados_validan_contra_el_esquema` (test 11 de T12, caso G con la atacante en 0: `atacante_pendiente = "ocarra_1"`). Ese test cubre la atacante caída en una victoria. Ningún test arma una derrota con la atacante caída. Si Sistemas elige B, cambia una condición de `armar` y se suma ese caso al test 11.
- **Respuesta:** `Sistema.md` 9.2, paso 6 (v1.4 y v1.5) y Visión 6.4 v1.2: opción B. Si el combate nocturno termina en derrota, la atacante se va, también si ya estaba caída: su pergamino arde, vuelve a ser salvaje y no hay `atacante_pendiente`. Su ida no cambia la lealtad de nadie. Cambia una condición de `ResultadoCombate.armar` y se suma la derrota al test 11 de T12. Se aplica en T30.
- **Cerrada en:** T30

## P-025 — Guardar a una caída y la consulta única de objetivo
- **Estado:** CERRADA
- **Para:** ARQUITECTO
- **Tarea:** T38
- **Fecha:** 06/10/2026
- **Fuente:** `Arquitectura.md` B.2.1, fila T38 ("Aliada: la oculta sí vale") y regla "Consulta única de objetivo"; `Sistema.md` 1.6 (Remiendo: "no afecta a las caídas"), 3.1 y 11.5 (el Maestro puede guardar a una caída propia)
- **Duda:** ¿cómo admite la consulta única a una caída propia para guardar, si el Remiendo, que también es aliado, no la admite?
- **Caso que la dispara:** la Rodauva de la tribu cae. Para el Remiendo (T22) no es objetivo; para guardar a una caída (T26) sí. Con dos clases (hostil y aliada) la consulta no puede dar las dos respuestas.
- **Opciones:** A) una tercera clase, "aliada que admite caída", solo para guardar. B) la consulta recibe el tipo de acción (ataque, Martillazo, Lanzadera, sellar, Encono, Remiendo, guardar) y de ahí saca qué estados deja pasar. — Recomendación técnica: B (cada acción dice una sola vez qué admite, y la próxima diferencia no pide otra clase).
- **Bloquea:** no (se necesita antes de T26)
- **Mientras tanto:** `nucleo/combate/objetivos.gd` (`Objetivos.Clase`) tiene `HOSTIL` y `ALIADA`, y `ALIADA` deja afuera a la caída, que es lo que pide el Remiendo. Test: `pruebas/combate/test_junco.gd`, `test_aliada_vale_sobre_oculta` (una caída da `OBJETIVO_CAIDO` como aliada). Ninguna acción aliada existe todavía.
- **Respuesta:** Arquitecto (06/10/2026): depende de la acción. ALIADA (Remiendo) sigue dejando afuera a la caída (Sistema.md 1.6). Guardar a una caída usa una clase nueva de Objetivos, CAIDA_PROPIA, que exige que esté caída; que sea de la tribu lo revisa la acción, no la consulta. Se aplica y se cierra en T27.
- **Cerrada en:** T27

## P-026 — Qué presas elige el Tasajero en Caza y en qué orden las ataca
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T39
- **Fecha:** 06/10/2026
- **Fuente:** `Sistema.md` 11.8, tabla de desempates, fila "Casilla del Tasajero en Caza (paso 6b)" ("Con 3 o más presas adyacentes, ataca a las 2 de menos vida"), y 11.2.3, fila "Primera presa tumbada"
- **Duda:** entre las presas de la casilla elegida, ¿se usa "menos vida → antes en la cola" (el criterio de S-23) para elegir las 2 cuando empatan en vida y para decidir a cuál va el primer ataque?
- **Caso que la dispara:** junto a [3,4] están la Ocarra, la Rodauva y el Maestro, las tres con 8 de vida. ¿A cuáles dos ataca? Otro caso: dos presas, el Maestro con 4 y la Rodauva con 8. Si el primer golpe va al Maestro, lo tumba, el combate termina y la Rodauva no recibe el segundo. Si va a la Rodauva, recibe 5 y después cae el Maestro.
- **Opciones:** A) Menos vida → antes en la cola, para elegir y para el orden (el primer ataque va a la de menos vida, como el segundo de S-23). B) Solo antes en la cola. — Recomendación técnica: A.
- **Bloquea:** no
- **Mientras tanto:** programada la opción A como lectura declarada: `nucleo/combate/ia/ia_salvaje.gd`, `_DESEMPATE_PRESAS` y `_presas_elegidas`. Test: `pruebas/combate/ia/test_ia_salvaje.gd`, `test_t39_desempates_de_la_caza`, caso (g). Si la respuesta es otra, cambian esa constante y ese caso.
- **Respuesta:** Sistema.md 11.8 v1.6: opción A. Con 3 o más presas, las 2 de menos vida → la que actúa antes en la cola; el primer ataque va a la de menos vida. Ya programado así: no cambia código ni tests. Se cierra al empezar T41.
- **Cerrada en:** T41

## P-027 — Empate en "la enemiga de pie más cercana"
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T39
- **Fecha:** 06/10/2026
- **Fuente:** `Sistema.md` 11.8, tabla de desempates, filas "Retirada del Tasajero en Cuenta" y "Casilla del surco (Surcón salvaje, paso 7)"
- **Duda:** si dos enemigas de pie están a la misma distancia, ¿cuál es "la enemiga de pie más cercana", de la que el Tasajero se aleja y hacia la que el Surcón cava?
- **Caso que la dispara:** escenario F. El Surcón salvaje [4,1] tiene al Maestro [3,6] y a la Ocarra [4,7] a 6. Hacia el Maestro cava en [3,1] (justo debajo del Zancajunco salvaje, y le cambia el camino); hacia la Ocarra cavaría en [4,2].
- **Opciones:** A) Más cercana → menos vida → antes en la cola, como el objetivo de "Acercarse". B) Mirar todas las empatadas: la casilla que queda más cerca (en la retirada, más lejos) de cualquiera de ellas. — Recomendación técnica: A. En el caso de F, A y B dan la misma casilla, [3,1].
- **Bloquea:** no
- **Mientras tanto:** programada la opción A como lectura declarada: `nucleo/combate/ia/ia_salvaje.gd`, `_enemiga_mas_cercana` (usa `_DESEMPATE_CERCANA`). Tests: `pruebas/combate/ia/test_ia_salvaje.gd`, `test_t39_surcon_cava_hacia_la_mas_cercana` (caso con la Rodauva a 6) y `test_t39_f_el_zancajunco_se_oculta_avanza_y_embiste` (el camino de F depende del surco en [3,1]).
- **Respuesta:** Sistema.md 11.8 v1.6: opción A. "La enemiga de pie más cercana" se desempata por más cercana → menos vida → la que actúa antes en la cola, como Acercarse. Ya programado así: no cambia código ni tests. Se cierra al empezar T41.
- **Cerrada en:** T41

## P-028 — `dudosa_hasta` repite el piso de Neutral
- **Estado:** CERRADA
- **Para:** ARQUITECTO
- **Tarea:** T14
- **Fecha:** 06/10/2026
- **Fuente:** `Arquitectura.md` A.2.2, filas "Cada número en un solo archivo" y "Estados de lealtad"; `Sistema.md` 5.1 y 5.4 (Cortes, P-003)
- **Duda:** desde que la lealtad y la obediencia comparten los cortes (piso de Neutral `neutral_desde`), `tablas/lealtad.json` `dudosa_hasta` (3) es una copia de `neutral_desde − 1` que el código ya no lee. ¿Se quita, o se deja con un chequeo cruzado en el `Cargador`?
- **Caso que la dispara:** si alguien sube `neutral_desde` a 5 y deja `dudosa_hasta` en 3, la lealtad 4 se ve "Dudosa" (la cuenta sale de `neutral_desde`), y el archivo dice otra cosa.
- **Opciones:** A) quitar `dudosa_hasta` del esquema y del dato (Dudosa = desde `desleal_hasta + 1` hasta `neutral_desde − 1`). B) dejarlo y que el `Cargador` exija `dudosa_hasta + 1 = neutral_desde`. — Recomendación técnica: A (un número, un lugar).
- **Bloquea:** no
- **Mientras tanto:** `EstadosUnidad.corte` (`nucleo/unidades/estados_unidad.gd`) usa `desleal_hasta` y `neutral_desde`. `dudosa_hasta` queda en el dato y en el esquema sin leerse. Con los datos de hoy (3 y 4) el resultado es el mismo. Test: `pruebas/unidades/test_obediencia.gd`, `test_cortes_desde_los_datos`.
- **Respuesta:** Arquitecto (06/10/2026): se quita dudosa_hasta de tablas/lealtad.json y de su esquema. Es neutral_desde − 1 y viola "cada número en un solo archivo" (A.2.2). El estado Dudosa queda definido como desleal_hasta + 1 hasta neutral_desde − 1. Orden: esquema → datos → fixtures → código, con su línea en la tabla de cotejo. Se aplica y se cierra al empezar T15, en el mismo PR.
- **Cerrada en:** T15
## P-029 — Golpe que gana el combate y saca a la objetivo de la cadena: ¿`objetivo_fuera` o `fin_combate`?
- **Estado:** CERRADA
- **Para:** ARQUITECTO
- **Tarea:** T16
- **Fecha:** 07/10/2026
- **Fuente:** `Arquitectura.md` A.7, "Eventos de 0a.2" (motivos de `cadena_cortada`), y B.3, fila T16 (Cortes)
- **Duda:** cuando un golpe de la tribu saca del tablero a la objetivo de la cadena y con eso gana el combate, ¿el único `cadena_cortada` lleva el motivo `objetivo_fuera` o `fin_combate`?
- **Caso que la dispara:** `escenario_cadena_combate` sin `rodauva_s1` y con `surcon_s1` en 10 de vida. El Zancajunco pega 4 y la Ocarra 6 (eslabón 2): `surcon_s1` queda fuera y es la victoria. El corte por objetivo se mira después de cada acción aplicada (dentro del `Turno`) y el de fin, al terminar (en `Combate._terminar`), así que gana el primero. Consecuencia: hoy `fin_combate` no se da en ningún combate real, porque una cadena viva necesita una objetivo enemiga que todavía pueda ser objetivo (no hay victoria) y el Maestro no puede caer en un turno de la tribu hasta T18.
- **Opciones:** A) `objetivo_fuera` (lo que pasó primero en la regla de 10.2); `fin_combate` queda para las cadenas que sigan vivas al terminar (desde T18, T25 y T26). B) `fin_combate` siempre que el combate termine en esa acción. — Recomendación técnica: A (un orden fijo y sin caso especial; para T23 da igual, porque cuenta eslabones).
- **Bloquea:** no
- **Mientras tanto:** programada la opción A como lectura técnica: `nucleo/combate/turno.gd` (`_resolver` llama a `Cadena.revisar_objetivo` antes de evaluar el fin) y `nucleo/combate/combate.gd` (`_terminar` corta con `fin_combate` lo que quede). Tests: `pruebas/combate/test_cadena.gd`, `test_registro_instantanea_y_grabacion` (victoria con un solo corte `objetivo_fuera`, y `Cadena.cortar(fin_combate)` sobre una cadena abierta, una sola vez).
- **Respuesta:** Arquitecto (07/10/2026): opción A. El corte por objetivo se mira después de cada acción aplicada y va antes que el de fin: un golpe que saca a la objetivo y gana el combate deja un solo cadena_cortada, con objetivo_fuera. fin_combate queda para las cadenas que sigan vivas al terminar (desde T18, T25, T26 y T28). Para T23 da igual, porque cuenta eslabones. Ya programado así: no cambia código ni tests. Se cierra al empezar T41.
- **Cerrada en:** T41

## P-030 — Coordenadas de los escenarios en 12 × 12
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T43
- **Fecha:** 07/10/2026
- **Fuente:** `Sistema.md` 11.9 v1.6, "Criterios de despliegue en 12 × 12" y "Cómo se fijan las coordenadas"; 11.3 v1.6, "Contacto en la ronda 2"
- **Duda:** ¿se aprueban las coordenadas de 12 × 12 de la tabla de abajo (como P-007), verificadas contra la IA real por `pruebas/datos/test_contacto.gd`?
- **Caso que la dispara:** A a F y H pasan de 8 × 8 a 12 × 12 (G sigue en 8 × 8); `tablas/combate.json` `despliegue_filas` = 3. Coordenadas `[x, y]`, `y = 0` arriba; M = Maestro; entre paréntesis, la distancia Manhattan a la enemiga más cercana (a la unidad de la tribu más cercana, para las enemigas).

  | Escenario | Tribu | Enemigas | Lo que hace la IA con la tribu quieta (verificado) |
  |---|---|---|---|
  | A | M [5,10] (9), Rodauva [6,10] (8) | Ocarra [6,2] (8) | Ronda 1: se acerca a [6,5]. Ronda 2: le pega a la Rodauva desde [6,8] |
  | B | M [4,9] (8), Rodauva [6,10] (8) | Ocarra s1 [4,1] (8), Ocarra s2 [6,2] (8) | s1 va por el Maestro y s2 por la Rodauva. Cierre de la ronda 1: [4,4] y [6,5]. Ronda 2: pegan desde [4,7] y [6,8]. Nunca vecinas en 8 (están a 2) |
  | C y H | M [5,10] (8), Rodauva [4,10] (9), Ocarra [4,11] (10), Zancajunco [6,10] (9) | Tasajero [5,2] (8) | Ronda 1: se acerca a [5,6]. Ronda 2: Caza desde [4,9] contra la Rodauva (5 + 5) |
  | D (3) | M [5,10] (8), Ocarra [5,11] (9), Zancajunco [6,11] (10) | Surcón [4,2] (9), Rodauva [5,2] (8) | La Ocarra y el Zancajunco empiezan vecinos. Rodauva salvaje: ronda 1 a [5,6], ronda 2 le pega al Maestro. El Surcón cava en [5,2] y [4,3] |
  | E (2) | M [4,10] (12), Rodauva leal [6,10] (10), Rodauva Neutral [6,11] (11), Surcón [4,11] (13) | Tasajero [8,2] (10) | Ronda 1: a [6,4] (a 6 y 7 de las Rodauvas: ninguna rival a su alcance en su turno). Ronda 2: a [6,8] (las dos con rival a su alcance). Primer ataque enemigo, en la ronda 3 |
  | F | M [5,10] vida 6 (8), Rodauva [5,11] (9), Ocarra [6,11] (9) | Zancajunco [5,2] (8), Surcón [6,2] (9) | Zancajunco: se oculta en la 1; en la 2 baja a [5,6], destapado y con el bono; en la 3 le pega 7 al Maestro desde [5,9]. El Surcón cava en [6,3] y [5,2] |
  | G | Sin cambios (8 × 8) | — | Llega al primer turno del jugador |

  El test comprueba en cada escenario (salvo G) las zonas de despliegue (filas 9 a 11 y 0 a 2), la distancia mínima (8; E, 10) y que ninguna enemiga ataca en la ronda 1, más la fila de cada escenario en la tabla de criterios. Romper una coordenada a mano (el Tasajero de C a [5,5], distancia 5) lo hace fallar.

  **Dos avisos:**
  1. **B:** con las dos Ocarras a 8, las dos no pueden ir por la Rodauva sin terminar vecinas. Con las filas 0 a 2 y 9 a 11, a distancia 8 las dos quedan a 2 columnas o menos de su objetivo y convergen en diagonal (es lo que pasaba en 8 × 8). Por eso cada una va por la unidad que tiene más cerca, y cambia la línea de referencia de 11.6 B ("las dos van primero por la Rodauva"): el Maestro recibe un golpe de 4 por ronda desde la ronda 2. Para la Lanzadera (T22): con el Maestro en [4,8] (un paso), atraer a la Ocarra s2 a [5,8] la deja en diagonal con la s1.
  2. **C y H:** la Ocarra de la tribu pasa de detrás del Maestro a detrás de la Rodauva. Si no, empezaría en diagonal con el Zancajunco (rivales), y con las vecinas en 8 (11.3 v1.6) eso es un incidente posible desde el primer turno. La `_nota` vieja buscaba lo contrario ("no son adyacentes al empezar").
- **Opciones:** A) aprobar las coordenadas tal como están. B) pedir cambios por escenario, que se verifican de nuevo con el test. — Recomendación técnica: A.
- **Bloquea:** no
- **Mientras tanto:** las coordenadas están en `datos/escenarios/` (T43) y el test de contacto queda como regresión permanente.
- **Respuesta:** Sistemas (`Sistema.md` 15 v1.7): `Sistema.md` 11.9 v1.7: opción A. Coordenadas de 12 × 12 aprobadas tal como están, como provisorias (P-007). Se reescribe la línea de referencia de 11.6 B (cada Ocarra va por la unidad que tiene más cerca) y se asienta que en C y H la Ocarra empieza detrás de la Rodauva. No cambia código ni datos.
- **Cerrada en:** T44

## P-031 — Cuándo se declara Secundar (S-29)
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T17
- **Fecha:** 07/10/2026
- **Fuente:** `Sistema.md` 10.1 (Secundar) y 11.3 (Turno de una unidad); `Arquitectura.md` 10.5, S-29
- **Duda:** ¿Secundar solo se puede declarar con el turno sin usar (sin haberse movido ni usado la acción)?
- **Caso que la dispara:** el Zancajunco de C se mueve dos casillas y después quiere Secundar a la Ocarra. 10.1 no dice cuándo se declara y 11.3 no lo lista entre las acciones del turno.
- **Opciones:** A) solo con el turno sin usar: Secundar aplaza el turno entero, no lo parte. B) también después de moverse, guardando la acción para después. — Recomendación técnica: A (lectura declarada de `Arquitectura.md` 10.5).
- **Bloquea:** no
- **Mientras tanto:** programada la lectura A: `Turno` rechaza Secundar con `YA_SE_MOVIO` o `ACCION_USADA` (`nucleo/combate/turno.gd`, `_motivo_puede_secundar`). Tests en `pruebas/combate/test_secundar.gd`.
- **Respuesta:** Sistemas (`Sistema.md` 15 v1.7): `Sistema.md` 10.1 v1.7: opción A. Secundar solo con el turno sin usar: aplaza el turno entero. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T44

## P-032 — Secundar dos veces en la misma ronda (S-30)
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T17
- **Fecha:** 07/10/2026
- **Fuente:** `Sistema.md` 10.1 (Secundar, Restricciones); `Arquitectura.md` 10.5, S-30
- **Duda:** ¿una unidad que ya Secundó puede volver a Secundar cuando le toca de nuevo en la misma ronda?
- **Caso que la dispara:** en C, el Zancajunco Secunda a la Ocarra; al volver, la Rodauva sigue pendiente detrás y la quiere Secundar también.
- **Opciones:** A) vale si al volver queda otra aliada pendiente detrás; la entrada siempre avanza en la cola, así que la ronda termina. B) una sola vez por ronda. — Recomendación técnica: A (lectura declarada de `Arquitectura.md` 10.5).
- **Bloquea:** no
- **Mientras tanto:** programada la lectura A (`ColaIniciativa.secundar`, `Turno._secundar`). Tests en `pruebas/combate/test_secundar.gd`.
- **Respuesta:** Sistemas (`Sistema.md` 15 v1.7): `Sistema.md` 10.1 v1.7: opción A. Al volver, puede Secundar otra vez si queda otra aliada pendiente detrás. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T44

## P-033 — Inicio del turno al volver de Secundar (S-31)
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T17
- **Fecha:** 07/10/2026
- **Fuente:** `Sistema.md` 11.3 (Inicio del turno: orden de los chequeos) y 11.2.3 (cambio de modo); `Arquitectura.md` 10.5, S-31
- **Duda:** al volver después de Secundar, ¿el turno sigue sin repetir los chequeos del inicio del turno ni el cambio de modo?
- **Caso que la dispara:** un Tasajero de la tribu en Caza Secunda al Maestro; entre medio una enemiga lo deja por debajo del umbral de Cuenta. Si el inicio corriera dos veces, cambiaría de modo al volver; con T18 y T21, Secundar sería una segunda tirada de incidente o un segundo maná.
- **Opciones:** A) los chequeos de 11.3 (maná, huida, Encono o cobardía, incidente), el borrado de Erizarse y el cambio de modo corren una sola vez por ronda, la primera vez que le toca; al volver, el turno sigue. B) corren cada vez que le toca. — Recomendación técnica: A (lectura declarada de `Arquitectura.md` 10.5).
- **Bloquea:** no (antes de T18 y T21)
- **Mientras tanto:** programada la lectura A: la entrada que vuelve lleva `EntradaCola.vuelve` y `Turno.empezar` no corre `_inicio_del_turno` con ella. Tests en `pruebas/combate/test_secundar.gd`.
- **Respuesta:** Sistemas (`Sistema.md` 15 v1.7): `Sistema.md` 10.1 y 11.3 v1.7: opción A. El inicio del turno, el borrado de Erizarse y el cambio de modo corren una vez por ronda; al volver de Secundar el turno sigue. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T44

## P-034 — Incidente con una rival oculta (S-32)
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T18
- **Fecha:** 07/10/2026
- **Fuente:** `Sistema.md` 11.2.2 (Relaciones: la oculta "sigue dando y recibiendo incidentes"; no puede ser objetivo de ningún ataque) y 10.4; `Arquitectura.md` 10.5, S-32
- **Duda:** una rival aliada oculta, ¿provoca la tirada de incidente aunque el golpe no pueda ir a ella?
- **Caso que la dispara:** una Ocarra de la tribu con obediencia 3 junto a un Zancajunco oculto de la tribu (Ocarra–Zancajunco mal). Sale el incidente y el Zancajunco es su única rival al alcance.
- **Opciones:** A) provoca la tirada, pero el golpe no puede ir a ella; si es la única rival a su alcance, la criatura se distrae. B) la oculta no provoca la tirada. — Recomendación técnica: A (lectura declarada de `Arquitectura.md` 10.5).
- **Bloquea:** no
- **Mientras tanto:** programada la lectura A: `Incidente.rivales_vecinas` cuenta a la oculta (`Objetivos.de_pie`) y `Turno._chequear_incidente` elige el golpe con la validación del ataque (`Objetivos`, clase `HOSTIL`). Test `test_oculta_provoca_pero_no_se_golpea` en `pruebas/combate/test_incidente.gd`.
- **Respuesta:** Sistemas (`Sistema.md` 15 v1.7): `Sistema.md` 10.4 y 11.2.2 v1.7: opción A. La rival oculta provoca la tirada pero no recibe el golpe; si es la única a su alcance, la criatura se distrae. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T44

## P-035 — El golpe del incidente y la cadena (S-33)
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T18
- **Fecha:** 07/10/2026
- **Fuente:** `Sistema.md` 10.2 (la cadena se corta si un aliado ataca a otro objetivo, "incluido el golpe de un incidente"); `Arquitectura.md` 10.5, S-33
- **Duda:** el golpe de un incidente, ¿empieza una cadena nueva sobre la aliada golpeada?
- **Caso que la dispara:** la tribu viene encadenando sobre el Surcón salvaje. Una Ocarra con obediencia 3 golpea a su rival aliada por un incidente: la cadena vieja se corta. Si empezara una nueva, un segundo incidente sobre la misma aliada en la ronda sumaría combo contra una compañera.
- **Opciones:** A) corta la cadena que había, no empieza otra y no recibe bono de combo (`eslabon` nulo en el evento `ataque`). B) empieza una cadena nueva sobre la aliada, en el eslabón 1. — Recomendación técnica: A (lectura declarada de `Arquitectura.md` 10.5).
- **Bloquea:** no
- **Mientras tanto:** programada la lectura A: `Turno._atacar_desde(..., por_incidente)` no pide el combo, deja `eslabon` en nulo y corta con `otro_objetivo` en lugar de avanzar la cadena. Test `test_golpe_corta_la_cadena_sin_empezar_otra` en `pruebas/combate/test_incidente.gd`.
- **Respuesta:** Sistemas (`Sistema.md` 15 v1.7): `Sistema.md` 10.2 v1.7: opción A. El golpe del incidente corta la cadena, no empieza otra y no recibe combo. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T44

## P-036 — Incidente de un Tasajero de la tribu en Caza (S-34)
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T18
- **Fecha:** 07/10/2026
- **Fuente:** `Sistema.md` 10.4 ("pierde la acción"; "usa la acción para golpear a la rival") y 11.2.3 (Caza: dos ataques por turno)
- **Duda:** un Tasajero de la tribu en Caza con un incidente, ¿pierde los dos ataques (si se distrae) y gasta los dos con el golpe a la rival (si golpea)?
- **Caso que la dispara:** un Tasajero de la tribu en Caza, con obediencia 3, empieza su turno junto a una Rodauva de la tribu (Rodauva–Tasajero mal) y con una enemiga a su alcance. Sale el incidente y golpea a la Rodauva: ¿puede usar el segundo ataque de Caza contra la enemiga?
- **Opciones:** A) "la acción" son todos los ataques del turno: la distraída pierde los dos y el golpe gasta los dos (no hay segundo ataque). B) el golpe gasta solo uno: el segundo queda para otra objetivo. — Recomendación técnica: A, lectura literal con la acción de T36 (`accion_usada` = "usó alguna acción").
- **Bloquea:** no
- **Mientras tanto:** programada la lectura A: el golpe del incidente deja `ataques_restantes` en 0 y la distraída también. Sin test propio: el caso no aparece en ningún escenario de la 0a.
- **Respuesta:** Sistemas (`Sistema.md` 15 v1.7): `Sistema.md` 10.4 v1.7: opción A. 'La acción' son todos los ataques del turno: la distraída pierde los dos y el golpe gasta los dos. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T44

## P-037 — Nombre del campo "tipo" del evento chequeo_rival
- **Estado:** CERRADA
- **Para:** ARQUITECTO
- **Tarea:** T19
- **Fecha:** 07/10/2026
- **Fuente:** `Arquitectura.md` A.7, "Eventos de 0a.2" (T19): `chequeo_rival` (unidad, tipo `encono` / `cobardia`, rivales, porcentaje, `tiro` y resultado)
- **Duda:** todo evento del registro ya usa la clave `tipo` para su nombre (`"tipo": "chequeo_rival"`). ¿Con qué clave va el tipo `encono` / `cobardia`?
- **Caso que la dispara:** el evento no puede tener dos claves `tipo`: `{"tipo": "chequeo_rival", "tipo": "encono"}` pisa una con la otra.
- **Opciones:** A) `tipo_chequeo` (`{"tipo": "chequeo_rival", "tipo_chequeo": "encono", ...}`). B) `chequeo`. C) Otro nombre. — Recomendación técnica: A.
- **Bloquea:** no
- **Mientras tanto:** programada la opción A en `Combate._registrar_chequeo_rival`, con su test (`test_registro_del_chequeo_y_del_incidente`). Cambiar el nombre es una línea y su test. La pantalla (sesión 2) y las métricas (T23) la van a leer.
- **Respuesta:** Arquitecto (08/10/2026): opción A. La clave es tipo_chequeo (encono / cobardia); tipo sigue siendo el nombre del evento en todo el registro. Ya programado así: no cambia código ni tests. Se cierra al empezar T20 (Arquitectura.md A.7, v0.34).
- **Cerrada en:** T20

## P-038 — Casillas de la enconada después del primer ataque (S-38)
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T19
- **Fecha:** 08/10/2026
- **Fuente:** `Sistema.md` 10.5 ("Su acción queda fijada en atacar a esa rival… El jugador elige la casilla") y "Tasajero enconado en Caza" (el primero de sus dos ataques va a la rival)
- **Duda:** la enconada que alcanza a su rival solo puede moverse a casillas desde donde la golpea. ¿Esa limitación dura todo el turno o termina con el primer ataque a la rival?
- **Caso que la dispara:** un Tasajero en Cuenta (movimiento partido, 11.2.3) enconado golpea a su rival y quiere retirarse con los pasos que le quedan. Si la limitación dura todo el turno, solo puede ir a casillas desde donde la seguiría golpeando, y casi nunca se retira. En T20 la IA del Tasajero salvaje va a chocar con esto.
- **Opciones:** A) dura todo el turno (lectura literal: "su acción queda fijada"). B) termina con el primer ataque a la rival: después se mueve como cualquiera. — Recomendación técnica: B, por coherencia con "Tasajero enconado en Caza", donde el segundo ataque ya es libre.
- **Bloquea:** no (sí conviene responderla antes de T20)
- **Mientras tanto:** programada la opción A (lectura declarada S-35 de la sesión 1): `Turno._motivo_destino_rival` rechaza con `CASILLA_SIN_RIVAL` toda casilla que no golpee a una rival del chequeo mientras `obligacion` sea `ATACAR`. Para pasar a B alcanza con que la obligación termine con el primer ataque, y con su test.
- **Respuesta:** Sistemas (`Sistema.md` 15 v1.7): `Sistema.md` 10.5 v1.7: opción A. La restricción de casillas de la enconada dura todo el turno. Consecuencia aceptada: el Tasajero enconado en Cuenta casi nunca se retira (riesgo en 14, con la opción B como palanca). Ya programado así: no cambia código ni tests.
- **Cerrada en:** T44

## P-039 — El −50 % de la acobardada en el golpe del incidente (S-39)
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T19
- **Fecha:** 08/10/2026
- **Fuente:** `Sistema.md` 10.6 ("Acobardada: −50% de daño") y 10.4 (el golpe a la rival aliada con obediencia baja)
- **Duda:** una acobardada que en el mismo turno golpea a su rival aliada por un incidente, ¿pega ese golpe con el −50 %?
- **Caso que la dispara:** una Rodauva de la tribu con obediencia 3 queda acobardada por un Tasajero salvaje a su alcance (paso 3 de 11.3). Después le sale el incidente con un Tasajero de la tribu vecino (Rodauva–Tasajero "mal", paso 4) y lo golpea. Con daño 2, ¿le pega 1 o 2?
- **Opciones:** A) sí: el −50 % rige en todos sus golpes del turno, también en el del incidente. B) no: el incidente es otra regla, y el golpe va sin el −50 %. — Recomendación técnica: A (lectura literal: "−50% de daño", sin excepciones).
- **Bloquea:** no
- **Mientras tanto:** programada la opción A: `Turno._aportes` suma `ChequeoRival.aporte_cobardia()` en todo ataque de la acobardada, también con `por_incidente`. Sin test propio: ningún escenario de la 0a tiene un Tasajero en la tribu.
- **Respuesta:** Sistemas (`Sistema.md` 15 v1.7): `Sistema.md` 10.4 y 10.6 v1.7: opción A. El −50 % de la acobardada rige en todos sus ataques del turno, también en el golpe del incidente. Ya programado así: no cambia código ni tests.
- **Cerrada en:** T44

## P-040 — Mínimo del 5 % del toggle de afines sin afines vecinas (S-40)
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T19
- **Fecha:** 08/10/2026
- **Fuente:** `Sistema.md` 10.6, toggle de afines (`PROPUESTA`): "−10 puntos por afín vecina (máximo −20), con un mínimo de 5%"
- **Duda:** con el toggle activo en el escenario, ¿el mínimo de 5 % rige siempre, o solo cuando hay al menos una afín vecina que resta?
- **Caso que la dispara:** con el toggle, una criatura sin afines vecinas cuya cobardía da menos de 5 % (por ejemplo, si un cambio de números deja a la leal con el Maestro vecino en 0 %). Con la tabla de 10.6 de hoy no pasa: el valor más bajo sin afines es 10 %. Así que la duda solo importa si cambian los números.
- **Opciones:** A) rige siempre: con el toggle, la cobardía nunca baja de 5 %. B) solo cuando restó alguna afín: sin afines, el piso es 0 como sin el toggle. — Recomendación técnica: ninguna (las dos son de una línea).
- **Bloquea:** no
- **Mientras tanto:** programada la opción A en `ChequeoRival._pct_cobardia`: con el toggle, el piso es `afines_contra_cobardia.minimo_pct` haya o no afines. Sin test propio de ese caso.
- **Respuesta:** Sistemas (`Sistema.md` 15 v1.7): `Sistema.md` 10.6 v1.7: opción B, precisada. Las afines no bajan la cobardía por debajo de 5 %, pero el piso no la sube: `max(sin_afines − afines, min(sin_afines, 5))`. Sin afines, el toggle no cambia nada. Cambia `ChequeoRival._pct_cobardia` y se suma un test.
- **Cerrada en:** T44

## P-041 — Qué afín sostuvo a la que resiste (campo `afin` de `chequeo_rival`)
- **Estado:** CERRADA
- **Para:** ARQUITECTO
- **Tarea:** T44
- **Fecha:** 09/10/2026
- **Fuente:** `Arquitectura.md` A.7, "Eventos de 0a.2" (T44: `sostenida_por` = `maestro` / `afin` / `null`) y `datos/textos/es.json` `cobardia.resiste.afin` ("Se queda porque tiene {a_afin} cerca.", `Mundo.md` 5 v1.3)
- **Duda:** el evento `chequeo_rival` resistido con `sostenida_por: "afin"`, ¿trae también qué afín la sostuvo, para llenar el hueco `{a_afin}`?
- **Caso que la dispara:** en `e_cobardia_afines`, la Rodauva leal resiste con la otra Rodauva y el Surcón vecinos. A.7 dice solo `"afin"`, y la pantalla no puede recalcular después cuál era (no tiene reglas y el tablero ya cambió). Sin el dato, la línea sale "Se queda porque tiene [FALTA: afin] cerca."
- **Opciones:** A) con `sostenida_por: "afin"`, el evento suma `afin` con el id de la primera afín del toggle, en el orden del Plantel (la misma cuenta del porcentaje). B) sin campo nuevo: la línea queda con `[FALTA: afin]` hasta que el Worldbuilder cambie el texto. — Recomendación técnica: A.
- **Bloquea:** no
- **Mientras tanto:** programada la opción A, que eligió el usuario en la sesión 1 de T44: `ChequeoRival._pct_cobardia` devuelve también `afin`, y `Combate._registrar_chequeo_rival` lo suma al evento solo en una resistida sostenida por una afín. Si se elige B, se borra el campo y su test.
- **Respuesta:** Arquitecto (09/10/2026): opción A, ya programada en T44. En un chequeo_rival resistido con sostenida_por: "afin", el evento suma afin con el id de la primera afín del toggle, en el orden del Plantel (la misma cuenta del porcentaje). Se cierra al empezar T22, sin cambios de código.
- **Cerrada en:** T22

## P-042 — Contra quién choca la Lanzadera (evento `lanzadera`)
- **Estado:** CERRADA
- **Para:** ARQUITECTO
- **Tarea:** T22
- **Fecha:** 10/10/2026
- **Fuente:** `Arquitectura.md` A.7, "Eventos de 0a.2" (T22: `lanzadera` con objetivo, sentido, desde, hasta o `null`, `choque`, `danio`, `vida_antes`, `vida_despues`) y `datos/textos/es.json` `lanzadera.choque` ("{unidad} sale despedid{unidad_o} y se lleva por delante {a_otra}.") y `lanzadera.choque.contra_maestro`
- **Duda:** el evento `lanzadera` con `choque: true`, ¿suma un campo con la unidad que ocupaba la casilla de destino, para llenar `{a_otra}`?
- **Caso que la dispara:** el Maestro empuja a la Ocarra salvaje contra la Rodauva salvaje. El texto nombra a la Rodauva, pero el evento solo dice que hubo choque; la pantalla no puede recalcular después quién estaba en el destino (no tiene reglas y el tablero puede haber cambiado). Un choque contra el borde o contra un surco no tiene otra unidad.
- **Opciones:** A) con `choque: true`, el evento suma `contra`: el id de la unidad (de pie o caída) de la casilla de destino, o `null` si es el borde o un surco. B) sin campo nuevo: la línea del choque contra una unidad sale con `[FALTA: a_otra]` hasta que cambie el texto. — Recomendación técnica: A.
- **Bloquea:** no (afecta a los sucesos de la sesión 2 de T22)
- **Mientras tanto:** el evento `lanzadera` lleva exactamente los campos de A.7.
- **Respuesta:** - Arquitecto (10/10/2026): opción A. Con `choque: true`, el evento `lanzadera` suma `contra`: el id de la unidad (de pie o caída) que ocupa la casilla de destino, o `null` si el choque es contra el borde o un surco. Sin choque, el campo no va. La previsualización (`ResultadoAccion.evento`) lo trae igual. Se aplica y se cierra en T22, sesión 2.
- **Cerrada en:** T22

## P-043 — ¿La métrica 9 (caídas) cuenta la caída del Maestro?
- **Estado:** CERRADA
- **Para:** ARQUITECTO
- **Tarea:** T23
- **Fecha:** 11/10/2026
- **Fuente:** `Arquitectura.md` B.3, fila T23 ("(9) caídas: lista de `{unidad, ronda}` (eventos `estado` que pasan a `caida`)") y `Sistema.md` 11.9 (métrica 9 "Caídas: por id de unidad"; alarma de F "en más del 60% de las partidas en que el Maestro cae, no queda rescatista de pie", métricas 9 y 12)
- **Duda:** la métrica 9, ¿incluye la caída del Maestro, que en el registro es un evento `estado` que pasa a `caido` (no a `caida`)?
- **Caso que la dispara:** en F, el Zancajunco tumba al Maestro en la ronda 3: el registro tiene `{"tipo": "estado", "unidad": "maestro", "de": "en_pie", "a": "caido"}`. Con la lectura literal de la fila T23 la métrica 9 no lo lista, y la alarma de F no puede saber desde la métrica 9 si el Maestro cayó.
- **Opciones:** A) incluirla: la lista suma `{unidad: "maestro", ronda}` cuando `a` es `caido`. B) solo criaturas (`a == "caida"`); la caída del Maestro se lee del desenlace. — Recomendación técnica: A.
- **Bloquea:** no
- **Mientras tanto:** programada con la opción A, por decisión del usuario en el plan de T23 (lectura declarada en el resumen). Si la respuesta es B, se cambia una constante (`MetricasCombate._A_CAIDA`) y su test.
- **Respuesta:** Arquitecto (11/10/2026; copiada por pedido del usuario de `Arquitectura.md`, "Resuelta por el Arquitecto"): se acepta la lectura que eligió el usuario y ya programó T23: la métrica 9 incluye la caída del Maestro (`caido`). Motivo: 11.9 cuenta las caídas "por id de unidad", y el umbral de F mira "las partidas en que el Maestro cae" con las métricas 9 y 12. Se cierra al empezar T24, sin cambios de código.
- **Cerrada en:** T24

## P-044 — Los tests de mouse fallan por el tamaño de la ventana, no por eventos reales: ¿qué arreglo se toma?
- **Estado:** CERRADA
- **Para:** ARQUITECTO
- **Tarea:** T24-ajustes
- **Fecha:** 11/10/2026
- **Fuente:** `Arquitectura.md` B.4, fila T24-ajustes (opciones A y B), y D-006 ("los tests mandan eventos con su `position` por `Input.parse_input_event`")
- **Duda:** la causa no es la que supone la tarea (un evento real que le gana al del test). ¿Cuál de estos arreglos se toma, ya que no es ni A ni B?
- **Caso que la dispara:**
  - Los tests calculan la posición en coordenadas del **viewport** (`get_canvas_transform() * …`), pero `Input.parse_input_event` la toma en coordenadas de la **ventana** y la pasa por la inversa de `Viewport.get_final_transform()`. Con `window/stretch/mode="canvas_items"` y `aspect="expand"`, esa transformación es la identidad solo si la ventana mide 1152 × 648.
  - El runner de escenas de GdUnit4 **minimiza** la ventana al liberar cada runner y la restaura al crear el siguiente (`GdUnitSceneRunnerImpl.gd`, `move_window_to_background` / `move_window_to_foreground`). Si un test manda el evento antes de que la ventana recupere su tamaño, la posición se agranda y la casilla sale enorme.
  - Experimento (test temporal, ya borrado): con la ventana en 200 × 120, el evento del test para `(1,7)` en `(351,398)` llega a la vista como `(2025,2296)` (transformación final 0,1736) y da `(35,45)`. Es la misma familia que `(41,34)` y `(164,9)` de T24, y que `(93,80)` en lugar de `(1,7)`: así falló en esta sesión una corrida de `pruebas/pantalla`, incluido un test nuevo con el filtro de device **desactivado**.
  - Los eventos reales también llegan (registro temporal: movimientos en `(0,0)` del `warp_mouse` de GdUnit4, y del cursor del usuario, con un clic incluido), todos con `device=32`, el mismo que traen por defecto los eventos del test. Pero no explican las casillas enormes, y la opción B (filtro de device) no corrige esta falla.
  - Opción A (sin ventana) descartada: con `--headless --ignoreHeadlessMode`, `pruebas/pantalla` da 10 fallas y 1 error (GdUnit4 avisa que en headless no se transportan los `InputEvent`).
- **Opciones:**
  - A) El ayudante de los tests pasa la posición a coordenadas de ventana antes de mandarla (`evento.position = viewport.get_final_transform() * posicion`). Sigue con `parse_input_event` y D-006, y ninguna aserción cambia. Se puede sumar el filtro de device de B contra los eventos reales (ya escrito y probado: 2 tests nuevos que pasan).
  - B) Los tests mandan el mouse con `Viewport.push_input(evento, true)` (coordenadas locales). No pasa por la ventana, pero no actualiza el estado de `Input`: el test de arrastre de la cámara (`Input.is_action_pressed("camara_arrastrar")`) cambiaría, y D-006 también.
  - C) Que GdUnit4 no minimice la ventana entre tests. Implica tocar el addon.
  - Recomendación técnica: A, con el filtro de device.
- **Bloquea:** sí — no se puede cerrar T24-ajustes: el arreglo que pide la tarea (A o B) no corrige la causa.
- **Mientras tanto:** se paró antes de dejar cambios. La opción B quedó guardada en `git stash` ("T24-ajustes: opcion B (costura de device), en pausa por P-044"): filtro en `VistaCombate._input` (`dispositivo_mouse`, `DISPOSITIVO_CUALQUIERA`), `pruebas/pantalla/mouse_prueba.gd` (`MousePrueba`), los 4 ayudantes y `test_vista_dispositivo_mouse.gd`. El código de la rama está igual que `develop`.
- **Respuesta:** (Arquitecto, 11/10/2026): se toman las dos partes de la recomendación (D-012):

MousePrueba pasa la posición a coordenadas de ventana con get_viewport().get_final_transform(), en el mismo momento de mandar el evento, y lo marca con su propio device. Todo test de mouse pasa por MousePrueba.
VistaCombate acepta solo el device de dispositivo_mouse; por defecto acepta cualquiera, así que el juego no cambia.
El comando de tests no cambia. Se descartan: el modo sin ventana, porque GdUnit4 no transporta los eventos; fijar el tamaño de la ventana o esperar a que se restaure, porque suma esperas; y cualquiera de las dos partes sola. Se cierra en la sesión 2.
- **Cerrada en:** T24-ajustes

## P-045 — En B no queda ninguna enemiga pendiente cuando el Maestro declara la huida
- **Estado:** CERRADA
- **Para:** ARQUITECTO
- **Tarea:** T28
- **Fecha:** 12/10/2026
- **Fuente:** `Arquitectura.md` B.4, fila T28, test (11) y prueba manual (pasos 2 y 5)
- **Duda:** ¿El test (11) y la prueba manual de la huida se pasan de B a un escenario donde alguna enemiga juegue después del Maestro (por ejemplo, D)?
- **Caso que la dispara:** en B las dos Ocarras (Velocidad 7) y la Rodauva (6) juegan antes que el Maestro (5). Cuando él declara, ya no queda ninguna enemiga pendiente en la ronda. `Combate.previsualizar_huida` da la lista vacía y daño máximo 0, el combate termina en `huida` al cerrar esa misma ronda, y el test (11) pasa sin probar la previsualización. Por lo mismo, el paso 2 de la prueba manual ("el panel muestra las Ocarras que actúan antes del cierre") no se va a ver: el panel dice que nadie actúa antes del cierre. En D, el Surcón salvaje (Velocidad 2) juega después del Maestro y figura en la previsualización.
- **Opciones:**
  - A) B queda como está (huir antes de que vuelvan a actuar es la salida de B) y el test con `datos/` real suma D.
  - B) El test (11) y la prueba manual pasan a D.
  - Recomendación técnica: A, que es lo que se hizo.
- **Bloquea:** no
- **Mientras tanto:** `pruebas/datos/test_huida_maestro_b.gd` hace B tal como lo pide la tarea (lista vacía, daño máximo 0, termina en `huida`) y el mismo caso en D (`surcon_s1` figura en la previsualización). Lo aprobó el usuario en el plan de T28.
- **Respuesta:** Arquitecto (12/10/2026): se acepta lo programado. En B el Maestro actúa último y al declarar no queda ninguna enemiga pendiente: la previsualización vacía es correcta. La previsualización con enemigas pendientes queda probada en D. Sin cambios de código. El balance de la huida va a Sistemas como S-63. Se cierra al empezar T29.
- **Cerrada en:** T29

## P-046 — Vida de la atacante resellada
- **Estado:** CERRADA
- **Para:** SISTEMAS
- **Tarea:** T30
- **Fecha:** 13/10/2026
- **Fuente:** `Sistema.md` 4.4 (fila "Resultado": "vuelve guardada con lealtad 1") y 9.3 (fila "Sellar")
- **Duda:** ¿con qué vida queda guardada la atacante nocturna resellada? 4.4 da su lealtad, pero no su vida, y está caída en 0.
- **Caso que la dispara:** el Maestro tumba a la Ocarra atacante en G y la resella. Queda guardada de la tribu; si en 0b se la invoca, ¿sale con 0 de vida, con la de una caída que se levanta o con otra?
- **Opciones:** A) con la vida que tiene (0). B) con un valor propio en `datos/` (como `vida_al_guardar_caida`, 11.5). — Recomendación técnica: B (un guardado con 0 de vida no tiene sentido al invocarlo).
- **Bloquea:** no
- **Mientras tanto:** el usuario respondió en la sesión 2 de T30 y se programó con esa respuesta (abajo).
- **Respuesta:** el usuario, en el chat de la sesión 2 de T30 (13/10/2026): "Queda con 10 puntos de vida". Programado como `tablas/combate.json` `vida_al_resellar` = 10 (esquema `combate`, requerido); los fixtures de combate llevan 1 (D-009). Falta que Sistemas lo pase a `Sistema.md` 4.4.
- **Cerrada en:** T30

## P-047 — En G el resellado falla siempre por la semilla fija
- **Estado:** ABIERTA
- **Para:** ARQUITECTO
- **Tarea:** T30-fix
- **Fecha:** 13/10/2026
- **Fuente:** `Arquitectura.md` B ("Semillas: arbitrarias…") y A.11 (azar: una semilla por partida); `datos/escenarios/g_ataque_nocturno.json` (`semilla: 777`)
- **Duda:** ¿Se deja que G (y R, que recarga el mismo escenario) jueguen siempre con la semilla 777 hasta que T31 permita cambiarla, aunque eso haga que el resellado falle en todas las pruebas manuales?
- **Caso que la dispara:** en G no hay ninguna tirada antes del destino, así que "Sellar de nuevo" es siempre la tirada 0 del generador de combate de la semilla 777: `entero(1, 100)` = **82**, y con 80 % falla siempre (grabación `registros/g_ataque_nocturno_777_4.jsonl`: `mana` 4 → 2 `resellar`, `tirada` índice 0 resultado 82, `destino_atacante` `sellado_fallido`; reproducida dos veces con `herramientas/reproducir.gd`, mismo 82). El usuario lo vio 6 de 6 veces. La cuenta está bien: con 2000 semillas distintas sale 1598 veces (79,9 %, `pruebas/datos/test_resellar_g.gd`).
- **Opciones:** A) se deja así hasta T31 (panel de parámetros y semilla), y la prueba manual del éxito se hace con otra semilla en una copia de los datos (`--datos=`). B) G cambia de semilla (dato del escenario, decisión del staff). — Recomendación técnica: A (la política de semillas no se toca en un fix).
- **Bloquea:** no
- **Mientras tanto:** no se cambió ninguna semilla ni la política. Los tests de T30-fix buscan en el núcleo una semilla que sale y otra que falla.
- **Respuesta:** _(la completa el staff)_
