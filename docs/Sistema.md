# SISTEMA — Reglas, números y balance

> **Estado:** Borrador v0.6 · **Dueño:** Diseñador de Sistemas y Balance · **Última actualización:** 01/10/2026
> Este documento baja a números lo definido en `00_Vision.md`. Si algo acá contradice la Visión, manda la Visión: se propone el cambio y se registra en `Decisiones.md`.
> Los nombres del juego (Arrimo, Encono, Secundar, péñola, prenda, Urdimbre, "lo que diste", Erizarse, Lomo de tierra, Alabarda, Hacerse junco, Caza y cuenta, Martillazo, Lanzadera, Remiendo, Leña en las púas, Sueño liviano, Madriguera, Acecho, Poza Tibia) son finales y viven en `Mundo.md` (1.2, 2.8, 4.5 y 4.7). "Malherido" sigue siendo *(provisorio)*. Los marcados como *(provisorio)* esperan la confirmación del Worldbuilder.

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

**Experiencia** — fuentes `DECIDIDO` (Visión 6.1); números `PREGUNTA ABIERTA`:

| Fuente | Peso | Regla |
|---|---|---|
| Hitos de la tribu: una criatura llega a Leal por primera vez, una captura, un ritual | Alto | Es la fuente principal: el Maestro crece cuando crece su tribu |
| Ganar un combate | Bajo | Que el combate no pierda sentido (Pilar 1), sin empujar a buscar peleas |
| Comerse una criatura | 0 | Nunca da experiencia |

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

| Evento | Cambio | Decisión que genera |
|---|---|---|
| Pelearon juntos y ganaron | +1 | El Maestro se gana a su tribu peleando a su lado |
| Muere o es comida otra criatura del grupo | −2 a todas (−4 si eran afines) | Toda pérdida tiene costo social |
| El Maestro se come a una criatura | −3 adicional a todas las sueltas | La decisión más dura del juego tiene que doler |
| El Maestro se come a una criatura que lo atacó | Solo −2 a todas (sin el −3 extra) | El grupo vio la traición |
| El Maestro perdona a una criatura que lo atacó | +1 a las leales | La clemencia fortalece a la tribu |
| Rescató al Maestro | +2 | Refuerza la regla de oro |

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
| Malherido *(provisorio)* | Al terminar la recuperación (ver abajo) |
| Las caídas | **Mueren**: la rescatista solo puede cargar al Maestro. Sus pergaminos arden y se aplica "muerte en el grupo" (5.2). Las que el Maestro guardó antes de caer sobreviven en su pergamino (11.5) |
| Sin rescatista | Permadeath |

### 6.1 Malherido: la secuela — `DECIDIDO` (Visión 6.6)

| Regla | Valor | Decisión que genera |
|---|---|---|
| Efecto | No regenera vida ni maná: no cura ni recupera maná al dormir, ni regenera maná por turno en combate | Cada combate en el camino se pelea con lo que queda |
| Secuela | **−1 de vida máxima real por día** (al cerrar el día, paso 7 de 7.9), mínimo 1 | ¿Voy directo a la Poza o junto comida antes? |
| Permanencia | Lo perdido **no vuelve**: la vida máxima real queda reducida. Todos los porcentajes de vida se calculan sobre el nuevo valor (7.8) | La tardanza se paga para siempre |
| Cura | Bañarse en la **Poza Tibia** (Vado) devuelve la regeneración | — |
| Si nunca va | Termina con 1 de vida máxima | — |

**Malherido no es un estado negativo**: es una marca en la barra de vida con su contador, como "lo que diste".

**Distancia:** Molino → Huertos → Vado son 2 días. Con la balanza en 2, en el mejor caso pierde **1 punto** (cierra un día en los Huertos y se baña al llegar al Vado, antes del cierre): queda con 19 de vida máxima real.

### 6.2 Recuperación y Poza Tibia — `PROPUESTA`

