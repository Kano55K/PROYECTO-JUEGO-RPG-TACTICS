# SISTEMA — Reglas, números y balance

> **Estado:** Borrador v1.2 · **Dueño:** Diseñador de Sistemas y Balance · **Última actualización:** 04/10/2026
> **Sincronizado con:** `00_Vision.md` v1.0 · `Mundo.md` v1.0 · `Arquitectura.md` v0.16 (responde las dudas abiertas de 10.5: S-13 a S-19, y P-011 a P-018 y P-020 a P-022 de `docs/PREGUNTAS.md`).
> Este documento baja a números lo definido en `00_Vision.md`. Si algo acá contradice la Visión, manda la Visión: se propone el cambio y se registra en `Decisiones.md`.
> Los nombres del juego (Arrimo, Encono, Secundar, péñola, prenda, Urdimbre, "lo que diste", Erizarse, Lomo de tierra, Alabarda, Hacerse junco, Caza y cuenta, Martillazo, Lanzadera, Remiendo, Leña en las púas, Sueño liviano, Madriguera, Acecho, Poza Tibia, quebranto, Menestral, las rayas y las golondrinas) son finales y viven en `Mundo.md` (1.2, 2.8, 2.9, 4.5, 4.7, 4.9 y 4.10). Los marcados como *(provisorio)* esperan la confirmación del Worldbuilder.

**Cómo leer este documento:**
- `DECIDIDO` → la **regla** está aprobada. Los **números** son valores iniciales de test y se ajustan sin necesidad de nueva decisión.
- `PROPUESTA` → se discute, todavía no es regla.
- `PREGUNTA ABIERTA` → sin respuesta.
- Cada tabla incluye la **decisión que genera en el jugador**. Si una regla no genera decisiones, se cuestiona.

---

## 1. El Maestro

### 1.1 Atributos — `DECIDIDO`

| Atributo | Qué controla | Valor inicial MVP | Decisión que genera |
|---|---|---|---|
| **Balanza Barro ↔ Soplo** | Posición de 1 (polo Barro) a 5 (polo Soplo). Define maná, descuentos, rango sellable, vida, daño físico, vínculos y Arrimo (tabla 1.2) | 2 | ¿Quiero ser un gran mago o un gran líder de mi tribu? |
| **Poder mágico** | Daño/curación = base del hechizo + Poder | 1 | ¿Invierto en pelear con magia o en sostener al grupo? |
| **Regeneración de maná** | Maná por turno en combate = valor del atributo | 1 | ¿Aguanto combates largos o juego a ráfagas? |

**Balanza inicial:** la clase del MVP arranca en la **posición 2** (inclinada al Barro). El MVP enseña primero la tribu.

### 1.2 Tabla de la balanza — `DECIDIDO`

| Posición | Reserva de maná | Descuento sellar/invocar | Rango máx. sellable | Vida máxima real | Daño cuerpo a cuerpo | Umbral de rescate | Lealtad por día alimentada | Ajuste a la lealtad inicial | Pasos de Arrimo |
|---|---|---|---|---|---|---|---|---|---|
| 1 (Barro) | 7 | — | 1 | 22 | 5 | 6 | +1 por día | — | 4 |
| 2 | 8 | — | 2 | 20 | 4 | 7 | +1 por día | — | 3 |
| 3 | 9 | −1 | 2 | 18 | 4 | 7 | +1 por día | −1 | 2 |
| 4 | 10 | −1 | 3 | 16 | 3 | 8 | +1 cada 2 días | −1 | 1 |
| 5 (Soplo) | 11 | −2 | 3 | 14 | 3 | 8 | +1 cada 2 días | −2 | 0 |

**Fórmulas:**
- Reserva = **6 + posición**
- Vida máxima real = **24 − 2 × posición** (ver 7.8)
- Daño cuerpo a cuerpo = **5 − (posición ÷ 2)**, redondeado hacia abajo
- Umbral de rescate = **6 + (posición ÷ 2)**, redondeado hacia abajo
- Pasos de Arrimo = **5 − posición**

**Reglas:**
- **Costo mínimo:** con descuento, ninguna acción cuesta menos de **1 maná**.
- Al mover la balanza, el umbral de rescate, el ritmo de lealtad y el Arrimo cambian **de inmediato**. El ajuste a la lealtad inicial **no** se recalcula: solo aplica al capturar.
- La interfaz avisa, **antes de confirmar**, qué criaturas dejan de poder rescatar al Maestro.
- El camino de confianza **respeta** el rango máximo sellable: el polo Barro captura menos, pero lidera mejor.

La vida y el daño físico de esta tabla son las estadísticas del Maestro en la ficha de combate (11.2).

### 1.3 Arrimo — efecto del polo Barro — `DECIDIDO`

Cada paso de Arrimo:
- Baja **5 puntos** la probabilidad de incidente entre rivales aliadas (−25% del base de 20%).
- Baja **5 puntos** la probabilidad de Encono.
- Baja **5 puntos** la probabilidad de cobardía.
- Suma **+10 puntos** al bono de combo.

| Posición | Pasos | Incidente de rivalidad | Bono de combo (sin relación / afines) |
|---|---|---|---|
| 1 | 4 | 0% | +60% / +80% |
| 2 (inicial) | 3 | 5% | +50% / +70% |
| 3 | 2 | 10% | +40% / +60% |
| 4 | 1 | 15% | +30% / +50% |
| 5 | 0 | 20% | +20% / +40% |

**Decisión que genera:** ¿quiero un plantel amplio o un grupo chico que funcione como una sola tribu?

### 1.4 Progresión por nivel — `DECIDIDO`

| Al subir de nivel | Regla |
|---|---|
| Punto de atributo | +1 a Poder mágico o a Regeneración de maná |
| Balanza | Además, opcionalmente, mover la balanza 1 paso hacia cualquier polo |

**Motivo:** la balanza es un intercambio, no una ganancia pura; cobrarla como punto castigaría doble al polo Barro.

**Experiencia** — `DECIDIDO` (Visión 6.1; números del 02/10/2026):

| Fuente | XP | Regla | Decisión que genera |
|---|---|---|---|
| Una criatura llega a **Leal por primera vez** | 3 | Una vez por instancia. Incluye a la compañera inicial | Cuidar a cada criatura hasta que llegue a leal paga |
| **Captura** (cualquiera de los dos caminos) | 3 | Solo la **primera captura de cada especie** (máximo 4 en el MVP: 12 XP). La compañera inicial no cuenta como captura. Resellar no da XP | Ampliar la tribu con especies nuevas, no repetir la misma |
| **Ritual de sangre** | 3 | — | El viaje largo también hace crecer al Maestro |
| **Combate de nodo ganado** | 1 | Las emboscadas, los ataques nocturnos y las huidas no dan XP | Pelear suma, pero no reemplaza a la tribu |
| **Derrotar al Tasajero** | 3 | Reemplaza al 1 del combate (12.10) | El único combate que vale como un hito |
| Comerse una criatura | 0 | Nunca da experiencia | — |

**Por qué las emboscadas y los ataques nocturnos no dan XP:** si dieran, dejar guardias sin cubrir sería una forma de farmear, y un ataque nocturno premiaría haber maltratado a la tribu. **Por qué la captura cuenta una vez por especie:** corta el loop de comerse una criatura y recapturar otra de la misma especie, y premia la tribu variada, igual que las habilidades de campamento (9.4).

**Curva:** XP para pasar del nivel N al N+1 = **5 × N**. Nivel máximo en el MVP: **10**.

| Nivel | 1→2 | 2→3 | 3→4 | 4→5 | 5→6 |
|---|---|---|---|---|---|
| Costo | 5 | 10 | 15 | 20 | 25 |
| Acumulado | 5 | 15 | 30 | 50 | 75 |

**Subida de nivel:** la XP se suma al instante, pero el nivel sube en el **paso 0 del cierre del día** (7.9), con el aviso de qué rescatistas se pierden antes de confirmar. Así toda la noche usa los valores nuevos.

**Decisión que genera:** ¿muevo la balanza esta noche, sabiendo que cambia quién me rescata mañana?

**Verificación (partida de 30 días, sección 13):**

| Estilo de partida | Capturas | Leales | Rituales | Combates | Total | Nivel final |
|---|---|---|---|---|---|---|
| Tribu cuidada | 9–12 | 18 | 9 | 15 | 51–54 | 5 (4 subidas) |
| Buscador de peleas | 6 | 6 | 3 | 25 | 40 | 4 (3 subidas) |
| Partida floja | 3–6 | 6 | 0–3 | 8 | ~20 | 3 (2 subidas) |

Los hitos son cerca del 70% de la XP en una partida cuidada: el Maestro crece cuando crece su tribu. **Primer nivel:** capturar la Ocarra el día 1 (+3, +1 por el combate) y que la Rodauva llegue a leal el día 2 (+3) da 7 XP: sube el día 2.

La experiencia no entra en la Prueba 0a.

### 1.5 Alimentación del Maestro — `DECIDIDO`

| Regla | Valor | Decisión que genera |
|---|---|---|
| Omnívoro | Acepta todos los tipos de comida, incluida una criatura (cuenta como carne) | La decisión más dura del juego siempre está disponible |
| Día monótono | Todas las raciones del día fueron del mismo tipo | — |
| Aviso | Al 2.º día monótono seguido aparece el indicador "comiendo lo mismo" | Tiempo para reaccionar |
| Enfermo por dieta | Al 3.er día monótono seguido del mismo tipo: Enfermo seguro (como Empacho, 1 día) | Moverse entre destinos o resignarse a un tipo de comida |

### 1.6 Hechizos de la clase inicial — `DECIDIDO`

Rama única del MVP. Aprobados en la Visión v0.7; nombres finales en `Mundo.md` 2.8. Los tres están disponibles desde el nivel 1; el orden de desbloqueo se define con las ramas (Capa 3).

| Hechizo | Costo | Alcance | Efecto | Escala con Poder | Decisión que genera |
|---|---|---|---|---|---|
| **Martillazo** (básico) | 2 | Distancia Manhattan ≤ 3, sin bloqueo | Daño **2 + Poder** (3 al inicio) | Sí | ¿Pego 4 cuerpo a cuerpo gratis o 3 a distancia con el maná del sellado? |
| **Lanzadera** (básico) | 2 | Línea recta ≤ 2; no atraviesa enemigas | Empuja o atrae **1 casilla** a una unidad que no esté caída. Si la casilla está ocupada o fuera del tablero, no se mueve y recibe 1 de daño | No | Separar rivales aliadas, juntar rivales salvajes, sacar a la Rodauva del alcance del Tasajero |
| **Remiendo** (fuerte) | 4 | Adyacente o sí mismo | Cura **3 + Poder** (4 al inicio). **No afecta a las caídas** (11.5) | Sí | ¿Media reserva para sostener a una aliada o para sellar? |

**Reglas comunes:**
- Lanzar un hechizo gasta la **acción** del Maestro; conserva su movimiento.
- El Martillazo es un ataque: cuenta como eslabón de combo y le aplican Saciado, enfermedades y afinidad (11.4). Su daño exacto lo vuelve la **mano fina para sellar**.
- La Lanzadera no es un ataque: no suma eslabón ni corta la cadena.

**Lanzadera: casos borde** — `DECIDIDO` (03/10/2026):

| Caso | Regla | Decisión que genera |
|---|---|---|
| Daño del choque | **1 fijo**, sin modificadores. Solo lo recibe la unidad movida, no la que ocupa la casilla | — |
| ¿Es un ataque? | No: no suma Encono, no cuenta como golpe a la rival, no gasta Hacerse junco y no corta la cadena | — |
| ¿Puede tumbar? | Sí. Una salvaje en 0 huye y se pierde la captura (11.5); una aliada queda caída | Empujar contra una pared a una salvaje con 1 de vida es perderla |
| Atraer a una unidad adyacente al Maestro | Objetivo no válido | — |
| Unidad erizada | **Se puede mover**: Erizarse le impide moverse sola, no que la muevan. Conserva el −50% | Sacar a la Rodauva erizada del alcance del Tasajero sigue siendo posible |
- Sin descuento de la balanza (2.3). No se usan fuera del combate (2.5).

**Identidad del Soplo:** con la balanza en 5 y Poder 3, el Maestro pega 3 cuerpo a cuerpo y 5 con el Martillazo: un mago de distancia con reserva grande.

---

## 2. Maná

### 2.1 Regeneración — `DECIDIDO`

| Momento | Regla | Decisión que genera |
|---|---|---|
| En combate | Al **inicio de cada turno del Maestro** regenera lo que indique el atributo Regeneración. "Turnos pares" (2.2) significa **rondas pares** | ¿Gasto ahora o espero un turno? |
| Tope de combate | El maná nunca supera el valor con el que se entró al combate | Dormir bien antes de un combate importante define la pelea |
| Al dormir | 1 vez por día en el mapa del mundo; la cantidad depende del hambre **al acostarse**, antes de sumar el hambre del día (2.2 y 7.9) | ¿Como antes de dormir o guardo la comida? |

### 2.2 Efecto del hambre sobre el maná — `DECIDIDO`

| Estado de hambre | Regeneración en combate | Recuperación al dormir |
|---|---|---|
| Saciado | 100% | Reserva completa |
| Normal | 100% | Reserva completa |
| Hambriento | Solo en turnos pares | 50% de la reserva máxima (redondeado hacia abajo) |
| Famélico | 0 | 0 |

### 2.3 Costos — `DECIDIDO`

| Acción | Rango 1 | Rango 2 | Rango 3 | Decisión que genera |
|---|---|---|---|---|
| Hechizo básico (Martillazo, Lanzadera; 1.6) | 2 | — | — | Pegar ahora o guardar para sellar |
| Hechizo fuerte (Remiendo; 1.6) | 4 | — | — | Una jugada grande o dos chicas |
| Sellar criatura | 3 | 5 | 7 | ¿Vale media reserva esta criatura? |
| Invocar criatura propia | 2 | 3 | 4 | ¿La saco ahora o espero? |
| Resellar a una criatura propia caída (4.4) | 2 | 3 | 4 | ¿Guardo maná en el combate para recuperarla? |
| Guardar a una caída propia (11.5) | 2 | 3 | 4 | ¿Gasto el maná en salvarla o en ganar la pelea? |

El descuento de la balanza se aplica a sellar, invocar, resellar y guardar caídas, nunca a hechizos.

### 2.4 Maná en el combate nocturno — `DECIDIDO`

Si una criatura ataca de noche (ver 9.2), el sueño se interrumpe: el Maestro recupera **la mitad** de lo que habría recuperado (redondeado hacia abajo). Ese valor es su **tope de combate**. Esa noche no recupera más.

**Decisión que genera:** una criatura en riesgo no solo amenaza la vida del Maestro; también arruina el descanso del que depende el día siguiente.

### 2.5 Magia fuera del combate — `DECIDIDO`

| Acción | Costo | Decisión que genera |
|---|---|---|
| Invocar | Igual que en combate: 2 / 3 / 4 (con descuento, mínimo 1) | ¿La saco ahora o espero al combate? |
| Guardar | Gratis | — |
| Sellar por el camino de confianza | Costo de sellado del rango | — |
| Hechizos de daño o curación | **No se pueden usar** | — |

**Motivo:** si los hechizos se pudieran usar en el mapa, el Maestro se curaría gratis todas las noches gastando el maná que el sueño le devuelve.

> ⚠️ **A vigilar:** dormir llena la reserva sin importar cuánto maná quede, así que invocar a la noche es gratis en maná, pero la criatura **come ese día y el siguiente**. Invocar a la mañana cuesta maná del día, que ya no está para el combate. Si en los tests todos invocan siempre a la noche, se revisa.

---

## 3. Pergaminos

### 3.1 Estados de la criatura — `DECIDIDO`

| Regla | Valor | Decisión que genera |
|---|---|---|
| Invocar en combate | Gasta el turno completo del Maestro. La criatura aparece en una **casilla libre adyacente** al Maestro; si no hay ninguna, no se puede invocar | Conviene tener criaturas sueltas antes del combate, pero eso cuesta comida. Un Maestro rodeado no recibe refuerzos |
| Guardar fuera de combate | Gratis | — |
| Guardar en combate | Cuesta la acción de la criatura y exige que esté adyacente al Maestro | ¿La salvo o la dejo pelear un turno más? |
| Guardar a una caída | Cuesta la acción del Maestro y maná (11.5) | ¿La salvo ahora o sigo peleando? |
| Cobro de comida | Come toda criatura que estuvo suelta en algún momento del día | Sacarla "un ratito" también cuesta |
| Criatura guardada | No come, no sufre clima, no gana ni pierde lealtad, no participa de relaciones, no abandona, **no se cura** | Seguridad contra vínculo |
| Criatura suelta | Come, sufre el clima, gana y pierde lealtad, tiene relaciones, se cura al dormir (7.8) | Disponibilidad y vínculo contra costo |

