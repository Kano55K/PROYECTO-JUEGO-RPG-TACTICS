# 00 — VISIÓN DEL JUEGO

> **Estado:** v1.6 — **MVP definido, rasgos en revisión** · **Dueño:** Director Creativo · **Última actualización:** 13/10/2026
> **Para Sistemas:** la v1.1 reescribe los rasgos de combate (6.2). Los números de cada rasgo están pendientes en `Sistema.md` 11.2; mientras tanto, rige la dirección de diseño de 6.2. La v1.3 cambia la geometría de las relaciones (vecinas en 8) y el tablero de referencia (12 × 12): ver Escala 3. La v1.4 agrega **los Legados y sus Sombras** a Ideas en espera (10). La v1.5 define **qué da cada uno de los 18 legados** (verbo y perfil de atributos), el boceto de estadísticas del juego completo y las reglas nuevas de generación e inversión (10). La v1.6 agrega **Más allá de Valdelumbre** a Ideas en espera (10), enmienda la sección 8 (coleccionar es el camino del Soplo) y reordena las Capas 4 y 5. Ni la v1.4, ni la v1.5, ni la v1.6 tocan el MVP ni la 0a.
> Este documento es la fuente de verdad. Ningún agente puede contradecirlo sin proponer un cambio y registrarlo en `Decisiones.md`.
> **Documentos subordinados:** `Sistema.md` (reglas y números) · `Mundo.md` (mundo, regiones y criaturas) · `Arquitectura.md` (decisiones técnicas y plan de construcción). Este documento define **qué** y **por qué**; los números viven en `Sistema.md`, y el detalle del mundo, en `Mundo.md`.
> **`Decisiones.md` es el historial, no la fuente de verdad:** registra cómo se llegó a cada regla. Queda fuera de `docs/` (Claude Code no lo lee) y es opcional en el conocimiento del proyecto.
> Los nombres marcados como *(provisorio)* esperan la confirmación del Worldbuilder.

---

## 1. Título de trabajo

**[PENDIENTE]** — Nombre provisorio hasta definir la identidad del mundo. La región inicial ya tiene nombre: **Valdelumbre**.

## 2. Pitch en una frase

Un juego táctico por turnos en 2D isométrico donde sobrevivís en un mundo medieval junto a criaturas que capturás, domesticás y cuidás… hasta que el hambre te obliga a decidir si son tus compañeras o tu comida.

## 3. Género y referencias

**Género:** Tactics RPG por casillas + captura de criaturas + supervivencia con permadeath condicional.

**Referencias (inspiración, no copia):**
- *Final Fantasy Tactics / Triangle Strategy* → combate por casillas en vista isométrica.
- *Darkest Dungeon* → grupo frágil, mapa de nodos, decisiones con consecuencias.
- *Don't Starve / Rimworld* → supervivencia donde el tono amable esconde decisiones brutales.
- *The Legend of Zelda* → calidez, aventura y sentido de descubrimiento.
- *Juegos de captura de criaturas* (Cassette Beasts, Temtem) → género libre.

**Restricción legal:** todas las criaturas, nombres, tipos, mecánicas emblemáticas y diseños son 100% originales. Nada de Pokémon ni de ninguna otra franquicia.

## 4. Pilares de diseño

Toda idea nueva se evalúa contra estos pilares. Si no refuerza al menos uno, no entra.

### Pilar 1 — El Maestro también pelea
El jugador no es un espectador. El Maestro de Criaturas tiene clase, habilidades, magia y combate cuerpo a cuerpo. Ocupa una casilla en el tablero y pelea junto a su grupo.

### Pilar 2 — Cada criatura es una decisión
Las criaturas fuertes en combate son peores trabajando, y al revés. No existe el equipo perfecto, solo el adecuado para la situación.

### Pilar 3 — Tu grupo es una tribu, no una colección
Las criaturas tienen lealtad hacia el Maestro y relaciones entre sí (afinidades y rivalidades). Gestionar la convivencia es parte central del juego.

### Pilar 4 — Calidez con dientes
El mundo es luminoso y aventurero, pero la supervivencia no perdona. El hambre puede llevar a comerse una criatura, a que una criatura te ataque, o a que se maten entre ellas.

### Regla de oro
**Tu vida depende de cómo trataste a tu grupo.** La lealtad acumulada decide si alguien te salva cuando caés.

## 5. Estructura del juego (tres escalas + campamento)

### Escala 1 — Mapa del mundo
- Mapa **fijo**, diseñado a mano. La región del MVP es **Valdelumbre** (ver `Mundo.md`).
- El jugador elige un destino y avanza **una casilla por día**.
- Cada día consume recursos (comida, energía, tiempo). Es el reloj de supervivencia.
- Al dormir, el Maestro recupera maná (ver 6.7) y se resuelven los eventos nocturnos: el **abandono**, el **ataque nocturno** (ver 6.4) y, fuera del Molino, la **emboscada** (ver 6.9).
- Fuera del Molino se duerme **al raso**: guardias, fuego y riesgo de emboscada (ver 6.9).

### Escala 2 — Mapa de nodos (la locación)
- Al llegar a un destino se abre un mapa de nodos para explorar el lugar.
- Cada día se recorren **4 nodos**, uno por columna: cada elección es un trueque entre comida, material, criatura y pelea.
- Los nodos contienen **eventos al azar**: recolección, criaturas salvajes, peligros, decisiones morales, encuentros.
- Las criaturas sueltas pueden cambiar lo que pasa en un evento (por ejemplo, una que espanta a otra).
- Cada destino ofrece uno de los **materiales del ritual de los pergaminos** (ver 6.7).
- Aquí vive la variedad y la rejugabilidad.
- Un destino explorado días seguidos **se agota**, y parte de la comida **se pudre**: quedarse siempre en el mismo lugar no es una estrategia.

### Escala 3 — Tablero táctico
- Combate **por turnos** con movimiento **por casillas**, vista **isométrica**.
- **Cuadrícula ortogonal** (`DECIDIDO` 05/10/2026, ratificado 07/10/2026): moverse, atacar, guardar junto al Maestro y la Caza del Tasajero usan las **4 casillas adyacentes**. Las diagonales abaratan la táctica: los muros, los pasillos y la formación pierden peso.
- **Las relaciones miran las 8 vecinas** (`DECIDIDO` 07/10/2026): la afinidad, los incidentes entre rivales y el sostén de la cobardía cuentan también las diagonales. Los **combos no miran la posición**.
  - **Por qué:** con la adyacencia en 4, dos aliadas que le pegan cuerpo a cuerpo a la misma objetivo nunca quedan vecinas entre sí: la afinidad y el foco se excluían, y pelear juntas no premiaba (Pilar 3). Con vecinas en 8, sí.
  - Las posiciones en diagonal que dan afinidad son las mismas que le dan dos presas al Tasajero: el dilema de *dónde no me paro* queda más nítido (6.2). También suben los incidentes: la vecindad amplia tiene costo.
- **Tablero de referencia: 12 × 12** (`DECIDIDO` 07/10/2026). Un escenario puede ser más chico si lo pide (combates de nodo, peleas cortas), nunca más grande en el MVP.
  - **El primer contacto llega en la ronda 2.** El espacio es para maniobrar (flanquear, usar el surco, separar rivales con la Lanzadera), no para caminar: cada ronda suma hambre de combate. Los despliegues los define Sistemas.
  - El tablero grande necesita **cámara móvil** (desplazar y acercar).
- El orden de actuación lo define la **iniciativa** de cada unidad, y los bandos **se intercalan** en la cola. Una unidad puede **Secundar**: actuar justo después de un aliado elegido, a cambio de dejar que los enemigos intermedios actúen antes. Sin enemigas intermedias, Secundar no tendría decisión.
- El Maestro y sus criaturas pelean juntos en el tablero.
- Los turnos de combate **suman hambre**: los combates largos tienen costo.
- El maná del Maestro se regenera por turno, pero **nunca supera el maná con el que entró al combate** (ver 6.7).
- **El orden y la posición importan:** los ataques en cadena (combos), la afinidad entre vecinas, los incidentes entre rivales, el Encono y la cobardía convierten a las relaciones de la tribu en táctica (ver 6.4).
- En combate, el comportamiento de cada criatura lo rige su **obediencia**: su lealtad, descontada por el hambre (ver 6.4).

### Campamento — El Molino Callado
- Base del jugador: descanso, recuperación y convivencia de las criaturas sueltas.
- **Único refugio**: no hay emboscadas, el fuego siempre está encendido y es el único lugar donde se descansa para curarse (ver 6.5).
- Lugar al que el Maestro es arrastrado si cae en combate.
- Escenario posible del **ataque nocturno** (ver 6.4).
- Lugar del **ritual de sangre** que crea pergaminos (ver 6.7).
- Es un **molino de agua**, callado porque la acequia se tapó. Nunca se explica por qué.
- A futuro: repararlo destapando la acequia y mejorarlo (Capa 1); la **Mudanza** y la **involución** de las criaturas (Ideas en espera).

### Fin de la partida — el epílogo
- Una partida termina de dos maneras: por **permadeath** o al **cumplirse el plazo**, un número fijo de días: **30** en el MVP (dato editable en `Sistema.md` 13).
- El plazo **se ve y se cuenta** desde el día 1, como el hambre y la secuela: el jugador sabe cuánto falta.
- Al cumplirse el plazo, la partida cierra con un **epílogo que lee la tribu**: quién sigue, quién es leal, a quién perdiste y cómo (comida, abandono, muerte en combate, hambre).
- **Sin puntaje numérico.** Llegar al final ya es sobrevivir; el epílogo dice *cómo* sobreviviste. El final es la regla de oro vista de frente.
- **Ningún final premia vaciar la tribu.** Comerse a una criatura el último día pesa en el epílogo igual que el primero: el plazo no puede convertirse en permiso para la crueldad sin consecuencias.
- **Las rayas y las golondrinas** marcan el plazo (`Mundo.md` 4.10): las **rayas** de carbón cuentan los días en la interfaz y en una viga del Molino; las **golondrinas** del techo del Molino son la señal del mundo, se van antes del alba del último día y no tienen mecánica. Sin simular clima (Capa 2) ni explicar el pasado del Maestro (Capas 3 y 5).
- **Por qué:** sin un final, la única forma de terminar es morir, y la tribu bien cuidada nunca ve su recompensa. El plazo le da horizonte al reloj de supervivencia (Pilar 4) y el epílogo convierte al vínculo en el resultado de la partida (Pilar 3 y regla de oro).
- **En el juego completo** (13/10/2026): por ahora no hay final definido; el juego completo es de **exploración abierta**, y las misiones principales llegan con la historia (Capa 5). **Criterio:** cualquier final futuro **lee a la tribu**, como el epílogo del MVP.

## 6. Sistemas centrales (resumen)

Las reglas y los números de cada sistema están en `Sistema.md`.

### 6.1 El Maestro de Criaturas
- Elige una **clase inicial** al comenzar.
- Desbloquea **ramas** de habilidades a medida que progresa.
- Combina magia, habilidades y combate físico.
- Es el **único que usa magia**.

**Atributos del Maestro:**
- **La balanza Barro ↔ Soplo.** No son dos atributos, sino los dos polos de uno solo.
  - Hacia el **Soplo** (lo que los Nueve pusieron en movimiento): más maná, sellar e invocar más barato y acceso a criaturas de rango más alto.
  - Hacia el **Barro** (lo que los Nueve modelaron): más vida, más daño físico, vínculos más fáciles con la tribu (umbral de rescate más bajo, lealtad que crece más rápido) y **Arrimo**.
- **Poder mágico:** potencia de los hechizos.
- **Regeneración de maná:** maná recuperado por turno en combate.

**Arrimo** *(antes "Liderazgo")*: es el efecto del polo Barro sobre la tribu en combate. Un Maestro arraigado hace que su grupo obedezca y se coordine: menos incidentes entre rivales, menos Encono y combos más fuertes. **El Barro captura menos, pero lidera mejor.**

**Progresión por nivel:**
- Al subir de nivel, el jugador suma **1 punto a Poder mágico o a Regeneración de maná**.
- **Además**, si quiere, mueve la balanza **1 paso hacia cualquiera de los dos polos**. Mover la balanza no consume el punto: es un intercambio, no una ganancia.
- El cambio afecta **de inmediato** el umbral de rescate, el ritmo de ganancia de lealtad y el Arrimo. La lealtad inicial no se recalcula (solo aplica al capturar).
- La interfaz avisa, **antes de confirmar**, qué criaturas dejan de poder rescatar al Maestro.

**Experiencia:** mixta, con peso en los **hitos de la tribu**: que una criatura llegue a Leal por primera vez, una captura o un ritual. Ganar combates también da experiencia, pero menos. **El Maestro crece cuando crece su tribu.** Comerse una criatura nunca da experiencia.
- Por qué: si la experiencia saliera solo del combate, empujaría a buscar peleas; si saliera solo de los hitos, el combate perdería sentido (Pilar 1).

**Balanza inicial:** la clase del MVP, el **Menestral** (ver `Mundo.md` 2.9), arranca **inclinada hacia el Barro**. El MVP enseña primero la tribu, porque lo que se testea es si la regla de oro es divertida.
- **La posición inicial de la balanza es parte de la identidad de cada clase** (Capa 3).
- **Ninguna clase arranca en un polo.** La balanza es un viaje: arrancar en un extremo le quita al jugador la mitad de la decisión.

**Alimentación del Maestro:**
- Es **omnívoro**: puede comer cualquier tipo de comida, incluida una criatura.
- Necesita una **dieta variada**: si come el mismo tipo de comida varios días seguidos, cae **Enfermo** (ver 6.5). La interfaz avisa antes de que pase.

**A futuro (Ideas en espera, 10):** el Maestro será **avatar de los Legados**: no está atado a ninguno y manifiesta su naturaleza por el equipo, con una afinidad que crece con su tribu por **la rueda del árbol**.

### 6.2 Criaturas
- Tienen habilidades **activas y pasivas**, que funcionan **dentro y fuera del combate**.
- Pueden combatir, trabajar y transportar objetos.
- Compromiso fijo: más aptitud de combate = menos utilidad, y viceversa. El rol también define el temperamento ante una rival enemiga: las criaturas **de trabajo** **se acobardan**; las **de combate y las mixtas** **se enconan** (ver 6.4).
- Tienen un **rango** (1 a 3) que representa su fuerza y define cuánto cuesta sellarlas e invocarlas.
- En el MVP, cada criatura tiene **un solo rasgo de combate**. Donde el rasgo no generaba decisiones, se reescribió como **activa**: el rasgo nuevo **reemplaza** al anterior, nunca se suma (05/10/2026). La segunda habilidad de cada criatura queda reservada para la Mudanza (Ideas en espera).
- **Principio de las activas:** toda habilidad activa es un **trueque sobre el propio cuerpo**. Mejora algo de la criatura por un tiempo, o cambia el tablero, y siempre la paga la criatura con otra característica. Nunca es gratis.
  - **Sin estadísticas nuevas:** los costos se pagan con lo que ya existe (vida, daño, daño recibido, movimiento, alcance, velocidad). No hay Defensa en el MVP.
  - **Las de trabajo no se vuelven guerreras:** la activa de una criatura de trabajo es de defensa o de apoyo, nunca de daño (Pilar 2).
  - Erizarse es el modelo: menos daño recibido a cambio de quedarse quieta.