| Regla | Valor propuesto | Decisión que genera |
|---|---|---|
| Días de recuperación | **2**, en el Molino. Cada día se cierra como un día en el Molino sin exploración: se reparte comida del inventario y se chequea el abandono | La tribu tiene que haber guardado comida para sostenerlo |
| Vida al terminar | 25% de la vida máxima real (redondeado hacia abajo, mínimo 1) | Sale débil y sin regenerar |
| Poza Tibia | Mientras el Maestro está malherido, el mapa del Vado reemplaza **La crecida** por **La Poza Tibia**. Bañarse ocupa ese nodo; no tiene encuentro | Un nodo de comida menos el día que se cura |
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

### 7.2 Cuánto sube — `DECIDIDO`

| Fuente | Cantidad | Decisión que genera |
|---|---|---|
| Fin del día (al dormir) | Según el apetito (7.3) | ¿Cuántas bocas puedo sostener afuera? |
| Combate | +1 al cerrar las rondas 5, 10, 15…, al Maestro y a las criaturas sueltas en el tablero. La obediencia, la regeneración y el estado de hambre se recalculan en el acto | Cerrar rápido o arriesgarse: una leal puede pasar a Hambrienta en pleno combate |
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

1. Lealtad diaria según la cobertura de comida (5.2).
2. Chequeo de abandono o ataque de una criatura propia (9.1). Si hay ataque, se resuelve el combate (9.2).
3. **Emboscada**: solo al raso y si no hubo ataque propio (9.4).
4. Recuperación de maná (2.2 y 2.4) y de vida (7.8): a la mitad si hubo combate nocturno; las guardianas no se curan y el Maestro guardián recupera 2 de maná menos (9.4).
5. Daño por terminar famélico (7.6).
6. Suma del hambre del día según el apetito (7.3).
7. Avance de contadores: enfermedades (8.3), debilidad del ritual (3.3), malherido (6.1), dieta monótona (1.5), agotamiento y pudrición (12.5), confianza (4.5).

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
- Afectan igual al Maestro y a las criaturas.

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

1. La criatura golpea primero: daño gratis al Maestro, salvo que haya una Ocarra suelta que no sea la atacante (Centinela, 12.6).
2. Empieza un **combate donde se duerme**: el Molino o el campamento al raso (9.4). Participan las criaturas sueltas; las leales pelean del lado del Maestro.
3. Durante el combate, la atacante se trata como **salvaje**: obediencia ≤ 3 y sin Arrimo (10.7).
4. El Maestro pelea con el maná del sueño interrumpido (2.4).
5. A diferencia de una salvaje, la atacante **no huye** al llegar a 0 de vida: queda **caída** y el Maestro decide su destino (9.3).
6. Si el Maestro cae en este combate, rige 11.5: si hay rescatista, el Maestro queda en recuperación (ya está en el Molino); las caídas de la tribu mueren y **la atacante se va** (su pergamino arde, como en un abandono). Sin rescatista, permadeath.

### 9.3 Destino de la atacante derrotada — `DECIDIDO`

Queda **caída** y el Maestro elige. En las tres salidas, **su pergamino arde**.

| Opción | Efecto |
|---|---|
| Perdonar | Se va libre y vuelve a ser salvaje. Las leales ganan +1 |
| Sellar | Resellado (4.4): costo de invocar y un pergamino en blanco. Vuelve guardada con lealtad 1 |
| Comer | Rango × 2 raciones de carne. −2 a todas, sin el −3 extra |

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
| Base: Huertos / Vado / Robledal | 10 / 20 / 30 |
| Cada guardia sin cubrir | +10 |
| Fuego | −10 (Robledal: +10) |
| Madriguera (habilidad) | −10 |
| Mínimo fuera del Molino | 5% |

| Si ocurre | Efecto |
|---|---|
| Cuándo | Cae en una de las 3 guardias, al azar |
| Guardia cubierta | Alarma: el combate empieza normal |
| Guardia sin cubrir | **Ronda de sorpresa**: en la primera ronda solo actúan las salvajes |
| Quiénes atacan | Salvajes del destino, con el tope de amenaza de sus encuentros (11.6). En el Robledal, el Tasajero según su hostilidad |
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
| Actúa una enemiga (cada turno del Tasajero cuenta) | Una acción aliada que no es ataque: moverse, Lanzadera, Remiendo, Erizarse, guardar, esperar |
| Un aliado ataca a otro objetivo (incluido el golpe de un incidente) | — |
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

