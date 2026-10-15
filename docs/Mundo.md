# MUNDO — Mundo, regiones y criaturas (v1.5)

15/10/2026 · @Joaquín

**Estado:** v1.5 · **Textos del MVP aprobados y entregados en JSON** (`juego/datos/textos/es.json`; Visión v1.0). **v1.1:** textos de los rasgos reescritos (hito 0a.1b) y de la pantalla de T13 entregados en `es.json`, con los nombres nuevos en `PROPUESTA` (1.2.1). **v1.2:** etiquetas de T14 y T16, relaciones con vecinas en 8 (Visión v1.3) y cierre de las derivaciones ya resueltas. **v1.3:** etiquetas y avisos de T19 a T21 (Encono, cobardía y maná) y textos revisados contra la escala ×10 de vida y daño (`Sistema.md` 11.1 v1.7). **v1.4:** textos de T22 a T28 (hechizos, sellar, huida, invocar, guardar a una caída y huida del Maestro) y lore de fondo de **los Legados y sus Reveses** (2.10): los Nueve son nueve oficios de dos manos. **v1.5:** cierre de la 0a del lado del Worldbuilder: las 13 claves que T25, T28 y T29 dejaron sin texto (rescatista, pantalla de resultado, caídas en la previsualización de la huida, salvaje que no huye), aprobadas por el usuario el 15/10/2026; `es.json`: 620 → 633 claves · Sincronizado con `00_Vision.md` v1.5, `Sistema.md` v1.7, `Arquitectura.md` v0.48 y el estado del código hasta T33 (`CLAUDE.md`) · **Dueño:** Worldbuilder y Diseñador Narrativo

Este documento define la identidad del mundo. Si algo acá contradice `00_Vision.md`, manda la Visión: se propone el cambio y se registra en `Decisiones.md`. Los números (rangos, apetito, efectos, costos) viven en `Sistema.md`.

**Cómo leer este documento:**

- `DECIDIDO` → aprobado por el Director Creativo.
- `PROPUESTA` → se discute, todavía no es regla.
- `PREGUNTA ABIERTA` → sin respuesta.
- `PARA [ÁREA]:` → derivación a otra área.

## 1. Convenciones del mundo — `DECIDIDO`

### 1.1 Nombres

Todo se nombra en **castellano evocador**: palabras reales o compuestas que suenen a campo, oficio y Edad Media (Valdelumbre, Surcón, Tasajero). Nada de lenguas inventadas.

- **Criaturas:** una palabra, compuesta de rasgo + oficio o forma (*Rodauva* = rueda + uva, *Zancajunco* = zanco + junco).
- **Lugares:** artículo + sustantivo + adjetivo o complemento (*El Molino Callado*, *El Vado de los Juncos*).
- **Dioses:** por un oficio de dar forma (*la Alfarera*, *la Hilandera*). Desde la v1.4, los nueve oficios están fijados (2.4).
- Evitar nombres que ya sean marca, personaje o criatura de otra franquicia.

### 1.2 Glosario de términos del juego — `DECIDIDO`

| Término | Qué nombra | Por qué este nombre |
| --- | --- | --- |
| **Barro ↔ Soplo** | La balanza del Maestro | Lo que los Nueve modelaron frente a lo que pusieron en movimiento |
| **Arrimo** | Efecto del polo Barro sobre la tribu en combate | *Arrimarse*: acercarse y apoyarse en alguien. Palabra de cuerpo y cercanía |
| **Encono** | Una criatura que se ensaña con su rival enemiga | Rencor enquistado; sangre caliente, opuesto a la cobardía |
| **Secundar** | Actuar justo después de un aliado elegido | Verbo claro para un botón. Se descartó "Ir a la zaga" porque se lee como posición, no como turno |
| **La Urdimbre** | El trazo de carbón del ritual de sangre | Urdir es preparar los hilos del telar; el pergamino es "el hilo". Reemplaza a "círculo de hechura" |
| **La prenda** | Lo que un cuerpo da sin daño para el ritual | En castellano viejo, una garantía que se deja en manos de otro. Reemplaza a "algo que el cuerpo suelta sin daño" |
| **La péñola** | Material del ritual que sale de los Huertos | Palabra antigua para la pluma de escribir. Reemplaza a "pluma" y evita confundirla con la pluma de muda |
| **Lo que diste** | Tramo de vida máxima que falta tras el ritual | No es un estado: es una marca en la barra de vida |
| **Menestral** | La clase del Maestro en el MVP | Artesano de oficios manuales, en castellano viejo. Une los tres oficios de sus hechizos (ver 2.9) |
| **Quebranto** | La secuela tras el rescate (antes "malherido") | "Quebranto de salud": un daño que no se repone. No se lee como estado negativo (ver 4.9) |
| **Las rayas** | El contador del plazo de la partida | Rayas de carbón del fuego del Molino, una por día (ver 4.10) |
| **Las golondrinas del Molino** | La señal del fin del plazo en el mundo | Se juntan en el techo a medida que pasan los días y se van el último (ver 4.10) |
| **Huyendo** | El Maestro que declaró la huida y todavía no se fue (v1.4) | Gerundio a propósito: es el único estado que todavía no pasó; la ronda sigue y puede caer antes |
| **Rescatista** | La criatura que hoy llevaría al Maestro a casa si cae (v1.5) | Ya es la palabra de las reglas (`Sistema.md` 6) y no cambia de género: sirve igual para la Rodauva y el Surcón, sin variantes |

Los términos de capas futuras (Legados, Reveses, desborde, molida, torcedura, el Yugo…) están en 2.10 y en 8.

### 1.2.1 Nombres de la v1.1 — `PROPUESTA` (PARA DIRECTOR CREATIVO)

Nombres que dejaron pendientes los rasgos reescritos tras el playtest 0a.1 (Visión 6.2 v1.1; `Sistema.md` 11.2.1 a 11.2.3). Ya están en `es.json` con la opción recomendada, para que la prueba manual de T40 no muestre `[FALTA]`. Si el Director elige otra, cambia solo el texto: las claves (`rasgo.surco.*`, `accion.cavar`, `marca.oculto`, `marca.bono`) no se tocan.

| Qué se nombra | Provisorio | Recomendado | Alternativas | Por qué |
| --- | --- | --- | --- | --- |
| Activa del Surcón | El surco | **Arar** | Abrir surco · Zanjar | Un verbo, como Erizarse y Hacerse junco: el nombre de la activa es su botón. Su hocico es una reja de arado, y un surco es lo que deja el arado. La casilla se sigue llamando **surco**, como nombre común. *Zanjar* queda como alternativa: una zanja no es un surco |
| Estado del Zancajunco oculto | Oculto | **Hecho junco** | Entre juncos · Quieto | Repite el nombre de la activa, como Erizarse → erizada: el jugador une la acción con su efecto sin leer el tooltip. *Quieto* no explica por qué no se lo puede elegir como blanco |
| Bono pendiente del Zancajunco | Bono | **Embestida** | Golpe en espera · Impulso | Así lo describe `Sistema.md` 11.2.2: moverse con el bono es una embestida. Se descarta *Al acecho*, que ya es su habilidad de campamento (4.7) |
| Modos del Tasajero | Caza · Cuenta | **Caza · Cuenta** (sin cambio) | — | Ya son las marcas de la cola (`iniciativa.caza`, `iniciativa.cuenta`). Ahora nombran modos y no turnos, y el nombre del rasgo sigue diciendo lo que pasa: primero caza, después cuenta |
| Hostilidad "Cazando" del Tasajero (4.5) | — | **Rastreando** | Cazando (sin cambio) | Choca con el modo Caza (lo marca `Sistema.md` 15): "Cazando" en el mapa sugiere que el modo de combate depende de la hostilidad, y no depende (siempre empieza cazando). *Rastreando* conserva el tooltip *"Te busca."* Es 0b: **no se cambia en `es.json` hasta que decida el Director** |

### 1.3 Tono

**Calidez con dientes** (Pilar 4). El mundo es luminoso por defecto. Lo oscuro aparece como **rastro de decisiones pasadas** o como **consecuencia de las del jugador**, nunca como decorado.

> **Comer a una criatura se elide: la tribu es la cámara** — `DECIDIDO`. El texto nunca muestra el acto: muestra a la tribu (quién mira, quién se va, quién se acerca) y la mañana siguiente. Es la forma en que se cumple "sacrificio, nunca gore" (Visión 7). Aplica al escenario G (4.6), a 4.12 y a todo texto futuro de comer criaturas. El mismo principio rige el abandono (4.13): nadie ve irse a la criatura; queda su rastro.

### 1.4 Legibilidad para arte

- Sprites en 4 direcciones (2 dibujadas + 2 espejadas): **evitar asimetrías fuertes** (marcas, cicatrices o vendas de un solo lado).
- Cada criatura del MVP tiene una **silueta distinta**: redonda, baja y ancha, cuello largo, vertical y horizontal.
- **Con el tablero de 12 × 12 y la cámara alejada** (Visión v1.3), las posturas que cambian una regla (Rodauva erizada o acobardada, Zancajunco hecho junco, Tasajero en Caza o en Cuenta) se tienen que leer por la silueta aun en chico, no por el detalle.

### 1.5 Textos como datos — `DECIDIDO`

Los textos de este documento viven como datos en **`juego/datos/textos/es.json`** (`Arquitectura.md` A.2.1 y A.4). El Worldbuilder es dueño del contenido; el Arquitecto, del esquema. Este documento sigue siendo la fuente: si un texto cambia acá, cambia en el JSON.

#### Notación

| En este documento | En el JSON | Qué es |
| --- | --- | --- |
| `[Criatura]`, `[Rival]`, `[Guardiana]`… | `{criatura}`, `{rival}`, `{guardiana}`… | Una criatura en un rol |
| `[X]%` | `{porcentaje}%` | Probabilidad que se muestra antes |
| `Día [N]` | `{dia}` | Número de día |
| `[N] rayas` | `{rayas}` | Días contados |
| `[comida]` (tipo de comida) | `{comida}` | `fruta`, `raíces`, `grano`… |
| `[comida]` (la criatura comida, 4.12) | `{ausente}` | La que ya no está |
| "1 día", "2 días" | `{duracion}` | Se arma con `tiempo.dia` / `tiempo.dias` |
| Un número de la pantalla | `{n}` | Ronda, vida de cambio de modo, daño máximo de la huida (literal) |

#### Huecos gramaticales — `DECIDIDO` (`Arquitectura.md` A.2.1, programados en T34)

Los textos piensan en "la criatura", pero las especies no comparten género (*la* Rodauva, *el* Surcón). Cada hueco de criatura tiene seis formas, que el código arma una sola vez a partir de `especie.<id>.articulo`:

| Hueco | Rodauva | Surcón |
| --- | --- | --- |
| `{criatura}` | la Rodauva | el Surcón |
| `{a_criatura}` | a la Rodauva | al Surcón |
| `{de_criatura}` | de la Rodauva | del Surcón |
| `{criatura_o}` | a | o |
| `{criatura_la}` | la | lo |
| `{criatura_ella}` | ella | él |

Valen para cualquier rol (`{a_rival}`, `{de_guardiana}`, `{testigo_o}`). Ejemplo: *"amaneció más flac{criatura_o}"*.

#### Reglas de armado

- **Mayúscula automática** al principio del texto y después de `. ? ! ¿ ¡`: *"¿{criatura}?"* da *"¿La Rodauva?"*.
- **Variantes por condición:** las claves terminadas en `.<especie>` o `.maestro` **reemplazan** a la clave base. Excepción: `caida.*`, `nocturno.base.*` y `nocturno.raso.*` son **complementos** que se muestran después de la línea base.
- **Variantes al azar** (lista): solo `noche.molino`, con 3 variantes. Los textos de varios párrafos (ritual, apertura, epílogo) son un solo texto separado con `\n\n`, nunca una lista.
- **Etiquetas de estado** (hambre, lealtad, estado de la unidad y marcas sobre la ficha): en femenino para las criaturas (*Famélica*: "la criatura") y en masculino para el Maestro, con la clave `.maestro`. **Desde la v1.1, las especies de nombre masculino concuerdan**, con variantes `.surcon`, `.zancajunco` y `.tasajero` (*Famélico*, *Caído*): la etiqueta se lee pegada al nombre, y "Surcón · Saciada" parece un error (hallazgo de T13). Los tooltips de un estado (*"Famélica: come lo que rechaza…"*) siguen en femenino: hablan de "la criatura". Programado en T40 (`Arquitectura.md` A.2.1, `DECIDIDO` 06/10/2026). **Las etiquetas de obediencia no concuerdan con la especie:** califican a la obediencia (*"Obediencia: 3 (Baja)"*), no a la criatura.
- **Desde la v1.5, las etiquetas nuevas eligen palabras sin género** cuando pueden (*Rescatista*, *Quedó atrás*, *Se levantaron*): una etiqueta que no concuerda no necesita variantes.

#### Textos nuevos de la entrega — `DECIDIDO`

Escritos para que ninguna pantalla muestre `[FALTA]`. Están en el JSON. Aprobados con los textos del MVP (Visión v1.0):

| Qué | Claves | Texto o criterio |
| --- | --- | --- |
| Etiquetas de acciones | `accion.*` | Mover · Atacar · Sellar · Invocar · Guardar · Guardar a la caída · Secundar · Huir · Esperar |
| Botones de la atacante caída | `nocturno.boton.*` | Perdonar · Sellar de nuevo · Comer (sin género) |
| Opciones de nodos sin etiqueta | `evento.*.opcion.*`, `rio.opcion.*` | Juntar una péñola · Juntar agua del charco · Juntar una ramita caída · Bañarte en la Poza · Leer el río · Cruzar · Esperar un día · Llevarte el grano que sirve · Revisar a fondo · Dejarle fruta · Espantarla |
| Espantar a la Rodauva | `evento.manzano.espantar` | *"Das un paso fuerte. La Rodauva se hace bola y rueda hasta las zarzas. Las manzanas quedan."* |
| Emboscada con el Maestro de guardia | `emboscada.<destino>.alarma.maestro` | Huertos: *"En tu guardia, algo cruza la hierba a los graznidos. Despertás a los tuyos a tiempo."* · Vado: *"Ves moverse el juncal donde no hay viento. Despertás a los tuyos antes de que el primer junco dé un paso."* · Robledal: *"Te quedás mirando las ramas de arriba. Algo los estaba contando mientras los tuyos dormían."* |
| Noche y alba con el Maestro de guardia | `noche.raso.tranquila.maestro`, `noche.alba.maestro` | *"La noche pasa. Hacés tu guardia mirando las brasas, y nada más."* · *"Amanece sin novedad. Lo viste clarear desde tu guardia."* |
| Combos con el Maestro | `combo.eslabon.sigue_al_maestro`, `combo.eslabon.maestro_sigue` (y `.afin`) | *"[Criatura] sigue tu golpe."* · *"Seguís el golpe de [aliado]."* · *"[Criatura] y vos ya se conocen el golpe."* · *"Vos y [aliado] ya se conocen el golpe."* |
| Lanzadera contra el Maestro | `lanzadera.choque.contra_maestro` | *"[Unidad] sale despedida y se te viene encima."* |
| Reacciones de Encono | `encono.<especie>.<rival>` | Las reacciones de la sección 5 pasan a línea de registro, con los mismos gestos |
| Centinela | `nocturno.centinela` | *"La otra Ocarra grazna una vez, fuerte. Te alcanza para rodar a un costado."* (las criaturas no tienen nombre propio; ver 4.6) |

#### Textos de la pantalla de combate (T13) — `PROPUESTA`

Claves que dejó T13 sin texto (`RESUMENES.md`). Son etiquetas de interfaz: cortas, sin prosa, para que lo que se lea sea el estado y no la palabra.

| Qué | Claves | Texto |
| --- | --- | --- |
| Nombre del Maestro (ficha, cola y panel) | `maestro.nombre` | Maestro |
| Ronda | `combate.ronda` | Ronda {n} |
| Título de la cola | `iniciativa.titulo` | Orden de la ronda |
| Panel de la unidad del turno | `panel.vida` · `panel.lealtad` · `panel.hambre` | Vida · Lealtad · Hambre |
| Botón con la acción ya usada | `accion.terminar` | Terminar turno |
| Marcas sobre la ficha | `marca.caida` · `marca.erizada` · `marca.fuera` | Caída (*Caído* en el Surcón y el Zancajunco) · Erizada · Se fue |
| Desglose del daño | `desglose.base` · `desglose.total` · `desglose.minimo` | Base · Total · Golpe mínimo |
| Fuentes del desglose | `desglose.fuente.combo` · `.afinidad` · `.encono` · `.cobardia` | Cadena · Afinidad · Encono · Cobardía |
| Pantalla de resultado | `resultado.titulo` · `.rondas` · `.lealtad` · `.volver` | Fin del combate · Rondas · Lealtad · Volver |
| Desenlace | `resultado.desenlace.victoria` · `.derrota_por_caida` | Victoria · Caíste |
| Estado de la unidad | `estado.suelta` · `.guardada` · `.caida` · `.fuera` · `.muerta` | Suelta · Guardada · Caída · Se fue · Muerta (en masculino para el Surcón, el Zancajunco y el Tasajero; `estado.caida.maestro`: Caído) |
| Motivos de lealtad | `lealtad.motivo.<evento>` | `victoria`: *Pelearon juntos y ganaron* · `muerte_en_el_grupo`: *Murió alguien de la tribu* · `muerte_en_el_grupo_afines`: *Murió alguien con quien se llevaba bien* · `rescate`: *Te llevó a casa* · `perdon_a_leales`: *Perdonaste a quien te atacó* · `comer_atacante`: *Te comiste a quien te atacó* |
| Hambre y lealtad en masculino | `hambre.estado.<estado>.<especie>` · `lealtad.estado.dudosa.<especie>` | Saciado · Hambriento · Famélico · Dudoso (Surcón y Zancajunco; el Tasajero solo en el hambre) |

> **Cadena** y no *combo*: castellano evocador (1.1), y es la palabra de sus eslabones (`combo.eslabon`). La clave sigue diciendo `combo`: las claves no se leen.
> **"Se fue"** sirve para la salvaje que dejó el tablero: huida o sellada. Sin culpa y sin juicio, como su línea de huida.

#### Textos de la pantalla de la 0a.2 (T14, T16) — `PROPUESTA` (v1.2)

Claves que dejaron T14 y T16 sin texto (`RESUMENES.md`). Mismo criterio que T13: etiquetas cortas.

| Qué | Claves | Texto |
| --- | --- | --- |
| Etiqueta del panel y del tooltip | `panel.obediencia` | Obediencia |
| Tramo de obediencia | `obediencia.tramo.baja` · `.neutral` · `.leal` | Baja · Neutral · Leal |
| Cadena en curso (panel del turno) | `panel.cadena` | Cadena |

> **Baja · Neutral · Leal:** son las palabras de las reglas (`Sistema.md` 5.4) y de los tooltips de relaciones; el panel ya muestra el estado de lealtad al lado, y dos vocabularios para lo mismo confunden. *Alternativas descartadas:* Díscola · Mansa · Fiel (más evocadoras, pero obligan a aprender otra escala).
> **Cadena** repite la fuente del desglose (`desglose.fuente.combo`): el jugador ve la misma palabra en el panel y en el número.

#### Tooltips de relaciones (vecinas en 8) — `PROPUESTA` (v1.2)

`Sistema.md` 15 (v1.6) pide que todo texto de afinidad, incidente o cobardía deje claro que **cuentan las diagonales**, y que el del incidente aclare que la rival en diagonal no recibe el golpe. Los necesitan las previsualizaciones obligatorias de T18 y T19. Claves confirmadas por el Arquitecto (`Arquitectura.md` 10.5, 07/10/2026).

| Qué | Clave | Texto |
| --- | --- | --- |
| Afinidad (casilla o unidad) | `afinidad.tooltip` | *"Con una afín al lado o en diagonal, pega un poco más fuerte."* |
| Incidente (casilla destino) | `incidente.tooltip` | *"[X]% de incidente: queda al lado o en diagonal de su rival. Si te obedece, se distrae. Si no, le pega, pero solo si la alcanza sin moverse."* |
| Cobardía | `cobardia.tooltip` | *"[X]% de que se acobarde. La sostienen vos y sus afines, al lado o en diagonal."* |
| Encono | `encono.tooltip` | *"[X]% de que se encone: tiene a su rival a tiro. Enconada, solo ve a esa."* |

> Sin números de reglas: el porcentaje es lo que se muestra antes, no la regla. *"Al lado o en diagonal"* es la forma más corta de decir "las 8 vecinas" sin la palabra técnica.
> Las líneas de Hacerse junco (*"se le planta al lado"*, `aviso.destapar`) **no cambian**: su contacto sigue siendo ortogonal (`Sistema.md` 11.2.2 v1.6), y "al lado" dice justo eso.

#### Textos de la pantalla de T19 a T21 — `DECIDIDO` (v1.3, aprobados por el usuario el 08/10/2026)

Claves que dejaron T19 a T21 sin texto (`RESUMENES.md`; `Sistema.md` 15 v1.7). Mismo criterio que T13: etiquetas cortas y avisos que se entienden sin abrir el tooltip.

| Qué | Claves | Texto |
| --- | --- | --- |
| Marca de la enconada (ficha y tooltip) | `marca.enconada` · `.zancajunco` · `.tasajero` | Enconada · *Enconado* (Zancajunco y Tasajero) |
| Marca de la acobardada (ficha y tooltip) | `marca.acobardada` · `.surcon` | Acobardada · *Acobardado* (Surcón) |
| Contador del Encono | `panel.encono` | Encono (se ve como "Encono: 2/3") |
| Maná del Maestro (panel y tooltip) | `panel.mana` | Maná (se ve como "Maná: 8/8") |
| No puede terminar: debe golpear a su rival | `aviso.terminar.debe_atacar_rival` | *"Primero tiene que pegarle a su rival. Este turno no se le despega."* |
| No puede terminar: debe acercarse | `aviso.terminar.debe_acercarse` | *"No llega a su rival, pero tiene que acercarse todo lo que pueda antes de terminar."* |

> **Concordancia:** las marcas siguen la regla de 1.5 (variante por especie de nombre masculino). Solo llevan variante las especies que pueden quedar en ese estado: se enconan las de combate y mixtas (Ocarra, Zancajunco, Tasajero); se acobardan las de trabajo (Rodauva, Surcón).
> **Los avisos van sin género:** la rival puede ser el Zancajunco o el Tasajero. *"No se le despega"* cubre P-038 en la opción A (`Sistema.md` 10.5 v1.7): la enconada no se aleja de su rival en todo el turno, también después del primer golpe.
> **Maná** con tilde: es palabra del juego (2.2) y la pantalla la lee pegada al número.

