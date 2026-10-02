# 00 — VISIÓN DEL JUEGO

> **Estado:** Borrador v0.7 · **Dueño:** Director Creativo · **Última actualización:** 01/10/2026
> Este documento es la fuente de verdad. Ningún agente puede contradecirlo sin proponer un cambio y registrarlo en `Decisiones.md`.
> **Documentos subordinados:** `Sistema.md` (reglas y números) · `Mundo.md` (mundo, regiones y criaturas). Este documento define **qué** y **por qué**; los números viven en `Sistema.md`, y el detalle del mundo, en `Mundo.md`.
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
- El orden de actuación lo define la **iniciativa** de cada unidad. Una unidad puede **Secundar**: actuar justo después de un aliado elegido, a cambio de dejar que los enemigos intermedios actúen antes.
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

**Balanza inicial:** la clase del MVP arranca **inclinada hacia el Barro**. El MVP enseña primero la tribu, porque lo que se testea es si la regla de oro es divertida.
- **La posición inicial de la balanza es parte de la identidad de cada clase** (Capa 3).
- **Ninguna clase arranca en un polo.** La balanza es un viaje: arrancar en un extremo le quita al jugador la mitad de la decisión.

**Alimentación del Maestro:**
- Es **omnívoro**: puede comer cualquier tipo de comida, incluida una criatura.
- Necesita una **dieta variada**: si come el mismo tipo de comida varios días seguidos, cae **Enfermo** (ver 6.5). La interfaz avisa antes de que pase.

### 6.2 Criaturas
- Tienen habilidades **activas y pasivas**, que funcionan **dentro y fuera del combate**.
- Pueden combatir, trabajar y transportar objetos.
- Compromiso fijo: más aptitud de combate = menos utilidad, y viceversa. El rol también define el temperamento ante una rival enemiga: las criaturas **de trabajo** **se acobardan**; las **de combate y las mixtas** **se enconan** (ver 6.4).
- Tienen un **rango** (1 a 3) que representa su fuerza y define cuánto cuesta sellarlas e invocarlas.
- En el MVP, cada criatura tiene **un solo rasgo de combate**: **Erizarse** (Rodauva), **Lomo de tierra** (Surcón), **Alabarda** (Ocarra), **Hacerse junco** (Zancajunco) y **Caza y cuenta** (Tasajero, dos turnos por ronda).
- Cada criatura tiene una comida **favorita**, comidas que **acepta** y comidas que **rechaza** (ver 6.5).
- Cada criatura está en uno de dos estados: **guardada** en su pergamino o **suelta** (ver 6.7).
- **La compañera inicial:** el Maestro **no arranca solo**. Empieza con **una criatura fija**, **suelta**, que **ocupa uno de los pergaminos iniciales** y empieza **Neutral**: le faltan pocos días bien alimentada para poder rescatarlo.
  - **Por qué:** un Maestro solo, en sus primeros días, moriría sin haber tomado ninguna decisión sobre su tribu, y eso contradice la sección 8. Una compañera ya leal regalaría la regla de oro. Con una compañera que todavía no es leal, la regla de oro es la lección del día 1: *si la cuidás, te va a salvar; todavía no*.
  - **Criterios:** rango 1, **de trabajo** (el jugador tiene que salir a buscar quién pelee, Pilar 2, y el Maestro carga con el combate al principio, Pilar 1) y con su comida favorita cerca del Molino.
  - **Es la Rodauva, la dueña del Molino**: ya vivía junto a la piedra del fuego cuando llegó el Maestro (ver `Mundo.md` 4.8). La relación se invierte: el recién llegado es él.
  - La apertura **no explica el pasado del Maestro**: ese hueco depende de la clase (Capa 3) y de la historia principal (Capa 4).