**Decisión que genera:** juntar rivales es un riesgo chico con una tribu leal y bien alimentada, y un peligro con una hambrienta.

### 10.5 Rival enemiga: Encono — `DECIDIDO`

Aplica a las criaturas **de combate y mixtas**. Las de trabajo usan la cobardía (10.6).

| Regla | Valor | Decisión que genera |
|---|---|---|
| Contador | Encono de 0 a 3 por criatura | — |
| Enconarse | Al inicio de su turno, con una rival enemiga **a su alcance** (distancia Manhattan ≤ Movimiento + Alcance; misma definición para la cobardía): 25% + 25% por punto · −5 por paso de Arrimo · ±10 según obediencia (5.4) | El jugador ve la probabilidad antes de acercarla |
| Enconada | Su acción queda fijada en atacar a esa rival, con +1 de daño por punto. **El jugador elige la casilla** (y la rival, si hay varias). Si no llega, se acerca lo más posible y pierde la acción | Usarla como cazadora de su rival a cambio de perder el control del objetivo, no de la posición |
| Cada golpe a la rival | +1 de Encono (máx. 3); con 3, queda enconada seguro | Cuanto más pega, más se ensaña |
| Fin del combate | El Encono vuelve a 0 | — |


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

> `PROPUESTA` a testear (toggle en el escenario E de la Prueba 0a, 11.9): cada afín adyacente resta **−10 puntos** a la cobardía (máximo −20), con un **mínimo de 5%**. Ejemplo: Rodauva leal con la balanza en 2, junto a dos Rodauvas: 25% → 5%. Anticipa la barra de zozobra.

### 10.7 Criaturas salvajes — `DECIDIDO`

Siguen las mismas reglas de rivalidad, Encono y cobardía. No tienen lealtad: se tratan como **obediencia ≤ 3** y sin Arrimo. Si ocurre un incidente, siempre se atacan entre ellas.

**Decisión que genera:** atraer a una Ocarra salvaje hacia un Zancajunco salvaje es una táctica legítima.

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
| **Rodauva** | Trabajo | 1 | 8 | 2 | 4 | 1 | 6 | **Erizarse** (acción): hasta su próximo turno recibe −50% de daño y no se mueve |
| **Surcón** | Trabajo | 2 | 18 | 3 | 2 | 1 | 2 | **Lomo de tierra** (pasiva): −1 a cada golpe recibido, mínimo 1 |
| **Ocarra** | Combate | 1 | 12 | 4 | 3 | **2** | 7 | **Alabarda**: su alcance 2 es el rasgo |
| **Zancajunco** | Mixto | 2 | 12 | 4 | 4 | 1 | 8 | **Hacerse junco** (pasiva): +2 de daño en su primer ataque del combate |
| **Tasajero** | Combate | 3 | 30 | 6 | 4 | 1 | 8 y 3 | **Caza y cuenta**: dos turnos por ronda; aparece dos veces en la cola, con las marcas Caza y Cuenta |

La vida y el daño del Maestro siguen la balanza (tabla 1.2). Su Movimiento, Alcance y Velocidad no dependen de ella.

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
| Turno de una unidad | **1 movimiento y 1 acción**, en cualquier orden, sin partir el movimiento. Acciones: atacar, hechizo, sellar, guardar, Erizarse, esperar. Invocar y huir gastan el turno completo | ¿Pego y me retiro, o me acomodo y pego? |
| Movimiento | Solo ortogonal. Se atraviesan aliadas y caídas propias, nunca enemigas. No se termina en una casilla ocupada | Las enemigas funcionan como muro; un pasillo protege |
| Distancias | Todas **Manhattan** | — |
| Despliegue | El jugador ubica a sus sueltas en las **2 filas de su borde**; las salvajes ocupan las 2 filas opuestas | La formación inicial ya es una decisión |
| Adyacencia | 4 casillas ortogonales (coherente con los sprites en 4 direcciones). Rige afinidad, incidentes, Arrimo del Maestro adyacente y guardar en combate | Las diagonales no dan afinidad: formar en cruz, no en bloque |
| Orden | Mayor Velocidad primero, **sin azar** | El jugador planifica la ronda entera |
| Empates | Bando del jugador antes que el enemigo · El Maestro antes que sus criaturas · Entre criaturas, el orden de la tribu (lo define el jugador fuera del combate) | Predecible |
| Criatura invocada | Entra en la cola **a partir de la ronda siguiente** | Invocar en combate cuesta el turno del Maestro y una ronda de la criatura: conviene sacarla antes, y eso cuesta comida |
| Alcance 2 | En línea recta; puede golpear **por encima de una aliada**, nunca por encima de una enemiga | Segunda fila detrás del Maestro |

