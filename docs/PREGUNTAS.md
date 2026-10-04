## P-001 — Qué significa "afines" en la muerte en el grupo
- **Estado:** ABIERTA
- **Para:** SISTEMAS
- **Tarea:** T04
- **Fecha:** 03/10/2026
- **Fuente:** `Sistema.md` 5.2, fila "Muere o es comida otra criatura del grupo: −2 a todas las sueltas (−4 si eran afines)"
- **Duda:** ¿"afines" significa que la especie de la que murió y la de cada suelta se llevan "bien" (10.8), evaluado suelta por suelta, o se usa la afinidad de combate de 10.3 (relación "bien" y además adyacentes en el tablero)?
- **Caso que la dispara:** el Maestro huye y muere una Rodauva caída. Quedan sueltas otra Rodauva (Rodauva–Rodauva: bien), un Surcón (Rodauva–Surcón: bien) y una Ocarra leal (Rodauva–Ocarra: sin relación). ¿La Ocarra recibe −2 o −4?
- **Opciones:** A) solo la relación de especie, suelta por suelta: Rodauva −4, Surcón −4, Ocarra −2. B) afinidad de combate (10.3): −4 solo a las que se llevan bien con la muerta y estaban adyacentes a ella al morir; el resto, −2. — Recomendación técnica: A (no depende de la posición, y la muerte por huida o derrota ocurre con el combate ya terminado).
- **Bloquea:** no. El esquema `lealtad` guarda los dos números (`eventos.muerte_en_el_grupo` y `eventos.muerte_en_el_grupo_afines`); la regla se programa en T10.
- **Mientras tanto:** solo están los campos en el esquema; no hay código que elija entre −2 y −4.
- **Respuesta:** _(la completa el staff)_

## P-002 — Afines de la atacante comida por el Maestro
- **Estado:** ABIERTA
- **Para:** SISTEMAS
- **Tarea:** T04
- **Fecha:** 03/10/2026
- **Fuente:** `Sistema.md` 5.2, filas "Muere o es comida otra criatura del grupo: −2 a todas las sueltas (−4 si eran afines)" y "El Maestro se come a una criatura que lo atacó: Solo −2 a todas las sueltas (sin el −3 extra)"; 9.3
- **Duda:** cuando el Maestro se come a la atacante, ¿las sueltas afines a ella reciben −2 como todas, o −4 como en cualquier muerte en el grupo?
- **Caso que la dispara:** una Ocarra ataca de noche, es derrotada y el Maestro se la come. Quedan sueltas una Rodauva y otra Ocarra; si la otra Ocarra fuera afín a la atacante, ¿recibe −2 o −4?
- **Opciones:** A) −2 a todas, sin excepción ("solo −2 a todas"). B) −2 a todas y −4 a las afines (la fila de muerte en el grupo sigue aplicando; "solo" quita únicamente el −3 extra). — Recomendación técnica: A (es la lectura literal).
- **Bloquea:** no. `tablas/lealtad.json` guarda `eventos.comer_atacante: -2` y `eventos.muerte_en_el_grupo_afines: -4`; la regla se programa en T10.
- **Mientras tanto:** solo están los datos; no hay código que elija.
- **Respuesta:** _(la completa el staff)_

## P-003 — Tramos de obediencia y estados de lealtad
- **Estado:** ABIERTA
- **Para:** SISTEMAS
- **Tarea:** T04
- **Fecha:** 03/10/2026
- **Fuente:** `Sistema.md` 5.4, tabla de obediencia (filas "≥ umbral de rescate", "4 hasta umbral − 1", "≤ 3"), y 5.1 (Desleal 0–1, Dudosa 2–3, Neutral 4 hasta umbral − 1)
- **Duda:** ¿los tramos de obediencia de 5.4 son los mismos cortes que los estados de lealtad de 5.1 (aplicados a la obediencia), o son umbrales propios que se pueden ajustar por separado?
- **Caso que la dispara:** si un ajuste de balance mueve Neutral de 5.1 a "desde 5", ¿una criatura con obediencia 4 pasa al tramo "≤ 3" (+10 Encono, +20 cobardía, ataca a la rival aliada) o sigue en el tramo normal?
- **Opciones:** A) mismos cortes: el código lee el límite de `tablas/lealtad.json` (`dudosa_hasta`) y se quita `obediencia.baja.hasta` de `tablas/combate.json`. B) umbrales propios: queda `obediencia.baja.hasta: 3` en `tablas/combate.json`. — Recomendación técnica: A (la fila de 5.4 repite la de 5.1 y así cada número vive en un solo archivo).
- **Bloquea:** no. Hoy los dos valen 3 y dan el mismo resultado.
- **Mientras tanto:** `tablas/combate.json` guarda `obediencia.baja.hasta: 3` citando 5.4; no hay código que lo lea todavía.
- **Respuesta:** _(la completa el staff)_