- **Puede haber varias criaturas de la misma especie** en la tribu. La **Rodauva es el piso de supervivencia**: abundante y fácil de domesticar. Muchas Rodauvas aseguran un mínimo de comida, no una partida fácil: una tribu de Rodauvas recolecta bien y pelea mal (Pilar 2).
- En el MVP **no hay tipos ni linajes**. Si a futuro existen, serán **linajes de hechura** (cuál de los Nueve modeló a la criatura), nunca elementos como fuego, agua o planta.

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
- Lo que la destruye: el hambre, comer lo que rechaza, la muerte de compañeros y, sobre todo, que el Maestro se coma a una criatura.
- Repartir la comida es una decisión: alimentar bien a algunas o poco a todas.

**Obediencia:** es la lealtad en el momento, **descontada por el hambre**. La lealtad es el vínculo de fondo; la obediencia es cuánto pesa ahora.
- **En combate, todo se lee sobre la obediencia. El rescate usa la lealtad real.**
- Una criatura leal con hambre deja de ser tu mejor aliada en el tablero, aunque todavía pueda rescatarte.
- El Maestro es **afín** de toda criatura con obediencia leal: pelear juntos los potencia.

**Relaciones** (criatura ↔ criatura): en el MVP, un solo tipo: **se llevan bien** o **se llevan mal**. En el tablero se juegan así:
- **Afines vecinas:** se potencian.
- **Combos (ataque en cadena):** aliados que actúan seguidos sobre el mismo objetivo suman daño; entre afines, más. Cada eslabón vale menos que el anterior.
- **Rivales aliadas vecinas:** riesgo de **incidente**. Una criatura obediente se distrae; una poco obediente ataca a su rival.
- **Rival enemiga — Encono** *(antes "provocación")*: las criaturas **de combate y mixtas** pueden ensañarse; la criatura puede ensañarse y atacar a su rival sí o sí, ganando fuerza y perdiendo control.
- **Cobardía:** las criaturas **de trabajo**, ante una rival enemiga, no se enconan: se acobardan y quedan debilitadas. Su obediencia puede hacerlas resistir: **la regla de oro también se ve en el coraje**. Las **afines adyacentes** también la sostienen (regla a testear en el MVP).
- **Salvajes:** siguen las mismas reglas, sin obediencia que las contenga. Atraer a dos rivales salvajes es una táctica legítima.
- Toda probabilidad de incidente o Encono se **muestra antes** de mover.

Las criaturas **guardadas** en pergamino **no ganan ni pierden lealtad, ni participan de relaciones**. El vínculo solo se construye con criaturas sueltas.

**Abandono y ataque nocturno:**
- Durante la recuperación del Maestro, las criaturas de poca lealtad pueden irse (ver 6.6).
- Fuera de la recuperación, una criatura **suelta, famélica y desleal** puede **irse durante la noche**. La interfaz marca el riesgo antes de dormir; guardarla en su pergamino evita el chequeo, pero congela el vínculo.
- Criterio de visión: ante una criatura desleal y famélica, **irse es la norma; atacar al Maestro es la excepción**.
- **Ataque nocturno:** la criatura golpea primero y empieza un combate donde se duerme, en el Molino o al raso. Las sueltas leales defienden al Maestro. El sueño interrumpido le deja menos maná.
- **La atacante derrotada** queda caída y el Maestro elige: **perdonarla** (se va libre; la tribu valora la clemencia), **sellarla** de nuevo (con un pergamino nuevo y lealtad mínima) o **comerla** (la tribu vio la traición, y el golpe social es menor).
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
- **Si el Maestro cae, el combate termina.** La rescatista lo arrastra al campamento y **las caídas quedan atrás y mueren**: la que te salva no puede cargar a todas.
- Una salvaje en 0 huye (ver 6.3). La atacante nocturna, en cambio, queda caída para que el Maestro decida (ver 6.4).
- El Maestro puede **guardar a una caída** gastando su acción y maná: sobrevive en su pergamino aunque después se pierda el combate. Hay que decidirlo **antes** de caer.
- El Maestro puede **huir**: el combate termina al final de la ronda y las caídas que quedan en el tablero mueren.

