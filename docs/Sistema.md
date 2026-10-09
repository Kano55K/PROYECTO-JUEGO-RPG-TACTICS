# SISTEMA — Reglas, números y balance

> **Estado:** Borrador v1.7 · **Dueño:** Diseñador de Sistemas y Balance · **Última actualización:** 08/10/2026
> **Sincronizado con:** `00_Vision.md` v1.3 · `Mundo.md` v1.0 · `Arquitectura.md` v0.34 · `docs/PREGUNTAS.md` y `docs/RESUMENES.md` al cierre de T21. La v1.7 aplica la **escala ×10 de vida y daño** (A-3; tabla en 11.1): todos los valores de vida, daño y curación de este documento están ya multiplicados por 10 respecto de la v1.6; porcentajes, maná, hambre, lealtad, movimiento, alcance y velocidad no cambian. Responde además P-030 (coordenadas de 12 × 12 aprobadas, 11.9), P-031 a P-033 (Secundar, 10.1 y 11.3), P-034 a P-036 (incidente, 10.2 y 10.4), P-038 a P-040 (Encono y cobardía, 10.5 y 10.6) y S-41 a S-44 (salvajes en el chequeo de rival, 10.5 y 10.6; Famélico en combate, 2.2). La v1.6 sincroniza con la Visión v1.3 (geometría y tablero): qué reglas miran las **4 casillas ortogonales** y cuáles las **8 vecinas** (11.3); afinidad, incidente y cobardía con vecinas en 8, **sin cambiar sus números** (10.3, 10.4, 10.6); incidente con la rival en diagonal (10.4); tablero de **12 × 12** con contacto en la ronda 2 y criterios de despliegue (11.3, 11.9); hambre de combate **cada 6 rondas** (7.2); métricas 1 y 13 contadas desde el primer ataque (11.9); respuestas a P-026 y P-027 (11.8). La v1.5 sincroniza con la Visión v1.2: la atacante que se va si cae el Maestro (9.2, 9.3, 11.5) y su registro en el epílogo (13), la prenda sin consecuencias (3.3) y los playtests sin encuesta (11.9); además, suma lo que mide el hito 0a.1b (11.9) y pone al día los pendientes (15). La v1.4 responde las lecturas declaradas S-21 a S-26 y la P-024 (S-20) del Arquitecto, y cierra las preguntas de `Mundo.md` 9.1 (confianza, golondrinas, aviso al comer y solo se come a una suelta). La v1.3 cierra los números de los rasgos reescritos tras el playtest 0a.1 (Visión 6.2) en una sola pasada de balance: el surco, Hacerse junco y Caza y cuenta (11.2.1 a 11.2.3), y la IA del Tasajero (11.8).
> Este documento baja a números lo definido en `00_Vision.md`. Si algo acá contradice la Visión, manda la Visión: se propone el cambio y se registra en `Decisiones.md`.
> Los nombres del juego (Arrimo, Encono, Secundar, péñola, prenda, Urdimbre, "lo que diste", Erizarse, Alabarda, Hacerse junco, Caza y cuenta, Martillazo, Lanzadera, Remiendo, Leña en las púas, Sueño liviano, Madriguera, Acecho, Poza Tibia, quebranto, Menestral, las rayas y las golondrinas) son finales y viven en `Mundo.md` (1.2, 2.8, 2.9, 4.5, 4.7, 4.9 y 4.10). Los marcados como *(provisorio)* esperan la confirmación del Worldbuilder: en la v1.3, **el surco** del Surcón y el estado **oculto** del Zancajunco.

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
| **Poder mágico** | Daño/curación de los hechizos = 10 × (base del hechizo + Poder) (1.6). Poder no escala: sigue de 1 a 3 | 1 | ¿Invierto en pelear con magia o en sostener al grupo? |
| **Regeneración de maná** | Maná por turno en combate = valor del atributo | 1 | ¿Aguanto combates largos o juego a ráfagas? |

**Balanza inicial:** la clase del MVP arranca en la **posición 2** (inclinada al Barro). El MVP enseña primero la tribu.

### 1.2 Tabla de la balanza — `DECIDIDO`

| Posición | Reserva de maná | Descuento sellar/invocar | Rango máx. sellable | Vida máxima real | Daño cuerpo a cuerpo | Umbral de rescate | Lealtad por día alimentada | Ajuste a la lealtad inicial | Pasos de Arrimo |
|---|---|---|---|---|---|---|---|---|---|
| 1 (Barro) | 7 | — | 1 | 220 | 50 | 6 | +1 por día | — | 4 |
| 2 | 8 | — | 2 | 200 | 40 | 7 | +1 por día | — | 3 |
| 3 | 9 | −1 | 2 | 180 | 40 | 7 | +1 por día | −1 | 2 |
| 4 | 10 | −1 | 3 | 160 | 30 | 8 | +1 cada 2 días | −1 | 1 |
| 5 (Soplo) | 11 | −2 | 3 | 140 | 30 | 8 | +1 cada 2 días | −2 | 0 |

**Fórmulas:**
- Reserva = **6 + posición**
- Vida máxima real = **240 − 20 × posición** (ver 7.8)
- Daño cuerpo a cuerpo = **10 × (5 − ⌊posición ÷ 2⌋)**
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
| **Martillazo** (básico) | 2 | Distancia Manhattan ≤ 3, sin bloqueo | Daño **10 × (2 + Poder)** (30 al inicio) | Sí | ¿Pego 40 cuerpo a cuerpo gratis o 30 a distancia con el maná del sellado? |
| **Lanzadera** (básico) | 2 | Línea recta ≤ 2; no atraviesa enemigas | Empuja o atrae **1 casilla** a una unidad que no esté caída. Si la casilla está ocupada o fuera del tablero, no se mueve y recibe 10 de daño | No | Separar rivales aliadas, juntar rivales salvajes, sacar a la Rodauva del alcance del Tasajero |
| **Remiendo** (fuerte) | 4 | Adyacente (4 ortogonales, 11.3) o sí mismo | Cura **10 × (3 + Poder)** (40 al inicio). **No afecta a las caídas** (11.5) | Sí | ¿Media reserva para sostener a una aliada o para sellar? |

**Reglas comunes:**
- Lanzar un hechizo gasta la **acción** del Maestro; conserva su movimiento.
- El Martillazo es un ataque: cuenta como eslabón de combo y le aplican Saciado, enfermedades y afinidad (11.4). Su daño exacto lo vuelve la **mano fina para sellar**.
- La Lanzadera no es un ataque: no suma eslabón ni corta la cadena.

**Lanzadera: casos borde** — `DECIDIDO` (03/10/2026):

| Caso | Regla | Decisión que genera |
|---|---|---|
| Daño del choque | **10 fijo**, sin modificadores. Solo lo recibe la unidad movida, no la que ocupa la casilla | — |
| ¿Es un ataque? | No: no suma Encono, no cuenta como golpe a la rival, no le quita el bono de Hacerse junco a una destapada y no corta la cadena | — |
| ¿Puede tumbar? | Sí. Una salvaje en 0 huye y se pierde la captura (11.5); una aliada queda caída | Empujar contra una pared a una salvaje con 10 de vida o menos es perderla |
| Atraer a una unidad adyacente al Maestro | Objetivo no válido | — |
| Unidad erizada | **Se puede mover**: Erizarse le impide moverse sola, no que la muevan. Conserva el −50% | Sacar a la Rodauva erizada del alcance del Tasajero sigue siendo posible |
| Unidad oculta (Hacerse junco, 11.2.2) | **Objetivo no válido**, como para el Martillazo. Si la Lanzadera deja a una enemiga de pie adyacente a una oculta, la destapa | Destapar al Zancajunco salvaje acercándole una unidad |
| Destino en un surco (11.2.1) | Cuenta como **casilla ocupada**: no se mueve y recibe 10. A un Surcón sí lo mueve | Empujar contra un surco es empujar contra una pared |
- Sin descuento de la balanza (2.3). No se usan fuera del combate (2.5).

**Identidad del Soplo:** con la balanza en 5 y Poder 3, el Maestro pega 30 cuerpo a cuerpo y 50 con el Martillazo: un mago de distancia con reserva grande.

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

**Famélico en combate** — `DECIDIDO` (08/10/2026, responde S-44): solo corta la regeneración; **no le quita el maná que ya tiene**. El "sin maná" de 7.1 lo produce el sueño, que con Famélico recupera 0: en la 0b el Maestro famélico entra al combate con lo que le haya quedado. En la 0a, `mana_entrada: null` es la reserva completa sea cual sea su hambre.

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
| Invocar en combate | Gasta el turno completo del Maestro. La criatura aparece en una **casilla libre adyacente** al Maestro (4 ortogonales, 11.3); si no hay ninguna, no se puede invocar | Conviene tener criaturas sueltas antes del combate, pero eso cuesta comida. Un Maestro rodeado no recibe refuerzos |
| Guardar fuera de combate | Gratis | — |
| Guardar en combate | Cuesta la acción de la criatura y exige que esté adyacente al Maestro (4 ortogonales) | ¿La salvo o la dejo pelear un turno más? |
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
| Prenda | El Maestro o cualquier criatura suelta, **sin diferencia mecánica**. No tiene consecuencias en el MVP y no se registra para el epílogo (Visión 10 y 11, v1.2: el epílogo que la nombra queda en Ideas en espera) | Siempre disponible |
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
| Debilidad ("lo que diste") | **−40 de vida máxima durante 3 días**. Si la vida actual supera el nuevo máximo, se recorta. **No es un estado:** se muestra como un tramo marcado en la barra de vida, con su contador de días |
| Acumulación | Cada ritual tiene su propio contador de debilidad; se acumulan. El daño no se achica por rituales recientes |

**Restricciones:**
- **El ritual nunca mata:** exige vida actual **mayor** que el daño (con balanza 2: vida 51 o más).
- No se puede hacer **famélico**.
- Máximo **1 ritual por día**.

**Ejemplo (balanza 2, dos rituales en días seguidos, sin curación en el medio):**

| | Vida actual | Vida máxima vigente |
|---|---|---|
| Inicio | 200 | 200 |
| Ritual 1 | 150 | 160 |
| Ritual 2 | 100 | 120 |

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
| Completa, sin pergamino en blanco | **El olvido corre igual** (05/10/2026, responde `Mundo.md` 9.1): alimentarla mantiene la confianza en el máximo; cada día sin ración resta 1 | Hacer el ritual o seguir pagando una ración por día para no perderla |
| Etapas visibles (`Mundo.md` 4.14) | **"A mitad de camino":** confianza ≥ la mitad de la necesaria, redondeando hacia arriba. **"Falta poco":** una ración favorita la completa (le faltan 2 o menos). Se muestra la etapa más alta alcanzada, aunque se salte una (05/10/2026) | El jugador sabe cuánto le falta sin ver el número |
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
| ≥ umbral de rescate | Afín: +10 de daño mutuo y combo de afines | −10 puntos | −20 puntos | Se distrae |
| 4 hasta umbral − 1 | Sin relación | Normal | Normal | Se distrae |
| ≤ 3 | Sin relación | +10 puntos | +20 puntos | **Ataca a la rival** si la alcanza desde su casilla; si no, se distrae (10.4) |

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
| Secuela | **−10 de vida máxima real por día** (al cerrar el día, paso 7 de 7.9), mínimo 10 | ¿Voy directo a la Poza o junto comida antes? |
| Permanencia | Lo perdido **no vuelve**: la vida máxima real queda reducida. Todos los porcentajes de vida se calculan sobre el nuevo valor (7.8) | La tardanza se paga para siempre |
| Cura | Bañarse en la **Poza Tibia** (Vado) devuelve la regeneración | — |
| Si nunca va | Termina con 10 de vida máxima | — |

**El quebranto no es un estado negativo**: es una marca en la barra de vida con su contador, como "lo que diste".

**Distancia:** Molino → Huertos → Vado son 2 días. Con la balanza en 2, en el mejor caso pierde **10 puntos** (cierra un día en los Huertos y se baña al llegar al Vado, antes del cierre): queda con 190 de vida máxima real.

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
| 9–10 | Famélico | Sin maná (2.2; en combate conserva el que tiene, S-44) · Obediencia −4 · Puede comer comida rechazada · Abandono nocturno (9.1) · Pierde vida al dormir (7.6) · No puede hacer el ritual (3.3) |

**Saciado no es un valor aparte:** se deriva del hambre (0–2). En la Prueba 0a, el escenario fija el hambre de cada unidad y el estado sale de esta tabla (responde S-6).

### 7.2 Cuánto sube — `DECIDIDO`

| Fuente | Cantidad | Decisión que genera |
|---|---|---|
| Fin del día (al dormir) | Según el apetito (7.3) | ¿Cuántas bocas puedo sostener afuera? |
| Combate | +1 al cerrar las rondas **6, 12, 18…**, al Maestro y a **toda criatura de la tribu en el tablero, de pie o caída**. No alcanza a las guardadas (tampoco a la caída que se guardó), a las salvajes ni a la atacante nocturna. La obediencia, la regeneración y el estado de hambre se recalculan en el acto | Cerrar rápido o arriesgarse: una leal puede pasar a Hambrienta en pleno combate. Guardar a una caída también la saca del reloj |
| Descanso para curarse | El hambre sigue subiendo normalmente (solo se toma agua) | Ver 8.3 |

**Cada 6 rondas** — `DECIDIDO` (07/10/2026; antes, cada 5): con el tablero de 12 × 12, la ronda 1 es de acercamiento (11.3), y la Visión pide que el tablero grande no cobre hambre por caminar. Seis rondas equivalen a las cinco de pelea de antes. Es un dato (`tablas/hambre.json`, `combate.cada_rondas`: 5 → 6), sin cambio de código. **Alternativa descartada:** contar desde el primer ataque; es más exacto, pero exige programar un contador nuevo.

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

| Regla | Valor | Decisión que genera |
|---|---|---|
| Aviso de rescatistas | `DECIDIDO` (05/10/2026, responde `Mundo.md` 9.1; Visión 8): antes de confirmar, la interfaz lista las criaturas que **dejan de poder rescatar** al Maestro con la lealtad resultante (−2 / −4 y −3), incluida la comida si era rescatista. Mismo aviso que al mover la balanza (1.2) | La decisión más dura se toma sabiendo quién deja de salvarte |
| Solo sueltas | `DECIDIDO` (05/10/2026, opción B): **no se come a una guardada**. Solo se come a una criatura **suelta** en el reparto. Para comer a una guardada hay que invocarla antes, con el costo normal (2.5). Un Maestro sin maná no puede sacarla: el pergamino protege a la que duerme | El pergamino no es una despensa (Visión 6.7: los pergaminos nunca son un recurso de supervivencia) |

**Decisión que genera:** nunca rinde como comida; solo como supervivencia.

### 7.8 Vida y curación — `DECIDIDO`

**Vida máxima real y vigente:**
- **Vida máxima real:** la del Maestro = 240 − 20 × posición de la balanza. La de las criaturas está en su ficha (11.2).
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

**Referencia con la balanza 2:** una noche bien comida cura 50 puntos; una herida de media vida tarda 2 noches.

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
- Redondeo hacia abajo. El daño nunca baja de 10 (11.4); la recolección **puede dar 0**.
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