- **Rasgos del MVP** (los números viven en `Sistema.md` 11.2):

| Criatura | Rasgo | Tipo | Qué hace y qué paga |
|---|---|---|---|
| Rodauva | **Erizarse** | Activa | Recibe menos daño hasta su próximo turno; no se mueve |
| Ocarra | **Alabarda** | Característica | Alcance 2 en línea recta |
| Surcón | **El surco** *(provisorio)* | Activa | Cava un surco en una casilla. **Solo un Surcón puede pasarlo**, de cualquier bando: andar por la tierra removida es de su naturaleza. Para el resto es intransitable. Reemplaza a Lomo de tierra. Trueque: **cavar le gasta el turno completo** (no se mueve ni ataca ese turno). Cuánto dura el surco y cuántos puede haber a la vez lo define Sistemas. **La Rodauva aguanta; el Surcón cierra el paso y lo usa** |
| Zancajunco | **Hacerse junco** | Activa | Se queda quieto entre los juncos y su próximo ataque suma daño; si lo golpean antes de atacar, pierde el bono |
| Tasajero | **Caza y cuenta** | Activa de un solo uso | Dos modos, ver abajo |

- **Caza y cuenta (Tasajero):** **un solo turno por ronda**, con dos modos. Empieza el combate en **Caza**, porque se expuso para cazar. Su activa es **pasar a Cuenta**: es gratis, solo se usa **al principio de su turno** (si se mueve o ataca, ya no puede ese turno) y **no tiene vuelta**. El cambio es el evento del combate.
  - **Caza:** se mueve normal y hace **dos ataques separados**, a una o a dos presas **adyacentes** (las 4 ortogonales). Recibe **más daño** que lo normal.
  - **Cuenta:** se mueve normal y **puede partir el movimiento** (acercarse, pegar y retirarse). Un solo ataque, con **menos daño**. Recibe daño normal.
  - **El Tasajero desgasta, no ejecuta.** Pegarle a dos presas es lo propio de un cazador. Del lado del jugador, la pregunta es *dónde no me paro*: formar apretado suma afinidad, pero le da al Tasajero dos presas en un turno. Las aliadas en diagonal entre sí son vecinas (suman afinidad) y a la vez dejan esquinas donde el Tasajero alcanza a dos (Escala 3).
  - **Su IA** la propone Sistemas, con estos criterios de visión: prefiere repartir los golpes antes que gastarlos en una sola presa; es predecible y sin azar; no tumba a una presa entera de un solo turno sin una decisión previa del jugador. Cuándo cambia de modo también se ve antes.
- **Todo rasgo se ve:** nombre y explicación al pasar el mouse sobre cualquier unidad, propia o enemiga, y un aviso cada vez que el rasgo actúa. Un rasgo que no se ve no existe para el jugador (hallazgo del playtest 0a.1).
- Cada criatura tiene una comida **favorita**, comidas que **acepta** y comidas que **rechaza** (ver 6.5).
- Cada criatura está en uno de dos estados: **guardada** en su pergamino o **suelta** (ver 6.7).
- **La compañera inicial:** el Maestro **no arranca solo**. Empieza con **una criatura fija**, **suelta**, que **ocupa uno de los pergaminos iniciales** y empieza **Neutral**: le faltan pocos días bien alimentada para poder rescatarlo.
  - **Por qué:** un Maestro solo, en sus primeros días, moriría sin haber tomado ninguna decisión sobre su tribu, y eso contradice la sección 8. Una compañera ya leal regalaría la regla de oro. Con una compañera que todavía no es leal, la regla de oro es la lección del día 1: *si la cuidás, te va a salvar; todavía no*.
  - **Criterios:** rango 1, **de trabajo** (el jugador tiene que salir a buscar quién pelee, Pilar 2, y el Maestro carga con el combate al principio, Pilar 1) y con su comida favorita cerca del Molino.
  - **Es la Rodauva, la dueña del Molino**: ya vivía junto a la piedra del fuego cuando llegó el Maestro (ver `Mundo.md` 4.8). La relación se invierte: el recién llegado es él.
  - La apertura **no explica el pasado del Maestro**: ese hueco depende de la clase (Capa 3) y de la historia principal (Capa 5).
- **Puede haber varias criaturas de la misma especie** en la tribu. La **Rodauva es el piso de supervivencia**: abundante y fácil de domesticar. Muchas Rodauvas aseguran un mínimo de comida, no una partida fácil: una tribu de Rodauvas recolecta bien y pelea mal (Pilar 2).
- En el MVP **no hay tipos ni linajes**. A futuro, el sistema de linajes es **los Legados y sus Sombras** (Ideas en espera, 10): conceptos de la hechura de los Nueve, nunca elementos como fuego, agua o planta, y sin multiplicadores de daño.

### 6.3 Obtención de criaturas
Siempre se sellan en un **pergamino** gastando **maná**, por dos caminos:
- **Camino de combate:** debilitar a la criatura y sellarla. Es una **apuesta**: la probabilidad depende de la vida que le queda y de su rango, se **muestra antes** de gastar el maná, y si falla, el maná se pierde. Una salvaje que llega a 0 de vida **huye** sin dar comida: pegarle de más es perder la captura. Con poca vida, también puede **huir en su turno** (la probabilidad se muestra): debilitarla y sellarla antes de que actúe es cuestión de iniciativa.
- **Camino de confianza:** domesticarla con comida, tiempo y confianza. El sellado es **seguro**.

Reglas comunes:
- Sellar usa el mismo maná que la magia de combate: capturar y pelear compiten por el mismo recurso.
- Toda captura **ocupa un pergamino** (ver 6.7).
- Solo se pueden sellar criaturas cuyo rango esté al alcance de la balanza, por cualquiera de los dos caminos (más Soplo, rango más alto).
- **Ambos caminos tienen ventajas reales:** las criaturas capturadas por combate empiezan con **lealtad baja**; las domesticadas empiezan con **lealtad alta**, pero cuestan más días y comida. Un Maestro inclinado hacia el Soplo empieza con menos lealtad por cualquiera de los dos caminos.

### 6.4 Lealtad, obediencia y relaciones

**Lealtad** (criatura → Maestro): un valor numérico que sube o baja según las decisiones del jugador. Define cuatro estados: **Desleal**, **Dudosa**, **Neutral** y **Leal**. Solo las leales pueden rescatar al Maestro.
- Lo que la construye: pasar el día suelta y bien alimentada, pelear juntos y ganar, que el Maestro perdone a una atacante.
  - **Ganar juntos** se lee por el estado **al terminar** el combate: lo reciben las que quedan de pie y las caídas que se levantan. Las guardadas al terminar, no: el pergamino congela el vínculo. Guardar a una caída le salva la vida a cambio de ese punto.
- Lo que la destruye: el hambre, comer lo que rechaza, la muerte de compañeros y, sobre todo, que el Maestro se coma a una criatura.
- Repartir la comida es una decisión: alimentar bien a algunas o poco a todas.

**Obediencia:** es la lealtad en el momento, **descontada por el hambre**. La lealtad es el vínculo de fondo; la obediencia es cuánto pesa ahora.
- **En combate, todo se lee sobre la obediencia. El rescate usa la lealtad real.**
- Una criatura leal con hambre deja de ser tu mejor aliada en el tablero, aunque todavía pueda rescatarte.
- El Maestro es **afín** de toda criatura con obediencia leal: pelear juntos los potencia.

**Relaciones** (criatura ↔ criatura): en el MVP, un solo tipo: **se llevan bien** o **se llevan mal**. En el tablero se juegan así. **Vecina** significa cualquiera de las **8 casillas** alrededor, diagonales incluidas (Escala 3):
- **Afines vecinas:** se potencian.
- **Combos (ataque en cadena):** aliados que actúan seguidos sobre el mismo objetivo suman daño; entre afines, más. Cada eslabón vale menos que el anterior. **El combo no mira la posición:** dos afines encadenan como afines aunque estén lejos entre sí.
- **Rivales aliadas vecinas:** riesgo de **incidente**. Una criatura obediente se distrae; una poco obediente ataca a su rival.
- **Rival enemiga — Encono** *(antes "provocación")*: las criaturas **de combate y mixtas** pueden ensañarse; la criatura puede ensañarse y atacar a su rival sí o sí, ganando fuerza y perdiendo control.
- **Cobardía:** las criaturas **de trabajo**, ante una rival enemiga, no se enconan: se acobardan y quedan debilitadas. Su obediencia puede hacerlas resistir: **la regla de oro también se ve en el coraje**. Las **afines vecinas** también la sostienen (regla a testear en el MVP).
- **Salvajes:** siguen las mismas reglas **de relación** (afinidad, incidentes, Encono y cobardía), sin obediencia que las contenga. Atraer a dos rivales salvajes es una táctica legítima.
  - **Las salvajes no encadenan combos:** se sostienen entre ellas, pero no se coordinan. La cadena es algo que solo da el vínculo con el Maestro (Pilar 3).
- Toda probabilidad de incidente o Encono se **muestra antes** de mover.

Las criaturas **guardadas** en pergamino **no ganan ni pierden lealtad, ni participan de relaciones**. El vínculo solo se construye con criaturas sueltas.

**Abandono y ataque nocturno:**
- Durante la recuperación del Maestro, las criaturas de poca lealtad pueden irse (ver 6.6).
- Fuera de la recuperación, una criatura **suelta, famélica y desleal** puede **irse durante la noche**. La interfaz marca el riesgo antes de dormir; guardarla en su pergamino evita el chequeo, pero congela el vínculo.
- Criterio de visión: ante una criatura desleal y famélica, **irse es la norma; atacar al Maestro es la excepción**.
- **Ataque nocturno:** la criatura golpea primero y empieza un combate donde se duerme, en el Molino o al raso. Las sueltas leales defienden al Maestro. El sueño interrumpido le deja menos maná.
- **La atacante derrotada** queda caída y el Maestro elige: **perdonarla** (se va libre; la tribu valora la clemencia), **sellarla** de nuevo (con un pergamino nuevo y lealtad mínima) o **comerla** (la tribu vio la traición, y el golpe social es menor).
  - **Si el Maestro cae antes de decidir**, la atacante **se va**: su pergamino arde y vuelve a ser salvaje. La tribu **no gana ni pierde lealtad**, porque nadie decidió. Nadie la ve irse; queda su rastro (ver 7).
  - **Por qué:** la decisión más dura tiene un solo momento (6.5); dejarla pendiente durante la recuperación la saca de ese momento, y matarla castigaría una derrota con algo que el jugador no eligió. Irse es la norma.
- **Todo vínculo roto quema el pergamino** (ver 6.7) y la criatura vuelve a ser salvaje.

### 6.5 Supervivencia
- El **hambre** es el único recurso de supervivencia del MVP. Estar saciado da ventaja; el hambre resta maná, obediencia y, al final, vida.
- **La comida tiene tipos** (fruta, raíces, grano, bichos, pescado, carne, hongos) y cada región ofrece algunos. La comida más segura está cerca y alimenta a pocas criaturas; la carne alimenta a las más fuertes y está en el lugar más peligroso.
- La fruta, el pescado, la carne y los hongos **se pudren**; el grano, las raíces y los bichos, no. Lo perecedero se come cerca de donde se encuentra.
- **Las criaturas no comen lo que rechazan.** Famélicas, pueden hacerlo pagando un costo: pérdida de lealtad y riesgo de caer Enfermas.
- **Los bichos** son la comida de emergencia: siempre están, pero juntar una ración cuesta tiempo. Convertirlos en ración es directo, **no es crafteo**.
- **El Maestro necesita variedad** (ver 6.1).
- Las criaturas **sueltas** comen y están expuestas al hambre y a los elementos. Come toda criatura que **estuvo suelta en algún momento del día**. Las **guardadas** están protegidas.
- El hambre también afecta al Maestro: **reduce la regeneración de maná**, y con **hambre extrema no se regenera**.
- **Morir de hambre:** cada día terminado famélico cuesta vida. El reloj se ve y se puede contar; cuando se acerca el final, comerse a una criatura deja de ser impensable.
- **Comerse una criatura** nunca rinde como comida; solo como supervivencia.
- **Cuándo se come:** solo en el **reparto de la noche, junto al fuego**, con la tribu mirando. No se puede en cualquier momento del mapa ni al terminar un combate (una caída de un combate ganado se levanta; nunca se ofrece como carne). La única otra salida es el destino de la atacante nocturna (6.4), que también se decide de noche.
  - **Por qué:** la decisión más dura del juego tiene un solo momento y un solo lugar. Si cada victoria ofreciera carne, el combate se volvería una fuente de comida y el vínculo (Pilar 3) perdería frente al hambre.
- En situaciones extremas: comerse una criatura, ser atacado por una criatura hambrienta, que las criaturas se ataquen entre sí o que abandonen al grupo.

**Estado negativo: Enfermo**
- En el MVP existe **un solo estado negativo**, **Enfermo**, con un único efecto mecánico (debilita el daño y la recolección) y tres causas narrativas: **Empacho** (comer algo rechazado o la dieta monótona del Maestro), **Tripa negra** (comida podrida) y **Fiebre del hongo** (hongos dañinos). La causa define la duración.
- **Las enfermedades se acumulan:** cada mala decisión de comida suma, y enfermo se recolecta menos.
- **Cura:** descansando en el Molino con solo agua (rápido, pero el hambre sigue subiendo) o, más lento, mientras se viaja. Con varias enfermedades juntas no se puede curar todo descansando: hay que elegir.
- La probabilidad de enfermarse se **muestra antes** de elegir.
- Afecta tanto a las criaturas como al Maestro.
- No contradice "el hambre como único recurso": el estado es una **consecuencia** del hambre y de comer mal, no un recurso nuevo.
- Los tres estados con efectos distintos entran en la Capa 1.

### 6.6 Muerte y rescate

**Caídas en combate:**
- Una criatura de la tribu que llega a 0 de vida queda **caída**: si se gana el combate, se levanta con 1 de vida; si se pierde o se huye, **muere** y su pergamino arde.
- **Si el Maestro cae, el combate termina.** La rescatista lo arrastra al campamento y **las caídas quedan atrás y mueren**: la que te salva no puede cargar a todas. *(En el juego completo hay una sola excepción: las criaturas de Desapego siguen peleando; ver Ideas en espera, 10. El MVP no cambia.)*
- Una salvaje en 0 huye (ver 6.3). La atacante nocturna, en cambio, queda caída para que el Maestro decida (ver 6.4).
- El Maestro puede **guardar a una caída** gastando su acción y maná: sobrevive en su pergamino aunque después se pierda el combate. Hay que decidirlo **antes** de caer.
- El Maestro puede **huir**: el combate termina al final de la ronda y las caídas que quedan en el tablero mueren.
  - Si el Maestro **cae antes del cierre de la ronda**, queda caído y se aplica el rescate, como en cualquier caída. **La huida es una apuesta anticipada, no un seguro.** La interfaz muestra, al declararla, qué enemigas actúan antes del cierre y si alcanzan al Maestro.