#### Textos y escala ×10 — `DECIDIDO` (v1.3)

`Sistema.md` 11.1 v1.7 multiplica por 10 la vida y el daño. Se revisaron `es.json` y este documento: los textos de reglas ya no citan vida ni daño desde la v1.1, salvo uno.

| Clave | Antes | Ahora |
| --- | --- | --- |
| `guardar_caida.tooltip` | *"Guardada con 1 de vida. No se cura hasta que salga."* | *"Guardada con lo justo para respirar. No se cura hasta que salga."* |

> **Regla desde la v1.3:** ningún texto escribe un número de vida, daño o curación. Si la pantalla tiene que mostrar uno, va por hueco (`{n}`, `{vida}`, `{porcentaje}`) y lo llena desde los datos, como `aviso.cuenta.umbral` y `rio.crecido.tooltip`. Así un cambio de balance nunca deja un texto mintiendo. Los números de distancia, días o cantidades de lore (*"dos casillas"*, *"Tres días de [tipo]"*, *"tres gotas"*, *"cuarenta y una rayas"*) no son de balance y se quedan.

#### Textos de la pantalla de T22 a T28 — `DECIDIDO` (v1.4, aprobados por el usuario el 13/10/2026)

Claves que dejaron T22 a T28 sin texto (`Arquitectura.md` A.10 v0.48). `es.json`: 586 → 620 claves.

**Criterio:**
- Los avisos de botón deshabilitado dicen **qué falta** y, cuando aplica, qué todavía se puede hacer. Sin números de balance: el daño de la huida va por `{n}`.
- Los avisos de sellar y de guardar a una caída hablan del **hilo**, como `sellar.*`: el sellado es el hilo del pergamino (2.5), no un rayo.
- **Invocar y huir** repiten *"lleva el turno entero"*: es la misma regla (S-53) y se aprende una vez.
- `accion_usada` es el mismo texto en hechizo, sellar y guardar a una caída. Si el Arquitecto prefiere una sola clave compartida, cambia la clave, no el texto.

| Qué | Clave | Texto |
| --- | --- | --- |
| Hechizo sin maná (T22) | `aviso.hechizo.mana_insuficiente` | *"No te alcanza el maná para este hechizo."* |
| Hechizo con la acción usada | `aviso.hechizo.accion_usada` | *"Ya usaste tu acción este turno."* |
| Hechizo sin objetivos | `aviso.hechizo.sin_objetivos` | *"No hay nadie a tu alcance para este hechizo."* |
| Sentidos de la Lanzadera (clic izquierdo y derecho) | `hechizo.sentido.empujar` · `.atraer` | Empujar · Atraer |
| Choque contra el borde o un surco (P-042) | `lanzadera.choque.obstaculo` | *"[Unidad] sale despedid[a/o], no tiene adónde ir y se da de lleno."* |
| Sellar con la acción usada (T24) | `aviso.sellar.accion_usada` | *"Ya usaste tu acción este turno."* |
| Sellar sin maná | `aviso.sellar.mana_insuficiente` | *"No te alcanza el maná para tender el hilo."* |
| Salvaje fuera de alcance | `aviso.sellar.fuera_de_alcance` | *"Está demasiado lejos: el hilo no llega."* |
| No sellable (el Tasajero) | `aviso.sellar.no_sellable` | *"Hay cosas que el hilo no sujeta. Esta es una."* |
| Oculta | `aviso.sellar.oculta` | *"No la distinguís: el hilo no sabe a quién buscar."* |
| No salvaje | `aviso.sellar.no_salvaje` | *"El hilo solo busca a las salvajes."* |
| Sin salvajes al alcance | `aviso.sellar.sin_objetivos` | *"No hay ninguna salvaje al alcance del hilo."* |
| Marca de huida sobre la salvaje (T25) | `marca.huida` | Huida |
| Tooltip de la marca | `huida.salvaje.porcentaje` | *"[X]% de que huya al empezar su turno. Si se va, ya no se puede sellar."* |
| Invocar después de moverse (T26) | `aviso.invocar.ya_se_movio` | *"Invocar lleva el turno entero, y ya te moviste."* |
| Invocar con la acción usada | `aviso.invocar.accion_usada` | *"Invocar lleva el turno entero, y ya usaste tu acción."* |
| Invocar sin maná | `aviso.invocar.mana_insuficiente` | *"No te alcanza el maná para desenrollar este pergamino."* |
| Invocar sin casilla libre | `aviso.invocar.sin_casilla_libre` | *"No hay lugar libre a tu lado para que salga."* |
| Guardar a una caída con la acción usada (T27) | `aviso.guardar_caida.accion_usada` | *"Ya usaste tu acción este turno."* |
| Caída fuera de alcance | `aviso.guardar_caida.fuera_de_alcance` | *"Está demasiado lejos: el hilo no llega."* |
| Guardar a una caída sin maná | `aviso.guardar_caida.mana_insuficiente` | *"No te alcanza el maná para recogerla."* |
| Sin caídas al alcance | `aviso.guardar_caida.sin_objetivos` | *"No hay nadie caído al alcance del hilo."* |
| Desenlace de la huida (T28) | `resultado.desenlace.huida` | Huiste |
| Marca del Maestro que declaró la huida | `marca.huida_declarada` | Huyendo |
| Panel del turno del Maestro | `panel.huida_declarada` | *"Te vas al cerrar la ronda."* |
| Huir después de moverse | `aviso.huir.ya_se_movio` | *"Huir lleva el turno entero, y ya te moviste."* |
| Huir con la acción usada | `aviso.huir.accion_usada` | *"Huir lleva el turno entero, y ya usaste tu acción."* |
| Previsualización: título | `huida.previa.titulo` | Si huís ahora |
| Lista de las que actúan antes del cierre | `huida.previa.actuan` | *"Antes de que salgas del claro, todavía actúan:"* |
| Nadie actúa antes del cierre | `huida.previa.ninguna` | *"Nadie más actúa antes de que salgas del claro."* |
| Alguna alcanza al Maestro (`{n}` = daño máximo) | `huida.previa.alcanzan` | *"Te pueden alcanzar. En el peor caso, [n] de daño."* |
| Actúan, pero ninguna llega | `huida.previa.no_alcanzan` | *"Ninguna te alcanza antes de que te vayas."* |
| El daño máximo tumba al Maestro | `huida.previa.caes` | *"Con eso, caés antes de irte."* |

> **Claves confirmadas (v1.5):** T30 adoptó los nombres de `huida.previa.*` y `aviso.huir.*` de esta tabla y retiró los provisorios de T28 (`CLAUDE.md`, estado de T30). Quedó una sola sin texto, `huida.previa.caidas`, que se agrega en la tabla siguiente.
> **"Huyendo"** es el único participio que no es participio: dice que la huida todavía no se cumplió (11.7: el Maestro puede caer antes del cierre). Sin concordancia: solo el Maestro huye.
> **`lanzadera.choque.obstaculo`** no nombra contra qué choca: con P-042, `contra` es `null` en el borde y en un surco.
> **`huida.salvaje.tooltip`** (*"Se fue. Ya no se puede sellar."*) existe y T25 no lo usa. Se propone usarlo como tooltip del suceso de una huida ya ocurrida, junto a `huida.salvaje.<especie>` (PARA ARQUITECTO).

#### Textos de la pantalla de T25, T28 y T29 — `DECIDIDO` (v1.5, aprobados por el usuario el 15/10/2026)

Claves que dejaron T25, T28 y T29 sin texto (`CLAUDE.md`, estado de T25, T29 y T30). Con esto, ninguna pantalla de la 0a muestra `[FALTA]`. `es.json`: 620 → 633 claves.

**Criterio:**
- El rescate se nombra con lo que **hace**, no con un cargo: *"te lleva a casa"* es la frase de la regla de oro (Visión 6.6) y la del motivo de lealtad (`lealtad.motivo.rescate`). La marca sobre la ficha es la excepción, porque tiene que caber: *Rescatista*, que no cambia de género.
- La pantalla de resultado lee lo que pasó con la tribu **sin culpa**: las muertas *"no volvieron"* y su causa dice dónde quedaron, no quién falló. Es el criterio de "quedar atrás es sobrio" (sección 5).
- Ninguna etiqueta lleva género: sirven igual para la Rodauva y el Surcón sin variantes (1.5).

| Qué | Clave | Texto | Se lee como |
| --- | --- | --- | --- |
| Rescatista en el panel del turno (T29) | `panel.rescatista` | Te lleva a casa | "Te lleva a casa: Rodauva" |
| Sin rescatista en el panel | `panel.sin_rescatista` | *"Si caés ahora, nadie te lleva a casa."* | Línea completa |
| Marca sobre la ficha de la rescatista | `marca.rescatista` | Rescatista | Sobre la ficha |
| Rescatista en la pantalla de resultado | `resultado.rescatista` | Te llevó a casa | "Te llevó a casa: Surcón", seguido de `rescate.<especie>` |
| Muertas en el resultado | `resultado.muertas` | No volvieron | Título de la lista |
| Causa: el Maestro cayó | `resultado.causa.derrota_por_caida` | Quedó atrás cuando caíste | "Ocarra · Quedó atrás cuando caíste" |
| Causa: el Maestro huyó | `resultado.causa.huida` | Quedó atrás en la huida | "Rodauva · Quedó atrás en la huida" |
| Caídas levantadas | `resultado.levantadas` | Se levantaron | Título de la lista |
| Caídas guardadas a tiempo | `resultado.caidas_guardadas` | Guardadas a tiempo | Título de la lista |
| Salvajes selladas | `resultado.capturas` | Se sumaron a la tribu | Título de la lista |
| Atacante nocturna esperando su destino | `resultado.atacante_pendiente` | Queda por decidir | "Queda por decidir: Ocarra", antes de los botones de 4.6 |
| Previsualización de la huida: caídas que mueren (T28) | `huida.previa.caidas` | *"Si te vas, quedan atrás:"* | Título de la lista, como `huida.previa.actuan` |
| Salvaje que tira para huir y se queda (T25, opcional) | `huida.salvaje.se_queda` | *"[Criatura] mira hacia el borde del claro, pero se queda."* | Línea de sucesos |

> **"Te lleva a casa"** retoma la promesa del día 1 (*"Si la cuidás, te va a salvar"*, 4.8): el panel le recuerda al jugador, turno a turno, quién cumple hoy esa promesa. Elegida por el usuario. *Descartadas:* Rescatista (más técnica; queda solo como marca sobre la ficha) · Si caés, te lleva a casa (más larga).
> **"No volvieron"** y no *Muertas*: el estado de la unidad ya dice *Muerta* al lado del nombre; el título no lo repite. *Descartada:* Quedaron atrás.
> **"Se sumaron a la tribu"** y no *Capturas*: en Valdelumbre nadie captura; el hilo recoge (2.5). *Descartada:* Selladas.
> **`huida.salvaje.se_queda`** es opcional: T25 la muestra solo si existe. Da sentido al porcentaje de la marca de huida: el jugador ve que la tirada pasó y que esa salvaje sigue a tiro del hilo.
> **PARA ARQUITECTO:** confirmar que `panel.rescatista`, `resultado.rescatista`, `resultado.atacante_pendiente` y los títulos de lista se arman como "etiqueta: nombre" (como `panel.encono`) y no como frase con hueco. Si alguna lleva hueco, cambia el texto, no la clave.

## 2. La magia y los Nueve

La magia es el resto de la hechura del mundo: tocarla vuelve al Maestro más etéreo y lo aleja de lo tangible, de su cuerpo y de su tribu.

### 2.1 Los Nueve — `DECIDIDO`

- La magia proviene de **los Nueve**, los dioses que **le dieron forma** al mundo. **Son nueve** (v1.4): nueve oficios, de dos manos cada uno (2.4).
- No lo crearon de la nada: lo **hicieron**, como se hace una vasija o un tejido. Al terminar, quedó en el aire un resto de esa hechura. Eso es la magia.
- **Qué pasa hoy con los Nueve: nadie lo sabe.** Es un misterio deliberado. Ningún texto del juego lo afirma; los personajes y los rastros solo suponen.

> **Criterio narrativo:** el misterio se sostiene con rastros (un altar sin dueño, una talla gastada), nunca con respuestas. Ningún evento del MVP revela el destino de los Nueve. Los rastros nunca aparecen en un códice ni se explican (ver 2.7). El mundo conoce los **oficios** de los Nueve por las marcas que dejaron en lo que hicieron, no sus nombres propios.

### 2.2 Lo etéreo — `DECIDIDO`

Quien toca la magia empieza a parecerse un poco a los Nueve: sabe dar forma a las cosas, pero deja de estar del todo entre ellas. Su cuerpo pesa menos, su mano pega más flojo y las criaturas, que viven de comer, dormir y estar cerca, lo sienten lejos.

| Regla de sistema | Cómo la explica el lore |
| --- | --- |
| El polo Soplo baja la vida y el daño físico | El cuerpo se vuelve liviano, menos de este mundo |
| El polo Soplo enfría los vínculos | Las criaturas se arriman a lo que pueden oler y tocar; el mago se les vuelve borroso |
| El polo Barro da vida, daño y Arrimo | Arraigado en lo tangible: cuerpo sólido, presencia que se siente |
| Dormir recupera el maná | En el sueño, el alma se acerca a lo que queda de los Nueve y vuelve cargada |
| Tope de maná en combate | Lo que trajiste del sueño es todo lo que tenés |
| El hambre reduce el maná; famélico, se corta | La magia aleja del cuerpo, pero necesita un cuerpo que la sostenga. Con hambre, el ancla se afloja y la magia se escurre |
| El ritual de sangre funciona en cualquier punto de la balanza | El ritual no pide magia: pide cuerpo (ver 2.6) |

> **Centro dramático del Maestro:** vive tironeado entre lo etéreo y lo tangible.

### 2.3 La balanza: Barro ↔ Soplo — `DECIDIDO`

| Polo | Reemplaza a | Lectura |
| --- | --- | --- |
| **Barro** (posición 1) | Carisma | Lo que los Nueve modelaron: cuerpo, tierra, tribu |
| **Soplo** (posición 5) | Aptitud mágica | Lo que los Nueve pusieron en movimiento: magia, distancia |

Los valores viven en la tabla 1.2 de `Sistema.md`.

### 2.4 Los Nueve: nueve oficios de dos manos — `DECIDIDO` (v1.4)

> **Cada uno de los Nueve trabajaba con dos manos. Lo que hizo con la mano que da es un legado; lo que hizo con la otra, su revés.**

- Cada dios se nombra por un **oficio de dar forma**. Todo oficio tiene un gesto que da y otro que quita, sostiene o calla, y los dos hacen falta para que la cosa quede hecha: la Alfarera **llena** la vasija, pero lo que la hace vasija es el **hueco**.
- Son **dieciocho** legados (Visión 10): nueve oficios, dos manos cada uno.
- **Nadie hizo los reveses aparte**: los hicieron los mismos Nueve, con la otra mano. **Un revés no es el mal** ni una versión oscura: es la otra cara del oficio, como el revés de una tela. Una criatura de Drenaje no es mala, como la hoz no es mala.
- **El legado es lo que el hacedor dejó de sí en lo que hizo.** Es la ley del ritual: *"Nadie hace nada sin dejar algo de sí"* (2.6). El Maestro deja su sangre en el pergamino; los Nueve dejaron sus manos en las criaturas.
- Los **linajes de hechura** de la v0.3 quedan reemplazados por **los Legados y sus Reveses** (Visión 10). No existen en el MVP (`DECIDIDO`) y nunca serán elementos como fuego, agua o planta.
- El detalle (los nueve oficios, los cuatro ciclos, los nombres del sistema) está en 2.10. Es **material de fondo**: no se necesita para la 0a ni la 0b.

### 2.5 Los pergaminos — `DECIDIDO`

- El pergamino es **el hilo entre el Maestro y la criatura**. Cada criatura de la tribu, suelta o guardada, ocupa uno.
- **No está hecho de piel.** La hoja se cuaja en el agua del cuenco durante el ritual (ver 2.6). Ningún texto ni arte debe sugerir que sale de una criatura.
- **Dentro del pergamino** la criatura queda un paso fuera de lo tangible. No tiene hambre, ni clima, ni tiempo, ni compañía: duerme sin soñar y, al salir, cree que es el mismo día en que entró. Por eso no gana ni pierde lealtad.
- **Todo vínculo roto quema el pergamino:** abandono, perdón a la atacante y muerte de la criatura (incluido que sea comida). Arde con una llama pálida que no calienta y deja solo ceniza.
- Cuando la criatura se va, **vuelve a ser salvaje**.
- **Origen:** el Maestro arranca con una cantidad fija (ver `Sistema.md`). La única forma de obtener pergaminos nuevos en el MVP es el **ritual de sangre**.

> Imagen para el Pilar 4: cuando una criatura muere, la tribu ve arder su pergamino.

### 2.6 El ritual de sangre — `DECIDIDO`

Es un evento fijo del Molino Callado con requisitos, no un sistema de crafteo. El costo en vida y las restricciones viven en `Sistema.md` (sección 3).

#### Qué es en el lore

El ritual es el Maestro haciendo en chiquito lo que hicieron los Nueve: **dar forma y dejar algo de sí en lo que hizo**. Cada material es algo que el mundo ya soltó, y una sola cosa se toma por la fuerza.

> **Regla del lore: nada del ritual se arranca; todo se recoge.** La péñola se junta del suelo, la ramita es caída, el agua se quedó quieta sola, la prenda se da. **El único que paga con daño es el Maestro.** Por eso sirve su sangre y no la de otro: *nadie hace nada sin dejar algo de sí*, y el hilo tiene que quedar atado a quien lo hizo.

| Material | Qué es en el lore | Qué aporta al pergamino | De dónde sale |
| --- | --- | --- | --- |
| **Péñola** | Algo que voló | Con ella se traza el hilo | El palomar (Huertos de Almiar) |
| **Agua de charco** | Agua que dejó de correr | La quietud: por eso la criatura duerme fuera del tiempo | El charco quieto (Vado de los Juncos) |
| **Ramita de roble** | Algo que creció despacio | El eje donde la hoja se enrolla | El Roble Viejo (Robledal Hondo) |
| **Cuenco** (permanente) | Algo hecho por manos | Donde todo se junta | La hornacina (ruinas de Almiar) |
| **Carbón** | Lo que el fuego terminó | El trazo de la Urdimbre | El fuego del Molino |
| **Prenda** | Algo que un cuerpo dejó ir sin daño | La tribu pone algo de sí: el hilo es de todos | El Maestro o cualquier criatura suelta |
| **Sangre del Maestro** | Lo único que el cuerpo no quiere dar | El nudo: el hilo queda atado a él | Su cuerpo |

> La Ocarra no vuela: su pluma sirve de **prenda**, nunca de **péñola**.

#### La Urdimbre

No es un círculo con símbolos. Son **líneas de carbón paralelas, como un telar dibujado en el piso**, que rodean al cuenco y terminan en **un único hilo suelto**. Sin runas, sin geometría alquímica, simétrica para el espejado.

#### Texto del ritual

> *Con el carbón del fuego trazás la Urdimbre en el piso del Molino: hilo junto a hilo, alrededor del cuenco. Agua quieta adentro. La ramita, de borde a borde. La prenda, en el centro.*
> *Abrís la palma sobre el agua. Tres gotas. El agua deja de moverse del todo, como si se hubiera olvidado de ser agua.*
> *Cuando la péñola toca la superficie, la hoja ya está ahí: blanca, tibia, enrollándose sola sobre la ramita.*
> *Te tiembla el pulso. Nadie hace nada sin dejar algo de sí.*

#### Línea según quién da la prenda

Sin diferencia mecánica en el MVP: la prenda no tiene consecuencias (Visión 6.7 y 11 v1.2). El epílogo que nombra quién dio cada prenda queda en Ideas en espera (8).

| Prenda de | Qué da | Línea |
| --- | --- | --- |
| Maestro | Un mechón | *"Un mechón tuyo. Lo único del ritual que no duele."* |
| Rodauva | Una púa | *"Se sacude y deja caer una púa. Después se queda mirando el cuenco, como si fuera fruta."* |
| Surcón | Pelo | *"Se rasca contra el marco de la puerta hasta que queda un puñado de pelo color tierra."* |
| Ocarra | Una pluma de muda | *"Suelta una pluma de muda a tus pies y grazna como si te estuviera haciendo un favor."* |
| Zancajunco | Una hoja de junco | *"Se queda quieto hasta que una hoja de junco se le desprende del lomo. No te la da: la deja caer."* |

#### Lo que diste

La debilidad posterior al ritual **no es un estado negativo** (el único del MVP sigue siendo Enfermo). En la barra de vida, el tramo de vida máxima que falta se muestra como **"lo que diste"**, con su contador de días.

| Momento | Texto de la mañana |
| --- | --- |
| Día 1 | *"El cuerpo te recuerda lo que diste anoche."* |
| Día 2 | *"La palma ya cerró. El cansancio, todavía no."* |
| Día 3 | *"Casi no lo sentís. Casi."* |
| Rituales acumulados | *"Diste otra vez antes de reponerte. El cuerpo lleva la cuenta."* |
| Variante cálida (criatura suelta y leal; solo texto) | *"[Criatura] camina más cerca tuyo que de costumbre."* |

### 2.7 Rastros de los Nueve en Valdelumbre — `DECIDIDO`

Cada nodo de material del ritual lleva un rastro. Juntar materiales es también recorrer el misterio, sin que nada lo explique.

| Lugar | Rastro | Qué no se dice nunca |
| --- | --- | --- |
| La hornacina (Huertos) | Un hueco hecho para guardar una sola cosa; un cuenco con ceniza vieja y una mancha oscura | Si alguien en Almiar ya hizo el ritual |
| El charco quieto (Vado) | Piedras lisas en ronda que ninguna corriente ordenó | Quién las puso |
| El Roble Viejo (Robledal) | Una talla gastada: una figura con las manos juntas, sosteniendo algo que ya no está | Quién es la figura ni qué sostenía |

> **La mancha del cuenco es ambigua para siempre.** Sugiere que alguien en Almiar hizo el ritual antes del Invierno Flaco, pero ningún texto, en ninguna capa, lo confirma ni lo niega. Es un rastro, no una pista.
>
> **Desde la v1.4**, cada rastro se puede leer como la mano de un oficio (2.10: la Alfarera en el cuenco, el Vidriero en el charco, el Tallista en el Roble Viejo, el Molinero en el Molino Callado). **Esa lectura nunca se escribe en el juego:** la hace el jugador o nadie.

### 2.8 Los hechizos del Maestro — `DECIDIDO`

Nombres y hechizos aprobados (Visión 6.7; reglas en `Sistema.md` 1.6). Cada uno evoca un **oficio de dar forma** distinto: insinúa que los Nueve eran varios sin nombrar a ninguno (2.4).