1. La criatura golpea primero: **un ataque normal** contra el Maestro, con la fórmula de 11.4 (aplican sus rasgos de característica, como la Alabarda; la atacante no llega oculta, así que Hacerse junco no suma; como toda enemiga, no recibe Saciado ni enfermedades; no hay combo y no suma Encono). Con una Ocarra atacante son 40 de daño. No ocurre si hay una Ocarra suelta que no sea la atacante (Centinela, 12.6), **tenga la lealtad que tenga**. **Si el golpe deja al Maestro en 0**, el combate termina por caída antes de la ronda 1 y rige el paso 6 (responde S-10).
2. Empieza un **combate donde se duerme**: el Molino o el campamento al raso (9.4). **Solo las leales defienden al Maestro** (ver "Quién defiende", abajo); las demás sueltas miran.
3. Durante el combate, la atacante se trata como **salvaje**: obediencia ≤ 3 y sin Arrimo (10.7).
4. El Maestro pelea con el maná del sueño interrumpido (2.4).
5. A diferencia de una salvaje, la atacante **no huye** al llegar a 0 de vida: queda **caída** y el Maestro decide su destino (9.3).
6. Si el Maestro cae en este combate, rige 11.5: si hay rescatista, el Maestro queda en recuperación (ya está en el Molino); las caídas de la tribu mueren y **la atacante se va** (su pergamino arde y vuelve a ser salvaje, como en un abandono), **también si ya estaba caída**: su destino no queda pendiente (05/10/2026, responde P-024 = S-20; confirmado por la Visión 6.4 v1.2). **Su ida no cambia la lealtad de nadie**: nadie decidió nada. El resto de la derrota se aplica igual: las caídas que mueren (−2 / −4, 5.2) y el +2 de la rescatista. En el epílogo se registra como **abandono** (13). Sin rescatista, permadeath. *En el MVP el caso de la atacante caída en una derrota no ocurre: es la única enemiga y, si cae, se gana. La regla se programa igual, para la 0b.*

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

**Peor caso (balanza 2):** el Maestro solo, con 160 de vida tras el golpe inicial, contra una Ocarra atacante (120 de vida, 40 de daño). Necesita 3 golpes; ella le saca unos 120 en ese tiempo. Sobrevive con poco margen y casi sin maná para sellarla. Duro, pero no es una muerte automática (riesgo en 14).

### 9.3 Destino de la atacante derrotada — `DECIDIDO`

Queda **caída** y el Maestro elige. En las tres salidas, **su pergamino arde**. Si el Maestro cae antes de elegir, no hay elección: la atacante se va (9.2, paso 6).

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

**Geometría (v1.6, Visión v1.3):** las relaciones de esta sección (afinidad, incidente y sostén de la cobardía) miran las **8 vecinas**, diagonales incluidas. Moverse, atacar y guardar miran las **4 ortogonales**. Los combos **no miran la posición**. Tabla completa en 11.3.

### 10.1 Iniciativa y Secundar — `DECIDIDO`

| Regla | Valor | Decisión que genera |
|---|---|---|
| Orden | Cada unidad actúa según su **Velocidad**, sin azar (reglas completas en 11.3) | — |
| Secundar | La unidad actúa justo después de un aliado elegido que todavía no actuó en la ronda | Armar la cadena a mano |
| Costo de Secundar | Ninguno explícito: los enemigos que estaban en el medio actúan antes | ¿Combo seguro más tarde o golpe inmediato? |
| Restricciones | No puede Secundar una unidad enconada ni una acobardada. No se puede Secundar más allá del final de la ronda. **Las salvajes no Secundan** | La furia y el miedo rompen la coordinación; la coordinación es ventaja de la tribu |
| Cuándo se declara | Solo con el turno **sin usar**: sin haberse movido ni usado la acción. Secundar aplaza el turno entero, no lo parte (08/10/2026, responde P-031) | Se decide antes de moverse: ¿actúo ya o espero a la aliada? |
| Volver a Secundar | Al volver, puede Secundar otra vez si queda otra aliada pendiente detrás. La entrada siempre avanza en la cola, así que la ronda termina (08/10/2026, responde P-032) | Encadenar a mano cuesta entregarles más turnos a las enemigas del medio |
| Al volver | El turno sigue donde quedó: el inicio del turno (11.3), el borrado de Erizarse y el cambio de modo corren **una vez por ronda**, la primera vez que le toca (08/10/2026, responde P-033) | Secundar no sirve para volver a tirar un chequeo ni para sumar maná |

### 10.2 Combos: ataque en cadena — `DECIDIDO`

Cuando aliados atacan **de forma consecutiva** al **mismo objetivo**, cada golpe desde el segundo suma un bono. **El combo no mira la posición:** dos afines encadenan como afines aunque estén lejos entre sí (Visión v1.3; S-28).

| La cadena se corta si… | No la corta… |
|---|---|
| Actúa una enemiga (incluido el turno del Tasajero) | Una acción aliada que no es ataque: moverse, Lanzadera, Remiendo, Erizarse, Hacerse junco, cavar un surco, guardar, Secundar, esperar (terminar el turno sin usar la acción **es** esperar, 11.3) |
| Un aliado ataca a otro objetivo (incluido el golpe de un incidente) | — |
| **Se cierra la ronda** (03/10/2026): la cadena nunca pasa a la ronda siguiente, aunque no quede ninguna enemiga por actuar | — |
| El objetivo sale del tablero (huye, es sellado) | — |

**El golpe de un incidente** — `DECIDIDO` (08/10/2026, responde P-035): corta la cadena que había, **no empieza otra** sobre la aliada golpeada y no recibe bono de combo. Un segundo incidente sobre la misma compañera no suma combo contra ella.

| Par que encadena | Bono base | + Arrimo |
|---|---|---|
| Sin relación | +20% | +10 por paso |
| Afines (incluye Maestro + criatura con obediencia leal) | +40% | +10 por paso |

**Cada eslabón vale la mitad que el anterior**, sin tope. Ejemplo entre afines con balanza 2 (+70%):

| Eslabón | 2 | 3 | 4 | 5 |
|---|---|---|---|---|
| Bono | +70% | +35% | +17% | +8% |

Con la escala ×10 (v1.7) cada eslabón suma lo que dice, también el 4 y el 5 (con daño 40: 68 / 54 / 46 / 43). Antes, con daños de 2 a 5, el tope real quedaba en 3 o 4 eslabones. La regla de la mitad no cambia (08/10/2026).

**Decisión que genera:** el orden en que actúan tus unidades importa tanto como dónde están.

### 10.3 Afinidad entre vecinas — `DECIDIDO`

Una unidad **vecina** de una afín (cualquiera de las **8 casillas** alrededor, diagonales incluidas) suma **+10 de daño plano**, como máximo +10 por ataque aunque tenga varias afines vecinas. Se mira la posición del atacante al golpear. El Maestro es afín de toda criatura con obediencia ≥ umbral de rescate (y viceversa).

**Con vecinas en 8 el número no cambia** — `DECIDIDO` (07/10/2026, responde la pregunta de la Visión 11): el tope de un bono por ataque ya impide acumular. Lo que sube es la **frecuencia**, que es lo buscado: dos aliadas que rodean por los lados a la misma objetivo quedan en diagonal entre sí y ahora se potencian (Visión 6.4). Efecto en C: unos 30 o 40 de daño más por ronda (⚠️ 14). Con la escala ×10 (v1.7) el bono queda en +10; si los playtests piden afinarlo, ahora existe el +5, que antes no era posible.

**Decisión que genera:** rodear a una objetivo potencia a la tribu, pero deja esquinas abiertas al Tasajero (11.2.3); el bloque protege, pero llega con menos golpes. El Maestro en el frente potencia a la tribu, pero se expone.

### 10.4 Rivalidad entre aliadas: incidente — `DECIDIDO`

Una criatura **vecina** (8 casillas) de una rival aliada tiene **20% de incidente** al **inicio de su turno** (−5 puntos por paso de Arrimo). El resultado depende de su obediencia (5.4): **≥ 4 se distrae y pierde la acción; ≤ 3 usa la acción para golpear a la rival, si la alcanza desde su casilla**. En ambos casos **conserva el movimiento**: la distraída todavía se puede alejar. La probabilidad se muestra en la casilla antes de mover, el turno anterior.

**Precisiones** — `DECIDIDO` (03/10/2026):
- **Una sola tirada por turno**, aunque tenga varias rivales aliadas vecinas: amontonarlas no multiplica el riesgo. Con obediencia ≤ 3 golpea a la rival de **menos vida actual** entre las que alcanza; si empatan, a la primera en el orden de la tribu.
- **Una criatura enconada no tira incidente** ese turno: la furia la enfoca en la rival enemiga (orden del inicio del turno en 11.3). Motivo: la enconada ya perdió el control; cobrarle dos veces la misma pérdida no genera una decisión nueva.
- *Palanca en reserva:* una tirada por rival vecina castigaría más a una tribu de Ocarras (14). Solo si esa tribu domina en los tests.

**Con vecinas en 8** — `DECIDIDO` (07/10/2026):
- **El 20% no cambia.** Con una sola tirada por turno, más rivales vecinas no multiplican el riesgo: solo sube la chance de tener alguna al lado. Eso además mitiga el riesgo de incidentes casi invisibles con la balanza 2 (14).
- **La rival en diagonal:** con obediencia ≤ 3, golpea a la rival solo **si la alcanza desde su casilla**, sin moverse y con su alcance normal (el ataque es ortogonal; la Alabarda pega en línea recta). Si ninguna rival vecina está a su alcance, **se distrae** y pierde la acción, como la obediente. **Alternativa descartada:** que se mueva para pegarle, como la enconada; suma una decisión forzada nueva y más código en T18.

**Más casos** — `DECIDIDO` (08/10/2026):
- **Rival oculta** (responde P-034): una rival aliada oculta (11.2.2) **provoca la tirada**, pero no puede recibir el golpe. Si es la única rival a su alcance, la criatura se distrae. Esconder al Zancajunco no lo saca de la rivalidad.
- **"La acción" son todos los ataques del turno** (responde P-036): un Tasajero de la tribu en Caza con incidente pierde sus dos ataques si se distrae, y si golpea a la rival, ese golpe gasta los dos.
- **Acobardada:** el golpe del incidente también lleva el −50% (10.6; responde P-039).
- **Golpe y cadena:** ver 10.2 (P-035).

**Decisión que genera:** juntar rivales es un riesgo chico con una tribu leal y bien alimentada, y un peligro con una hambrienta.

### 10.5 Rival enemiga: Encono — `DECIDIDO`

Aplica a las criaturas **de combate y mixtas**. Las de trabajo usan la cobardía (10.6).

| Regla | Valor | Decisión que genera |
|---|---|---|
| Contador | Encono de 0 a 3 por criatura. El Tasajero, con un solo turno por ronda desde la v1.3, se chequea **una vez por ronda**, como todas | — |
| Enconarse | Al inicio de su turno, con una rival enemiga **a su alcance** (distancia Manhattan ≤ Movimiento + Alcance; misma definición para la cobardía): 25% + 25% por punto · −5 por paso de Arrimo · ±10 según obediencia (5.4) | El jugador ve la probabilidad antes de acercarla |
| Enconada | Su acción queda fijada en atacar a esa rival, con **+10 de daño por punto, contando el punto que suma ese golpe** (máximo +30). **El jugador elige la casilla** (y la rival, si hay varias). Si no llega, se acerca lo más posible y pierde la acción | Usarla como cazadora de su rival a cambio de perder el control del objetivo, no de la posición |
| Cada golpe a la rival | +1 de Encono (máx. 3), **esté enconada o no**: también suman los golpes voluntarios. Con 3, queda enconada seguro | Pegarle a la rival a propósito acerca el Encono: cuanto más pega, más se ensaña |
| Orden del golpe enconado | Primero sube el contador; después se calcula el daño con el valor nuevo. Los golpes voluntarios (sin estar enconada) suben el contador, pero **no tienen bono** | — |
| Remate | La enconada puede dejar a su rival en 0. Si es una salvaje, huye y se pierde la captura | ¿Llevo a la Ocarra contra un Zancajunco que quiero sellar? ¿La alejo con la Lanzadera antes de que actúe? |
| Fin del combate | El Encono vuelve a 0 | — |

**Salvaje enconada con varias rivales a su alcance** — `DECIDIDO` (03/10/2026): elige con la lista de la IA (11.8): la que **puede tumbar**; si no, la de **menos vida actual**; si empatan, la **más cercana**; después, la que actúa antes en la cola. Así el Tasajero va por la Rodauva (80 de vida) antes que por la Ocarra (120). **Si no la alcanza** (08/10/2026, confirma S-43): se mueve a una de las casillas de menor distancia a su rival que el turno permite y, entre ellas, desempata por orden de lectura, como Acercarse.

**Ejemplo:** la Ocarra (daño 40) enconada contra su rival, golpes seguidos: **50 / 60 / 70 / 70**. Cada Encono da fuerza desde el primero (Visión 6.4: "ganando fuerza y perdiendo control").

**Alternativas descartadas:** el valor del contador antes del golpe (el primer Encono sería pura pérdida de control), el bono en cualquier golpe a la rival (estrategia dominante: cargar el contador a propósito y cobrar la fuerza sin pagar con el control) y +20 plano (pierde el ensañamiento creciente).

**Rival oculta** — `DECIDIDO` (05/10/2026): un Zancajunco **oculto** (11.2.2) no cuenta como rival a su alcance para el Encono ni para la cobardía (10.6), y no puede ser la rival elegida. El que ya se destapó cuenta normalmente.

**Tasajero enconado en Caza** — `DECIDIDO` (05/10/2026): el **primero** de sus dos ataques va a la rival; el segundo sigue la IA de Caza (11.8, paso 6b). El ensañamiento le quita el control de un golpe, no de los dos. **Casilla** (08/10/2026, confirma S-42): primero elige la rival (desempates de arriba); la casilla, entre las que la golpean, con la clave del paso 6b; el segundo ataque va a otra presa adyacente de menos vida y, si no hay otra, a la rival.

**Casillas de la enconada** — `DECIDIDO` (08/10/2026, responde P-038, opción A): la enconada que alcanza a su rival solo puede moverse a casillas desde donde la golpea, y esa restricción **dura todo el turno**, también después del primer golpe. Las obligaciones de atacar a la rival y de no terminar sin atacarla se cumplen con ese primer golpe. Consecuencia: un Tasajero enconado en Cuenta solo se retira a casillas desde donde sigue golpeando a su rival, así que casi nunca se retira. **Decisión que genera:** acercarle su rival al Tasajero en Cuenta le quita la retirada ("pica y se va" se vuelve "pica y se queda"); con la tribu pasa lo mismo: la Ocarra enconada no puede pegar y salir de la zona de Caza. ⚠️ 14.

### 10.6 Rival enemiga: cobardía — `DECIDIDO`

Aplica a las criaturas **de trabajo**. Se chequea con el mismo disparador que el Encono: al inicio de su turno, con una rival enemiga a su alcance.