### 3.2 Cantidad y pérdida — `DECIDIDO`

| Regla | Valor | Decisión que genera |
|---|---|---|
| Pergaminos iniciales | **3** | ¿Uso el tercero ya o guardo uno en blanco de reserva? |
| Ocupación | Cada criatura de la tribu, suelta o guardada, ocupa uno | El tamaño de la tribu tiene techo |
| Quema | Todo vínculo roto quema el pergamino: abandono, perdón a una atacante y muerte (incluido que sea comida) | Toda pérdida cuesta un ritual |
| Pergamino de la atacante | Arde cuando se resuelve su destino (9.3), sea cual sea la salida | — |

Los pergaminos **nunca** son un recurso de supervivencia.

### 3.3 Ritual de sangre — `DECIDIDO`

Evento fijo del Molino con requisitos; no es crafteo. Lo puede hacer cualquier Maestro, sin importar la balanza. Da **1 pergamino**.

**Requisitos** (detalle en la Visión 6.7 y en `Mundo.md` 2.6):

| Requisito | De dónde sale | ¿Se gasta? |
|---|---|---|
| Péñola | El palomar (Huertos de Almiar) | Sí |
| Agua de charco | El charco quieto (Vado de los Juncos) | Sí |
| Ramita de roble | El Roble Viejo (Robledal Hondo) | Sí |
| Cuenco | La hornacina (ruinas de Almiar) | No: permanente |
| Carbón | El fuego del Molino; con él se traza la **Urdimbre** | Siempre disponible |
| Prenda | El Maestro o cualquier criatura suelta, sin diferencia mecánica | Siempre disponible |
| Sangre del Maestro | Su cuerpo | Ver "Costo en sangre" |

**Materiales:**

| Regla | Valor | Decisión que genera |
|---|---|---|
| Hallazgo | **1 garantizado por visita** en cada destino, en un nodo propio | Cada visita: ¿gasto un nodo en el material o en comida? |
| Acumulación | Se acumulan sin límite y no se echan a perder | Juntar de antemano para reponer rápido |
| Cuenco | Garantizado en el primer recorrido de las ruinas de Almiar | — |

**Costo en sangre:**

| Efecto | Valor |
|---|---|
| Daño | **25% de la vida máxima real**, fijo (redondeado hacia abajo), restado de la vida actual |
| Debilidad ("lo que diste") | **−4 de vida máxima durante 3 días**. Si la vida actual supera el nuevo máximo, se recorta. **No es un estado:** se muestra como un tramo marcado en la barra de vida, con su contador de días |
| Acumulación | Cada ritual tiene su propio contador de debilidad; se acumulan. El daño no se achica por rituales recientes |

**Restricciones:**
- **El ritual nunca mata:** exige vida actual **mayor** que el daño (con balanza 2: vida 6 o más).
- No se puede hacer **famélico**.
- Máximo **1 ritual por día**.

**Ejemplo (balanza 2, dos rituales en días seguidos, sin curación en el medio):**

| | Vida actual | Vida máxima vigente |
|---|---|---|
| Inicio | 20 | 20 |
| Ritual 1 | 15 | 16 |
| Ritual 2 | 10 | 12 |

**Decisión que genera:** ¿hago el ritual antes de salir hacia el Robledal, con el cuerpo debilitado, o al volver, sin pergamino de reserva para el viaje?

### 3.4 Compañera inicial — `DECIDIDO`

| Regla | Valor |
|---|---|
| Criatura | **Rodauva** (fija en el MVP) |
| Estado inicial | Suelta, lealtad **5** (camino de confianza) → Neutral con la balanza en 2 |
| Pergaminos | Ocupa 1 de los 3 iniciales: el jugador arranca con **2 en blanco** |
| Hambre inicial | **3** (Normal) para la Rodauva y el Maestro |
| Inventario inicial | **2 raciones de fruta** (las que la Rodauva trae clavadas en las púas) |
| Llega a leal (umbral 7) | Día 2 bien alimentada (5 → 6 → 7). El día 1 solo si come bien **y** gana un combate (+1 +1) |

**Consecuencia de balance:** el primer combate del día 1 se pelea **sin rescatista**. Por eso los encuentros de los Huertos tienen un tope de amenaza (11.6).

**Decisión que genera:** ¿arriesgo el día 1 peleando para que la compañera llegue a leal esa noche, o espero un día más seguro?

Se puede tener **más de una criatura de la misma especie**: cada una es una instancia separada, con su propia lealtad, hambre, vida y pergamino.

---

## 4. Captura

### 4.1 Probabilidad de sellado — `DECIDIDO`

| Vida restante | Rango 1 | Rango 2 | Rango 3 |
|---|---|---|---|
| ≤ 25% | 80% | 65% | 50% |
| 26–50% | 50% | 35% | 20% |
| 51–75% | 20% | 10% | 5% |
| > 75% | 5% | 0% | 0% |
| **Camino de confianza** | **100%** | **100%** | **100%** |

| Regla | Decisión que genera |
|---|---|
| El porcentaje se muestra antes de gastar el maná | La apuesta es informada |
| Si falla, el maná gastado se pierde | ¿Tiro ahora o le pego un turno más y arriesgo matarla? |
| Solo se sellan criaturas de rango ≤ rango máximo de la balanza, por cualquier camino | La posición de la balanza abre o cierra el acceso a criaturas fuertes |
| Toda captura exige un pergamino en blanco | Sin pergamino, no hay captura |
| En combate, sellar gasta la **acción** del Maestro (conserva el movimiento), a distancia Manhattan **≤ 2**, sobre una salvaje de pie. Si sale bien, la salvaje deja el tablero guardada y cuenta como enemiga fuera | Para sellar hay que acercar al Maestro, y eso lo expone (Pilar 1) |

### 4.2 Lealtad inicial según el camino — `DECIDIDO`

| Camino | Lealtad base | Balanza 3–4 | Balanza 5 |
|---|---|---|---|
| Combate | 2 | 1 | 0 |
| Confianza | 5 | 4 | 3 |

### 4.3 Rango de las criaturas del MVP — `DECIDIDO`

| Criatura | Rango | Rol | Sellable con la balanza inicial (2) |
|---|---|---|---|
| Rodauva | 1 | Trabajo | Sí |
| Ocarra | 1 | Combate | Sí |
| Surcón | 2 | Trabajo | Sí |
| Zancajunco | 2 | Mixto | Sí |
| Tasajero | 3 | Combate | No. En el MVP no se sella ni se domestica, sin importar la balanza: solo se apacigua |

### 4.4 Resellar a una criatura propia caída — `DECIDIDO`

Aplica a la criatura que atacó al Maestro y fue derrotada (ver 9.3).

| Regla | Valor |
|---|---|
| Costo | Igual que **invocar**: 2 / 3 / 4, con el descuento de la balanza y mínimo 1 |
| Probabilidad | Fila de vida ≤ 25%: 80% / 65% / 50% |
| Pergamino | Su pergamino ya ardió: exige **un pergamino en blanco** |
| Resultado | Vuelve **guardada** con lealtad **1** (con el ajuste de la balanza; nunca menos de 0) |
| Si falla | El maná se pierde y el Maestro vuelve a elegir entre perdonar y comer |

**Factibilidad con la balanza 2** (sin maná gastado en el combate):

| Hambre del Maestro | Tope nocturno | Rango 1 (2) | Rango 2 (3) |
|---|---|---|---|
| Saciado / Normal | 4 | Sí | Sí |
| Hambriento | 2 | Sí | No |
| Famélico | 0 | No | No |

**Decisión que genera:** ¿gasto en el combate el maná que necesito para resellarla? ¿Vale mi pergamino de reserva recuperar a una criatura que me traicionó?

### 4.5 Camino de confianza — `DECIDIDO`

| Regla | Valor | Decisión que genera |
|---|---|---|
| Dónde | En el **nodo de avistamiento** de la especie (12.7). Las salvajes de combate y mixtas atacan en los encuentros: su avistamiento es un nodo aparte | — |
| Cada día | Se ofrece 1 ración: favorita **+2** de confianza, aceptada **+1**. La ración se pierde | ¿Gasto comida y un nodo en una criatura que todavía no es mía? |
| Olvido | **−1** de confianza por cada día sin alimentarla | Hay que volver seguido, contra el agotamiento (12.5) |
| Al completarse | Sellado al 100% con el costo de sellar del rango y un pergamino en blanco. Entra con lealtad 5 (4.2) | — |

| Criatura | Confianza necesaria | Días con favorita | Días con aceptada | Nodo de avistamiento |
|---|---|---|---|---|
| Rodauva | 3 | 2 | 3 | Bajo el manzano (Huertos) |
| Ocarra | 4 | 2 | 4 | El corral caído (Huertos). Una Ocarra suelta lo bloquea ese día (Ocarra–Ocarra se llevan mal) |
| Surcón | 4 | 2 | 4 | El surco que ronca (orilla del Vado) |
| Zancajunco | 6 | 3 | 6 | Algo se movió en el juncal (Vado). Una Ocarra suelta lo espanta: no se puede usar ese día |

**Comparación con la balanza 2 (Ocarra):** por combate, 1 pelea, 3 de maná, cerca de 80% y lealtad 2 (leal en unos 5 días). Por confianza, 2 días, 2 nodos, 2 raciones de grano y 3 de maná, con lealtad 5 (leal en unos 4 días). La confianza gana en vínculo, pero obliga a quedarse en un destino y comerse el agotamiento.

---

## 5. Lealtad y obediencia

### 5.1 Escala y estados — `DECIDIDO`

Valor entero de **0 a 10**. Solo cambia mientras la criatura está **suelta**.

| Lealtad | Estado | Consecuencia |
|---|---|---|
| 0–1 | Desleal | Durante la recuperación del Maestro abandona seguro. Famélica, se expone al abandono nocturno (9.1) |
| 2–3 | Dudosa | Durante la recuperación tiene 50% de abandonar |
| 4 hasta umbral − 1 | Neutral | Se queda, pero no rescata |
| Umbral de rescate o más | Leal | Puede rescatar al Maestro |

### 5.2 Eventos de lealtad — `DECIDIDO`

**Lealtad diaria según la cobertura de comida** (criatura suelta):

| Resultado del día | Cambio | Decisión que genera |
|---|---|---|
| Comió lo suficiente (cubrió su apetito) | +1 (+1 cada 2 días con balanza 4–5) | — |
| Comió algo, pero no alcanzó | 0 | Repartir poco entre todas… |
| No comió nada | −2 | …o alimentar bien a algunas y castigar a otras |
| Comió algo rechazado (estando famélica) | −1 (reemplaza a las filas anteriores) | ¿Le doy algo que odia o la dejo pasar hambre? |

**Otros eventos:**

Todos los eventos de esta sección cambian la lealtad **solo de las sueltas**: las guardadas no ganan ni pierden lealtad (3.1). Esto incluye las muertes y las comidas de compañeras (responde `Mundo.md` 9.1).

| Evento | Cambio | Decisión que genera |
|---|---|---|
| Pelearon juntos y ganaron | +1 a las criaturas **sueltas al terminar** el combate: de pie, caídas que se levantan e invocadas durante el combate. **Las guardadas al terminar no lo reciben**, aunque hayan peleado. Cuenta como victoria que la última enemiga huya o sea sellada, y también ganar un combate nocturno. **De noche, solo lo reciben las que pelearon**: las que miraron no (9.2) | El Maestro se gana a su tribu peleando a su lado; guardar a una caída le salva la vida a cambio de ese punto |
| Muere o es comida otra criatura del grupo | −2 a todas las sueltas (−4 si eran afines). Se aplica **una vez por cada muerte** | Toda pérdida tiene costo social |
| El Maestro se come a una criatura | −3 adicional a todas las sueltas | La decisión más dura del juego tiene que doler |
| El Maestro se come a una criatura que lo atacó | **−2 en total** a todas las sueltas, **incluidas sus afines**: reemplaza a la fila de "muere o es comida" y no suma el −3 extra | El grupo vio la traición |
| El Maestro perdona a una criatura que lo atacó | +1 a las leales | La clemencia fortalece a la tribu |
| Rescató al Maestro | +2 | Refuerza la regla de oro |

**Precisiones** — `DECIDIDO` (03/10/2026, responde P-001 y P-002 de `Arquitectura.md`):
- **"Afines" en la muerte es la relación de especie** (10.8), mirada suelta por suelta: −4 a cada suelta cuya especie se lleve **bien** con la de la muerta; −2 al resto. No es la afinidad de combate: la muerte se resuelve con el combate terminado y la posición no cuenta. Ejemplo: muere una Rodauva → la otra Rodauva y el Surcón pierden 4; la Ocarra pierde 2.
- **Suma y recorte únicos:** todos los cambios de lealtad de un mismo combate (o de una misma noche) se **suman** y el resultado se recorta a **0–10 una sola vez**. El orden de aplicación no cambia nada. Ejemplo: una rescatista con 9 que además pierde 2 por una caída que muere queda en 9 (9 + 2 − 2), no en 8.

**Decisión que genera:** perder a una criatura de una manada duele el doble; llevar dos Rodauvas es más fuerte en el tablero y más frágil socialmente.

### 5.3 Referencia: días hasta poder rescatar (sin combates, cobertura completa)

| | Capturada por combate | Domesticada |
|---|---|---|
| Balanza 2 | 5 días | 2 días |
| Balanza 5 | 16 días | 10 días |

### 5.4 Obediencia efectiva — `DECIDIDO`

**Obediencia = lealtad − penalización por hambre.** La lealtad es el vínculo de fondo; la obediencia es cuánto pesa en el momento.

| Estado de hambre | Penalización |
|---|---|
| Saciado / Normal | 0 |
| Hambriento | −2 |
| Famélico | −4 |

**En combate, todo se lee sobre la obediencia. El rescate usa la lealtad real.**

**Cortes** — `DECIDIDO` (03/10/2026, responde P-003): los tramos de obediencia usan **los mismos números** que los estados de lealtad de 5.1: el piso de Neutral (**4**) y el umbral de rescate de la balanza. "≤ 3" es lo que en lealtad son Desleal y Dudosa. Cada número vive en un solo dato.

| Obediencia | Con el Maestro | Encono | Cobardía | Incidente con rival aliada |
|---|---|---|---|---|
| ≥ umbral de rescate | Afín: +1 de daño mutuo y combo de afines | −10 puntos | −20 puntos | Se distrae |
| 4 hasta umbral − 1 | Sin relación | Normal | Normal | Se distrae |
| ≤ 3 | Sin relación | +10 puntos | +20 puntos | **Ataca a la rival** |

**Decisión que genera:** una criatura leal con hambre deja de ser tu mejor aliada en el tablero, aunque todavía pueda rescatarte.

---

## 6. Muerte y rescate — `DECIDIDO`

| Paso | Regla numérica |
|---|---|
| El Maestro cae | El combate termina en el acto (11.5). Se busca una criatura **suelta**, **de pie** (ni caída ni guardada) y con **lealtad real** ≥ umbral de rescate |
| Elección de rescatista | Si hay varias: la de **mayor lealtad real**; si empatan, la **más cercana** al Maestro; si siguen empatadas, el orden de la tribu |
| Rescate | Lo arrastra al campamento y gana +2 de lealtad |
| Recuperación | Por cada día: lealtad 0–1 abandona seguro, lealtad 2–3 tiene 50% de abandonar |
| Quebranto | Al terminar la recuperación (6.1) |
| Las caídas | **Mueren**: la rescatista solo puede cargar al Maestro. Sus pergaminos arden y se aplica "muerte en el grupo" (5.2). Las que el Maestro guardó antes de caer sobreviven en su pergamino (11.5) |
| Sin rescatista | Permadeath |

### 6.1 Quebranto: la secuela — `DECIDIDO` (Visión 6.6)

