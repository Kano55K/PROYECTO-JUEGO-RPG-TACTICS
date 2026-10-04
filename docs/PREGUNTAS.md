## P-001 — Qué significa "afines" en la muerte en el grupo
- **Estado:** RESPONDIDA
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
- **Estado:** RESPONDIDA
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

## P-005 — El Maestro en todos los escenarios
- **Estado:** RESPONDIDA
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

## P-006 — Hambre del Maestro en D Hambriento
- **Estado:** RESPONDIDA
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

## P-007 — Posiciones iniciales de los escenarios
- **Estado:** RESPONDIDA
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
- **Estado:** RESPONDIDA
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