**Probabilidad de acobardarse:**

| Factor | Modificador |
|---|---|
| Base | 60% |
| Arrimo | −5 puntos por paso |
| Obediencia leal (≥ umbral) | −20 puntos |
| Obediencia ≤ 3 | +20 puntos |
| El Maestro es **vecino** (8 casillas) | −10 puntos. **Solo a su tribu** |

**El Maestro vecino en 8** — `DECIDIDO` (07/10/2026): es sostén, como el de las afines del toggle, y la Visión v1.3 pone el sostén de la cobardía en las 8 vecinas. Si quedara en 4, el Maestro en diagonal sostendría como afín pero no como Maestro. **Solo a su tribu** (08/10/2026, confirma S-41): una salvaje junto al Maestro enemigo no recibe el −10.

| Balanza | Leal + Maestro al lado | Leal | Neutral | Obediencia ≤ 3 |
|---|---|---|---|---|
| 1 (Barro) | 10% | 20% | 40% | 60% |
| 2 (inicial) | 15% | 25% | 45% | 65% |
| 5 (Soplo) | 30% | 40% | 60% | 80% |

**Acobardada** (dura ese turno; no tiene contador):
- −50% de daño en **todos sus ataques del turno**, incluido el golpe de un incidente (se suma con los otros porcentajes, 8.4; daño mínimo 10; P-039).
- No puede terminar su movimiento más cerca de la rival que donde empezó.
- No puede Secundar.
- Conserva el turno: puede moverse, atacar a otro objetivo, encadenar combos o ser guardada.

**Decisión que genera:** ¿pongo al Maestro junto a la criatura asustada para sostenerla, sabiendo que eso lo expone?

> `PROPUESTA` a testear (toggle en el escenario E de la Prueba 0a, 11.9): cada afín **vecina** (8 casillas) resta **−10 puntos** a la cobardía (máximo −20), con un **mínimo de 5%**. Ejemplo: Rodauva leal con la balanza en 2, junto a dos Rodauvas: 25% → 5%. Anticipa la barra de zozobra. Si se aprueba, también alcanza a las salvajes (10.7). **El Maestro no cuenta como afín vecina** para este toggle: ya tiene su −10 propio (`DECIDIDO` 03/10/2026, responde P-008). Así quedan dos herramientas separadas: sostener con el Maestro o sostener con la manada. **Con vecinas en 8 los números no cambian** (07/10/2026): llegar a −20 se vuelve más fácil, y el escenario E lo mide.
>
> **Piso del toggle** — `DECIDIDO` (08/10/2026, responde P-040): las afines no pueden bajar la cobardía por debajo de 5%, pero el piso **tampoco la sube**. Prender el toggle nunca empeora a nadie:
> `cobardía = max(sin_afines − afines, min(sin_afines, 5))`
> Sin afines vecinas, el resultado es el mismo que sin el toggle. Con los números de hoy no cambia ningún caso.

### 10.7 Criaturas salvajes — `DECIDIDO`

Siguen las mismas reglas de relación: afinidad, rivalidad, Encono y cobardía, con las **8 vecinas**. No tienen lealtad: se tratan como **obediencia ≤ 3** y sin Arrimo. Si ocurre un incidente, siempre se atacan entre ellas (si se alcanzan desde su casilla, 10.4). El −10 del Maestro vecino en la cobardía no las alcanza (10.6, S-41).

| Regla | Valor |
|---|---|
| Afinidad | +10 plano entre salvajes afines vecinas (10.3). **La afinidad solo existe dentro del mismo bando**: una Rodauva de la tribu junto a una Rodauva salvaje no suma nada |
| Combos | **No encadenan**: sus ataques consecutivos no suman bono. La cadena es algo que solo da el vínculo con el Maestro (Visión 6.4). Sus turnos sí cortan las cadenas de la tribu (10.2) |
| Impacto en el MVP | El único par afín salvaje posible es Rodauva–Rodauva (Huertos, 15%): pasan de 20 a 30 de daño |

**Decisión que genera:** atraer a una Ocarra salvaje hacia un Zancajunco salvaje es una táctica legítima; separar a dos Rodauvas salvajes con la Lanzadera les quita la afinidad (ahora hay que dejarlas a 2 casillas o más, también en diagonal).

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

Valores iniciales de test (sesión del 01/10/2026; escala ×10 desde el 08/10/2026). Los rasgos de combate están aprobados (Visión v0.7).

### 11.1 Estadísticas — `DECIDIDO`

| Estadística | Qué controla | Decisión que genera |
|---|---|---|
| **Vida** | Golpes que aguanta | ¿A quién expongo en el frente? |
| **Daño** | Daño base por ataque | ¿Quién remata y quién debilita para sellar? |
| **Movimiento** | Casillas por turno, solo ortogonales | ¿Llego a la afín o me quedo cubriendo? |
| **Alcance** | 1 = adyacente · 2 = en línea recta | Formar en dos filas |
| **Velocidad** | Orden en la ronda | Armar cadenas sin necesidad de Secundar |

**No hay Defensa en el MVP.** Con daños de 20 a 50, una defensa plana de 10 cambia el resultado entre un 20% y un 50%: es demasiado sensible para tenerla en todas las unidades. La dureza se expresa con la vida, con rasgos puntuales (Erizarse) y con el surco, que cierra el paso (11.2.1).

**Escala de vida y daño ×10** — `DECIDIDO` (08/10/2026, responde A-3 de `Arquitectura.md` 10.5): con daños de 2 a 5, los porcentajes chicos se perdían al redondear (el eslabón 4 no sumaba con daño 4, Saciado no le servía a la Rodauva y una enfermedad le sacaba la mitad del daño). Con todo ×10, cada porcentaje vale lo que dice.

| Escala ×10 | No escala |
|---|---|
| Vida de las fichas y del Maestro (balanza: `240 − 20 × posición`) | Porcentajes (combo, Saciado, enfermedades, Erizarse, Caza, cobardía, sellado, huida, umbrales de vida) |
| Daño de las fichas y del Maestro (balanza: `10 × (5 − ⌊posición ÷ 2⌋)`) | Hambre, lealtad, obediencia, Encono (el contador de 0 a 3) |
| Planos: afinidad +10, Encono +10 por punto, Hacerse junco +30, Cuenta −10, choque de la Lanzadera 10 | Maná, costos, Regeneración y Poder (sigue de 1 a 3) |
| Martillazo `10 × (2 + Poder)` y Remiendo `10 × (3 + Poder)` | Movimiento, alcance, velocidad, distancias |
| Daño mínimo **10**; vida al levantarse y al guardar una caída **10** | Los "mínimo 1 de vida" que significan "no mata" (ritual, río) y los mínimos de las curas por porcentaje (7.8, 6.2, 7.6) |
| Debilidad del ritual −40; quebranto −10 por día (mínimo 10) | El bono del combo por eslabón (la mitad del anterior, sin cambios) |

**Decisión que genera:** ninguna nueva; hace que las existentes (Saciado, cadenas largas, enfermedades) pesen lo que dicen. ⚠️ Los combos y Saciado pegan un poco más: en la primera ronda de pelea de C, cerca de +9% de daño al Tasajero (14).

### 11.2 Fichas — `DECIDIDO`

| Unidad | Rol | Rango | Vida | Daño | Mov | Alc | Vel | Rasgo |
|---|---|---|---|---|---|---|---|---|
| **Maestro** (balanza 2) | — | — | 200 | 40 | 3 | 1 | 5 | Magia: Martillazo, Lanzadera, Remiendo (1.6) |
| **Rodauva** | Trabajo | 1 | 80 | 20 | 4 | 1 | 6 | **Erizarse** (acción): hasta su próximo turno recibe −50% de daño y no se mueve. Cierra el movimiento que le quede: puede moverse y después erizarse, no al revés |
| **Surcón** | Trabajo | 2 | **240** | 30 | 2 | 1 | 2 | **El surco** *(provisorio)* (activa): cava un surco en una casilla adyacente; solo un Surcón lo pisa. Gasta el turno completo (11.2.1). Reemplaza a Lomo de tierra |
| **Ocarra** | Combate | 1 | 120 | 40 | 3 | **2** | 7 | **Alabarda**: su alcance 2 es el rasgo |
| **Zancajunco** | Mixto | 2 | 120 | 40 | 4 | 1 | 8 | **Hacerse junco** (activa): queda **oculto** (no se lo puede elegir como objetivo) y su próximo ataque suma **+30**. No dos turnos seguidos (11.2.2) |
| **Tasajero** | Combate | 3 | 300 | **50** | 4 | 1 | **8 en Caza · 3 en Cuenta** | **Caza y cuenta**: **un turno por ronda** en dos modos. Caza: dos ataques de 50 y recibe +25%. Cuenta: un ataque con −10 y movimiento partido. Pasa a Cuenta una sola vez (11.2.3) |

La vida y el daño del Maestro siguen la balanza (tabla 1.2). Su Movimiento, Alcance y Velocidad no dependen de ella. **En la 0a ningún estado los modifica** (hambre, enfermedad, quebranto): la Velocidad del Maestro es siempre la de su ficha y entra en la cola en todas las rondas (`DECIDIDO` 04/10/2026, responde P-013).

**Motivo de cada valor:**

| Unidad | Por qué |
|---|---|
| Maestro | Pega lo mismo que la Ocarra: el Maestro también pelea (Pilar 1) |
| Rodauva | Frágil. Su daño de 20 la vuelve la **mano fina para sellar**: baja a una salvaje al tramo ≤ 25% sin hacerla huir. Salvaje y erizada, debilitarla cuesta mucho: conviene domesticarla |
| Surcón | El Maestro necesita 6 golpes para debilitarlo (240 ÷ 40): la vida compensa la pérdida de Lomo de tierra (05/10/2026). Ya no es un muro que aguanta golpes, sino uno que **cierra el paso**: se para detrás de su surco |
| Ocarra | Ataca primero (temperamento). Desde atrás del Maestro queda vecina de él: la formación natural refuerza la regla de oro |
| Zancajunco | "Si ataca, lo hace primero y rápido". Desde el juncal, el golpe sale de la quietud |
| Tasajero | Un solo turno por ronda (Visión 6.2 v1.1), pero con **dos ataques en Caza**: el jefe no pierde por número de acciones. En Caza abre la ronda (Vel 8); en Cuenta actúa tarde (Vel 3) y **corta las cadenas** de las más lentas. Daño 50: dos golpes no tumban a ninguna presa entera salvo a la Rodauva (80), que erizada aguanta |

**Pilar 2:** las fuertes en combate (Ocarra, Zancajunco) trabajan peor; las que trabajan (Rodauva, Surcón) pelean peor.

### 11.2.1 El surco *(provisorio)* — `DECIDIDO` (05/10/2026)

Rasgo del Surcón. Reemplaza a Lomo de tierra (Visión 6.2 v1.1). Es el **único terreno del MVP** y no abre un sistema de terreno.

| Regla | Valor | Decisión que genera |
|---|---|---|
| Dónde | Una casilla **libre** (sin unidad ni surco), **ortogonalmente adyacente** al Surcón. **Puede estar junto a enemigas** (⚠️ encierro, 14) | Cerrar el paso a la que llega o cavar antes |
| Costo | **Turno completo**: se declara al inicio de su turno, sin haberse movido. Ese turno no se mueve ni ataca | ¿Peleo o cierro el paso? |
| Tope | **2 surcos por Surcón.** Si cava un tercero, se cierra el más viejo | Elegir qué dos pasillos importan; mover un surco cuesta un turno |
| Duración | Mientras **su** Surcón esté en el tablero, de pie o caído. Se cierran si sale del tablero (guardado, sellado, huido) y al terminar el combate | Sellar a un Surcón salvaje abre sus surcos; guardar al propio cierra los tuyos |
| Tránsito | Solo un **Surcón, de cualquier bando**, puede entrar, atravesarlo o terminar en él. Para el resto es intransitable | El Surcón tiene un pasillo propio |
| Línea | **No bloquea** el Alcance 2, el Martillazo ni la Lanzadera: es un pozo, no un muro | Ocarra (afín) detrás del surco, pegando por encima |
| Lanzadera | Mover a una no-Surcón hacia un surco cuenta como casilla ocupada: no se mueve y recibe 10 (1.6) | — |
| Combos | Cavar no es ataque: **no corta la cadena** (10.2) | — |
| IA salvaje | Paso 7 de 11.8 | — |

### 11.2.2 Hacerse junco — `DECIDIDO` (05/10/2026)

Rasgo del Zancajunco, reescrito como activa (Visión 6.2 v1.1). Reemplaza a la pasiva de primer ataque. **"Adyacente" en este rasgo son las 4 ortogonales** (v1.6, 11.3): contacto es poder pegarle.

| Regla | Valor | Decisión que genera |
|---|---|---|
| Activar | Gasta la **acción**. Solo si **no se movió** este turno y **no tiene ninguna enemiga de pie adyacente** (4 ortogonales) | ¿Avanzo o me escondo? No sirve para escapar de un cuerpo a cuerpo |
| Oculto *(provisorio)* | No puede ser objetivo de **ataques, hechizos** (Martillazo, Lanzadera) ni del **Encono**. **Sigue visible en el tablero** y ocupa su casilla. No hay niebla de guerra | Un hueco que la IA ignora |
| Bono | Su **próximo ataque suma +30** (plano, paso 3 de 11.4). No acumula: volver a hacerse junco con el bono no suma | Concentrar el daño en un golpe: rematar, o pegar antes de un sellado |
| Se destapa | Si **se mueve**, si **ataca** o si **una enemiga de pie queda adyacente** (4 ortogonales; por su movimiento o por la Lanzadera). Una enemiga en diagonal no lo destapa | Sondear el juncal: acercarse lo destapa, pero esa unidad queda al lado de un golpe de 70 |
| Moverse | Lo destapa, pero **conserva el bono**: el golpe es una embestida (amenaza a distancia 5) | — |
| Pierde el bono | Si **recibe un ataque** después de destapado y antes de atacar (incluidos el Martillazo y el golpe de un incidente). La Lanzadera no cuenta | Destaparlo y pegarle en la misma ronda; se arma con Secundar |
| Límite | **No puede hacerse junco dos turnos seguidos** | Nunca queda oculto dos rondas enteras: no hay rescatista blindada |
| Relaciones | Oculto **sigue dando y recibiendo afinidad e incidentes** (vecinas en 8; provoca la tirada aunque no se lo pueda golpear, 10.4). No cuenta como rival a su alcance (10.5) | Sigue siendo parte de la tribu |
| Fin del combate | Se borran el estado oculto y el bono | — |
| Acciones hostiles y aliadas | Oculto no puede ser objetivo de ninguna acción **hostil**: ataque, Martillazo, Lanzadera, Encono **ni sellado** (S-21). Las **aliadas** sí lo alcanzan: Remiendo y guardar (S-22) | Para sellar a un Zancajunco salvaje, primero hay que destaparlo |
| Destape por contacto | Se mira **al terminar** un movimiento, una Lanzadera o una invocación; pasar al lado por el camino no destapa (S-24). En Cuenta, cada tramo del movimiento partido cuenta como un movimiento que termina | Rodearlo sin destaparlo es posible |
| Destapar y pegar | La unidad que lo destapa al moverse **puede atacarlo en la misma acción del turno**: le quita el bono. **La IA no lo planifica**: elige su objetivo antes de moverse y una oculta no es objetivo (11.8) | Contra el Zancajunco salvaje, acercarse y pegar es la respuesta; cuesta quedar al lado de un golpe de 40 |
| Movimiento después | Hacerse junco **cierra el movimiento que quede**, como Erizarse (S-26) | — |