**El rescate:**
1. El Maestro cae en combate y el combate termina.
2. Si sobrevive al menos una criatura **suelta**, **viva** y con lealtad **igual o mayor al umbral de rescate**, lo arrastra al campamento. Las criaturas guardadas en pergamino no pueden rescatarlo. El umbral depende de la balanza: cuanto más Barro, más bajo.
3. **Días de recuperación** en el campamento. Durante ese tiempo, las criaturas con **poca lealtad pueden abandonarlo**.
4. Tras recuperarse, el Maestro queda con **quebranto**: no regenera vida ni maná (tampoco al dormir), y **cada día pierde 1 punto de vida máxima**. El sanador del MVP es la **Poza Tibia**, un lugar en la orilla del Vado donde los animales lastimados se bañan en tregua (no es un NPC). Bañarse ahí le devuelve la regeneración, pero **lo perdido no vuelve: esa es la secuela**. Si nunca va, termina vagando con 1 de vida máxima.
5. Si nadie lo rescata: **permadeath**. Se pierde todo.

**Por qué así:** la secuela es un reloj visible y contable, como el hambre. Su tamaño depende de cuánto tarda el jugador en llegar a la Poza, y llegar exige cruzar dos destinos sin regenerar: la tribu tiene que sostener al Maestro débil. **El quebranto no es un estado negativo** (el único del MVP sigue siendo Enfermo): es la última etapa del rescate, una marca en la barra de vida con su contador, como "lo que diste".

**En el MVP, el permadeath es absoluto:** no hay progresión entre partidas.
- **Salir nunca repite una tirada.** Al salir a mitad de un combate, se guarda el estado exacto (incluido el azar) y se retoma en el mismo punto. El combate se guarda solo durante la pelea, de modo que un cierre forzado tampoco devuelve al inicio.

### 6.7 Magia, maná y pergaminos
- La magia es **exclusiva del Maestro** y usa **maná** como recurso.
- **Regeneración:** el maná se regenera **por turno durante el combate** y se recupera **al dormir, una vez por día** en el mapa del mundo. El hambre reduce ambas regeneraciones; el hambre extrema las corta.
- **Tope de combate:** dentro de un combate, el maná nunca supera el valor con el que se entró. Dormir bien antes de un combate importante define la pelea.
- **Invocar en combate** gasta el turno completo del Maestro. **Guardar en combate** gasta la acción de la criatura y exige que esté junto al Maestro. Fuera del combate, guardar es gratis.
- **Sellar** e **invocar** cuestan maná, más cuanto mayor es el rango de la criatura. Ninguna acción cuesta menos de 1 maná.
- En combate, el maná se reparte entre tres usos: **hechizos**, **sellar** criaturas salvajes e **invocar** las propias.
- **Hechizos de la clase del MVP:** **Martillazo** (daño a distancia), **Lanzadera** (empuja o atrae una casilla: separa rivales aliadas y junta rivales salvajes) y **Remiendo** (cura; no levanta a las caídas). Solo se usan en combate.
  - ⚠️ **Vigilar:** que el Martillazo no esconda al Maestro en la retaguardia (sección 8). Si pasa, se le recorta el alcance.
- **La tensión central:** una criatura guardada está a salvo pero sacarla cuesta maná; una criatura suelta está disponible gratis pero come, sufre el clima y no puede crear vínculo si no está afuera.

**Pergaminos:**
- El pergamino es **el hilo entre el Maestro y la criatura**. Cada criatura de la tribu, suelta o guardada, ocupa uno.
- **La cantidad de pergaminos limita el tamaño de la tribu.** Los pergaminos **nunca** son un recurso de supervivencia: no se administran día a día.
- **Todo vínculo roto quema el pergamino:** abandono, perdón a una atacante y muerte de la criatura (incluido que sea comida). La tribu lo ve arder. *(En el juego completo, también la venta: ver Más allá de Valdelumbre, 10.)*
- El Maestro arranca con una **cantidad fija** de pergaminos.

**El ritual de sangre** — la única forma de obtener pergaminos nuevos en el MVP:
- Es un **evento fijo del Molino con requisitos**, no un sistema de crafteo: no hay recetas ni otros objetos que se fabriquen así. El crafteo sigue en la Capa 1.
- Lo puede hacer cualquier Maestro, **sin importar la balanza**.
- El sacrificio es la **sangre del Maestro**: el pergamino se paga con su cuerpo.

| Requisito | Tipo | De dónde sale |
|---|---|---|
| Péñola | Se gasta | El palomar, en los Huertos de Almiar |
| Agua de charco | Se gasta | El charco quieto, en el Vado de los Juncos |
| Ramita de roble | Se gasta | El Roble Viejo, en el Robledal Hondo (por el colgadero o por el rodeo de las zarzas) |
| Cuenco | Permanente | Se encuentra una vez, en la hornacina de las ruinas de Almiar |
| Carbón | Gratis | El fuego del Molino (para trazar la **Urdimbre**) |
| Prenda | Gratis | Algo que un cuerpo deja ir sin daño, del Maestro o de cualquier criatura suelta: un mechón, una púa, una pluma de muda, una hoja de junco |
| Sangre del Maestro | El sacrificio | Su cuerpo |

Cada pergamino nuevo exige recorrer el valle, y el material más difícil está donde vive el Tasajero.

- **Regla del ritual: nada se arranca; todo se recoge.** La péñola se junta del suelo, la ramita es caída, el agua se quedó quieta sola, la prenda se da. **El único que paga con daño es el Maestro.** Lo duro del ritual es una decisión del jugador sobre su propio cuerpo, nunca una crueldad del mundo.
- **La Urdimbre** es el trazo del ritual: líneas de carbón paralelas, como un telar dibujado en el piso, que terminan en un único hilo suelto. Sin runas ni geometría alquímica.
- **Lo que diste:** el ritual deja al Maestro con menos vida máxima durante unos días. **No es un estado negativo** (el único del MVP sigue siendo Enfermo): es una marca en la barra de vida, con su contador.
- El pergamino **no está hecho de piel**: la hoja se cuaja en el agua del cuenco. Ningún texto ni arte debe sugerir que sale de una criatura.

### 6.8 Fundamento del mundo (resumen de `Mundo.md`)
- **Los Nueve** *(número provisorio)* son los dioses que **le dieron forma** al mundo, como se hace una vasija o un tejido. **La magia es el resto de esa hechura.**
- **Qué pasa hoy con los Nueve: nadie lo sabe.** Es un misterio deliberado que se sostiene con rastros, nunca con respuestas. Ningún evento del MVP lo revela.
- **Lo etéreo:** quien toca la magia empieza a parecerse a los Nueve. Su cuerpo pesa menos y las criaturas lo sienten lejos. Por eso el Soplo debilita el cuerpo y enfría los vínculos, y el Barro arraiga. **El Maestro vive tironeado entre lo etéreo y lo tangible.**
- **Rastros:** cada nodo de material del ritual guarda un rastro de los Nueve (la hornacina, la ronda de piedras del charco, la talla del Roble Viejo). Juntar materiales es también recorrer el misterio. **La mancha del cuenco es ambigua para siempre.**
- **Dentro del pergamino**, la criatura duerme sin soñar, fuera del tiempo: al salir cree que es el mismo día en que entró. Por eso no gana ni pierde lealtad.

### 6.9 Campamento al raso
Fuera del Molino, cada noche el Maestro arma un campamento. Entra completo en el MVP. Los números están en `Sistema.md` 9.4.
- **Guardias:** la noche tiene tres guardias, y cada una la cubre el Maestro o una criatura suelta. Vigilar cuesta descanso. Una guardiana **poco obediente puede dormirse**: la regla de oro también decide a quién le confiás la noche.
- **Fuego:** se enciende con tiempo, no con un objeto. Cocina la carne y el pescado del Maestro y aleja a casi todo, salvo en el Robledal, donde el Tasajero lo ve.
- **Emboscada:** las salvajes del destino pueden atacar de noche. Una guardia sin cubrir deja al grupo sorprendido. Una emboscada corta el descanso a la mitad. La probabilidad se muestra antes de dormir.
- **Habilidades de campamento:** son **del Maestro** y se despiertan por la convivencia. Cada **especie distinta** suelta y obediente despierta una: **Leña en las púas** (Rodauva), **Sueño liviano** (Ocarra), **Madriguera** (Surcón) y **Acecho** (Zancajunco). **Una tribu variada duerme mejor** (Pilar 3).

## 7. Tono y estética

- **Tono base:** aventura cálida, colorida, con sentido de maravilla.
- **Contraste:** las decisiones del jugador pueden llevar a momentos oscuros y duros. Lo oscuro no es el mundo por defecto: aparece como **rastro de decisiones pasadas** o como **consecuencia de las del jugador**.
- **Los momentos oscuros de cada criatura** son la cara narrativa de reglas generales (abandono, ataque nocturno, muerte por hambre), no reglas propias de cada una.
- **El ritual de sangre** se lee como sacrificio, nunca como gore.
- **Comer a una criatura se elide: la tribu es la cámara.** El texto nunca muestra el acto: muestra quién mira, quién se aleja y la mañana siguiente (`Mundo.md` 1.3). El abandono sigue el mismo principio: nadie ve irse a la criatura; queda su rastro.
- **Nombres:** todo en **castellano evocador**, sin lenguas inventadas (Valdelumbre, Surcón, el Molino Callado, Barro, Soplo).
- **Originalidad:** se evitan las imágenes emblemáticas de otras franquicias (por ejemplo, el círculo de transmutación). Nuestros símbolos salen de la hechura de los Nueve: la Urdimbre es un telar, no un círculo.
- **Vista:** 2D isométrica.
- **Arte:** sprites en **4 direcciones** (2 dibujadas + 2 espejadas) para contener el costo de producción. Por eso se evitan las asimetrías fuertes en los diseños, y cada criatura tiene una silueta distinta.

## 8. Lo que el juego NO es

- No es un Pokémon: no hay entrenador espectador, ni combates 1v1 clásicos, ni tipos elementales. **Los Legados y sus Sombras** (10) no son elementos ni una tabla de efectividad: sus ciclos actúan sobre la carga, nunca multiplican el daño.
- No es un juego de colección **por defecto**. Coleccionar es el camino del **Soplo**, y se paga con la regla de oro: los esbirros no rescatan, y a un Maestro coleccionista nadie lo arrastra al Molino. Todo vínculo roto, incluida la venta, quema el pergamino. La tribu está limitada por los pergaminos.
- No es un juego de acción en tiempo real.
- No es un mundo generado proceduralmente (el mapa es fijo; el azar vive en los eventos).
- No es un juego que castiga sin sentido: la muerte siempre es consecuencia de decisiones, y las apuestas se muestran antes de hacerlas.

## 9. Alcance del MVP (primer prototipo jugable)

Objetivo: comprobar que el núcleo es divertido antes de agregar capas.

**Alcance congelado** (01/10/2026): algo nuevo entra al MVP solo si **tapa un hueco que impide jugar** o **reemplaza algo que sale**. Todo lo demás va a Ideas en espera.

**Maestro**
- **1** clase de Maestro, el **Menestral** (con 1 rama), con la balanza inclinada hacia el **Barro** al empezar.
- Magia con maná y sus **3 atributos**: la balanza Barro ↔ Soplo, Poder mágico y Regeneración de maná.
- Progresión por nivel: 1 punto a Poder o Regeneración, más 1 paso opcional de balanza.
- 3 hechizos: Martillazo, Lanzadera y Remiendo.
- Experiencia mixta, con peso en los hitos de la tribu.
- Dieta variada del Maestro.
- Arranca con **1 compañera inicial fija**, suelta, Neutral y ocupando un pergamino.

**Criaturas**
- **5** criaturas con roles distintos (2 de trabajo, 2 de combate, 1 mixta): **4 reclutables** (Rodauva, Surcón, Ocarra, Zancajunco) y **1 aspiracional**, el **Tasajero** (rango 3), que aparece como **encuentro de combate** y se puede apaciguar, pero no domesticar ni sellar.
- **1** rasgo de combate por criatura, reescrito como activa con trueque donde aporta (6.2), y visible en pantalla.
- Pergaminos con **solo dos estados** por criatura: guardada o suelta.
- Cantidad inicial fija de pergaminos y **ritual de sangre** como única reposición.
- Captura por ambos caminos.
- Lealtad simple (valor numérico con cuatro estados), obediencia y **1** tipo de relación (se llevan bien / se llevan mal).
- Abandono durante la recuperación, abandono nocturno y ataque nocturno.
- **Sin Legados ni Sombras** (Ideas en espera, 10), y sin las estadísticas del juego completo: el MVP usa sus cinco estadísticas (`Sistema.md` 11.1).

**Mundo**
- **1** región: **Valdelumbre**, con el campamento (el Molino Callado) y **3** destinos de riesgo creciente: los Huertos de Almiar (bajo), el Vado de los Juncos (medio) y el Robledal Hondo (alto).
- **1** mapa de nodos por destino con eventos simples, incluidos los materiales del ritual. Mapa del día de 4 columnas, con agotamiento y comida perecedera.
- La **Poza Tibia**, en el Vado, como sanador.

**Supervivencia y combate**
- Combate táctico básico en tablero de **hasta 12 × 12**, de **cuadrícula ortogonal** con **relaciones entre vecinas en 8**, con cámara móvil, iniciativa, Secundar, combos, afinidad, incidentes, Encono y cobardía.
- **Sin terreno**, salvo una excepción: **el surco del Surcón**, el único terreno del MVP, que lo crea una criatura en combate. No abre un sistema de terreno.
- Hambre como único recurso de supervivencia, con **7 tipos de comida** y preferencias por criatura.
- **1** estado negativo: **Enfermo**, acumulable, con cura por descanso o viaje.
- Huida, caídas y guardar a una caída.
- Campamento al raso completo: guardias, fuego, emboscadas y habilidades de campamento.
- Sistema de rescate completo, con la secuela de la Poza Tibia.
- Permadeath absoluto, sin progresión entre partidas.

**Partida**
- Duración fija en días, con el plazo visible, y **epílogo** que lee la tribu (ver sección 5, Fin de la partida).

## 10. Roadmap de capas (tentativo)

| Capa | Contenido |
|---|---|
| 0 — MVP | Todo lo de la sección 9 |
| 1 | Crafteo y mejoras del campamento (reparar el Molino: destapar la acequia) · Estados negativos con efectos distintos (Empacho, Tripa negra, Fiebre del hongo) |
| 2 | Clima, estaciones, ciclo día/noche |
| 3 | Más clases y ramas del Maestro |
| 4 | **Economía, comercio, NPCs** · **Más allá de Valdelumbre** (salidas, ciudades, lo hondo, trabajos y misiones; ver Ideas en espera) *(antes Capa 5; reordenado el 13/10/2026)* |
| 5 | **Facciones, reinos, historia principal y misiones principales** *(antes Capa 4)* |

- **Por qué el reorden:** salir del valle necesita comercio antes que reinos.
- **Dependencias de la Capa 4:** el antídoto necesita los estados de la Capa 1, y acampar fuera de la ciudad expuesto al clima necesita la Capa 2. Si la primera porción llega antes, entra sin esos objetos y sin clima.