**El rescate:**
1. El Maestro cae en combate y el combate termina.
2. Si sobrevive al menos una criatura **suelta**, **viva** y con lealtad **igual o mayor al umbral de rescate**, lo arrastra al campamento. Las criaturas guardadas en pergamino no pueden rescatarlo. El umbral depende de la balanza: cuanto más Barro, más bajo.
3. **Días de recuperación** en el campamento. Durante ese tiempo, las criaturas con **poca lealtad pueden abandonarlo**.
4. Tras recuperarse, el Maestro queda **malherido** *(provisorio)*: no regenera vida ni maná, y **cada día pierde 1 punto de vida máxima**. El sanador del MVP es la **Poza Tibia**, un lugar en la orilla del Vado donde los animales lastimados se bañan en tregua (no es un NPC). Bañarse ahí le devuelve la regeneración, pero **lo perdido no vuelve: esa es la secuela**. Si nunca va, termina vagando con 1 de vida máxima.
5. Si nadie lo rescata: **permadeath**. Se pierde todo.

**Por qué así:** la secuela es un reloj visible y contable, como el hambre. Su tamaño depende de cuánto tarda el jugador en llegar a la Poza, y llegar exige cruzar dos destinos sin regenerar: la tribu tiene que sostener al Maestro débil. **Malherido no es un estado negativo** (el único del MVP sigue siendo Enfermo): es la última etapa del rescate, una marca en la barra de vida con su contador, como "lo que diste".

**En el MVP, el permadeath es absoluto:** no hay progresión entre partidas.

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
- **Todo vínculo roto quema el pergamino:** abandono, perdón a una atacante y muerte de la criatura (incluido que sea comida). La tribu lo ve arder.
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
- **Nombres:** todo en **castellano evocador**, sin lenguas inventadas (Valdelumbre, Surcón, el Molino Callado, Barro, Soplo).
- **Originalidad:** se evitan las imágenes emblemáticas de otras franquicias (por ejemplo, el círculo de transmutación). Nuestros símbolos salen de la hechura de los Nueve: la Urdimbre es un telar, no un círculo.
- **Vista:** 2D isométrica.
- **Arte:** sprites en **4 direcciones** (2 dibujadas + 2 espejadas) para contener el costo de producción. Por eso se evitan las asimetrías fuertes en los diseños, y cada criatura tiene una silueta distinta.

## 8. Lo que el juego NO es

- No es un Pokémon: no hay entrenador espectador, ni combates 1v1 clásicos, ni tipos elementales.
- No es un juego de colección: guardar criaturas sin vínculo tiene un costo, y la tribu está limitada por los pergaminos.
- No es un juego de acción en tiempo real.
- No es un mundo generado proceduralmente (el mapa es fijo; el azar vive en los eventos).
- No es un juego que castiga sin sentido: la muerte siempre es consecuencia de decisiones, y las apuestas se muestran antes de hacerlas.

## 9. Alcance del MVP (primer prototipo jugable)

Objetivo: comprobar que el núcleo es divertido antes de agregar capas.

**Alcance congelado** (01/10/2026): algo nuevo entra al MVP solo si **tapa un hueco que impide jugar** o **reemplaza algo que sale**. Todo lo demás va a Ideas en espera.

**Maestro**
- **1** clase de Maestro (con 1 rama), con la balanza inclinada hacia el **Barro** al empezar.
- Magia con maná y sus **3 atributos**: la balanza Barro ↔ Soplo, Poder mágico y Regeneración de maná.
- Progresión por nivel: 1 punto a Poder o Regeneración, más 1 paso opcional de balanza.
- 3 hechizos: Martillazo, Lanzadera y Remiendo.
- Experiencia mixta, con peso en los hitos de la tribu.
- Dieta variada del Maestro.
- Arranca con **1 compañera inicial fija**, suelta, Neutral y ocupando un pergamino.

**Criaturas**
- **5** criaturas con roles distintos (2 de trabajo, 2 de combate, 1 mixta): **4 reclutables** (Rodauva, Surcón, Ocarra, Zancajunco) y **1 aspiracional**, el **Tasajero** (rango 3), que aparece como **encuentro de combate** y se puede apaciguar, pero no domesticar ni sellar.
- **1** rasgo de combate por criatura.
- Pergaminos con **solo dos estados** por criatura: guardada o suelta.
- Cantidad inicial fija de pergaminos y **ritual de sangre** como única reposición.
- Captura por ambos caminos.
- Lealtad simple (valor numérico con cuatro estados), obediencia y **1** tipo de relación (se llevan bien / se llevan mal).
- Abandono durante la recuperación, abandono nocturno y ataque nocturno.