### 11.4 Fórmula de daño — `DECIDIDO`

1. Se **suman todos los porcentajes**: bono de combo, Saciado, enfermedades, cobardía, Erizarse.
2. Se aplican al Daño base y se redondea hacia abajo.
3. Se suman los **bonos planos**: afinidad (+1), Encono (+1 por punto), Hacerse junco (+2), Lomo de tierra (−1).
4. **Mínimo 1.**

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
- No actúa, no da afinidad, no cuenta para combos ni Arrimo, y no puede rescatar.
- **El Maestro puede guardarla**: gasta su acción y el costo de invocar del rango (2 / 3 / 4, con descuento y mínimo 1), a distancia ≤ 2. Queda guardada con **1 de vida** y, como toda guardada, no se cura hasta salir. Si después el Maestro cae o huye, **sobrevive** en su pergamino.
- El Remiendo no afecta a las caídas (1.6).
- El combate se **gana** cuando no queda ningún enemigo en pie y se **pierde** cuando cae el Maestro.
- Una criatura que sube de caída a 1 de vida tiene la misma curación nocturna que las demás (7.8).

**Motivo:** con la Rodauva en 8 de vida, una Ocarra salvaje puede tumbarla en dos golpes el día 1. Con la caída, la compañera muere solo si el Maestro también cae.

**Decisión que genera:** guardar a una caída compite por el maná con el Martillazo, el Remiendo y sellar. Es la forma de no abandonarla si hay que huir.

### 11.6 Encuentros de referencia — `DECIDIDO`

**Prueba A — Día 1: Maestro + Rodauva (Neutral) contra 1 Ocarra salvaje.** Orden: Ocarra (7), Rodauva (6), Maestro (5). La cadena sale sola. Bono: "sin relación" + 3 pasos de Arrimo = **+50%**.

| Ronda | Ocarra | Rodauva | Maestro (eslabón 2) | Vida de la Ocarra |
|---|---|---|---|---|
| 1 | Maestro 20 → 16 | 2 | 6 | 12 → 4 (33%: sellado al 50%) |
| 2 | Maestro 16 → 12 | 2 → queda en 2 (≤ 25%) | Sella al **80%** por 3 de maná | — |

El Maestro termina con 12/20 y esa noche cura 5. **Decisión que aparece:** ¿sello al 50% o dejo que la Rodauva pegue una vez más y aguanto otra ronda de golpes?

**Prueba B — 2 Ocarras en los Huertos:** el Maestro recibe 8 por ronda, la pelea dura unas 4 rondas y cae sin rescatista. Es un muro.

**Prueba C — Tasajero:** pega 12 por ronda; un Maestro solo dura 2 rondas. Con Ocarra (Encono) + Zancajunco + Maestro, la tribu le hace unos 15 por ronda: la pelea dura 2 o 3 rondas. Va directo por la Rodauva, así que **llevar a la compañera al Robledal es una apuesta real**.

**Tope de amenaza por destino:**

| Destino | Regla |
|---|---|
| Huertos de Almiar | Como máximo **1 salvaje de combate** por encuentro. Las salvajes de trabajo no inician combate: se enrollan o huyen |
| Vado de los Juncos | `PREGUNTA ABIERTA` (referencia: Zancajunco + Ocarra salvajes, que son rivales entre sí, 10.7) |
| Robledal Hondo | El Tasajero; su hostilidad modifica el encuentro (pendiente) |

### 11.7 Huida — `DECIDIDO`

**El Maestro:**