| Funcional | Nombre final | Oficio | Tooltip |
| --- | --- | --- | --- |
| Golpe | **Martillazo** | Herrería | *"Lo que los Nueve modelaron también se abolla."* |
| Desplazar | **Lanzadera** | Telar | *"Va y vuelve, como la lanzadera en el telar."* (empuja o atrae) |
| Sanar | **Remiendo** | Costura | *"Un remiendo cierra lo abierto. No levanta lo caído."* |

> El tooltip del Remiendo explica en el lore por qué no afecta a las caídas (`Sistema.md` 11.5).
> Los hechizos **insinúan** oficios, no los asignan: el Martillazo no es "de Presión" ni la Lanzadera "de Unión". No se tocan con la v1.4.

### 2.9 La clase del MVP: el Menestral — `DECIDIDO`

El Maestro del MVP es un **Menestral**: alguien que hace magia como quien trabaja un oficio, con las manos. Sus tres hechizos salen de tres oficios distintos (herrería, telar, costura), y eso insinúa que los Nueve eran varios sin nombrar a ninguno (2.4). La balanza arranca inclinada al **Barro** (Visión 6.1).

- El nombre dice **qué hace** el Maestro, no **de dónde viene**: el pasado sigue sin explicarse en el MVP (4.8).
- Deja lugar a clases futuras nombradas por otros oficios (Capa 3).

#### Subida de nivel

| Momento | Texto |
| --- | --- |
| Subida | *"Algo se te acomoda por dentro. Esta noche sabés un poco más del oficio."* |
| Paso hacia el Barro | *"Te pesan las manos, como a quien trabajó la tierra todo el día. Las tuyas se te arriman."* |
| Paso hacia el Soplo | *"Por un momento, el fuego te calienta menos que antes."* |
| Aviso de rescatista perdida (antes de confirmar) | *"Si das este paso, [Criatura] ya no te va a poder llevar a casa."* |

### 2.10 Los Legados y sus Reveses — `DECIDIDO` (v1.4; material de fondo, capa futura)

Lore del sistema de la Visión 10. No toca la 0a ni la 0b. Responde las preguntas de Worldbuilder de la Visión 11 sin cambiar ninguna regla.

> **Revés en lugar de Sombra** (aprobado por el usuario, 13/10/2026; **PARA DIRECTOR CREATIVO**: renombrar en la Visión 6.1, 6.2, 8, 10 y 11). "Sombra" se leía como "lo malo", y la Visión prohíbe la estética de versión oscura. **Revés** sale del telar, como la Urdimbre, y dice "la otra cara" sin juicio.

#### Los nueve oficios

Columna "Rastro posible": dónde podría asomar, **sin explicarse nunca** (2.1 y 2.7).

| # | Oficio | Legado (la mano que da) | Revés (la otra mano) | La imagen | Rastro posible |
| --- | --- | --- | --- | --- | --- |
| 1 | **la Alfarera** | Lleno | Vacío | La vasija: el barro lleno y el hueco que guarda | El cuenco de la hornacina |
| 2 | **la Sembradora** | Crecimiento | Drenaje | Siembra y siega: la misma mano que hace crecer cosecha | Surcos viejos en los Huertos |
| 3 | **el Molinero** | Movimiento | Quietud | La **piedra volandera** gira; la **solera** no se mueve y sostiene a la otra | El Molino Callado: hecho para moverse, hoy quieto |
| 4 | **el Herrero** | Liviandad | Presión | El fuelle (lo que se escapa) y el martillo sobre el yunque (lo que aplasta) | Insinuado por el Martillazo |
| 5 | **el Alarife** (maestro de obras) | Intemperie | Protección | El patio abierto y el muro | Ruinas de Almiar: paredes de pie, techos caídos |
| 6 | **la Campanera** | Sonido | Silencio | La campana que suena y la que se queda quieta en la torre | Una región futura con un campanario sin badajo |
| 7 | **el Vidriero** | Sinceridad | Ilusión | El vidrio que deja ver y el espejo que devuelve otra cosa | El charco quieto, que refleja más de lo que hay |
| 8 | **la Hilandera** | Unión | Desapego | El huso que une y la tijera que corta | El pergamino es "el hilo": la magia del Maestro es la más cercana a este oficio |
| 9 | **el Tallista** | Disciplina | Inspiración | El golpe de gubia repetido y la veta que decide sola | La talla gastada del Roble Viejo |

> **Originalidad:** la Hilandera con huso y tijera recuerda de lejos a un motivo de folclore general (las hilanderas del destino). No es de ninguna franquicia, y se aleja así: **nuestra tijera corta lazos, no vidas**, y nadie mide la vida de nadie.

#### Nombres del sistema

| Qué | Nombre | Por qué |
| --- | --- | --- |
| El sistema | **Los Legados y sus Reveses** | "Legado" dice "lo que alguien dejó" |
| Casillero 5 | **Intemperie** (se confirma) | Se entiende sin explicación. Descartadas: Raso (se lee "liso") y Sereno (ambigua) |
| Almacén de carga | **El colmo** | El umbral es el colmo: lo que sobresale de la medida |
| Explosión | **Desborde** (*se desborda*) | La carga es una vasija que se llena; al llegar al colmo, rebalsa |
| Inversión | **Darse vuelta** (*se dio vuelta*) | Como un guante o una tela: muestra el revés |
| Extenuada | **Molida** (*molido* en masculino) | "Estar molido" es habla de campo y ata con el Molino. Descartadas: Rendida, Deshecha (se lee "destruida") |

#### Preguntas de la Visión 11

| Pregunta | Respuesta |
| --- | --- |
| Quién modeló a los Reveses | Los mismos Nueve, con la otra mano |
| ¿Legado + revés, o dos cualesquiera? | En el lore, **cualquier par vale**: una criatura puede llevar las dos manos de un oficio (Lleno y Vacío) o manos de oficios distintos. **PARA DIRECTOR / SISTEMAS:** el lore no restringe; si conviene, las dos manos del mismo oficio pueden ser una rareza, no una regla |
| Por qué el Maestro tiene afinidad con algunos legados y no con todos | Ningún humano tiene marca de hacedor: el Maestro **aprende** oficios. Arranca con los de su clase (el Menestral, con las manos) y aprende los de las criaturas con las que convive, **como un aprendiz que mira trabajar**. Los oficios lejanos de lo que vio le cuestan. Es la rueda del árbol dicha en el mundo (Pilar 3) |
| Por qué Lleno come mucho | Lo hizo la mano que llena: **tiene que estar lleno para ser lo que es** |
| Por qué Drenaje y Desapego son solitarios | Drenaje es la siega: donde pasa, lo de al lado se seca. Desapego es la tijera: lo suyo es soltar |
| Qué hace que una de Desapego se quede con el Maestro | **No se queda por necesidad: se queda porque quiere.** Por eso su lealtad cambia lento: no la compra el hambre ni la asusta el castigo |
| Cómo se comunican las de Sonido / por qué no se oye a las de Silencio | Sonido es la campana: llama y avisa, y el valle la entiende. Silencio es la campana quieta: no es mudez, es **no sonar** |

#### Los cuatro ciclos en el mundo

Cada ciclo es **un verbo del taller**. Sirve para que tooltips, descripciones y eventos digan siempre lo mismo.

| Ciclo | Distancia | Verbo | En una frase |
| --- | --- | --- | --- |
| Generación | +1 | **Nace** | Lo que una mano termina, la siguiente lo empieza |
| Potenciación | +4 | **Resuena** | Lo que uno tiene, el otro lo agranda, como la caja de un instrumento |
| Anulación | +8 | **Deshace** | Lo que uno hace, el otro lo desarma |
| Inversión | +9 | **Se da vuelta** | Las dos manos del mismo oficio |

**La rueda es una jornada de taller.** Los nueve legados son el trabajo del día, con la mano que da; los nueve reveses, el trabajo de la noche, con la otra. **Disciplina → Vacío** es el taller que queda vacío cuando termina la tarea de todos los días; **Inspiración → Lleno** es la idea de la madrugada que llena el día siguiente. Por eso la rueda no tiene principio ni fin.

**La regla que se desprende** (el revés de un legado anula a quien lo genera) se dice así: *la otra mano no deshace la obra, deshace de dónde salió.* El Vacío no rompe lo Lleno: le quita la Inspiración que lo llenaba.

##### Generación (+1): nace

| De | Nace | En el mundo |
| --- | --- | --- |
| Lleno | Crecimiento | Lo que está lleno tiene de qué crecer: la semilla lleva su propio alimento |
| Crecimiento | Movimiento | Lo que crece empieza a andar: el brote empuja la tierra, el potrillo corre |
| Movimiento | Liviandad | Lo que se mueve mucho se aliviana: la muela que gira saca la harina más fina |
| Liviandad | Intemperie | Lo liviano sale afuera: el vilano se va con el viento y vive en el aire |
| Intemperie | Sonido | Lo que vive afuera aprende a llamar: el pastor grita de un cerro al otro |
| Sonido | Sinceridad | Lo que suena se oye como es: la campana rajada no puede sonar sana |
| Sinceridad | Unión | De lo dicho de frente nace la confianza |
| Unión | Disciplina | Lo que se une se sostiene repitiendo: la trenza, la costumbre de la tribu |
| Disciplina | Vacío | Después de la tarea de todos los días queda el taller vacío. *Cruce del día a la noche* |
| Vacío | Drenaje | El hueco atrae lo que tiene alrededor: el pozo seca la tierra de al lado |
| Drenaje | Quietud | Lo que se secó deja de correr: el arroyo sin agua se queda quieto |
| Quietud | Presión | Lo quieto pesa sobre lo de abajo: la piedra solera |
| Presión | Protección | Lo apretado hace muro: el adobe prensado, la tierra pisada |
| Protección | Silencio | Detrás del muro no se oye nada |
| Silencio | Ilusión | En el silencio se imagina lo que no está: de noche, cualquier ruido es otra cosa |
| Ilusión | Desapego | Quien descubre que era un reflejo deja de aferrarse |
| Desapego | Inspiración | Con las manos libres aparece la ocurrencia |
| Inspiración | Lleno | La idea de la madrugada llena el día. *Cruce de la noche al día* |

> **Gancho para Sistemas:** la generación cuesta **fatiga** (Visión 10). En el mundo: pasar a la tarea siguiente cansa, pero no rompe. La inversión es darse vuelta entera: por eso **muele**.

##### Potenciación (+4): resuena

| El que tiene | Agranda a | En el mundo |
| --- | --- | --- |
| Lleno | Intemperie | Lo que está lleno aguanta afuera: la vasija llena no se la lleva el viento |
| Crecimiento | Sonido | La madera que creció despacio es la que mejor suena |
| Movimiento | Sinceridad | Lo que anda no se puede esconder: se lo ve pasar |
| Liviandad | Unión | Solo lo liviano se hila: el vellón, no la piedra |
| Intemperie | Disciplina | El que duerme al raso hace la guardia todas las noches, o no amanece |
| Sonido | Vacío | Lo que suena, suena en el hueco: la campana es hueca, el cántaro vacío retumba |
| Sinceridad | Drenaje | Lo que se muestra entero deja ver por dónde sacarle: el panal a la vista se saquea primero |
| Unión | Quietud | Un estandarte necesita a los suyos alrededor para quedarse en pie |
| Disciplina | Presión | El golpe repetido aprieta: el pisón, el martillo sobre el yunque |
| Vacío | Protección | El hueco cuida lo que guarda: la vasija, la cueva, la madriguera |
| Drenaje | Silencio | Lo que se seca se calla: el molino sin agua es un molino callado |
| Quietud | Ilusión | Lo quieto se confunde con el paisaje: el que no se mueve se vuelve junco |
| Presión | Desapego | Lo que se aprieta demasiado se suelta: la soga tensa se corta |
| Protección | Inspiración | A resguardo se piensa: junto al fuego, bajo techo, se ocurren las cosas |
| Silencio | Lleno | Lo que no se anuncia se conserva: la despensa callada nadie la vacía |
| Ilusión | Crecimiento | Lo que se esconde crece sin que se lo coman |
| Desapego | Movimiento | Lo que no está atado va adonde quiere: la barca sin amarra |
| Inspiración | Liviandad | Cuando se te ocurre algo, se te va el peso |

> Dos rastros que nunca se explican: **Drenaje → Silencio** nombra al Molino Callado sin decir por qué se tapó la acequia (4.3), y **Quietud → Ilusión** es lo que hace el Zancajunco cuando se hace junco.

##### Anulación (+8): deshace

| El que deshace | Lo deshecho | En el mundo |
| --- | --- | --- |
| Lleno | Disciplina | El que está lleno afloja la costumbre: panza llena duerme la guardia |
| Crecimiento | Vacío | Lo que crece tapa el hueco: la hierba cubre el pozo abandonado |
| Movimiento | Drenaje | El agua que corre no se estanca ni se deja secar |
| Liviandad | Quietud | Lo liviano no se queda donde lo ponen: la pluma no se queda quieta |
| Intemperie | Presión | Lo que vive afuera no se deja encerrar ni sujetar: el aire no se aplasta |
| Sonido | Protección | Ningún muro detiene el aviso: la campana se oye adentro de la casa |
| Sinceridad | Silencio | Lo que se ve no se puede callar: el vidrio muestra aunque nadie hable |
| Unión | Ilusión | Dos que se conocen no se engañan: el lazo ve a través del espejo |
| Disciplina | Desapego | La costumbre ata más que el hilo: lo que se repite todos los días no se suelta |
| Vacío | Inspiración | El hueco se traga la chispa: en la cabeza vacía no se enciende nada |
| Drenaje | Lleno | La grieta vacía el cántaro, por lleno que esté |
| Quietud | Crecimiento | Lo quieto no deja crecer: la piedra sobre el brote |
| Presión | Movimiento | Lo apretado no se mueve: el cepo, la tenaza |
| Protección | Liviandad | En la casa cerrada no corre el aire: lo que vuela se queda en el suelo |
| Silencio | Intemperie | Afuera se vive de oír: en el silencio no sabés de dónde viene el peligro |
| Ilusión | Sonido | El eco engaña: oís el aviso y no sabés de dónde vino |
| Desapego | Sinceridad | La verdad solo pesa sobre quien quiere quedarse: al que no le importa, no lo ata |
| Inspiración | Unión | La ocurrencia de uno rompe el plan de todos: el que se cortó solo con su idea |

> La anulación sirve para atacar y para defender (Visión 10: sacarle carga a una aliada antes de que se desborde). En el mundo, deshacer también es **desatar un nudo antes de que apriete**.

##### Inversión (+9): se da vuelta

Invertirse es **darse vuelta como un guante**: la criatura muestra el trabajo de la otra mano de quien la hizo.

| Legado | Se da vuelta en | Oficio | En el mundo |
| --- | --- | --- | --- |
| Lleno | Vacío | la Alfarera | La vasija llena y el hueco que la hace vasija |
| Crecimiento | Drenaje | la Sembradora | La mano que siembra es la misma que siega |
| Movimiento | Quietud | el Molinero | La piedra volandera gira porque la solera no se mueve |
| Liviandad | Presión | el Herrero | El fuelle deja escapar; el martillo aplasta |
| Intemperie | Protección | el Alarife | El patio abierto y el muro que lo rodea |
| Sonido | Silencio | la Campanera | Toda campana pasa más tiempo callada que sonando |
| Sinceridad | Ilusión | el Vidriero | Con el mismo vidrio se hace una ventana o un espejo |
| Unión | Desapego | la Hilandera | El huso une; la tijera corta |
| Disciplina | Inspiración | el Tallista | La gubia repite el golpe; la veta decide sola |

> **Por qué la que se dio vuelta queda molida:** una criatura está hecha para una mano. Trabajar con la otra la deja **molida** el resto del día. Coincide con la regla de la Visión 10; no pide cambios.

#### La escena de Desapego (texto de referencia, no entra al MVP)

Para la regla "si cae el Maestro, Desapego sigue peleando" (Visión 10):

> *[Rescatista] te arrastra fuera del claro. Los demás vienen detrás.*
> *[Criatura de Desapego] no viene. Se queda entre los caídos y el enemigo, sola, como si nunca hubiera esperado otra cosa.*
> *No pelea por vos. Pelea porque nadie se lo pidió.*

Si gana: *"Cuando volvés a abrir los ojos, [criatura] está en el Molino, sentada lejos del fuego. Detrás de ella, los que habías dejado atrás."*

#### Hipótesis de legados para las criaturas del MVP — `PROPUESTA` (PARA SISTEMAS)

Cuál mano las hizo. Los perfiles de atributos son de Sistemas.

| Criatura | Principal | Secundario | Por qué |
| --- | --- | --- | --- |
| Rodauva | Protección | Crecimiento | Se cierra y aguanta (Erizarse es el modelo de Protección, Visión 10); vive de la fruta |
| Surcón | Presión | Lleno | Ara, decide por dónde se pasa; come mucho |
| Ocarra | Sonido | Movimiento | Centinela y alarma; carga a los graznidos |
| Zancajunco | Ilusión | Crecimiento | Definido en la Visión 10 (Hacerse junco es Ilusión) |
| Tasajero | Disciplina | Drenaje | Cuenta y guarda: constancia; caza hasta secar el robledal de presas |

> Lectura de ecología que se sostiene: el Tasajero (Drenaje) les cae mal a la Rodauva y a lo que crece. Si la rueda no queda coherente con el mapa de relaciones (6.1), el lore se acomoda, no al revés.

## 3. La comida — `DECIDIDO`

Cada criatura come solo ciertos tipos de comida, y el Maestro necesita variedad: alimentar al grupo es una decisión diaria.

### 3.1 Reglas

- La comida tiene **7 tipos** en el MVP.
- Cada criatura tiene una comida **favorita**, comidas que **acepta** y comidas que **rechaza**. No come lo que rechaza.
- **Famélica**, una criatura puede comer lo que rechaza, con **pérdida de lealtad** y riesgo de caer **Enferma**.
- El **Maestro es omnívoro** (puede comerse una criatura), pero necesita una **dieta variada**: comer siempre lo mismo lo enferma.

### 3.2 Catálogo de comida del MVP

| Tipo | Qué incluye | Dónde se encuentra en Valdelumbre | Quién la come (además del Maestro) |
| --- | --- | --- | --- |
| **Fruta** | Manzanas, peras, ciruelas, bayas | Huertos de Almiar | Rodauva (favorita), Ocarra |
| **Raíces** | Tubérculos, bulbos, nabos silvestres | Huertos de Almiar, orillas del Vado | Surcón (favorita), Ocarra |
| **Grano** | Trigo y cebada viejos, semillas | Granero de Almiar (a veces podrido) | Ocarra (favorita), Rodauva, Surcón |
| **Bichos** | Lombrices, caracoles, larvas | En todas partes, en poca cantidad | Todas las reclutables |
| **Pescado** | Peces, ranas, cangrejos de río | Vado de los Juncos | Zancajunco (favorita), Ocarra |
| **Carne** | Presas de caza | Robledal Hondo | Zancajunco (única reclutable que la acepta) · Tasajero (única) |
| **Hongos** | Setas del robledal (algunas dañinas) | Robledal Hondo | Surcón |

> **Criterio de diseño:** la comida más segura está cerca y alimenta a pocas criaturas. La carne alimenta al Maestro y al cazador del vado, y está en el lugar más peligroso.
>
> **Bichos:** la comida de emergencia siempre está, pero nunca alcanza. Convertirlos en ración es directo, no es crafteo.

### 3.3 Estado Enfermo

En el MVP hay **un solo estado negativo, Enfermo**, con un único efecto. Afecta a las criaturas y al Maestro. Las causas son narrativas; la duración y la probabilidad las define `Sistema.md` (sección 8).

| Causa narrativa | Origen en el mundo |
| --- | --- |
| **Empacho** | Comer algo rechazado estando famélica · dieta monótona del Maestro |
| **Tripa negra** | Grano o carne podridos (el granero de Almiar) |
| **Fiebre del hongo** | Hongos de sombrero manchado (el Robledal Hondo) |

Los tres estados con efectos distintos entran en la **Capa 1**.

### 3.4 Textos de la comida — `DECIDIDO`

**Rebuscar** (`Sistema.md` 12.4): *"Das vuelta piedras y hojas. Un puñado de bichos: no es comida, pero es algo."*
Con un Surcón suelto: *"El Surcón hunde el hocico donde vos no ves nada y saca el doble."*

**Comida que se pudre** (al cerrar el día, `Sistema.md` 12.5):

| Tipo | Texto |
| --- | --- |
| Fruta | *"La fruta se ablandó y le zumban las moscas."* |
| Pescado | *"El pescado tiene el ojo opaco. El olor llega antes que vos."* |
| Carne | *"La carne cambió de color en los bordes."* |
| Hongos | *"Los hongos se ablandaron y sudan."* |
| Grano podrido (granero) | *"Grano con manchas verdes. Pesa lo mismo que el bueno."* |
| Hongos dudosos | *"No todos tienen el sombrero limpio, y ya no sabés cuáles."* |

### 3.5 Hambre — `DECIDIDO`

Cada especie pasa hambre a su manera, y las líneas anticipan su momento oscuro (sección 5) sin ejecutarlo. Aparecen a la mañana, **solo al cambiar de estado**. Saciado y Normal no tienen línea: el hambre se nota cuando falta. Reglas en `Sistema.md` 7.

#### Pasa a Hambrienta

| Ser | Texto |
| --- | --- |
| General | *"[Criatura] camina más cerca de la bolsa de comida que de vos."* |
| Rodauva | *"La Rodauva se come la fruta que llevaba en las púas."* |
| Surcón | *"El Surcón bosteza más que de costumbre y se echa antes de llegar."* |
| Ocarra | *"La Ocarra grazna cada vez que abrís la bolsa."* |
| Zancajunco | *"El Zancajunco mira el agua aunque no haya agua cerca."* |
| Maestro | *"Te cuesta juntar la magia. El estómago tira para otro lado."* |

#### Pasa a Famélica

| Ser | Texto |
| --- | --- |
| General | *"[Criatura] ya no te sigue a vos: sigue a la comida."* |
| Rodauva | *"La Rodauva ya no tiene nada en las púas. Te olfatea las manos."* |
| Surcón | *"El Surcón se entierra a medias y no quiere salir."* |
| Ocarra | *"La Ocarra no grazna. Se queda mirando a las más chicas."* |
| Zancajunco | *"De noche, el Zancajunco se queda mirando hacia el río."* |
| Maestro | *"La magia se te escurre entre los dedos. Primero hay que comer."* |
| Tooltip | *"Famélica: come lo que rechaza y pierde vida cada noche. Si no te es leal, puede irse."* |

#### Consecuencias

