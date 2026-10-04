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
- **Estado:** RESPONDIDA
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

## P-003 — Tramos de obediencia y estados de lealtad
- **Estado:** RESPONDIDA
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
- **Estado:** RESPONDIDA
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
- **Respuesta:** _(la completa el staff)_
- **Cerrada en:** T06 (test (8) de T05, `pruebas/unidades/test_plantel.gd`)

## P-010- ESTADO --> RESPONDIDA

- Arquitecto (04/10/2026): error del criterio. Las salvajes no tienen pergamino (Sistema.md 3.2); el test (2) queda como está. La independencia de pergaminos se prueba con las dos Rodauvas de la tribu de E: nuevo test (8) de T05 en Arquitectura.md v0.10. Se cierra al agregar ese test.

## P-011 — Empate de Velocidad entre dos enemigas
- **Estado:** ABIERTA
- **Para:** SISTEMAS
- **Tarea:** T07
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.3, fila Empates (desempata tribu contra enemigas, Maestro contra criaturas y criaturas de la tribu entre sí, pero no dos enemigas entre sí). Es la S-14 de `Arquitectura.md` 10.5
- **Duda:** dos enemigas con la misma Velocidad, ¿actúan en el orden de la lista `enemigas` del escenario?
- **Caso que la dispara:** escenario B: `ocarra_s1` y `ocarra_s2`, las dos con Velocidad 7.
- **Opciones:** A) orden de la lista `enemigas` (como el orden de la tribu). B) otra regla (por ejemplo, la más cercana al Maestro primero). — Recomendación técnica: A (lectura declarada del Arquitecto, S-14).
- **Bloquea:** no
- **Mientras tanto:** programado con A en `nucleo/combate/cola_iniciativa.gd`; test (5) de T07 (`pruebas/combate/test_cola_iniciativa.gd`). Si Sistemas elige otra regla, cambia un desempate y ese test.
- **Respuesta:** _(la completa el staff)_

## P-012 — Unidad que deja de poder actuar a mitad de ronda
- **Estado:** ABIERTA
- **Para:** SISTEMAS
- **Tarea:** T07
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.5 (la caída "no actúa"; la salvaje en 0 "huye del tablero") y 11.3 (fila Criatura invocada)
- **Duda:** si una unidad queda caída, es guardada o sale del tablero después de armada la cola, ¿pierde todos sus turnos restantes de esa ronda, incluida la Cuenta del Tasajero si huye después de su Caza?
- **Caso que la dispara:** escenario C: el Tasajero actúa en Caza (8), baja a ≤ 25% y huye antes de su Cuenta (3). Lectura literal: la Cuenta se saltea.
- **Opciones:** A) se saltean todas sus entradas restantes de la ronda. B) otra regla para algún caso. — Recomendación técnica: A (lectura literal).
- **Bloquea:** no
- **Mientras tanto:** programado con A: al avanzar, la cola saltea las entradas de unidades que no están sueltas o no tienen posición (hoy "fuera del tablero" = sin posición; la huida de salvajes llega en su tarea). Tests (6b) de T07.
- **Respuesta:** _(la completa el staff)_

## P-013 — Velocidad del Maestro en la cola
- **Estado:** ABIERTA
- **Para:** SISTEMAS
- **Tarea:** T07
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.2 ("su Movimiento, Alcance y Velocidad no dependen de [la balanza]") y 11.5 (si el Maestro cae, el combate termina en el acto)
- **Duda:** ¿la Velocidad del Maestro es siempre la de `maestro.json` (5), sin ningún modificador en 0a (hambre, enfermedad, balanza), y el Maestro entra en la cola en todas las rondas?
- **Caso que la dispara:** escenario D Hambriento o un Maestro en balanza 5: la cola lo pone igual con Velocidad 5.
- **Opciones:** A) sí, siempre 5 y siempre en la cola. B) algún estado la modifica. — Recomendación técnica: A (lectura literal).
- **Bloquea:** no
- **Mientras tanto:** programado con A; el Maestro nunca se saltea porque si cae el combate termina (lo resuelve otra tarea).
- **Respuesta:** _(la completa el staff)_

## P-014 — Moverse después de erizarse
- **Estado:** ABIERTA
- **Para:** SISTEMAS
- **Tarea:** T08
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.2, fila Rodauva ("Erizarse (acción): hasta su próximo turno […] no se mueve") y 11.3, fila Turno de una unidad ("1 movimiento y 1 acción, en cualquier orden"). Es la S-15 de `Arquitectura.md` 10.5
- **Duda:** si la Rodauva se eriza antes de usar su movimiento, ¿puede moverse después en el mismo turno?
- **Caso que la dispara:** Rodauva de la tribu en [2,6], al empezar su turno se eriza; después intenta moverse a [1,6].
- **Opciones:** A) no: erizarse cierra el movimiento que quede (si ya se había movido, vale). B) sí: el "no se mueve" empieza después de su turno. — Recomendación técnica: A (lectura declarada del Arquitecto, S-15).
- **Bloquea:** no
- **Mientras tanto:** programado con A en `nucleo/combate/turno.gd` (mover se rechaza con motivo `ERIZADA`); tests (7a) y (7b) de T08 (`pruebas/combate/test_turno.gd`). Si Sistemas elige B, cambia una condición y el test (7a).
- **Respuesta:** _(la completa el staff)_