**Por qué el contacto es ortogonal** (07/10/2026): con 8 vecinas, en 12 × 12 esconderse sería casi imposible, y una enemiga en diagonal no puede pegarle. Coincide con la regla general: el cuerpo mira 4, el vínculo mira 8.

**Por qué +30 con defensa:** esconderse y después golpear rinde 70 en dos turnos, contra 80 si pega dos veces. La diferencia la paga el turno en que nadie lo puede tocar. ⚠️ Si se vuelve la jugada por defecto de cada ronda impar, baja a +20 (14).

**Por qué no dos turnos seguidos:** un Zancajunco intargeteable sin límite sería una rescatista garantizada escondida atrás todo el combate. El rescate dejaría de depender de cómo se trató al grupo (regla de oro).

**Descartado:** la niebla de guerra (que el otro bando no lo vea). Es un sistema nuevo, choca con "las apuestas se muestran antes" (Visión 8) y con la IA predecible.

### 11.2.3 Caza y cuenta — `DECIDIDO` (05/10/2026)

Rasgo del Tasajero (Visión 6.2 v1.1). **Un solo turno por ronda**, con dos modos. Empieza el combate en Caza.

| | **Caza** (empieza así) | **Cuenta** (sin vuelta) |
|---|---|---|
| Velocidad | 8 | 3 |
| Movimiento | Normal, sin partir | **Partido**: se acerca, pega y se retira, con 4 en total |
| Ataques | **2 ataques separados de 50**, a una o a dos presas adyacentes (4 ortogonales) | **1 ataque de 40** (−10 plano) |
| Daño recibido | **+25%**: se suma a los porcentajes del atacante (paso 1 de 11.4) | Normal |
| Decisión que genera | Castigarlo mientras está expuesto, o no pararse en su zona | Corta las cadenas tardías; pica y se va |

| Regla | Valor | Decisión que genera |
|---|---|---|
| Cambio a Cuenta | Al inicio de su turno, si su vida es **≤ 50%** (150). Juega ese turno en Cuenta. **No tiene vuelta.** El umbral se muestra sobre la unidad | El jugador sabe cuándo se termina la Caza |
| Velocidad tras el cambio | La de Cuenta rige **desde la ronda siguiente**: la cola no se rearma a mitad de ronda (11.3) | Ver la Cuenta en la cola de la próxima ronda |
| Encono y huida | Una vez por ronda, con contador normal (10.5, 11.7) | — |
| Enconado en Caza | El primer ataque va a la rival; el segundo sigue la IA de Caza (10.5) | — |
| Enconado en Cuenta | Solo se mueve a casillas desde donde golpea a su rival durante todo el turno: casi nunca se retira (10.5, P-038) | Enconarlo le quita la retirada |
| Sin partir en Caza | Se mueve **antes o después** de los dos ataques, nunca entre ellos (S-23) | — |
| Primera presa tumbada | El segundo ataque va a otra presa adyacente (menos vida → antes en la cola); si no hay, **se pierde** (S-23) | Dejar a una sola herida en su zona no le regala el segundo golpe a otra |
| IA | Pasos 2 y 6b de 11.8: **prefiere repartir los golpes antes que ejecutar**; predecible y sin azar | Dónde no me paro |

**Dos presas, geometría** (reescrito en la v1.6, con vecinas en 8): las presas del Tasajero son **ortogonales**, así que consigue dos solo en las **esquinas cóncavas**: una casilla que toca por los lados a dos unidades que están en diagonal entre sí, o con una casilla de hueco (formación en cruz, en L o en diagonal). Una **línea** o un **bloque de 2 × 2** no dejan ninguna. Con vecinas en 8, las diagonales también dan afinidad (10.3):
- **Rodear a una objetivo** (aliadas en diagonal entre sí) da afinidad y concentra golpes, pero abre esquinas.
- **El bloque** da afinidad a todos y cierra las esquinas, pero llega con menos golpes: contra una enemiga solo pega el miembro que la toca, más la Ocarra por encima.
- **El bloque aguanta; rodear mata y expone.** Es el dilema de *dónde no me paro* (Visión 6.2). ⚠️ Vigilar que el bloque no se vuelva dominante (14).

**Contra la Rodauva:** sola en su zona de Caza recibe 50 + 50 = 100 y cae (80 de vida). Erizada recibe 25 + 25 = 50 y aguanta. Dejarla sola a su alcance es la "decisión previa" que pide la Visión; la zona de Caza se ve (15, Arte / UI).

### 11.3 Tablero e iniciativa — `DECIDIDO`

| Regla | Valor | Decisión que genera |
|---|---|---|
| Tablero de referencia | **12 × 12**, con cámara móvil (Visión v1.3). Un escenario puede ser más chico si lo pide (combates de nodo, peleas cortas, G), nunca más grande en el MVP. Sin terreno en el MVP **salvo el surco** (11.2.1), que lo crea una criatura en combate | Espacio para maniobrar: flanquear, cavar, separar rivales |
| Turno de una unidad | **1 movimiento y 1 acción**, en cualquier orden, sin partir el movimiento. Acciones: atacar, hechizo, sellar, guardar, Erizarse, Hacerse junco (sin haberse movido, 11.2.2), esperar. Invocar, huir y **cavar un surco** gastan el turno completo. **Secundar** aplaza el turno entero y solo se declara con el turno sin usar (10.1). **Excepción al movimiento sin partir:** el Tasajero en Cuenta (11.2.3). **Terminar el turno sin usar la acción es esperar** (con o sin movimiento; P-015). **Erizarse cierra el movimiento que quede** (P-014) | ¿Pego y me retiro, o me acomodo y pego? Con la Rodauva: ¿me ubico primero y después me erizo? |
| Movimiento | Solo ortogonal. Se atraviesan aliadas y caídas propias, nunca enemigas, **tampoco caídas** (P-018). No se termina en una casilla ocupada. **Los surcos** solo los pisa un Surcón (11.2.1) | Las enemigas funcionan como muro; un pasillo protege. La caída propia sigue cubriendo: guardarla libera la casilla y abre el paso |
| Distancias | Todas **Manhattan** | — |
| Casilla libre | Dentro del tablero, **sin unidad** (de pie o caída) **y sin surco**, para cualquier unidad, incluido un Surcón (S-25). La usan cavar, invocar y la métrica de encierro (11.9) | — |
| Despliegue | Tribu en las filas **9 a 11** (su borde); enemigas en las filas **0 a 2**. Dentro de esas zonas, la distancia la fija el criterio de contacto (abajo). En la 0b, el jugador ubica a sus sueltas en su zona | La formación inicial ya es una decisión |
| **Adyacencia (4 ortogonales)** | `DECIDIDO` por la Visión v1.3: mover, atacar, guardar y presas de la Caza. `DECIDIDO` 07/10/2026, por coherencia: invocar, cavar, Remiendo, Erizarse de la IA (11.8), Hacerse junco (activar y destape por contacto, 11.2.2) y casilla libre / encierro | **El cuerpo mira 4**: se pega y se toca por los lados |
| **Vecinas (8, diagonales incluidas)** | `DECIDIDO` por la Visión v1.3: afinidad (también entre salvajes, 10.3 y 10.7), incidente (10.4) y sostén de la cobardía (toggle de afines, 10.6). `DECIDIDO` 07/10/2026, por coherencia: el −10 del Maestro vecino en la cobardía (10.6). **Los combos no miran la posición** (10.2) | **El vínculo mira 8**: rodear potencia, pero abre esquinas al Tasajero (11.2.3) |
| Orden | Mayor Velocidad primero, **sin azar** | El jugador planifica la ronda entera |
| Empates | Bando del jugador antes que el enemigo · El Maestro antes que sus criaturas · Entre criaturas, el orden de la tribu (lo define el jugador fuera del combate) · **Entre enemigas, el orden de la lista de enemigas del encuentro** (P-011) | Predecible |
| Velocidad por modo | El Tasajero usa la Velocidad de su modo (8 en Caza, 3 en Cuenta). Si cambia, la nueva rige **desde la ronda siguiente** (11.2.3) | La Caza abre la ronda; la Cuenta corta cadenas tardías |
| Criatura invocada | Entra en la cola **a partir de la ronda siguiente** | Invocar en combate cuesta el turno del Maestro y una ronda de la criatura: conviene sacarla antes, y eso cuesta comida |
| Unidad que deja de actuar a mitad de ronda | Si cae, es guardada, huye o sale del tablero, **pierde todas sus entradas restantes de la ronda**: con el Tasajero de un solo turno (v1.3), el ejemplo original de P-012 ya no aplica. La cola no se rearma | Tumbar o hacer huir a una unidad antes de su turno le quita la acción de esa ronda |
| Alcance 2 | En línea recta; puede golpear **por encima de una aliada**, nunca por encima de una enemiga, **tampoco de una caída** (P-018). **Los surcos no bloquean la línea** (11.2.1) | Segunda fila detrás del Maestro |

**Contacto en la ronda 2** — `DECIDIDO` (07/10/2026; Visión v1.3, Escala 3):

- **Definición:** **con la tribu quieta, la primera enemiga ataca en la ronda 2.** Pegar primero en la ronda 1, yendo a buscarla, es una decisión del jugador: pega antes, pero se mete en su zona.
- **Por qué no se pide más:** la enemiga se acerca en su turno de la ronda 1, y después la tribu ya la tiene a tiro (el Martillazo llega a 6: 3 de movimiento más 3 de alcance). Con estos movimientos, es imposible garantizar a la vez que nadie pegue en la ronda 1 y que la enemiga llegue en la 2.

| Enemiga que abre el combate | Alcance (Mov + Alc) | Distancia mínima válida a la tribu | Estándar |
|---|---|---|---|
| Tasajero, Zancajunco, Rodauva (Mov 4) | 5 | 6 a 9 | **8** |
| Ocarra (Mov 3, Alc 2) | 5 | 6 a 8 | **8** |
| Surcón (Mov 2) | 3 | No abre: llega tarde | — |

- **Ronda del primer ataque:** la primera en que cualquier unidad de cualquier bando ataca (incluido el Martillazo). **Rondas de pelea:** desde esa ronda hasta el fin, inclusive. Las métricas 1 y 13 y el umbral de duración de C se leen así (11.9).
- **Decisión que genera:** la ronda 1 es para acomodarse: sacar a la herida de la zona de Caza, cavar, esconderse o separar rivales con la Lanzadera.

**Inicio del turno: orden de los chequeos** — `DECIDIDO` (03/10/2026):

| Paso | Chequeo | Quién |
|---|---|---|
| 1 | Regeneración de maná (2.1) | Maestro |
| 2 | Huida con vida ≤ 25% (11.7) | Salvajes |
| 3 | Rival enemiga a su alcance → Encono (10.5) o cobardía (10.6) | Criaturas |
| 4 | Incidente con rival aliada vecina (10.4), **solo si no quedó enconada** | Criaturas |

Si la huida del paso 2 sale, el turno termina ahí. **El inicio del turno corre una vez por ronda** (08/10/2026, responde P-033): la unidad que vuelve de Secundar sigue su turno sin repetirlo, igual que el borrado de Erizarse y el cambio de modo del Tasajero.

### 11.4 Fórmula de daño — `DECIDIDO`

1. Se **suman todos los porcentajes**: bono de combo, Saciado, enfermedades, cobardía, Erizarse, Caza (+25% al daño que recibe el Tasajero en Caza).
2. Se aplican al Daño base y se redondea hacia abajo.
3. Se suman los **bonos planos**: afinidad (+10), Encono (+10 por punto), Hacerse junco (+30), Cuenta (−10 al ataque del Tasajero en Cuenta). Lomo de tierra sale en la v1.3.
4. **Mínimo 10.**

**Precisiones** — `DECIDIDO` (04/10/2026):
- **Sin recorte intermedio** (responde P-017): si los porcentajes dejan el daño por debajo de 0, los planos se suman sobre ese valor negativo y el único recorte es el mínimo del paso 4. Ejemplo: Zancajunco (40) con 3 enfermedades contra una Rodauva erizada, con el bono de Hacerse junco: −125% → 40 × (−0,25) = −10; +30 = **20**. Motivo: un solo recorte, desglose legible; el caso es extremo y el mínimo lo cubre.
- **Saciado y enfermedades son del bando de la tribu** (Maestro y criaturas de la tribu; responde P-016). Las enemigas (salvajes, Tasajero, atacante nocturna) pegan con su Daño base, sus rasgos y los aportes de combate que les toquen (afinidad entre salvajes, Encono, cobardía). Motivo: las salvajes no tienen hambre en el modelo, y la atacante nocturna es famélica, así que Saciado nunca le aplicaría; sus enfermedades quedan fuera para no sumar un caso aparte en la 0a. Coincide con 11.6: dos golpes de la Ocarra salvaje tumban a la Rodauva.

**Ejemplo:** el Maestro (40), segundo eslabón de la cadena (+50%) y vecino de una afín: 40 × 1,5 = 60, más 10 = **70**.

> **Resuelto en la v1.7:** con la escala ×10, Saciado le sirve a la Rodauva: 20 × 1,25 = **25** (antes 2 × 1,25 = 2,5 → 2).

### 11.5 Vida en 0 y fin del combate — `DECIDIDO`

| Unidad que llega a 0 | Qué pasa | Decisión que genera |
|---|---|---|
| **Criatura de la tribu** | Queda **caída**. Si se gana el combate, se levanta con **10 de vida**. Si el combate se pierde (o se huye, 11.7), **muere**: su pergamino arde y se aplica "muerte en el grupo" | La muerte depende de cómo termina la pelea, no de un solo golpe |
| **Maestro** | El combate **termina en el acto**. La rescatista (suelta, de pie y leal) lo arrastra al Molino. **Las caídas quedan atrás y mueren** | No exponer al Maestro: si cae, arrastra a sus caídas con él |
| **Salvaje** | **Huye** del tablero. No da comida ni puede sellarse | Pegarle de más significa perder la captura |
| **Atacante nocturna** | Queda caída para que el Maestro decida su destino (9.3). Si después cae el Maestro, se va (9.2, paso 6) | Tumbarla no alcanza: hay que ganar el combate para decidir |