**La Capa 0 se divide en dos** `DECIDIDO`:
- **0a — rebanada de combate:** tablero, relaciones, sellado, caída y rescate. Se juega con escenarios fijos, panel de parámetros y semilla de azar fija. Vista cenital en los hitos 0a.1 y 0a.2; **isométrica antes de cualquier playtest de criterios de éxito**.
- **0b — loop completo:** mapa del mundo, mapa de nodos, supervivencia, campamento, ritual y fin de la partida con epílogo.
  - **El Soplo en la 0b:** con 3 o 4 subidas por partida, el polo Soplo casi no se juega, y se acepta: el MVP enseña primero la tribu. Para los playtests, la **balanza inicial es un parámetro de test**, para poder jugar partidas enteras inclinadas al Soplo. El jugador real siempre arranca donde lo pone su clase.

**Estado de construcción** `DECIDIDO` (03/10/2026):
- **La 0a se programa ya**, desde la tarea T02 (`Arquitectura.md` B). Ninguna tarea está bloqueada. Mientras dure la 0a no se construye nada de la 0b y no entra nada nuevo al alcance.
- **Criterios de éxito de la 0a:** se miden con las **13 métricas** de `Sistema.md` 11.9 y con los **umbrales de alarma** aprobados para cada escenario (A a H). Superar un umbral obliga a revisar la regla antes de pasar a la 0b.
- **Hitos de la 0b** (`Arquitectura.md` B.5), validados en este orden:
  1. **Un día:** del Molino al Molino, con un combate de nodo.
  2. **El valle:** los tres destinos, el ritual, el camino de confianza y el Tasajero.
  3. **La noche:** abandono, ataque nocturno, campamento al raso, rescate, quebranto y Poza Tibia. Acá se testea la regla de oro completa.
  4. **30 días:** experiencia, plazo y epílogo.
- **Las tareas de la 0b se detallan después de los playtests de la 0a**, porque esos tests pueden cambiar reglas.
- **Hallazgos del hito 0a.1** (05/10/2026):
  - **Los rasgos pasivos no se notaron** (Lomo de tierra, Hacerse junco). Respuesta: todo rasgo se ve en pantalla (6.2).
  - **El combate se sintió rígido.** Se evaluaron y **descartaron las diagonales** (Escala 3). Respuesta: los rasgos reescritos (6.2), que agregan control del espacio (el surco), emboscada (Hacerse junco) y un jefe que castiga la formación apretada (Caza y cuenta). Se vuelve a juzgar con la 0a.2, que suma relaciones, magia y combos, y en isométrica.
- **Los rasgos reescritos se programan antes de cerrar la 0a.2**, porque tocan tareas terminadas (cola, turno, daño, tablero e IA). Sistemas cierra los números en **una sola pasada de balance**. El Arquitecto decide si T14 avanza en paralelo. Son reemplazos, no agregados: el alcance sigue congelado.
- **Geometría y tablero** `DECIDIDO` (07/10/2026). Tras jugar la 0a.1b, la afinidad y el foco cuerpo a cuerpo se excluían, y el tablero de 8 × 8 dejaba poco tiempo para planear. No bloquean T16. Orden de trabajo:
  1. **T16 (cadenas)** sigue como está: los combos no dependen de la posición.
  2. **Vecinas en 8 para las relaciones**, antes de T18 (incidentes), para que T18 y T19 (Encono y cobardía) nazcan con la regla nueva.
  3. **Tablero de 12 × 12 con cámara móvil** y escenarios A a H reubicados, antes de los playtests de la 0a.2, porque las alarmas de duración (`Sistema.md` 11.9) se miden sobre el tablero real. Sistemas los recalibra en una sola pasada.
  - Son reemplazos de reglas existentes, no agregados: el alcance sigue congelado.

**Ideas en espera** (aprobadas en espíritu, sin capa asignada):

- **Más allá de Valdelumbre** *(aprobado en espíritu el 13/10/2026; Capa 4)*. Es el mundo del juego completo, fijo y diseñado a mano.
  - **Cinco salidas** desde el valle:

    | # | Salida | Sale desde | Lo que promete | Ciudad |
    |---|---|---|---|---|
    | 1 | **Aguas abajo** (llanura del río) | El Molino (boca del valle) | La salida civilizada: comercio, trabajos, poca captura | La más cercana: la primera ciudad |
    | 2 | **Las colinas** (lomas, cuencas) | Los Huertos | Pastoreo, aldeas, encargos de campo para las criaturas de trabajo | Pueblo con mercado, a distancia media |
    | 3 | **La meseta** (altiplano, cañones, desierto) | El Vado | Escasez de agua y comida, criaturas duras | Lejana: caravanas, no ciudad |
    | 4 | **Aguas arriba** (cordillera) | El Robledal (cruzando el río) | El riesgo más alto, criaturas de rango alto, paso a otra región | Ninguna: refugios |
    | 5 | **La boca** *(provisorio)* | Una cueva en la ladera de la montaña | Lo hondo: de solo ida y fuera de todo mapa que se venda | Ninguna |

    - **La ciudad está cerca de lo seguro y lejos de lo valioso.** Es la curva de Valdelumbre (fruta, pescado, carne) llevada al mapa: ninguna salida es la mejor (Pilar 2).
    - Los caminos se pueden reencontrar más adelante: el mundo es un grafo, no un árbol.
  - **Lo hondo:** lugares misteriosos, accesibles desde temprano, con acceso condicionado (la crecida, la noche, un paso que se derrumba detrás). El lugar no se mueve (mapa fijo), pero volver no está garantizado. Nadie vende el mapa de lo hondo.
    - **Lo hondo siempre avisa, con señales y nunca con porcentajes.** Avisa el mundo (huesos en la entrada, un frío que sale de adentro, un rumor de que nadie volvió) y avisa la tribu (la Ocarra no quiere entrar, la Rodauva se enrolla en la boca). Entrar después de las señales **es la decisión**: se respeta la sección 8.
    - El rescate también rige adentro: la regla de oro llega a lo hondo.
  - **La ciudad:**
    - **El hambre se paga con plata**: en la ciudad, la comida se compra; afuera, el hambre vuelve a regir. El reloj cambia de forma, no desaparece (Pilar 4).
    - **El basural** es la comida de emergencia de la ciudad, con criaturas carroñeras que viven de él.
    - **Las criaturas pagan el corral por día**, o acampan con el Maestro fuera de la ciudad, expuestas a bandidos, emboscadas y clima. **El corral protege, pero no une:** ahí no ganan lealtad, porque no conviven con el Maestro (Pilar 3).
    - **Quedarse en la ciudad siempre gasta más de lo que dan sus trabajos.** Si no, la ciudad sería un refugio infinito y el Molino dejaría de importar.
  - **Comprar y vender criaturas:**
    - **Vender rompe el vínculo:** el pergamino arde, la tribu lo ve y pierde confianza, y el epílogo lo cuenta. El comprador la sella con un pergamino propio.
    - **Comprar** exige un pergamino en blanco del Maestro, y la criatura arranca con lealtad baja: los pergaminos siguen limitando la tribu.
    - **Nada del cuerpo de una criatura se vende**: ni su carne, ni sus partes, ni sus prendas. Comerse una criatura nunca rinde (6.5), y la venta no puede ser la forma de que rinda.
    - **Coleccionar es el camino del Soplo** (sección 8): el Barro manda por vínculo; el Soplo, por dominio.
  - **Trabajos:** a las criaturas se les encargan trabajos según su aptitud (arar, acarrear, vigilar, pescar). Las de trabajo ganan en los encargos de oficio; las de combate, en los de pelea (Pilar 2).
  - **Misiones:** son **expediciones**, nunca "matá 5 de X". Se planean, se compra el mapa del viaje y se preparan. Las presas son difíciles de encontrar: los rumores dicen que hay una manada por acá o por allá, nada seguro. Elegir la misión es parte del desafío.
    - **Caza y captura** de una o varias criaturas, iguales o distintas.
    - **Carteles de recompensa** (viva o muerta). "Muerta" vale solo para **individuos marcados** (por ejemplo, una criatura que se come el ganado de un pueblo): la salvaje en 0 de vida sigue huyendo (6.3).
    - **Criminales:** son **Maestros renegados con su propia tribu**, con las mismas reglas que el jugador (obediencia, Encono, cobardía, rescate). Son un espejo: un Maestro del Soplo con sus esbirros, o uno del Barro al que su tribu defiende hasta el final.
  - **Mochila y objetos:** la comida cuesta plata y espacio. Se compran objetos de viaje (antorchas, tela, herramientas, antídoto, repelente, estacas, cuerdas de cuero, montura) y equipo.
    - **Cada objeto de tienda tiene que generar una decisión que otro no genera** (misma regla que las estadísticas, `Sistema.md` 11.1). Si dos resuelven lo mismo, sale uno.
    - **El fuego sigue encendiéndose con tiempo** (6.9); lo comprado lo acelera, nunca es obligatorio.
    - El antídoto depende de los estados de la Capa 1, y el repelente, de las emboscadas.
  - **Las criaturas solo llevan aparejos de trabajo y carga** (alforjas, arnés, montura): suman espacio de mochila y permiten encargos, nunca nada en combate. Lo que distingue a una criatura sigue siendo su especie (Pilar 2). El Maestro es el único que se equipa para pelear.
  - **Restricciones de mundo:** ninguna ciudad confirma adónde fueron los de Almiar (`Mundo.md` 4.2).
  - **Primera porción propuesta:** aguas abajo, la primera ciudad, el corral, los encargos de trabajo, una misión de captura por rumores y la boca. Prueba la ciudad, la expedición y lo hondo antes de multiplicar el contenido.
  - **Espera porque** es un juego entero arriba del MVP: economía, inventario, objetos, monturas, rumores, carteles, Maestros enemigos, lo hondo y cinco regiones con su arte.