| Regla | Valor | Decisión que genera |
|---|---|---|
| Cuándo | En su turno, desde cualquier casilla | — |
| Costo | Gasta su **turno completo**. El combate termina **al final de la ronda**: los enemigos que faltan todavía actúan | Para guardar a una caída y huir hacen falta dos turnos: hay que planear con una ronda de anticipación |
| Quiénes se van | El Maestro y las criaturas de pie | — |
| Caídas en el tablero | **Mueren**: sus pergaminos arden y se aplica "muerte en el grupo". Las guardadas sobreviven | Huir sin guardarlas es abandonarlas |
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
| Tasajero | 25% |

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
3. **Remate:** si puede tumbar a alguna unidad este turno, ataca a esa. Si hay varias, la de menos vida actual.
4. **Cercana:** si no, ataca a la unidad más cercana que pueda alcanzar; si empatan, la de menos vida.
5. **Acercarse:** si no alcanza a nadie, se mueve hacia la unidad más cercana.

**Reglas fijas:** una acobardada no termina su movimiento más cerca de su rival; la Ocarra ataca desde distancia 2 si puede; nadie apunta a una caída; las salvajes no Secundan.

**Decisión que genera:** dejar a una herida expuesta es invitar al remate. ¿La retiro, la guardo o la cubro con el Surcón?

**Alternativas descartadas:** "la más cercana" (combates resolubles de memoria) y "el Maestro primero" (empuja a esconderlo, sección 8 de la Visión).

### 11.9 Prueba 0a — `DECIDIDO`

Rebanada de combate aprobada el 01/10/2026: tablero, relaciones, sellado, caída y rescate. Lo que no entra se carga como **parámetro del escenario** (lealtad, hambre, Saciado, enfermedades, balanza, Poder, Regeneración, vida y maná de entrada). Se juega con **escenarios fijos + panel de parámetros + semilla de azar fija**. El brief completo para el Arquitecto vive en el doc "Brief para el Arquitecto — Prueba 0a".

| Escenario | Configuración | Qué mide | Señal de alarma |
|---|---|---|---|
| A. Día 1 | Prueba A (11.6) | ¿Sello al 50% o arriesgo una ronda más? | Siempre se elige lo mismo |
| B. Muro | Prueba B (11.6) | ¿Reconoce que hay que huir? ¿Guarda a la caída antes? | Huir nunca se lee como opción |
| C. Tasajero | Prueba C (11.6), tribu leal | Duración (meta: 2 o 3 rondas) · ¿Llevo a la Rodauva? | Más de 5 rondas, o la Rodauva muere sin decisión |
| D. Rivales aliadas | Ocarra + Zancajunco en la tribu; Normal y después Hambriento | Incidentes por combate · ¿Separa con la Lanzadera? | 0 incidentes, o castigo puro |
| E. Cobardía | Rodauva leal contra el Tasajero, con y sin Maestro al lado; toggle de afines (10.6) | ¿Sostiene a la asustada? | Nunca aparece, o frustra siempre |
| F. Rescate | Maestro con 6 de vida, 1 leal y 1 Neutral, encuentro duro | ¿Guarda caídas antes de caer? ¿Entiende quién lo salva? | El rescate se siente azaroso |
| G. Ataque nocturno | Ocarra desleal atacante; maná de entrada a la mitad (2.4) | Las 3 salidas (9.3) · ¿Alcanza para resellar? | Comer es siempre la respuesta |
| H. Soplo | C con balanza 5 y Poder 3 | ¿El Soplo es una build trampa? | Pierde siempre, o gana más fácil que el Barro |

**Métricas por combate:** rondas, usos de Secundar, eslabones promedio, incidentes, Encono y cobardía, sellados intentados y logrados, salvajes que huyeron antes del sellado, caídas, caídas guardadas, muertes, rescates y **distancia media del Maestro a la enemiga más cercana** (vigila el Martillazo).

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
| Colgadero (robar) | Robledal | Carne | 4 | — (hostilidad: pendiente) |

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
| Ocarra | Centinela | Revela la composición de los encuentros del mapa del día · En el ataque de una criatura propia, anula el golpe gratis si ella no es la atacante | No se acumula |