**Reglas de la caída:**
- La caída queda en su casilla y la ocupa, pero **no puede ser objetivo**: nadie la remata.
- No actúa, no cuenta para combos ni Arrimo, y no puede rescatar.
- **No participa de ninguna relación:** no da ni recibe afinidad, no provoca ni sufre incidentes y no cuenta como rival a su alcance para el Encono ni para la cobardía.
- Sigue sumando hambre de combate (7.2).
- **El Maestro puede guardarla**: gasta su acción y el costo de invocar del rango (2 / 3 / 4, con descuento y mínimo 1), a distancia ≤ 2. Queda guardada con **10 de vida** y, como toda guardada, no se cura hasta salir. Si después el Maestro cae o huye, **sobrevive** en su pergamino.
- El Remiendo no afecta a las caídas (1.6).
- El combate se **gana** cuando no queda ningún enemigo en pie y se **pierde** cuando cae el Maestro.
- Una criatura que sube de caída a 10 de vida tiene la misma curación nocturna que las demás (7.8).

**Motivo:** con la Rodauva en 80 de vida, una Ocarra salvaje puede tumbarla en dos golpes el día 1. Con la caída, la compañera muere solo si el Maestro también cae.

**Decisión que genera:** guardar a una caída compite por el maná con el Martillazo, el Remiendo y sellar. Es la forma de no abandonarla si hay que huir.

### 11.6 Encuentros de referencia — `DECIDIDO`

> **Desde la v1.6**, las líneas típicas de esta sección usan las posiciones del tablero de 8 × 8 y se leen como **rondas de pelea** (desde el primer ataque, 11.3). En 12 × 12 se les suma la ronda de acercamiento: la primera ronda de cada tabla pasa a ser la ronda 2 del combate. Los daños no cambian, salvo la afinidad, que con vecinas en 8 aparece más seguido (10.3). **Desde la v1.7**, en la escala ×10.

**Prueba A — Día 1: Maestro + Rodauva (Neutral) contra 1 Ocarra salvaje.** Orden: Ocarra (7), Rodauva (6), Maestro (5). La cadena sale sola. Bono: "sin relación" + 3 pasos de Arrimo = **+50%**.

> Esta sección es **referencia de daño**. El objetivo de cada salvaje lo decide la IA de 11.8, que **manda** (03/10/2026, responde P-009): la Ocarra va por la Rodauva, que tiene menos vida, no por el Maestro.

Línea típica con las posiciones del escenario A en 8 × 8 (Maestro [3,7], Rodauva [4,7], Ocarra [4,0]):

| Ronda | Ocarra | Tribu | Vida de la Ocarra |
|---|---|---|---|
| 1 | No alcanza; se acerca a [4,3] | Rodauva pega 20 · Martillazo con +50% pega 45 | 120 → 55 (46%: sellado al 50%) |
| 2 | Rodauva 80 → 40 | Rodauva pega 20 → **decisión** | 55 → 35 (29%: sellado al 50%) |
| 3 | **Tumba a la Rodauva**, salvo que esté erizada o se la haya movido | Una ronda más para llegar al 80% | — |

**Decisión que aparece:** ¿sello al 50% o arriesgo a mi compañera una ronda más para ir al 80%? "Una ronda más" ya no cuesta vida del Maestro: cuesta que la Rodauva caiga. Es la regla de oro en el día 1.

**Prueba B — 2 Ocarras en los Huertos** (reescrita en la v1.7 con las coordenadas de 12 × 12, P-030): cada Ocarra va por la unidad que tiene más cerca, una por la Rodauva y otra por el Maestro. Desde la ronda 2 del combate el Maestro recibe 40 por ronda; la Rodauva cae en la ronda 3 y desde ahí el Maestro recibe 80 por ronda. Cae sin rescatista hacia la ronda 5. Es un muro, y se siente antes que en 8 × 8. La pregunta "¿guardo a la caída antes de huir?" aparece temprano. **Salida táctica:** con el Maestro un paso adelante, atraer a una Ocarra con la Lanzadera la deja en diagonal con la otra (rivales, 10.7).

**Prueba C — Tasajero** (v1.3): en Caza pega 100 por ronda (dos ataques de 50) y recibe +25%; en Cuenta pica 40 y se retira. Un Maestro solo dura 2 rondas. Línea típica en rondas de pelea (en 8 × 8, con el Tasajero en [3,1]; en 12 × 12, la ronda 1 de esta tabla es la ronda 2 del combate):

| Ronda de pelea | Qué pasa | Vida del Tasajero |
|---|---|---|
| 1 | El Zancajunco se oculta. Caza: su única presa al alcance es el Maestro → 50 + 50 (200 → 100). La tribu, con +25%: Ocarra 50, Rodauva 39, Maestro con combo y afinidad 74 | 300 → 137 |
| 2 | El Zancajunco embiste antes del cambio de modo (empate en 8, gana la tribu): 40 × 1,25 = 50, + 30 = 80. En su turno, con 57 de 300 (≤ 25%), **primero tira huida (25%)**; si se queda, pasa a Cuenta y pica 40. La tribu remata | 137 → 57 → 0 |
| 3 | Si sobrevivió: remate o huida | — |

**Duración: unas 2 a 2,5 rondas de pelea**, dentro de la meta. Con vecinas en 8 la afinidad aparece más seguido y con la escala ×10 los eslabones pegan completos (+9% en la ronda 1 de esta línea): estimo el borde bajo, 2 rondas (⚠️ 14). Va por la Rodauva si queda sola en su zona de Caza (100), así que **llevar a la compañera al Robledal sigue siendo una apuesta real**; erizada recibe 50.

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
| Vado | 40% | 1 Zancajunco | Golpe desde el juncal: destaparlo antes de que embista (Hacerse junco) |
| Vado | 30% | 1 Zancajunco + 1 Surcón | Un atacante oculto y un cavador que cierra el paso |
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
| Previsualización al declarar | Qué enemigas actúan antes del cierre y el **daño máximo** que pueden hacerle al Maestro | ¿Huyo ahora con 60 de vida o pego una vez más? |
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
| Tasajero | 25%, al inicio de su turno (uno por ronda desde la v1.3) |

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
2. **Cambio de modo** (Tasajero en Caza): con vida **≤ 50%**, pasa a Cuenta y juega este turno en Cuenta (11.2.3).
3. **Encono:** si está enconada, va por su rival (10.5). Así el Tasajero va por la Rodauva. En Caza, solo el primero de sus dos ataques; el segundo sigue el paso 6b (S-42). Si no la alcanza, se acerca (S-43).
4. **Erizarse:** si su especie tiene Erizarse, su vida es **≤ 50%** y tiene una enemiga **de pie adyacente** (4 ortogonales), se eriza (03/10/2026). Una caída no cuenta: no es objetivo ni amenaza (04/10/2026, responde P-022). Una enemiga en diagonal tampoco: no puede pegarle (07/10/2026).
5. **Remate:** si puede tumbar a alguna unidad este turno, ataca a esa. Si hay varias, la de menos vida actual.
6. **Cercana:** si no, ataca a la unidad más cercana que pueda alcanzar; si empatan, la de menos vida.
   - **6b. Tasajero en Caza** (reemplaza a los pasos 5 y 6): elige la casilla alcanzable que lo deja junto a **2 presas** y les da un ataque a cada una; si no hay, junto a **1 presa**, y le da los dos ataques. Desempates en la tabla de abajo. **Prefiere repartir antes que ejecutar.**
   - **Tasajero en Cuenta:** después de atacar, se retira con el movimiento que le queda (tabla de abajo). Enconado, solo a casillas desde donde sigue golpeando a su rival (10.5, P-038).
7. **Prepararse** (si no puede atacar a nadie este turno, ni moviéndose):
   - **Zancajunco:** si no tiene el bono y no se escondió el turno anterior, **se hace junco** sin moverse (11.2.2).
   - **Surcón:** si tiene menos de 2 surcos, **cava** (11.2.1).
8. **Acercarse:** si no alcanza a nadie, se mueve hacia la unidad más cercana. El Zancajunco con el bono avanza: se destapa y lo conserva.

**Tasajero:** su único turno recorre esta lista desde el paso 1, con el modo que tenga.

**"Puede tumbar" y "puede alcanzar"** — `DECIDIDO` (03/10/2026, responde S-8): se mira el **turno completo**, es decir, moverse y después una acción.

**Desempates deterministas** — `DECIDIDO` (03/10/2026). La IA es simple a propósito: tiene que ser predecible para que el jugador planifique la ronda.

| Elección | Criterio, en orden |
|---|---|
| Objetivo con remate (paso 5) | Menos vida actual → más cercana → la que actúa antes en la cola |
| Objetivo sin remate (paso 6) | **Más cercana** → menos vida actual → la que actúa antes en la cola (04/10/2026, responde P-020) |
| "La que actúa antes en la cola" | El orden de la **ronda entera**, por la primera entrada de cada unidad, haya actuado o no (04/10/2026, responde P-021) |
| "Puede tumbar" | Se calcula con la misma función de previsualización del daño (determinista: el daño no tiene azar) |
| Casilla desde dónde golpear | Si ya alcanza desde donde está, **no se mueve** · la Ocarra prefiere la distancia 2 · la de menos movimiento · orden de lectura (y menor, después x menor) |
| Acercarse | Objetivo: la más cercana → menos vida → cola. Casilla: la alcanzable más cercana a la objetivo (Manhattan) → orden de lectura. Si ninguna la acerca, no se mueve |
| Enconada que no alcanza (paso 3) | Entre las casillas de menor distancia a su rival que el turno permite → orden de lectura (08/10/2026, S-43) |
| Casilla del Tasajero en Caza (paso 6b) | Junto a 2 presas > junto a 1 → la que tumba a alguien → menos vida sumada de sus presas → menos pasos → orden de lectura |
| **Presas del Tasajero en Caza** (paso 6b) | Con 3 o más presas adyacentes, elige **las 2 de menos vida → la que actúa antes en la cola**. El **primer ataque** va a la de menos vida (mismo criterio que el segundo de S-23) (07/10/2026, responde P-026) |
| Tasajero enconado en Caza (pasos 3 y 6b) | La rival por los desempates de 10.5 → la casilla, entre las que la golpean, con la clave del 6b → el segundo ataque a otra presa de menos vida; si no hay, a la rival (08/10/2026, S-42) |
| Retirada del Tasajero en Cuenta | Golpea desde la casilla de menos pasos (le queda más para irse). Después, la casilla alcanzable **más lejana** (Manhattan) de la enemiga de pie más cercana → orden de lectura. Si ninguna la aleja, no se mueve |
| Casilla del surco (Surcón salvaje, paso 7) | La casilla válida más cercana a la enemiga de pie más cercana → orden de lectura |
| **"La enemiga de pie más cercana"** (retirada y surco) | **Más cercana → menos vida → la que actúa antes en la cola**, igual que el objetivo de Acercarse. Nunca una oculta (07/10/2026, responde P-027) |

**Por qué dos órdenes distintos** (P-020): el remate premia exponer a una herida; sin remate, manda la **posición**. El que se pone adelante recibe, incluido el Maestro (Pilar 1), y el Surcón puede hacer de muro. Con "menos vida primero" en los dos casos, la IA ignoraría la formación.

**Reglas fijas:** una acobardada no termina su movimiento más cerca de su rival; la Ocarra ataca desde distancia 2 si puede; nadie apunta a una caída ni a una oculta (11.2.2); las salvajes no Secundan.

**Decisión que genera:** dejar a una herida expuesta es invitar al remate. ¿La retiro, la guardo o la cubro con el Surcón? Contra una Rodauva salvaje: el golpe que la deja en la mitad de su vida decide si después se eriza; conviene bajarla de un golpe justo, con la mano fina.

**Alternativas descartadas para Erizarse:** no erizarse nunca (la Rodauva salvaje queda trivial) y erizarse siempre que tenga una enemiga adyacente (combates largos contra un erizo inmóvil).

**Alternativas descartadas:** "la más cercana" (combates resolubles de memoria) y "el Maestro primero" (empuja a esconderlo, sección 8 de la Visión).

### 11.9 Prueba 0a — `DECIDIDO`

Rebanada de combate aprobada el 01/10/2026: tablero, relaciones, sellado, caída y rescate. Lo que no entra se carga como **parámetro del escenario** (lealtad, hambre, Saciado, enfermedades, balanza, Poder, Regeneración, vida y maná de entrada). Se juega con **escenarios fijos + panel de parámetros + semilla de azar fija**. El brief completo para el Arquitecto vive en el doc "Brief para el Arquitecto — Prueba 0a" (01/10/2026), que es histórico: ante cualquier diferencia, manda este documento (`Arquitectura.md` A.5).

| Escenario | Archivo (`datos/escenarios/`) | Configuración | Qué mide | Señal de alarma |
|---|---|---|---|---|
| A. Día 1 | `a_dia_1.json` (Arquitecto) | Prueba A (11.6) | ¿Sello al 50% o arriesgo una ronda más? | Siempre se elige lo mismo |
| B. Muro | `b_muro.json` | Maestro + Rodauva Neutral (5) contra 2 Ocarras separadas. Sin rescatista | ¿Reconoce que hay que huir? ¿Guarda a la caída antes? Segunda salida: juntar a las Ocarras (rivales) con la Lanzadera | Huir nunca se lee como opción |
| C. Tasajero | `c_tasajero.json` | Maestro + Rodauva, Ocarra y Zancajunco leales (8) contra el Tasajero. La Rodauva se puede pasar a guardada en el panel | Duración (meta: 2 o 3 rondas de pelea) · ¿Llevo a la Rodauva? | Más de 5 rondas de pelea, o la Rodauva muere sin decisión |
| D. Rivales aliadas | `d_rivales_normal.json` · `d_rivales_hambriento.json` | Ocarra + Zancajunco Neutrales (5) contra Surcón + Rodauva salvajes, sin relación con la tribu. Hambre 3 y 6 | Incidentes por combate · ¿Separa con la Lanzadera? Con hambre, la obediencia baja a 3 y el incidente pasa a golpe | 0 incidentes, o castigo puro. **Leer también con la balanza 4** (ver 14) |
| E. Cobardía | `e_cobardia.json` · `e_cobardia_afines.json` | Rodauva leal (8), Rodauva Neutral (5) y Surcón leal contra el Tasajero; sin y con el toggle de afines (10.6) | ¿Sostiene a la asustada? | Nunca aparece, o frustra siempre |
| F. Rescate | `f_rescate.json` | Maestro con 60 de vida · Rodauva leal (rescatista frágil) · Ocarra Neutral, contra Zancajunco + Surcón | ¿Guarda caídas antes de caer? ¿Entiende quién lo salva? | El rescate se siente azaroso |
| G. Ataque nocturno | Borrador del Arquitecto | Ocarra desleal atacante; maná de entrada a la mitad (2.4); golpe inicial de 40 (9.2) | Las 3 salidas (9.3) · ¿Alcanza para resellar? | Comer es siempre la respuesta |
| H. Soplo | `h_soplo.json` | C con balanza 5 y Poder 3, mismas lealtades | ¿El Soplo es una build trampa? | Pierde siempre, o gana más fácil que el Barro |

**Valores de los escenarios** — `DECIDIDO` (03/10/2026, responde P-004 a P-007):