- **Los Legados y sus Sombras** *(nombre provisorio; aprobado como diseño el 10/10/2026; los 18 legados se definieron el 12/10/2026)*. Es el sistema de linajes del juego completo: reemplaza a los "linajes de hechura" de la v1.3. Son **18**: los **Nueve legados** (1 a 9) y sus **nueve Sombras** (10 a 18), en una rueda.
  - **La rueda:**

    | # | Legado | # | Sombra |
    |---|---|---|---|
    | 1 | Lleno | 10 | Vacío |
    | 2 | Crecimiento | 11 | Drenaje |
    | 3 | Movimiento | 12 | Quietud |
    | 4 | Liviandad | 13 | Presión |
    | 5 | Intemperie *(provisorio)* | 14 | Protección |
    | 6 | Sonido | 15 | Silencio |
    | 7 | Sinceridad | 16 | Ilusión |
    | 8 | Unión | 17 | Desapego |
    | 9 | Disciplina | 18 | Inspiración |

  - **Cuatro ciclos, que se cuentan por distancia en la rueda y actúan sobre la carga, nunca sobre el daño.** No hay tabla de efectividad: cada legado tiene exactamente una relación de cada ciclo.
    - **Generación (+1):** cada legado genera al siguiente (Lleno → Crecimiento → … → Inspiración → Lleno).
    - **Potenciación (+4):** cada legado resuena con el que está cuatro casilleros adelante (Lleno → Intemperie, Crecimiento → Sonido…).
    - **Anulación (+8):** cada legado anula al que está ocho casilleros adelante (Lleno anula Disciplina, Vacío anula Inspiración…).
    - **Inversión (+9):** cada legado se invierte en su Sombra, y cada Sombra en su legado (Lleno ↔ Vacío).
    - **Regla que se desprende:** la Sombra de un legado anula a quien lo genera (+9 +8 = −1). La Sombra no ataca al legado: ataca su raíz.
  - **Criaturas:** cada una está **atada a dos legados**, un **principal** y un **secundario**, que definen cómo recibe la carga. Su ataque normal y sus habilidades ponen puntos de uno de ellos, según convenga y según la criatura (por ejemplo, el Zancajunco, Ilusión y Crecimiento: con Hacerse junco carga Ilusión; con el ataque normal, Crecimiento).
    - **Lo que distingue a una criatura** de las demás son tres cosas: sus **atributos base**, sus **activas** y su **combinación de legados**.
  - **Qué da cada legado** (12/10/2026):
    - **Un perfil de atributos:** **dos estadísticas altas y dos bajas**. El perfil inclina la ficha de la especie; cuánto pesa frente a la ficha, y cómo se reparte entre el legado principal y el secundario, lo define Sistemas.
      - **Cada par de la rueda es un eje en espejo:** las altas de uno son las bajas del otro. Lleno ↔ Vacío es la excepción: los dos son lentos, porque su espejo es de dónde sale el poder (el cuerpo o el espíritu).
      - **Dos legados pueden compartir sus altas si sus bajas son distintas;** lo que no se repite es el perfil completo.
    - **Un verbo:** una frase corta que dice cómo juega. **No es una regla del juego:** es la guía para diseñar las activas de las especies de ese legado. Las mecánicas (curar, drenar, auras, áreas) las ponen las **activas de cada especie**. Una especie puede romper su verbo a propósito, si Mundo tiene un motivo.
    - La identidad de un legado está sobre todo en su verbo: es lo que el jugador reconoce en el tablero. El perfil lo sostiene.
  - **Estadísticas del juego completo** *(boceto, sujeto a cambios)*. El MVP sigue con sus cinco estadísticas y sin Defensa (`Sistema.md` 11.1).

    | Estadística | Qué abarca |
    |---|---|
    | **Fuerza** | Daño físico, anclarse a la tierra, levantar objetos pesados |
    | **Agilidad** | Evasión, probabilidad de golpear dos veces, escapar de un agarre |
    | **Constitución** | Vida, regeneración de vida, defensa, bloqueo, resistencia a estados y a enfermedades |
    | **Sabiduría** | Percepción, resistencia a estados mentales, supervivencia, encontrar alimento |
    | **Espíritu** | Resistencia mágica, poder espiritual (daño mágico), maná, regeneración de maná, capacidad de curación |
    | **Resistencia** | Capacidad de fatiga, movimiento, velocidad, iniciativa |
    | **Suerte** | **Solo los picos:** golpe brillante, turno de más, hallazgos raros. **Nunca es un dado escondido:** todo lo que toca se muestra como probabilidad antes de actuar (sección 8). La captura, los incidentes y la huida no dependen de ella |

    - **No hay Inteligencia:** Espíritu cubre el daño mágico. Una estadística entra solo si genera una decisión que otra no genera (`Sistema.md` 11.1). La Suerte la genera: elegir entre lo seguro y lo variable.
  - **Los 18 legados:**

    | # | Legado | Verbo | Altas | Bajas |
    |---|---|---|---|---|
    | 1 | **Lleno** | Aguanta con el cuerpo: el tanque físico. Come mucho | Fuerza, Constitución | Resistencia (poco movimiento e iniciativa) |
    | 10 | **Vacío** | Aguanta con el espíritu: el tanque mágico. Cuerpo casi nulo | Espíritu, Sabiduría | Fuerza, Constitución, Resistencia |
    | 2 | **Crecimiento** | Polo de la naturaleza y soporte: cura dando de su propia vida. Su curación es de a poco; el Remiendo del Maestro es la curación de urgencia (Pilar 1) | Constitución, Espíritu | Fuerza, Agilidad |
    | 11 | **Drenaje** | Absorbe la vida de quien tenga cerca, enemigas y aliadas; tiene que seguir pegando para sostenerse. **Solitario:** si a una aliada no le gusta que la drenen, su relación con la que la drena empeora durante un par de días (por la rueda, les molesta a las de Crecimiento y de Lleno) | Fuerza, Agilidad | Constitución, Espíritu |
    | 3 | **Movimiento** | Cuanto más se mueve, más ayuda: una presencia que está | Resistencia, Agilidad | Constitución, Sabiduría |
    | 12 | **Quietud** | El estandarte del equipo: cuanto más quieta, más sostiene. Genera un aura distinta según la especie (maná, vida o atributos): una presencia sin estar | Constitución, Sabiduría | Resistencia, Agilidad |
    | 4 | **Liviandad** | No la atrapan ni la sujetan: se escurre, atraviesa y no la pueden empujar | Agilidad, Espíritu | Fuerza, Resistencia |
    | 13 | **Presión** | Sujeta, aplasta y empuja: decide dónde se quedan las otras. Lleno aguanta; Presión mueve a las demás | Fuerza, Resistencia | Agilidad, Espíritu |
    | 5 | **Intemperie** | No se protege ni se refugia, y sobrevive igual: esquiva en vez de aguantar y sabe vivir afuera | Agilidad, Sabiduría | Constitución, Resistencia |
    | 14 | **Protección** | Aguanta y cubre a las demás: se pone delante y recibe por ellas. Erizarse es su modelo | Constitución, Resistencia | Agilidad, Sabiduría |
    | 6 | **Sonido** | Activas de área: soporte, daño o tanque según la especie. Fuera del combate, comunica: avisa, llama y alerta | Espíritu, Resistencia | Constitución, Agilidad |
    | 15 | **Silencio** | Calla: algunas especies apagan su zona. Fuera del combate, no se la oye (sigilo) | Constitución, Agilidad | Espíritu, Resistencia |
    | 7 | **Sinceridad** | Revela: destapa a las ocultas, sus golpes no se esquivan ni se desvían, y la engañan poco. Fuera del combate, detecta trampas y engaños | Fuerza, Sabiduría | Agilidad, Espíritu |
    | 16 | **Ilusión** | Oculta, confunde y desvía. Fuera del combate, distrae y evita encuentros. Hacerse junco es Ilusión | Agilidad, Espíritu | Fuerza, Sabiduría |
    | 8 | **Unión** | Tiende lazos en el combate: cuanto más fuerte el lazo, más fuerte el combo y la unión. Sufre más una muerte en el grupo | Sabiduría, Resistencia | Fuerza, Espíritu |
    | 17 | **Desapego** | Corta lazos: al atacar, corta los que teje Unión, de los dos bandos. Cuanto más sola, más fuerte: sin vecinas cerca, y como última criatura de su bando en pie. Su lealtad cambia más lento, para subir y para bajar, pero nunca es inmune (regla de oro). Es la única que sigue peleando cuando cae el Maestro (ver abajo) | Fuerza, Espíritu | Sabiduría, Resistencia |
    | 9 | **Disciplina** | Constancia: rinde parejo, mejora repitiendo y obedece aunque tenga hambre o esté herida. Fuera del combate, guardias y trabajo de todos los días | Fuerza, Resistencia | Suerte, Sabiduría |
    | 18 | **Inspiración** | El momento: picos (golpe brillante, turno de más) con probabilidad visible. Fuera del combate, eventos raros y hallazgos | Suerte, Sabiduría | Fuerza, Resistencia |

    - **Contrajuego entre soportes:** Silencio es la respuesta natural al estandarte de Quietud y a las áreas de Sonido; Desapego, a los lazos de Unión.
    - **Fuera del combate**, Sonido, Silencio, Sinceridad, Ilusión, Intemperie y Disciplina se usan en lo que ya existe en la 0b (guardias, emboscadas, ataque nocturno, eventos del mapa de nodos): el sistema llega al día (Pilar 4) sin inventar sistemas nuevos.
  - **El almacén de carga:** cada unidad tiene uno, con un **umbral** (entre 6 y 10, lo define Sistemas).
    - Todo legado que entra **suma**, aunque no tenga relación con lo que ya había.
    - **Solo la anulación resta:** quita puntos del legado anulado, y lo que sobra se pierde (anular nunca carga). Sirve para atacar (desarmar a un enemigo) o para defender (evitar que una aliada explote).
    - **Potenciación:** cuando se dispara, el ataque **no carga su propio legado**: carga solo el legado potenciado, con **+1 punto** (por ejemplo, 2 de Crecimiento entran como 3 de Sonido). Se dispara si el legado potenciado **ya está en el almacén** del objetivo o **es uno de sus dos legados propios**.
    - **Se ve y se cuenta:** el almacén es una sola barra segmentada por legado, con el dominante marcado, y la interfaz avisa antes si un golpe lo llena (sección 8).
  - **Hacia dónde se invierte** (12/10/2026): **siempre a la Sombra de un legado propio** de la criatura, nunca a la del dominante del almacén. Una criatura tiene a lo sumo dos inversiones posibles, y el jugador las aprende.
    - Se invierte en la Sombra de su legado propio **con más carga** en el almacén. Si ninguno de los dos tiene carga, o están empatados, en la Sombra de su **legado principal**.
    - El almacén sigue importando: cargar el secundario de una criatura elige hacia dónde explota.
  - **Lo decide quien completa el umbral:**
    - **Un enemigo → explosión e inversión.** Durante algunos turnos, la unidad **toma solo la forma de pegar de la Sombra, con sus atributos de siempre**: queda desacoplada y casi inservible (por ejemplo, una de Lleno pega con Espíritu, que casi no tiene; una de Vacío pega con Fuerza). Al terminar la inversión queda **extenuada** *(provisorio)*.
    - **La propia criatura o una aliada → el Maestro elige:**
      - **Generación:** defiende como el **legado siguiente** de la rueda y gana sus atributos. Cuesta **fatiga** (Resistencia), **nunca extenuación**.
      - **Inversión:** toma **el cuerpo entero de la Sombra**: sus atributos y su forma de pegar. Es buena en combate, pero queda extenuada y pierde lealtad. Invertir a una propia es un **sacrificio táctico**.
      - **La generación cansa; la inversión agota.**
    - Dar el último punto es una decisión táctica, y cargar a una aliada es una apuesta: si un enemigo la termina, explota del lado equivocado.
  - **Extenuada:** solo por inversión, nunca por generación. Queda inservible el resto del combate y del día: no trabaja, no hace guardia ni pelea, y no puede volver a acumular. **Sigue comiendo y puede rescatar al Maestro**: la regla de oro no depende de un estado de combate.
  - **Lo que no le gusta a una criatura** es la Sombra o el anulador de cualquiera de sus legados (Mundo puede agregar casos por especie). Una sola regla para lo que le duele:
    - Si se lo carga **el Maestro, una aliada o ella misma** (o el Maestro elige invertirla), pierde **lealtad**: es una decisión del jugador.
    - Si se lo carga **un enemigo**, pierde **obediencia** durante el combate: la sufre, pero el vínculo no se rompe por la acción de otro (sección 8).
  - **Si cae el Maestro, Desapego sigue peleando** (12/10/2026; solo en el juego completo, el MVP no cambia):
    - La rescatista, que **siempre es una leal**, se lleva al Maestro, y las demás criaturas de pie se van con ellos. **El combate sigue solo con las de Desapego** contra lo que quede del enemigo.
    - **Si ganan, las caídas de la tribu se salvan**, porque no queda nadie que las remate. Si caen ellas también, las caídas mueren como siempre.
    - **Desapego no rescata ni salva al Maestro:** la regla de oro no cambia. Desapego no pelea por el Maestro; pelea porque no lo necesita. La que no se ata a nadie salva a las que sí se ataban.
  - **El Maestro, avatar de los legados:** no está atado a ninguno; manifiesta la naturaleza de cualquiera por su equipo y su magia. El **arma** define su legado de ataque y la **armadura**, sus dos legados defensivos. Elige el equipo **antes del combate**, y cambiar de arma en combate le gasta el turno: no puede ser el anulador universal. Si manifiesta un legado que no le gusta a una criatura de su tribu, ella lo siente.
  - **La rueda del árbol:** la construcción del Maestro. Su afinidad con los legados nace de su clase y **crece con la tribu que elige y por la rueda**: se expande a los legados vecinos, y acercarse a las Sombras de sus legados cuesta más. **Especializarse limita; nunca es gratis.** No es un árbol aparte: sale de la rueda, la clase y la tribu (decisión del 01/10: clases distintas sin sistemas nuevos).
  - **Criterios de visión:**
    - La explosión es **un evento, no ruido**: una o dos por combate en las unidades clave. La generación no puede volverse la jugada de cada ronda: por eso cuesta fatiga.
    - Explotar a un enemigo **no puede valer más** que bajarle la vida.
    - El beneficio de invertir a una propia **nunca puede superar** la extenuación y la lealtad perdida.
    - La tribu pesa más que el enfrentamiento: los legados nunca reemplazan a la afinidad, los combos ni el Encono (Pilar 3).
    - **Ningún legado anula al Maestro:** un Silencio enemigo no lo deja sin magia todo el combate y una Protección no lo escuda todo el combate. Es un problema que se resuelve, no una anulación (Pilar 1 y regla de oro).
    - **Un equipo entero de Desapego no puede ser la jugada óptima:** es la excepción anti-tribu que se elige (Pilar 2), no el camino eficiente.
    - **Toda área y todo pico se ven antes** de confirmar (sección 8).
  - **Espera porque** es un sistema grande: 18 perfiles con su verbo, las estadísticas del juego completo, la explosión y la inversión, relaciones entre individuos que cambian durante la partida, el combate que sigue tras la caída del Maestro, arte e interfaz, y el equipo del Maestro. Las armas y armaduras dependen además del crafteo (Capa 1). Se le asigna capa cuando el MVP valide la tribu.
- **La Mudanza** *(nombre provisorio)*. Cada criatura tiene un **defecto de naturaleza** (la Rodauva, la cobardía; la Ocarra, la impulsividad; el Zancajunco, la ariscura; el Surcón, el letargo). Superarlo gracias al vínculo con el Maestro la transforma. Condiciones de visión:
  - **La barra de zozobra** *(nombre provisorio)*: cada criatura tiene una barra que se llena por causas propias de su naturaleza. Al llenarse, la criatura llega a su límite: **se quiebra** (aparece su defecto; los quiebres repetidos pueden llevar a la **involución**) o **lo supera** (queda lista para mudar). Superar el defecto es el **disparador general** de la Mudanza.
  - **Superarlo no es azar puro:** depende de la **obediencia** y de las **afines vecinas**, y la probabilidad se muestra antes. La regla de oro también decide quién se crece. *(Así se diferencia de la tirada de Darkest Dungeon.)*
  - La barra **persiste entre combates** y **baja en el Molino**. Guardada en su pergamino, queda congelada, igual que el resto del vínculo.
  - La barra entra **con la capa de la Mudanza**. En el MVP, la cobardía sigue funcionando como hoy.
  - **Nunca** por nivel ni por experiencia: es un momento de vínculo. Aplica a todas las criaturas. *(Única excepción acotada: el contador de combos de la Muda colectiva.)*
  - Da **forma nueva y habilidad nueva**, con una silueta distinta pero **reconocible** como la misma criatura.
  - El momento de vínculo deja a la criatura **lista para mudar**; la Mudanza la **inicia el Maestro en el Molino**, cuando decide.
  - Mudar **acelera el metabolismo**: la criatura come más mientras dura. **El riesgo de morir depende de su hambre**, no de una tirada fija: la muerte es consecuencia de la preparación.
  - El Maestro puede **cancelarla** con maná (vuelve a "lista para mudar" y se puede reintentar) o **protegerla** con mucho más maná (evita la muerte por la Mudanza, pero no garantiza que mude). La protección no cubre el hambre general.
  - Espera porque duplica el costo de arte por criatura. Se le asigna capa cuando el MVP valide el vínculo.
- **La Muda colectiva de la Rodauva** *(aprobada en espíritu)*: es la cara del defecto de la Rodauva, la cobardía. Primero, la Rodauva **supera su cobardía** al llenarse su barra de zozobra (la manada vecina le da chances). Después, **cinco Rodauvas** que lograron **3 combos de 5 eslabones juntas** (acumulados entre combates; el contador es de esas cinco y vuelve a 0 si alguna cambia) se funden en una Rodauva más grande. Sus pergaminos quedan sellados dentro de un **pergamino de muda** *(provisorio)*. Condiciones: los pergaminos internos siguen ocupados, si muere arden todos y la Muda se inicia en el Molino, con riesgo según el hambre. Es la forma en que la Rodauva vive la regla general: su valentía le llega de la manada. La reversibilidad se decide cuando tenga capa.
- **La involución** *(provisorio)*. Es la otra cara de la Mudanza: la criatura consumida por su defecto de naturaleza. Condiciones de visión:
  - **Disparador:** se quiebra **más de 3 veces**, **sin vínculo** con el Maestro (lealtad 3 o menos) y habiendo sido **obligada** (Grito) o **subyugada** antes. Nunca es un accidente: es la consecuencia de un maltrato sostenido. La interfaz avisa cuando está a un quiebre.
  - **Igual de fuerte, pero paga en el vínculo:** solitaria, egoísta, come más y se lleva mal con todas. Sin control, hace lo que quiere. **Nunca puede rendir más que cuidar a la tribu.**
  - **Permanente:** no se redime.
  - **Forma:** su defecto exagerado, reconocible como la misma criatura. Sin estética de "versión oscura" (auras, ojos rojos, paleta negra) ni gore.
  - **Control:** solo con la subyugación, que exige una posición mínima de Soplo según la criatura y su rango.
  - Entra con la capa de la Mudanza: triplica el costo de arte por criatura.
- **Las órdenes** *(provisorio)*. Son la voz del Maestro, no magia: se pagan con lealtad, no con maná.
  - **Grito:** cualquier Maestro obliga a una criatura a obedecer. Gasta su **movimiento** (conserva la acción), alcanza **todo el tablero** y cuesta **1 de lealtad**, o **2** si la criatura es **orgullosa** (dato de cada criatura; la regla es general). Cuenta como "obligarla" para la involución.
  - ⚠️ **Vigilar:** que el Maestro no se esconda atrás a gritar (sección 8: no hay entrenador espectador). Si pasa, el Grito tendrá alcance.
  - No entran al MVP. El Grito es candidato si la cobardía frustra en los tests.
- **La subyugación** *(provisorio)*. Es el hechizo del polo Soplo: la forma eficiente de obligar. Baja la lealtad y dura hasta que el Maestro la suelte. Mientras dura, **retiene maná de la reserva** y achica el tope de combate. La criatura subyugada es un **esbirro**: **nunca rescata**. Si el maná que el Maestro recupera al dormir no cubre lo retenido, esa noche se suelta y puede abandonar o atacar.
  - **El Barro manda por vínculo; el Soplo, por dominio.** Ningún camino es gratis: el que domina tiene fuerza, pero nadie lo va a arrastrar al Molino.
  - Entra con la capa de la Mudanza o con una rama Soplo (Capa 3).