**Pilar 2:** las de trabajo producen comida; la mixta, solo en el Vado; la de combate da información y seguridad.

### 12.7 Composición de referencia del mapa del día (8 nodos) — `DECIDIDO` (valores de test)

| Destino | Nodos |
|---|---|
| Huertos | Frutal ×2 · Huerta · Granero · Palomar (péñola) · Bajo el manzano · Encuentro (máx. 1 salvaje de combate) · Hornacina (primera visita) o El corral caído (desde la segunda) |
| Vado | Pesca ×2 · Orilla · Charco quieto (agua) · Algo se movió en el juncal · El surco que ronca · Encuentro · La crecida (La Poza Tibia mientras el Maestro está malherido, 6.2) |
| Robledal | Colgadero · Rodeo de las zarzas · Roble Viejo (ramita) · Hongos ×2 · Encuentro (Tasajero, según hostilidad) · Paso ×2 |

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

---

## 13. Combinaciones rotas y riesgos

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
| **Malherido sin maná** camino a la Poza | Intencional | No sella ni invoca hasta curarse: la tribu suelta lo tiene que sostener. Si es un callejón sin salida, permitir la regeneración por turno en combate |

---

## 14. Pendientes

**PARA SISTEMAS (próximas sesiones, en este orden):**
- [ ] Tasajero: hostilidad, robo y ofrenda del colgadero (qué comida vale, cuánta y cuánto baja la hostilidad), si vuelve tras ser derrotado o tras huir, efecto de la Rodauva suelta y del fuego.
- [ ] Encuentros del Vado (tope de amenaza) y composición de las emboscadas por destino.
- [ ] La crecida: efecto mecánico y si cierra el paso al Robledal ese día.
- [ ] Experiencia: cuánta da cada fuente y cuánta hace falta por nivel (1.4).
- [ ] ¿5 posiciones de balanza alcanzan para el juego completo?
- [ ] Capa 3: posición inicial de la balanza por clase, entre 2 y 4 (nunca en un polo).

**PARA DIRECTOR CREATIVO:**
- [ ] Registrar la división 0a/0b en la Visión (secciones 10 y 11).
- [ ] ¿El 0a usa vista isométrica real o una cenital de prueba?
- [ ] Aprobar la recuperación y la Poza Tibia (6.2, `PROPUESTA`).
- [ ] Confirmar la lectura de malherido (6.1): "no regenera maná" incluye el maná que se recupera al dormir.

**PARA WORLDBUILDER:**
- [ ] Textos de la criatura distraída por su rival aliada y de la que la ataca (sirven placeholders en el 0a).
- [ ] Texto del baño en la Poza Tibia y nombre final de "malherido".

**PARA ARQUITECTO:**
- [ ] Prueba 0a (11.9): motor, plataforma y formato de datos y de escenarios. Todo número de las secciones 1 a 11 es dato editable.
- [ ] Reglas de combate nuevas: estructura del turno, movimiento y despliegue (11.3), corte de combos (10.2), afinidad no acumulable (10.3), incidente al inicio del turno (10.4), alcance y enconada (10.5), IA de remate (11.8), rescatista (6).
- [ ] Hechizos: Martillazo (distancia Manhattan sin bloqueo), Lanzadera (línea con bloqueo por enemigas, choque con 1 de daño), Remiendo.
- [ ] Malherido: contador de días y reducción permanente de `vida_max_real`.
- [ ] 0b: mapa del día de 4 columnas × 2 nodos con composición por destino como datos (incluidos los nodos que cambian por estado: hornacina/corral, crecida/Poza); agotamiento; raciones con fecha de pudrición; marcas "podrida" y "dudosa"; confianza por nodo de avistamiento; campamento y cierre del día en el orden de 7.9.

**PARA ARTE / UI:**
- [ ] Previsualizaciones obligatorias del 0a: % de sellado y de huida, % de incidente por casilla, % de Encono y cobardía, desglose del daño, cola de iniciativa (Caza y Cuenta), umbral de rescate, caídas en riesgo, empuje de la Lanzadera.
- [ ] Marca de malherido en la barra de vida, con contador.
- [ ] 0b: rendimiento previsto de cada nodo; días de cada ración perecedera; pantalla del campamento.