| Momento | Texto |
| --- | --- |
| Comer algo rechazado | *"[Criatura] come [comida] con la cabeza gacha. No te lo va a agradecer."* |
| Pierde vida al dormir famélica | *"[Criatura] amaneció más flaca."* |
| El Maestro pierde vida | *"Te cuesta levantarte. El cinturón te sobra un agujero."* |
| Aviso: la próxima noche la mata | *"Si [Criatura] pasa otra noche así, no va a despertar."* (se ve **antes** del reparto) |
| Muere de hambre (general) | *"[Criatura] no se levantó esta mañana. Su pergamino ya era ceniza cuando abriste los ojos."* |
| Muere de hambre: Surcón | *"El Surcón se enterró a dormir el hambre. Esta mañana, la tierra no sube ni baja."* |
| La tribu ante la muerte | *"Los demás duermen un poco más lejos del lugar vacío."* |
| Reparto: no alcanza | *"No alcanza para todos. Alguien se va a dormir con hambre."* |

> El aviso de muerte es el reloj contable de la Visión 6.5 dicho en el mundo: el momento en que comerse a una criatura deja de ser impensable.

### 3.6 Enfermo: textos — `DECIDIDO`

El efecto es uno solo (pega y junta menos), pero cada causa se ve distinta: el jugador tiene que leer qué le pasó a quién, porque la causa define cuánto dura. Malestar de campo, no de hospital. Reglas en `Sistema.md` 8 y 1.5.

> Solo el Surcón come hongos entre las criaturas: la Fiebre del hongo se escribe para él y para el Maestro. El Maestro, omnívoro, solo se empacha por dieta monótona.

#### Antes de comer (en el reparto)

| Momento | Texto |
| --- | --- |
| Ración rechazada a una famélica | *"[X]% de que le caiga mal: Empacho, 1 día."* |
| Ración podrida | *"[X]% de Tripa negra, 2 días."* |
| Ración dudosa de hongos | *"[X]% de Fiebre del hongo, 3 días."* |
| El Maestro come carne o pescado sin fuego | *"Crudo. [X]% de Tripa negra."* |
| Dieta monótona: aviso (2.º día) | *"Otra vez [tipo]. La boca ya no le encuentra el gusto."* |
| Dieta monótona: Empacho (3.er día) | *"Tres días de [tipo]. El cuerpo dice basta."* |

#### Cae Enfermo

| Causa | Quién | Texto |
| --- | --- | --- |
| Empacho | Criatura | *"[Criatura] se echa con la panza hinchada y no quiere moverse."* |
| Empacho | Maestro | *"Te pesa el estómago como si hubieras comido piedras."* |
| Tripa negra | Criatura | *"[Criatura] pasó la noche con retortijones. A la mañana tiene los ojos opacos."* |
| Tripa negra | Maestro | *"Algo de lo que comiste anoche no estaba bien. Te lo dice todo el cuerpo."* |
| Fiebre del hongo | Surcón | *"El Surcón tiembla en su hondonada y ronca con los ojos abiertos."* |
| Fiebre del hongo | Maestro | *"Te arde la frente. Los árboles se mueven un poco más de lo que deberían."* |

#### Acumulación y cura

| Momento | Texto |
| --- | --- |
| Segunda enfermedad | *"Una cosa encima de la otra. [Criatura] apenas levanta la cabeza."* |
| Tercera enfermedad | *"[Criatura] ya no sabe qué le duele."* |
| Maestro con tres | *"Ya no sabés qué te duele. Solo que todo."* |
| Tooltip del estado | *"Enferma: pega menos y junta menos. Cada enfermedad suma."* |
| Empezar a descansar (Molino) | *"Te quedás en el Molino con agua del río y nada más. El cuerpo se arregla; el estómago se queja."* |
| Cortar el descanso | *"Salís antes de estar del todo bien. Lo que se curó, quedó curado."* |
| Curarse viajando | *"Caminar también cura, aunque despacio."* |
| Se cura el Empacho | *"A [Criatura] se le deshinchó la panza."* |
| Se cura la Tripa negra | *"A [Criatura] se le aclararon los ojos."* |
| Se cura la Fiebre del hongo | *"A [Criatura] le bajó la fiebre. Vuelve a mirar lo que sí está."* |
| Se cura el Maestro | *"Te levantás y el cuerpo responde. Ya era hora."* |

> El agua es del río, no de la acequia: la acequia está tapada (4.3).

## 4. Región inicial: Valdelumbre — `DECIDIDO`

Valdelumbre enseña la supervivencia de menor a mayor riesgo: **fruta** (fácil) → **pescado** (media) → **carne** (peligrosa).

### 4.1 Concepto

Un valle ancho y dorado, con frutales asilvestrados, un río lento y un robledal oscuro al norte. En el MVP es siempre **fin de verano** (las estaciones entran en la Capa 2).

### 4.2 Historia

En el valle había una aldea, **Almiar**. Sus vecinos se fueron después de un invierno de hambre al que en la zona llaman **el Invierno Flaco**. Nadie sabe adónde fueron. El valle se recuperó y hoy desborda de fruta.

Lo que queda: un granero vacío, un molino parado, un palomar al que volvieron algunas palomas, una hornacina con un cuenco y, en el marco de una puerta, rayitas que cuentan días.

**Función narrativa:** la abundancia es real. Lo oscuro es el rastro de lo que pasó la última vez que alguien no se preparó. Es una advertencia, no una amenaza.

### 4.3 Geografía del valle — `DECIDIDO`

El valle es una línea que sigue el río hacia el norte, aguas arriba. Para llegar al Robledal hay que pasar por los otros dos destinos y **cruzar el río en el vado** (los días de viaje están en `Sistema.md` 12.1).

```
(sur, boca del valle)                                    (norte, cabecera)
Molino Callado ── Huertos de Almiar ── Vado de los Juncos ══ Robledal Hondo
                                                    (el río se cruza acá)
```

| Tramo | Dónde está | Qué lo justifica |
| --- | --- | --- |
| El Molino Callado | La boca del valle, al sur, donde el río sale | Un molino se construye donde el agua ya bajó y junta fuerza |
| Los Huertos de Almiar | Media ladera sobre el río, en las tierras de labor de la aldea | La gente vivía cerca del molino y lejos del bosque |
| El Vado de los Juncos | Donde el río se ensancha y se puede cruzar a pie | Es el único paso hacia la otra orilla |
| El Robledal Hondo | La cabecera del valle, **del otro lado del vado** | Para llegar al Robledal hay que cruzar el río |

**Función:** el Vado es el **umbral** del destino peligroso, y "La crecida" es el portero del Robledal.

> La crecida **no cierra el paso**: el río crecido se cruza pagando vida (`Sistema.md` 12.11; textos en 4.5).

**El Molino es de agua** — aprobado en espíritu (gancho para la Capa 1). Está callado porque **la acequia se tapó** y la rueda dejó de girar. Repararlo sería destaparla y hacer girar la rueda otra vez. Nunca se explica por qué se tapó.

### 4.4 Lugares

| Lugar | Tipo | Comida | Material del ritual | Criaturas | Peligro | Qué le enseña al jugador |
| --- | --- | --- | --- | --- | --- | --- |
| **El Molino Callado** | Campamento | Agua | Carbón (el fuego) | — | Ninguno | Descanso, convivencia, rescate, ritual de sangre. Escenario del ataque nocturno. Molino de agua con la acequia tapada; reparable a futuro (Capa 1). Las rayas y las golondrinas marcan el plazo (4.10) |
| **Los Huertos de Almiar** | Destino 1 (cerca) | Fruta, raíces, grano, bichos | Péñola · Cuenco (una vez) | Rodauva, Ocarra | Bajo | Recolección y camino de confianza |
| **El Vado de los Juncos** | Destino 2 (media) | Pescado, raíces, bichos | Agua de charco | Zancajunco, Ocarra, Surcón | Medio | Combate, sellado probabilístico, relaciones en conflicto. La Poza Tibia (sanador) |
| **El Robledal Hondo** | Destino 3 (lejos) | Carne, hongos, bichos | Ramita de roble | Tasajero | Alto | Riesgo contra recompensa, apaciguar, decisiones morales |

### 4.5 Eventos de nodo

#### Los Huertos de Almiar

- **El granero.** *"La mitad de los sacos está podrida. En la viga alguien talló cuarenta y una rayas."* Opciones: llevarse el grano que sirve · revisar a fondo y llevar más, con riesgo de **Tripa negra**.
- **Bajo el manzano.** *"Una bola de púas junta manzanas caídas. Se queda quieta cuando te ve."* Opciones: dejarle fruta (inicia el camino de confianza con una Rodauva) · espantarla y quedarse con la fruta.
- **La hornacina** *(cuenco; solo en el primer recorrido de las ruinas)*. *"En la pared de la casa más grande hay un hueco a la altura del pecho. Adentro, un cuenco de barro boca abajo. Al darlo vuelta, en el fondo queda ceniza vieja y una mancha oscura que ninguna lluvia lavó."* Resultado: el Maestro obtiene el cuenco.
  - En visitas posteriores: *"La hornacina está vacía. Alguien la hizo para guardar una sola cosa."*
- **El corral caído** *(avistamiento de la Ocarra)*. *"Detrás de la casa grande hay un corral con la cerca medio caída. Una Ocarra se pasea por arriba del muro como si fuera suyo. Te grazna antes de que des un paso."*

| Opción | Texto | Consecuencia |
| --- | --- | --- |
| Dejar comida en la cerca | *"Dejás la ración sobre la piedra y retrocedés. Baja, la come de espaldas a vos y vuelve a subir."* | +confianza (`Sistema.md` 4.5) |
| Irse | *"Te vas. Sigue graznando un rato largo, por las dudas."* | Sin cambio |
| *Requisito: Ocarra suelta* | *"Las dos Ocarras se miran por encima de la cerca. Ninguna baja la cresta."* | No se puede usar ese día (Ocarra–Ocarra se llevan mal; misma regla que el juncal) |

- **El palomar** *(péñola)*. *"Las palomas se fueron con la gente, pero algunas volvieron. En el piso hay plumas largas y duras, de las que sirven para escribir."*
- **La ciruela en disputa** *(encuentro de solo trabajo: 2 Rodauvas, `Sistema.md` 11.6)*. *"Dos Rodauvas se disputan una ciruela caída. Cuando te ven, se enrollan juntas, púa contra púa."*

| Opción | Texto | Consecuencia |
| --- | --- | --- |
| Atacar | *"No te buscan pelea. Si querés sellarlas por la fuerza, la vas a tener que empezar vos."* Tooltip: *"Erizadas, cuesta debilitarlas sin pasarse."* | Combate |
| Seguir de largo | *"Las dejás con su ciruela. Cuando te alejás, oís que se desenrollan."* | Sin cambio |
| *Variante: Rodauva suelta* (solo texto) | *"Tu Rodauva se acerca a olerlas. Las tres se quedan quietas, como si se conocieran."* | Sin cambio |

Línea general para cualquier encuentro de solo trabajo: *"[Criaturas] no te buscan pelea. Si querés una, la vas a tener que empezar vos."*

#### El Vado de los Juncos

- **La crecida: leer el río** *(`Sistema.md` 12.11)*. El nodo muestra el estado del río del día siguiente. Mientras el Maestro tiene quebranto, este nodo es la Poza Tibia.

| Momento | Texto |
| --- | --- |
| Leer el río: mañana normal | *"Tirás una rama al agua y la seguís con la vista. Baja tranquila. Mañana se va a poder cruzar."* |
| Leer el río: mañana crecido | *"La rama se hunde y sale lejos, girando. Mañana el río va a bajar crecido."* |
| Cruce normal | *"El agua te llega a las rodillas. Cruzás sin mojar la comida."* |
| Río crecido, antes de cruzar | *"El vado está tapado de agua marrón. Se puede cruzar. No se puede cruzar entero."* Tooltip: *"Cada uno de los sueltos pierde [X] de vida. Las guardadas cruzan a salvo."* |
| Cruce con daño | *"El río te empuja de costado y te arrastra un trecho contra las piedras. Llegás a la otra orilla tosiendo agua. Los tuyos también."* |
| Esperar un día | *"Acampás en la orilla a esperar que baje. Mañana va a estar mejor, o peor."* |
| Cruce a ciegas con quebranto | *"No pudiste leer el río: estabas en la Poza. Vas a saber cómo baja cuando tengas el agua en la cintura."* |
- **Algo se movió en el juncal** *(avistamiento del Zancajunco)*. *"Uno de los juncos parpadeó."*

| Opción | Texto | Consecuencia |
| --- | --- | --- |
| Dejar comida en la orilla | *"Dejás la ración en una piedra de la orilla y te vas sin mirar atrás. Cuando volvés la cabeza, la piedra está vacía y el juncal, quieto."* | +confianza (`Sistema.md` 4.5) |
| Seguir de largo | *"Seguís de largo. Sentís que el juncal te mira la nuca."* | Sin cambio |
| *Requisito: Ocarra suelta* | *"La Ocarra le grazna al juncal. Algo se va entre los juncos, y hoy no vuelve."* | No se puede usar ese día |
- **El surco que ronca** *(avistamiento del Surcón; en la orilla)*. *"Alguien aró anoche la tierra blanda de la orilla. El surco es torcido y hondo, y termina en un montículo que sube y baja despacio. Ronca."*

| Opción | Texto | Consecuencia |
| --- | --- | --- |
| Dejar comida al borde del surco | *"A la mañana, la ración ya no está y el surco es un poco más largo."* | +confianza (`Sistema.md` 4.5) |
| Seguir de largo | *"No lo despertás. Nadie despierta a un Surcón por gusto."* | Sin cambio |
| *Variante: Ocarra suelta* (solo texto) | *"La Ocarra se mete en el surco detrás de él, a picotear lombrices. El montículo no se queja."* | Sin cambio |

- **La Poza Tibia** *(el sanador del MVP)*. *"Entre las piedras de la orilla brota un agua que no se enfría ni de noche. Los animales del vado vienen a bañarse cuando están lastimados, y ninguno molesta a otro."* Es el lugar al que el Maestro debe viajar después de recuperarse de un rescate para evitar las secuelas (Visión 6.6). No es un NPC: es un lugar que los animales conocían antes que el Maestro.
  - Ocupa el nodo de La crecida mientras el Maestro tiene quebranto, sin encuentro; la noche en el Vado sigue con emboscada normal (`Sistema.md` 6.2). Textos del baño en 4.9.
  - La Poza **no es un rastro de los Nueve** y ningún texto la relaciona con ellos: es ecología, no misterio.

- **El charco quieto** *(agua de charco)*. *"La última crecida dejó un charco en la orilla, separado del río por una lengua de barro. El agua no se mueve. En el fondo, unas piedras lisas forman una ronda que ninguna corriente pudo ordenar."*

#### El Robledal Hondo

- **El colgadero.** *"De las ramas cuelgan presas, ordenadas como en una despensa. Entre ellas quedan huecos, como si alguien supiera exactamente cuántas faltan."*

| Opción | Texto | Consecuencia |
| --- | --- | --- |
| Robar carne | *"Descolgás lo que podés cargar. Detrás tuyo, una rama se mueve sin viento."* | Ganás carne · sube la hostilidad del Tasajero |
| Dejar una ofrenda | *"Dejás comida en la rama más baja. Esta noche alguien va a comer menos. Cuando volvés a mirar, ya no está."* | Baja la hostilidad · la comida ofrendada se pierde |
| Irse sin tocar nada | *"Retrocedés por donde viniste. Te queda la sensación de que alguien anotó tu visita."* | Sin cambio |
| *Requisito: Rodauva suelta* | *"La Rodauva se enrolla y no se mueve. Algo, arriba, ya la vio."* | Sube la hostilidad aunque no robes nada |

- **Hongos al pie del roble.** *"Hay de sobra. Algunos tienen el sombrero manchado."* Opciones: recoger con cuidado (menos cantidad) · recoger todo (riesgo de **Fiebre del hongo**).
- **El Roble Viejo** *(ramita de roble; más allá del colgadero)*. *"El bosque se abre alrededor de un roble más ancho que el Molino. En la corteza hay una talla gastada: una figura con las manos juntas, como quien sostiene algo que ya no está. A sus pies hay ramitas caídas."*
- **El rodeo de las zarzas** *(camino alternativo al Roble Viejo)*. *"Hay otra forma de llegar: por la ladera, entre zarzas, lejos de las ramas que cuelgan. Es más largo. Nadie te mira, o eso parece."*

> **Llegar al Roble Viejo** — `DECIDIDO`: hay dos caminos. Por el colgadero (más corto, expuesto al Tasajero) o por el rodeo de las zarzas (más largo, sin pasar por el colgadero). El jugador elige entre tiempo y riesgo.
>
> El rodeo **ocupa una columna extra** del mapa del día y no tiene peligro propio en el MVP: su costo es un nodo menos de comida (`Sistema.md` 12.8).

#### El Tasajero por estado — `DECIDIDO`

La hostilidad y sus efectos viven en `Sistema.md` 12.10. La ofrenda: −1 de hostilidad cada 2 raciones, la carne cuenta doble, máximo −2 por ofrenda, sin raciones podridas.

| Estado | Al llegar al Robledal | Tooltip |
| --- | --- | --- |
| Apaciguado | *"Las ramas del colgadero se mueven con el viento, nada más. Hoy nadie te cuenta."* | *"Te deja pasar."* |
| Atento | *"Entre los robles, algo te sigue siempre a la misma distancia. No se acerca. No se va."* | *"Te observa."* |
| Cazando | *"Las presas del colgadero están ordenadas de nuevo. Hay un hueco que ayer no estaba."* | *"Te busca."* |

| Momento | Texto |
| --- | --- |
| Nodo de encuentro apaciguado | *"En el claro hay huellas largas y frescas que se alejan de vos. El Tasajero pasó por acá y decidió que no valías la pena. Podés rebuscar en paz."* |
| Robar estando Cazando (combate inmediato) | *"Descolgás la primera presa y la rama de arriba no se mueve: baja. El Tasajero ya no está contando."* |
| Sube a Cazando | *"Esta noche, en el Robledal, alguien hizo lugar en una rama."* |
| Baja de estado | *"La ofrenda ya no está, y la rama quedó quieta."* |

### 4.6 Ataque nocturno — `DECIDIDO`

**Base:** *"Te despierta el silencio. El Molino cruje como siempre, pero algo dejó de respirar junto al fuego. Cuando abrís los ojos, [criatura] ya está encima tuyo."*

| Criatura | Línea propia |
| --- | --- |
| Ocarra | *"No grazna. Eso es lo que más te asusta: la Ocarra nunca hizo nada en silencio."* |
| Rodauva | *"Tiene las púas vacías. Se desenrolla a tus pies y, por primera vez, no se aparta."* |
| Surcón | *"La tierra del piso se abre debajo de las bolsas de comida. Después, debajo tuyo."* |
| Zancajunco | *"Está de pie en la puerta, inmóvil, como en el vado. Te mira como mira el agua."* |

**Al raso** (`Sistema.md` 9.4): *"Te despierta el silencio. El fuego está bajo y nadie lo atizó. Del otro lado de las brasas, [criatura] no se volvió a echar."*
Sin fuego: *"No encendiste fuego. Por eso no ves a [criatura] hasta que la tenés encima."*

| Criatura | Línea al raso (las demás sirven igual que en el Molino) |
| --- | --- |
| Surcón | *"La tierra se abre debajo de las bolsas de comida. Después, debajo tuyo."* |
| Zancajunco | *"Está de pie al borde del campamento, inmóvil, como en el vado. Te mira como mira el agua."* |

**Centinela** (otra Ocarra, que no es la atacante, anula el golpe gratis): *"La otra Ocarra grazna una vez, fuerte. Te alcanza para rodar a un costado."*

> Texto fijo, sin hueco: con `{criatura}` saldría "la Ocarra" y no se distinguiría de la atacante cuando las dos son Ocarras.

**Las que miran** — `PROPUESTA` (v1.1). Solo las leales defienden; las demás miran (`Sistema.md` 9.2). Estos complementos ya estaban en `es.json` y no figuraban en este documento; cierran el pedido de `Sistema.md` 15.

| Momento | Clave | Texto |
| --- | --- | --- |
| Hay sueltas que no defienden | `nocturno.miran` | *"No todos vienen. En la oscuridad hay ojos abiertos que no se mueven."* |
| Ninguna lo defiende | `nocturno.miran.ninguna` | *"Nadie se levanta a ayudarte. En la oscuridad hay ojos abiertos que no se mueven. Esta pelea es tuya."* |
| La Centinela no es leal | `nocturno.centinela.mira` | *"Después se queda donde está, con el cuello estirado. Ya te avisó: el resto no es asunto suyo."* |

#### La atacante caída — `DECIDIDO` (escenario G, T30)

Las tres salidas de la Visión 6.4. Sirven en el Molino y al raso. Las líneas del epílogo de cada salida ya existen (4.11).

| Momento | Clave | Texto |
| --- | --- | --- |
| Al caer la atacante | `nocturno.atacante.caida` | *"[Criatura] cae y no se levanta. Respira. Nadie de la tribu se mueve: esperan a ver qué hacés."* |
| **Perdonar** | `nocturno.perdonar` | *"Te hacés a un lado. [Criatura] tarda en entender que puede irse. Cuando se va, su pergamino se enciende con una llama pálida."* |
| Perdonar: la tribu | `nocturno.perdonar.tribu` | *"Nadie dice nada. Esta noche, los tuyos duermen un poco más cerca."* |
| Perdonar: tooltip | `nocturno.perdonar.tooltip` | *"Se va libre y su pergamino arde. La tribu valora la clemencia."* |
| **Sellar de nuevo** | `nocturno.sellar` | *"Su pergamino ya es ceniza. Desenrollás uno en blanco y el hilo la recoge, más corto que antes."* |
| Sellar: tooltip | `nocturno.sellar.tooltip` | *"Vuelve a la tribu sin ninguna confianza. Gasta un pergamino en blanco."* |
| Sin pergamino en blanco | `pergamino.sin_blanco` | *"No te queda ningún pergamino en blanco."* (compartido con el sellado en combate) |
| **Comerla** | `nocturno.comer` | *"No esperás a la mañana. Cuando terminás, el fuego está más bajo y nadie te mira. Vieron lo que hizo ella. También vieron lo que hiciste vos."* |
| Comer: tooltip | `nocturno.comer.tooltip` | *"Te da de comer. Su pergamino arde. La tribu pierde confianza, aunque menos que si no te hubiera atacado."* |
| Comer: con Zancajunco suelto (solo texto) | `nocturno.comer.zancajunco_suelto` | *"El Zancajunco se acerca a comer con vos. Es el único."* |