## P-015 — Terminar el turno sin usar la acción es "esperar"
- **Estado:** ABIERTA
- **Para:** SISTEMAS
- **Tarea:** T08
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 10.2 ("No la corta: […] esperar") y 11.3, fila Turno de una unidad (acciones: "… Erizarse, esperar"). Es la S-16 (no figura todavía en la copia de `Arquitectura.md` 10.5 del repositorio)
- **Duda:** ¿terminar el turno sin usar la acción (con o sin movimiento) cuenta como la acción "esperar"?
- **Caso que la dispara:** la Ocarra de la tribu se mueve y cierra el turno sin atacar, entre dos golpes aliados al mismo objetivo.
- **Opciones:** A) sí: se registra "esperar"; no corta la cadena (el corte de cadena es de T16). B) "esperar" es una acción aparte y terminar sin acción es otra cosa. — Recomendación técnica: A (lectura declarada del Arquitecto, S-16).
- **Bloquea:** no
- **Mientras tanto:** programado con A: `terminar` sin haber usado la acción devuelve `espero = true` en `ResultadoAccion` (`nucleo/combate/turno.gd`); test (10) de T08. T16 lo usa para la cadena.
- **Respuesta:** _(la completa el staff)_

## P-016 — Saciado y enfermedades de las enemigas en el daño
- **Estado:** ABIERTA
- **Para:** SISTEMAS
- **Tarea:** T09
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 7.1 ("Cada ser (el Maestro y cada criatura suelta) tiene un valor de Hambre") y 8.2. Es la S-17 de `Arquitectura.md` 10.5
- **Duda:** las salvajes, el Tasajero y la atacante nocturna, ¿reciben el +25% de Saciado o el −25% por enfermedad en su daño?
- **Caso que la dispara:** una Ocarra salvaje (los escenarios no le dan hambre, y el modelo lo deja en 0, que sería Saciado) pega al Maestro: ¿4 o 5? La atacante nocturna del escenario G trae hambre 9.
- **Opciones:** A) no: pegan con su Daño base, sus rasgos y los aportes que les toquen. B) sí, con el hambre y las enfermedades que traigan. — Recomendación técnica: A (lectura declarada del Arquitecto, S-17; coincide con 11.6: dos golpes de la Ocarra salvaje tumban a la Rodauva).
- **Bloquea:** no
- **Mientras tanto:** programado con A en `nucleo/combate/danio.gd` (hambre y enfermedades solo para el Maestro y la tribu); test (11) de T09 (`pruebas/combate/test_danio.gd`). Si Sistemas elige B, cambia una condición y ese test.
- **Respuesta:** _(la completa el staff)_

## P-017 — Daño negativo tras los porcentajes y bonos planos
- **Estado:** ABIERTA
- **Para:** SISTEMAS
- **Tarea:** T09
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.4 (pasos 2 a 4) y 8.4 ("Redondeo hacia abajo. El daño nunca baja de 1")
- **Duda:** si los porcentajes suman menos de −100% y el daño queda por debajo de 0 tras el paso 2, ¿los bonos planos del paso 3 se suman sobre ese valor negativo (el único recorte es el mínimo del paso 4)?
- **Caso que la dispara:** el Zancajunco (4) con 3 enfermedades (−75%) ataca a una Rodauva erizada (−50%) en su primer ataque (+2): 4 × (−25%) = −1, +2 = **1**. Si se recorta a 0 antes de los planos: 0 + 2 = **2**.
- **Opciones:** A) sin recorte intermedio: −1 + 2 = 1. B) recortar a 0 tras el paso 2: 2. — Recomendación técnica: A (lectura literal de 11.4 y de `Arquitectura.md` B.2, T09: "piso explícito").
- **Bloquea:** no
- **Mientras tanto:** programado con A en `nucleo/combate/danio.gd`; tests (8) y (10) de T09 (`pruebas/combate/test_danio.gd`: −125% sobre 2 da −1). Si Sistemas elige B, se agrega un recorte en `Danio` (no en `Porcentajes`) y cambia el test (8).

## P-018 — La caída bloquea el paso y la línea de Alcance 2
- **Estado:** ABIERTA
- **Para:** SISTEMAS
- **Tarea:** T10
- **Fecha:** 04/10/2026
- **Fuente:** `Sistema.md` 11.5, Reglas de la caída ("queda en su casilla y la ocupa" y "no participa de ninguna relación") y 11.3, fila Alcance 2 ("nunca por encima de una enemiga")
- **Duda:** una unidad caída, ¿bloquea el paso y la línea de Alcance 2 de la otra banda igual que si estuviera de pie?
- **Caso que la dispara:** la Ocarra atacante nocturna cae en [3,5]; la Ocarra de la tribu en [3,6] quiere golpear a una salvaje en [3,4] por encima de ella, o el Maestro quiere pasar por [3,5]. Lectura literal: no puede (la caída ocupa la casilla y es enemiga).
- **Opciones:** A) sí: bloquea como de pie (no se pasa por encima ni a través de una caída enemiga; por una aliada sí). B) no: la casilla está ocupada (nadie termina ahí), pero no corta la línea ni el paso. — Recomendación técnica: A (lectura literal; es lo que ya hace `Tablero` desde T06, que cuenta a las caídas como ocupantes).
- **Bloquea:** no
- **Mientras tanto:** programado con A, sin cambios en `nucleo/combate/tablero.gd`. Si Sistemas elige B, `Tablero` deja de contar a las caídas para el paso y la línea (no para terminar el movimiento) y se agrega un test.
- **Respuesta:** _(la completa el staff)_

## P-019 — Nombres de motivo de lealtad en el resultado
- **Estado:** RESPONDIDA
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