**Mundo**
- **1** región: **Valdelumbre**, con el campamento (el Molino Callado) y **3** destinos de riesgo creciente: los Huertos de Almiar (bajo), el Vado de los Juncos (medio) y el Robledal Hondo (alto).
- **1** mapa de nodos por destino con eventos simples, incluidos los materiales del ritual. Mapa del día de 4 columnas, con agotamiento y comida perecedera.
- La **Poza Tibia**, en el Vado, como sanador.

**Supervivencia y combate**
- Combate táctico básico en tablero pequeño, con iniciativa, Secundar, combos, afinidad, incidentes, Encono y cobardía.
- Hambre como único recurso de supervivencia, con **7 tipos de comida** y preferencias por criatura.
- **1** estado negativo: **Enfermo**, acumulable, con cura por descanso o viaje.
- Huida, caídas y guardar a una caída.
- Campamento al raso completo: guardias, fuego, emboscadas y habilidades de campamento.
- Sistema de rescate completo, con la secuela de la Poza Tibia.
- Permadeath absoluto, sin progresión entre partidas.

## 10. Roadmap de capas (tentativo)

| Capa | Contenido |
|---|---|
| 0 — MVP | Todo lo de la sección 9 |
| 1 | Crafteo y mejoras del campamento (reparar el Molino: destapar la acequia) · Estados negativos con efectos distintos (Empacho, Tripa negra, Fiebre del hongo) |
| 2 | Clima, estaciones, ciclo día/noche |
| 3 | Más clases y ramas del Maestro |
| 4 | Facciones, reinos, historia principal |
| 5 | Economía, comercio, NPCs |

`PROPUESTA`: dividir la Capa 0 en **0a** (rebanada de combate: tablero, relaciones, sellado, caída y rescate) y **0b** (loop completo).

**Ideas en espera** (aprobadas en espíritu, sin capa asignada):

- **La Mudanza** *(nombre provisorio)*. Cada criatura tiene un **defecto de naturaleza** (la Rodauva, la cobardía; la Ocarra, la impulsividad; el Zancajunco, la ariscura; el Surcón, el letargo). Superarlo gracias al vínculo con el Maestro la transforma. Condiciones de visión:
  - **La barra de zozobra** *(nombre provisorio)*: cada criatura tiene una barra que se llena por causas propias de su naturaleza. Al llenarse, la criatura llega a su límite: **se quiebra** (aparece su defecto; los quiebres repetidos pueden llevar a la **involución**) o **lo supera** (queda lista para mudar). Superar el defecto es el **disparador general** de la Mudanza.
  - **Superarlo no es azar puro:** depende de la **obediencia** y de las **afines adyacentes**, y la probabilidad se muestra antes. La regla de oro también decide quién se crece. *(Así se diferencia de la tirada de Darkest Dungeon.)*
  - La barra **persiste entre combates** y **baja en el Molino**. Guardada en su pergamino, queda congelada, igual que el resto del vínculo.
  - La barra entra **con la capa de la Mudanza**. En el MVP, la cobardía sigue funcionando como hoy.
  - **Nunca** por nivel ni por experiencia: es un momento de vínculo. Aplica a todas las criaturas. *(Única excepción acotada: el contador de combos de la Muda colectiva.)*
  - Da **forma nueva y habilidad nueva**, con una silueta distinta pero **reconocible** como la misma criatura.
  - El momento de vínculo deja a la criatura **lista para mudar**; la Mudanza la **inicia el Maestro en el Molino**, cuando decide.
  - Mudar **acelera el metabolismo**: la criatura come más mientras dura. **El riesgo de morir depende de su hambre**, no de una tirada fija: la muerte es consecuencia de la preparación.
  - El Maestro puede **cancelarla** con maná (vuelve a "lista para mudar" y se puede reintentar) o **protegerla** con mucho más maná (evita la muerte por la Mudanza, pero no garantiza que mude). La protección no cubre el hambre general.
  - Espera porque duplica el costo de arte por criatura. Se le asigna capa cuando el MVP valide el vínculo.