| Regla | Valor | Decisión que genera |
|---|---|---|
| Efecto | No regenera vida ni maná: no cura ni recupera maná al dormir, ni regenera maná por turno en combate | Cada combate en el camino se pelea con lo que queda |
| Secuela | **−1 de vida máxima real por día** (al cerrar el día, paso 7 de 7.9), mínimo 1 | ¿Voy directo a la Poza o junto comida antes? |
| Permanencia | Lo perdido **no vuelve**: la vida máxima real queda reducida. Todos los porcentajes de vida se calculan sobre el nuevo valor (7.8) | La tardanza se paga para siempre |
| Cura | Bañarse en la **Poza Tibia** (Vado) devuelve la regeneración | — |
| Si nunca va | Termina con 1 de vida máxima | — |

**El quebranto no es un estado negativo**: es una marca en la barra de vida con su contador, como "lo que diste".

**Distancia:** Molino → Huertos → Vado son 2 días. Con la balanza en 2, en el mejor caso pierde **1 punto** (cierra un día en los Huertos y se baña al llegar al Vado, antes del cierre): queda con 19 de vida máxima real.

### 6.2 Recuperación y Poza Tibia — `DECIDIDO` (Visión v0.8)

| Regla | Valor propuesto | Decisión que genera |
|---|---|---|
| Días de recuperación | **2**, en el Molino. Cada día se cierra como un día en el Molino sin exploración: se reparte comida del inventario y se chequea el abandono | La tribu tiene que haber guardado comida para sostenerlo |
| Vida al terminar | 25% de la vida máxima real (redondeado hacia abajo, mínimo 1) | Sale débil y sin regenerar |
| Poza Tibia | Mientras el Maestro tiene quebranto, el mapa del Vado reemplaza **La crecida** por **La Poza Tibia**. Bañarse ocupa ese nodo; no tiene encuentro. Mientras dure, no se puede leer el río: el Maestro con quebranto cruza a ciegas (12.11) | Un nodo de comida menos el día que se cura |
| Noche en el Vado | La emboscada sigue normal (9.4) | Llegar a la Poza exige cubrir la noche con la tribu |

---

## 7. Hambre y vida

### 7.1 Escala — `DECIDIDO`

Cada ser (el Maestro y cada criatura suelta) tiene un valor de **Hambre de 0 a 10**. 0 es lleno; 10 es el tope.

| Hambre | Estado | Efectos |
|---|---|---|
| 0–2 | Saciado | +25% al daño y a la recolección · Cura al dormir (7.8) |
| 3–5 | Normal | Cura al dormir (7.8) |
| 6–8 | Hambriento | Maná reducido (2.2) · Obediencia −2 · No cura al dormir |
| 9–10 | Famélico | Sin maná (2.2) · Obediencia −4 · Puede comer comida rechazada · Abandono nocturno (9.1) · Pierde vida al dormir (7.6) · No puede hacer el ritual (3.3) |

**Saciado no es un valor aparte:** se deriva del hambre (0–2). En la Prueba 0a, el escenario fija el hambre de cada unidad y el estado sale de esta tabla (responde S-6).

### 7.2 Cuánto sube — `DECIDIDO`

| Fuente | Cantidad | Decisión que genera |
|---|---|---|
| Fin del día (al dormir) | Según el apetito (7.3) | ¿Cuántas bocas puedo sostener afuera? |
| Combate | +1 al cerrar las rondas 5, 10, 15…, al Maestro y a **toda criatura de la tribu en el tablero, de pie o caída**. No alcanza a las guardadas (tampoco a la caída que se guardó), a las salvajes ni a la atacante nocturna. La obediencia, la regeneración y el estado de hambre se recalculan en el acto | Cerrar rápido o arriesgarse: una leal puede pasar a Hambrienta en pleno combate. Guardar a una caída también la saca del reloj |
| Descanso para curarse | El hambre sigue subiendo normalmente (solo se toma agua) | Ver 8.3 |

### 7.3 Apetito — `DECIDIDO`

| Ser | Apetito | Hambre por día | Raciones normales para cubrir el día |
|---|---|---|---|
| Maestro | Medio | +3 | 1,5 |
| Rodauva | Poco | +2 | 1 |
| Ocarra | Poco | +2 | 1 |
| Zancajunco | Medio | +3 | 1,5 |
| Surcón | Mucho | +4 | 2 |
| Tasajero | Mucho | +4 | — (no reclutable) |

**Referencia de balance:** el grupo completo del MVP (Maestro + 4) consume unas **7 raciones por día**.

### 7.4 Raciones — `DECIDIDO`

| Ración | Efecto | Decisión que genera |
|---|---|---|
| Aceptada | −2 de hambre | — |
| Favorita | −3 de hambre | Buscar la favorita rinde un 50% más |
| Rechazada | Solo famélica: −2 de hambre, −1 de lealtad y 50% de Empacho | ¿Le doy algo que odia o la dejo con hambre? |
| Podrida (12.3 y 12.5) | Como aceptada, con **50% de Tripa negra** al comerla | ¿A quién le doy la ración riesgosa? |
| Dudosa (hongos, 12.3) | Como aceptada, con **25% de Fiebre del hongo** al comerla | Ídem |
| Carne o pescado sin fuego (9.4) | Las criaturas, sin riesgo. El Maestro, **25% de Tripa negra** | ¿Enciendo el fuego aunque me vean? |

> **Carne:** entre las reclutables, **solo el Zancajunco** la acepta. Comerse una criatura alimenta al Maestro y al Zancajunco; las demás pueden comer esa carne únicamente famélicas, como comida rechazada. Que el Zancajunco comparta la carne de una compañera es texto, no regla: no tiene costo extra de lealtad.
>
> ⚠️ **A vigilar:** una criatura de rango 2 da 4 raciones, que cubren el día del Maestro y del Zancajunco. El Zancajunco es el único que se beneficia de la decisión más dura del juego.

### 7.5 Bichos — `DECIDIDO`

**5 bichos = 1 ración** (de tipo bichos). Se juntan **rebuscando** (12.4): 1 por nodo, 2 con un Surcón suelto. No es crafteo: es una conversión directa.

**Decisión que genera:** comida de emergencia que siempre está, pero cuesta 3 o 4 nodos por ración. Es tiempo, no comida.

### 7.6 Morir de hambre — `DECIDIDO`

| Regla | Valor | Decisión que genera |
|---|---|---|
| Termina el día famélico | Pierde 25% de su **vida máxima real** (redondeado hacia abajo, mínimo 1) | El reloj se ve y se puede contar |
| Vida a 0 por hambre | Muere. Si es una criatura, se aplica "muerte en el grupo" | Al cuarto día famélico llega la muerte: es el momento en que comerse a una criatura deja de ser impensable |

### 7.7 Comerse una criatura — `DECIDIDO`

Da **rango × 2** raciones de carne: 2 / 4 / 6. Aplica los eventos de lealtad de 5.2.

**Decisión que genera:** nunca rinde como comida; solo como supervivencia.

### 7.8 Vida y curación — `DECIDIDO`

**Vida máxima real y vigente:**
- **Vida máxima real:** la del Maestro = 24 − 2 × posición de la balanza. La de las criaturas está en su ficha (11.2).
- **Vida máxima vigente:** la real menos las reducciones temporales activas (debilidad del ritual, 3.3).
- **Todos los porcentajes de vida** (daño del ritual, curación al dormir, muerte por hambre) se calculan sobre la **vida máxima real**. Las reducciones temporales solo **limitan** la vida actual.

**Curación al dormir** (según el hambre al acostarse):

| Hambre | Vida recuperada |
|---|---|
| Saciado / Normal | +25% de la vida máxima real (redondeado hacia abajo, mínimo 1) |
| Hambriento | 0 |
| Famélico | −25% (7.6) |

**Reglas:**
- El **descanso no cura vida extra**: solo cura enfermedades (8.3).
- Las criaturas **sueltas** se curan con la misma tabla. Las **guardadas no se curan**: duermen fuera del tiempo.
- Fuera del combate no se pueden usar hechizos de curación (2.5).

**Referencia con la balanza 2:** una noche bien comida cura 5 puntos; una herida de media vida tarda 2 noches.

**Decisión que genera:** las heridas se arrastran de un día a otro. ¿Encaro el próximo destino herido o espero una noche más, aunque cueste comida?

### 7.9 Orden del cierre del día — `DECIDIDO`

Todo se resuelve con el **estado de hambre al acostarse**, antes de sumar el hambre del día. Así, lo que la interfaz muestra antes de dormir es lo que pasa.

0. Subida de nivel, si alcanza la XP (1.4), con el aviso de rescatistas perdidos.
1. Lealtad diaria según la cobertura de comida (5.2).
2. Chequeo de abandono o ataque de una criatura propia (9.1). Si hay ataque, se resuelve el combate (9.2).
3. **Emboscada**: solo al raso y si no hubo ataque propio (9.4).
4. Recuperación de maná (2.2 y 2.4) y de vida (7.8): a la mitad si hubo combate nocturno; las guardianas no se curan y el Maestro guardián recupera 2 de maná menos (9.4).
5. Daño por terminar famélico (7.6).
6. Suma del hambre del día según el apetito (7.3).
7. Avance de contadores: enfermedades (8.3), debilidad del ritual (3.3), quebranto (6.1), dieta monótona (1.5), agotamiento y pudrición (12.5), confianza (4.5), plazo de la partida (13) y tirada del estado del río del día siguiente (12.11).

Al terminar el cierre del día 30, la partida termina y empieza el epílogo (13).

---

## 8. Estado Enfermo — `DECIDIDO`

Un solo efecto mecánico; la causa define la duración.

### 8.1 Causas

| Causa narrativa | Origen | Probabilidad | Duración |
|---|---|---|---|
| Empacho | Comer algo rechazado estando famélica · Dieta monótona del Maestro | 50% · 100% | 1 día |
| Tripa negra | Comer una ración podrida (12.3 y 12.5) · El Maestro come carne o pescado sin fuego (9.4) | 50% · 25% | 2 días |
| Fiebre del hongo | Comer una ración dudosa de hongos (12.3) | 25% | 3 días |

La probabilidad se tira **al comer** y se muestra antes de repartir.

### 8.2 Efecto y acumulación

- Cada enfermedad activa: **−25% al daño y a la recolección**.
- **Se acumulan:** 3 enfermedades juntas = −75%.
- Las enfermedades forman una **cola** que se cura de la más corta a la más larga. Total con las tres: 1 + 2 + 3 = **6 días**.
- Afectan igual al Maestro y a las criaturas **de la tribu**. Las enemigas (salvajes, Tasajero y atacante nocturna) no tienen enfermedades ni Saciado en el daño (11.4; `DECIDIDO` 04/10/2026, responde P-016).

**Decisión que genera:** cada mala decisión de comida suma, y la penalización a la recolección dificulta justamente conseguir comida.

### 8.3 Cura

| Forma | Ritmo | Decisión que genera |
|---|---|---|
| Descansar tomando solo agua (**solo en el Molino**, 9.4) | 1 día de la cola por día. Se puede cortar en cualquier momento; lo curado queda curado. El hambre sigue subiendo. No cura vida extra (7.8) | ¿Cuántos días de descanso aguanta mi estómago? |
| Seguir viajando | 1 día de la cola cada 2 días de viaje | Avanzar enfermo es posible, pero lento |

> Con 3 enfermedades, curarlas todas descansando es imposible sin salir a comer: el Maestro queda famélico al 3.er día y muere al 6.º. Es intencional: obliga a elegir qué curar.

### 8.4 Combinación de modificadores — `DECIDIDO`

- Los porcentajes (Saciado, enfermedades, cobardía) **se suman**: Saciado con 1 enfermedad = 0%.
- En recolección se aplican al **total del nodo**, sumando todos los tipos, no ítem por ítem.
- Redondeo hacia abajo. El daño nunca baja de 1; la recolección **puede dar 0**.
- En combate, el orden completo del cálculo de daño (porcentajes, luego bonos planos) está en 11.4.

---

## 9. Noche: abandono, ataque y campamento

### 9.1 Abandono nocturno — `DECIDIDO`

Condición: criatura **suelta + famélica + desleal** (lealtad 0–1). Se chequea al dormir (7.9, paso 2).

| Lealtad | Se va | Ataca | Se queda |
|---|---|---|---|
| 1 | 50% | 0% | 50% |
| 0 | 70% | 10% | 20% |

Si se va, su pergamino arde (3.2). La interfaz muestra un **ícono de riesgo** sobre la criatura antes de dormir. Guardarla en su pergamino evita el chequeo.

**Decisión que genera:** ¿la guardo (congelo el problema y pierdo el vínculo) o la dejo afuera esperando conseguir comida mañana?

### 9.2 Ataque nocturno — `DECIDIDO`

1. La criatura golpea primero: **un ataque normal** contra el Maestro, con la fórmula de 11.4 (aplican sus rasgos, como Hacerse junco; como toda enemiga, no recibe Saciado ni enfermedades; no hay combo y no suma Encono). Con una Ocarra atacante son 4 de daño. No ocurre si hay una Ocarra suelta que no sea la atacante (Centinela, 12.6), **tenga la lealtad que tenga**. **Si el golpe deja al Maestro en 0**, el combate termina por caída antes de la ronda 1 y rige el paso 6 (responde S-10).
2. Empieza un **combate donde se duerme**: el Molino o el campamento al raso (9.4). **Solo las leales defienden al Maestro** (ver "Quién defiende", abajo); las demás sueltas miran.
3. Durante el combate, la atacante se trata como **salvaje**: obediencia ≤ 3 y sin Arrimo (10.7).
4. El Maestro pelea con el maná del sueño interrumpido (2.4).
5. A diferencia de una salvaje, la atacante **no huye** al llegar a 0 de vida: queda **caída** y el Maestro decide su destino (9.3).
6. Si el Maestro cae en este combate, rige 11.5: si hay rescatista, el Maestro queda en recuperación (ya está en el Molino); las caídas de la tribu mueren y **la atacante se va** (su pergamino arde, como en un abandono). Sin rescatista, permadeath.

**Quién defiende al Maestro** — `DECIDIDO` (03/10/2026, responde S-12; Visión 6.4: "las sueltas leales defienden al Maestro"):

| Regla | Valor | Decisión que genera |
|---|---|---|
| Quién entra al tablero | Las sueltas con **lealtad real ≥ umbral de rescate**, sin contar a la atacante. Se mide **una vez**, al empezar el combate, después del golpe inicial | ¿A quién cuidé lo suficiente para que me defienda? |
| Comportamiento | Se rige por la **obediencia**, como en cualquier combate: una leal hambrienta entra, pero puede pelear mal | Leal y bien alimentada no es lo mismo |
| Las que miran | No están en el tablero: no actúan, no son objetivo, no participan de relaciones y no suman hambre de combate (7.2) | — |
| Victoria | El +1 de 5.2 es **solo para las que pelearon** | Defender al Maestro es la forma de ganárselo |
| Eventos que siguen valiendo | Las que miran **son sueltas**: las alcanzan la muerte de una caída (−2 / −4) y comer a la atacante (−2) (5.2) | El grupo entero vio lo que pasó |
| Si el Maestro cae | La rescatista sale de las que pelearon (11.5). Las que miran no pueden rescatar | — |
| Centinela (12.6) | Anula el golpe inicial **con cualquier lealtad**: es una pasiva de suelta. Da la alarma, pero no pelea si no es leal | Una Ocarra Neutral avisa, pero deja solo al Maestro |
| Sin leales | El Maestro pelea solo contra la atacante, con medio maná | La regla de oro en su forma más pura |

**Peor caso (balanza 2):** el Maestro solo, con 16 de vida tras el golpe inicial, contra una Ocarra atacante (12 de vida, 4 de daño). Necesita 3 golpes; ella le saca unos 12 en ese tiempo. Sobrevive con poco margen y casi sin maná para sellarla. Duro, pero no es una muerte automática (riesgo en 14).

### 9.3 Destino de la atacante derrotada — `DECIDIDO`

Queda **caída** y el Maestro elige. En las tres salidas, **su pergamino arde**.

| Opción | Efecto |
|---|---|
| Perdonar | Se va libre y vuelve a ser salvaje. Las leales ganan +1 |
| Sellar | Resellado (4.4): costo de invocar y un pergamino en blanco. Vuelve guardada con lealtad 1 |
| Comer | Rango × 2 raciones de carne. −2 a todas las sueltas, sin el −3 extra |

### 9.4 Campamento al raso — `DECIDIDO`