- **El santuario de escribas:** pergaminos a cambio de monedas. Depende de la economía (Capa 4).
- **El Tasajero y la despensa:** cuando el Tasajero sea reclutable, si el Maestro cae y el Tasajero está famélico, no lo arrastra al campamento sino a su despensa; famélico, también empieza a "guardar" al más débil del grupo. **Condición de visión:** debe ser un evento del que se puede escapar, no una muerte instantánea.
- **La despensa como pasiva:** reserva de comida de emergencia que no se echa a perder.
- **El Surcón cava bajo las reservas** del campamento cuando está famélico.
- **Reencontrar a una criatura que se fue**, ya salvaje, en su hábitat.
- **La prenda en el epílogo:** el epílogo nombra quién dio la prenda de cada pergamino. Solo narrativa, sin consecuencia mecánica: una consecuencia volvería al ritual una optimización, y el ritual duele por la sangre. En el MVP, la prenda no tiene consecuencias.

## 11. Preguntas abiertas

- [ ] Nombre del juego y del mundo.
- [ ] ¿Cómo termina una partida del juego completo? Por ahora es exploración abierta, y las misiones principales llegan con la Capa 5. **Criterio:** cualquier final lee a la tribu (regla de oro).
- [ ] Más allá de Valdelumbre: geografía, nombres y rastros de las 5 salidas y de la primera ciudad; señales de la boca y de lo hondo, por especie; quiénes son los Maestros renegados; qué criaturas viven del basural; cómo se lee en el lore que vender rompe el hilo, y su línea del epílogo (Worldbuilder)
- [ ] Más allá de Valdelumbre: costo del corral por día frente a lo que rinden los trabajos; espacio de mochila de cada aparejo; lealtad que cuesta una venta frente a comerse una criatura; regla de los individuos marcados que valen "muertos"; días del Molino a la primera ciudad (Sistemas)
- [ ] ¿Hacia dónde arrastra la rescatista al Maestro que cae en lo hondo o en la ciudad? (Sistemas)
- [ ] Más allá de Valdelumbre: ¿la IA de bando sirve igual para un Maestro enemigo con tribu? ¿La Escala 1 admite varias regiones? (Arquitecto, al darle capa)
- [ ] Muda colectiva: ¿basta con que una Rodauva haya superado su cobardía, o tienen que superarla las cinco? ¿Es reversible? (al darle capa).
- [ ] Nombre final de la barra de zozobra (Worldbuilder).
- [ ] Número final de los Nueve (Worldbuilder). Los Legados y sus Sombras proponen fijarlo en 9.
- [ ] ¿Qué clases iniciales existen? (Capa 3).
- [ ] ¿En qué capa el Tasajero pasa a ser reclutable?
- [ ] ¿En qué capa entra la Mudanza?
- [ ] ¿En qué capa entran las órdenes? (al darle capa a la Mudanza)
- [ ] ¿El esbirro que se suelta ataca más de lo que abandona? (excepción a "irse es la norma"; al darle capa a la Mudanza).
- [ ] ¿Qué pasa si una Rodauva de la manada se quiebra? (choque entre la Muda colectiva y la involución; al darle capa a la Mudanza).
- [ ] Nombres finales de la involución, las órdenes, el Grito, la subyugación y el esbirro (Worldbuilder).
- [ ] ¿Hay progresión entre partidas en el juego completo? (en el MVP, no)
- [ ] Nombre final del surco del Surcón (Worldbuilder).
- [ ] Regla de IA del Tasajero: reparto de los dos ataques de Caza y momento del cambio a Cuenta (Sistemas, con los criterios de 6.2).
- [ ] Con vecinas en 8: ¿bajan el bono de afinidad y la probabilidad de incidente? (Sistemas)
- [ ] Despliegues de A a H en 12 × 12 con contacto en la ronda 2 y bandos que se crucen en la cola (Sistemas)
- [ ] ¿En qué capa entran los Legados y sus Sombras? (al validar la tribu en el MVP)
- [ ] Legados: confirmar el nombre **Intemperie** del casillero 5 o proponer otro con el mismo sentido; nombre del sistema ("Legados"); quién modeló a las Sombras; si cada criatura lleva un legado de los Nueve y una Sombra, o dos cualesquiera; justificaciones de las anulaciones Intemperie → Presión, Sinceridad → Silencio, Unión → Ilusión y Disciplina → Desapego, y de por qué Lleno potencia a Intemperie (Worldbuilder)
- [ ] Legados: nombres finales de la explosión y de "extenuada"; qué legados le caen mal a cada especie, más allá de la regla de la rueda; por qué el Maestro tiene afinidad con algunos legados y no con todos (Worldbuilder)
- [ ] Legados: los 18 verbos en el lenguaje del mundo; por qué el Lleno come mucho; por qué Drenaje y Desapego son solitarios y qué hace que una de Desapego se quede con el Maestro; cómo se comunican las de Sonido y por qué no se oye a las de Silencio; la escena de la de Desapego que se queda peleando mientras se llevan al Maestro; qué legado principal y secundario lleva cada especie (Worldbuilder, al darle capa)
- [ ] Legados: umbral del almacén (6 a 10); duración de la inversión; cuánta lealtad y obediencia cuesta una carga que no le gusta; costos de especialización en la rueda del árbol (Sistemas)
- [ ] Legados: cuánto pesa el perfil frente a la ficha de la especie y cómo se reparte entre el legado principal y el secundario; cuánta fatiga cuesta la generación y cuánto dura; daño físico y mágico, con la defensa y la resistencia mágica que trae; cuánto mueve la Suerte cada pico (Sistemas)
- [ ] Legados: números de cada verbo: curación de Crecimiento y vida que paga; drenaje, distancia y pérdida por turno sin pegar; días que dura la relación empeorada por drenaje; alcance y fuerza de las auras de Quietud y si se suman; forma y tamaño de las áreas de Sonido y Silencio, y si el silencio afecta a las aliadas según la especie; costo de cubrir de Protección; cómo crece un lazo de Unión; cuánto más fuerte es Desapego sola y su tope si además es la última (Sistemas)
- [ ] Legados: cómo sigue el combate después de la caída del Maestro con las de Desapego (cómo se gana, qué pasa si caen) (Sistemas; Arquitecto al darle capa)
- [ ] Legados: ¿cómo se invierte el Maestro, que no está atado a ningún legado? (al darle capa)
- [ ] Legados: ¿qué pasa con una salvaje extenuada? ¿Huye o es más fácil de sellar? (compite con "debilitar y sellar", 6.3; Sistemas)
- [x] ~~Orden del roadmap para salir del valle~~ → Economía, comercio y NPCs pasan a la Capa 4; facciones, reinos e historia, a la Capa 5 (10).
- [x] ~~¿Cómo se venden y compran criaturas?~~ → Vender rompe el vínculo: el pergamino arde, la tribu lo ve y el epílogo lo cuenta; el comprador sella con un pergamino propio (10).
- [x] ~~¿El juego es de colección?~~ → No por defecto: coleccionar es el camino del Soplo y se paga con la regla de oro (8).
- [x] ~~¿Las criaturas usan equipo?~~ → Solo aparejos de trabajo y carga, sin efecto en combate (10).
- [x] ~~¿Lo hondo puede matar sin aviso?~~ → No: siempre avisa, con señales del mundo y de la tribu, nunca con porcentajes (10).
- [x] ~~¿Qué da cada legado?~~ → Un perfil de atributos (dos altas y dos bajas, en espejo dentro del par) y un verbo que guía las activas de sus especies (10).
- [x] ~~¿Se suma Inteligencia como estadística?~~ → No: Espíritu cubre el daño mágico. Se suma Suerte, solo para los picos y siempre visible (10).
- [x] ~~¿Hacia qué Sombra se invierte una criatura?~~ → A la de su legado propio con más carga; en empate o sin carga, a la de su principal (10).
- [x] ~~¿La afinidad y el foco cuerpo a cuerpo se excluyen?~~ → No: las relaciones miran las 8 vecinas; los combos no miran la posición (Escala 3, 6.4).
- [x] ~~¿Tablero más grande? (A-2)~~ → 12 × 12 de referencia, con contacto en la ronda 2 y cámara móvil (Escala 3, 9).
- [x] ~~¿Los bandos se intercalan en la cola?~~ → Sí, ya funciona: el orden es por Velocidad de cada unidad (Escala 3).
- [x] ~~¿Los playtests de E y F incluyen una encuesta?~~ → No: los umbrales se miden solo con el registro. Se reabre si los comentarios de los jugadores contradicen los números.
- [x] ~~¿La prenda tiene consecuencias?~~ → No en el MVP; el epílogo que la nombra queda en Ideas en espera (10).
- [x] ~~Destino de la atacante caída si cae el Maestro (P-024)~~ → Se va: el pergamino arde, sin cambio de lealtad (6.4).
- [x] ~~Trueque del surco~~ → Cavar le gasta el turno completo (6.2).
- [x] ~~¿El combate admite diagonales?~~ → No para mover ni atacar: cuadrícula ortogonal (Escala 3). Las relaciones sí miran las diagonales (07/10).
- [x] ~~¿Cada criatura tiene una activa y una pasiva de combate en el MVP?~~ → No: un solo rasgo, reescrito como activa donde aporta (6.2).
- [x] ~~¿Cuándo se puede comer a una criatura?~~ → Solo en el reparto de la noche, junto al fuego (6.5).
- [x] ~~Umbrales de las señales de alarma de la 0a~~ → Aprobados (`Sistema.md` 11.9).
- [x] ~~Nombre de la clase del MVP~~ → El Menestral (6.1).
- [x] ~~¿Qué marca en el mundo el final del plazo?~~ → Las rayas y las golondrinas (5).
- [x] ~~Duración de la partida y peso de las criaturas comidas~~ → 30 días; cada comida pesa igual, sin importar el día (5).
- [x] ~~Nombre final de "malherido"~~ → Quebranto (6.6).
- [x] ~~Motor de desarrollo y plataforma objetivo~~ → Godot 4.7.1, solo PC (`Arquitectura.md` A.1).
- [x] ~~¿Se divide la Capa 0 en 0a y 0b?~~ → Sí (10).
- [x] ~~¿Cómo termina una partida del MVP?~~ → Plazo fijo con epílogo que lee la tribu (5).
- [x] ~~¿Por qué la Rodauva está con el Maestro?~~ → Es la dueña del Molino (6.2).
- [x] ~~¿Hay un límite de criaturas sueltas?~~ → No, aparte de los pergaminos (9).
- [x] ~~¿Qué es el sanador del MVP y qué son las secuelas?~~ → La Poza Tibia; 1 de vida máxima perdida por cada día de demora (6.6).
- [x] ~~¿De dónde sale la experiencia del Maestro?~~ → Mixta, con peso en los hitos de la tribu (6.1).
- [x] ~~Nombres finales de Arrimo, Encono, Secundar, el círculo y el aporte corporal~~ → Arrimo, Encono, Secundar, la Urdimbre y la prenda.
- [x] ~~¿La posición inicial de la balanza depende de la clase?~~ → Sí, y ninguna clase arranca en un polo (6.1).
- [x] ~~¿Las criaturas mixtas se enconan?~~ → Sí (6.2).
- [x] ~~¿El Maestro arranca con alguna criatura?~~ → Sí: una compañera fija, Neutral (6.2).
- [x] ~~¿Cómo funciona la magia del Maestro?~~ → Resuelto en 6.7.
- [x] ~~¿El carisma es un atributo propio?~~ → Es el polo Barro de la balanza (6.1).
- [x] ~~¿Los estados negativos entran en el MVP?~~ → Uno solo: Enfermo (6.5).
- [x] ~~¿Las criaturas pueden abandonar fuera de la recuperación?~~ → Sí, de noche, si están sueltas, famélicas y desleales (6.4).
- [x] ~~¿El Maestro tiene preferencias de comida?~~ → No: es omnívoro, pero necesita variedad (6.1).
- [x] ~~Nombre de la balanza y de sus polos~~ → Barro ↔ Soplo (6.1).
- [x] ~~¿De dónde viene la magia y qué es un pergamino en el lore?~~ → Los Nueve y el hilo (6.8).
- [x] ~~¿Por qué la magia aleja al Maestro de su tribu y debilita su cuerpo?~~ → Lo etéreo (6.8).
- [x] ~~¿Existen tipos o elementos de criaturas?~~ → No en el MVP; a futuro, los Legados y sus Sombras (10), sin elementos ni multiplicadores de daño.
- [x] ~~¿Cómo funcionan los linajes?~~ → Rueda de 18 con cuatro ciclos sobre un almacén de carga (10).
- [x] ~~¿Hay un límite de pergaminos?~~ → Sí: cantidad fija inicial + ritual de sangre (6.7).
- [x] ~~¿Cuántas criaturas guardadas puede tener el Maestro?~~ → Tantas como pergaminos (6.7).

## 12. Registro de decisiones

Resumen de las decisiones que afectan a este documento. El detalle completo está en `Decisiones.md`.