| Caso | Valor |
|---|---|
| "Leal" y "Neutral" sin número | **Leal 8, Neutral 5.** 8 sigue siendo leal con la balanza 5 (umbral 8); 5 es Neutral en todas las posiciones |
| El Maestro | Está en **los 11 escenarios**, con los valores iniciales salvo F (vida 60), G (maná 4), H (balanza 5, Poder 3) y `d_rivales_balanza4` |
| D hambriento | Hambre 6 **solo en las criaturas**; el Maestro queda en 3. La única diferencia entre las dos D es la obediencia |
| Posiciones | **Aprobadas en 12 × 12** (08/10/2026, responde P-030), tal como las propuso Claude Code y las verifica `pruebas/datos/test_contacto.gd` (tabla en `Arquitectura.md` A.9 y en P-030). G sigue en 8 × 8. **Ante una alarma, primero se descarta que la causa sea la posición; después se toca la regla** |
| B en 12 × 12 | Cada Ocarra va por la unidad que tiene más cerca: el Maestro recibe golpes desde la ronda 2 (11.6, Prueba B reescrita). Lo que mide B no cambia |
| C y H en 12 × 12 | La Ocarra de la tribu empieza detrás de la Rodauva, no del Maestro: así no empieza en diagonal con el Zancajunco (rivales). El Tasajero está a distancia 8, en la fila del frente de su zona; caza en la ronda 2 |
| F con el Zancajunco nuevo | Se oculta en la ronda 1, avanza destapado con el bono en la 2 y embiste en la 3 (40 + 30 = 70 tumba al Maestro con 60), salvo que lo golpeen en la 2. A distancia 8 la línea se mantiene igual |

**Criterios de despliegue en 12 × 12** — `DECIDIDO` (07/10/2026; Visión v1.3: "los despliegues los define Sistemas"):

| Escenario | Distancia mínima tribu–enemiga | Qué tiene que pasar con la tribu quieta | Qué no puede pasar |
|---|---|---|---|
| A | 8 (Ocarra–Rodauva) | La Ocarra se acerca en la ronda 1, va por la Rodauva y la golpea en la ronda 2. La línea de 11.6 se mantiene | — |
| B | 8 a las dos Ocarras | Las dos llegan a la tribu en la ronda 2 | Que las Ocarras salvajes **terminen vecinas** (8, también en diagonal) al final de las rondas 1 o 2: sería un incidente gratis. La Lanzadera tiene que poder juntarlas con 1 o 2 pasos del Maestro |
| C y H | 8 (Tasajero a la tribu) | En la ronda 1 el Tasajero se acerca; el jugador tiene su ronda 1 para sacar a la Rodauva de la zona de Caza, erizarla o esconder al Zancajunco. Caza en la ronda 2 | Que el Tasajero pegue en la ronda 1 |
| D (3 variantes) | 8 a la Rodauva salvaje | Las rivales aliadas (Ocarra y Zancajunco) **empiezan vecinas** (la diagonal ya cuenta) | Que separarlas no sea la primera decisión |
| E (2 variantes) | **10** a las Rodauvas (excepción) | La primera tirada de cobardía cae en la **ronda 2**, con la formación que eligió el jugador. Con 8, el Tasajero (Vel 8) se acerca y las Rodauvas (Vel 6) tiran en la ronda 1, antes de que el Maestro (Vel 5) pueda acomodarse. E mide la cobardía, no la duración | Que la primera tirada caiga antes de que el Maestro actúe |
| F | 8 (Zancajunco salvaje) | La línea de F de arriba | — |
| G | Excepción: tablero de **8 × 8** | Es un ataque nocturno donde se duerme: contacto inmediato. La atacante queda cerca, como hoy | — |

**Cómo se fijan las coordenadas:** Claude Code las propone sobre estos criterios y las **verifica contra la IA real** con un test que juega las rondas 1 y 2 con el jugador esperando, y comprueba la distancia, la ronda del primer ataque enemigo y las condiciones de cada fila. Sistemas las aprueba, como en P-007 (las de la v1.6 quedaron aprobadas en P-030). Motivo: verificar a mano el camino de la IA es fácil de errar.

**Bandos que se cruzan en la cola:** depende de las Velocidades, no de las posiciones. Se cruzan C, D, G y H; E se cruza solo después del cambio a Cuenta; A, B y F no se cruzan. **Se acepta** (07/10/2026): cruzarlos exigiría cambiar la composición de los escenarios, y con eso, lo que mide cada uno. Secundar (métrica 2) se lee solo en los escenarios que se cruzan.

**Reglas de los escenarios:** todos usan posiciones fijas (el panel las cambia), hambre 3 y maná completo salvo indicación. Las variantes que se comparan **comparten semilla** (C y H; las dos D; las dos E), para que la diferencia salga de la regla y no del azar. Las notas de diseño de cada escenario viven en su campo `_nota`.

**Métricas por combate** — `DECIDIDO` (03/10/2026). Son **14** (la 14 se sumó el 05/10/2026) y reemplazan a cualquier otra lista (incluidas las "7 del Brief"). Se exportan junto con el resultado del combate (desenlace, destino de la atacante).

| # | Métrica | Cómo se cuenta |
|---|---|---|
| 1 | Rondas | **Rondas totales**, **ronda del primer ataque** y **rondas de pelea** (desde el primer ataque hasta el fin, inclusive; 11.3). Los umbrales de duración usan las rondas de pelea (v1.6) |
| 2 | Secundar | Usos. Se lee en C, D, G y H (y en E después de la Cuenta) |
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
| 13 | Distancia del Maestro | Manhattan a la enemiga de pie más cercana, al final de cada turno suyo **desde la ronda del primer ataque**; promedio del combate (vigila el Martillazo). Motivo (v1.6): la ronda de acercamiento la inflaría y la alarma saltaría siempre |
| 14 | Activas y terreno | Usos de Erizarse; surcos cavados; Hacerse junco (ocultos, destapes por contacto, bonos cobrados y perdidos); ronda del cambio a Cuenta; turnos que una unidad termina **sin ninguna casilla libre adyacente** (encierro) |

**Umbrales de alarma** — `DECIDIDO` (03/10/2026; aprobados por el Director Creativo). Superar uno obliga a revisar la regla antes de pasar a la 0b (Visión 10).

**Cómo se mide:** **10 partidas por escenario**, y cada variante cuenta aparte, con al menos **3 jugadores distintos**. Se usan 10 semillas; las variantes que se comparan usan **las mismas 10** (C y H; las dos D; las dos E). **Sin encuesta** (`DECIDIDO` por el Director, Visión 11 v1.2): todo sale del registro. Se reabre si los comentarios de los jugadores contradicen los números. Con 10 partidas, "80%" = 8 de 10.

**Desde cuándo se miden** (`Arquitectura.md` B.2.1): el hito **0a.1b** sirve para **sentir** los rasgos (¿se ven?, ¿generan decisiones?, ¿el combate sigue rígido?), no para medir estos umbrales: sin combos, afinidad ni relaciones, los números de C todavía no son los de 11.6. Los umbrales se miden **desde la 0a.2**, sobre el tablero de 12 × 12 y en la escala ×10, y los de criterio de éxito, en isométrica (Visión 10). La métrica 14 sí se puede mirar desde la 0a.1b, como señal temprana y sin umbral.

| Escenario | Señal | Umbral | Métrica |
|---|---|---|---|
| A. Día 1 | Siempre se elige lo mismo | Más del **80%** de los primeros intentos de sellado en el mismo tramo de probabilidad (50% o 80%) | 7 |
| B. Muro | Huir nunca se lee como opción | Menos del **30%** de las partidas terminan en huida o en victoria | Desenlace |
| C. Tasajero | Combate largo | Más de **5 rondas de pelea** en más del **20%** de las partidas, o promedio de rondas de pelea fuera de **2 a 3,5** | 1 |
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
| Todos | El Maestro se esconde (Martillazo) | Distancia media del Maestro (desde el primer ataque) **mayor a 3** en más del **50%** de los combates → se recorta el alcance del Martillazo (1.6) | 13 |
| Todos | Una activa no genera decisiones | Una activa de la tribu (Erizarse, cavar, Hacerse junco) usada en menos del **20%** de los combates donde estaba disponible | 14 |
| C y E | Encierro con surcos | El Tasajero termina un turno sin ninguna casilla libre adyacente en más del **20%** de las partidas | 14 |

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
| Ganarle + 1 ofrenda | Un combate de 2 o 3 rondas de pelea contra 100 de daño por ronda en Caza, más 2 raciones |
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

**La atacante que se va tras una derrota nocturna** (9.2, paso 6) — `DECIDIDO` (05/10/2026): causa **abandono**, con el día de la noche del ataque y el flag "fue atacante". Usa la línea de Abandono de `Mundo.md` 4.11, que ya dice lo que pasó ("se fue de noche, su pergamino ardió solo"). Una variante "tras atacarte", como la de Comida, es opcional (Worldbuilder).

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

**Etapas de las golondrinas** — `DECIDIDO` (05/10/2026, responde `Mundo.md` 9.1): cuartos de la duración. Etapa = **⌈4 × día ÷ duración⌉**, del día 1 al penúltimo; la mañana del último día ya no están (Visión 5). Con 30 días: etapa 1 los días 1–7, etapa 2 los 8–15, etapa 3 los 16–22 y etapa 4 los 23–29. Se calcula con el dato de duración: con 20 días de test, los cortes se acomodan solos.

**Referencia:** con 30 días alcanzan 3 o 4 rituales (cada vuelta al Robledal son 6 días, 12.9) y una captura de mitad de partida llega a leal.

---

## 14. Combinaciones rotas y riesgos