Fuera del Molino, cada noche el Maestro arma un campamento: reparte la comida, asigna las guardias, decide si enciende el fuego y **despierta habilidades** según las criaturas sueltas que tiene alrededor. Hay riesgo de emboscada, y una emboscada **reduce el descanso a la mitad**. Entra completo en el MVP.

**El Molino frente al raso:**

| | Molino Callado | Campamento al raso |
|---|---|---|
| Emboscadas | No: es refugio | Sí |
| Guardias | No hacen falta | Sí |
| Fuego | Siempre encendido | Hay que encenderlo |
| Ritual de sangre | Sí | No |
| Descanso para curar enfermedades (8.3) | Sí | No: el ritmo es el de viaje |

**Decisión que genera:** volver al Molino cuesta un día sin explorar (12.2), pero es la única noche segura.

**Guardias:**

| Regla | Valor | Decisión que genera |
|---|---|---|
| Guardias | **3** por noche (primera, media y alba). Cada una la cubre un ser: el Maestro o una criatura suelta y de pie | ¿Cuántas bocas llevo para cubrir la noche? |
| Límite | 1 guardia por ser | Cubrir la noche entera exige al Maestro y 2 sueltas |
| Costo para una criatura | Esa noche **no se cura** | ¿Vigila la herida o la sana? |
| Costo para el Maestro | Recupera **2 de maná menos** (mínimo 0) | Vigilar uno mismo cuesta la pelea de mañana |
| Guardiana con obediencia ≤ 3 | **50% de dormirse**: si la emboscada cae en su guardia, cuenta como descubierta. Se muestra antes | La regla de oro decide a quién le confiás la noche |

La interfaz repite por defecto la asignación de la noche anterior.

**Fuego.** No es un recurso: se enciende con tiempo, no con un objeto.

| Regla | Valor | Decisión que genera |
|---|---|---|
| Encender | Cuesta **1 nodo del día** (juntar leña caída: nada se arranca) | Un nodo menos de comida |
| Emboscada | −10 puntos en los Huertos y el Vado · **+10 en el Robledal** (el Tasajero lo ve) | En el Robledal, el fuego protege y delata |
| Cocinar | Sin fuego, el Maestro que come carne o pescado tiene **25% de Tripa negra**. Las criaturas comen crudo sin riesgo | ¿Carne cocida y te ven, o cruda y te arriesgás? |

**Emboscada nocturna:**

| Factor | Puntos |
|---|---|
| Base: Huertos / Vado | 10 / 20 |
| Base: Robledal, según el Tasajero (12.10) | Apaciguado: **sin emboscada** · Atento: 30 · Cazando: 50 |
| Cada guardia sin cubrir | +10 |
| Fuego | −10 (Robledal: +10) |
| Madriguera (habilidad) | −10 |
| Mínimo fuera del Molino | 5% (salvo el Robledal con el Tasajero apaciguado o derrotado en esta visita: 0%) |

| Si ocurre | Efecto |
|---|---|
| Cuándo | Cae en una de las 3 guardias, al azar |
| Guardia cubierta | Alarma: el combate empieza normal |
| Guardia sin cubrir | **Ronda de sorpresa**: en la primera ronda solo actúan las salvajes |
| Quiénes atacan | La tabla de encuentros del destino (11.6) **sin las salvajes de trabajo**, que no emboscan. Huertos: 1 Ocarra · Vado: Zancajunco (55%) o Zancajunco + Ocarra (45%) · Robledal: el Tasajero (12.10) |
| El descanso | Maná y vida recuperan **la mitad**; ese maná es el tope del combate (misma regla que 2.4) |
| Prioridad | Si esa noche hay ataque de una criatura propia, no se tira emboscada |

La probabilidad total y la de sorpresa se muestran antes de dormir.

**Habilidades de campamento del Maestro:**
- Son **del Maestro**: se despiertan por la convivencia con sus criaturas sueltas.
- Cada **especie distinta** suelta, de pie y con obediencia ≥ 4 despierta **1 habilidad**. Dos Rodauvas despiertan una sola: **cuantas más especies distintas, más habilidades**.
- Solo duran mientras esa especie está suelta alrededor: guardarla las apaga.
- Solo se usan al raso.

| Especie suelta | Habilidad del Maestro | Efecto |
|---|---|---|
| Rodauva | **Leña en las púas** | Encender el fuego no cuesta nodo |
| Ocarra | **Sueño liviano** | Ninguna emboscada tiene ronda de sorpresa |
| Surcón | **Madriguera** | −10 puntos de emboscada |
| Zancajunco | **Acecho** | Si la emboscada cae en una guardia cubierta, el bando del jugador actúa primero en la primera ronda |

**Decisión que genera:** una tribu variada duerme mejor que una de una sola especie (Pilar 3). Es también un freno a las tribus de Rodauvas o de Ocarras.

**Verificación (viaje largo):** la vuelta del primer ritual son 5 noches al raso. Con el Maestro y la Rodauva se come poco (2,5 por día), pero queda 1 guardia sin cubrir: en el Vado, sin fuego, la emboscada es del 30% (con Leña en las púas, el fuego sale gratis y baja a 20%). Sumar a la Ocarra cubre la noche y anula la sorpresa, por 1 ración más por día.

---

## 10. Combate: iniciativa, combos y relaciones

### 10.1 Iniciativa y Secundar — `DECIDIDO`

| Regla | Valor | Decisión que genera |
|---|---|---|
| Orden | Cada unidad actúa según su **Velocidad**, sin azar (reglas completas en 11.3) | — |
| Secundar | La unidad actúa justo después de un aliado elegido que todavía no actuó en la ronda | Armar la cadena a mano |
| Costo de Secundar | Ninguno explícito: los enemigos que estaban en el medio actúan antes | ¿Combo seguro más tarde o golpe inmediato? |
| Restricciones | No puede Secundar una unidad enconada ni una acobardada. No se puede Secundar más allá del final de la ronda. **Las salvajes no Secundan** | La furia y el miedo rompen la coordinación; la coordinación es ventaja de la tribu |

### 10.2 Combos: ataque en cadena — `DECIDIDO`

Cuando aliados atacan **de forma consecutiva** al **mismo objetivo**, cada golpe desde el segundo suma un bono.

| La cadena se corta si… | No la corta… |
|---|---|
| Actúa una enemiga (cada turno del Tasajero cuenta) | Una acción aliada que no es ataque: moverse, Lanzadera, Remiendo, Erizarse, guardar, esperar (terminar el turno sin usar la acción **es** esperar, 11.3) |
| Un aliado ataca a otro objetivo (incluido el golpe de un incidente) | — |
| **Se cierra la ronda** (03/10/2026): la cadena nunca pasa a la ronda siguiente, aunque no quede ninguna enemiga por actuar | — |
| El objetivo sale del tablero (huye, es sellado) | — |

| Par que encadena | Bono base | + Arrimo |
|---|---|---|
| Sin relación | +20% | +10 por paso |
| Afines (incluye Maestro + criatura con obediencia leal) | +40% | +10 por paso |

**Cada eslabón vale la mitad que el anterior**, sin tope. Ejemplo entre afines con balanza 2 (+70%):

| Eslabón | 2 | 3 | 4 | 5 |
|---|---|---|---|---|
| Bono | +70% | +35% | +17% | +8% |

Con daños de 3 a 5 y redondeo hacia abajo, el tope real queda en 3 o 4 eslabones.

**Decisión que genera:** el orden en que actúan tus unidades importa tanto como dónde están.

### 10.3 Afinidad por adyacencia — `DECIDIDO`

Una unidad adyacente a una afín suma **+1 de daño plano**, como máximo +1 por ataque aunque tenga varias afines al lado. Se mira la posición del atacante al golpear. El Maestro es afín de toda criatura con obediencia ≥ umbral de rescate (y viceversa).

**Decisión que genera:** formar en bloque o dispersarse para cubrir el tablero; el Maestro en el frente potencia a la tribu, pero se expone.

### 10.4 Rivalidad entre aliadas: incidente — `DECIDIDO`

Una criatura adyacente a una rival aliada tiene **20% de incidente** al **inicio de su turno** (−5 puntos por paso de Arrimo). El resultado depende de su obediencia (5.4): **≥ 4 se distrae y pierde la acción; ≤ 3 usa la acción para golpear a la rival**. En ambos casos **conserva el movimiento**: la distraída todavía se puede alejar. La probabilidad se muestra en la casilla antes de mover, el turno anterior.

**Precisiones** — `DECIDIDO` (03/10/2026):
- **Una sola tirada por turno**, aunque tenga varias rivales aliadas adyacentes: amontonarlas no multiplica el riesgo. Con obediencia ≤ 3 golpea a la rival de **menos vida actual**; si empatan, a la primera en el orden de la tribu.
- **Una criatura enconada no tira incidente** ese turno: la furia la enfoca en la rival enemiga (orden del inicio del turno en 11.3). Motivo: la enconada ya perdió el control; cobrarle dos veces la misma pérdida no genera una decisión nueva.
- *Palanca en reserva:* una tirada por rival adyacente castigaría más a una tribu de Ocarras (14). Solo si esa tribu domina en los tests.

**Decisión que genera:** juntar rivales es un riesgo chico con una tribu leal y bien alimentada, y un peligro con una hambrienta.

### 10.5 Rival enemiga: Encono — `DECIDIDO`

Aplica a las criaturas **de combate y mixtas**. Las de trabajo usan la cobardía (10.6).

| Regla | Valor | Decisión que genera |
|---|---|---|
| Contador | Encono de 0 a 3 por criatura. El Tasajero tiene **un solo contador** para sus dos turnos | — |
| Enconarse | Al inicio de su turno, con una rival enemiga **a su alcance** (distancia Manhattan ≤ Movimiento + Alcance; misma definición para la cobardía): 25% + 25% por punto · −5 por paso de Arrimo · ±10 según obediencia (5.4) | El jugador ve la probabilidad antes de acercarla |
| Enconada | Su acción queda fijada en atacar a esa rival, con **+1 de daño por punto, contando el punto que suma ese golpe** (máximo +3). **El jugador elige la casilla** (y la rival, si hay varias). Si no llega, se acerca lo más posible y pierde la acción | Usarla como cazadora de su rival a cambio de perder el control del objetivo, no de la posición |
| Cada golpe a la rival | +1 de Encono (máx. 3), **esté enconada o no**: también suman los golpes voluntarios. Con 3, queda enconada seguro | Pegarle a la rival a propósito acerca el Encono: cuanto más pega, más se ensaña |
| Orden del golpe enconado | Primero sube el contador; después se calcula el daño con el valor nuevo. Los golpes voluntarios (sin estar enconada) suben el contador, pero **no tienen bono** | — |
| Remate | La enconada puede dejar a su rival en 0. Si es una salvaje, huye y se pierde la captura | ¿Llevo a la Ocarra contra un Zancajunco que quiero sellar? ¿La alejo con la Lanzadera antes de que actúe? |
| Fin del combate | El Encono vuelve a 0 | — |

**Salvaje enconada con varias rivales a su alcance** — `DECIDIDO` (03/10/2026): elige con la lista de la IA (11.8): la que **puede tumbar**; si no, la de **menos vida actual**; si empatan, la **más cercana**; después, la que actúa antes en la cola. Así el Tasajero va por la Rodauva (8 de vida) antes que por la Ocarra (12).

**Ejemplo:** la Ocarra (daño 4) enconada contra su rival, golpes seguidos: **5 / 6 / 7 / 7**. Cada Encono da fuerza desde el primero (Visión 6.4: "ganando fuerza y perdiendo control").

**Alternativas descartadas:** el valor del contador antes del golpe (el primer Encono sería pura pérdida de control), el bono en cualquier golpe a la rival (estrategia dominante: cargar el contador a propósito y cobrar la fuerza sin pagar con el control) y +2 plano (pierde el ensañamiento creciente).


### 10.6 Rival enemiga: cobardía — `DECIDIDO`

Aplica a las criaturas **de trabajo**. Se chequea con el mismo disparador que el Encono: al inicio de su turno, con una rival enemiga a su alcance.

**Probabilidad de acobardarse:**

| Factor | Modificador |
|---|---|
| Base | 60% |
| Arrimo | −5 puntos por paso |
| Obediencia leal (≥ umbral) | −20 puntos |
| Obediencia ≤ 3 | +20 puntos |
| El Maestro está adyacente | −10 puntos |

| Balanza | Leal + Maestro al lado | Leal | Neutral | Obediencia ≤ 3 |
|---|---|---|---|---|
| 1 (Barro) | 10% | 20% | 40% | 60% |
| 2 (inicial) | 15% | 25% | 45% | 65% |
| 5 (Soplo) | 30% | 40% | 60% | 80% |

**Acobardada** (dura ese turno; no tiene contador):
- −50% de daño (se suma con los otros porcentajes, 8.4; daño mínimo 1).
- No puede terminar su movimiento más cerca de la rival que donde empezó.
- No puede Secundar.
- Conserva el turno: puede moverse, atacar a otro objetivo, encadenar combos o ser guardada.

**Decisión que genera:** ¿pongo al Maestro junto a la criatura asustada para sostenerla, sabiendo que eso lo expone?

> `PROPUESTA` a testear (toggle en el escenario E de la Prueba 0a, 11.9): cada afín adyacente resta **−10 puntos** a la cobardía (máximo −20), con un **mínimo de 5%**. Ejemplo: Rodauva leal con la balanza en 2, junto a dos Rodauvas: 25% → 5%. Anticipa la barra de zozobra. Si se aprueba, también alcanza a las salvajes (10.7). **El Maestro no cuenta como afín adyacente** para este toggle: ya tiene su −10 propio (`DECIDIDO` 03/10/2026, responde P-008). Así quedan dos herramientas separadas: sostener con el Maestro o sostener con la manada.

### 10.7 Criaturas salvajes — `DECIDIDO`

Siguen las mismas reglas de relación: afinidad, rivalidad, Encono y cobardía. No tienen lealtad: se tratan como **obediencia ≤ 3** y sin Arrimo. Si ocurre un incidente, siempre se atacan entre ellas.

| Regla | Valor |
|---|---|
| Afinidad | +1 plano entre salvajes afines adyacentes (10.3). **La afinidad solo existe dentro del mismo bando**: una Rodauva de la tribu junto a una Rodauva salvaje no suma nada |
| Combos | **No encadenan**: sus ataques consecutivos no suman bono. La cadena es algo que solo da el vínculo con el Maestro (Visión 6.4). Sus turnos sí cortan las cadenas de la tribu (10.2) |
| Impacto en el MVP | El único par afín salvaje posible es Rodauva–Rodauva (Huertos, 15%): pasan de 2 a 3 de daño |

**Decisión que genera:** atraer a una Ocarra salvaje hacia un Zancajunco salvaje es una táctica legítima; separar a dos Rodauvas salvajes con la Lanzadera les quita la afinidad.

### 10.8 Relaciones entre las reclutables (referencia, de `Mundo.md`)

| Par | Relación |
|---|---|
| Rodauva – Surcón | Bien |
| Surcón – Ocarra | Bien |
| Ocarra – Zancajunco | Mal |
| Rodauva – Rodauva | Bien (manada) |
| Ocarra – Ocarra | Mal (territoriales) |
| Resto de los pares (incluidos Surcón–Surcón y Zancajunco–Zancajunco) | Sin relación |

Con el Tasajero (enemigo): Rodauva y Ocarra se llevan mal; el Zancajunco se lleva bien. El Surcón es el pegamento del bando "granja"; el Zancajunco queda aislado en el MVP.

---

## 11. Unidades y resolución del combate

Valores iniciales de test (sesión del 01/10/2026). Los rasgos de combate están aprobados (Visión v0.7).

### 11.1 Estadísticas — `DECIDIDO`

| Estadística | Qué controla | Decisión que genera |
|---|---|---|
| **Vida** | Golpes que aguanta | ¿A quién expongo en el frente? |
| **Daño** | Daño base por ataque | ¿Quién remata y quién debilita para sellar? |
| **Movimiento** | Casillas por turno, solo ortogonales | ¿Llego a la afín o me quedo cubriendo? |
| **Alcance** | 1 = adyacente · 2 = en línea recta | Formar en dos filas |
| **Velocidad** | Orden en la ronda | Armar cadenas sin necesidad de Secundar |

**No hay Defensa en el MVP.** Con daños de 2 a 6, una defensa plana de 1 cambia el resultado entre un 15% y un 50%: es demasiado sensible para tenerla en todas las unidades. La dureza se expresa con la vida y con rasgos puntuales (Lomo de tierra).