| Fecha | Decisión | Motivo |
|---|---|---|
| 30/09/2026 | Criaturas y mundo 100% originales | Evitar problemas legales con Pokémon |
| 30/09/2026 | Combate por turnos en casillas, vista isométrica | Permite que el Maestro pelee junto a sus criaturas con táctica real |
| 30/09/2026 | Permadeath condicional con rescate por lealtad | Une muerte, lealtad y relaciones en una sola mecánica |
| 30/09/2026 | Mundo fijo + eventos al azar | Identidad de mundo + rejugabilidad |
| 30/09/2026 | Sprites en 4 direcciones | Contener costo de arte |
| 30/09/2026 | Magia exclusiva del Maestro, con maná como recurso | Refuerza el Pilar 1 |
| 30/09/2026 | Maná: regenera por turno en combate y se recupera al dormir | Ritmo táctico sin salir del reloj de supervivencia |
| 30/09/2026 | Hambre reduce la regeneración de maná; hambre extrema la corta | Mantiene el hambre como único recurso de supervivencia |
| 30/09/2026 | Sellar, invocar y hechizos comparten el mismo maná | Tensión entre pelear, capturar e invocar (Pilares 2 y 4) |
| 30/09/2026 | El pergamino es el contenedor de la criatura; guardadas protegidas, sueltas expuestas | Convierte al pergamino en decisión de supervivencia |
| 30/09/2026 | Criaturas guardadas no ganan lealtad ni tienen relaciones | Protege el Pilar 3: tribu, no colección |
| 30/09/2026 | Solo las criaturas sueltas pueden rescatar al Maestro | Conecta el sistema de pergaminos con la regla de oro |
| 30/09/2026 | "Afinidad mágica" pasa a "Aptitud mágica" (provisorio) | Evitar confusión con afinidades entre criaturas |
| 30/09/2026 | La Aptitud alta debilita el cuerpo y los vínculos del Maestro | Evita un atributo dominante; conecta magia con la regla de oro |
| 30/09/2026 | Sellado probabilístico por combate, seguro por confianza; el % se muestra antes | Tensión táctica informada; premia la paciencia |
| 30/09/2026 | Lealtad inicial baja por combate y alta por confianza | Ambos caminos tienen ventajas reales |
| 30/09/2026 | Tope de maná en combate igual al maná de entrada | Mata el exploit de alargar combates; dormir importa |
| 30/09/2026 | Invocar en combate gasta el turno completo del Maestro | Incentiva tener criaturas sueltas, que cuestan comida |
| 30/09/2026 | Come toda criatura que estuvo suelta en algún momento del día | Mata el exploit de guardar antes de dormir |
| 30/09/2026 | Nombres en castellano evocador | Identidad clara y cercana al tono medieval |
| 30/09/2026 | Región inicial Valdelumbre, campamento el Molino Callado, 3 destinos de riesgo creciente | Enseña la supervivencia de menor a mayor riesgo |
| 30/09/2026 | La comida tiene tipos y cada criatura tiene favorita, acepta y rechaza | Alimentar al grupo se vuelve una decisión |
| 30/09/2026 | Un solo estado negativo en el MVP: Enfermo, con tres causas narrativas | Pilar 4 sin multiplicar el balance |
| 30/09/2026 | Abandono nocturno: criatura suelta, famélica y desleal | Refuerza los Pilares 3 y 4 con una sola regla |
| 30/09/2026 | 5 criaturas en el MVP: 4 reclutables + Tasajero como encuentro aspiracional | Progresión aspiracional sin romper la balanza inicial |
| 30/09/2026 | Carisma y Aptitud mágica son los dos polos de una sola balanza | El carisma se vuelve una elección; la regla de oro se hace visible |
| 30/09/2026 | La balanza se mueve 1 paso por nivel hacia cualquier polo, con aviso previo de rescatistas perdidos | Progresión con identidad; decisiones informadas |
| 30/09/2026 | El Maestro es omnívoro pero necesita dieta variada | Mantiene abierta la decisión de comerse una criatura y empuja a viajar |
| 30/09/2026 | La idea del Tasajero y la despensa se posterga hasta que sea reclutable | No tiene dónde aplicarse en el MVP |
| 30/09/2026 | Obediencia = lealtad descontada por el hambre; rige el combate, el rescate usa la lealtad real | El hambre desordena a la tribu |
| 30/09/2026 | Combos, afinidad por adyacencia, incidentes y provocación (Encono) | Las relaciones se juegan como táctica; reemplaza la PROPUESTA de adyacencia |
| 30/09/2026 | Enfermo acumulable, con cura por descanso o viaje | Cada mala decisión de comida suma |
| 30/09/2026 | Ataque nocturno con combate en el Molino y tres salidas para la atacante | La tribu se ve jugando |
| 01/10/2026 | La balanza pasa a llamarse Barro ↔ Soplo; Liderazgo pasa a Arrimo (provisorio) | Nombres evocadores que hacen visible la regla de oro |
| 01/10/2026 | Los Nueve, lo etéreo y el pergamino que arde ante todo vínculo roto | Fundamento del mundo que explica la balanza y los pergaminos |
| 01/10/2026 | Progresión por nivel: 1 punto a Poder o Regeneración + 1 paso opcional de balanza | La balanza es un intercambio, no una ganancia |
| 01/10/2026 | La clase del MVP arranca inclinada al Barro | El MVP enseña primero la tribu |
| 01/10/2026 | Las criaturas de trabajo se acobardan ante una rival enemiga; la obediencia puede hacerlas resistir | Regla general por rol; reemplaza el "encono de presa" |
| 01/10/2026 | Los pergaminos limitan el tamaño de la tribu y nunca son un recurso de supervivencia | Protege el hambre como único recurso y el Pilar 3 |
| 01/10/2026 | El ritual de sangre en el Molino es la única fuente de pergaminos del MVP; evento con requisitos, no crafteo | Pilar 4 sin adelantar la Capa 1 |
| 01/10/2026 | Los materiales del ritual salen uno de cada destino | Cada pergamino exige recorrer el valle |
| 01/10/2026 | Sin tipos ni linajes en el MVP; a futuro, solo linajes de hechura | Alcance y originalidad |
| 01/10/2026 | La Mudanza y el santuario de escribas entran en Ideas en espera | Alcance del MVP |
| 01/10/2026 | Arrimo, Encono y Secundar, nombres finales; Urdimbre, prenda, péñola y "lo que diste" | Glosario confirmado por el Worldbuilder (`Mundo.md` v0.3) |
| 01/10/2026 | Regla del ritual: nada se arranca, todo se recoge; solo el Maestro paga con daño | Pilar 4 como decisión del jugador, no crueldad del mundo |
| 01/10/2026 | Trabajo → cobardía; combate y mixta → Encono | Regla general de dos ramas |
| 01/10/2026 | La balanza inicial depende de la clase; ninguna arranca en un polo | Clases distintas sin sistemas nuevos |
| 01/10/2026 | El Maestro arranca con una compañera fija, suelta y Neutral, que ocupa un pergamino | Evita el permadeath sin decisiones; la regla de oro es la lección del día 1 |
| 01/10/2026 | La compañera es la Rodauva; puede haber varias de una misma especie; la Rodauva es el piso de supervivencia | Red de seguridad que no regala el combate (Pilar 2) |
| 01/10/2026 | Muda colectiva de cinco Rodauvas, con contador por grupo, aprobada en espíritu | La valentía de la cobarde llega de la manada (Pilar 3) |
| 01/10/2026 | Barra de zozobra: llena dispara el defecto o su superación; disparador general de la Mudanza; entra con su capa | La Mudanza vuelve a ser regla general; original frente a Darkest Dungeon |
| 01/10/2026 | Caídas: la criatura en 0 se levanta si se gana y muere si se pierde; si cae el Maestro, el combate termina; la salvaje en 0 huye | La muerte es consecuencia de cómo termina la pelea (sección 8) |
| 01/10/2026 | La involución: forma permanente consumida por el defecto, con triple disparador | La regla de oro se ve en el cuerpo; nunca es accidental |
| 01/10/2026 | Órdenes (voz, con lealtad) y subyugación (magia, con maná retenido) | El Barro manda por vínculo; el Soplo, por dominio |
| 01/10/2026 | Rasgos de combate y hechizos (Martillazo, Lanzadera, Remiendo) aprobados | Pilares 1 y 2; la Lanzadera vuelve táctica a las relaciones |
| 01/10/2026 | Guardar a una caída, huida y salvajes que huyen en su turno | Decisiones informadas antes de caer |
| 01/10/2026 | Campamento al raso completo en el MVP | Dormir afuera es inevitable; la tribu variada duerme mejor (Pilar 3) |
| 01/10/2026 | Secuela: el quebranto hace perder 1 de vida máxima por día hasta la Poza Tibia | Reloj visible; la tribu sostiene al Maestro débil |
| 01/10/2026 | Experiencia mixta con peso en los hitos de la tribu | El Maestro crece cuando crece su tribu |
| 01/10/2026 | Permadeath absoluto y sin límite de sueltas en el MVP | Testear la regla de oro sin ruido |
| 01/10/2026 | Alcance del MVP congelado | Proteger la sección 9 |
| 01/10/2026 | Capa 0 dividida en 0a (rebanada de combate) y 0b (loop completo) | Validar el combate antes de construir el loop |
| 02/10/2026 | Recuperación de 2 días y Poza Tibia aprobadas; el quebranto no recupera maná al dormir | La tribu sostiene al Maestro débil (regla de oro) |
| 02/10/2026 | Vista cenital en 0a.1 y 0a.2, isométrica antes de los playtests | Velocidad de desarrollo sin perder la lectura isométrica |
| 02/10/2026 | La partida del MVP termina por plazo fijo con un epílogo que lee la tribu, sin puntaje | Sin final no se testea la 0b, y la regla de oro necesita su recompensa |
| 02/10/2026 | Ningún final premia vaciar la tribu: lo comido pesa en el epílogo | Evita el exploit del último día (Pilar 4 con sentido) |
| 02/10/2026 | Plazo de 30 días; el Menestral; quebranto; las rayas y las golondrinas | Cierres de Sistemas (`Sistema.md` 13) y del Worldbuilder (`Mundo.md` v0.6) |
| 02/10/2026 | Guardado de suspensión: salir a mitad de un combate retoma el estado exacto | Salir nunca repite una tirada; protege el permadeath |
| 02/10/2026 | El Maestro que cae tras declarar la huida queda caído y se busca rescatista | La huida es una apuesta anticipada, no un seguro |
| 02/10/2026 | Las salvajes tienen afinidad, pero no encadenan combos | El combo es algo que solo da el vínculo con el Maestro (Pilar 3) |
| 02/10/2026 | El +1 por victoria lo reciben las de pie y las caídas que se levantan, no las guardadas | Premia a la que arriesgó; el pergamino congela el vínculo |
| 02/10/2026 | El Soplo casi no se juega en la 0b; la balanza inicial es parámetro de test | El MVP enseña la tribu sin dejar el Soplo sin probar |
| 03/10/2026 | Los eventos de lealtad alcanzan solo a las sueltas, incluidas las muertes y comidas de compañeras | El pergamino congela el vínculo |
| 03/10/2026 | Tasajero con dos turnos completos y un solo Encono; la Rodauva salvaje se eriza herida y acorralada; golpe inicial nocturno como ataque normal | Cierres de Sistemas (`Sistema.md` v0.9) |
| 03/10/2026 | Textos del MVP completos y aprobados, incluido el ritmo del día; Claude Code nunca inventa un texto | La calidez del Pilar 4 vive en el ritmo del día; cada área edita lo suyo |
| 03/10/2026 | Guardado de suspensión por grabación; flujo de Git con `main` para hitos y `develop` para el trabajo diario | Salir nunca repite una tirada; el usuario controla lo que se publica |
| 03/10/2026 | Comer a una criatura solo en el reparto de la noche, junto al fuego | Un solo momento para la decisión más dura; el combate no se vuelve fuente de carne (Pilares 3 y 4) |
| 03/10/2026 | Luz verde a la 0a; hitos de la 0b validados; las 13 métricas de `Sistema.md` 11.9 y sus umbrales miden los criterios de éxito | El MVP queda definido para construir |
| 03/10/2026 | `Decisiones.md` es el historial, no la fuente de verdad; queda fuera de `docs/` | Claude Code trabaja con las reglas vigentes |
| 05/10/2026 | Todo rasgo se ve en pantalla y avisa cuando actúa | Playtest 0a.1: los rasgos pasivos no se notaron |
| 05/10/2026 | Se evalúa y se descarta el combate en 8 direcciones: cuadrícula ortogonal | Las diagonales abaratan la táctica |
| 05/10/2026 | Principio de las activas: trueque sobre el propio cuerpo, sin estadísticas nuevas; las de trabajo nunca de daño | Generaliza Erizarse; refuerza los Pilares 2 y 4 |
| 05/10/2026 | Un solo rasgo por criatura, reescrito como activa donde aporta | Respeta el alcance congelado; la Mudanza conserva su premio |
| 05/10/2026 | Hacerse junco pasa a ser activa; el surco reemplaza a Lomo de tierra y es el único terreno del MVP | Rasgos que generan decisiones; defensa para una criatura de trabajo |
| 05/10/2026 | Caza y cuenta: un turno por ronda, empieza en Caza (dos ataques, recibe más daño) y pasa una vez a Cuenta (parte el movimiento, pega menos) | El Tasajero desgasta, no ejecuta; castiga la formación apretada |
| 05/10/2026 | Los rasgos reescritos se programan antes de cerrar la 0a.2 | Tocan tareas terminadas; una sola pasada de balance |
| 05/10/2026 | El surco solo lo atraviesa un Surcón, de cualquier bando | Identidad de cavador; el surco es un pasillo propio, no solo un muro |
| 05/10/2026 | Cavar el surco le gasta al Surcón el turno completo | Paga con su movimiento y su ataque: el Surcón que cava no pelea |
| 05/10/2026 | Los playtests de E y F no llevan encuesta: los umbrales se miden solo con el registro | Tests livianos; se reabre si los comentarios contradicen los números |
| 05/10/2026 | La prenda no tiene consecuencias en el MVP; el epílogo que la nombra queda en espera | Pilar 3 sin reglas nuevas; alcance congelado; el ritual duele por la sangre, no por una optimización |
| 05/10/2026 | Si el Maestro cae con la atacante nocturna caída, ella se va: su pergamino arde, sin cambio de lealtad | La decisión moral tiene un solo momento (6.5); irse es la norma; sin decisión del Maestro, la tribu no reacciona |
| 07/10/2026 | Mover, atacar, guardar y la Caza siguen ortogonales (4 adyacentes) | Ratifica el 05/10: las diagonales abaratan la táctica |
| 07/10/2026 | Las relaciones (afinidad, incidentes, sostén de la cobardía) miran las 8 vecinas; los combos no miran la posición | La afinidad y el foco cuerpo a cuerpo se excluían (Pilar 3); refuerza el dilema del Tasajero |
| 07/10/2026 | Tablero de referencia 12 × 12, con cámara móvil; un escenario puede ser menor | Espacio para maniobrar y planear (A-2) |
| 07/10/2026 | Criterio: primer contacto en la ronda 2 | El tablero grande no puede cobrar hambre por caminar |
| 07/10/2026 | Orden de trabajo: T16 sigue; vecinas en 8 antes de T18; tablero nuevo antes de los playtests de la 0a.2 | Nada bloquea T16; T18 y T19 nacen con la regla nueva; las alarmas se miden sobre el tablero real |
| 07/10/2026 | Los bandos ya se intercalan en la cola; sin cambios | Confirmado en el escenario C; Secundar depende de eso |
| 10/10/2026 | Los Legados y sus Sombras (rueda de 18) reemplazan a los linajes de hechura como norte; quedan en Ideas en espera, fuera de la 0a y la 0b | Alcance congelado; el MVP no tiene linajes |
| 10/10/2026 | Cuatro ciclos por distancia en la rueda (generación +1, potenciación +4, anulación +8, inversión +9), que actúan sobre la carga y nunca multiplican el daño | Sin tabla de efectividad: el sistema queda propio (sección 8) |
| 10/10/2026 | Almacén de carga por unidad: todo legado suma, solo la anulación resta y su sobrante se pierde | La anulación es la única limpieza; la carga es una apuesta |
| 10/10/2026 | Quien completa el umbral decide: un enemigo → explosión e inversión; una aliada o la propia → el Maestro elige generación o inversión | Dar el último punto es una decisión táctica; invertir a una propia es un sacrificio con costo |
| 10/10/2026 | La invertida queda extenuada el resto del combate y del día; sigue comiendo y puede rescatar | La consecuencia del combate llega al día (Pilar 4); la regla de oro no depende de un estado de combate |
| 10/10/2026 | Potenciación: carga solo el legado potenciado, con +1, si ya está en el almacén o es un legado propio del objetivo | El ciclo actúa sobre la carga; premia leer el almacén |
| 10/10/2026 | Lo que no le gusta = Sombra o anulador de sus legados; carga propia o aliada → lealtad; carga enemiga → obediencia | El vínculo solo se rompe por decisiones del jugador (sección 8) |
| 10/10/2026 | El Maestro es avatar de los legados: arma = legado de ataque, armadura = dos legados defensivos; equipo elegido antes del combate y cambio de arma con costo de turno | Pilar 1 sin que el Maestro sea el anulador universal |
| 10/10/2026 | La rueda del árbol: la afinidad del Maestro crece con la tribu que elige y por la rueda; especializarse limita | Construcción profunda sin un árbol aparte; el Maestro crece con su tribu (Pilares 1 y 3) |
| 12/10/2026 | Una criatura se distingue por sus atributos base, sus activas y su combinación de legados; cada criatura tiene un legado principal y uno secundario | Identidad de cada especie entre más de 100 sin una tabla de tipos |
| 12/10/2026 | Cada legado da un perfil de atributos (dos altas y dos bajas, en espejo dentro del par; Lleno ↔ Vacío es la excepción) y un verbo que guía las activas de sus especies, sin reglas globales | Invertir le da vuelta a la criatura justo en lo que es buena; identidad reconocible sin 18 reglas para programar |
| 12/10/2026 | Dos legados pueden compartir sus altas si sus bajas son distintas; el perfil completo no se repite | 18 legados no entran en 15 combinaciones de dos altas |
| 12/10/2026 | Boceto de estadísticas del juego completo: Fuerza, Agilidad, Constitución, Sabiduría, Espíritu, Resistencia y Suerte; sin Inteligencia; el MVP sigue con sus cinco | Base de los perfiles sin tocar el alcance congelado; cada estadística genera una decisión propia |
| 12/10/2026 | La Suerte rige solo los picos y siempre se muestra como probabilidad | Es la estadística de Inspiración, no un dado escondido (sección 8) |
| 12/10/2026 | Los 18 legados quedan definidos con verbo y perfil (tabla de la sección 10) | Sistema completo en papel |
| 12/10/2026 | La inversión va a la Sombra de un legado propio (el de más carga; en empate o sin carga, el principal); reemplaza "la Sombra del dominante" y la regla de empate del 10/10 | Cada criatura tiene a lo sumo dos inversiones, que se aprenden; el almacén sigue decidiendo hacia dónde explota |
| 12/10/2026 | Inversión por enemigo: toma solo la forma de pegar de la Sombra; inversión propia: toma el cuerpo entero de la Sombra, con extenuación y pérdida de lealtad | Una sola regla para el desacople; el sacrificio táctico sigue teniendo costo |
| 12/10/2026 | Generación: defiende como el legado siguiente y gana sus atributos; cuesta fatiga, nunca extenuación (reemplaza "1 punto del legado siguiente") | La generación cansa y la inversión agota; la explosión sigue siendo un evento |
| 12/10/2026 | El Remiendo es la curación de urgencia; la de las criaturas es de a poco | Las criaturas que curan no reemplazan al Maestro (Pilar 1) |
| 12/10/2026 | Drenar a una aliada a la que no le gusta empeora su relación con la que drena durante un par de días | El costo de Drenaje recae en el vínculo de la tribu (Pilares 3 y 4) |
| 12/10/2026 | Desapego, al atacar, corta los lazos de Unión de los dos bandos; es más fuerte sin vecinas y como última criatura de su bando; su lealtad cambia más lento, nunca es inmune | Espejo exacto de Unión; la regla de oro sigue intacta |
| 12/10/2026 | Si cae el Maestro, solo las de Desapego siguen peleando; la rescatista (leal) se lleva al Maestro con las demás; si las de Desapego ganan, las caídas se salvan. Solo en el juego completo | Desapego no pelea por el Maestro: no lo necesita; el rescate sigue siendo de una leal (regla de oro) |
| 13/10/2026 | Más allá de Valdelumbre: 5 salidas desde el valle (aguas abajo con la primera ciudad, las colinas, la meseta, aguas arriba y la boca); la ciudad está cerca de lo seguro y lejos de lo valioso. Post-MVP, Capa 4 | Exploración con elección sobre un mapa fijo; ninguna salida es la mejor (Pilar 2) |
| 13/10/2026 | Lo hondo: lugares misteriosos accesibles desde temprano, con acceso condicionado; siempre avisa con señales del mundo y de la tribu, nunca con porcentajes | Miedo y descubrimiento sin contradecir la sección 8 |
| 13/10/2026 | La boca: cueva en la ladera de la montaña, quinta salida, de solo ida y fuera de los mapas que se venden | Completa las 5 salidas con un lugar hondo |
| 13/10/2026 | Vender una criatura rompe el vínculo: el pergamino arde, la tribu lo ve y el epílogo lo cuenta; el comprador sella con un pergamino propio. Comprar exige un pergamino en blanco y arranca con lealtad baja. Nada del cuerpo de una criatura se vende | Respeta el lore del hilo; la venta no puede ser la forma de que comer rinda (6.5) |
| 13/10/2026 | Sección 8 enmendada: no es un juego de colección por defecto; coleccionar es el camino del Soplo y se paga con la regla de oro | El Barro manda por vínculo y el Soplo por dominio; la colección queda como elección con costo |
| 13/10/2026 | Las criaturas solo llevan aparejos de trabajo y carga, sin efecto en combate | La especie sigue definiendo a la criatura (Pilar 2); la mochila depende de las de trabajo |
| 13/10/2026 | Trabajos encargados a las criaturas según su aptitud; misiones como expediciones con rumores y mapas (nunca "matá 5 de X"); carteles de recompensa, con "muerta" solo para individuos marcados; criminales como Maestros renegados con tribu propia | Pilar 2; el desafío está en elegir y preparar la misión; reutiliza el sistema de la tribu |
| 13/10/2026 | En la ciudad, el hambre se paga con plata; afuera vuelve a regir. Basural con criaturas carroñeras. Corral por día que protege pero no une, o campamento afuera expuesto a bandidos, emboscadas y clima. Quedarse en la ciudad siempre gasta más de lo que dan sus trabajos | El reloj cambia de forma, no desaparece (Pilar 4); la ciudad no reemplaza al Molino (Pilar 3) |
| 13/10/2026 | La comida cuesta plata y espacio; cada objeto de tienda debe generar una decisión propia; el fuego sigue siendo de tiempo y lo comprado solo lo acelera | Prepararse es parte del juego sin inflar la tienda; respeta 6.9 |
| 13/10/2026 | Primera porción post-MVP: aguas abajo, la primera ciudad, el corral, los encargos, una misión de captura por rumores y la boca | Probar la ciudad, la expedición y lo hondo antes de multiplicar el contenido |
| 13/10/2026 | El juego completo es de exploración abierta, sin final definido; cualquier final futuro lee a la tribu | El epílogo es la regla de oro vista de frente |
| 13/10/2026 | Capas reordenadas: economía, comercio y NPCs pasan a la Capa 4; facciones, reinos, historia y misiones principales, a la Capa 5 | Salir del valle necesita comercio antes que reinos |