> La clemencia, el nuevo sello y la comida se leen distinto por cómo reacciona la tribu, no por cómo se describe a la atacante. Comerla se elide (1.3).
> **Desde T30**, la pantalla de resultado muestra *"Queda por decidir: [criatura]"* (`resultado.atacante_pendiente`, v1.5) antes de los tres botones. Si el resellado falla, la pantalla muestra `sellar.fallo` y la atacante sigue caída: quedan perdonar o comer.

#### La atacante que se va — `PROPUESTA` (v1.1; Visión 6.4 v1.2, `Sistema.md` 9.2, paso 6)

Si el Maestro cae antes de decidir, la atacante, caída o de pie, **se va**: su pergamino arde y vuelve a ser salvaje. Nadie la ve irse (Visión 7): el jugador se entera al despertar, por la ceniza. La tribu no reacciona, porque nadie decidió nada.

| Momento | Clave | Texto |
| --- | --- | --- |
| Primera mañana de la recuperación | `nocturno.atacante.se_fue` | *"De la noche del ataque te acordás a pedazos. Cuando podés contar a los tuyos, falta [Criatura]. En la bolsa, su pergamino es ceniza, y no sabés para qué lado se fue."* |
| Epílogo | `epilogo.perdida.abandono.atacante` | Ver 4.11 |

- Se muestra **antes** de las líneas de abandono de la recuperación (4.13): primero la que se fue por la noche del ataque, después las que se fueron mientras el Maestro se reponía.
- Sin rescatista (permadeath) no hay mañana: la línea no aparece.
- *"No sabés para qué lado se fue"* hace eco con la línea Desleal del epílogo (*"no sabés para qué lado iría"*): lo que era una duda se cumplió.

### 4.7 Noches al raso — `DECIDIDO`

#### Habilidades de campamento del Maestro

Nombres finales (reemplazan a los provisorios de `Sistema.md` 9.4) y texto de la primera noche en que cada una despierta.

| Especie suelta | Habilidad | Texto de despertar |
| --- | --- | --- |
| Rodauva | **Leña en las púas** | *"La Rodauva vuelve del monte con ramitas secas clavadas entre las púas. Se sacude a tu lado hasta que caen todas."* |
| Ocarra | **Sueño liviano** | *"La Ocarra no se echa. Se queda de pie, con un ojo abierto. Esta noche, cualquier ruido va a tener respuesta."* |
| Surcón | **Madriguera** (antes "Hoyo", que se leía como trampa) | *"El Surcón cava una hondonada en la tierra blanda y se acuesta en el borde. Quedás más abajo que el viento y que cualquier mirada."* |
| Zancajunco | **Acecho** | *"El Zancajunco se planta al borde del campamento y deja de moverse. Si algo viene, lo va a ver antes de que llegue."* |

#### Emboscadas

| Destino | Con alarma ([guardiana] cubre la guardia) | Sin alarma (ronda de sorpresa) |
| --- | --- | --- |
| Huertos | *"En la guardia de [guardiana], algo cruza la hierba a los graznidos. Te despierta a tiempo."* | *"Te despierta un picotazo. Una Ocarra se plantó en medio del campamento como si fuera su corral."* |
| Vado | *"[Guardiana] ve moverse el juncal donde no hay viento. Te despierta antes de que el primer junco dé un paso."* | *"Anoche el juncal estaba más lejos. Cuando abrís los ojos, ya está entre vos y el fuego."* |
| Robledal | *"[Guardiana] se queda mirando las ramas de arriba. Algo te estaba contando mientras dormías."* | *"No hubo ningún ruido. Cuando abrís los ojos, el Tasajero ya está entre las sueltas. Mira a dos a la vez."* (v1.1: en Caza reparte los golpes, no ejecuta) |

| Variante | Texto |
| --- | --- |
| Fuego en el Robledal | *"El fuego te calentó toda la noche. También te iluminó."* |
| Guardiana dormida (obediencia ≤ 3) | *"[Guardiana] se durmió en su guardia."* |

### 4.8 La apertura: la dueña del Molino — `DECIDIDO`

**Por qué la Rodauva está con el Maestro.** Cuando el Maestro llegó al valle, el Molino Callado ya tenía ocupante: una Rodauva dormía en la hojarasca, junto a la piedra del fuego. Compartieron el techo unas noches; cuando ella se acercó al fuego, el Maestro la selló por confianza.

| Condición del sistema | Cómo la cumple el lore |
| --- | --- |
| Ocupa un pergamino | Ya está sellada antes del día 1 |
| Lealtad 5 (camino de confianza) | La selló después de varias noches de dejarle comida |
| Todavía no es leal | El vínculo tiene días: todavía se enrolla si hablás fuerte |
| Su comida favorita está cerca | Vive en el Molino desde antes y conoce los Huertos |

**Qué hace en la historia:** invierte la relación. **El recién llegado es el Maestro**; la Rodauva es la dueña de casa. La compañera queda atada al lugar del rescate, del ritual y del ataque nocturno.

> **Restricción de lore:** la Rodauva **no era de Almiar** ni tuvo un Maestro antes. Nada de la apertura puede confirmar que alguien en la aldea hizo el ritual (la mancha del cuenco es ambigua para siempre, 2.7).

**Texto de apertura:**

> *Llegaste a Valdelumbre con tres pergaminos en blanco y poco más. El Molino Callado fue el primer techo que encontraste. No estaba vacío: junto a la piedra del fuego había un montón de hojarasca, y el montón respiraba.*
> *Tres noches le dejaste lo que te sobraba. La cuarta, la Rodauva durmió del lado de adentro del fuego. A la mañana siguiente, el primer pergamino ya no estaba en blanco.*
> *Todavía se enrolla cuando hablás fuerte. Todavía no es tuya del todo. Pero hoy salió a la puerta antes que vos, y mira hacia los huertos.*

**Las dos frutas iniciales** (inventario del día 1, `Sistema.md` 3.4): *"Antes de salir, la Rodauva se sacude en la puerta. Dos frutas caen de sus púas y ruedan hasta tus botas. No te las da: se le cayeron. Pero no vuelve a juntarlas."*

**Línea de la interfaz** (la primera vez que se muestra el umbral de rescate): *"Si la cuidás, te va a salvar. Todavía no."*

> En combate, el panel del turno retoma esta promesa con *"Te lleva a casa: [criatura]"* o *"Si caés ahora, nadie te lleva a casa."* (1.5, v1.5).

**El pasado del Maestro no se explica en el MVP** — `DECIDIDO`. La apertura no dice de dónde viene ni por qué tiene tres pergaminos. Ese hueco es deliberado: depende de la clase (Capa 3) y de la historia principal (Capa 4).

### 4.9 El quebranto y la Poza Tibia — `DECIDIDO`

**Quebranto** reemplaza a "malherido". Es la última etapa del rescate: una marca en la barra de vida con su contador, como "lo que diste". **No es un estado negativo** (el único del MVP sigue siendo Enfermo). Reglas en `Sistema.md` 6.1 y 6.2.

| Momento | Texto |
| --- | --- |
| Fin de la recuperación | *"Te podés parar. No mucho más. Algo adentro tuyo no está cerrando."* |
| Mañana con quebranto | *"Hoy amaneciste con menos de lo que tenías ayer."* |
| Vida máxima en el mínimo (nunca fue a la Poza) | *"Ya no queda nada que perder. Eso tampoco es un alivio."* |
| Baño en la Poza | *"Te metés en la Poza hasta el pecho. El agua no está caliente: está tibia como un cuerpo. Del otro lado, un animal que no conocés tiene una pata recogida y no te mira. Cuando salís, el cansancio sigue ahí, pero ya no se te sigue cayendo encima."* |
| Tooltip del baño | *"Lo que perdiste no vuelve. Lo que te queda, ahora sí se cura."* |
| Variante (criatura suelta y leal; solo texto) | *"[Criatura] se queda en la orilla, de guardia, hasta que salís."* |

### 4.10 El plazo: las rayas y las golondrinas — `DECIDIDO`

La partida dura un número fijo de días (`Sistema.md` 13). Dos marcas, cada una con su papel, sin simular clima ni explicar el pasado del Maestro:

| Marca | Papel | Qué se ve |
| --- | --- | --- |
| **Las rayas** | El contador exacto | El plazo se muestra en la interfaz como rayas de carbón del fuego del Molino, una por día. Las mismas rayas aparecen en una viga del Molino. Es el carbón de la Urdimbre: sin objetos nuevos |
| **Las golondrinas del Molino** | La señal del mundo | Se juntan en el techo del Molino a medida que pasan los días (3 o 4 etapas). Antes del alba del último día se van todas juntas. No cuentan nada con precisión ni tienen mecánica |

> **Eco con Almiar:** en la viga del granero alguien talló cuarenta y una rayas (4.5). Las tuyas son de carbón y están en el Molino. El eco es un **rastro, no una pista**: dice que ellos también contaban días, nunca qué les pasó.

### 4.11 El epílogo — `DECIDIDO`

Solo texto que lee la tribu, sin puntaje (Visión 5; `Sistema.md` 13). Cada criatura comida tiene su propia línea y **pesa igual el último día que el primero**.

**Orden de lectura** — `DECIDIDO` (`Sistema.md` 13): la apertura; las sueltas (la **compañera inicial** primero, después de mayor a menor lealtad); las guardadas (de la guardada hace más tiempo a la más reciente); las perdidas por día, en el orden en que ocurrieron; y el cierre. Lo que queda se cuenta primero; lo perdido se lee día por día. La compañera inicial tiene líneas propias porque fue el primer pergamino.

**Apertura:**

> *Esta mañana no hay golondrinas en el techo del Molino. Se fueron todas juntas, antes del alba, y el valle quedó tan callado como el Molino. El verano se terminó. Vos seguís acá.*
> *Contás a los tuyos.*

#### Sueltas al final

| Estado | Línea |
| --- | --- |
| Leal (general) | *"[Criatura] sigue a tu lado. Si mañana caés, sabés quién te va a llevar a casa."* |
| Leal, Rodauva | *"La Rodauva duerme pegada a tus botas. Ya no se enrolla cuando hablás fuerte."* |
| Leal, compañera inicial | *"La Rodauva del Molino sigue durmiendo junto a la piedra del fuego. Ahora te deja el lado de adentro."* |
| Leal, Surcón | *"El Surcón ronca en la hondonada que cavó junto al fuego. Cuando te movés, abre un ojo."* |
| Leal, Ocarra | *"La Ocarra te grazna a la mañana, como todos los días. Ahora sabés que es un saludo."* |
| Leal, Zancajunco | *"El Zancajunco se queda quieto a tu lado. No mira el agua: te mira a vos."* |
| Neutral | *"[Criatura] sigue con vos. No te debe nada, y vos a ella tampoco. Todavía."* |
| Dudosa | *"[Criatura] come de tu mano, pero no se acerca a dormir."* |
| Desleal | *"[Criatura] sigue acá porque el hilo la ata. Si se cortara, no sabés para qué lado iría."* |

#### Guardadas al final

> *"[Criatura] duerme en su pergamino. Para ella, todavía es el día [N]: el día en que la guardaste."*

Sale del lore del pergamino (2.5): adentro no pasa el tiempo. Necesita el día en que se guardó por última vez.

#### Perdidas

| Causa | Línea |
| --- | --- |
| Comida | *"Día [N]. [Criatura] te dio de comer. No fue su decisión."* |
| Comida, compañera inicial | *"Día [N]. La Rodauva del Molino, la que estaba antes que vos. Te dio de comer. No fue su decisión."* |
| Comida, tras atacarte (variante opcional) | *"Día [N]. [Criatura] te atacó una noche, y te la comiste. Nadie dijo nada."* |
| Abandono | *"Día [N]. [Criatura] se fue de noche. Su pergamino ardió solo. Ahora vive en algún lugar del valle, y no te conoce."* |
| Abandono, tras atacarte (la atacante que se fue, 4.6; flag "fue atacante", `Sistema.md` 13) — `PROPUESTA` | *"Día [N]. [Criatura] te atacó una noche y se fue mientras no podías mirar. Su pergamino ardió solo."* |
| Muerte en combate | *"Día [N]. [Criatura] cayó peleando y quedó atrás. Contaste su ceniza."* |
| Hambre | *"Día [N]. [Criatura] se murió de hambre. El valle tenía comida; no alcanzó para todos."* |
| Hambre, Surcón | *"Día [N]. El Surcón se enterró a dormir el hambre y no despertó."* |
| Perdonada | *"Día [N]. [Criatura] te atacó una noche, y la dejaste ir. Su pergamino ardió; ella no."* |

#### Cierre

> *"[N] rayas en la viga. Las del granero de Almiar llegaron a cuarenta y una."*
> *"Sobreviviste al verano. Lo que venga, lo vas a enfrentar con los que quedaron."*

| Variante | Segunda línea |
| --- | --- |
| No queda ninguna criatura de la tribu, ni suelta ni guardada | *"Sobreviviste al verano. Solo."* |
| Solo quedan guardadas (ninguna suelta, al menos una guardada) — `DECIDIDO` | *"Sobreviviste al verano. Los tuyos duermen en sus pergaminos: para ellos, el verano todavía no terminó."* |

Ambas variantes son **hechos, no umbrales** (`Sistema.md` 13). La de "solo guardadas" responde al riesgo ⚠️ de guardar a toda la tribu los últimos días (`Sistema.md` 14): no culpa, pero muestra que nadie llegó despierto al final.

[N] sale del dato de duración (los primeros playtests pueden usar 20 días), nunca de un valor fijo.

#### Permadeath

Pantalla final cuando nadie rescata al Maestro: *"Nadie te llevó a casa."*

Si el Maestro muere de hambre (`DECIDIDO`; es permadeath directo, sin rescate, `Sistema.md` 7.6): *"Te acostaste con hambre y no te levantaste."* La línea del rescate culparía a la tribu de algo que no pudo evitar.

### 4.12 Comerse una criatura — `DECIDIDO`

**Cuándo:** solo en el **reparto de la noche, junto al fuego**, con la tribu mirando (Visión 6.5), y solo a una criatura **suelta** (`Sistema.md` 7.7, v1.4). La decisión se toma junto al fuego; el acto se elide ("lo hacés lejos del fuego"). La única otra salida es comer a la atacante nocturna (4.6). Una caída de un combate ganado se levanta y nunca se ofrece como carne.

**Criterio:** la tribu es la cámara (1.3). El acto nunca se describe y la criatura comida casi no aparece. Las guardadas no lo ven: el pergamino las deja fuera del tiempo (2.5), y ese es el contraste más duro. Reglas en `Sistema.md` 5.2 y 7.7.

#### Antes: la decisión

| Momento | Texto |
| --- | --- |
| Al abrir la opción | *"Mirás a los tuyos. Alguno de ellos también te está mirando."* |
| Elegir a la criatura | *"¿[Criatura]?"* |
| Tooltip | *"Da [N] raciones de carne. Su pergamino arde. Las sueltas pierden confianza, y más las que se llevaban bien con ella. Nunca te hace crecer."* |
| Aviso de rescatista perdida | *"Si lo hacés, [Criatura] ya no te va a poder llevar a casa."* (mismo patrón que la subida de nivel, 2.9) |
| Botones | **Hacerlo** · **Todavía no** |
| Cancelar | *"Esta noche no. El hambre sigue ahí."* |

#### El momento

Se arma con una base, de 1 a 3 líneas de testigos y, si corresponde, un cierre.

| Pieza | Texto |
| --- | --- |
| Base | *"Lo hacés lejos del fuego. Su pergamino arde solo, con una llama pálida, y todos lo miran arder."* |
| Base, a partir de la segunda vez | *"Esta vez nadie se sorprende. Eso es peor."* |
| Testigo: Rodauva | *"La Rodauva se enrolla del otro lado del fuego y no se desenrolla en toda la noche."* |
| Testigo: Surcón | *"El Surcón se entierra hasta las orejas. Esta noche no ronca."* |
| Testigo: Ocarra | *"La Ocarra no grazna. Te sigue con un ojo, de costado, como a algo que se metió en el corral."* |
| Testigo: Zancajunco (come con el Maestro) | *"El Zancajunco se acerca al fuego y come con vos. No te mira: mira la carne. Los demás lo miran a él."* |
| Testigo afín de la comida | *"[Criatura] se queda mirando el lugar donde dormía [comida]."* |
| Testigo leal | *"[Criatura] no se aparta. Tampoco se acerca."* |
| Famélica que come esa carne | *"[Criatura] come porque no puede no comer. Después se aleja del fuego."* |
| Sin sueltas que lo vean | *"Nadie lo ve. Los pergaminos duermen en la bolsa, y para ellos todavía es otro día."* |
| Era la última de la tribu | *"Ya no queda nadie que te mire."* |
| Cierre: compañera inicial (Molino) | *"Esta noche, la hojarasca junto a la piedra del fuego queda vacía."* |
| Cierre: compañera inicial (al raso) | *"Esta noche nadie duerme del lado de adentro del fuego."* |

**Regla de testigos** (`PROPUESTA` para el Arquitecto): como máximo 3 líneas. Primero las afines de la comida, después el Zancajunco si comió, después el resto por lealtad, de mayor a menor. Una línea por especie. Sin sueltas, "sin testigos".

#### La mañana siguiente

| Momento | Texto |
| --- | --- |
| General | *"Amanece igual que siempre. Los tuyos tardan en acercarse."* |
| El Maestro saciado | *"El hambre se calló. Lo demás, no."* |
| Se perdió una rescatista | *"Anoche, [Criatura] todavía te habría llevado a casa."* |
| Una criatura bajó de estado | *"[Criatura] duerme lejos de vos."* |
| Invocar después a una guardada que no lo vio (opcional) | *"[Criatura] sale del pergamino y busca a [comida] con la vista. Todavía no sabe."* |
| Ofrendar esa carne en el colgadero | *"Dejás en la rama lo que sobró. El colgadero lo recibe igual. Las cuentas del Tasajero no preguntan de dónde viene la carne."* |

La pudrición usa la línea general de carne (3.4). El ataque nocturno (4.6) y el epílogo (4.11) tienen sus propias líneas.

### 4.13 Abandono — `DECIDIDO`

**Criterio:** nadie ve irse a la criatura; queda su rastro, distinto por especie. El Zancajunco es la cara narrativa del abandono, y su huella es la más clara. Reglas en `Sistema.md` 9.1 y 6.2.

| Momento | Texto |
| --- | --- |
| Tooltip del ícono de riesgo (antes de dormir) | *"Famélica y sin vínculo: esta noche puede irse. Guardada no se va, pero tampoco se acerca."* |
| A la mañana, si se fue (general) | *"El lugar donde dormía [Criatura] está frío. En la bolsa, su pergamino es ceniza."* |
| Rastro: Rodauva | *"Hay un camino de hojas revueltas que baja hacia los huertos."* |
| Rastro: Surcón | *"Un surco nuevo sale del campamento y se pierde en la tierra blanda."* |
| Rastro: Ocarra | *"Por primera vez, nadie te grazna al despertar."* |
| Rastro: Zancajunco | *"Hay huellas largas que bajan hacia el río. No vuelven."* |
| Testigo afín (solo texto) | *"[Testigo] se quedó despierta mirando hacia donde se fue."* |
| Sobrevivió al chequeo | *"[Criatura] pasó la noche despierta. Sigue acá."* |
| Recuperación: alguien se fue | *"Entre fiebre y sueño, oís crepitar algo junto al fuego. Cuando podés mirar, el pergamino de [Criatura] es ceniza."* |
| Recuperación: varias se fueron | *"Te despertás y contás la ceniza."* |
| Recuperación: una leal no se movió (solo texto) | *"[Criatura] no se movió de tu lado."* |
| Recuperación: nadie se fue | *"Cuando podés incorporarte, están todos. Te estaban esperando."* |

### 4.14 Camino de confianza y Leal por primera vez — `DECIDIDO`

**Criterio:** cada especie confía a su manera, y el jugador lo ve en la distancia, no en una barra: primero come cuando te vas, después come con vos ahí, al final te espera. Reglas en `Sistema.md` 4.5.

**Etapas:** primera ofrenda · a mitad de camino (la confianza llega a la mitad de lo necesario) · falta poco (una ración favorita la completa) · olvido (bajó por un día sin alimentarla) · acepta el pergamino. Las primeras ofrendas de la Ocarra, el Surcón y el Zancajunco están en sus eventos (4.5).

| Etapa | Rodauva (bajo el manzano) | Ocarra (el corral caído) |
| --- | --- | --- |
| Primera ofrenda | *"Dejás la fruta en el pasto y te alejás. La Rodauva espera a que estés lejos para desenrollarse."* | En el evento (4.5) |
| A mitad de camino | *"Hoy no se enrolla del todo cuando llegás. Un poco, nada más."* | *"Hoy te grazna menos. Todavía te grazna."* |
| Falta poco | *"Hoy viene rodando antes de que dejes la fruta."* | *"Baja del muro antes de que dejes la ración y la come mirándote a vos."* |
| Olvido | *"La Rodauva se enrolla apenas te ve. Se acuerda de que ayer no viniste."* | *"Te grazna desde el muro como el primer día. Ayer no viniste, y la Ocarra lleva la cuenta."* |
| Acepta el pergamino | *"Hoy no espera a que te alejes. Come con el hocico pegado a tu bota. Cuando sacás el pergamino, no se enrolla."* | *"Hoy baja del muro, te pica la bota una vez, para que quede claro, y se queda. Cuando sacás el pergamino, te mira como si hubiera sido idea suya."* |

| Etapa | Surcón (el surco que ronca) | Zancajunco (el juncal) |
| --- | --- | --- |
| Primera ofrenda | En el evento (4.5) | En el evento (4.5) |
| A mitad de camino | *"Hoy el surco llega hasta donde dejás la ración."* | *"Hoy, el junco que parpadea está más cerca de la orilla."* |
| Falta poco | *"Cuando llegás, el montículo deja de roncar y asoma un ojo."* | *"Hoy no finge ser junco: te mira desde el agua, con el cuello en S."* |
| Olvido | *"Durante la noche, el surco se desvió lejos de donde dejabas la comida."* | *"Hoy todos los juncos son juncos. No encontrás cuál te miraba."* |
| Acepta el pergamino | *"Hoy el Surcón te espera despierto, con medio cuerpo afuera. Cuando sacás el pergamino, bosteza. Lo tomás como un sí."* | *"Está parado en la orilla, al lado de la piedra. No se acerca: deja que vos te acerques. El pergamino lo recoge sin que mueva una pata."* |

| Caso | Texto |
| --- | --- |
| Sin pergamino en blanco al completarse | *"Te está esperando. No tenés un pergamino en blanco para ofrecerle."* |
| Rango fuera de la balanza | Reutiliza el sellado: *"El hilo no alcanza a sujetar algo así. Te falta Soplo."* |
| Con una Rodauva de la tribu suelta (solo texto) | *"Tu Rodauva deja una manzana al lado de la tuya. La otra la mira, y esta vez no se enrolla."* |