### 11.2 Fichas — `DECIDIDO`

| Unidad | Rol | Rango | Vida | Daño | Mov | Alc | Vel | Rasgo |
|---|---|---|---|---|---|---|---|---|
| **Maestro** (balanza 2) | — | — | 20 | 4 | 3 | 1 | 5 | Magia: Martillazo, Lanzadera, Remiendo (1.6) |
| **Rodauva** | Trabajo | 1 | 8 | 2 | 4 | 1 | 6 | **Erizarse** (acción): hasta su próximo turno recibe −50% de daño y no se mueve. Cierra el movimiento que le quede: puede moverse y después erizarse, no al revés |
| **Surcón** | Trabajo | 2 | 18 | 3 | 2 | 1 | 2 | **Lomo de tierra** (pasiva): −1 a cada golpe recibido, mínimo 1 |
| **Ocarra** | Combate | 1 | 12 | 4 | 3 | **2** | 7 | **Alabarda**: su alcance 2 es el rasgo |
| **Zancajunco** | Mixto | 2 | 12 | 4 | 4 | 1 | 8 | **Hacerse junco** (pasiva): +2 de daño en su primer ataque del combate |
| **Tasajero** | Combate | 3 | 30 | 6 | 4 | 1 | 8 y 3 | **Caza y cuenta**: dos turnos **completos** por ronda (movimiento y acción en cada uno); aparece dos veces en la cola, con las marcas Caza y Cuenta |

La vida y el daño del Maestro siguen la balanza (tabla 1.2). Su Movimiento, Alcance y Velocidad no dependen de ella. **En la 0a ningún estado los modifica** (hambre, enfermedad, quebranto): la Velocidad del Maestro es siempre la de su ficha y entra en la cola en todas las rondas (`DECIDIDO` 04/10/2026, responde P-013).

**Motivo de cada valor:**

| Unidad | Por qué |
|---|---|
| Maestro | Pega lo mismo que la Ocarra: el Maestro también pelea (Pilar 1) |
| Rodauva | Frágil. Su daño de 2 la vuelve la **mano fina para sellar**: baja a una salvaje al tramo ≤ 25% sin hacerla huir. Salvaje y erizada, debilitarla cuesta mucho: conviene domesticarla |
| Surcón | El Maestro necesita 6 golpes para debilitarlo. Es un muro lento, y debilitarlo es un desgaste |
| Ocarra | Ataca primero (temperamento). Desde atrás del Maestro queda adyacente a él: la formación natural refuerza la regla de oro |
| Zancajunco | "Si ataca, lo hace primero y rápido" |
| Tasajero | Con un solo turno, un jefe contra 3 a 5 unidades pierde por número de acciones. Con dos turnos separados (Vel 8 y 3), además **corta cadenas a mitad de ronda** |

**Pilar 2:** las fuertes en combate (Ocarra, Zancajunco) trabajan peor; las que trabajan (Rodauva, Surcón) pelean peor.

### 11.3 Tablero e iniciativa — `DECIDIDO`

| Regla | Valor | Decisión que genera |
|---|---|---|
| Tablero de referencia | 8 × 8, sin terreno en el MVP | — |
| Turno de una unidad | **1 movimiento y 1 acción**, en cualquier orden, sin partir el movimiento. Acciones: atacar, hechizo, sellar, guardar, Erizarse, esperar. Invocar y huir gastan el turno completo. **Terminar el turno sin usar la acción es esperar** (con o sin movimiento; P-015). **Erizarse cierra el movimiento que quede** (P-014) | ¿Pego y me retiro, o me acomodo y pego? Con la Rodauva: ¿me ubico primero y después me erizo? |
| Movimiento | Solo ortogonal. Se atraviesan aliadas y caídas propias, nunca enemigas, **tampoco caídas** (P-018). No se termina en una casilla ocupada | Las enemigas funcionan como muro; un pasillo protege. La caída propia sigue cubriendo: guardarla libera la casilla y abre el paso |
| Distancias | Todas **Manhattan** | — |
| Despliegue | El jugador ubica a sus sueltas en las **2 filas de su borde**; las salvajes ocupan las 2 filas opuestas | La formación inicial ya es una decisión |
| Adyacencia | 4 casillas ortogonales (coherente con los sprites en 4 direcciones). Rige afinidad, incidentes, Arrimo del Maestro adyacente y guardar en combate | Las diagonales no dan afinidad: formar en cruz, no en bloque |
| Orden | Mayor Velocidad primero, **sin azar** | El jugador planifica la ronda entera |
| Empates | Bando del jugador antes que el enemigo · El Maestro antes que sus criaturas · Entre criaturas, el orden de la tribu (lo define el jugador fuera del combate) · **Entre enemigas, el orden de la lista de enemigas del encuentro** (P-011) | Predecible |
| Criatura invocada | Entra en la cola **a partir de la ronda siguiente** | Invocar en combate cuesta el turno del Maestro y una ronda de la criatura: conviene sacarla antes, y eso cuesta comida |
| Unidad que deja de actuar a mitad de ronda | Si cae, es guardada, huye o sale del tablero, **pierde todas sus entradas restantes de la ronda**: el Tasajero que huye en Caza no juega la Cuenta (P-012). La cola no se rearma | Tumbar o hacer huir al Tasajero antes de su Cuenta le quita el segundo golpe |
| Alcance 2 | En línea recta; puede golpear **por encima de una aliada**, nunca por encima de una enemiga, **tampoco de una caída** (P-018) | Segunda fila detrás del Maestro |

**Inicio del turno: orden de los chequeos** — `DECIDIDO` (03/10/2026):

| Paso | Chequeo | Quién |
|---|---|---|
| 1 | Regeneración de maná (2.1) | Maestro |
| 2 | Huida con vida ≤ 25% (11.7) | Salvajes |
| 3 | Rival enemiga a su alcance → Encono (10.5) o cobardía (10.6) | Criaturas |
| 4 | Incidente con rival aliada (10.4), **solo si no quedó enconada** | Criaturas |

Si la huida del paso 2 sale, el turno termina ahí.

### 11.4 Fórmula de daño — `DECIDIDO`

1. Se **suman todos los porcentajes**: bono de combo, Saciado, enfermedades, cobardía, Erizarse.
2. Se aplican al Daño base y se redondea hacia abajo.
3. Se suman los **bonos planos**: afinidad (+1), Encono (+1 por punto), Hacerse junco (+2), Lomo de tierra (−1).
4. **Mínimo 1.**

**Precisiones** — `DECIDIDO` (04/10/2026):
- **Sin recorte intermedio** (responde P-017): si los porcentajes dejan el daño por debajo de 0, los planos se suman sobre ese valor negativo y el único recorte es el mínimo del paso 4. Ejemplo: Zancajunco (4) con 3 enfermedades contra una Rodauva erizada, en su primer ataque: −125% → 4 × (−0,25) = −1; +2 = **1**. Motivo: un solo recorte, desglose legible; el caso es extremo y el mínimo 1 lo cubre.
- **Saciado y enfermedades son del bando de la tribu** (Maestro y criaturas de la tribu; responde P-016). Las enemigas (salvajes, Tasajero, atacante nocturna) pegan con su Daño base, sus rasgos y los aportes de combate que les toquen (afinidad entre salvajes, Encono, cobardía). Motivo: las salvajes no tienen hambre en el modelo, y la atacante nocturna es famélica, así que Saciado nunca le aplicaría; sus enfermedades quedan fuera para no sumar un caso aparte en la 0a. Coincide con 11.6: dos golpes de la Ocarra salvaje tumban a la Rodauva.

**Ejemplo:** el Maestro (4), segundo eslabón de la cadena (+50%) y adyacente a una afín: 4 × 1,5 = 6, más 1 = **7**.

> ⚠️ **A vigilar:** con Saciado, la Rodauva hace 2 × 1,25 = 2,5 → **2**: el bono no le sirve. Se acepta; su aporte está en la recolección.

### 11.5 Vida en 0 y fin del combate — `DECIDIDO`

| Unidad que llega a 0 | Qué pasa | Decisión que genera |
|---|---|---|
| **Criatura de la tribu** | Queda **caída**. Si se gana el combate, se levanta con **1 de vida**. Si el combate se pierde (o se huye, 11.7), **muere**: su pergamino arde y se aplica "muerte en el grupo" | La muerte depende de cómo termina la pelea, no de un solo golpe |
| **Maestro** | El combate **termina en el acto**. La rescatista (suelta, de pie y leal) lo arrastra al Molino. **Las caídas quedan atrás y mueren** | No exponer al Maestro: si cae, arrastra a sus caídas con él |
| **Salvaje** | **Huye** del tablero. No da comida ni puede sellarse | Pegarle de más significa perder la captura |
| **Atacante nocturna** | Queda caída para que el Maestro decida su destino (9.3) | — |

**Reglas de la caída:**
- La caída queda en su casilla y la ocupa, pero **no puede ser objetivo**: nadie la remata.
- No actúa, no cuenta para combos ni Arrimo, y no puede rescatar.
- **No participa de ninguna relación:** no da ni recibe afinidad, no provoca ni sufre incidentes y no cuenta como rival a su alcance para el Encono ni para la cobardía.
- Sigue sumando hambre de combate (7.2).
- **El Maestro puede guardarla**: gasta su acción y el costo de invocar del rango (2 / 3 / 4, con descuento y mínimo 1), a distancia ≤ 2. Queda guardada con **1 de vida** y, como toda guardada, no se cura hasta salir. Si después el Maestro cae o huye, **sobrevive** en su pergamino.
- El Remiendo no afecta a las caídas (1.6).
- El combate se **gana** cuando no queda ningún enemigo en pie y se **pierde** cuando cae el Maestro.
- Una criatura que sube de caída a 1 de vida tiene la misma curación nocturna que las demás (7.8).

**Motivo:** con la Rodauva en 8 de vida, una Ocarra salvaje puede tumbarla en dos golpes el día 1. Con la caída, la compañera muere solo si el Maestro también cae.

**Decisión que genera:** guardar a una caída compite por el maná con el Martillazo, el Remiendo y sellar. Es la forma de no abandonarla si hay que huir.

### 11.6 Encuentros de referencia — `DECIDIDO`

**Prueba A — Día 1: Maestro + Rodauva (Neutral) contra 1 Ocarra salvaje.** Orden: Ocarra (7), Rodauva (6), Maestro (5). La cadena sale sola. Bono: "sin relación" + 3 pasos de Arrimo = **+50%**.

> Esta sección es **referencia de daño**. El objetivo de cada salvaje lo decide la IA de 11.8, que **manda** (03/10/2026, responde P-009): la Ocarra va por la Rodauva, que tiene menos vida, no por el Maestro.

Línea típica con las posiciones del escenario A (Maestro [3,7], Rodauva [4,7], Ocarra [4,0]):

| Ronda | Ocarra | Tribu | Vida de la Ocarra |
|---|---|---|---|
| 1 | No alcanza; se acerca a [4,3] | Rodauva pega 2 · Martillazo con +50% pega 4 | 12 → 6 (50%: sellado al 50%) |
| 2 | Rodauva 8 → 4 | Rodauva pega 2 → **decisión** | 6 → 4 (33%: sellado al 50%) |
| 3 | **Tumba a la Rodauva**, salvo que esté erizada o se la haya movido | Una ronda más para llegar al 80% | — |

**Decisión que aparece:** ¿sello al 50% o arriesgo a mi compañera una ronda más para ir al 80%? "Una ronda más" ya no cuesta vida del Maestro: cuesta que la Rodauva caiga. Es la regla de oro en el día 1.

**Prueba B — 2 Ocarras en los Huertos:** las dos van primero por la Rodauva y la tumban en la ronda 2 (11.8); después el Maestro recibe 8 por ronda, la pelea dura unas 4 rondas y cae sin rescatista. Es un muro. La pregunta "¿guardo a la caída antes de huir?" aparece temprano.

**Prueba C — Tasajero:** pega 12 por ronda; un Maestro solo dura 2 rondas. Con Ocarra (Encono) + Zancajunco + Maestro, la tribu le hace unos 15 por ronda: la pelea dura 2 o 3 rondas. Va directo por la Rodauva, así que **llevar a la compañera al Robledal es una apuesta real**.

**Tope de amenaza por destino:**

| Destino | Regla |
|---|---|
| Huertos de Almiar | Como máximo **1 salvaje de combate** por encuentro |
| Vado de los Juncos | Como máximo **2 salvajes**, y nunca dos de combate que no sean rivales entre sí |
| Robledal Hondo | El Tasajero, según su hostilidad (12.10) |

**Salvajes de trabajo** — `DECIDIDO`: no inician combate. Si el encuentro es solo de trabajo, el jugador elige entre **atacar** (para sellarlas por el camino de combate) o **seguir de largo**.

**Tablas de encuentros** — `DECIDIDO` (valores de test):

| Destino | Probabilidad | Composición | Qué enseña |
|---|---|---|---|
| Huertos | 60% | 1 Ocarra | Es la Prueba A: el primer sellado |
| Huertos | 25% | 1 Ocarra + 1 Rodauva | Elegir a quién debilitar primero |
| Huertos | 15% | 2 Rodauvas (no inician combate) | Atacar o seguir de largo; erizadas, cuesta debilitarlas |
| Vado | 40% | 1 Zancajunco | Golpe fuerte de entrada (Hacerse junco) |
| Vado | 30% | 1 Zancajunco + 1 Surcón | Un muro lento detrás de un atacante rápido |
| Vado | 30% | 1 Zancajunco + 1 Ocarra | Son rivales: con la Lanzadera, el jugador las junta y se pelean entre ellas (10.7) |

Las emboscadas usan estas mismas tablas, sin las salvajes de trabajo (9.4).

### 11.7 Huida — `DECIDIDO`

**El Maestro:**

| Regla | Valor | Decisión que genera |
|---|---|---|
| Cuándo | En su turno, desde cualquier casilla | — |
| Costo | Gasta su **turno completo**. El combate termina **al final de la ronda**: los enemigos que faltan todavía actúan | Para guardar a una caída y huir hacen falta dos turnos: hay que planear con una ronda de anticipación |
| Quiénes se van | El Maestro y las criaturas de pie | — |
| Caídas en el tablero | **Mueren**: sus pergaminos arden y se aplica "muerte en el grupo". Las guardadas sobreviven | Huir sin guardarlas es abandonarlas |
| Si el Maestro cae antes del cierre | Hasta el cierre de la ronda sigue en el tablero y puede ser objetivo. Si cae, el combate termina **por caída, no por huida**: se busca rescatista (6; las que se iban con él siguen de pie y pueden rescatarlo) y las caídas mueren. Visión 6.6 | La huida es una apuesta anticipada, no un seguro |
| Previsualización al declarar | Qué enemigas actúan antes del cierre y el **daño máximo** que pueden hacerle al Maestro | ¿Huyo ahora con 6 de vida o pego una vez más? |
| Lealtad | No se gana el +1 de "pelearon juntos y ganaron" | — |
| En el mapa | Se pierden los nodos que quedaban del día | Huir salva el pellejo, pero cuesta comida |
| De noche | Se puede huir de una emboscada; el descanso queda a la mitad igual | — |

**Las salvajes** también pueden huir, **en su turno**:

| Salvaje | Probabilidad de huir al inicio de su turno con vida ≤ 25% |
|---|---|
| Rodauva | 50% |
| Surcón | 25% (terco) |
| Ocarra | 0% (valiente de más) |
| Zancajunco | 50% (prefiere huir) |
| Tasajero | 25%, al inicio de cada uno de sus dos turnos |

| Modificador | Efecto |
|---|---|
| Acobardada | +25 puntos |
| Enconada | No huye |
| Resultado | Gasta su turno y sale del tablero: no da comida ni se puede sellar |

La probabilidad se muestra sobre la unidad. A 0 de vida, la salvaje huye siempre (11.5).

**Decisión que genera:** una salvaje debilitada al tramo de 80% de sellado puede irse antes de que el Maestro tire. Hay que debilitarla y sellarla **en la misma ronda, antes de su turno**: la iniciativa y Secundar deciden la captura. La Prueba A (Ocarra, 0%) no cambia.

### 11.8 IA de las salvajes: remate — `DECIDIDO`

Cada salvaje, en su turno, decide en este orden:

1. **Huida:** con vida ≤ 25%, tira huida al inicio de su turno (11.7).
2. **Encono:** si está enconada, va por su rival (10.5). Así el Tasajero va por la Rodauva.
3. **Erizarse:** si su especie tiene Erizarse, su vida es **≤ 50%** y tiene una enemiga **de pie adyacente**, se eriza (03/10/2026). Una caída no cuenta: no es objetivo ni amenaza (04/10/2026, responde P-022).
4. **Remate:** si puede tumbar a alguna unidad este turno, ataca a esa. Si hay varias, la de menos vida actual.
5. **Cercana:** si no, ataca a la unidad más cercana que pueda alcanzar; si empatan, la de menos vida.
6. **Acercarse:** si no alcanza a nadie, se mueve hacia la unidad más cercana.

**Tasajero:** cada uno de sus dos turnos (Caza y Cuenta) recorre esta lista desde el paso 1.

**"Puede tumbar" y "puede alcanzar"** — `DECIDIDO` (03/10/2026, responde S-8): se mira el **turno completo**, es decir, moverse y después una acción.

**Desempates deterministas** — `DECIDIDO` (03/10/2026). La IA es simple a propósito: tiene que ser predecible para que el jugador planifique la ronda.

| Elección | Criterio, en orden |
|---|---|
| Objetivo con remate (paso 4) | Menos vida actual → más cercana → la que actúa antes en la cola |
| Objetivo sin remate (paso 5) | **Más cercana** → menos vida actual → la que actúa antes en la cola (04/10/2026, responde P-020) |
| "La que actúa antes en la cola" | El orden de la **ronda entera**, por la primera entrada de cada unidad, haya actuado o no (04/10/2026, responde P-021) |
| "Puede tumbar" | Se calcula con la misma función de previsualización del daño (determinista: el daño no tiene azar) |
| Casilla desde dónde golpear | Si ya alcanza desde donde está, **no se mueve** · la Ocarra prefiere la distancia 2 · la de menos movimiento · orden de lectura (y menor, después x menor) |
| Acercarse | Objetivo: la más cercana → menos vida → cola. Casilla: la alcanzable más cercana a la objetivo (Manhattan) → orden de lectura. Si ninguna la acerca, no se mueve |

**Por qué dos órdenes distintos** (P-020): el remate premia exponer a una herida; sin remate, manda la **posición**. El que se pone adelante recibe, incluido el Maestro (Pilar 1), y el Surcón puede hacer de muro. Con "menos vida primero" en los dos casos, la IA ignoraría la formación.

**Reglas fijas:** una acobardada no termina su movimiento más cerca de su rival; la Ocarra ataca desde distancia 2 si puede; nadie apunta a una caída; las salvajes no Secundan.

**Decisión que genera:** dejar a una herida expuesta es invitar al remate. ¿La retiro, la guardo o la cubro con el Surcón? Contra una Rodauva salvaje: el golpe que la deja en la mitad de su vida decide si después se eriza; conviene bajarla de un golpe justo, con la mano fina.

**Alternativas descartadas para Erizarse:** no erizarse nunca (la Rodauva salvaje queda trivial) y erizarse siempre que tenga una enemiga adyacente (combates largos contra un erizo inmóvil).

**Alternativas descartadas:** "la más cercana" (combates resolubles de memoria) y "el Maestro primero" (empuja a esconderlo, sección 8 de la Visión).

### 11.9 Prueba 0a — `DECIDIDO`

Rebanada de combate aprobada el 01/10/2026: tablero, relaciones, sellado, caída y rescate. Lo que no entra se carga como **parámetro del escenario** (lealtad, hambre, Saciado, enfermedades, balanza, Poder, Regeneración, vida y maná de entrada). Se juega con **escenarios fijos + panel de parámetros + semilla de azar fija**. El brief completo para el Arquitecto vive en el doc "Brief para el Arquitecto — Prueba 0a".

| Escenario | Archivo (`datos/escenarios/`) | Configuración | Qué mide | Señal de alarma |
|---|---|---|---|---|
| A. Día 1 | `a_dia_1.json` (Arquitecto) | Prueba A (11.6) | ¿Sello al 50% o arriesgo una ronda más? | Siempre se elige lo mismo |
| B. Muro | `b_muro.json` | Maestro + Rodauva Neutral (5) contra 2 Ocarras separadas. Sin rescatista | ¿Reconoce que hay que huir? ¿Guarda a la caída antes? Segunda salida: juntar a las Ocarras (rivales) con la Lanzadera | Huir nunca se lee como opción |
| C. Tasajero | `c_tasajero.json` | Maestro + Rodauva, Ocarra y Zancajunco leales (8) contra el Tasajero. La Rodauva se puede pasar a guardada en el panel | Duración (meta: 2 o 3 rondas) · ¿Llevo a la Rodauva? | Más de 5 rondas, o la Rodauva muere sin decisión |
| D. Rivales aliadas | `d_rivales_normal.json` · `d_rivales_hambriento.json` | Ocarra + Zancajunco Neutrales (5) contra Surcón + Rodauva salvajes, sin relación con la tribu. Hambre 3 y 6 | Incidentes por combate · ¿Separa con la Lanzadera? Con hambre, la obediencia baja a 3 y el incidente pasa a golpe | 0 incidentes, o castigo puro. **Leer también con la balanza 4** (ver 14) |
| E. Cobardía | `e_cobardia.json` · `e_cobardia_afines.json` | Rodauva leal (8), Rodauva Neutral (5) y Surcón leal contra el Tasajero; sin y con el toggle de afines (10.6) | ¿Sostiene a la asustada? | Nunca aparece, o frustra siempre |
| F. Rescate | `f_rescate.json` | Maestro con 6 de vida · Rodauva leal (rescatista frágil) · Ocarra Neutral, contra Zancajunco + Surcón | ¿Guarda caídas antes de caer? ¿Entiende quién lo salva? | El rescate se siente azaroso |
| G. Ataque nocturno | Borrador del Arquitecto | Ocarra desleal atacante; maná de entrada a la mitad (2.4); golpe inicial de 4 (9.2) | Las 3 salidas (9.3) · ¿Alcanza para resellar? | Comer es siempre la respuesta |
| H. Soplo | `h_soplo.json` | C con balanza 5 y Poder 3, mismas lealtades | ¿El Soplo es una build trampa? | Pierde siempre, o gana más fácil que el Barro |

**Valores de los escenarios** — `DECIDIDO` (03/10/2026, responde P-004 a P-007):

| Caso | Valor |
|---|---|
| "Leal" y "Neutral" sin número | **Leal 8, Neutral 5.** 8 sigue siendo leal con la balanza 5 (umbral 8); 5 es Neutral en todas las posiciones |
| El Maestro | Está en **los 11 escenarios**, con los valores iniciales salvo F (vida 6), G (maná 4), H (balanza 5, Poder 3) y `d_rivales_balanza4` |
| D hambriento | Hambre 6 **solo en las criaturas**; el Maestro queda en 3. La única diferencia entre las dos D es la obediencia |
| Posiciones | Las de `Arquitectura.md` A.9 quedan aprobadas como provisorias. **Ante una alarma, primero se descarta que la causa sea la posición; después se toca la regla** |

**Reglas de los escenarios:** todos usan posiciones fijas (el panel las cambia), hambre 3 y maná completo salvo indicación. Las variantes que se comparan **comparten semilla** (C y H; las dos D; las dos E), para que la diferencia salga de la regla y no del azar. Las notas de diseño de cada escenario viven en su campo `_nota`.

**Métricas por combate** — `DECIDIDO` (03/10/2026). Son **13** y reemplazan a cualquier otra lista (incluidas las "7 del Brief"). Se exportan junto con el resultado del combate (desenlace, destino de la atacante).

| # | Métrica | Cómo se cuenta |
|---|---|---|
| 1 | Rondas | Rondas iniciadas hasta el fin del combate |
| 2 | Secundar | Usos |
| 3 | Eslabones | Promedio y máximo, contando solo las cadenas de 2 eslabones o más |
| 4 | Incidentes | Total, dividido en distracciones y golpes |
| 5 | Encono | Veces que una criatura quedó enconada, por bando |
| 6 | Cobardía | Tiradas, separadas en acobardadas y resistidas |
| 7 | Sellados | Intentados y logrados, con la **probabilidad mostrada** en cada intento |
| 8 | Capturas perdidas | Por huida en su turno y por llegar a 0 (detecta el "pegarle de más") |
| 9 | Caídas | Por id de unidad |
| 10 | Caídas guardadas | Por id de unidad |
| 11 | Muertes | Por id y causa: derrota, huida o caída del Maestro |
| 12 | Rescate | Sí o no, y quién rescató |
| 13 | Distancia del Maestro | Manhattan a la enemiga de pie más cercana, al final de cada turno suyo; promedio del combate (vigila el Martillazo) |

**Umbrales de alarma** — `DECIDIDO` (03/10/2026; aprobados por el Director Creativo). Superar uno obliga a revisar la regla antes de pasar a la 0b (Visión 10).

**Cómo se mide:** **10 partidas por escenario**, y cada variante cuenta aparte, con al menos **3 jugadores distintos**. Se usan 10 semillas; las variantes que se comparan usan **las mismas 10** (C y H; las dos D; las dos E). Sin encuesta (Visión 11, pregunta abierta), todo sale del registro. Con 10 partidas, "80%" = 8 de 10.

| Escenario | Señal | Umbral | Métrica |
|---|---|---|---|
| A. Día 1 | Siempre se elige lo mismo | Más del **80%** de los primeros intentos de sellado en el mismo tramo de probabilidad (50% o 80%) | 7 |
| B. Muro | Huir nunca se lee como opción | Menos del **30%** de las partidas terminan en huida o en victoria | Desenlace |
| C. Tasajero | Combate largo | Más de **5 rondas** en más del **20%** de las partidas, o promedio fuera de **2 a 3,5** | 1 |
| C. Tasajero | La Rodauva muere sin decisión | La Rodauva muere en más del **50%** de las partidas en que empezó suelta | 11 |
| D. Normal | Rivales invisibles | Menos del **20%** de los combates con al menos 1 incidente. Leer también con la balanza 4 | 4 |
| D. Hambriento | Castigo puro | Derrota en más del **50%** de las partidas, o **3 o más** golpes por incidente por combate, en promedio | 4, desenlace |
| E. Cobardía | Nunca aparece / frustra siempre | Acobardadas por debajo del **10%** o por encima del **60%** de las tiradas | 6 |
| E. Toggle de afines | Decide el toggle (10.6) | Se aprueba si sin él se supera el 60% y con él la tasa queda entre 10% y 60% | 6 |
| F. Rescate | Se siente azaroso | En más del **60%** de las partidas en que el Maestro cae, no queda rescatista de pie | 9, 12 |
| F. Rescate | Guardar caídas no se lee | Ninguna caída guardada en más del **80%** de las partidas con caídas | 10 |
| G. Ataque nocturno | Comer es siempre la respuesta | Comer en más del **70%** de las partidas | Destino de la atacante |
| H. Soplo | Build trampa | Victorias en H por debajo del **20%** | Desenlace |
| H. Soplo | Más fácil que el Barro | Victorias en H más de **20 puntos** por encima de las de C | Desenlace |
| Todos | El Maestro se esconde (Martillazo) | Distancia media del Maestro **mayor a 3** en más del **50%** de los combates → se recorta el alcance del Martillazo (1.6) | 13 |

---

## 12. El valle: viaje, nodos y recolección

### 12.1 Mapa — `DECIDIDO` (geografía confirmada en `Mundo.md` 4.3)

```
Molino ──1── Huertos ──1── Vado ──1── Robledal
```

| Destino | Días desde el Molino |
|---|---|
| Huertos de Almiar | 1 |
| Vado de los Juncos | 2 |
| Robledal Hondo | 3 |

Valle en línea, siguiendo el río hacia el norte: para llegar al Robledal hay que pasar por los otros dos y cruzar el río en el Vado.

### 12.2 El día — `DECIDIDO`

| Regla | Valor | Decisión que genera |
|---|---|---|
| Acción del día | Moverse 1 casilla **o** quedarse | — |
| Llegar a un destino o quedarse en él | Se explora el **mapa del día** ese mismo día | — |
| Llegar al Molino | No se explora: el día no da comida | Volver al Molino tiene costo |
| Mapa del día | **4 columnas de 2 nodos**: se elige uno por columna (4 nodos por día) | Cada columna es un trueque: comida, material, criatura o pelea |
| Información | El tipo de nodo se ve; la composición de los encuentros, no (salvo con Centinela, 12.6) | — |

### 12.3 Rendimiento por nodo — `DECIDIDO`

| Nodo | Destino | Comida | Base | Pasiva que suma |
|---|---|---|---|---|
| Frutal | Huertos | Fruta | 3 | Rodauva +1 |
| Huerta | Huertos | Raíces | 2 | Surcón +1 |
| Granero | Huertos | Grano | 2 sanas · "revisar a fondo": +2 **podridas** | — |
| Pesca | Vado | Pescado | 2 | Zancajunco +1 |
| Orilla | Vado | Raíces | 2 | Surcón +1 |
| Hongos | Robledal | Hongos | 2 "con cuidado" · "todo": +2 **dudosas** | — |
| Colgadero (robar) | Robledal | Carne | 4 | — (+2 de hostilidad, 12.10) |

**Modificadores (precisa 8.4):** los porcentajes del **Maestro** (Saciado, enfermedades) se aplican al **total del nodo**, base más pasivas. Una criatura **Enferma no aporta su pasiva**.

**Raciones de riesgo:** la podrida y la dudosa se comen como aceptadas; la probabilidad de enfermar se tira **al comerlas** (7.4). La decisión pasa a ser a quién le toca.

### 12.4 Rebuscar — `DECIDIDO`

En cualquier nodo, en lugar de su evento, se puede **rebuscar**: **1 bicho**, o 2 con un Surcón suelto. No le afecta el agotamiento.

**Decisión que genera:** es el piso de un destino agotado. Mantiene vivo al Maestro, no a la tribu.

### 12.5 Agotamiento y comida perecedera — `DECIDIDO`

| Regla | Valor | Decisión que genera |
|---|---|---|
| Agotamiento por destino | +1 al cerrar un día en que se lo exploró · −1 al cerrar un día en que no (mínimo 0) | ¿Me quedo otro día o alterno? |
| Efecto | Cada nodo de recolección rinde **base − agotamiento** (mínimo 0). Las pasivas no se agotan | Ejemplo: el Frutal rinde 3, 2 y 1 en tres días seguidos |
| Perecedera: fruta, pescado, carne, hongos | Se pudre en el **2.º cierre de día** después de recogerla y pasa a ser **podrida** | La carne del Robledal se come ahí |
| Seca: grano, raíces, bichos | No se pudre en el MVP | Los Huertos son la despensa del viaje largo |

**Motivo:** los Huertos ofrecen tres tipos de comida, así que la dieta variada no empuja al Maestro a salir. Sin agotamiento ni pudrición, acampar ahí sería la estrategia dominante.

### 12.6 Pasivas fuera de combate — `DECIDIDO`

Aplican con la criatura **suelta**. Son de la criatura; las habilidades de campamento, en cambio, son del Maestro (9.4).

| Criatura | Pasiva | Efecto | Tope |
|---|---|---|---|
| Rodauva | Recolección | +1 fruta por Frutal | Una misma pasiva suma como máximo **+2 por nodo** |
| Surcón | Excavación | +1 raíces por Huerta u Orilla · +1 bicho al rebuscar | Ídem |
| Zancajunco | Pesca | +1 pescado por Pesca | Ídem |
| Ocarra | Centinela | Revela la composición de los encuentros del mapa del día · En el ataque de una criatura propia, anula el golpe gratis si ella no es la atacante, **con cualquier lealtad** (9.2) | No se acumula |

**Pilar 2:** las de trabajo producen comida; la mixta, solo en el Vado; la de combate da información y seguridad.

### 12.7 Composición de referencia del mapa del día (8 nodos) — `DECIDIDO` (valores de test)

| Destino | Nodos |
|---|---|
| Huertos | Frutal ×2 · Huerta · Granero · Palomar (péñola) · Bajo el manzano · Encuentro (11.6) · Hornacina (primera visita) o El corral caído (desde la segunda) |
| Vado | Pesca ×2 · Orilla · Charco quieto (agua) · Algo se movió en el juncal · El surco que ronca · Encuentro (11.6) · La crecida: leer el río (12.11; La Poza Tibia mientras el Maestro tiene quebranto, 6.2) |
| Robledal | Colgadero · Rodeo de las zarzas · Roble Viejo (ramita) · Hongos ×2 · Encuentro (Tasajero, según hostilidad, 12.10) · Paso ×2 |