| Riesgo | Estado | Solución |
|---|---|---|
| Alargar combates para recargar maná | Resuelto | Tope de maná de entrada + hambre por ronda |
| Guardar criaturas antes del conteo de comida | Resuelto | Come si estuvo suelta en algún momento del día |
| Guardar en combate para salvar criaturas gratis | Resuelto | Cuesta la acción de la criatura y exige adyacencia |
| Invocar gratis con descuento máximo | Resuelto | Costo mínimo de 1 maná |
| Porcentajes que se pierden con números chicos | Resuelto | Escala ×10 de vida y daño (v1.7, 11.1); afinidad plana; recolección sobre el total del nodo |
| Resellar a la traidora para "reiniciarla" | Resuelto | Vuelve con lealtad 1 y exige un pergamino en blanco |
| Resellar un rango 2 era imposible con el maná nocturno | Resuelto | Resellar cuesta lo mismo que invocar |
| Combos que dependen del azar de la iniciativa | Resuelto | Acción Secundar |
| Cadenas infinitas | Resuelto | Cada eslabón vale la mitad |
| Curarse gratis con hechizos antes de dormir | Resuelto | Sin hechizos fuera del combate |
| Encadenar rituales con materiales acumulados | Resuelto | Máximo 1 por día; debilidades acumulables |
| Porcentajes de vida que se achican en cadena | Resuelto | Todo se calcula sobre la vida máxima real |
| **Balanza inicial en 2 da casi todo el Arrimo** | ⚠️ Vigilar | Decidido arrancar en 2. Si el Barro se siente "normal" y el Soplo un castigo, revisar |
| **Combo de afines +80% en balanza 1** | ⚠️ Vigilar | Testear que no trivialice los combates de rango 1. Con la escala ×10 el bono se cobra completo |
| **Polo Soplo como build trampa** | ⚠️ Vigilar | Sin Arrimo y con umbral 8. La interfaz debe mostrar el umbral de rescate y los riesgos de incidente |
| **Espiral de enfermedad** (enfermo → recolecta menos → famélico → come rechazado → enfermo) | ⚠️ Vigilar | Es intencional (Pilar 4). Testear que la cura viajando y el descanso parcial permitan salir |
| **Bichos rompen la monotonía muy barato** | ⚠️ Vigilar | Si resulta trivial, exigir que cada tipo cubra al menos 1 ración completa |
| **Hambre por ronda castiga combates largos legítimos (jefes)** | ⚠️ Vigilar | Desde la v1.6, cada 6 rondas (7.2). Si molesta, eximir a los jefes o subir a cada 8 rondas |
| **Invocar siempre a la noche** (gratis en maná) | ⚠️ Vigilar | Cuesta un día extra de comida. Si domina en los tests, revisar |
| **El Zancajunco, único beneficiado por comer criaturas** | ⚠️ Vigilar | Coherente con su ficha; ver en test si empuja a comer compañeras |
| **Cobardía poco testeada en el MVP** | ⚠️ Vigilar | Con la Rodauva como compañera desde el día 1, se testea si el jugador la lleva al Robledal (el colgadero y el Tasajero la castigan). Si aun así casi no aparece, armar un escenario de test forzado |
| **Tribu de Rodauvas trivializa el hambre en los Huertos** | Resuelto | Agotamiento y pudrición (12.5); tope de +2 por pasiva y nodo; una sola habilidad de campamento por especie (9.4) |
| **Acampar en los Huertos** (la dieta variada no lo impide) | Resuelto | Agotamiento y comida perecedera (12.5) |
| **Tribu de Ocarras** (rango 1, alcance 2, Velocidad 7, come poco) | ⚠️ Vigilar | Ocarra–Ocarra mal, Centinela no se acumula, una sola habilidad por especie. Con vecinas en 8 se tocan más seguido (10.4). Si domina, subir el incidente entre Ocarras |
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
| **Jefe sin suficientes acciones** | ⚠️ Vigilar | Desde la v1.3, un solo turno con dos ataques en Caza (Visión 6.2). Si C dura menos de 2 rondas de pelea, subir la vida del Tasajero a 360 |
| **Criatura "guardaespaldas"** (una sola suelta, siempre leal) | Aceptado | Es la regla de oro funcionando |
| **Congelar desleales en el pergamino** | Aceptado | Detiene el abandono, pero también el vínculo y la curación; sacarla cuesta maná |
| **La IA de remate castiga de más a la Rodauva** (80 de vida) | ⚠️ Vigilar | Escenarios A y E. Si la compañera cae en casi todos los combates, bajar el remate a "solo si la objetivo no está erizada" |
| **Combos demasiado fáciles** (las acciones que no son ataque no cortan) | ⚠️ Vigilar | Si las cadenas de 4 eslabones son rutina, que solo la Lanzadera no corte. Con la escala ×10 los eslabones 4 y 5 ya suman: vigilar la métrica 3 |
| **Quebranto sin maná** camino a la Poza | Intencional | No sella ni invoca hasta curarse: la tribu suelta lo tiene que sostener. Si es un callejón sin salida, permitir la regeneración por turno en combate |
| **Comer y recapturar para farmear XP** | Resuelto | La captura da XP solo la primera vez por especie (1.4). Queda el hito de Leal por una instancia nueva: +3 tras unos 5 días, al costo de −5 de lealtad para toda la tribu. Se acepta |
| **Derrotar al Tasajero no daba recompensa** | Resuelto | 3 XP, −1 de hostilidad y el resto de la visita sin él (12.10) |
| **Guardar a toda la tribu los últimos días** (no come y la lealtad queda congelada para el epílogo) | ⚠️ Vigilar | El epílogo distingue sueltas de guardadas (13). Si aparece como rutina, pedirle al Director Creativo que el texto lo marque con más peso |
| **El Soplo llega tarde en la 0b** | ⚠️ Vigilar | Con 3 o 4 subidas, el polo Soplo se alcanza recién al final. El escenario H de la 0a lo testea por parámetro; si hace falta en la 0b, partida de test con la balanza inicial como parámetro |
| **Robar y ofrendar en loop** | Aceptado | Neto: 2 de carne en dos días de colgadero, menos que un día de Hongos |
| **Ofrendar carne de una compañera comida** | ⚠️ Vigilar | Permitido: consecuencia del Pilar 4, no regla. Si aparece como estrategia, se prohíbe ofrendar carne de criatura |
| **Quebranto y hambriento atrapado del otro lado del río** | Resuelto | El cruce no mata (12.11). Queda el costo de llegar con poca vida |
| **Encono alto siempre deseable** (la Ocarra enconada pega 70) | ⚠️ Vigilar | Si perder el control no pesa, bajar el máximo a +20. Métricas de los escenarios C y D |
| **El Maestro casi nunca es objetivo** (la IA va por la de menos vida; 11.8) | ⚠️ Vigilar | Mitigado en parte: sin remate, la IA va por la más cercana (P-020), así que un Maestro adelante recibe. En B (12 × 12) una Ocarra va por él desde la ronda 2. Métrica 9 en C y F. Si el Maestro no cae nunca, el Pilar 1 se debilita: aplicar el remate sobre el Maestro con su vida en porcentaje |
| **Maestro solo en el ataque nocturno** (ninguna leal defiende; 9.2) | ⚠️ Vigilar | Peor caso ajustado. Si en 0b.3 termina en permadeath la mayoría de las veces, la atacante pierde el golpe inicial cuando no hay defensoras. Testear con la variante `g_sin_leales` |
| **Muertes en cadena** (cada muerte resta por separado; 5.2) | Intencional | Perder un combate con dos caídas golpea a toda la tribu. Es la regla de oro; vigilar que no empuje a una espiral de abandonos |
| **La enconada remata a la salvaje que se quería sellar** | ⚠️ Vigilar | Tensión intencional (Pilar 2). Si frustra, que la enconada deje a una salvaje en 10 de vida |
| **Incidentes casi invisibles con la balanza 2** (5% por chequeo; cerca de 30% de ver al menos uno en un combate de 3 o 4 rondas) | ⚠️ Vigilar | Mitigado en parte por las vecinas en 8 (v1.6): las rivales se tocan más seguido. Escenario D con la balanza 2 y con la 4 (15%). Si a balanza 2 los rivales nunca se notan, bajar el Arrimo a −3 puntos por paso o subir la base a 25% |
| **La Rodauva salvaje erizada alarga los combates** | ⚠️ Vigilar | Escenario D. Si se vuelve un muro, que solo se erice si la enemiga adyacente puede tumbarla este turno |
| **Encierro con surcos** (dos surcos cierran una esquina) | ⚠️ Vigilar | Cavar junto a enemigas está permitido (05/10/2026). Umbral en 11.9. Palanca: prohibir cavar en casillas adyacentes a una enemiga de pie |
| **Ocarra detrás del surco**, intocable para las de alcance 1 | ⚠️ Vigilar | Tope de 2 surcos y turno completo. Si domina, el surco corta la línea del Alcance 2 |
| **Zancajunco oculto como rescatista blindada** | Resuelto | No dos turnos seguidos; se destapa al moverse, al atacar o con una enemiga adyacente (11.2.2) |
| **Hacerse junco en cada ronda impar** (+30 y defensa) | ⚠️ Vigilar | Métrica 14. Si es la jugada por defecto, bajar el bono a +20 |
| **Zancajunco con el bono y enconado** (40 + 30 + 30 = 100) | Aceptado | Raro: exige una espera previa y a la rival a tiro |
| **El Tasajero muere antes de cazar** | ⚠️ Vigilar | El castigo de Caza bajó de +50% a +25% (05/10/2026). Si C dura menos de 2 rondas de pelea, vida 360 |
| **Rodauva sola en la zona de Caza** (recibe 100) | ⚠️ Vigilar | Métrica 11 en C. Si muere sin decisión, la IA nunca pone los dos ataques sobre una presa con la vida completa |
| **Surcón frágil sin Lomo de tierra** | Resuelto | Vida 180 → 240 (05/10/2026; en la escala de entonces, 18 → 24) |
| **Hacerse junco asimétrico** (el jugador destapa y pega en el mismo turno; la IA no lo planifica, 11.2.2) | ⚠️ Vigilar | Aceptado mientras la IA sea simple: la salvaje se oculta solo si nadie la alcanza (11.8, paso 7), así que el jugador rara vez llega a destaparla y pegar. Métrica 14 (bonos cobrados y perdidos) en F y en el Vado de la 0b. Si la oculta del jugador resulta intocable, la IA suma "destapar y pegar" a su lista |
| **Comer criaturas guardadas como despensa** | Resuelto | Solo se come a una suelta (7.7, opción B) |
| **Bloque de 2 × 2 como formación dominante** (v1.6) | ⚠️ Vigilar | Con vecinas en 8, el bloque da afinidad a todos y el Tasajero no consigue dos presas (11.2.3). Contrapeso: pega con menos golpes (solo el miembro que toca a la enemiga, más la Ocarra por encima). Escenarios C y E: si la tribu termina en bloque la mayoría de los turnos y gana igual, revisar con el Director (palanca a definir con los datos) |
| **La afinidad más frecuente y la escala ×10 acortan C** (v1.6, v1.7) | ⚠️ Vigilar | Unos 30 o 40 de daño más por ronda por la afinidad, y cerca de +9% por los eslabones completos; estimo 2 rondas de pelea, en el borde bajo de la meta. Palanca ya anotada: vida del Tasajero 360 |
| **Cuenta con espacio** (v1.6) | ⚠️ Vigilar | En 12 × 12, el Tasajero en Cuenta siempre tiene lugar para retirarse: pica y se va. Puede alargar C. Métrica 1 (rondas de pelea). Palanca: la retirada de Cuenta usa como máximo 2 casillas |
| **El jugador pega primero en la ronda 1** (v1.6) | Aceptado | La enemiga se acerca en su turno de la ronda 1 y queda a tiro (11.3). Ir a buscarla es una decisión: pega antes, pero entra en su zona |
| **La enconada atada a su rival todo el turno** (v1.7, P-038 opción A) | ⚠️ Vigilar | El Tasajero enconado en Cuenta casi nunca se retira, y la Ocarra enconada no puede pegar y salir de la zona de Caza. Es intencional (perder el control), pero puede acortar C (un Tasajero que no se retira recibe más) y frustrar a la tribu. Métricas 1 y 5 en C y F. Palanca: que la restricción de casillas termine con el primer ataque a la rival (opción B de P-038; una condición y su test) |

---

## 15. Pendientes

> En la v1.5 se resumieron los pendientes ya cerrados de las versiones anteriores: el detalle de cada cierre está en el registro de cambios (16).

**PARA SISTEMAS:**
- [x] ~~Todo lo pedido hasta la v1.5~~: S-1 a S-26, P-001 a P-024, escenarios B a F y H, rasgos reescritos e IA del Tasajero, preguntas de `Mundo.md` 9.1, sincronización con la Visión v1.2. Ver 16.
- [x] ~~Visión v1.3: números con vecinas en 8 y despliegues en 12 × 12~~ → Hecho en la v1.6 (10.3, 10.4, 10.6, 11.3, 11.9). P-026 y P-027 respondidas (11.8).
- [x] ~~Aprobar las coordenadas de 12 × 12~~ → Aprobadas en la v1.7 (P-030, 11.9).
- [x] ~~P-031 a P-036, P-038 a P-040, S-41 a S-44 y A-3~~ → Respondidas en la v1.7 (ver 16).
- [ ] Toggle de afines contra la cobardía (10.6): se decide con el escenario E (0a.2 en adelante).
- [ ] Riesgos ⚠️ (14): se ajustan con las métricas de los playtests, **desde la 0a.2** (11.9). Nuevos en la v1.6: el bloque de 2 × 2, la afinidad que acorta C y la Cuenta con espacio. Nuevo en la v1.7: la enconada atada a su rival todo el turno (P-038).
- [ ] Hito 0a.1b: leer la prueba manual de T40 (¿los rasgos se ven y generan decisiones?) y la métrica 14 como señal temprana. Si algún rasgo no genera decisiones, se revisa antes de la 0a.2.
- [ ] Fuera del MVP (Capa 3): ¿5 posiciones de balanza alcanzan para el juego completo? · Posición inicial de la balanza por clase, entre 2 y 4.

**PARA DIRECTOR CREATIVO:**
- [ ] **v1.7, `Decisiones.md`:** registrar la escala ×10 de vida y daño (11.1). No cambia ninguna regla ni proporción; cambia cómo se leen los números en pantalla (la Ocarra pega 40, el Maestro tiene 200 de vida). Si la Visión cita números de vida o daño, actualizarlos.
- [ ] **Visión v1.3, Escala 3:** registrar la lectura de "el primer contacto llega en la ronda 2" aprobada en la sesión del 07/10: **con la tribu quieta, la primera enemiga ataca en la ronda 2**; pegar antes, yendo a buscarla, es una decisión del jugador (11.3).
- [ ] **Visión 6.2 (corregir):** "formar apretado suma afinidad, pero le da al Tasajero dos presas" no es exacto. Las dos presas salen de **formar con huecos** (cruz, L, diagonales: esquinas cóncavas). El bloque cierra las esquinas y da afinidad, pero pega con menos golpes (11.2.3). El dilema queda: **el bloque aguanta, rodear mata y expone**.
- [ ] **Visión 11:** cerrar "Con vecinas en 8: ¿bajan el bono de afinidad y la probabilidad de incidente?" (no: 10.3 y 10.4) y "Despliegues de A a H en 12 × 12" (criterios en 11.9; coordenadas aprobadas en P-030). Cerrar también "Regla de IA del Tasajero" (resuelta desde la v1.3: 11.2.3 y 11.8). **Encabezado de la Visión:** la línea "los números de cada rasgo están pendientes en `Sistema.md` 11.2" ya no rige (11.2.1 a 11.2.3).
- [ ] **Visión 10:** dice "13 métricas"; desde la v1.3 son **14** (11.9). El registro del 03/10 no se toca (fue cierto ese día).
- [ ] Registrar en `Decisiones.md` las decisiones de Sistemas v0.8 a v1.7 que todavía no estén. En especial: "las leales defienden" quiere decir **solo** las leales (v1.1, 9.2); solo se come a una criatura **suelta** (v1.4, 7.7, opción B); la atacante que se va se registra como abandono (v1.5, 13); **el cuerpo mira 4 y el vínculo mira 8**, con la lista de 11.3 (v1.6); la escala ×10 (v1.7).
- [ ] **Visión 6.2** (de la v1.3): Hacerse junco deja **oculto** (no se lo puede elegir como objetivo, sigue visible); Caza recibe +25%; Velocidad por modo; el surco se puede cavar junto a enemigas.
- [ ] **Visión 6.5** (de la v1.4): solo se come a una criatura suelta (7.7).
- [ ] Marcar el Brief del 01/10/2026 como histórico (lo propone el Arquitecto en 10.5; 11.9 ya lo dice).
- [ ] La niebla de guerra queda fuera del MVP (11.2.2). ¿Entra en Ideas en espera?
- [x] ~~D-1: ¿encuesta en E y F?~~ → No (Visión 11 v1.2). Aplicado en 11.9.
- [x] ~~P-024~~ → La Visión 6.4 v1.2 confirma la respuesta de 9.2 (paso 6).

**PARA WORLDBUILDER:**
- [ ] **v1.7, escala ×10:** revisar `es.json` y `Mundo.md` por textos que citen vida o daño con números (tooltips de Hacerse junco "+3", de Caza y cuenta "ataques de 5", del Encono, de la afinidad "+1", la Lanzadera "recibe 1"). Pasarlos a la escala nueva o, mejor, dejarlos sin número y usar un hueco (`{n}`) que llene la pantalla desde los datos.
- [ ] **v1.7, claves sin texto** que dejaron T13 a T21 (`RESUMENES.md`): `marca.enconada`, `marca.acobardada`, `panel.encono`, `panel.obediencia`, `obediencia.tramo.*`, `panel.cadena`, `panel.mana`, `aviso.terminar.debe_atacar_rival` y `aviso.terminar.debe_acercarse`. Con P-038 en la opción A, el aviso `debe_atacar_rival` también describe que la enconada no puede alejarse de su rival en ese turno.
- [ ] **Antes de la prueba manual de T40** (lo pide el Arquitecto en 10.5): reemplazar en `es.json` los tooltips de Hacerse junco y de Caza y cuenta, que describen las reglas viejas ("actúa dos veces por ronda"), y retirar `rasgo.lomo_de_tierra.nombre` y `rasgo.lomo_de_tierra.tooltip`. Un texto equivocado engaña más que un `[FALTA]`.
- [ ] **v1.3, textos nuevos** con las claves que el Arquitecto ya confirmó (`Arquitectura.md` 10.5): `rasgo.surco.*`, `accion.cavar`, `suceso.surco.cavar` y `.cerrar`, `marca.oculto`, `marca.bono`, `suceso.destape.mover`, `.atacar` y `.contacto`, `suceso.pierde_bono`, `aviso.cuenta.umbral` (`{n}`), `suceso.cuenta.cambio` y `aviso.destapar`.
- [ ] **v1.3, nombres:** nombre final del **surco** (provisorio) y del estado **oculto** del Zancajunco (provisorio). Ojo con el choque entre "Caza" (modo de combate) y "Cazando" (hostilidad, 12.10).
- [ ] **v1.3, fichas de `Mundo.md`:** el rasgo del Surcón pasa a ser el surco (sale Lomo de tierra); Hacerse junco cambia (se esconde y no se lo puede elegir como objetivo; ya no es "su primer golpe"); Caza y cuenta pasa a un turno en dos modos.
- [ ] **v1.6, tooltips de relaciones:** si algún texto de afinidad, incidente o cobardía dice "adyacente" o "al lado", tiene que dejar claro que **cuentan las diagonales** (10.3, 10.4, 10.6). Y el del incidente, que la rival en diagonal no recibe el golpe: la criatura se distrae.
- [ ] **v1.4, `Mundo.md` 9.1:** cerrar aviso de rescatistas al comer (sí, 7.7), olvido sin pergamino (sí, 4.5), cortes de etapas de confianza y de golondrinas (aprobados tal cual: 4.5 y 13) y "¿se puede comer a una guardada?" (no, opción B, 7.7). **Retirar la clave `comer.sacar_guardada`.** Cerrar también que las guardadas no pierden lealtad al comerse a una compañera (5.2).
- [ ] **v1.5, la atacante que se va** (9.2, paso 6; Visión 6.4 v1.2): una línea para la mañana de la recuperación en `Mundo.md` 4.6, sin mostrar la ida ("nadie la ve irse; queda su rastro", Visión 7). En el epílogo usa la línea de Abandono (13); la variante "tras atacarte" es opcional.
- [ ] Ataque nocturno (0b): una línea para las sueltas que miran sin defender al Maestro, con variante si **ninguna** lo defiende, y otra para la Centinela no leal ("avisa y se queda quieta") (9.2).
- [ ] Claves de pantalla que dejó T13 sin texto (`RESUMENES.md`, T13): no son de Sistemas, pero conviene revisar las de lealtad (`lealtad.motivo.<evento>`), que nombran los eventos de 5.2.