#### Leal por primera vez

Hito de experiencia (`Sistema.md` 1.4). Varias líneas son la versión temprana de las del epílogo (4.11).

| Criatura | Texto |
| --- | --- |
| General | *"[Criatura] se echa a dormir pegada a vos, como si siempre hubiera sido así."* |
| Rodauva | *"Hoy hablaste fuerte y la Rodauva no se enrolló. Te miró, nada más."* |
| Surcón | *"Esta noche, el Surcón durmió con la cabeza sobre tus botas. Pesa como un costal."* |
| Ocarra | *"La Ocarra te grazna a la mañana. Por primera vez, suena a saludo."* |
| Zancajunco | *"El Zancajunco se quedó quieto a tu lado toda la noche. Esta vez no miraba el agua."* |

**El payoff de la compañera inicial:** la primera vez que alcanza el **umbral de rescate**, la línea del día 1 (4.8) se cierra: *"Si la cuidás, te va a salvar. Ahora sí."* Se dispara con el umbral y no con el estado Leal, porque la promesa del día 1 hablaba del rescate. Si las dos cosas pasan la misma mañana, se muestra solo esta.

### 4.15 Ritmo del día — `DECIDIDO`

**Criterio:** el ritmo se repite 30 veces por partida. Frases cortas, que rotan y nunca se repiten dos días seguidos; lo largo se guarda para la primera vez y para el plazo. Acá vive la calidez del Pilar 4: es la parte del juego donde no pasa nada malo. Reglas en `Sistema.md` 12.1, 12.2, 12.5 y 9.4.

#### Viaje

El cruce entre el Vado y el Robledal tiene sus textos en 4.5 ("leer el río").

| Tramo | Ida (hacia el norte) | Vuelta (hacia el sur) |
| --- | --- | --- |
| Molino ↔ Huertos | *"Subís por el camino viejo de Almiar. Todavía se ven las rodadas de los carros."* | *"Bajás hacia la boca del valle. Desde lejos, la rueda del Molino sigue quieta."* |
| Huertos ↔ Vado | *"Dejás los frutales atrás y seguís el río aguas arriba. El pasto se vuelve junco."* | *"Seguís el río aguas abajo hasta que los juncos vuelven a ser pasto y aparecen los frutales."* |

#### Llegada, quedarse y agotamiento

| Destino | Primera vez | Las demás veces |
| --- | --- | --- |
| Huertos | *"Los frutales de Almiar se cerraron sobre los caminos. Hay más fruta en el suelo de la que nadie podría juntar."* | *"Los Huertos de Almiar. Huele a fruta caída."* |
| Vado | *"El río se abre y se vuelve bajo, lleno de piedras y de juncos. Algo chapotea donde no mirás."* | *"El Vado de los Juncos. El agua sigue en lo suyo."* |
| Robledal | *"Del otro lado del vado, los robles se cierran sobre el camino. Acá la luz llega tarde."* (después, la línea del Tasajero según su estado) | La línea del Tasajero según su estado (4.5) |
| Molino | — | *"Hoy no se junta nada. Esta noche, nadie vigila."* |

| Momento | Texto |
| --- | --- |
| Quedarse | *"Te quedás un día más."* |
| Huertos agotados (2 días o más) | *"Los frutales ya dieron lo que tenían a mano."* |
| Vado agotado | *"Los peces aprendieron dónde te parás."* |
| Robledal agotado | *"El robledal está más callado: las presas se corrieron."* |
| Tooltip del agotamiento | *"Rinde menos cada día seguido. Se recupera si lo dejás descansar."* |

#### Noches

| Momento | Texto |
| --- | --- |
| Molino sin eventos (variante 1) | *"El fuego cruje. Por una noche, nadie cuenta nada."* |
| Molino sin eventos (variante 2) | *"Los tuyos se acomodan alrededor del fuego, cada uno en su lugar."* |
| Molino sin eventos (variante 3) | *"Dormís con la espalda contra la piedra del fuego. Afuera, el río pasa de largo."* |
| Molino, con la compañera suelta | *"La Rodauva del Molino ya está en su hojarasca cuando llegás."* |
| Armar campamento: Huertos | *"Acampás entre los frutales, de espaldas a una pared de Almiar."* |
| Armar campamento: Vado | *"Acampás en la orilla alta, donde la crecida no llega."* |
| Armar campamento: Robledal | *"Acampás entre raíces de roble. Mirás para arriba antes de acostarte."* |
| Encender el fuego | *"Juntás leña caída. Nada se arranca."* (la misma ley del ritual, 2.6) |
| Tooltip del fuego en el Robledal | *"Acá el fuego se ve desde las ramas."* |
| Sin fuego | *"Dormís a oscuras. Cualquier ruido suena más cerca."* |
| Nombres de las guardias | **Primera guardia** · **Guardia media** · **Guardia del alba** |
| Tooltip: vigila el Maestro | *"Vigilás vos: mañana vas a tener menos maná."* |
| Tooltip: vigila una criatura | *"Esta noche no se cura."* |
| Tooltip: puede dormirse | *"[Guardiana] puede dormirse: todavía no te obedece del todo."* |
| Guardia sin cubrir | *"Nadie cubre la [guardia]."* |
| Noche al raso tranquila | *"La noche pasa. [Guardiana] te despierta para el cambio de guardia, y nada más."* |
| Alba tranquila | *"Amanece sin novedad. [Guardiana del alba] sigue despierta."* |

#### El plazo: rayas y golondrinas

| Momento | Texto |
| --- | --- |
| Primera raya (día 1) | *"Hacés la primera raya en la viga, con carbón del fuego."* |
| Mitad de la partida | *"[N] rayas. La mitad del verano."* |
| Quedan tres días | *"Quedan tres rayas por hacer."* |
| Último día | *"Hoy hacés la última raya."* |
| Golondrinas, etapa 1 | *"Un par de golondrinas entra y sale del techo del Molino."* |
| Golondrinas, etapa 2 | *"Ya son varias en las vigas. Gritan todas las mañanas."* |
| Golondrinas, etapa 3 | *"El techo está lleno de golondrinas. Se posan juntas, mirando al sur."* |
| Golondrinas, etapa 4 | *"Las golondrinas casi no salen. Parece que esperan algo."* |

Las golondrinas solo se ven al llegar o despertar en el Molino. Su partida es la apertura del epílogo (4.11).

## 5. Criaturas del MVP — `DECIDIDO`

El MVP tiene 5 criaturas (2 de trabajo, 2 de combate, 1 mixta): 4 reclutables y el **Tasajero** como encuentro aspiracional de rango 3. Los momentos oscuros son la **cara narrativa de reglas generales** (abandono, ataque nocturno, muerte por hambre), no reglas propias de cada criatura.

Cada ficha incluye la **prenda** que da para el ritual (2.6) y su **defecto de naturaleza**, que es la base de la Mudanza (Ideas en espera, sección 8). La hipótesis de legados de cada una (capa futura) está en 2.10.

### Rodauva

- **Concepto (1 línea):** erizo de huerto que rueda bajo los frutales y se lleva la fruta clavada en las púas (imagen de los bestiarios medievales).
- **Rango:** 1.
- **Hábitat:** huertos abandonados y bordes de campo; duerme en montones de hojarasca. Avistamiento: **bajo el manzano**, en los Huertos (4.5).
- **Compañera inicial:** la del Molino Callado (ver 4.8).
- **Comportamiento y temperamento:** tímido, curioso y acumulador; se enrolla ante cualquier ruido fuerte. Cuando confía, sigue al Maestro pegado a los talones.
- **Dieta:** Favorita: **fruta** · Acepta: grano, bichos · Rechaza: carne, pescado, hongos, raíces. Come poco.
- **Rol:** trabajo.
- **Rasgo de combate:** **Erizarse** (acción). Se cierra en una bola tensa con las púas paradas.
- **Se lleva bien con:** Surcón, otras Rodauvas (en otoño duermen juntas en la misma hojarasca) · **Se lleva mal con:** Tasajero (lo caza).
- **Qué hace fuera del combate:** recolecta fruta extra en nodos de huerto y carga objetos chicos en el lomo.
- **Cómo se consigue mejor:** domesticación, con fruta. En combate se eriza y cuesta debilitarlo sin lastimarlo de más.
- **Prenda:** una púa.
- **Defecto de naturaleza:** la cobardía.
- **Descripción visual:** bola de púas pardas del tamaño de un gato, con frutas de colores clavadas (variables entre individuos). Hocico rosado, ojos grandes. Muy simétrico. Reposo: olfatea. Movimiento: rueda. Erizada: bola tensa, púas paradas, quieta. Acobardada: bola floja, temblando, con el hocico asomando. **Las dos tienen que distinguirse por la silueta, no solo por el color.**
- **Momento oscuro posible:** con hambre se come la fruta que carga, y la cosecha se achica en el camino. Es la criatura más chica y tierna del grupo: la primera que el jugador va a mirar cuando el hambre apriete.

### Surcón

- **Concepto (1 línea):** excavador pesado y dormilón con un hocico de hueso en forma de reja de arado que deja surcos por donde camina.
- **Rango:** 2.
- **Hábitat:** tierra blanda de la orilla del río, en el Vado de los Juncos. Avistamiento: **el surco que ronca** (4.5).
- **Comportamiento y temperamento:** plácido y terco, le cuesta arrancar. No pelea salvo acorralado. Duerme mucho, a veces medio enterrado.
- **Dieta:** Favorita: **raíces** · Acepta: bichos, hongos, grano · Rechaza: carne, pescado, fruta. Come mucho.
- **Rol:** trabajo. En combate pega poco y aguanta mucho, pero su valor es **cerrar el paso**: se planta detrás de sus surcos y obliga al enemigo a dar la vuelta.
- **Rasgo de combate:** **Arar** *(nombre `PROPUESTA`, 1.2.1; provisorio: el surco)* (activa). Hunde la reja del hocico y abre un surco en la casilla de al lado. La tierra removida es su casa: solo un Surcón, de cualquier bando, puede pisarla; para las demás patas es un pozo blando que hay que rodear. No tapa la vista: se puede pegar por encima. Arar le lleva el turno entero. Reemplaza a Lomo de tierra (v1.1).
- **Se lleva bien con:** Ocarra, Rodauva · **Se lleva mal con:** nadie. Con otro Surcón, sin relación: no busca compañía.
- **Qué hace fuera del combate:** desentierra raíces en nodos de tierra.
- **Cómo se consigue mejor:** domesticación. En combate aguanta tanto que debilitarlo es un desgaste, y salvaje ara hacia vos para cerrarte el paso. Sellarlo deshace sus surcos.
- **Prenda:** un puñado de pelo color tierra.
- **Defecto de naturaleza:** el letargo.
- **Descripción visual:** cuerpo bajo y ancho como un tonel echado; pelaje corto color tierra mojada; patas delanteras cortas y anchas; hocico de hueso pálido en punta de reja; ojitos casi cerrados; siempre con terrones pegados. **Arando:** hocico hundido hasta los ojos, lomo arqueado, terrones saltando a los dos lados. **El surco** (casilla): tierra oscura recién removida, con un lomo de terrones a cada costado y el fondo húmedo; simétrico y sin brillo, que se lea como pozo y no como muro.
- **Momento oscuro posible:** con hambre se entierra y entra en letargo. Si el letargo dura demasiado, no despierta: es la **cara narrativa de la muerte por hambre**.

### Ocarra

- **Concepto (1 línea):** ave de corral asilvestrada, guardiana de los huertos, con un pico ganchudo que usa como alabarda.
- **Rango:** 1.
- **Hábitat:** huertos, orillas y ruinas de Almiar. Avistamiento: **el corral caído**, en los Huertos (4.5).
- **Comportamiento y temperamento:** territorial, ruidosa, valiente de más. Ataca primero y pregunta después. Leal, pero a los gritos. No vuela.
- **Dieta:** Favorita: **grano** · Acepta: bichos, fruta, raíces, pescado · Rechaza: carne, hongos. Come poco. Es la más fácil de alimentar: su costo es el carácter, no la comida.
- **Rol:** combate.
- **Rasgo de combate:** **Alabarda**. Su pico ganchudo alcanza a dos casillas.
- **Se lleva bien con:** Surcón (lo sigue para comerse las lombrices que desentierra) · **Se lleva mal con:** Tasajero (enemigo natural), Zancajunco (le espanta la pesca), otras Ocarras (dos Ocarras en un mismo huerto se pelean el corral).
- **Qué hace fuera del combate:** centinela; de noche da la alarma.
- **Cómo se consigue mejor:** combate. Respeta la fuerza; domesticada, igual te va a picotear.
- **Prenda:** una pluma de muda (nunca sirve de péñola).
- **Defecto de naturaleza:** la impulsividad.
- **Descripción visual:** ave grande de cuello largo, blanco sucio con remates gris pizarra, patas naranjas enormes. Pico largo terminado en gancho óseo; cresta corta y dura como un yelmo. Exagerar pico-alabarda y cresta-yelmo para que no se lea como un ganso común.
- **Momento oscuro posible:** con hambre le roba la ración a las más chicas (primero a Rodauva). Famélica y desleal, es la **cara más creíble del ataque nocturno**: se vuelve contra quien tenga comida, incluido el Maestro.

### Zancajunco

- **Concepto (1 línea):** cazador del vado con patas de zancos y lomo de juncos, que se queda inmóvil hasta confundirse con el juncal.
- **Rango:** 2.
- **Hábitat:** el vado y los juncales del río. Avistamiento: **algo se movió en el juncal** (4.5).
- **Comportamiento y temperamento:** paciente, solitario y arisco. Prefiere huir; si ataca, lo hace primero y rápido. Tolera al Maestro, nunca del todo.
- **Dieta:** Favorita: **pescado** · Acepta: bichos, **carne** · Rechaza: fruta, raíces, grano, hongos. Apetito medio.
- **Rol:** mixto (pesca + emboscada).
- **Rasgo de combate:** **Hacerse junco** (activa desde la v1.1). Se queda tan quieto que el ojo lo cuenta como un junco más: queda **hecho junco** *(estado `PROPUESTA`, 1.2.1; provisorio: oculto)* y nadie puede elegirlo como blanco, aunque se lo vea en el tablero. Su próximo golpe sale de la quietud: la **embestida** *(`PROPUESTA`, 1.2.1)*. Se destapa si se mueve, si ataca o si alguien se le planta al lado (por los lados, no en diagonal). Su paciencia no da para dos turnos seguidos.
- **Se lleva bien con:** Tasajero (cazadores silenciosos que comen lo mismo y se respetan) · **Se lleva mal con:** Ocarra. Con otro Zancajunco, sin relación: cada uno tiene su vado.
- **Qué hace fuera del combate:** pesca en nodos de agua.
- **Cómo se consigue mejor:** combate, si lográs sorprenderlo: hecho junco, el hilo no lo encuentra, y hay que destaparlo antes de sellarlo. La domesticación es posible pero lenta.
- **Prenda:** una hoja de junco.
- **Defecto de naturaleza:** la ariscura.
- **Descripción visual:** alto y flaco, patas larguísimas, cuerpo cubierto de hojas de junco verdes y ocres como un fardo, cuello en S, mandíbula larga y fina. Ojo: por su altura puede tapar casillas en isométrico. **Hecho junco:** cuello recogido en vertical, patas juntas, hojas del lomo erguidas: la silueta de una mata de juncos, con el ojo apenas visible. **Con la embestida pendiente:** cuello en S tenso, como una rama doblada antes de soltarse. Las tres posturas se distinguen por la silueta, no solo por el color.
- **Momento oscuro posible:** con hambre se va de noche a pescar y no siempre vuelve: es la **cara narrativa del abandono nocturno**. Si el Maestro se come a una criatura, el Zancajunco es **el único que puede compartir esa carne sin estar famélico**. Lo hace sin dudar, y el resto de la tribu lo ve.

### Tasajero

- **Concepto (1 línea):** depredador del robledal que cuelga a sus presas en las ramas y lleva la cuenta de cada despensa.
- **Rango:** 3.
- **Hábitat:** el Robledal Hondo; marca territorio con colgaderos.
- **Comportamiento y temperamento:** calculador, previsor, silencioso. No caza por hambre sino para guardar. Es quien mejor sobrevive a una hambruna, porque siempre tiene algo guardado.
- **Dieta:** Favorita y única: **carne** · Rechaza: todo lo demás. Come mucho.
- **Rol:** combate.
- **Rasgo de combate:** **Caza y cuenta** (reescrito en la v1.1). Un turno por ronda, en dos modos. Empieza **cazando**: se expone, reparte dos zarpazos (a una presa o a dos) y recibe más daño. Cuando la cuenta ya no le cierra (herido hasta la mitad), deja de cazar y **cuenta**: pica una vez, más flojo, y se aparta a cuidar lo que le queda. No vuelve a cazar en ese combate. En la cola y en su ficha, el modo se lee **Caza** o **Cuenta**. *El Tasajero desgasta, no ejecuta* (Visión 6.2): por eso prefiere dos presas a una. Las encuentra en los **huecos** de la formación (la esquina entre dos aliadas en diagonal); una tribu en bloque no le deja ninguna, pero pega con menos golpes (`Sistema.md` 11.2.3 v1.6).
- **Se lleva bien con:** Zancajunco · **Se lleva mal con:** Rodauva (su presa), Ocarra.
- **Qué hace fuera del combate:** en el MVP, nada (no es reclutable). La despensa queda en Ideas en espera.
- **Cómo se consigue mejor:** **en el MVP no se sella ni se domestica.** Es el encuentro de combate del Robledal y se lo **apacigua** con ofrendas en el colgadero. Meta aspiracional para capas futuras.
- **Prenda y defecto de naturaleza:** se definen cuando sea reclutable.
- **Descripción visual:** marta del tamaño de un lobo chico, cuerpo largo y bajo, pelaje castaño oscuro con antifaz claro, collar de pelo erizado, cola gruesa, garras curvas como ganchos de carnicero. Silueta horizontal. **Caza:** pegado al suelo, cuello estirado, collar erizado, cola recta: la silueta más larga del juego. **Cuenta:** más alto y recogido, collar plano, cola enroscada alrededor de las patas, la cabeza girando: una silueta corta. Los dos modos se distinguen por la silueta, como la Rodauva erizada y la acobardada.
- **Momento oscuro posible:** en el MVP, ninguno propio: es el peligro, no el compañero. Su colgadero lleno es la imagen de lo que el jugador no tiene, una despensa que solo se toca pagando. (La despensa famélica pasa a Ideas en espera, sección 8.)

### Reacciones de Encono y cobardía — `DECIDIDO`

Las criaturas de **combate** y **mixtas** se enconan ante una rival enemiga; las de **trabajo** se acobardan (regla general por rol, ver `Sistema.md` 10.6).

| Criatura | Rival | Regla | Reacción |
| --- | --- | --- | --- |
| Ocarra | Zancajunco | Encono | Baja el cuello como una lanza en ristre y carga graznando |
| Ocarra | Tasajero | Encono | Se le eriza la cresta-yelmo y golpea el suelo con el pico antes de cada ataque |
| Zancajunco | Ocarra | Encono | Deja de fingir que es junco: rompe la quietud de golpe y estira el cuello |
| Tasajero (salvaje) | Rodauva u Ocarra | Encono | Ignora a todos los demás y va directo, como quien busca algo que ya es suyo |
| Rodauva | Tasajero | **Cobardía** | Se enrolla y tiembla; no se acerca a su rival. Si su obediencia la sostiene, se desenrolla y se queda |

> Reemplaza al "encono de presa" de la v0.2.
>
> Un Zancajunco **hecho junco** no cuenta como rival a su alcance: no dispara Encono ni cobardía hasta que se destapa (`Sistema.md` 10.5). En el mundo, nadie se ensaña con un junco.
>
> La cobardía la sostienen el Maestro y las afines **vecinas**, también en diagonal (`Sistema.md` 10.6 v1.6). En el mundo: a la Rodauva la calma sentir a los suyos cerca, no verlos de frente. Por eso sus líneas de resistir dicen *"cerca"* y no *"al lado"* (`cobardia.resiste.afin`: *"Se queda porque tiene a [afín] cerca."* · `cobardia.resiste.maestro`: *"Se queda porque estás cerca."*). Desde T44, el evento trae quién la sostuvo (`sostenida_por`, `Arquitectura.md` A.7) y las dos líneas se ven.

### Incidentes entre rivales aliadas — `DECIDIDO`

Regla en `Sistema.md` 10.4 (v1.6): una criatura **vecina** de su rival aliada (las 8 casillas, también en diagonal) puede tener un incidente. Con obediencia alta se distrae; con obediencia baja ataca a su rival **si la alcanza desde su casilla**, y si no, se distrae igual. Las únicas rivales que pueden estar en la misma tribu son Ocarra–Zancajunco y Ocarra–Ocarra.

| Caso | Distraída | Ataca a su rival |
| --- | --- | --- |
| General | *"[Criatura] no le saca el ojo a [rival]. Se le va el turno mirándola."* | *"[Criatura] se olvida del enemigo y se le tira encima a [rival]."* |
| Ocarra → Zancajunco | *"La Ocarra le grazna al Zancajunco por encima del hombro y se olvida de la pelea."* | *"La Ocarra le tira un picotazo al Zancajunco. Hace rato que tenía ganas."* |
| Zancajunco → Ocarra | *"El Zancajunco se queda tieso, esperando que la Ocarra se calle. No se calla."* | *"El Zancajunco rompe la quietud, pero no contra el enemigo."* |
| Ocarra → Ocarra | *"Las dos Ocarras se miran cresta contra cresta. Ninguna baja la vista."* | *"Una Ocarra le pica la cresta a la otra. Se pelean el corral, aunque acá no haya corral."* |

> La línea "Distraída" ya cubre a la rival en diagonal que no se alcanza: los textos no cambian.

### Rasgos de combate: nombres — `DECIDIDO`

Nombres y rasgos aprobados (Visión 6.2; reglas en `Sistema.md` 11.2).

| Criatura | Nombre provisorio | Nombre final | Por qué |
| --- | --- | --- | --- |
| Rodauva | Enrollarse | **Erizarse** | "Enrollarse" ya es la imagen de la cobardía. La defensa elegida y el miedo no pueden verse igual |
| Surcón | Lomo de tierra → el surco | **Arar** *(`PROPUESTA`, 1.2.1)* | Lomo de tierra sale en la v1.1 (Visión 6.2): era pasiva y no se notaba. La activa nueva nombra lo que hace, como un botón |
| Ocarra | Pico-alabarda | **Alabarda** | Más corto para la interfaz; la alabarda es un arma de alcance |
| Zancajunco | Emboscada | **Hacerse junco** | El golpe sale de la quietud; conecta con su texto de Encono. Desde la v1.1 es activa y deja al Zancajunco **hecho junco** |
| Tasajero | Dos turnos por ronda | **Caza y cuenta** | Desde la v1.1 nombra dos modos y no dos turnos: primero caza, después cuenta, y no vuelve |