**Motivo de los cambios (v0.6):** los avistamientos del Surcón y la Ocarra (`Mundo.md` 4.5) entran sin pasar de 8 nodos. El corral caído comparte casilla con la hornacina: la primera visita es para el cuenco. En el Vado, el surco ocupa uno de los dos encuentros.

### 12.8 Rodeo de las zarzas — `DECIDIDO`

| Camino al Roble Viejo | Nodos | Riesgo |
|---|---|---|
| Por el colgadero | 2 (colgadero + Roble Viejo) | El Tasajero; la Rodauva suelta sube la hostilidad |
| Por el rodeo | 3: el rodeo **ocupa una columna extra** | Ninguno en el MVP: el costo es un nodo menos de comida |

### 12.9 Presupuesto de comida (referencia de balance)

| Tipo de día | Raciones aproximadas |
|---|---|
| Destino, 4 nodos de comida | Huertos 8–10 · Vado 6–8 · Robledal 6–8 (robando carne) |
| Destino, día mixto (2 de comida + material + encuentro) | 4–6 |
| Llegar al Molino | 0 |

| Tribu suelta | Consumo diario |
|---|---|
| Maestro + Rodauva | 2,5 |
| + Ocarra | 3,5 |
| + Surcón | 5,5 |
| Grupo completo | 7 |

**Costo real del primer ritual:** Molino → Huertos → Vado → Robledal → Vado → Huertos → Molino = **6 días**, 5 de exploración y 5 noches al raso, unas 26 raciones en días mixtos. Alcanza para el Maestro y 2 o 3 sueltas: **el viaje largo se hace guardando a alguien**, aunque cada criatura guardada deja una guardia sin cubrir y apaga su habilidad de campamento (9.4).

### 12.10 El Tasajero: hostilidad — `DECIDIDO`

La hostilidad es una **variable de la partida**, de **0 a 6**, que arranca en **3**. **No baja sola**: el Tasajero se acuerda ("alguien anotó tu visita"). En la Prueba 0a siempre está Atento.

| Hostilidad | Estado | Encuentro del Robledal | Emboscada en el Robledal | Colgadero |
|---|---|---|---|---|
| 0–1 | **Apaciguado** | Sin combate: el nodo es de paso y se puede rebuscar | **No hay emboscadas** | Robar sube la hostilidad, sin combate |
| 2–4 | **Atento** | Combate contra el Tasajero | Base 30% | Ídem |
| 5–6 | **Cazando** | Combate | Base **50%** | Robar dispara un **combate inmediato** |

**Decisión que genera:** ¿pago por la paz en el Robledal o lo atravieso arriesgándome?

| Evento | Cambio | Decisión que genera |
|---|---|---|
| **Robar carne** (4 raciones, 12.3) | **+2** | La mejor comida del valle cuesta pasar de Atento a Cazando |
| **Rodauva suelta** en el colgadero | **+1**, aunque no se robe | ¿Guardo a la compañera (y apago Leña en las púas) o la llevo? |
| **Ofrenda** | **−1 cada 2 raciones**; la carne cuenta doble. Máximo **−2 por ofrenda**. No se aceptan raciones podridas | La paz cuesta una comida del día y no se compra en un solo día |
| **Derrotarlo** (huye o llega a 0) | **−1**, **3 XP** (1.4) y no vuelve en lo que queda de la visita: ni encuentro ni emboscada | Pelear también se gana su respeto, pero es caro |
| Fuego en el Robledal | Sin cambio en la hostilidad: ya suma +10 a la emboscada (9.4) | — |

Una **visita** son los días seguidos en el Robledal; termina al irse. Derrotarlo no da comida: huye como cualquier salvaje (11.5).

| Camino para apaciguarlo desde 3 | Costo |
|---|---|
| Solo ofrendas | 4 raciones repartidas en 2 días (tope de −2 por ofrenda) |
| Ganarle + 1 ofrenda | Un combate de 2 o 3 rondas contra 12 de daño por ronda, más 2 raciones |
| Después de robar una vez | Sube a 5 (Cazando): volver a Atento cuesta 4 raciones |

### 12.11 La crecida — `DECIDIDO`

El Vado es el portero del Robledal. Cada día, el río tiene un estado: **70% normal, 30% crecido**. La tirada del día siguiente se hace al cerrar el día (7.9, paso 7). Afecta el cruce **en las dos direcciones** (Vado → Robledal y Robledal → Vado).

| Regla | Valor | Decisión que genera |
|---|---|---|
| Río normal | Se cruza sin costo | — |
| Río crecido | Se puede cruzar: cada ser **suelto** (el Maestro incluido) pierde el **25% de su vida máxima real** (redondeado hacia abajo, mínimo 1). Las **guardadas** cruzan a salvo | ¿Guardo a la tribu (y pago el maná para sacarla), la expongo, o espero un día? |
| Daño del cruce | **El cruce no mata a nadie**: el Maestro y las criaturas quedan con 1 de vida como mínimo, igual que en el ritual (3.3). Motivo: una muerte fuera del combate se saltearía el rescate | Llegar al Robledal con 1 de vida es el riesgo real |
| Leer el río | Elegir el nodo **La crecida** muestra el estado del río del día siguiente | Cambiar un nodo de comida por información para planificar |
| Quebranto | El nodo es la Poza Tibia (6.2): no se puede leer el río, se cruza a ciegas | — |

**Frecuencia:** en un viaje de ida y vuelta al Robledal hay un 51% de encontrar el río crecido al menos una vez.

---

## 13. Partida: plazo y epílogo — `DECIDIDO` (Visión 5)

| Regla | Valor | Decisión que genera |
|---|---|---|
| Duración | **30 días**, visibles y contados desde el día 1. Dato editable: los primeros playtests pueden usar 20 | ¿Me alcanza el tiempo para otro ritual? |
| Fin | Al terminar el **cierre del día 30** (7.9). Esa noche se resuelve completa: abandono, ataque y emboscada | — |
| Otra forma de terminar | Permadeath (6) | — |
| Epílogo | **Solo texto que lee la tribu**: sin puntaje ni cierres por umbral | Cómo sobreviviste, no cuánto |
| Comidas | Cada criatura comida tiene su propia línea, **sin ponderar por día**: el último día pesa igual que el primero | Comer al final no es gratis |

**Registro para el epílogo**, por instancia: especie, si al final está **suelta, guardada o perdida**, estado de lealtad final, **día en que se guardó por última vez**, flag de **compañera inicial** y, si se perdió, **la causa** (comida, abandono, muerte en combate, hambre, perdonada) **y el día**. Opcional: flag "fue atacante".

**Orden de lectura** (responde `Mundo.md` 4.11):

| Bloque | Orden interno |
|---|---|
| 1. Apertura | — |
| 2. Sueltas | La **compañera inicial** primero, si sigue suelta; después, de **mayor a menor lealtad**; los empates, por el orden de la tribu |
| 3. Guardadas | Por día del último guardado, de la más antigua a la más reciente |
| 4. Perdidas | Por día; dentro del mismo día, en el orden en que ocurrieron |
| 5. Cierre | — |

**Variante "Sobreviviste al verano. Solo."**: aparece si al final **no queda ninguna criatura de la tribu, ni suelta ni guardada**. Es un hecho, no un cierre por umbral.

**Las golondrinas no tienen mecánica:** el plazo lo cuentan las rayas, con el dato de duración.

**Referencia:** con 30 días alcanzan 3 o 4 rituales (cada vuelta al Robledal son 6 días, 12.9) y una captura de mitad de partida llega a leal.

---

## 14. Combinaciones rotas y riesgos

| Riesgo | Estado | Solución |
|---|---|---|
| Alargar combates para recargar maná | Resuelto | Tope de maná de entrada + hambre por ronda |
| Guardar criaturas antes del conteo de comida | Resuelto | Come si estuvo suelta en algún momento del día |
| Guardar en combate para salvar criaturas gratis | Resuelto | Cuesta la acción de la criatura y exige adyacencia |
| Invocar gratis con descuento máximo | Resuelto | Costo mínimo de 1 maná |
| Porcentajes que se pierden con números chicos | Resuelto | Afinidad plana; recolección sobre el total del nodo |
| Resellar a la traidora para "reiniciarla" | Resuelto | Vuelve con lealtad 1 y exige un pergamino en blanco |
| Resellar un rango 2 era imposible con el maná nocturno | Resuelto | Resellar cuesta lo mismo que invocar |
| Combos que dependen del azar de la iniciativa | Resuelto | Acción Secundar |
| Cadenas infinitas | Resuelto | Cada eslabón vale la mitad |
| Curarse gratis con hechizos antes de dormir | Resuelto | Sin hechizos fuera del combate |
| Encadenar rituales con materiales acumulados | Resuelto | Máximo 1 por día; debilidades acumulables |
| Porcentajes de vida que se achican en cadena | Resuelto | Todo se calcula sobre la vida máxima real |
| **Balanza inicial en 2 da casi todo el Arrimo** | ⚠️ Vigilar | Decidido arrancar en 2. Si el Barro se siente "normal" y el Soplo un castigo, revisar |
| **Combo de afines +80% en balanza 1** | ⚠️ Vigilar | Testear que no trivialice los combates de rango 1 |
| **Polo Soplo como build trampa** | ⚠️ Vigilar | Sin Arrimo y con umbral 8. La interfaz debe mostrar el umbral de rescate y los riesgos de incidente |
| **Espiral de enfermedad** (enfermo → recolecta menos → famélico → come rechazado → enfermo) | ⚠️ Vigilar | Es intencional (Pilar 4). Testear que la cura viajando y el descanso parcial permitan salir |
| **Bichos rompen la monotonía muy barato** | ⚠️ Vigilar | Si resulta trivial, exigir que cada tipo cubra al menos 1 ración completa |
| **Hambre por ronda castiga combates largos legítimos (jefes)** | ⚠️ Vigilar | Si molesta, eximir a los jefes o subir a cada 8 rondas |
| **Invocar siempre a la noche** (gratis en maná) | ⚠️ Vigilar | Cuesta un día extra de comida. Si domina en los tests, revisar |
| **El Zancajunco, único beneficiado por comer criaturas** | ⚠️ Vigilar | Coherente con su ficha; ver en test si empuja a comer compañeras |
| **Cobardía poco testeada en el MVP** | ⚠️ Vigilar | Con la Rodauva como compañera desde el día 1, se testea si el jugador la lleva al Robledal (el colgadero y el Tasajero la castigan). Si aun así casi no aparece, armar un escenario de test forzado |
| **Tribu de Rodauvas trivializa el hambre en los Huertos** | Resuelto | Agotamiento y pudrición (12.5); tope de +2 por pasiva y nodo; una sola habilidad de campamento por especie (9.4) |
| **Acampar en los Huertos** (la dieta variada no lo impide) | Resuelto | Agotamiento y comida perecedera (12.5) |
| **Tribu de Ocarras** (rango 1, alcance 2, Velocidad 7, come poco) | ⚠️ Vigilar | Ocarra–Ocarra mal, Centinela no se acumula, una sola habilidad por especie. Si domina, subir el incidente entre Ocarras |
| **Esquivar todos los combates eligiendo columnas** | ⚠️ Vigilar | Sin combates no hay +1 de lealtad. Desde la v0.6 el Vado trae un solo encuentro: si se vuelve un destino sin peleas, sumar un segundo encuentro en lugar de la Orilla |
| **Guardar a todas las caídas y huir siempre** | ⚠️ Vigilar | Lo limitan el maná, la acción, el alcance y los dos turnos. Si nunca muere nadie, subir el costo al de sellar |
| **IA predecible de más** (no se mueve si ya alcanza; 11.8) | ⚠️ Vigilar | Si trivializa B o D, sumar "la casilla con menos enemigas adyacentes" antes del orden de lectura |
| **Salvajes que huyen antes del sellado** frustran | ⚠️ Vigilar | Se muestra el %. Si frustra, que solo huyan las acobardadas |
| **Microgestión nocturna** | ⚠️ Vigilar | La interfaz repite la asignación de guardias de la noche anterior |
| **Lanzadera sobre el Tasajero en cada ronda** | Aceptado | Movimiento 4 contra 1 casilla de empuje; la reserva se agota |
| **Rebuscar como piso sin fin** | Aceptado | Sostiene al Maestro, no a la tribu |
| **La compañera muere en el primer combate** | Resuelto | Caída en lugar de muerte (11.5) y tope de amenaza en los Huertos (11.6) |
| **Pegarle de más a una salvaje** | Resuelto | Huye: se pierde la captura, no hay muerte ni comida (11.5) |
| **Cazar salvajes como fuente de carne** | Resuelto | Las salvajes huyen y no dan comida (11.5) |
| **Exponer al Maestro con caídas en el tablero** | Intencional | Si cae, sus caídas mueren. La interfaz debe mostrar las caídas en riesgo |
| **Jefe sin suficientes acciones** | Resuelto | El Tasajero tiene dos turnos por ronda |
| **Criatura "guardaespaldas"** (una sola suelta, siempre leal) | Aceptado | Es la regla de oro funcionando |
| **Congelar desleales en el pergamino** | Aceptado | Detiene el abandono, pero también el vínculo y la curación; sacarla cuesta maná |
| **La IA de remate castiga de más a la Rodauva** (8 de vida) | ⚠️ Vigilar | Escenarios A y E. Si la compañera cae en casi todos los combates, bajar el remate a "solo si la objetivo no está erizada" |
| **Combos demasiado fáciles** (las acciones que no son ataque no cortan) | ⚠️ Vigilar | Si las cadenas de 4 eslabones son rutina, que solo la Lanzadera no corte |
| **Quebranto sin maná** camino a la Poza | Intencional | No sella ni invoca hasta curarse: la tribu suelta lo tiene que sostener. Si es un callejón sin salida, permitir la regeneración por turno en combate |
| **Comer y recapturar para farmear XP** | Resuelto | La captura da XP solo la primera vez por especie (1.4). Queda el hito de Leal por una instancia nueva: +3 tras unos 5 días, al costo de −5 de lealtad para toda la tribu. Se acepta |
| **Derrotar al Tasajero no daba recompensa** | Resuelto | 3 XP, −1 de hostilidad y el resto de la visita sin él (12.10) |
| **Guardar a toda la tribu los últimos días** (no come y la lealtad queda congelada para el epílogo) | ⚠️ Vigilar | El epílogo distingue sueltas de guardadas (13). Si aparece como rutina, pedirle al Director Creativo que el texto lo marque con más peso |
| **El Soplo llega tarde en la 0b** | ⚠️ Vigilar | Con 3 o 4 subidas, el polo Soplo se alcanza recién al final. El escenario H de la 0a lo testea por parámetro; si hace falta en la 0b, partida de test con la balanza inicial como parámetro |
| **Robar y ofrendar en loop** | Aceptado | Neto: 2 de carne en dos días de colgadero, menos que un día de Hongos |
| **Ofrendar carne de una compañera comida** | ⚠️ Vigilar | Permitido: consecuencia del Pilar 4, no regla. Si aparece como estrategia, se prohíbe ofrendar carne de criatura |
| **Quebranto y hambriento atrapado del otro lado del río** | Resuelto | El cruce no mata (12.11). Queda el costo de llegar con poca vida |
| **Encono alto siempre deseable** (la Ocarra enconada pega 7) | ⚠️ Vigilar | Si perder el control no pesa, bajar el máximo a +2. Métricas de los escenarios C y D |
| **El Maestro casi nunca es objetivo** (la IA va por la de menos vida; 11.8) | ⚠️ Vigilar | Mitigado en parte: sin remate, la IA va por la más cercana (P-020), así que un Maestro adelante recibe. Métrica 9 en C y F. Si el Maestro no cae nunca, el Pilar 1 se debilita: aplicar el remate sobre el Maestro con su vida en porcentaje |
| **Maestro solo en el ataque nocturno** (ninguna leal defiende; 9.2) | ⚠️ Vigilar | Peor caso ajustado. Si en 0b.3 termina en permadeath la mayoría de las veces, la atacante pierde el golpe inicial cuando no hay defensoras. Testear con la variante `g_sin_leales` |
| **Muertes en cadena** (cada muerte resta por separado; 5.2) | Intencional | Perder un combate con dos caídas golpea a toda la tribu. Es la regla de oro; vigilar que no empuje a una espiral de abandonos |
| **La enconada remata a la salvaje que se quería sellar** | ⚠️ Vigilar | Tensión intencional (Pilar 2). Si frustra, que la enconada deje a una salvaje en 1 de vida |
| **Incidentes casi invisibles con la balanza 2** (5% por chequeo; cerca de 30% de ver al menos uno en un combate de 3 o 4 rondas) | ⚠️ Vigilar | Escenario D con la balanza 2 y con la 4 (15%). Si a balanza 2 los rivales nunca se notan, bajar el Arrimo a −3 puntos por paso o subir la base a 25% |
| **La Rodauva salvaje erizada alarga los combates** | ⚠️ Vigilar | Escenario D. Si se vuelve un muro, que solo se erice si la enemiga adyacente puede tumbarla este turno |