**PARA ARQUITECTO:**
- [ ] **v1.7, T44 (escala ×10, solo datos, antes de T22):** multiplicar por 10, con su línea en la tabla de cotejo:
  - `especies/*.json`: `vida` y `danio` de las 5 fichas (Rodauva 80/20, Surcón 240/30, Ocarra 120/40, Zancajunco 120/40, Tasajero 300/50); `rasgo.bono_plano` del Zancajunco +30; `danio_plano` del modo Cuenta −10.
  - `tablas/balanza.json`: vida 220/200/180/160/140 y daño 50/40/40/30/30.
  - `tablas/combate.json`: `danio_minimo` 10, `vida_tras_caida` 10, `afinidad_danio_plano` 10, bono del Encono por punto 10, vida al guardar una caída 10 y choque de la Lanzadera 10 (donde viva cada uno).
  - Hechizos (T22): Martillazo `20 + 10 × Poder`, Remiendo `30 + 10 × Poder`. Poder sigue de 1 a 3.
  - Escenarios: F, vida del Maestro 60. G: golpe inicial de 40 (sale de la ficha). Revisar las `_nota` que citen daños.
  - Para la 0b: debilidad del ritual −40, quebranto −10 por día (mínimo 10).
  - **No cambian:** porcentajes, umbrales en %, maná, hambre, lealtad, Encono (contador), movimiento, alcance, velocidad, y los "mínimo 1" de 6.2, 7.6, 7.8 y 12.11.
  - Los tests que leen `datos/` real con números de daño (por ejemplo, el de F en `test_contacto.gd`: "pega 7") pasan a la escala nueva; los de fixtures no cambian salvo que se decida otra cosa.
- [ ] **v1.7, P-040 (cambia código):** el piso del toggle pasa a `max(sin_afines − afines, min(sin_afines, 5))`. Cambia `ChequeoRival._pct_cobardia` y se suma el test del caso.
- [ ] **v1.7, respuestas para pegar en `docs/PREGUNTAS.md`:**
  - P-030: *"`Sistema.md` 11.9 v1.7: opción A. Coordenadas de 12 × 12 aprobadas tal como están, como provisorias (P-007). Se reescribe la línea de referencia de 11.6 B (cada Ocarra va por la unidad que tiene más cerca) y se asienta que en C y H la Ocarra empieza detrás de la Rodauva. No cambia código ni datos."*
  - P-031: *"`Sistema.md` 10.1 v1.7: opción A. Secundar solo con el turno sin usar: aplaza el turno entero. Ya programado así: no cambia código ni tests."*
  - P-032: *"`Sistema.md` 10.1 v1.7: opción A. Al volver, puede Secundar otra vez si queda otra aliada pendiente detrás. Ya programado así: no cambia código ni tests."*
  - P-033: *"`Sistema.md` 10.1 y 11.3 v1.7: opción A. El inicio del turno, el borrado de Erizarse y el cambio de modo corren una vez por ronda; al volver de Secundar el turno sigue. Ya programado así: no cambia código ni tests."*
  - P-034: *"`Sistema.md` 10.4 y 11.2.2 v1.7: opción A. La rival oculta provoca la tirada pero no recibe el golpe; si es la única a su alcance, la criatura se distrae. Ya programado así: no cambia código ni tests."*
  - P-035: *"`Sistema.md` 10.2 v1.7: opción A. El golpe del incidente corta la cadena, no empieza otra y no recibe combo. Ya programado así: no cambia código ni tests."*
  - P-036: *"`Sistema.md` 10.4 v1.7: opción A. 'La acción' son todos los ataques del turno: la distraída pierde los dos y el golpe gasta los dos. Ya programado así: no cambia código ni tests."*
  - P-038: *"`Sistema.md` 10.5 v1.7: opción A. La restricción de casillas de la enconada dura todo el turno. Consecuencia aceptada: el Tasajero enconado en Cuenta casi nunca se retira (riesgo en 14, con la opción B como palanca). Ya programado así: no cambia código ni tests."*
  - P-039: *"`Sistema.md` 10.4 y 10.6 v1.7: opción A. El −50 % de la acobardada rige en todos sus ataques del turno, también en el golpe del incidente. Ya programado así: no cambia código ni tests."*
  - P-040: *"`Sistema.md` 10.6 v1.7: opción B, precisada. Las afines no bajan la cobardía por debajo de 5 %, pero el piso no la sube: `max(sin_afines − afines, min(sin_afines, 5))`. Sin afines, el toggle no cambia nada. Cambia `ChequeoRival._pct_cobardia` y se suma un test."*
- [ ] **v1.7, 10.5:** pasar S-41 a S-44 y A-3 a "Resueltas": S-41 a S-44 confirmadas tal como están programadas (10.5, 10.6, 11.8, 2.2); A-3 aprobada como T44 con la lista de arriba. Sincronizar el encabezado con `Sistema.md` v1.7 y copiarlo a `docs/`.
- [ ] **v1.6, métricas (T23, T33):** la métrica 1 registra **rondas totales, ronda del primer ataque y rondas de pelea**; la métrica 13 se cuenta **desde la ronda del primer ataque**. El umbral de duración de C usa las rondas de pelea (11.9).
- [ ] **v1.4 / v1.5, P-024:** la atacante se va si el combate nocturno termina en derrota, de pie o caída, y su ida no cambia la lealtad (9.2, paso 6). Cambia una condición de `ResultadoCombate.armar` y se suma el caso de derrota al test 11 de T12 → T30.
- [ ] **B.2.1, regla de sincronización:** copiar a `docs/` la Visión **v1.3** y `Sistema.md` **v1.7**.
- [ ] 0b: el reparto de la noche solo ofrece comer a las sueltas (7.7). La atacante que se va tras una derrota entra al registro del epílogo como abandono, con el flag "fue atacante" (13).
- [ ] Escenario G: golpe inicial como ataque normal, 40 de daño con la Ocarra (9.2) → T30.
- [ ] Casos borde de la Lanzadera (1.6) → T22, con el choque de 10.
- [ ] 0b.3: lista de defensoras al empezar el combate nocturno; +1 de victoria solo para las que pelearon; golpe inicial letal termina el combate antes de la ronda 1 (9.2). Variante de escenario `g_sin_leales` (Rodauva y Zancajunco con lealtad 5, misma semilla que G).
- [ ] 0b: registro del epílogo con día del último guardado y flag de compañera inicial; orden de lectura y variante "Solo" (13). Cruce del río con vida mínima 1 (12.11). En los encuentros generados desde las tablas de 11.6, la lista de enemigas sigue el orden de la columna Composición (11.3).
- [ ] Vigentes: todo número de las secciones 1 a 11 es dato editable (11.9); mapa del día, agotamiento, pudrición, confianza, campamento y cierre del día (7.9); contador de días, XP y nivel, hostilidad del Tasajero, tablas de encuentros y estado del río.
- [x] ~~v1.6, geometría, dato de hambre cada 6 rondas, tablero de 12 × 12 y test de contacto~~ → Hechos en T41 a T43. Incidente con la rival en diagonal → T18. Orden del inicio del turno y una tirada por turno → T18, T19.
- [x] ~~P-026 y P-027~~ → Cerradas en T41.
- [x] ~~Corte de la cadena al cerrar la ronda (10.2) → T16~~ → Hecho en T16.
- [x] ~~Rasgos reescritos de la v1.3~~ → Asumidos en el hito 0a.1b (B.2.1, T35 a T40), **antes de T14 y sin paralelo** (decisión del Arquitecto, que la Visión 10 le dejaba).
- [x] ~~Escenarios B a F y H, paso de Erizarse en la IA y K-07, respuestas de la v1.1 y la v1.2 en 10.5, 14 métricas en T23 y T33~~ → Hechos en `Arquitectura.md` v0.8 a v0.22.

**PARA ARTE / UI:**
- [ ] **v1.7:** con la escala ×10, las barras de vida y los números de daño tienen tres cifras en el Tasajero (300). Prever el ancho en la ficha, la cola y el desglose.
- [ ] Previsualizaciones obligatorias de la 0a: % de sellado y de huida, % de incidente por casilla, % de Encono y cobardía, desglose del daño (con el bono del Encono), cola de iniciativa (Caza y Cuenta), umbral de rescate, caídas en riesgo y empuje de la Lanzadera.
- [ ] **v1.6:** al mover una unidad, marcar qué **vecinas** (las 8, con las diagonales) le darían afinidad o riesgo de incidente en la casilla de destino. Sin eso, la regla de las diagonales no se ve.
- [ ] Al declarar la huida, enemigas que actúan antes del cierre y daño máximo sobre el Maestro (11.7).
- [ ] Contador del Encono (0–3) visible sobre la criatura.
- [ ] Antes de dormir, junto al ícono de riesgo (9.1): avisar si el golpe inicial puede tumbar al Maestro y mostrar quiénes lo defenderían (9.2).
- [ ] Marca de quebranto en la barra de vida, con contador.
- [ ] **v1.3** (T40 los resuelve con placeholders; falta el arte): surcos marcados en el tablero, con su dueño; marca **oculto** sobre el Zancajunco (siempre visible para el jugador) y del bono pendiente; modo del Tasajero y su umbral de cambio en la cola; **zona de Caza** visible; aviso al mover una unidad junto a una oculta.
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
| v1.4 | 05/10/2026 | Respuestas al Arquitecto: S-21 a S-26 confirmadas (11.2.2, 11.2.3, 11.3), con la precisión de destapar y pegar; P-024 = S-20: la atacante caída se va en una derrota (9.2). `Mundo.md` 9.1: olvido sin pergamino y etapas de confianza (4.5), aviso de rescatistas al comer y solo se come a una suelta (7.7, opción B), etapas de las golondrinas (13). Prueba C con la tirada de huida (11.6). Riesgos nuevos (14). Encabezado sincronizado con `Arquitectura.md` v0.22. Pendientes (15) |
| v1.3 | 05/10/2026 | Sincronización con la Visión v1.1: pasada única de balance de los rasgos reescritos tras el playtest 0a.1. Nuevas 11.2.1 (el surco: reemplaza a Lomo de tierra; Surcón con vida 24), 11.2.2 (Hacerse junco activa: oculto, +3, no dos turnos seguidos) y 11.2.3 (Caza y cuenta: un turno por ronda, Caza con dos ataques de 5 y +25% recibido, Cuenta con −1 y movimiento partido, Velocidad 8 y 3, cambio con vida ≤ 50%). Tasajero con Daño 5 (11.2). Lanzadera contra ocultas y surcos (1.6). Golpe inicial nocturno sin Hacerse junco (9.2). Cortes de cadena (10.2). Encono: rival oculta y Tasajero enconado en Caza (10.5). Tablero, turno, movimiento y Velocidad por modo (11.3). Fórmula de daño (11.4). Prueba C y encuentros del Vado (11.6). Huida del Tasajero (11.7). IA con cambio de modo, Caza, retirada en Cuenta, Hacerse junco y cavar (11.8). Tasajero de C y H en [3,1], nota de F y métrica 14 con dos umbrales (11.9). Riesgos (14) y pendientes (15) actualizados |
| v1.5 | 05/10/2026 | Sincronización con la Visión v1.2, sin cambios de números ni de reglas ya programadas. La atacante que se va si cae el Maestro: vuelve a ser salvaje y su ida no cambia la lealtad (9.2, 9.3, 11.5); se registra como abandono en el epílogo (13). La prenda no tiene consecuencias y no se registra (3.3). Playtests sin encuesta y medición desde la 0a.2, con el hito 0a.1b para sentir los rasgos; el Brief del 01/10 es histórico (11.9). Pendientes resumidos y puestos al día con `Arquitectura.md` v0.22, `docs/PREGUNTAS.md` y `docs/RESUMENES.md` (15) |
| v1.6 | 07/10/2026 | Sincronización con la Visión v1.3 (geometría y tablero). **El cuerpo mira 4 y el vínculo mira 8:** tabla de adyacencia y vecinas (11.3); afinidad, incidente, toggle de afines y −10 del Maestro con vecinas en 8 (10.3, 10.4, 10.6, 10.7); Hacerse junco, Erizarse de la IA, invocar, cavar y Remiendo con las 4 ortogonales (1.6, 3.1, 11.2.2, 11.8). **Los números de afinidad (+1), incidente (20%) y del toggle no cambian.** Incidente con la rival en diagonal: golpea solo si la alcanza desde su casilla; si no, se distrae (10.4, 5.4). Geometría de las dos presas reescrita: el bloque cierra las esquinas, rodear las abre (11.2.3). Tablero de 12 × 12 con cámara móvil, zonas de despliegue y **contacto en la ronda 2** (definición, distancia estándar 8, rondas de pelea) (11.3). Hambre de combate cada **6** rondas (7.2). Líneas de 11.6 en rondas de pelea. Criterios de despliegue por escenario (E a distancia 10, G en 8 × 8), coordenadas a cargo de Claude Code con aprobación de Sistemas, bandos cruzados aceptados (11.9). Métrica 1 con ronda del primer ataque y rondas de pelea; métrica 13 desde el primer ataque; umbral de C en rondas de pelea (11.9). P-026 y P-027 respondidas, opción A; numeración de pasos corregida en los desempates (11.8). Riesgos nuevos: bloque de 2 × 2, afinidad que acorta C, Cuenta con espacio y golpe primero en la ronda 1 (14). Pendientes (15) |
| v1.7 | 08/10/2026 | **Escala ×10 de vida y daño** (A-3; tabla de qué escala y qué no en 11.1): fichas (11.2), balanza y sus fórmulas (1.2, 7.8), hechizos `10 × (base + Poder)` y choque de la Lanzadera 10 (1.6), planos de afinidad, Encono, Hacerse junco y Cuenta (10.3, 10.5, 11.2.2, 11.2.3, 11.4), daño mínimo 10 y vida 10 al levantarse o al guardar una caída (11.4, 11.5), ritual y quebranto (3.3, 6.1); la regla de los eslabones no cambia (10.2); ejemplos de 9.2, 11.4 y 11.6 recalculados y aviso de Saciado en la Rodauva resuelto. Respuestas: P-030, coordenadas de 12 × 12 aprobadas, con Prueba B reescrita y la Ocarra de C y H detrás de la Rodauva (11.6, 11.9); P-031 a P-033, Secundar con el turno sin usar, otra vez si queda aliada detrás, inicio del turno una vez por ronda (10.1, 11.3); P-034 a P-036, rival oculta en el incidente, golpe del incidente sin cadena y "la acción" son todos los ataques (10.2, 10.4); P-038, opción A: la enconada queda atada a su rival todo el turno (10.5, 11.2.3, 11.8, riesgo nuevo en 14); P-039, −50% de la acobardada también en el incidente (10.6); P-040, piso del toggle que no sube la cobardía (10.6); S-41 a S-44 confirmadas (2.2, 10.5, 10.6, 10.7, 11.8). Pendientes (15) |