### Huida, caída y rescate — `DECIDIDO`

Criterio: la caída **respira** (el jugador tiene que saber que todavía hay algo que salvar), la huida **no culpa** y quedar atrás es **sobrio**, sin gore.

#### Salvaje que huye a 0 de vida

Tooltip general: *"Se fue. Ya no se puede sellar."*

**Temperamento de huida** — confirmado: los porcentajes de `Sistema.md` 11.7 coinciden con las fichas. Rodauva, tímida, huye rodando · Surcón, no huye por valentía sino por inercia · Ocarra no huye nunca (su huida a 0 es "ofendida") · Zancajunco prefiere huir · Tasajero no huye: "se va a pensar".

| Criatura | Línea |
| --- | --- |
| Rodauva | *"Se hace bola y rueda cuesta abajo. Deja una manzana en el camino."* |
| Surcón | *"Se mete a medias en la tierra y se va abriendo un surco, sin apuro."* |
| Ocarra | *"Se aleja a los graznidos, ofendida, sin darte del todo la espalda."* |
| Zancajunco | *"Dos zancadas, y el juncal se lo traga. Después no se mueve ni una hoja."* |
| Tasajero | *"Retrocede sin dejar de mirarte. No huye: se va a pensar."* |

> Derrotar al Tasajero baja su hostilidad en 1 y no vuelve en lo que queda de la visita (`Sistema.md` 12.10).
> La salvaje que **huye en su turno** (T25) usa las mismas líneas; antes de que le toque, su riesgo se ve con `marca.huida` y `huida.salvaje.porcentaje` (1.5, v1.4). **Si tira y se queda** (v1.5): *"[Criatura] mira hacia el borde del claro, pero se queda."* (`huida.salvaje.se_queda`).

#### Criatura de la tribu caída

Base: *"[Criatura] cae y no se levanta. Todavía respira."*

| Criatura | Línea |
| --- | --- |
| Rodauva | *"Queda hecha bola, quieta. Las frutas se le cayeron de las púas."* |
| Surcón | *"Se derrumba de costado, como un tonel. Resopla."* |
| Ocarra | *"Cae con el cuello estirado. Sigue graznando, bajito."* |
| Zancajunco | *"Se dobla sobre las patas como un junco quebrado. Todavía te mira."* |

Al ganar el combate: *"[Criatura] se levanta. Despacio, pero se levanta."*

#### Guardar a una caída

*"Tendés el pergamino hacia [caída]. El hilo la encuentra donde cayó y la recoge."*
Tooltip: *"Guardada con lo justo para respirar. No se cura hasta que salga."* (v1.3: sin número, por la escala ×10)

#### Huida del Maestro

| Momento | Texto |
| --- | --- |
| Al declararla | *"Retrocedés. Hasta que salgas del claro, todavía te pueden alcanzar."* |
| Sin caídas | *"Se van sin mirar atrás. El día queda a medias."* |
| Con caídas en el tablero | *"Al cruzar el claro, mirás atrás una vez. [Caída] sigue donde cayó."* |
| Esa noche | *"Uno de los pergaminos se enciende solo, con una llama pálida que no calienta."* (sirve en el Molino y al raso, con o sin fuego) |

La previsualización antes de declarar y la marca "Huyendo" están en 1.5 (v1.4). Desde la v1.5, la previsualización también nombra a las caídas que quedarían atrás (`huida.previa.caidas`).

#### El rescate

| Rescatista | Línea |
| --- | --- |
| Rodauva | *"Es la mitad de tu tamaño. Te tira de la manga con los dientes, un palmo por vez, toda la noche."* |
| Surcón | *"Te carga en el lomo como a un costal. No se apura. No se detiene."* |
| Ocarra | *"Te arrastra del cuello de la ropa con el pico y le grazna a todo lo que se acerca."* |
| Zancajunco | *"Te arrastra de la capa entre las patas largas, mirando hacia atrás a cada paso."* |

> En combate, antes de caer, el jugador ya sabe quién lo llevaría: la marca **Rescatista** sobre la ficha y la línea del panel (1.5, v1.5). En la pantalla de resultado, *"Te llevó a casa: [criatura]"* va seguida de su línea de esta tabla.

#### Las caídas que quedan atrás

> *"Por encima del lomo de [rescatista] ves cómo el claro se achica. [Caída] sigue ahí. No te alcanzan las manos para nada."*
>
> **Al despertar en el Molino:** *"Sobre la piedra del fuego hay ceniza que antes no estaba. Es la del pergamino de [caída]."*

| Variante | Línea (solo texto) |
| --- | --- |
| Rescatista y caída eran afines | *"[Rescatista] se detuvo una vez y miró hacia atrás. Después siguió tirando."* |
| Varias caídas | *"Despertás y contás la ceniza."* |

La imagen del Pilar 4 ("la tribu lo ve arder") se cumple sin mostrar la muerte.

### Textos de combate de la 0a — `DECIDIDO`

Momentos que muestran los hitos 0a.1 a 0a.3 (`Arquitectura.md` B.2 a B.4) y que no tenían texto. Las claves son las de `juego/datos/textos/es.json` (1.5). Los tooltips describen sin números: los valores viven en `Sistema.md`.

#### Sellado (T24)

| Momento | Clave | Texto |
| --- | --- | --- |
| Tooltip previo | `sellar.tooltip` | *"[X]% de que el hilo la sujete. Si se suelta, el maná se pierde igual."* |
| Éxito | `sellar.exito` | *"El hilo la encuentra y se tensa. [Criatura] se achica hasta caber en el pergamino, y la hoja deja de estar en blanco."* |
| Fallo (general) | `sellar.fallo` | *"El hilo la roza y se suelta. El maná ya se fue."* |
| Fallo: Rodauva erizada | `sellar.fallo.erizada` | *"El hilo resbala entre las púas."* |
| Fallo: Surcón | `sellar.fallo.surcon` | *"El hilo se le enreda en los terrones y se cae con ellos."* |
| Fallo: Ocarra | `sellar.fallo.ocarra` | *"La Ocarra se sacude el hilo como si fuera agua y te grazna."* |
| Fallo: Zancajunco | `sellar.fallo.zancajunco` | *"El hilo agarra un puñado de juncos. El Zancajunco no estaba adentro."* |
| Rango fuera de la balanza | `sellar.rango_alto` | *"El hilo no alcanza a sujetar algo así. Te falta Soplo."* |
| Sin pergamino en blanco | `pergamino.sin_blanco` | Compartido con 4.6 |

La salvaje que **huye en su turno** reutiliza las líneas de "Salvaje que huye a 0 de vida". Los avisos del botón Sellar están en 1.5 (v1.4). En la pantalla de resultado, las selladas se listan bajo *"Se sumaron a la tribu"* (`resultado.capturas`, v1.5).

#### Encono y cobardía en el registro (T19)

Las reacciones por par de rivales (tabla de Encono y cobardía) sirven como línea de registro. Estas son las generales y las de resistir. Los tooltips de probabilidad están en 1.5 (v1.2).

| Momento | Clave | Texto |
| --- | --- | --- |
| Encono (general) | `encono.inicio` | *"[Criatura] se encona con [rival]. Ya no ve otra cosa."* |
| Sube el contador | `encono.sube` | *"El encono de [Criatura] crece."* |
| Cobardía (general) | `cobardia.inicio` | *"[Criatura] ve a [rival] y se le va el coraje."* |
| Cobardía: Rodauva | `cobardia.rodauva` | *"La Rodauva se hace bola. Tiembla."* |
| Resiste (general) | `cobardia.resiste` | *"[Criatura] tiembla, pero se queda."* |
| Resiste: Rodauva | `cobardia.resiste.rodauva` | *"La Rodauva se desenrolla. Le tiemblan las púas, pero se queda."* |
| Resiste por una afín vecina (toggle del escenario E) | `cobardia.resiste.afin` | *"Se queda porque tiene a [afín] cerca."* (v1.2) |
| Resiste con el Maestro vecino | `cobardia.resiste.maestro` | *"Se queda porque estás cerca."* (v1.2) |

> Desde T44 se muestran según `sostenida_por` del evento `chequeo_rival` (`Arquitectura.md` A.7): `maestro` → la del Maestro; `afin` → la de la afín; `null` → la general.

#### Tooltips de los rasgos (T08, T09, T13; reescritos en la v1.1)

Los de Arar, Hacerse junco y Caza y cuenta son `PROPUESTA` (v1.1). Se retiraron `rasgo.lomo_de_tierra.nombre` y `rasgo.lomo_de_tierra.tooltip`: un texto equivocado engaña más que un `[FALTA]`.

| Rasgo | Clave | Tooltip |
| --- | --- | --- |
| Erizarse | `rasgo.erizarse.tooltip` | *"Hecha bola, los golpes le entran a medias. Hasta su próximo turno, no se mueve."* |
| Arar | `rasgo.surco.nombre` · `rasgo.surco.tooltip` | *"Abre un surco en una casilla de al lado. Solo un Surcón pisa la tierra removida: para las demás es un pozo que hay que rodear. No tapa la vista. Arar le lleva el turno entero; si abre uno de más, se cierra el más viejo."* |
| Alabarda | `rasgo.alabarda.tooltip` | *"El gancho del pico llega a dos casillas."* |
| Hacerse junco | `rasgo.hacerse_junco.tooltip` | *"Quieto, es un junco más: nadie puede elegirlo como blanco, y su próximo golpe pega más fuerte. Se destapa si se mueve, si ataca o si alguien se le planta al lado. No dos turnos seguidos."* |
| Caza y cuenta | `rasgo.caza_y_cuenta.tooltip` | *"Empieza cazando: dos zarpazos por turno, a una presa o a dos, y recibe más daño. Herido, pasa a contar: pica una vez, más flojo, y se aparta. No vuelve a cazar."* |

#### Rasgos en acción: sucesos, marcas y avisos (hito 0a.1b, T37 a T40) — `PROPUESTA`

"Un rasgo que no se ve no existe" (Visión 6.2). Claves confirmadas por el Arquitecto (`Arquitectura.md` 10.5), incluida `suceso.oculto` (aceptada el 06/10/2026). Los sucesos de un solo dueño posible (el Surcón, el Zancajunco, el Tasajero) van **sin hueco**: con dos de la misma especie, la ficha marcada en el tablero dice cuál fue (mismo criterio que la Centinela, 4.6).

| Momento | Clave | Texto |
| --- | --- | --- |
| Botón de la activa del Surcón | `accion.cavar` | Arar |
| Un surco nuevo | `suceso.surco.cavar` | *"El Surcón hunde la reja y abre un surco."* |
| Un surco que se cierra | `suceso.surco.cerrar` | *"Un surco se desmorona. La tierra vuelve a asentarse."* |
| El Zancajunco se oculta | `suceso.oculto` | *"El Zancajunco se queda quieto. Ya no se lo distingue de los juncos."* |
| Marcas sobre el Zancajunco | `marca.oculto` · `marca.bono` | Hecho junco · Embestida |
| Se destapa al moverse (conserva el bono) | `suceso.destape.mover` | *"El Zancajunco deja de ser junco y avanza. La embestida sigue en pie."* |
| Se destapa al atacar | `suceso.destape.atacar` | *"El junco era el Zancajunco. El golpe sale de la quietud."* |
| Se destapa por contacto | `suceso.destape.contacto` | *"Alguien se le plantó al lado. El Zancajunco deja de fingir que es junco."* |
| Pierde el bono | `suceso.pierde_bono` | *"Le pegaron antes de embestir. El Zancajunco pierde el impulso."* |
| Aviso al mover junto a uno oculto | `aviso.destapar` | *"Pararse acá destapa al Zancajunco, y queda a tiro de su embestida."* |
| Umbral del Tasajero (sobre la unidad) | `aviso.cuenta.umbral` | *"Con {n} de vida o menos, pasa a Cuenta."* |
| El Tasajero pasa a Cuenta | `suceso.cuenta.cambio` | *"El Tasajero deja de cazar. Ahora cuenta lo que le queda."* |

> El destape al atacar no avisa del bono cobrado: ya se ve en el desglose (T40).

#### Secundar, combos, invocar y guardar (T16, T17, T26)

| Momento | Clave | Texto |
| --- | --- | --- |
| Secundar: tooltip | `secundar.tooltip` | *"Actúa justo después de [aliado]. Los enemigos que estaban en el medio actúan antes."* |
| Secundar bloqueado: enconada | `secundar.bloqueo.encono` | *"Enconada, no espera a nadie."* |
| Secundar bloqueado: acobardada | `secundar.bloqueo.cobardia` | *"Asustada, no sigue a nadie."* |
| Eslabón de combo | `combo.eslabon` | *"[Criatura] sigue el golpe de [aliado]."* |
| Eslabón entre afines | `combo.eslabon.afin` | *"[Criatura] y [aliado] ya se conocen el golpe."* |
| Invocar | `invocar` | *"Desenrollás el pergamino. [Criatura] sale parpadeando: para ella, no pasó el tiempo."* |
| Invocar: tooltip | `invocar.tooltip` | *"Llega en la ronda que viene."* |
| Guardar en combate | `guardar` | *"[Criatura] toca el pergamino y el hilo la recoge."* |
| Guardar: tooltip | `guardar.tooltip` | *"A salvo hasta que la saques. Mientras tanto, no gana ni pierde nada."* |

> El texto de invocar sale del lore del pergamino (2.5): enseña, sin tooltip, por qué una guardada no gana lealtad.
> Los combos **no miran la posición** (Visión v1.3): *"ya se conocen el golpe"* habla del vínculo, no de estar pegadas.
> Los avisos de los botones de invocar y de guardar a una caída están en 1.5 (v1.4).

#### Hechizos, hambre y cierre del combate (T10, T14, T22)

| Momento | Clave | Texto |
| --- | --- | --- |
| Lanzadera: choque | `lanzadera.choque` | *"[Unidad] sale despedida y se lleva por delante a [otra]."* |
| Lanzadera: choque contra el borde o un surco (v1.4) | `lanzadera.choque.obstaculo` | *"[Unidad] sale despedida, no tiene adónde ir y se da de lleno."* |
| Hambre de combate (al cerrar las rondas 6, 12…) | `combate.hambre` | *"La pelea se alarga. A los tuyos les empieza a pesar el estómago vacío."* |
| El Maestro cae (antes del rescate) | `maestro.caida` | *"Te fallan las piernas. El suelo está más cerca de lo que pensabas."* |
| Victoria | `combate.victoria` | *"El claro queda en silencio. Se terminó."* |

## 6. Relaciones y ecología — `DECIDIDO`

Hay dos bandos naturales, "la granja" (Rodauva, Surcón, Ocarra) y "lo salvaje" (Zancajunco, Tasajero), y la mejor dupla de combate (Ocarra + Tasajero) se lleva mal: ningún grupo es perfecto (Pilares 2 y 3).

**En el tablero, el vínculo mira 8 y el cuerpo mira 4** (Visión v1.3): las afines se potencian y las rivales chocan también en diagonal; moverse, pegar y esconderse siguen siendo por los lados. Los combos no miran la posición.

### 6.1 Mapa de relaciones

|  | Rodauva | Surcón | Ocarra | Zancajunco | Tasajero |
| --- | --- | --- | --- | --- | --- |
| **Rodauva** | Bien | Bien | · | · | **Mal** |
| **Surcón** | Bien | · | Bien | · | · |
| **Ocarra** | · | Bien | **Mal** | **Mal** | **Mal** |
| **Zancajunco** | · | · | **Mal** | · | Bien |
| **Tasajero** | **Mal** | · | **Mal** | Bien | — |

*(· = sin relación · — = no aplica en el MVP)*

**Misma especie** (la diagonal): puede haber varias criaturas de una misma especie en la tribu. Rodauva–Rodauva **se llevan bien** (manada; base de la Muda colectiva). Ocarra–Ocarra **se llevan mal** (territoriales: una tribu de Ocarras, la criatura más fácil de alimentar, paga su costo en incidentes). Surcón–Surcón y Zancajunco–Zancajunco, **sin relación**. Tasajero–Tasajero no aplica en el MVP.

### 6.2 Cadena alimentaria de Valdelumbre

- **Plantas y frutos** → Rodauva, Surcón, Ocarra.
- **Bichos** → comida de casi todos; nadie pelea por ellos.
- **Peces del río** → Zancajunco (y Ocarra, cuando puede).
- **Presas del robledal** → Tasajero y Zancajunco. Comparten la carne y por eso se respetan.
- **Rodauva y presas chicas** → Tasajero.
- **Tasajero** → no tiene depredador en el valle.
- **La Poza Tibia** → tregua: los animales lastimados se bañan juntos y ninguno molesta a otro. Es solo texto; no suspende las reglas de relaciones.
- **Fauna común** (palomas, peces, presas de caza) → existe como recurso y paisaje, no como criatura capturable.

## 7. Esbozo del resto del mundo — `PREGUNTA ABIERTA`

El resto del mundo se esboza, no se detalla, hasta cerrar el MVP. Lo que falta:

- Dónde aparecen los primeros rastros de los Nueve fuera de Valdelumbre (2.10 deja ideas: el campanario sin badajo de la Campanera).
- Esbozo de los escribas (cuando la economía tenga capa).

Resuelto: los Nueve no definen linajes en el MVP (2.4) · origen de los pergaminos (2.5 y 2.6) · **nombre, oficio y huella de cada uno de los Nueve (v1.4, 2.4 y 2.10)**.

## 8. Ideas en espera

Ideas aprobadas en espíritu, sin mecánica en el MVP.

| Idea | Por qué espera |
| --- | --- |
| **La Mudanza**: cada criatura supera su defecto de naturaleza gracias al vínculo y cambia de forma (detalle en la Visión, sección 10). Defectos confirmados: Rodauva, cobardía · Surcón, letargo · Ocarra, impulsividad · Zancajunco, ariscura | Duplica el costo de arte |
| **La despensa del Tasajero:** si el Maestro cae y el Tasajero está famélico, lo arrastra a su despensa; famélico, también empieza a "guardar" al más débil del grupo. Debe ser un evento del que se puede escapar | El Tasajero no es reclutable en el MVP |
| **La despensa como pasiva:** reserva de comida de emergencia que no se echa a perder | Ídem |
| **El Surcón cava bajo las reservas** del campamento cuando está famélico | Regla propia de criatura; el MVP usa reglas generales |
| **Reencontrar a una criatura que se fue** en su hábitat, ya salvaje | El MVP no guarda individuos |
| **El santuario de escribas:** pergaminos a cambio de monedas | Depende de la economía (Capa 5) |
| **La prenda en el epílogo:** el epílogo nombra quién dio la prenda de cada pergamino. Solo narrativa (Visión 10 v1.2) | Una consecuencia mecánica volvería al ritual una optimización: el ritual duele por la sangre |
| **Los Legados y sus Reveses** (lore en 2.10) | Sistema grande de la Visión 10; espera a que el MVP valide la tribu |

### 8.1 Nombres de las capas futuras — `DECIDIDO` (v1.4)

Responden las preguntas de nombres de la Visión 11. **PARA DIRECTOR CREATIVO:** registrarlos en la Visión 10 y 11.

| Qué | Nombre | Por qué |
| --- | --- | --- |
| Barra de zozobra | **Zozobra** (la barra); **templarse** (superarla); **quebrarse** (aparece el defecto) | La barra es la inquietud; el temple es lo que gana quien la supera |
| La Mudanza | **Mudanza** (se confirma) | Mudar plumas, mudar de casa |
| Pergamino de muda (Muda colectiva) | **El atado** (*un atado de pergaminos*) | Cinco hilos atados en uno |
| Involución | **Torcedura** (*se torció*) | Un árbol torcido sigue siendo el mismo árbol: reconocible y sin estética oscura |
| La subyugación | **El Yugo** | Herramienta de oficio, como los otros hechizos. El Soplo domina por yugo; el Barro guía por vínculo |
| El esbirro | **Uncida** (*uncido*) | *Uncir* = poner al yugo |
| Las órdenes | **La Voz**; la orden puntual, **el Grito** | La voz no es magia: es cuerpo (Barro) |
| Explosión, inversión y extenuada (Legados) | **Desborde**, **darse vuelta** y **molida** | Ver 2.10 |

## 9. Pendientes

**v1.5:** con las 13 claves de 1.5 (T25, T28 y T29), `es.json` cubre todas las claves que el código de la 0a pide hasta T33 (633 claves). Los textos de v1.5 están aprobados por el usuario (15/10/2026). **El Worldbuilder no tiene pendientes que bloqueen el cierre de la 0a ni la 0b.**

### 9.1 Preguntas abiertas de reglas

Todas cerradas.

- [x] ~~¿Se puede comer a una guardada?~~ → No: solo se come a una suelta (`Sistema.md` 7.7, v1.4, opción B). Se retiró `comer.sacar_guardada` (4.12).
- [x] ~~Aviso de rescatistas perdidas antes de comer~~ → Sí (`Sistema.md` 7.7). Texto: `comer.aviso_rescatista`.
- [x] ~~¿Corre el olvido si la confianza se completa sin pergamino en blanco?~~ → Sí (`Sistema.md` 4.5).
- [x] ~~Cortes de las etapas de confianza~~ → Aprobados tal cual (`Sistema.md` 4.5).
- [x] ~~Cortes de las golondrinas~~ → Cuartos de la duración (`Sistema.md` 13).
- [x] ~~¿Las guardadas pierden lealtad cuando se come a una compañera?~~ → No: los eventos de lealtad alcanzan solo a las sueltas (`Sistema.md` 5.2).
- [x] ~~¿Qué pasa con la atacante si el Maestro cae antes de decidir?~~ → Se va, sin cambio de lealtad (Visión 6.4 v1.2). Textos en 4.6 y 4.11.
- [x] ~~¿Cuándo se puede comer a una criatura?~~ → Solo en el reparto de la noche, junto al fuego (Visión v1.0, 6.5; 4.12).
- [x] ~~¿Qué pasa si el Maestro muere de hambre?~~ → Permadeath directo (`Sistema.md` 7.6). Pantalla propia `DECIDIDO` (4.11).

> Las preguntas abiertas de `PREGUNTAS.md` (P-048 a P-052, alarmas de playtest de T33) son de Sistemas y del Arquitecto y no tocan textos.

### 9.2 Derivaciones

**PARA EL USUARIO (aprobación de textos):**

- [x] ~~v1.5: aprobar las 13 claves de 1.5~~ → aprobadas el 15/10/2026, con `panel.rescatista` = *Te lleva a casa*.