## 13. Registro de versiones

| Versión | Fecha | Cambio |
|---|---|---|
| v0.1 | 30/09/2026 | Creación: pitch, pilares, estructura, sistemas centrales y alcance del MVP |
| v0.2 | 30/09/2026 | Nueva sección 6.7: magia, maná y pergaminos |
| v0.3 | 30/09/2026 | Integra `Sistema.md` v0.1 y `World.md` v0.1. Balanza Carisma ↔ Aptitud mágica (6.1). Captura probabilística y lealtad inicial por camino (6.3). Estados de lealtad y abandono nocturno (6.4). Tipos de comida, estado Enfermo y dieta variada del Maestro (6.5). Umbral de rescate (6.6). Tope de maná y reglas de pergaminos en combate (6.7). Convención de nombres (7). MVP actualizado con Valdelumbre y las 5 criaturas (9). Ideas en espera (10). Nueva sección de versiones (13) |
| v0.4 | 01/10/2026 | Integra `Sistema.md` v0.2 y `World.md` v0.2. Balanza Barro ↔ Soplo, Arrimo, progresión por nivel y balanza inicial (6.1). Cobardía por rol y sin tipos en el MVP (6.2). Obediencia, combos, afinidad, incidentes, Encono, cobardía y ataque nocturno (6.4). Bichos, muerte por hambre y Enfermo acumulable con cura (6.5). Pergaminos que arden, límite de tribu y ritual de sangre (6.7). Nueva sección 6.8: fundamento del mundo. Tono y originalidad (7). "No es" ampliado (8). MVP actualizado (9). Mudanza y escribas en Ideas en espera (10). Preguntas abiertas actualizadas (11) |
| v0.5 | 01/10/2026 | Integra `Mundo.md` v0.3 y corrige la referencia a `World.md`. Arrimo, Encono y Secundar finales (5, 6.1, 6.4). Balanza inicial por clase (6.1). Encono de las mixtas y compañera inicial (6.2). Ritual con péñola, prenda, Urdimbre, regla de "nada se arranca" y "lo que diste" (6.7). Rastros de los Nueve (6.8). Urdimbre en originalidad (7). Compañera inicial en el MVP (9). Preguntas abiertas actualizadas (11) |
| v0.6 | 01/10/2026 | Salvajes que huyen en 0 (6.3). Caídas y fin del combate al caer el Maestro (6.6). Ideas en espera: la involución, las órdenes (Grito) y la subyugación; la barra de zozobra conecta con la involución (10). Preguntas abiertas actualizadas (11) |
| v0.7 | 01/10/2026 | Integra `Sistema.md` v0.5 y `Mundo.md` v0.5. Emboscada y campamento al raso (Escala 1, nueva 6.9). Mapa del día, agotamiento y pudrición (Escala 2, 6.5). Molino de agua y único refugio (Campamento). Experiencia (6.1). Rasgos de combate y la Rodauva dueña del Molino (6.2). Salvajes que huyen en su turno (6.3). Afines contra la cobardía y ataque al raso (6.4). Guardar a una caída, huida, malherido, Poza Tibia y permadeath absoluto (6.6). Hechizos (6.7). Alcance congelado y MVP actualizado (9). Acequia en la Capa 1 y `PROPUESTA` 0a/0b (10). Preguntas abiertas (11) |
| v0.8 | 02/10/2026 | Nueva subsección "Fin de la partida — el epílogo" (5). Malherido no recupera maná al dormir (6.6). Partida con plazo y epílogo en el MVP (9). División 0a/0b `DECIDIDO` y vista de la 0a (10). Preguntas abiertas: se cierran motor, 0a/0b y fin de partida; nuevas: nombre de la clase, marca del final del plazo y duración (11) |
| v0.9 | 02/10/2026 | Plazo de 30 días con las rayas y las golondrinas (5). El Menestral (6.1, 9). Victoria por estado al terminar y salvajes con afinidad sin combos (6.4). Quebranto reemplaza a malherido; caída tras declarar la huida; guardado de suspensión (6.6). El Soplo en la 0b (10). Preguntas abiertas cerradas: clase, marca del plazo, duración y quebranto (11) |
| v1.0 | 03/10/2026 | **MVP definido.** Regla de cuándo se come a una criatura (6.5). Elisión de comer y del abandono (7). Estado de construcción: luz verde a la 0a, criterios de éxito con umbrales e hitos de la 0b validados (10). Papel de `Decisiones.md` y `Arquitectura.md` en el encabezado. Preguntas abiertas: se cierran cuándo comer y los umbrales; nueva: encuesta en E y F (11). Registro del 03/10 (12) |
| v1.1 | 05/10/2026 | **Rasgos reescritos tras el playtest 0a.1.** Cuadrícula ortogonal, diagonales descartadas (Escala 3). Principio de las activas, rasgos del MVP, Caza y cuenta en dos modos y rasgos visibles (6.2). Rasgo por criatura y el surco como único terreno, que solo atraviesa un Surcón (9). Hallazgos de la 0a.1 y orden de trabajo (10). Preguntas abiertas: nuevas sobre el surco y la IA del Tasajero; cerradas las diagonales y las activas (11). Registro del 05/10 (12) |
| v1.2 | 05/10/2026 | La atacante nocturna se va si el Maestro cae antes de decidir, sin cambio de lealtad (6.4, responde P-024). La prenda en el epílogo pasa a Ideas en espera (10). Preguntas abiertas: se cierran la encuesta de E y F, la prenda y la atacante (11). Registro del 05/10 (12) |
| v1.3 | 07/10/2026 | **Geometría y tablero.** Adyacencia en 4 para mover, atacar, guardar y la Caza; las relaciones miran las 8 vecinas; los combos no miran la posición; tablero de referencia 12 × 12 con cámara móvil y contacto en la ronda 2; bandos intercalados en la cola (Escala 3). Vecinas en 6.4 y en la nota del Tasajero (6.2). MVP actualizado (9). Orden de trabajo del 07/10 y vecinas en la barra de zozobra y la Muda colectiva (10). Preguntas abiertas: nuevas para Sistemas sobre afinidad e incidentes en 8 y despliegues en 12 × 12; cerradas afinidad y foco, tablero e intercalado (11). Registro del 07/10 (12) |
| v1.4 | 11/10/2026 | **Los Legados y sus Sombras** en Ideas en espera: rueda de 18, cuatro ciclos sobre la carga, almacén con explosión, inversión y extenuación, lo que no le gusta a cada criatura, el Maestro avatar y la rueda del árbol (10). Reemplazan a los linajes de hechura (6.2) y se nombran en el Maestro (6.1), en "no es" (8) y en el MVP como fuera de alcance (9). Preguntas abiertas: nuevas para Worldbuilder y Sistemas; cerrada la de cómo funcionan los linajes (11). Registro del 10/10 (12). Sin cambios en la 0a ni en la 0b |
| v1.5 | 12/10/2026 | **Los 18 legados definidos.** Legado principal y secundario; perfil de atributos y verbo de cada legado; boceto de siete estadísticas del juego completo con Suerte y sin Inteligencia; tabla de los 18; casillero 5 = Intemperie (provisorio); inversión hacia la Sombra de un legado propio; inversión por enemigo (solo la forma de pegar) y propia (el cuerpo entero); generación con fatiga; Desapego sigue peleando si cae el Maestro; criterios de visión nuevos (10). Nota de la excepción de Desapego en 6.6 y estadísticas fuera del MVP (9). Preguntas abiertas: nuevas para Worldbuilder y Sistemas; cerradas qué da cada legado, Inteligencia y hacia dónde se invierte (11). Registro del 12/10 (12). Sin cambios en la 0a ni en la 0b |
| v1.6 | 13/10/2026 | **Más allá de Valdelumbre** en Ideas en espera (Capa 4): 5 salidas con la ciudad cerca de lo seguro; lo hondo, que siempre avisa con señales; la boca; la ciudad (hambre con plata, basural, corral que protege pero no une); compra y venta de criaturas que rompe el vínculo; trabajos; misiones como expediciones, carteles y Maestros renegados; mochila y objetos; aparejos de trabajo para las criaturas; primera porción propuesta (10). Sección 8 enmendada: coleccionar es el camino del Soplo. Venta en los vínculos rotos (6.7). Final del juego completo: exploración abierta, cualquier final lee a la tribu (5). Capas 4 y 5 reordenadas, con dependencias; referencias a la historia (5, 6.2) y a los escribas (10) actualizadas. Preguntas abiertas nuevas y cerradas (11). Registro del 13/10 (12). Sin cambios en la 0a ni en la 0b |