---

## 15. Pendientes

**PARA SISTEMAS:**
- [x] ~~Dudas S-1 a S-6 del Arquitecto, cruce del río, orden del epílogo y variante "Solo"~~ → Resueltas el 02/10/2026.
- [x] ~~IA de la Rodauva salvaje, turnos del Tasajero, golpe gratis del ataque nocturno y lealtad de las guardadas al comer~~ → Resueltas el 03/10/2026 (5.2, 9.2, 10.5, 11.2, 11.7, 11.8).
- [x] ~~Escenarios B a F y H~~ → Entregados el 03/10/2026 (11.9). **Sistemas no tiene pendientes que bloqueen la 0a.**
- [x] ~~Dudas abiertas de `Arquitectura.md` 10.5: P-001 a P-009, S-8, S-10 y S-12~~ → Resueltas el 03/10/2026 (5.2, 5.4, 9.2, 10.6, 11.6, 11.8, 11.9, 12.6).
- [x] ~~Dudas S-13 a S-19 y P-011 a P-022 de la programación de T07 a T11~~ → Resueltas el 04/10/2026 (8.2, 9.2, 10.2, 11.2, 11.3, 11.4, 11.8). **Todas confirman la lectura ya programada: no cambia código ni tests.**
- [ ] Toggle de afines contra la cobardía (10.6): se decide con el escenario E.
- [ ] Riesgos ⚠️ (14): se ajustan con las métricas de los playtests.
- [x] ~~Inicio del turno, Encono contra incidente, rival de la salvaje enconada, desempates de la IA, Lanzadera y métricas~~ → Resueltos el 03/10/2026 (1.6, 10.2, 10.4, 10.5, 11.3, 11.8, 11.9).
- [ ] 0b, preguntas de `Mundo.md` 9.1 (no bloquean la 0a): ~~cuándo se puede comer a una criatura~~ (resuelto en la Visión v1.0, 6.5: solo en el reparto de la noche) · si se puede comer a una guardada · aviso de rescatistas perdidos al comer · qué pasa si el Maestro muere de hambre · olvido de la confianza sin pergamino en blanco · cortes de las etapas de confianza y de las golondrinas.
- [ ] Fuera del MVP (Capa 3): ¿5 posiciones de balanza alcanzan para el juego completo? · Posición inicial de la balanza por clase, entre 2 y 4.

**PARA DIRECTOR CREATIVO:**
- [ ] Registrar en `Decisiones.md` las decisiones del 02/10/2026 (v0.8) y del 03/10/2026 (v0.9). Ninguna contradice la Visión v0.9.
- [x] ~~Aprobar los umbrales de alarma de 11.9~~ → Aprobados el 03/10/2026. La Visión v1.0 (10 y 11) ya los da por aprobados: queda coherente.
- [ ] Registrar en `Decisiones.md` las decisiones del 03/10/2026 (v1.0).
- [ ] Registrar en `Decisiones.md` las decisiones de la v1.1, en especial que "las leales defienden" (Visión 6.4) quiere decir "solo las leales" (9.2).

**PARA WORLDBUILDER:**
- [x] ~~Textos de incidentes, baño en la Poza y línea de "solo guardadas"~~ → Entregados en `Mundo.md` v0.8.
- [ ] Cerrar en `Mundo.md` 9.1 la pregunta de las guardadas: no pierden lealtad al comerse a una compañera (5.2). La variante "todavía no sabe" de 4.12 es coherente.
- [ ] Ataque nocturno (0b): una línea para las sueltas que miran sin defender al Maestro, con variante si **ninguna** lo defiende, y otra para la Centinela no leal ("avisa y se queda quieta") (9.2).

**PARA ARQUITECTO:**
- [x] ~~S-1 a S-6 y desbloqueo de T28~~ → Cerrados en `Arquitectura.md` v0.6.
- [ ] Sumar los escenarios B a F y H a `datos/escenarios/` y validarlos contra el esquema `escenario` (sobre todo, `_nota` dentro de cada unidad y `"guardada"` como valor de `estado`).
- [ ] Escenario G: golpe inicial como ataque normal, 4 de daño con la Ocarra (9.2) → T30.
- [ ] IA: paso de Erizarse (11.8) → T11, T20, T24. Tasajero con dos turnos completos, huida y Encono chequeados en cada uno y contador único (10.5, 11.2, 11.7) → T07, T19, T20, T25.
- [ ] T23 y T33: exportar las **13 métricas de 11.9** (definidas el 03/10/2026), no "las 7 del Brief".
- [ ] Sumar el paso de Erizarse a la nota de K-07 (orden de la IA) y los desempates de 11.8 → T11, T20.
- [ ] Orden del inicio del turno (11.3) y una tirada de incidente por turno, salteada si está enconada (10.4) → T18, T19. Corte de la cadena al cerrar la ronda (10.2) → T16. Casos borde de la Lanzadera (1.6) → T22.
- [ ] Confirmar que la copia del Brief en `docs/` no contradiga los cambios de la v1.0.
- [ ] v1.1: pasar P-001 a P-009, S-8, S-10 y S-12 a "Resueltas" en 10.5. T10: suma y recorte único de la lealtad del combate, y "afines" por relación de especie (5.2). T14: cortes de obediencia desde los mismos datos que la lealtad (5.4). Actualizar la `_nota` de `a_dia_1.json`: la apuesta es la Rodauva, no la vida del Maestro (11.6).
- [ ] 0b.3: lista de defensoras al empezar el combate nocturno; +1 de victoria solo para las que pelearon; golpe inicial letal termina el combate antes de la ronda 1 (9.2). Variante de escenario `g_sin_leales` (Rodauva y Zancajunco con lealtad 5, misma semilla que G).
- [ ] 0b: registro del epílogo con día del último guardado y flag de compañera inicial; orden de lectura y variante "Solo" (13). Cruce del río con vida mínima 1 (12.11).
- [ ] v1.2: pasar S-13 a S-19 a "Resueltas" en 10.5 y cerrar P-011 a P-018 y P-020 a P-022 en `docs/PREGUNTAS.md`. Sin cambios de código, datos ni tests.
- [ ] 0b: en los encuentros generados desde las tablas de 11.6, la lista de enemigas sigue el orden de la columna Composición (desempate de iniciativa entre enemigas, 11.3).
- [ ] Vigentes: todo número de las secciones 1 a 11 es dato editable (11.9); mapa del día, agotamiento, pudrición, confianza, campamento y cierre del día (7.9); contador de días, XP y nivel, hostilidad del Tasajero, tablas de encuentros y estado del río.

**PARA ARTE / UI:**
- [ ] Previsualizaciones obligatorias de la 0a: % de sellado y de huida, % de incidente por casilla, % de Encono y cobardía, desglose del daño (con el bono del Encono), cola de iniciativa (Caza y Cuenta), umbral de rescate, caídas en riesgo y empuje de la Lanzadera.
- [ ] Al declarar la huida, enemigas que actúan antes del cierre y daño máximo sobre el Maestro (11.7).
- [ ] Contador del Encono (0–3) visible sobre la criatura.
- [ ] Antes de dormir, junto al ícono de riesgo (9.1): avisar si el golpe inicial puede tumbar al Maestro y mostrar quiénes lo defenderían (9.2).
- [ ] Marca de quebranto en la barra de vida, con contador.
- [ ] 0b: rendimiento previsto de cada nodo, días de cada ración perecedera, pantalla del campamento, contador del plazo (rayas), barra de XP, estado del Tasajero, estado del río con su previsión y aviso de daño antes de cruzar.

---

## 16. Registro de cambios

| Versión | Fecha | Cambio |
|---|---|---|
| v0.1 | 30/09/2026 | Creación: magia, maná, pergaminos, captura, lealtad, rescate y hambre en combate |
| v0.2 | 30/09/2026 | Sincronización con la Visión v0.3 (balanza, Tasajero). Liderazgo (1.3), progresión `PROPUESTA` (1.4) y dieta del Maestro (1.5). Maná nocturno (2.4). Rangos del MVP y resellado (4.3, 4.4). Lealtad diaria por cobertura y obediencia (5.2, 5.4). Escala de hambre, apetito, raciones, bichos, muerte por hambre y comer criaturas (7). Estado Enfermo acumulable con cura (8). Abandono y ataque nocturno (9). Iniciativa, Esperar, combos, afinidad, incidentes, provocación y salvajes (10). Riesgos actualizados (11) |
| v0.3 | 01/10/2026 | Sincronización con la Visión v0.4: balanza Barro ↔ Soplo, Arrimo, Encono y Secundar (provisorios); progresión por nivel `DECIDIDO`; balanza inicial en 2 (1). Magia fuera del combate (2.5). Sección 3 ampliada: pergaminos iniciales, quema y ritual de sangre con materiales y costo en sangre. Resellar con costo de invocar y pergamino en blanco (4.4). Zancajunco acepta carne (7.4). Vida máxima real y vigente, curación al dormir (7.8) y orden del cierre del día (7.9). Cobardía de las criaturas de trabajo (10.6). Riesgos actualizados (11) |
| v0.4 | 01/10/2026 | Sincronización con la Visión v0.5: nombres finales (Arrimo, Encono, Secundar), péñola, prenda, Urdimbre y "lo que diste" (3.3); mixtas se enconan (10.5). Compañera inicial (3.4). Caída del Maestro en combate y caídas (6, 9.2). Nueva sección 11: estadísticas, fichas, tablero e iniciativa, fórmula de daño, vida en 0 y encuentros de referencia. Riesgos pasa a 12, Pendientes a 13 y Registro a 14 |
| v0.5 | 01/10/2026 | Sincronización con `Mundo.md` v0.4: nombres finales de los rasgos y relaciones dentro de la especie (10.8). Hechizos de la clase inicial `PROPUESTA` (1.6). Guardar a una caída con maná (2.3, 3.1, 11.5). Hambre e inventario iniciales (3.4). Camino de confianza (4.5). Raciones podridas, dudosas y sin fuego (7.4). Cierre del día con emboscada (7.9). Enfermo por comida podrida y sin cocinar (8.1); descanso solo en el Molino (8.3). Campamento al raso: guardias, fuego, emboscadas y habilidades de campamento del Maestro (9.4). Afines contra la cobardía `PROPUESTA` (10.6). Huida del Maestro y de las salvajes (11.7). Nueva sección 12: mapa, día, nodos, rendimiento, rebuscar, agotamiento, pudrición, pasivas, rodeo y presupuesto. Riesgos pasa a 13, Pendientes a 14 y Registro a 15 |
| v0.6 | 01/10/2026 | Sincronización con la Visión v0.7 y `Mundo.md` v0.5: hechizos y rasgos `DECIDIDO` con nombres finales (1.6, 11.2); Madriguera (9.4); fuentes de experiencia (1.4). Malherido (6.1) y recuperación con Poza Tibia `PROPUESTA` (6.2). Avistamientos del Surcón y la Ocarra (4.5, 12.7). Reglas de combate de la Prueba 0a: regeneración al inicio del turno (2.1), invocar adyacente (3.1), sellar en combate (4.1), rescatista (6), hambre en combate (7.2), salvajes no Secundan (10.1), corte de combos (10.2), afinidad no acumulable (10.3), incidente (10.4), alcance y enconada (10.5), turno, movimiento, distancias y despliegue (11.3). Nuevas 11.8 (IA de remate) y 11.9 (Prueba 0a). Riesgos y pendientes actualizados |
| v0.7 | 02/10/2026 | Sincronización con la Visión v0.8: recuperación y Poza Tibia `DECIDIDO` (6.2). Experiencia: fuentes, XP de captura una vez por especie, curva 5 × N y subida de nivel en el paso 0 del cierre (1.4, 7.9). Encuentros de los Huertos y del Vado, salvajes de trabajo que no inician combate (11.6) y emboscadas desde las mismas tablas (9.4). Nuevas 12.10 (hostilidad del Tasajero) y 12.11 (la crecida). Nueva sección 13: plazo de 30 días y epílogo. Riesgos pasa a 14, Pendientes a 15 y Registro a 16. Sistemas queda sin bloqueantes del MVP |
| v1.0 | 03/10/2026 | Sincronización con la Visión v1.0. Cierre de los detalles de la 0a: casos borde de la Lanzadera (1.6), corte de la cadena al cerrar la ronda (10.2), una tirada de incidente por turno y sin incidente si está enconada (10.4), rival de la salvaje enconada (10.5), orden del inicio del turno (11.3), desempates de la IA (11.8), 13 métricas definidas y umbrales de alarma aprobados (11.9). Riesgo nuevo: IA predecible (14). Pendientes actualizados (15) |
| v0.9 | 03/10/2026 | Lealtad: todos los eventos de 5.2 alcanzan solo a las sueltas, incluidas las comidas (responde `Mundo.md` 9.1; 5.2, 9.3). Golpe inicial del ataque nocturno como ataque normal (9.2). Tasajero: dos turnos completos, huida y Encono en cada uno, contador único (10.5, 11.2, 11.7, 11.8). IA: paso de Erizarse para la Rodauva salvaje (11.8). Escenarios B a F y H entregados, con archivo y configuración (11.9). Riesgos nuevos: incidentes con la balanza 2 y Rodauva erizada (14). Pendientes actualizados (15) |
| v0.8 | 02/10/2026 | Sincronización con la Visión v0.9 y `Mundo.md` v0.6: quebranto reemplaza a malherido (6, 6.1, 6.2, 7.9, 12.7, 12.11, 14). Respuestas a `Arquitectura.md` 10.4: victoria por estado al terminar (5.2, S-5), Saciado derivado (7.1, S-6), hambre de combate en las caídas (7.2, S-2), bono y contador del Encono (10.5, S-4), salvajes con afinidad y sin combos (10.7, S-3), caída del Maestro tras declarar la huida (11.7, S-1). Caídas sin relaciones (11.5). El cruce del río no mata (12.11). Epílogo: registro, orden de lectura, variante "Solo" y golondrinas (13). Riesgos y pendientes actualizados |
| v1.1 | 03/10/2026 | Respuestas a `Arquitectura.md` 10.5. Lealtad: "afines" en la muerte por relación de especie, −2 total al comer a la atacante, suma y recorte único por combate (5.2). Cortes de obediencia iguales a los de lealtad (5.4). Ataque nocturno: golpe inicial letal termina el combate antes de la ronda 1 y solo las leales defienden; las demás miran (9.2). Centinela con cualquier lealtad (12.6). El Maestro no cuenta como afín en el toggle de cobardía (10.6). Prueba A reescrita como referencia de daño: manda la IA de 11.8 (11.6). "Puede tumbar" incluye moverse (11.8). Valores de escenarios y regla de alarma por posición (11.9). Riesgos nuevos (14). Pendientes actualizados (15) |
| v1.2 | 04/10/2026 | Respuestas a `Arquitectura.md` 10.5 (S-13 a S-19) y a `docs/PREGUNTAS.md` (P-011 a P-018, P-020 a P-022), todas con la lectura ya programada. Iniciativa: empate entre enemigas por orden de la lista y pérdida de las entradas restantes al dejar de actuar (11.3). Velocidad fija del Maestro en 0a (11.2). Erizarse cierra el movimiento y terminar sin acción es esperar (10.2, 11.2, 11.3). Saciado y enfermedades solo para la tribu; sin recorte intermedio en el daño (8.2, 9.2, 11.4). La caída enemiga bloquea paso y línea (11.3). IA: dos órdenes de objetivo (con y sin remate), cola de la ronda entera y caída que no hace erizarse (11.8). Riesgo del Maestro como objetivo actualizado (14). Pendientes actualizados (15) |