**PARA DIRECTOR CREATIVO:**

- [ ] **v1.4:** renombrar **Sombra → Revés** en la Visión (6.1, 6.2, 8, 10 y 11) y registrar en `Decisiones.md` el marco de los nueve oficios de dos manos (2.4 y 2.10). Cierra en la Visión 11: "número final de los Nueve" (9), "nombre final de la barra de zozobra", "nombres finales de la involución, las órdenes, el Grito, la subyugación y el esbirro", "confirmar Intemperie", "nombre del sistema", "quién modeló a las Sombras", las justificaciones de las anulaciones y de la potenciación, "nombres finales de la explosión y de extenuada", "por qué el Maestro tiene afinidad con algunos legados", "los verbos en el lenguaje del mundo" y "la escena de Desapego".
- [ ] **v1.4:** decidir si una criatura puede llevar las dos manos de un mismo oficio (2.10; el lore lo permite).
- [ ] Aprobar los nombres de 1.2.1: **Arar** (el surco), **Hecho junco** (oculto) y **Embestida** (el bono). Ya están en `es.json`. Al aprobarlos, cierran la pregunta "Nombre final del surco del Surcón" de la Visión 11 y sacan el *(provisorio)* de la Visión 6.2 y de `Sistema.md` 11.2.1 y 11.2.2.
- [ ] Decidir si la hostilidad **Cazando** pasa a **Rastreando** (1.2.1). Es 0b: no bloquea.
- [ ] Aprobar los textos nuevos de la v1.1 (pantalla de T13, las que miran, la atacante que se va, la emboscada del Robledal y los rasgos en acción) y de la v1.2 (etiquetas de T14 y T16, tooltips de relaciones y las dos líneas de cobardía) (1.5 y sección 5).
- [ ] Registrar en `Decisiones.md` que las etiquetas de estado concuerdan con el género de la especie, y que las de obediencia no (1.5).
- [ ] Registrar en `Decisiones.md` los textos de T19 a T21 y la regla "ningún texto escribe un número de vida, daño o curación" (1.5), aprobados por el usuario el 08/10/2026.

**PARA SISTEMAS:**

- [ ] **v1.4:** revisar la hipótesis de legados de las 5 criaturas (2.10) contra los perfiles y la rueda; si el mapa de relaciones (6.1) no queda coherente con las anulaciones, avisar: el lore se acomoda.
- [ ] Tachar en `Sistema.md` 15 los pedidos al Worldbuilder ya entregados: los de la v1.1, la v1.6 y los dos de la v1.7 (escala ×10 y claves sin texto de T13 a T21). Queda abierto solo el de los nombres, que espera al Director.
- [ ] Si el Director aprueba **Rastreando**, cambiar el nombre del estado en 12.10.

**PARA ARQUITECTO:**

- [ ] **v1.5:** copiar `es.json` v1.5 a `juego/datos/textos/` (Claude Code no edita esa carpeta). Claves: 620 → 633. La huella de los datos no cambia (excluye `textos/`, A.7). Desaparecen los `[FALTA]` de T25, T28 y T29.
- [ ] **v1.5:** confirmar que `panel.rescatista`, `resultado.rescatista`, `resultado.atacante_pendiente` y los títulos de lista del resultado se arman como "etiqueta: nombre" y no como frase con hueco (1.5). Si alguna lleva hueco, cambia el texto, no la clave.
- [ ] **v1.4:** `huida.salvaje.tooltip` existe y T25 no lo usa. Propuesta: tooltip del suceso de una huida ya ocurrida. Si no tiene lugar, se retira en la v1.6.
- [x] ~~v1.4: copiar `es.json` v1.4~~ → copiado (T30 ya usa `huida.previa.*`).
- [x] ~~v1.4, claves a confirmar `aviso.huir.*` y `huida.previa.*`~~ → confirmadas: T30 adoptó los nombres de 1.5 y retiró los provisorios de T28.
- [x] ~~v1.4, T29: claves de pantalla del rescate~~ → entregadas en la v1.5 (1.5).
- [x] ~~v1.3: copiar `es.json` v1.3~~ → copiado.
- [x] ~~v1.3: quién sostuvo a la que resiste~~ → `sostenida_por` y `afin` en el `chequeo_rival` (T44, P-041).
- [x] ~~Copiar `es.json` v1.2~~ → copiado en la sincronización previa a T41 (`Arquitectura.md` B.3.1).
- [x] ~~Confirmar las claves de los tooltips de relaciones~~ → confirmadas con esos nombres, con `{porcentaje}` (`Arquitectura.md` 10.5, 07/10/2026).
- [x] ~~`panel.cadena.eslabon`~~ → no hizo falta.
- [x] ~~Copiar `es.json` v1.1~~ → copiado en la sincronización previa a T35 (`Arquitectura.md` A.2.1).
- [x] ~~Claves retiradas (`rasgo.lomo_de_tierra.*`, `comer.sacar_guardada`)~~ → retiradas en T35.
- [x] ~~Concordancia de las etiquetas~~ → `DECIDIDO` (A.2.1), programada en T40.
- [x] ~~Claves nuevas propuestas (`suceso.oculto`, `nocturno.atacante.se_fue`, `epilogo.perdida.abandono.atacante`)~~ → aceptadas (`Arquitectura.md` 10.5, 06/10/2026).
- [x] ~~Desglose de 0a.1b~~ → sin claves nuevas: los modos con `iniciativa.*` y el bono con `rasgo.hacerse_junco.nombre` (T40).
- [x] ~~Huecos gramaticales y mayúsculas~~ → `DECIDIDO` (A.2.1, T34). ~~Esquema `textos` con `additionalProperties` como esquema~~ → A.2. ~~Claves de condición~~ → A.2.1. ~~Variante "solo guardadas" en G-03~~ → registrada.

**PARA ARTE / UI:**

- [ ] **v1.5, rescatista:** la marca "Rescatista" sobre la ficha tiene que leerse como una promesa, no como un estado de la criatura (un ícono chico de fuego o de casa junto a la palabra, por ejemplo), y no confundirse con las marcas de Encono o huida.
- [ ] **v1.4, huida:** la marca "Huida" sobre la salvaje con su porcentaje, y "Huyendo" sobre el Maestro que declaró. Que "Huyendo" no se confunda con un estado ya cumplido (un contorno que se apaga, por ejemplo).
- [ ] **v1.4, Lanzadera:** el choque contra el borde o un surco se lee igual que contra una unidad (un golpe seco, sin desplazamiento).
- [ ] **v1.3, escala ×10:** los números de vida y daño llegan a tres cifras (Tasajero, 300). Prever el ancho en la ficha, la cola y el desglose (`Sistema.md` 15 v1.7). Los textos no tienen números de balance: no cambian el ancho.
- [ ] **v1.3, marcas de Encono:** "Enconada" y "Acobardada" sobre la ficha, más el contador "Encono: n/3". Que la acobardada se lea por la silueta (bola floja, sección 5) y no solo por la palabra.
- [ ] **v1.2, tablero de 12 × 12 con cámara móvil:** las posturas que cambian una regla (Rodauva erizada y acobardada, Zancajunco hecho junco y con la embestida, Tasajero en Caza y en Cuenta) se tienen que leer por la silueta también con la cámara alejada (1.4).
- [ ] **v1.2, relaciones:** al mover una unidad, marcar qué vecinas (las 8) le darían afinidad o riesgo de incidente en el destino (`Sistema.md` 15). El texto ya dice "al lado o en diagonal"; el tablero lo tiene que mostrar.
- [ ] **v1.1, rasgos:** el surco (tierra removida con un lomo de terrones a cada lado, simétrico, que se lea como pozo), con el color del bando de su dueño; el Surcón arando; el Zancajunco **hecho junco** (silueta de mata de juncos) y con la **embestida** pendiente (cuello en S tenso); el Tasajero en **Caza** (largo y pegado al suelo) y en **Cuenta** (recogido, cola enroscada). Todo se distingue por la silueta (sección 5).
- [ ] Pantalla de comer a una criatura: aviso de rescatistas perdidas, botones "Hacerlo" / "Todavía no", la tribu alrededor del fuego sin mostrar a la comida y su pergamino ardiendo.
- [ ] Rastro del abandono donde dormía la criatura: hojas, surco o huellas, según la especie.
- [ ] Un solo ícono de Enfermo, con la causa y los días restantes en el tooltip; una sola postura de enferma, simétrica.
- [ ] Sin barra de confianza: el progreso se lee en el texto y en la postura del sprite en el nodo (enrollada, atenta, esperando).
- [ ] Líneas de Encono, cobardía y resistencia en el registro, cerca de la criatura.
- [ ] Al invocar, la criatura sale parpadeando: un gesto chico, igual en las cuatro especies.
- [ ] Siluetas distintas para la Rodauva erizada y la acobardada.
- [ ] Ceniza sobre la piedra del fuego al despertar tras un rescate con bajas (y tras la atacante que se fue).
- [ ] La línea *"Si la cuidás, te va a salvar. Todavía no."* junto al umbral de rescate del día 1, y su cierre *"Ahora sí."*
- [ ] Hojarasca junto a la piedra del fuego del Molino: la cama de la compañera.
- [ ] El Molino de agua con la rueda quieta y la acequia seca (para que la Capa 1 tenga qué reparar).
- [ ] La Urdimbre: hilos paralelos de carbón alrededor del cuenco, con un hilo suelto; simétrica por el espejado.
- [ ] La hoja que se enrolla sola sobre la ramita (momento visual del ritual).
- [ ] Tramo "lo que diste" y marca de **quebranto** en la barra de vida, cada uno con su contador. Sin vendas ni marcas de un solo lado.
- [ ] Contador del plazo como **rayas de carbón**; las mismas rayas en una viga del Molino.
- [ ] Techo del Molino con **golondrinas** en 4 etapas, y vacío al final.
- [ ] La talla del Roble Viejo: gastada, sin rasgos identificables.
- [ ] El pergamino ardiendo con llama pálida y ceniza.
- [ ] Animaciones de Encono (cresta erizada, cuello en ristre, ruptura de la quietud) y de cobardía (Rodauva enrollada).
- [ ] Despertar de las habilidades de campamento: ramitas en las púas de la Rodauva, Ocarra de pie con un ojo abierto, hondonada del Surcón, Zancajunco inmóvil al borde.
- [ ] La Poza Tibia: agua que humea apenas entre piedras de orilla, sin brillos mágicos.
- [ ] Controlar la altura del Zancajunco en el tablero isométrico (también hecho junco, que es su postura más alta).
- [ ] Frutas intercambiables en el sprite de Rodauva.
- [ ] El Maestro de polo Soplo, levemente desvaído en la ficha o el retrato.

### 9.3 Para el Worldbuilder (capas futuras, sin detallar)

- [ ] Qué criaturas son orgullosas (dato para el Grito).
- [ ] Por qué la voz del Maestro pesa sobre el hilo del pergamino, y por qué el Soplo puede atar una voluntad (el Yugo).
- [ ] Textos del momento en que el defecto consume a la criatura (la torcedura).
- [ ] Qué llena la zozobra en cada criatura y textos de quebrarse y templarse.
- [ ] Qué legados le caen mal a cada especie, más allá de la regla de la rueda (Visión 11).
- [ ] Verbos de los 18 legados en tooltips de juego (cuando tengan capa; base en 2.10).
- [ ] Esbozo de los escribas (Capa 5).
- [ ] Propuestas para el título del juego y el nombre del mundo (con el Director Creativo).
- [ ] **PREGUNTA ABIERTA:** ¿las criaturas tienen nombre propio? Con varias de la misma especie, el epílogo repite "la Rodauva". Se decide después del primer playtest de la 0b.
- [x] ~~Nombres finales de la involución, las órdenes, el Grito, la subyugación y el esbirro~~ → 8.1 (v1.4).
- [x] ~~Nombre final de la barra de zozobra~~ → Zozobra (8.1).
- [x] ~~Número final de los Nueve~~ → 9 (2.1 y 2.4).
- [x] ~~Nombre final de la Mudanza y del pergamino de muda~~ → Mudanza y el atado (8.1).
- [x] ~~Entregar los textos en JSON~~ → entregado el 03/10/2026 (1.5).

## 10. Registro de cambios

| Versión | Fecha | Cambio |
| --- | --- | --- |
| v1.5 | 15/10/2026 | **Cierre de la 0a del lado del Worldbuilder.** 1.5: textos de pantalla de T25, T28 y T29, aprobados por el usuario (rescatista; `panel.rescatista`: *Te lleva a casa* en el panel, en la ficha y en el resultado; títulos de muertas con su causa, levantadas, caídas guardadas, selladas y atacante pendiente; caídas en la previsualización de la huida; salvaje que tira para huir y se queda); claves de `huida.previa.*` y `aviso.huir.*` confirmadas por T30 (salen las ⚠️); regla nueva: las etiquetas nuevas eligen palabras sin género. 1.2: *Rescatista*. 4.6, 4.8 y sección 5: referencias a las líneas nuevas. 9: derivaciones al día (cerradas las del Arquitecto de la v1.4; nuevas para el usuario, el Arquitecto y Arte). `es.json`: 620 → 633 claves |
| v1.4 | 13/10/2026 | **Textos de T22 a T28 y lore de los Legados.** 1.5: textos de pantalla de T22 a T28 (avisos de hechizos, sellar, invocar y guardar a una caída; sentidos y choque de la Lanzadera; marca y tooltip de huida de las salvajes; desenlace, marca, panel, avisos y previsualización de la huida del Maestro), aprobados por el usuario; 8 claves a confirmar por el Arquitecto. 1.2: *Huyendo*. 2.1: los Nueve son nueve. 2.4 reescrita: nueve oficios de dos manos; los linajes de hechura pasan a **los Legados y sus Reveses** (Revés reemplaza a Sombra). Nueva 2.10: los nueve oficios, nombres del sistema (Legados, Intemperie, colmo, desborde, darse vuelta, molida), respuestas a la Visión 11, justificación de los cuatro ciclos en los 18 legados, escena de Desapego e hipótesis de legados de las 5 criaturas. 2.7: lectura de los rastros por oficio, nunca escrita en el juego. 7: Nueve resueltos. 8: Legados en espera; nueva 8.1 con los nombres de las capas futuras (zozobra, templarse, quebrarse, el atado, torcedura, el Yugo, uncida, la Voz y el Grito). 9: derivaciones al día. `es.json`: 586 → 620 claves |
| v1.3 | 08/10/2026 | **Sincronización con `Sistema.md` v1.7 y `Arquitectura.md` v0.37 (T17 a T21, escala ×10).** 1.5: textos de pantalla de T19 a T21 (`marca.enconada`, `marca.acobardada` con concordancia, `panel.encono`, `panel.mana`, `aviso.terminar.debe_atacar_rival` según P-038 opción A y `aviso.terminar.debe_acercarse`), aprobados por el usuario; revisión contra la escala ×10, con la regla "ningún texto escribe un número de vida, daño o curación". Sección 5: `guardar_caida.tooltip` sin número; nota sobre `cobardia.resiste.afin` y `.maestro`, que esperan un dato en el evento. 9.2: derivaciones al día (cerradas las de la v1.2 ya resueltas; nuevas para el Arquitecto, Sistemas, el Director y Arte). `es.json`: 577 → 586 claves |
| v1.2 | 07/10/2026 | **Sincronización con la Visión v1.3 y `Sistema.md` v1.6 (vecinas en 8, tablero de 12 × 12).** 1.4: siluetas legibles con la cámara alejada. 1.5: etiquetas de T14 (obediencia y sus tramos, sin concordancia) y T16 (cadena); tooltips de afinidad, incidente, cobardía y Encono con las diagonales (claves propuestas al Arquitecto); concordancia de etiquetas cerrada (T40). Sección 5: hecho junco se destapa solo por los lados; las presas del Tasajero en los huecos de la formación; sostén de la cobardía en 8, con dos líneas que pasan de "al lado" a "cerca"; incidente con la rival en diagonal; combos sin posición; hambre de combate cada 6 rondas. Sección 6: el vínculo mira 8, el cuerpo mira 4. 9.2: derivaciones cerradas y nuevas. `es.json`: 568 → 577 claves |
| v1.1 | 05/10/2026 | **Sincronización con la Visión v1.2 y `Sistema.md` v1.5 (rasgos reescritos tras el playtest 0a.1).** Nueva 1.2.1: nombres en `PROPUESTA` (Arar, Hecho junco, Embestida; Rastreando para la hostilidad). 1.5: huecos `DECIDIDO`, hueco `{n}`, concordancia de las etiquetas de estado con la especie y textos de la pantalla de T13. 2.6: la prenda sin consecuencias. 4.6: las que miran (ya estaban en `es.json`) y la atacante que se va. 4.7: emboscada del Robledal sin "mirando a una sola". 4.11: perdida por abandono tras atacarte. 4.12: solo se come a una suelta; sale "sacar a una guardada". Sección 5: Surcón con Arar (sale Lomo de tierra), Zancajunco con Hacerse junco activo, Tasajero con Caza y cuenta en dos modos; posturas nuevas para arte; nota del Encono con un Zancajunco hecho junco; tooltips nuevos y rasgos en acción. 8: la prenda en el epílogo. Sección 9 reescrita: 9.1 cerrada; derivaciones al Director, Sistemas, Arquitecto y Arte. `es.json`: 496 → 568 claves |
| v1.0 | 03/10/2026 | **Sincronización con la Visión v1.0. El Worldbuilder no tiene pendientes que bloqueen el MVP.** Pasan a `DECIDIDO` el ritmo del día (4.15) y los textos nuevos de la entrega (1.5). 4.12: cuándo se come a una criatura (solo en el reparto de la noche, junto al fuego). Centinela unificado entre 1.5 y 4.6, sin hueco (actualizar `nocturno.centinela` en `es.json`). Sección 9: se cierra la pregunta de cuándo comer; pedidos a Sistemas para poner al día `Sistema.md` 15; prioridad de los huecos gramaticales para el Arquitecto |
| v0.9 | 03/10/2026 | **Textos entregados en JSON** (`juego/datos/textos/es.json`, 493 claves). Nueva 1.5: notación, huecos gramaticales (`PROPUESTA` al Arquitecto), reglas de armado y textos nuevos de la entrega (`PROPUESTA` al Director). Claves de la sección 5 y 4.6 alineadas con el JSON (`sellar.fallo.erizada`, `nocturno.comer.zancajunco_suelto`, `rasgo.<id>.tooltip`). 4.11: muerte de hambre del Maestro `DECIDIDO` (`Sistema.md` 7.6). Sección 9 reescrita: se cierran los pedidos ya registrados en `Arquitectura.md` v0.6; las guardadas no pierden lealtad al comer a una compañera (Visión 6.4); nuevos pedidos sobre el esquema de textos y la variante "solo guardadas" |
| v0.8 | 02/10/2026 | **Textos del MVP completos.** Pasan a `DECIDIDO`: textos de combate de la 0a, atacante caída (4.6), variante "solo guardadas" (4.11) y el criterio de 1.3, que pasa a "la tribu es la cámara". Nuevas 3.5 (hambre) y 3.6 (Enfermo). Evento completo del juncal (4.5). Nuevas 4.12 (comerse una criatura), 4.13 (abandono), 4.14 (camino de confianza y Leal por primera vez, con el payoff de la compañera) y 4.15 (ritmo del día, `PROPUESTA`). Pantalla de muerte por hambre del Maestro (4.11, `PROPUESTA`). Sección 9 reescrita: preguntas de reglas para Sistemas y Director, y pedidos acumulados |
| v0.7 | 02/10/2026 | **Textos de la 0a completos en `PROPUESTA`.** 1.3: criterio "comer a una criatura se elide". 4.6: la atacante caída (escenario G) con sus tres salidas. 4.11: orden de lectura del epílogo `DECIDIDO` según `Sistema.md` 13; variante de cierre "solo quedan guardadas". Sección 5: textos de combate de la 0a (sellado, Encono y cobardía, tooltips de rasgos, Secundar, combos, invocar, guardar, choque de la Lanzadera, hambre de combate, caída del Maestro y victoria). Sección 9 reescrita |
| v0.6 | 02/10/2026 | **MVP cerrado para el Worldbuilder.** Glosario (1.2): Menestral, quebranto, las rayas y las golondrinas. Hechizos (2.8) y rasgos (sección 5) pasan a `DECIDIDO`. Nueva 2.9: la clase del MVP y textos de subida de nivel. 4.3: la crecida no cierra el paso. 4.5: la ciruela en disputa; "leer el río"; Poza, rodeo y Tasajero derrotado resueltos; textos del Tasajero por estado. Nuevas 4.9 (quebranto y Poza Tibia), 4.10 (el plazo) y 4.11 (el epílogo). Incidentes entre rivales aliadas (sección 5). Pendientes reescritos (9) |
| v0.5 | 01/10/2026 | Nueva 2.8: nombres de los hechizos. Nueva 3.4: textos de rebuscar y de pudrición. Nueva 4.3: geografía del valle; el Molino es de agua y está callado por la acequia tapada (gancho Capa 1). Lugares: el Surcón pasa al Vado. Eventos: el corral caído, el surco que ronca y la Poza Tibia. Ataque nocturno al raso y Centinela. Nueva 4.7: habilidades de campamento y emboscadas. Las dos frutas iniciales. Temperamento de huida; textos de guardar a una caída y de huida del Maestro |
| v0.4 | 01/10/2026 | Nueva 4.6: la apertura; la Rodauva es la dueña del Molino; el pasado del Maestro no se explica en el MVP. Fichas con rasgo de combate. Nombres finales de los rasgos. Rodauva erizada y acobardada con siluetas distintas. Textos de huida, caída, rescate y caídas que quedan atrás. Relaciones dentro de una misma especie |
| v0.3 | 01/10/2026 | Glosario (1.2): Arrimo, Encono y Secundar finales; Urdimbre, prenda, péñola y "lo que diste". Pergaminos: no son piel. Nueva 2.6: el ritual de sangre. Nueva 2.7: rastros de los Nueve. Nodos nuevos: la hornacina, el palomar, el charco quieto, el Roble Viejo y el rodeo de las zarzas. Fichas con prenda y defecto de naturaleza. Cobardía reemplaza al encono de presa. Mudanza y escribas en Ideas en espera |
| v0.2 | 30/09/2026 | Nueva sección 2: los Nueve, lo etéreo, la balanza Barro ↔ Soplo y los pergaminos que arden. Estado Enfermo único con tres causas. El Zancajunco acepta carne. Rangos en las fichas. Tasajero apaciguable. Momentos oscuros como caras de reglas generales |
| v0.1 | 30/09/2026 | Creación: convenciones, comida, región Valdelumbre y 5 criaturas del MVP |