- **La Muda colectiva de la Rodauva** *(aprobada en espíritu)*: es la cara del defecto de la Rodauva, la cobardía. Primero, la Rodauva **supera su cobardía** al llenarse su barra de zozobra (la manada adyacente le da chances). Después, **cinco Rodauvas** que lograron **3 combos de 5 eslabones juntas** (acumulados entre combates; el contador es de esas cinco y vuelve a 0 si alguna cambia) se funden en una Rodauva más grande. Sus pergaminos quedan sellados dentro de un **pergamino de muda** *(provisorio)*. Condiciones: los pergaminos internos siguen ocupados, si muere arden todos y la Muda se inicia en el Molino, con riesgo según el hambre. Es la forma en que la Rodauva vive la regla general: su valentía le llega de la manada. La reversibilidad se decide cuando tenga capa.
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
- **El santuario de escribas:** pergaminos a cambio de monedas. Depende de la economía (Capa 5).
- **El Tasajero y la despensa:** cuando el Tasajero sea reclutable, si el Maestro cae y el Tasajero está famélico, no lo arrastra al campamento sino a su despensa; famélico, también empieza a "guardar" al más débil del grupo. **Condición de visión:** debe ser un evento del que se puede escapar, no una muerte instantánea.
- **La despensa como pasiva:** reserva de comida de emergencia que no se echa a perder.
- **El Surcón cava bajo las reservas** del campamento cuando está famélico.
- **Reencontrar a una criatura que se fue**, ya salvaje, en su hábitat.

## 11. Preguntas abiertas

- [ ] Nombre del juego y del mundo.
- [ ] Muda colectiva: ¿basta con que una Rodauva haya superado su cobardía, o tienen que superarla las cinco? ¿Es reversible? (al darle capa).
- [ ] Nombre final de la barra de zozobra (Worldbuilder).
- [ ] Número final de los Nueve (Worldbuilder).
- [ ] ¿Qué clases iniciales existen? (Capa 3).
- [ ] ¿En qué capa el Tasajero pasa a ser reclutable?
- [ ] ¿En qué capa entra la Mudanza?
- [ ] ¿En qué capa entran las órdenes? (al darle capa a la Mudanza)
- [ ] ¿El esbirro que se suelta ataca más de lo que abandona? (excepción a "irse es la norma"; al darle capa a la Mudanza).
- [ ] ¿Qué pasa si una Rodauva de la manada se quiebra? (choque entre la Muda colectiva y la involución; al darle capa a la Mudanza).
- [ ] Nombres finales de la involución, las órdenes, el Grito, la subyugación y el esbirro (Worldbuilder).
- [ ] ¿Elegir de quién es la prenda (del Maestro o de una criatura) debería tener consecuencias a futuro?
- [ ] Motor de desarrollo y plataforma objetivo (Arquitecto).
- [ ] Nombre final de "malherido" (Worldbuilder).
- [ ] ¿Se divide la Capa 0 en 0a (rebanada de combate) y 0b (loop completo)?
- [ ] ¿Hay progresión entre partidas en el juego completo? (en el MVP, no)
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
- [x] ~~¿Existen tipos o elementos de criaturas?~~ → No en el MVP; a futuro, solo linajes de hechura (6.2).
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
| 01/10/2026 | Secuela: malherido pierde 1 de vida máxima por día hasta la Poza Tibia | Reloj visible; la tribu sostiene al Maestro débil |
| 01/10/2026 | Experiencia mixta con peso en los hitos de la tribu | El Maestro crece cuando crece su tribu |
| 01/10/2026 | Permadeath absoluto y sin límite de sueltas en el MVP | Testear la regla de oro sin ruido |
| 01/10/2026 | Alcance del MVP congelado | Proteger la sección 9 |

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