---

## 15. Registro de cambios

| Versión | Fecha | Cambio |
|---|---|---|
| v0.1 | 30/09/2026 | Creación: magia, maná, pergaminos, captura, lealtad, rescate y hambre en combate |
| v0.2 | 30/09/2026 | Sincronización con la Visión v0.3 (balanza, Tasajero). Liderazgo (1.3), progresión `PROPUESTA` (1.4) y dieta del Maestro (1.5). Maná nocturno (2.4). Rangos del MVP y resellado (4.3, 4.4). Lealtad diaria por cobertura y obediencia (5.2, 5.4). Escala de hambre, apetito, raciones, bichos, muerte por hambre y comer criaturas (7). Estado Enfermo acumulable con cura (8). Abandono y ataque nocturno (9). Iniciativa, Esperar, combos, afinidad, incidentes, provocación y salvajes (10). Riesgos actualizados (11) |
| v0.3 | 01/10/2026 | Sincronización con la Visión v0.4: balanza Barro ↔ Soplo, Arrimo, Encono y Secundar (provisorios); progresión por nivel `DECIDIDO`; balanza inicial en 2 (1). Magia fuera del combate (2.5). Sección 3 ampliada: pergaminos iniciales, quema y ritual de sangre con materiales y costo en sangre. Resellar con costo de invocar y pergamino en blanco (4.4). Zancajunco acepta carne (7.4). Vida máxima real y vigente, curación al dormir (7.8) y orden del cierre del día (7.9). Cobardía de las criaturas de trabajo (10.6). Riesgos actualizados (11) |
| v0.4 | 01/10/2026 | Sincronización con la Visión v0.5: nombres finales (Arrimo, Encono, Secundar), péñola, prenda, Urdimbre y "lo que diste" (3.3); mixtas se enconan (10.5). Compañera inicial (3.4). Caída del Maestro en combate y caídas (6, 9.2). Nueva sección 11: estadísticas, fichas, tablero e iniciativa, fórmula de daño, vida en 0 y encuentros de referencia. Riesgos pasa a 12, Pendientes a 13 y Registro a 14 |
| v0.5 | 01/10/2026 | Sincronización con `Mundo.md` v0.4: nombres finales de los rasgos y relaciones dentro de la especie (10.8). Hechizos de la clase inicial `PROPUESTA` (1.6). Guardar a una caída con maná (2.3, 3.1, 11.5). Hambre e inventario iniciales (3.4). Camino de confianza (4.5). Raciones podridas, dudosas y sin fuego (7.4). Cierre del día con emboscada (7.9). Enfermo por comida podrida y sin cocinar (8.1); descanso solo en el Molino (8.3). Campamento al raso: guardias, fuego, emboscadas y habilidades de campamento del Maestro (9.4). Afines contra la cobardía `PROPUESTA` (10.6). Huida del Maestro y de las salvajes (11.7). Nueva sección 12: mapa, día, nodos, rendimiento, rebuscar, agotamiento, pudrición, pasivas, rodeo y presupuesto. Riesgos pasa a 13, Pendientes a 14 y Registro a 15 |
| v0.6 | 01/10/2026 | Sincronización con la Visión v0.7 y `Mundo.md` v0.5: hechizos y rasgos `DECIDIDO` con nombres finales (1.6, 11.2); Madriguera (9.4); fuentes de experiencia (1.4). Malherido (6.1) y recuperación con Poza Tibia `PROPUESTA` (6.2). Avistamientos del Surcón y la Ocarra (4.5, 12.7). Reglas de combate de la Prueba 0a: regeneración al inicio del turno (2.1), invocar adyacente (3.1), sellar en combate (4.1), rescatista (6), hambre en combate (7.2), salvajes no Secundan (10.1), corte de combos (10.2), afinidad no acumulable (10.3), incidente (10.4), alcance y enconada (10.5), turno, movimiento, distancias y despliegue (11.3). Nuevas 11.8 (IA de remate) y 11.9 (Prueba 0a). Riesgos y pendientes actualizados |
