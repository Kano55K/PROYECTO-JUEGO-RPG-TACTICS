# CLAUDE.md — Instrucciones para Claude Code

> Revisado por última vez contra `docs/Arquitectura.md` v0.35 (08/10/2026). Dueño: Arquitecto Técnico.
> Si este archivo y `docs/` se contradicen, **manda `docs/`** y avisás de la contradicción en `docs/PREGUNTAS.md`.

## Qué es este proyecto

Tactics RPG 2D isométrico de captura de criaturas y supervivencia medieval. Estamos construyendo la **prueba 0a** (rebanada de combate), tarea por tarea, según el plan de `docs/Arquitectura.md`, sección B.

## Fuentes de verdad (leelas, no las supongas)

| Documento | Manda sobre |
|---|---|
| `docs/00_Vision.md` | Qué es el juego y su alcance |
| `docs/Sistema.md` | Reglas y números |
| `docs/Mundo.md` | Nombres y textos |
| `docs/Arquitectura.md` | Cómo se construye: estructura, datos, tareas (B.2 a B.4) y decisiones técnicas (A.11) |
| Brief de la prueba 0a (en `docs/`) | **Histórico** desde el 06/10/2026 (`Sistema.md` 11.9): no lo uses para decidir y no anotes sus contradicciones. Manda `Sistema.md` |
| `docs/PREGUNTAS.md` | Dudas abiertas con el staff y sus respuestas |

`docs/RESUMENES.md` es el historial de las sesiones de programación: **no manda sobre nada**. Si contradice a otro documento o al código, mandan ellos.

- **Nunca cambies una regla para que sea más fácil de programar.**
- **Nunca interpretes en silencio una regla ambigua.** Toda duda va a `docs/PREGUNTAS.md` (sección siguiente).
- **No edites ningún archivo de `docs/` salvo `docs/PREGUNTAS.md` y `docs/RESUMENES.md`.** Los demás son copias que actualiza el usuario.

## Preguntas al staff: `docs/PREGUNTAS.md`

Es el único canal para dudas de diseño. Una duda que solo aparece en el chat se pierde.

**Cuándo escribir una pregunta:**
- Una regla de `Sistema.md`, `Mundo.md`, la Visión o el Brief es ambigua, contradictoria o no cubre un caso que el código tiene que resolver.
- Falta un número, un dato o un texto que la tarea necesita.
- `CLAUDE.md` o `Arquitectura.md` se contradicen con otro documento, o una decisión técnica no alcanza para la tarea.

**Cuándo NO:** dudas de cómo programar algo dentro de las reglas de este archivo (eso lo resolvés vos y lo explicás en el plan), o dudas que ya tienen respuesta en `docs/`. **Antes de preguntar, buscá en `docs/`.**

**Formato** (agregá al final del archivo, numeración correlativa `P-001`, `P-002`…):

```markdown
## P-001 — <título corto>
- **Estado:** ABIERTA
- **Para:** SISTEMAS | WORLDBUILDER | DIRECTOR CREATIVO | ARQUITECTO
- **Tarea:** T04
- **Fecha:** dd/mm/aaaa
- **Fuente:** `Sistema.md` 11.4 (sección exacta donde está el problema)
- **Duda:** <una sola pregunta, concreta, que se pueda contestar en una o dos líneas>
- **Caso que la dispara:** <ejemplo numérico o situación de juego>
- **Opciones:** A) … B) … — Recomendación técnica: … (o "ninguna")
- **Bloquea:** sí — <qué no se puede hacer> | no
- **Mientras tanto:** <qué hiciste: nada de esa parte / dejaste el lugar con un test pendiente>
- **Respuesta:** _(la completa el staff)_
```

**Reglas:**
- Una pregunta por entrada. Si tenés tres dudas, son tres entradas.
- **Nunca completes `Respuesta`** ni elijas una opción por tu cuenta. Mientras esté ABIERTA, no programes esa parte: hacé el resto de la tarea si se puede, y si no, pará.
- Nunca borres ni reescribas entradas. Solo podés: agregar entradas nuevas, y pasar una entrada a `CERRADA` cuando su respuesta ya está aplicada en el código (agregando `- **Cerrada en:** T0X`).
- **Al empezar cada tarea, leé las entradas `RESPONDIDA`** que la afecten y aplicalas.
- Las preguntas nuevas van en el mismo commit de la tarea y se listan en el resumen final.

Estados: `ABIERTA` (sin respuesta) → `RESPONDIDA` (el usuario pegó la respuesta) → `CERRADA` (aplicada en el código).

## Resúmenes de sesión: `docs/RESUMENES.md`

Historial de lo que se hizo en cada sesión. El staff lo lee para saber en qué está el código sin abrir el repositorio, y vos lo leés al empezar una sesión de una tarea ya empezada.

**Cuándo:** al final de **cada sesión**, aunque la tarea siga. Una tarea en tres sesiones lleva tres entradas. Si la sesión se cortó con el plan sin aprobar, igual va una entrada corta.

**Formato** (agregá al final del archivo, nunca arriba ni en el medio):

```markdown
## T08 · sesión 1 · dd/mm/aaaa
- **Rama:** tarea/T08-turno
- **Estado:** EN CURSO (sigue en la sesión 2) | TERMINADA (pendiente de PR)
- **Hecho:** …
- **Archivos:** creados …; modificados …
- **Tests:** N nuevos, total M, todos pasan (sí/no)
- **Criterio de terminado:** cumplido punto por punto (1 …, 2 …) | parcial: faltan los puntos …
- **Lecturas declaradas:** reglas programadas con una lectura literal, con su P-00X o su S-XX (o "ninguna")
- **Claves de texto nuevas sin texto:** … (o "ninguna")
- **Preguntas:** nuevas P-00X (para quién, bloquea sí/no); cerradas P-00X (o "ninguna")
- **Para la próxima sesión:** … (o "nada: tarea terminada")
```

**Reglas:**
- Solo hechos: lo que no pasó los tests no va en "Hecho", va en "Para la próxima sesión".
- Nunca edites ni borres entradas anteriores. Si una tenía un error, la corrección va en la entrada nueva: `- **Corrige:** T08 · sesión 1, …`.
- Cuando la tarea termina, la última entrada resume **la tarea entera** (Hecho, Archivos, Tests y Criterio cuentan todas sus sesiones): esa entrada es la descripción del pull request.
- La entrada va en el commit de la sesión.
- No completes entradas de tareas viejas que no tengan una: el historial empieza donde empieza el archivo.

## Motor y entorno

- **Godot 4.7.1-stable** (estándar, no .NET). No sugieras actualizar.
- **GDScript tipado**: tipos declarados en toda variable, parámetro y retorno de `nucleo/`.
- **GdUnit4 v6.2.1** para tests. Windows.
- Prohibida la sintaxis de Godot 3 (`yield`, `export var`, `onready var`, `KinematicBody2D`…). Usá la de Godot 4 (`await`, `@export`, `@onready`).

## Arquitectura: dos mitades

```
nucleo/        reglas puras. Clases que extienden RefCounted. Sin Node, sin escenas, sin autoloads.
pantalla/      escenas de Godot. Leen el estado del núcleo y le mandan acciones. Nunca calculan reglas.
datos/         JSON + esquemas. Sin código.
pruebas/       tests del núcleo (misma estructura que nucleo/) y de la pantalla (pruebas/pantalla/).
pruebas/fixtures/  datos chicos de prueba, con errores a propósito si hace falta.
herramientas/  reproductor y scripts de consola.
registros/     salidas de combates (fuera de Git).
```

- `pantalla/` puede usar `nucleo/`. **`nucleo/` nunca usa `pantalla/`.**
- Todo lo que una clase del núcleo necesita le llega por parámetro (incluida la carpeta de datos).
- El núcleo trabaja en coordenadas de grilla `[x, y]`, con `y = 0` arriba. No sabe si la vista es cenital o isométrica.
- Las previsualizaciones usan **"calcular sin aplicar"**: la misma función que aplica la regla, sin modificar el estado.
- **Las entidades se apuntan por `id` (texto), nunca guardando el objeto de otra entidad**: la criatura guarda `pergamino_id`, el pergamino guarda `ocupante_id`, y quien necesita el objeto lo pide al contenedor. Dos `RefCounted` que se apuntan entre sí nunca se liberan. La ficha de especie sí se comparte como objeto de solo lectura.

## Pantalla (desde T13)

`pantalla/` es la única carpeta con nodos y escenas. Se rige por esto:

- **Cero reglas.** La pantalla no calcula daño, alcance, orden ni nada de `Sistema.md`. Pregunta al núcleo (consultas de `Turno`, `previsualizar_ataque`, `instantanea`, `registro`, `resultado`) y le manda `Accion`. Si para mostrar algo necesitás una cuenta, falta una consulta en el núcleo: agregala en `nucleo/` con su test.
- **Se redibuja desde el núcleo** después de cada cambio. No guarda copias propias de vida, posición ni estado.
- **Casilla ↔ pantalla solo con `TileMapLayer.map_to_local` y `local_to_map`.** Nunca multipliques coordenadas por un tamaño de casilla: la vista isométrica (T32) cambia solo el tileset.
- **Textos del jugador solo por `ArmadorTextos`**, con el generador de textos del contexto. Clave que falta → `[FALTA: clave]`, y va al resumen. Las pantallas de desarrollo (error de datos, selector de escenario, panel de depuración) pueden mostrar ids y datos técnicos.
- **La pantalla nunca usa un generador de azar.** Ni el de combate ni ninguno propio.
- **Teclas como acciones del `InputMap`** (`recargar`, `depuracion`…), nunca códigos de tecla en un script.
- La lógica de entrada que se pueda separar de los nodos (por ejemplo, traducir un clic en una `Accion`) va en una clase `RefCounted` dentro de `pantalla/`, con tests normales.
- Tests de pantalla en `pruebas/pantalla/`. Las escenas se prueban con el runner de escenas de GdUnit4 (arranque, creación, posiciones), y la experiencia de juego la prueba el usuario con la **lista de prueba manual** que va en el resumen de la última sesión de la tarea.
- Lo que escribe a disco (grabaciones y registros) va a `registros/`, que no se commitea.

## Principios que no se negocian

1. **Ningún número de balance en el código.** Todo número de `Sistema.md` vive en `datos/`. Si escribís un número que no sea 0, 1 o un índice, preguntate de dónde sale; si sale de `Sistema.md`, va a un JSON.
2. **Azar solo con el generador con semilla del núcleo** (`nucleo/azar/`, hecho en T02). Nunca `randi()`, `randf()` ni `RandomNumberGenerator` sueltos. Los generadores son objetos que se crean, no globales; el de textos está separado del de combate.
3. **Determinismo**: la iniciativa y el orden de las reglas se implementan tal cual están escritos en `docs/Sistema.md`. Misma semilla + mismas acciones = mismo registro, byte por byte.
4. **Comportamiento contra número**: un efecto nuevo (rasgo, geometría de hechizo) es un valor de `enum` programado una vez, con su test; sus números son dato.
5. **Solo la tarea pedida.** No construyas funciones de tareas o capas futuras. Si hace falta un lugar donde algo se va a enchufar, dejá el lugar (un campo con valor por defecto, un punto de extensión) y nada más.

## Datos

- JSON, un esquema por tipo en `datos/_esquemas/` (JSON Schema 2020-12, solo el subconjunto de `docs/Arquitectura.md` A.2). El validador y el cargador (`nucleo/datos/`, hechos en T03) son la única forma de leer datos.
- Todo objeto de campos fijos lleva `additionalProperties: false`. Todo objeto admite `_nota`; la raíz admite `$schema`.
- **Campo nuevo → primero el esquema, después el dato, después el código.**
- El cargador devuelve `errores` y `avisos`; con un solo error no entrega datos. El bloqueo del arranque del juego se enchufa en T13.
- Al transcribir números de `docs/Sistema.md` a JSON, citá la sección en `_nota` (ej.: `"_nota": "Sistema.md 4.1"`).

## Textos

- **Nunca inventes un texto que vea el jugador.** `datos/textos/es.json` es del Worldbuilder: no lo edites.
- Podés usar una clave nueva en el código. Si no existe, la pantalla muestra `[FALTA: clave]`, y la listás en tu resumen.
- Claves: `^[a-z0-9_]+(\.[a-z0-9_]+)*$`. Huecos entre llaves: `{criatura}`, `{a_criatura}`, etc. (A.2.1). El aviso de huecos desconocidos es del armador de textos (T34), no del cargador.

## Convenciones

- Términos del juego en castellano, como en `Sistema.md`, **sin tildes ni ñ**: `mana`, `danio`, `encono`, `secundar`. La API de Godot sigue en inglés.
- `snake_case` para variables y funciones, `PascalCase` para clases (`class_name`).
- Comentarios en castellano, cortos, explicando el porqué. Si una función implementa una regla, citá la sección: `# Sistema.md 11.4`.

## Tests

**Configuración (ya hecha en T01, no la repitas):** la variable de entorno `GODOT_BIN` apunta al ejecutable de consola de Godot:

```
GODOT_BIN = D:\Descargas\Herramientas para developer game\Godot_v4.7.1-stable_win64_console.exe
```

GdUnit4 la lee sola. Nunca escribas esa ruta dentro de un comando ni de un script: tiene espacios y depende de esta máquina.

Comando para correr **todos** los tests por consola, desde la raíz del proyecto:

```
addons/gdUnit4/runtest.cmd -a res://pruebas
```

Para una sola carpeta: `addons/gdUnit4/runtest.cmd -a res://pruebas/azar`.

- **Mientras trabajás, corré solo la carpeta que tocás** (`res://pruebas/combate`, `res://pruebas/pantalla`…): la suite completa tarda unos 15 minutos. **La suite completa va una vez al cerrar cada sesión y antes del commit.**
- **El mouse de los tests sale solo de `MousePrueba`** (`pruebas/pantalla/mouse_prueba.gd`, D-012): convierte la posición a coordenadas de ventana y marca su `device`; la vista se prepara con `MousePrueba.preparar(vista)`. Ningún test llama a `Input.parse_input_event` con un evento de mouse por su cuenta.
- **Tests intermitentes:** si en la suite completa falla un test de pantalla que no tocaste y pasa al correr solo su carpeta, no lo "arregles" con esperas ni reintentos: anotá en el resumen el test, el mensaje y si se repite, y avisá al usuario. Un test intermitente es un error del test y se corrige en su propia tarea.

- Escribí los tests **antes** del código, a partir del criterio "Terminada cuando…" de la tarea.
- **Tests de reglas: con datos de prueba propios en `pruebas/fixtures/`, nunca con `datos/`.** Llevan los números del ejemplo de `Sistema.md` que reproducen (los tests sí pueden tener esos números: son la comprobación; el código no) y la sección en `_nota`, y validan con los mismos esquemas. Así, cambiar un número de balance en `datos/` no rompe ningún test de reglas. Solo usan `datos/` real los tests que comprueban que todo carga y se puede crear (`docs/Arquitectura.md` A.6).
- Cada regla con sus casos de `docs/Sistema.md` y del Brief. Si la tarea cita un ejemplo numérico, el test lo reproduce.
- Una tarea no está terminada si **un solo test** del proyecto falla, aunque sea de otra tarea.
- **Si el comando falla por algo que no es un test** (no encuentra Godot, `GODOT_BIN` vacía, error de GdUnit4), no improvises otra forma de correr los tests: pará y mostrale el error al usuario.

## Git

- **Una rama por tarea**, creada desde `develop` actualizado: `tarea/T04-datos`. Si la tarea lleva varias sesiones, todas trabajan en la misma rama.
- Commits en esa rama, con mensaje `T04: <qué se hizo>`. El commit lo confirma el usuario.
- **Nunca** hagas `push`, `merge`, `rebase`, ni toques `main` o `develop` directamente. El usuario abre el pull request, lo revisa y mergea a `develop`. `main` solo recibe hitos (`0a.1`, `0a.2`…), y eso también lo hace el usuario.
- No commitees `registros/` ni la caché `.godot/`.

## Cómo trabajás cada tarea

1. Creá la rama de la tarea desde `develop`.
2. Leé la fila de la tarea en `docs/Arquitectura.md` (B.2 a B.4, y B.3.1 para T41 a T43), las secciones de `docs/Sistema.md` y del Brief que cita, y las entradas de `docs/PREGUNTAS.md` que la afecten.
3. **Proponé un plan** antes de escribir código: archivos que vas a crear o tocar, tests (uno por renglón del criterio de terminado) y dudas. Las dudas de diseño van como entradas nuevas de `PREGUNTAS.md`. Esperá la aprobación.
4. Escribí los tests, después el código. Mientras trabajás, corré la carpeta que tocás; al cerrar la sesión, la suite completa.
5. Actualizá la sección "Estado actual" de este archivo (solo esa sección). Es una foto corta del presente: qué está terminado (una línea por tarea), en qué rama se trabaja, qué preguntas abiertas afectan y cuál es la siguiente tarea. La historia va en `docs/RESUMENES.md`.
6. Agregá la entrada de la sesión a `docs/RESUMENES.md` (sección anterior) y mostrala también en el chat. Si la tarea terminó, esa entrada es la descripción del pull request.
7. Esperá el OK del usuario para el commit.

Si la tarea sigue en otra sesión: al empezar la siguiente, leé la última entrada de esa tarea en `docs/RESUMENES.md` antes de proponer el plan de la sesión.

## Hito 0a.1b — "Rasgos" (T35 a T40)

Reglas completas en `docs/Arquitectura.md` B.2.1. Las que más se olvidan:

- **Tests que contradicen la v1.3 de `Sistema.md`:** se reescriben, nunca se borran sin reemplazo. El resumen de la sesión y el PR los listan uno por uno, con la sección de `Sistema.md` que los cambia. Un test viejo cambiado sin esa referencia es un error de revisión.
- **Rasgo = efecto + parámetros.** El código reconoce un rasgo por su `efecto`, nunca por el `id` de la especie o del rasgo.
- **Consulta única de objetivo** (desde T38): toda elección de objetivo pasa por una sola función. Ninguna clase vuelve a mirar por su cuenta si una unidad está caída, fuera, guardada u oculta.
- **Estado intermedio:** entre T35 y T38, las activas nuevas existen en los datos y todavía no tienen acción. Es lo esperado.
- **Grabaciones del playtest 0a.1:** cambian de huella; el aviso del reproductor es lo esperado. No se arreglan.
- Las lecturas S-21 a S-26 están confirmadas por `Sistema.md` v1.4: no hace falta preguntarlas.

## Geometría y tablero (desde T41)

Reglas completas en `docs/Sistema.md` 11.3 v1.6 y `docs/Arquitectura.md` B.3.1 y A.11.

**El cuerpo mira 4, el vínculo mira 8:**

| Vecindad | Reglas |
|---|---|
| **4 ortogonales** | Mover, atacar, guardar (criatura junto al Maestro), invocar, cavar, Remiendo, presas de la Caza, Erizarse de la IA, Hacerse junco (activar y destape por contacto), casilla libre y encierro |
| **8 vecinas** (diagonales incluidas) | Afinidad (también entre salvajes), incidente con rival aliada, toggle de afines contra la cobardía y −10 del Maestro vecino |
| **Sin posición** | Combos |
| **Manhattan ≤ Movimiento + Alcance** | "A su alcance" del Encono y de la cobardía (sin cambios) |

- Toda regla de vínculo usa la consulta de vecina en 8 de `Tablero` (T41), y toda regla de cuerpo usa las vecinas ortogonales de T06. Nunca una tercera forma de medir, y ninguna clase calcula distancias por su cuenta.
- **Tablero de referencia: 12 × 12.** Un escenario puede ser más chico (G es de 8 × 8), nunca más grande. Ningún tamaño de tablero escrito en el código.
- **Cámara (desde T42) y mouse (desde T20-ajustes, D-006):** la vista toma la posición del mouse del último `InputEventMouse` que recibió y la convierte a casilla con la inversa de la transformación de canvas del `TileMapLayer` y `local_to_map`. Nunca lee el cursor del sistema (`get_local_mouse_position`, `get_global_mouse_position`, `get_viewport().get_mouse_position`), ni en la vista ni en los tests: los tests mandan eventos con su `position` y no mueven el cursor real. La cámara no toca el núcleo.
- **Test de contacto (desde T43):** si una tarea hace fallar `pruebas/datos/test_contacto.gd` (cambia la ronda del primer ataque de un escenario), no ajustes el test ni las coordenadas: anotalo en `docs/PREGUNTAS.md` y pará. **Única excepción autorizada (T19):** el ayudante del test que juega "esperando" puede jugar lo mínimo que obliga una regla cuando `puede_terminar()` da falso (una enconada que tiene que atacar o acercarse). Nunca se tocan coordenadas ni criterios.

## Relaciones en combate (desde T18)

Reglas completas en `docs/Sistema.md` 10.1 a 10.7 y 11.3, y en `docs/Arquitectura.md` B.3 y 10.5. Las que más se olvidan:

- **Orden del inicio del turno** (11.3): borrar Erizarse → maná (T21) → huida (T25) → cambio de modo → Encono o cobardía (T19) → incidente (T18, solo si no quedó enconada). **Corre una sola vez por ronda** (S-31): nunca con `entrada.vuelve`.
- **Toda tirada en %** pasa por `Porcentajes.tirar` con el generador de combate que recibe `Turno`. Con 0 % no se tira (el generador no se toca). **Una sola tirada por turno y por regla**, aunque haya varias rivales.
- **La rama sale del dato:** Encono o cobardía por el `rol` de la ficha; los rasgos, por su `efecto`. Nunca por `id`.
- **Los estados del turno** (distraída, enconada, acobardada) viven en `Turno` y se ven solo por sus consultas (`casillas_para_mover`, `objetivos_para_atacar`, `puede_terminar`, `puede_secundar` y la previsualización). La pantalla y la IA no los recalculan.
- **Una sola función para todos los bandos (desde T20):** las enemigas (salvajes y atacante nocturna) tiran chequeo de rival e incidente por las mismas funciones que la tribu, con tramo `baja` (`Obediencia`), sin Arrimo y sin el −10 del Maestro vecino en la cobardía (S-41). Nunca una copia de la regla para las salvajes: la diferencia es un parámetro (tramo, Arrimo), no otra función.
- **La IA toma sus casillas y objetivos de las consultas del `Turno`** (D-005): nunca recalcula una restricción (enconada, acobardada, distraída, obligación). Si le falta una consulta, se agrega al `Turno`, calculando sin aplicar, con su test.
- **Test de robustez de la IA (desde T20):** `pruebas/datos/test_robustez_ia.gd` juega los 11 escenarios con 10 semillas cada uno, sin `error()`. Si una tarea lo hace fallar, no cambies semillas, escenarios ni criterios: buscá la decisión de la IA que el `Turno` rechaza. Si el origen es una regla, anotalo en `docs/PREGUNTAS.md` y pará.
- **Lecturas declaradas abiertas** que ya están programadas o se programan así: S-27 y S-29 a S-43 (`docs/Arquitectura.md` 10.5). No las vuelvas a preguntar.

## Estado actual

- **Terminadas y mergeadas a `develop`:** T01 (proyecto), T02 (azar con semilla), T03 (validador y cargador), T04 (esquemas y datos de 0a; test permanente `pruebas/datos/test_datos_completos.gd`), T05 (modelo de unidades en `nucleo/unidades/`: `Especie`, `TablaBalanza`, `Criatura`, `Maestro`, `Pergamino`, `Plantel`).
- T06 (tablero y geometría) mergeada a `develop`: `nucleo/combate/tablero.gd` (`Tablero`), solo consultas sobre el `Plantel`. `Maestro` tiene `movimiento` y `alcance` (de `maestro.json`). Fixtures en `pruebas/fixtures/combate/`.
- T07 (cola de iniciativa) mergeada a `develop`: `nucleo/combate/cola_iniciativa.gd` (`ColaIniciativa`: `empezar_ronda`, `siguiente`, `terminar_ronda`, `entradas`) y `entrada_cola.gd` (`EntradaCola`). `Maestro` tiene `ID` y `velocidad`.
- T08 (turno de una unidad) mergeada a `develop`: `nucleo/combate/turno.gd` (`Turno.empezar(entrada, plantel, tablero, danio)`, `validar`/`aplicar` con la misma `_resolver`, consultas para pantalla e IA, puntos vacíos de inicio y fin de turno), `accion.gd` (`Accion`), `resultado_accion.gd` (`ResultadoAccion`: `valida`, `motivo`, `danio`, `espero`, `fin`). `Criatura` tiene `erizada`.
- T09 (fórmula de daño) mergeada a `develop`. `Danio.desde_datos(tabla_combate, tabla_hambre)`; `Danio.calcular(atacante, objetivo, plantel, aportes)` devuelve un `DesgloseDanio` con `ModificadorDanio` (también la forma de los aportes externos de T15, T16 y T19). `Porcentajes.aplicar`: piso explícito, sin mínimo.
- T10 (vida en 0, fin y cierre) mergeada a `develop`: `VidaCero.resolver`, `FinCombate.evaluar` (`EN_CURSO`, `VICTORIA`, `DERROTA_POR_CAIDA`, `HUIDA` sin programar), `Cierre.desde_datos(...).cerrar(plantel, fin)` → `ResultadoCierre`; `Criatura.Estado.FUERA` y `MUERTA`, `Maestro.caido`, `Plantel.cerrado`. En `nucleo/unidades/`: `Relaciones`, `AcumuladorLealtad`, `AnotacionLealtad`, `CambioLealtad`.
- T11 (IA de las salvajes) mergeada a `develop`: `IASalvaje.decidir(turno, plantel, cola)` → `DecisionIA` (`paso`, `acciones`, `describir()`), con `OpcionAtaque`. `Turno.previsualizar_ataque` comparte `_atacar_desde` y el punto vacío `_aportes` con el ataque real. Umbral de Erizarse en la ficha: `rasgo.umbral_vida_pct`.
- T12 (contrato del combate) mergeada a `develop`, con su ajuste (`tarea/T12-ajustes`: la huella excluye `escenarios/`, A.7 v0.19; P-024). `ContextoCombate.armar(escenario, datos)` (`valido`/`motivo`, `DESPLIEGUE_NO_IMPLEMENTADO`, `escenario`, `huella`, generadores `azar_combate` y `azar_textos` con `GeneradorAzar.derivado`), `Combate.empezar(contexto)` (`esperando_jugador`, `turno_actual`, `aplicar`, `terminado`, `fin`, `resultado` → `ResultadoCombate`, `registro`, `error`, `acciones_jugador`, `instantanea`), `RegistroCombate`, `ResultadoCombate` (`a_diccionario()` valida contra `resultado.schema.json`), `Grabacion` (`desde_combate`, `a_diccionario`, `desde_diccionario`; `grabacion.schema.json`), `Reproductor.reproducir(grabacion, datos, hasta_n)` (`combate`, `aviso_huella`, `error`, `accion_con_error`) y `HuellaDatos.calcular(datos)` en `nucleo/datos/` (sin `textos/` ni `escenarios/`, sin `_nota` ni `$schema`). P-019: el +1 de victoria está en `tablas/lealtad.json` `eventos.victoria`.
- T34 (armador de textos) mergeada a `develop`: `nucleo/textos/armador_textos.gd` (`ArmadorTextos.desde_datos(textos, generador)` con `ContextoCombate.azar_textos`; `armar(clave, datos, sujeto)`, `armar_lineas`, `avisos()`, `revisar(textos)` estático, `PREFIJOS_COMPLEMENTO`, `es_complemento`) y `hueco_criatura.gd` (`HuecoCriatura.new(especie_id)`, el valor de un hueco de rol). Fixtures en `pruebas/fixtures/textos/`. `revisar` sobre `datos/textos/es.json`: 0 avisos. `{duracion}` sin programar (0b).
- T13 (pantalla cenital) mergeada a `develop` (dos sesiones). En el núcleo: `Combate.cola()` y `entrada_actual()`, y `nucleo/unidades/estados_unidad.gd` (`EstadosUnidad`: `hambre(valor)`, `lealtad(valor, umbral)` y `fila_hambre`, que también usa `Danio`). En `pantalla/`:
  - `principal.tscn` (`Principal`): carga en dos pasos, con la segunda pasando `ClavesTextos.usadas(datos)`; pantalla de error; selector; `abrir_escenario`; `recargar()` (acción `recargar`); `@export carpeta_registros`.
  - `argumentos.gd` (`ArgumentosPantalla`, `--datos=`) y `claves_textos.gd` (`ClavesTextos`).
  - `combate/vista_combate.tscn` (`VistaCombate.empezar(escenario, datos, avisos, carpeta_registros)`, `redibujar`, `clic_casilla`, `sobre_casilla`, `desglose_mostrado`, `pulsar_erizarse`, `pulsar_terminar`, señal `volver`), `combate/ficha_unidad.tscn` (`FichaUnidad`) y `combate/lectura_combate.gd` (`LecturaCombate`, sin nodos: también `sucesos`, `desglose` y `resultado`).
  - `combate/interprete_clic.gd` (`InterpreteClic.accion(turno, foto, casilla)` y `objetivo_en`) y `combate/guardado_combate.gd` (`GuardadoCombate.guardar(combate, carpeta)` → `<escenario>_<semilla>_<n>.json` y `.jsonl`).
  - `combate/casillas_cenital.tres`: tileset placeholder (fuente 0 damero, fuente 1 marcas).

  InputMap: `depuracion` (F3), `recargar` (R), `seleccionar` (clic izquierdo). Escena principal: `res://pantalla/principal.tscn`. Tests de escenas con `scene_runner(auto_free(escena.instantiate()))`: si no, quedan nodos huérfanos.
- T35 (datos v1.3 y cola de un turno por ronda) mergeada a `develop`. Esquema `especie`: rasgo `{id, efecto, parámetros}` (efectos `erizarse`, `alabarda`, `surco`, `ocultarse`, `caza_y_cuenta`), `velocidad` en la ficha o en `rasgo.modos`; el `Cargador` revisa los parámetros de cada efecto (`_chequear_rasgos`). `Especie.modo_inicial()` y, por modo, `velocidad`, `ataques_por_turno`, `movimiento_partido`, `recibido_pct`, `danio_plano`; `Criatura.modo`. `ColaIniciativa`: una entrada por unidad, con la Velocidad y la marca del modo al armar la ronda. Salen `ya_ataco`, `registrar_ataque`, Lomo de tierra y el +2 de primer ataque. Las activas nuevas (surco, Hacerse junco) existen solo en los datos hasta T37 y T38.
- T36 (turno generalizado y Caza y cuenta) mergeada a `develop`.
  - `Turno`: `pasos_restantes` y `ataques_restantes`, que salen del modo después del inicio del turno. `movimiento_usado` quiere decir "sin pasos" y `accion_usada` "usó alguna acción". `cambio_modo` (`{de, a}` o `{}`). Motivo nuevo `MOVER_ENTRE_ATAQUES` (S-23).
  - `CambioModo` (`nucleo/combate/cambio_modo.gd`): `aplicar(criatura)` y `vida_de_cambio(criatura)`, comparando en enteros. Pasa al `Especie.modo_final()`; `Especie.umbral_cambio_pct()`.
  - `Danio`: `Fuente.MODO`, con el % recibido de la objetivo y el plano de la atacante, y el id del modo como detalle.
  - `Combate`: evento `cambio_modo` detrás de `turno`; `vida_de_cambio(unidad_id)`. La `instantanea` suma `modo` por criatura.
  - La pantalla muestra la fuente `modo` como `[FALTA: desglose.fuente.modo]` hasta T40.
- T37 (el surco) mergeada a `develop`.
  - `Surcos` (`nucleo/combate/surcos.gd`), dueño el `Combate`: `es_surcon(id, plantel)` (por el efecto), `hay_en`, `de(duenio)`, `cavar(casilla, duenio, tope)`, `cerrar_de(duenio)` (la única salida del tablero: hoy la llama `VidaCero` en `fuera`; después guardar, huir y sellar), `historial()` e `instantanea()`.
  - `Tablero`: `pasos_hasta`/`alcanzables(desde, mov, bando, plantel, surcos, pisa_surcos)` (obligatorios desde T38); `es_casilla_libre(casilla, plantel, surcos)`; `bloquea_desplazamiento(casilla, unidad, plantel, surcos)` para T22. La línea no mira surcos.
  - `Turno.empezar(entrada, plantel, tablero, danio, surcos)`, `se_movio`, acción `Accion.cavar(casilla)` (`gasta_turno_completo`). Motivos nuevos: `YA_SE_MOVIO`, `CASILLA_NO_ADYACENTE` y `CASILLA_NO_LIBRE`. `VidaCero.resolver(id, plantel, surcos)`. Los tests sin surcos pasan `Surcos.new()`.
  - `Combate`: vuelca `surco` y `surco_cerrado` después de los eventos `estado`; `instantanea()["surcos"]`. Esquema `grabacion`: tipo `cavar`.
  - La pantalla no muestra surcos ni tiene el botón hasta T40.
- T38 (Hacerse junco y "oculto") mergeada a `develop`.
  - **Consulta única de objetivo:** `Objetivos` (`nucleo/combate/objetivos.gd`, estática). `motivo(id, Clase.HOSTIL | ALIADA, plantel)` → `INEXISTENTE` / `FUERA_DEL_TABLERO` / `CAIDO` / `OCULTO` (solo hostil) / `NINGUNO`; `puede_ser_objetivo`; `de_pie(id, plantel)`; `cuenta_como_rival_a_su_alcance(unidad, rival, plantel)` para T19. El bando lo revisa cada acción. Usan la consulta el ataque del `Turno` (y por él `objetivos_para_atacar` y la previsualización) y la IA (sale `_enemigas_de_pie`).
  - `Criatura`: `oculta`, `bono_junco` y `junco_turno_anterior` (lo escribe `Turno._fin_del_turno`). Acción `Accion.hacerse_junco()`. Motivos nuevos: `OBJETIVO_OCULTO`, `ENEMIGA_ADYACENTE` y `JUNCO_TURNO_ANTERIOR`.
  - `Junco` (`nucleo/combate/junco.gd`, estática): `ocultar`, `destapar`, `revisar_contacto(movida_id, plantel)` (la única revisión; hoy la llama `mover` y después la van a llamar la Lanzadera e invocar), `atacar`, `recibir_ataque` y `limpiar` (desde `Cierre`). Cada función devuelve sus eventos de A.7, que se juntan en `Turno.eventos()`. El `Combate` los vuelca después del evento de la acción.
  - `Danio`: el bono es un plano `RASGO_ATACANTE` con detalle `hacerse_junco`, y se cobra solo al aplicar. La `instantanea` suma `oculta` y `bono_junco`. Esquema `grabacion`: tipo `hacerse_junco`.
  - La pantalla no tiene el botón ni muestra los eventos nuevos (T40).
- T39 (IA v1.3) mergeada a `develop`.
  - `IASalvaje`, con los pasos de 11.8 v1.3:
    - 6b Caza (`DecisionIA.Paso.CAZA`): casilla con 2 presas > 1 → tumba → menos vida sumada → pasos → lectura.
    - Cuenta: golpea desde la casilla de menos pasos y se retira (`DecisionIA.retirada`).
    - 7 `PREPARARSE`: el Zancajunco se oculta y el Surcón cava, siempre por efecto.
    - 8: el Zancajunco con el bono avanza.
  - Lecturas declaradas P-026 (`_DESEMPATE_PRESAS`) y P-027 (`_enemiga_mas_cercana`).
  - `DecisionIA`: `objetivos`, `retirada`, `modo`, `cambio_modo`, `sumar_ataque`; `describir()` dice "paso N" de 11.8.
  - Consultas nuevas: `Turno.casillas_para_cavar()` (también para T40), `surcos_propios()` y `pasos_para_retirarse(desde)`. `Tablero.pasos_hasta(..., dejada)` es opcional.
  - Fixtures en `pruebas/fixtures/combate/ia/` (`ia_caza*`, `ia_cuenta`, `ia_surcon`, `ia_oculta`) y `escenario_f.json`.
- T40 (pantalla de rasgos y ritmo de la IA) mergeada a `develop` (dos sesiones). Hito 0a.1b cerrado: prueba manual hecha y etiqueta `0a.1b` en `main`.
  - Núcleo: `Combate.zona_amenaza(id)` y `Combate.destaparia(id, casilla)`; la regla del contacto vive en `Junco.destaparia` (la usa `revisar_contacto`). `Turno.EFECTO_ERIZARSE` es público.
  - Pantalla: `LecturaCombate.botones_activas()` (por efecto; reemplaza a `boton_rasgo`), `tooltip_unidad(id)`, sucesos de los eventos nuevos, fuente `modo` → `iniciativa.<modo>`, concordancia con sujeto. `ClavesTextos.modo`, `suceso_destape`, `suceso_cambio`; `usadas` suma solo las variantes que están en el archivo.
  - `VistaCombate`: botones `Activa_<tipo>` y `pulsar_activa(tipo)` (sale `pulsar_erizarse`), modo cavar (`eligiendo_cavar`), capas `Surcos` y `Zona`, `PanelUnidad` (`tooltip_mostrado`), `Aviso` (`aviso_mostrado`), `zona_visible`, `alternar_zona`, `casillas_zona`. `InterpreteClic.accion(..., modo_cavar)`.
  - Ritmo de la IA (sesión 2): `SecuenciaIA.pasos(lineas, desde)` (`pantalla/combate/secuencia_ia.gd`: los `movimiento` y `ataque` de acciones con origen `ia`). `VistaCombate`: `@export pausa_ia` (0 = sin animar; los tests la ponen en 0), `en_secuencia()`, `saltar()`, nodo `Timer` `PausaIA` (se libera con la vista: R corta limpio). Durante la secuencia se bloquean clics, botones, activas, `terminar` y el hover; F3 y R andan; Z se aplica al final. Los turnos de la IA del arranque no se animan. `FichaUnidad.mostrar_vida` y `texto_vida`.
  - InputMap: `zona` (Z) y `saltar` (Espacio). Fixtures en `pruebas/fixtures/pantalla/` (`es_rasgos.json`, `especie_prueba.json`, `escenario_especie_prueba.json`) y `pruebas/fixtures/combate/escenario_caza_surco.json`. En los tests, una acción del InputMap se manda con `Input.parse_input_event` de un `InputEventAction` (`simulate_action_pressed` no llega a `_unhandled_input`).
- T14 (obediencia, hambre de combate y Arrimo) mergeada a `develop`. Es la primera tarea de la 0a.2.
  - `Obediencia` (`nucleo/unidades/obediencia.gd`): `valor(criatura)` (sin recorte; `null` en las enemigas) y `tramo(criatura, maestro)` → `TRAMO_BAJA` / `TRAMO_NEUTRAL` / `TRAMO_LEAL`. Las enemigas, siempre `salvajes.tramo_obediencia`. Nunca se guarda. Está en `ContextoCombate.obediencia`.
  - Cortes compartidos: `EstadosUnidad.corte(valor, neutral_desde, umbral)` (`enum Corte`) lo usan `lealtad()` y la obediencia. Dudosa = `desleal_hasta + 1` hasta `neutral_desde − 1` (P-028: `dudosa_hasta` salió en T15).
  - `HambreCombate` (`nucleo/combate/hambre_combate.gd`, en `ContextoCombate.hambre_combate`): `cerrar_ronda(ronda, plantel)` → `null` o los cambios. La llama `Combate._cerrar_ronda`; el evento `hambre_combate` va después del `fin_ronda`, también con `cambios` vacío.
  - `Arrimo` (`nucleo/combate/arrimo.gd`): `Arrimo.pasos(maestro)` y `ajuste(pasos, Arrimo.Uso)`. No la usa ninguna regla ni está en el contexto. Fixture `pruebas/fixtures/combate/arrimo.json`.
  - P-003: salió `obediencia.baja.hasta` (esquema, datos y fixture). La huella cambió.
  - La `instantanea` y el resultado llevan `hambre` (`null` en las enemigas). Esquema `resultado`: `unidades[].hambre`.
  - Pantalla: `LecturaCombate` muestra la obediencia en el panel y en el tooltip de la tribu, y el suceso `hambre_combate`. En `ClavesTextos`: `PANEL_OBEDIENCIA`, `COMBATE_HAMBRE` y `tramo_obediencia(tramo)`. Faltan en `es.json`: `panel.obediencia` y `obediencia.tramo.*`.
  - Fixture `pruebas/fixtures/combate/escenario_hambre_combate.json`: tablero de 3 × 40, nadie llega a pelear antes de la ronda 10.
- T15 (afinidad por adyacencia) mergeada a `develop`.
  - `Afinidad` (`nucleo/combate/afinidad.gd`, en `ContextoCombate.afinidad`, con las `Relaciones` y la `Obediencia` del contexto): `aporte(atacante_id, desde, plantel)` → `ModificadorDanio` (`AFINIDAD`, plano `combate.json` `afinidad_danio_plano`) o `null`; `son_afines(a, b, plantel)`. Mira desde `desde`, sin contar a la atacante; mismo bando, `Objetivos.de_pie`, oculta incluida; Maestro–criatura por tramo `leal`, preguntado en el momento. Sin estado.
  - `Turno._aportes` devuelve la afinidad; `Danio` no cambió.
  - P-028: salió `dudosa_hasta` (esquema `lealtad`, datos y fixture). La huella cambió.
  - Fixtures: `pruebas/fixtures/combate/escenario_afinidad.json` (todas estacionadas en los bordes; cada test acomoda las suyas) y `relaciones_junco_afin.json` (par inventado Rodauva–Zancajunco, solo para el test de la oculta).
- T16 (cadenas y combos) mergeada a `develop`.
  - `Afinidad.relacion_afin(a, b, plantel)`: qué es afín, sin posición ni estado. `son_afines` = las dos de pie + `relacion_afin`.
  - `Combo` (`nucleo/combate/combo.gd`, regla sin estado, en `ContextoCombate.combo`): `bono_par(anterior, atacante, plantel)` = `combate.json` `combo.sin_relacion_pct` / `afines_pct` + `Arrimo.ajuste(Arrimo.pasos(maestro), COMBO)`; `bono(eslabon, ...)` divide por `divisor_por_eslabon` k − 2 veces (S-27). Relación del par por `relacion_afin` (S-28).
  - `Cadena` (`nucleo/combate/cadena.gd`, estado, dueño el `Combate`): `aporte`, `eslabon_para` (calcular sin aplicar), `atacar` (solo la tribu; otra objetivo → `otro_objetivo` y eslabón 1), `cortar(motivo)` (un solo `cadena_cortada`), `revisar_objetivo` (`objetivo_fuera` por `Objetivos`), `historial`, `instantanea`. Constantes `MOTIVO_*`.
  - `Turno.empezar(entrada, plantel, tablero, danio, surcos, afinidad, cadena)` (las dos obligatorias). `_aportes` suma el combo; `_atacar_desde` pone `ResultadoAccion.eslabon` y solo al aplicar avanza la cadena; `_resolver` llama a `revisar_objetivo` después de cada acción aplicada. Los tests con un `Turno` suelto pasan `DatosFixture.afinidad()` y `DatosFixture.cadena()` (una nueva cada vez; también `DatosFixture.combo()`).
  - `Combate`: corta con `enemiga` al empezar el turno de una enemiga (detrás de `turno`), con `fin_ronda` en `_cerrar_ronda` (detrás del hambre de combate) y con `fin_combate` en `_terminar` (antes de `fin`); vuelca los cortes de la acción detrás de los surcos. Evento `ataque` con `eslabon`; `instantanea()["cadena"]`. P-029: `objetivo_fuera` gana a `fin_combate`.
  - Pantalla: `LecturaCombate.panel_turno()` suma la cadena en curso (`ClavesTextos.PANEL_CADENA`, falta en `es.json`). El combo sale en el desglose como "Cadena".
  - Fixtures: `escenario_cadena.json` (como el de afinidad, con `tasajero_s1`) y `escenario_cadena_combate.json` (para el `Combate`; `rodauva_s1` encerrada por dos caídas solo termina). `DatosFixture` carga `tablas/arrimo.json`.
- T41 (vecinas en 8 y hambre cada 6) mergeada a `develop`.
  - `Tablero.es_vecina_en_8(a, b)` (estática, Chebyshev 1): la única consulta de "vecina en 8" (D-001). `vecinas`/`adyacentes` siguen siendo las 4 del cuerpo.
  - `Afinidad.afines_vecinas(atacante_id, desde, plantel)` (ids en el orden del Plantel); `aporte` la usa (máximo +1). `Combate.afines_desde(unidad_id, casilla)` (calcular sin aplicar).
  - Pantalla: capa `Tablero/Afines` (marca `7:0`), `VistaCombate.casillas_afines()`; el hover sobre una casilla para mover o la propia marca las afines y suma `afinidad.tooltip` (`ClavesTextos.AFINIDAD_TOOLTIP`) al aviso.
  - `datos/tablas/hambre.json` `combate.cada_rondas` = 6 (7.2 v1.6; la huella cambió). Fixture `pruebas/fixtures/combate/hambre_cada_6.json`; el de T14 sigue en 5.
- T42 (cámara móvil) mergeada a `develop`. Solo `pantalla/` (D-003).
  - `EncuadreCamara` (`pantalla/combate/encuadre_camara.gd`, estática, sin nodos): `limites(esquina_a, esquina_b, margen)`, `acotar_zoom`, `acotar_centro(centro, visible, limites)` (centrada en el eje donde lo visible es más grande), `entra_entero`, `inicial(...)` → `{centro, zoom}` (encuadra entero con el zoom más cercano a 1, o centra en el Maestro).
  - `VistaCombate`: `@export zoom_minimo`, `zoom_maximo`, `paso_zoom` (se suma), `velocidad_camara`, `margen`; `camara()`, `limites_camara()`, `casilla_bajo_mouse()`, `mover_camara(desplazamiento)`, `acercar()`, `alejar()`. El encuadre se hace una vez, en `empezar` (`_encuadrar`): `_dibujar_tablero` ya no mueve la cámara. Mover la cámara rearma el hover si cambió la casilla bajo el mouse. Anda durante la secuencia de la IA.
  - InputMap: `camara_arriba`/`abajo`/`izquierda`/`derecha` (flechas y WASD), `camara_acercar`/`alejar` (rueda), `camara_arrastrar` (botón del medio).
  - Fixture `pruebas/fixtures/pantalla/escenario_12x12.json`. Tests en `pruebas/pantalla/test_encuadre_camara.gd` y `test_vista_camara.gd` (este, con los 11 de `datos/` y `principal.tscn`).
- T43 (escenarios en 12 × 12 y test de contacto) mergeada a `develop`, pendiente de la aprobación de Sistemas (P-030). Sin cambios en `nucleo/` ni en `pantalla/`.
  - `datos/tablas/combate.json` `despliegue_filas` = 3 (11.3 v1.6; la huella cambió). A a F y H en 12 × 12, con las coordenadas de P-030; G sigue en 8 × 8. C y H comparten coordenadas, y también las tres D y las dos E.
  - Test permanente `pruebas/datos/test_contacto.gd` (con `datos/` real): juega cada escenario esperando y comprueba los criterios de 11.9 v1.6 con el registro, la `instantanea` y las consultas del núcleo. Si una tarea lo hace fallar, ver "Test de contacto" arriba.
  - `test_datos_completos.gd::test_a_dia_1_es_el_ejemplo_de_a2` ya no compara el tablero ni las posiciones (ni sus `_nota`).
- T17 (Secundar) mergeada a `develop`.
  - `Accion.secundar(aliado_id)` (`{"tipo": "secundar", "aliado"}`; esquema `grabacion`). Motivos nuevos: `SALVAJE_NO_SECUNDA`, `SECUNDAR_A_SI_MISMA`, `ALIADA_DE_OTRO_BANDO` y `ALIADA_SIN_ENTRADA_PENDIENTE`. Con el turno usado, `YA_SE_MOVIO` / `ACCION_USADA` (S-29).
  - `ColaIniciativa`: `pendiente`, `lugar_de`, `orden_si_secunda` (sin aplicar) y `secundar`, las dos con `_reordenar`. `EntradaCola.vuelve`: la entrada del turno que vuelve.
  - `Turno.empezar(..., cadena, cola)`: la cola es **obligatoria**; los tests con un turno suelto pasan `ColaIniciativa.new()`. Con `entrada.vuelve` no corre `_inicio_del_turno` (S-31). `_motivo_puede_secundar` es el único lugar de la regla: **T19 completa ahí** enconada y acobardada. `puede_secundar()`, `aliadas_para_secundar()` y `cola_si_secunda(aliado_id)`. Secundar cierra el turno sin `_fin_del_turno`.
  - `Combate`: evento `secundar` (`unidad`, `detras_de`, `lugar`) y, al volver, `turno_vuelve` (`unidad`) en lugar de `turno`.
  - Pantalla: botón `Secundar` (solo con aliadas válidas), `VistaCombate.pulsar_secundar()` y `eligiendo_aliada()`, cola resultante con el mouse sobre una aliada (`LecturaCombate.filas_cola_si_secunda`), `InterpreteClic.accion(..., modo_secundar)` y `aliada_en`. `ClavesTextos.ACCION_SECUNDAR`.
- T18 (incidentes con rival aliada) mergeada a `develop`. Sin cambios de datos: la huella no cambió.
  - `Incidente` (`nucleo/combate/incidente.gd`, regla sin estado, en `ContextoCombate.incidente`): `rivales_vecinas(id, casilla, plantel)` (mismo bando, `Objetivos.de_pie`, `mal`, `Tablero.es_vecina_en_8`; hoy solo criaturas de la tribu: **T20 suma las salvajes ahí**, sin Arrimo), `consulta` → `{rivales, porcentaje}` (base + `Arrimo.ajuste(..., INCIDENTE)`, piso 0), `tirar(id, plantel, azar)` (con 0 % no toca el generador) y `se_distrae(criatura, maestro)`. `Porcentajes.tirar(azar, pct)`: `entero(1, 100) <= pct`, la convención de las tiradas en % (para T19 y T25).
  - `Turno.empezar(..., cola, incidente, azar)`: los dos **obligatorios**; los tests con un turno suelto pasan `DatosFixture.incidente()` y `GeneradorAzar.new(1)`. El paso 4 (`_chequear_incidente`) corre después de `_preparar` y no corre con `entrada.vuelve`. **T19 pone ahí** "la enconada no tira". `Turno.incidente` (`{rivales, porcentaje, resultado, objetivo}`) y `golpe_incidente`; `RESULTADO_DISTRAIDA` / `RESULTADO_GOLPE`. Distraída = `accion_usada` y sin ataques. El golpe: `_atacar_desde(..., por_incidente)` (aliada, solo afinidad, `eslabon` nulo, corta la cadena con `otro_objetivo` sin empezar otra, gasta todos los ataques).
  - `Combate`: evento `incidente` (`unidad`, `rivales`, `porcentaje`, `resultado`, `objetivo`) detrás de `turno` y su `tirada`; el golpe además como `ataque` con `eslabon: null`. Si la tirada no sale, solo `tirada`. `cambio_modo` se registra sin volcar tiradas (`_registrar(evento, false)`). `incidente_en(id, casilla)` (calcula sin aplicar).
  - Pantalla: capa `Tablero/Rivales` (marca `8:0`), `VistaCombate.casillas_rivales()`; el hover (casilla para mover o la propia) marca las rivales y suma `incidente.tooltip` con `{porcentaje}` si es > 0. Suceso `incidente` con `incidente.distraida` / `incidente.ataque` y sujeto `<especie>.<rival>`. `ClavesTextos.INCIDENTE_*`.
  - `DatosFixture.cargar(combate)` e `incidente(combate)`. Fixtures `combate_incidente_100.json`, `combate_incidente_0.json`, `escenario_incidente.json` (balanza 5) y `escenario_incidente_combate.json`.
- T19 (Encono y cobardía) mergeada a `develop` (dos sesiones). Sin cambios de datos: la huella no cambió.
  - `ChequeoRival` (`nucleo/combate/chequeo_rival.gd`, regla sin estado, en `ContextoCombate.chequeo_rival`, con el toggle `afines_contra_cobardia` del escenario): `tipo(criatura)` por `rol`, `es_rival_enemiga`, `rivales_a_su_alcance(id, casilla, plantel)` (hoy solo la tribu: **T20 suma las salvajes ahí**), `consulta` → `{tipo, rivales, porcentaje, seguro}`, `tirar` (una tirada; con 0 % no toca el generador; con el contador en el máximo, enconada sin tirar), `sumar_golpe` (todo golpe de combate o mixta a su rival enemiga, cualquier bando; devuelve el evento `encono`), `aporte_encono` y `aporte_cobardia`.
  - `Objetivos.cuenta_como_rival_a_su_alcance(..., desde)` opcional. `Criatura.encono` (el `Cierre` lo vuelve a 0; en la `instantanea`).
  - `Turno.empezar(..., regla_incidente, regla_chequeo, azar)`: **obligatorio**; los tests con un turno suelto pasan `DatosFixture.chequeo_rival(combate, toggle, relaciones)`. Públicos `chequeo_rival`, `enconada`, `acobardada` y `obligacion` (`Turno.Obligacion`: `NINGUNA`, `ATACAR`, `ACERCARSE`). La que no alcanza pierde la acción como la distraída. La enconada no tira incidente. Motivos nuevos: `ENCONADA`, `ACOBARDADA`, `CASILLA_SIN_RIVAL`, `OBJETIVO_NO_RIVAL`, `DEBE_ATACAR_RIVAL`, `CASILLA_NO_ACERCA`, `DEBE_ACERCARSE` y `MAS_CERCA_DE_RIVAL`.
  - `Combate`: evento `chequeo_rival` (`unidad`, `tipo_chequeo`, `rivales`, `porcentaje`, `tiro`, `resultado`; P-037) detrás de `turno`, `cambio_modo` y su `tirada`, antes del incidente; `encono` detrás del `ataque` (por `_registrar_eventos_turno`, antes `_registrar_junco`). `_registrar(evento, tiradas)`: cuántas tiradas pendientes vuelca (−1 = todas). `rival_en(unidad_id, casilla)`.
  - `test_contacto.gd`: el ayudante juega lo mínimo que obliga una regla (`_jugar_lo_obligado`).
  - Pantalla (sesión 2): capa `Tablero/RivalesEnemigas` (marca `9:0`, rombo violeta) y `VistaCombate.casillas_rivales_enemigas()`. El hover (casilla para mover o la propia) marca las rivales de `Combate.rival_en` y suma `encono.tooltip` / `cobardia.tooltip` si es > 0. `LecturaCombate.boton_terminar()` (`{texto, habilitado, motivo}`; sale `texto_terminar`): el botón sigue `puede_terminar()` y el motivo (`ClavesTextos.motivo_terminar`) va en su tooltip y al final de `panel_turno()`. Marcas `marca.enconada` / `marca.acobardada` de la unidad del turno; contador `panel.encono` n/máx en el tooltip (rama Encono, también en 0) y en la ficha (si > 0). Sucesos de `chequeo_rival` (reacción del par o de la especie si existe, si no la general; `no_enconada` sin línea) y `encono`. Consultas nuevas: `ChequeoRival.maximo_encono()` y `ArmadorTextos.tiene(clave)`. Faltan en `es.json`: `marca.enconada`, `marca.acobardada`, `panel.encono`, `aviso.terminar.debe_atacar_rival` y `aviso.terminar.debe_acercarse`. Fixture `pruebas/fixtures/pantalla/escenario_cobardia_pantalla.json`.
  - Fixtures: `combate_rival_100.json`, `combate_rival_0.json`, `combate_sin_rival.json` (aísla el incidente en `test_incidente.gd`), `escenario_rival.json` (12 × 12), `escenario_rival_combate.json`, `escenario_caza_tribu_encono.json`, `especie_rival_prueba.json` y `relaciones_rival_prueba.json`.
- T20 (las enemigas tiran y la IA que los respeta) mergeada a `develop` (dos sesiones). Sin cambios de datos: la huella no cambió.
  - `Arrimo.pasos_de(criatura, maestro)`: 0 para las enemigas (10.7). Es el único lugar de esa regla; lo usan `ChequeoRival` e `Incidente`.
  - `ChequeoRival` e `Incidente` valen para cualquier bando (sale el corte de la tribu). La cobardía de una enemiga no recibe el −10 del Maestro vecino (S-41). El empate del golpe del incidente es el orden del Plantel, que para las enemigas es el de `enemigas` (P-011).
  - `Turno`: `previsualizar_ataque(desde, objetivo, tras_primer_ataque)` (el segundo ataque de Caza, sin la obligación del Encono; a la misma rival lleva el punto de Encono del primero: `ChequeoRival.aporte_encono(criatura, golpes_previos)`) y `casillas_para_retirarse(desde, objetivo)` (la retirada filtrada por `_motivo_destino_rival` como quedaría después del golpe; los ayudantes reciben `sin_rival`).
  - IA (D-005): paso 3 en `IASalvaje._paso_encono` (`DecisionIA.Paso.ENCONO`, "paso 3"; en el registro, `paso: "encono"`). Elige la rival con `_DESEMPATE_ENCONO` (`Criterio.PUEDE_TUMBAR` nuevo), ataca como la tabla de 11.8, se acerca (S-43, `_encono_acercarse`) o juega la Caza enconada (S-42, `_encono_caza`). La clave del 6b vive en `_clave_caza(presas, golpes, casilla)` (con una presa, "tumba" suma los golpes planeados) y el armado en `_decision_caza`. `_retirada` usa `casillas_para_retirarse`. La acobardada y la distraída no tienen código propio: los pasos 4 a 8 ya toman todo del `Turno`.
  - Fixtures: `escenario_rival_salvajes.json` (12 × 12, con atacante nocturna) y `escenario_rival_salvajes_combate.json`. Tests: `pruebas/combate/test_rival_salvajes.gd` y `pruebas/combate/ia/test_ia_encono.gd`.
  - Robustez (A.6): `pruebas/datos/test_robustez_ia.gd` (11 escenarios × 10 semillas, jugador esperando, hasta la ronda 12; ningún `error()`). El jugador esperando es `JugadorEsperando.lo_obligado(combate)` (`pruebas/datos/jugador_esperando.gd`), que también usa `test_contacto.gd`.
  - Pantalla: el tooltip de una enemiga suma `encono.tooltip` / `cobardia.tooltip` con su especie como sujeto (`Combate.rival_en` en su casilla, si es > 0). `LecturaCombate.marca_estado(id, estado)`. Durante la secuencia de la IA, cada paso de `SecuenciaIA` lleva `estado` (del `chequeo_rival` de su turno) y la ficha de la que actúa muestra la marca (`FichaUnidad.mostrar_marca`, `texto_marcas`). Tests en `pruebas/pantalla/test_vista_rival_salvajes.gd`.
- T20-ajustes (mouse por evento, D-006) mergeada a `develop`. Solo `pantalla/` y sus tests.
  - `VistaCombate` guarda la posición del último `InputEventMouse` en `_input`. `_casilla_del_mouse()` es la única conversión (inversa de `get_global_transform_with_canvas()` + `local_to_map`); sin evento todavía, `Criatura.SIN_POSICION` y no hay hover. `casilla_bajo_mouse()` sigue siendo la casilla del último hover.
  - Tests de pantalla: el mouse se manda con `Input.parse_input_event` + `Input.flush_buffered_events()` y se comprueba sin `await` en el medio. Nunca `simulate_mouse_*`, que hace `warp_mouse`. El único `warp_mouse` es el de `test_el_cursor_real_no_cambia_la_casilla`.
- T21 (maná del Maestro en combate) mergeada a `develop`. Sin cambios de datos: la huella no cambió.
  - `Maestro.mana_entrada` es un `int`, resuelto en el `Plantel` (`null` → `reserva_mana` de su fila de balanza). Es el tope y no cambia. `Maestro.mana` es el actual.
  - `RegeneracionMana` (`nucleo/combate/regeneracion_mana.gd`, sin estado, en `ContextoCombate.regeneracion_mana`): `aplicar(maestro, ronda)` → `{de, a}` o `{}`, según `hambre.json` `regen_combate`. `MOTIVO_REGENERACION`.
  - `Turno.empezar(..., regla_chequeo, regla_mana, azar)`: **obligatorio**. Los tests con un turno suelto pasan `DatosFixture.regeneracion_mana()`. Paso 1 de `_inicio_del_turno`, solo para el Maestro. `Turno.mana`.
  - `Combate`: evento `mana` (`unidad`, `de`, `a`, `motivo`) justo detrás del `turno` del Maestro, solo si cambia (D-007). **T22, T24, T26 y T27 suman su motivo** al mismo evento. `instantanea()["maestro"]["mana"]`. Resultado `maestro.mana` entero (esquema sin `null`).
  - `Cargador._chequear_mana_entrada`: `mana_entrada` > reserva de su balanza → error.
  - Pantalla: `panel.mana` actual/tope en el panel y el tooltip del Maestro (`ClavesTextos.PANEL_MANA`, falta en `es.json`).
  - Fixtures: `pruebas/fixtures/combate/escenario_mana_combate.json` (3 × 40; los tests bajan el maná a mano antes de `Combate.empezar`) y `pruebas/fixtures/cargador/escenario_mana_entrada/`.
- T21-ajustes (reglas del turno en un solo objeto, D-008) mergeada a `develop`. Refactor puro: sin cambios de reglas, datos ni huella.
  - `ReglasCombate` (`nucleo/combate/reglas_combate.gd`): `danio`, `afinidad`, `combo`, `incidente`, `chequeo_rival` y `regeneracion_mana`, todas obligatorias. Una nula deja su nombre en `falta` y hace `push_error`. `REGLAS` es la lista que se revisa. **Una regla nueva (T22 en adelante) se suma ahí** (campo, `_init` y `REGLAS`), en `ContextoCombate.armar` y en `DatosFixture.reglas`, no en la firma del `Turno`.
  - `ContextoCombate.reglas`; las seis propiedades sueltas siguen como acceso de lectura.
  - **Firma vigente** (reemplaza lo que dicen arriba T16 a T21 sobre parámetros del turno): `Turno.empezar(entrada, plantel, tablero, surcos, cadena, cola, reglas, azar)`. Los tests con un turno suelto pasan `DatosFixture.reglas()` o `DatosFixture.reglas({"chequeo_rival": ..., ...})` para reemplazar alguna regla.
- T44 (escala ×10 de vida y daño y respuestas de `Sistema.md` v1.7, D-009) mergeada a `develop`.
  - `datos/` en la escala ×10 (11.1 v1.7): fichas, `tablas/balanza.json` (vida y daño), `combate.json` (`danio_minimo`, `vida_tras_caida`, `afinidad_danio_plano` y `encono.danio_plano_por_punto` en 10), el choque de la Lanzadera en `hechizos.json` (10) y la vida del Maestro de F (60). La huella cambió. Las `base` de Martillazo y Remiendo siguen viejas: las pasa T22. **Los fixtures no cambian** (D-009): sus números prueban mecánicas.
  - `ChequeoRival`: el piso del toggle sigue P-040 (`max(sin_afines − afines, min(sin_afines, minimo_pct))`). `consulta` suma `sostenida_por` y `afin`. `tirar` y el evento `chequeo_rival` los llevan **solo** en una `resistida`: `sostenida_por` (`SOSTENIDA_MAESTRO` / `SOSTENIDA_AFIN` / `null`), y `afin` (la primera afín del toggle, en el orden del Plantel) solo si es `"afin"` (P-041).
  - Pantalla: la resistida muestra `cobardia.resiste.maestro` o `cobardia.resiste.afin` (`{a_afin}`), con su variante de especie, y la general con `null` o sin la clave. `ClavesTextos.COBARDIA_RESISTE_MAESTRO` y `COBARDIA_RESISTE_AFIN` son fijas.
  - Tests: `pruebas/combate/test_cobardia_v17.gd` (fixtures, con una copia en memoria de `combate.json` para las bases que no tienen) y `pruebas/datos/test_escala_x10.gd` (`datos/` real).
- T22 (hechizos del Maestro) mergeada a `develop` (dos sesiones).
  - Datos (D-010): esquema `hechizos` con `por_poder` (sale `escala_poder`); `datos/hechizos.json` Martillazo 20 + 10 × Poder, Remiendo 30 + 10 × Poder (la huella cambió). Fixtures `pruebas/fixtures/combate/hechizos.json` (2/1, 3/1, choque 1) y `hechizos_choque_4.json`; `DatosFixture.cargar` suma `hechizos.json`.
  - `Hechizos` (`nucleo/combate/hechizos.gd`, en `ReglasCombate.hechizos` y `ContextoCombate.hechizos`): `ids()` (los de `maestro.json`), `hechizo(id)`, `valor(id, poder)`; constantes `EFECTO_*`, `GEOMETRIA_*`, `SENTIDO_*` y `MOTIVO_HECHIZO`. `DatosFixture.hechizos(archivo)` y `DatosFixture.reglas({"hechizos": ...})`.
  - `ContextoCombate.armar`: con `ReglasCombate.falta` no vacío, `Motivo.REGLA_FALTANTE` y `regla_faltante`.
  - `Danio.calcular_con_base(base, ...)`: el mismo 11.4 con otra base. `Turno._golpear` es el golpe compartido por el ataque y el Martillazo.
  - `Accion.hechizo(hechizo_id, objetivo_id, sentido = "")` (`Tipo.HECHIZO`; `{"tipo": "hechizo", "hechizo", "objetivo"[, "sentido"]}`; esquema `grabacion`). Motivos nuevos: `SOLO_MAESTRO`, `HECHIZO_INEXISTENTE`, `MANA_INSUFICIENTE`, `OBJETIVO_PROPIO`, `OBJETIVO_ENEMIGO`, `ATRAER_ADYACENTE`, `SENTIDO_INVALIDO`. `ResultadoAccion.mana`, `evento` y `destaparia`.
  - `Turno`: `objetivos_para_hechizo(id)`, `sentidos_para_hechizo(id, objetivo)` y `previsualizar_hechizo(id, objetivo, sentido)` (= `validar`). El comportamiento sale de `efecto` y `geometria`, nunca del id.
  - `Combate`: `accion` → `mana` (motivo `hechizo`) → `ataque` (Martillazo) o `lanzadera` / `remiendo` → destape, estado, surco, cadena.
  - Tests: `pruebas/combate/test_martillazo.gd`, `test_lanzadera.gd`, `test_remiendo.gd`, `test_hechizos.gd`, `test_hechizos_combate.gd` (ayudante `mesa_hechizos.gd`, `MesaHechizos`), fixtures `escenario_hechizos.json` y `escenario_hechizos_combate.json`.
  - Sesión 2, núcleo:
    - P-042: con `choque: true`, el evento `lanzadera` lleva `contra` (el id de la unidad del destino, o `null` si fue el borde o un surco). Lo busca `Turno._ocupante_en`.
    - `Turno.motivo_hechizo(id)`: los chequeos previos a la objetivo están en `_motivo_lanzar`, compartido con `_hechizo`. Motivo nuevo `SIN_OBJETIVOS`.
  - Sesión 2, pantalla:
    - `LecturaCombate.botones_hechizos()` (`{id, texto, tooltip, habilitado}`), `vista_previa_hechizo(previas)` y los sucesos de `accion` hechizo, `lanzadera` y `remiendo`.
    - `VistaCombate`: botones `Hechizo_<id>`, `pulsar_hechizo(id)`, `hechizo_elegido()`, `hechizo_mostrado()`, `casillas_destino_hechizo()` (capa `Tablero/DestinosHechizo`, marca 6:0) y `clic_casilla(casilla, alterno)`. Los modos cavar, Secundar y hechizo se excluyen entre sí.
    - `InterpreteClic.accion(..., hechizo_id, alterno)` y `objetivo_hechizo_en`.
    - `ClavesTextos`: `nombre_hechizo`, `tooltip_hechizo`, `sentido_hechizo`, `motivo_hechizo` y las constantes `LANZADERA_CHOQUE*` y `AVISO_HECHIZO_*`.
    - InputMap: `seleccionar_alterno` (clic derecho: atraer).
    - Faltan en `es.json`: `aviso.hechizo.{mana_insuficiente,accion_usada,sin_objetivos}`, `hechizo.sentido.{empujar,atraer}` y `lanzadera.choque.obstaculo`.
  - Sesión 2, tests: `pruebas/combate/test_motivo_hechizo.gd`, `pruebas/pantalla/test_vista_hechizos.gd`, `test_lectura_hechizos.gd` y `pruebas/datos/test_lanzadera_b.gd` (`datos/` real: en el turno 2 del Maestro, ir a [4,8] y atraer a `ocarra_s2`). Fixtures `pruebas/fixtures/pantalla/hechizos.json` (`pedrada`) y `maestro_hechizos.json`.
- T23 (métricas desde el registro, D-011) mergeada a `develop`. Cerró el hito 0a.2.
  - `Tablero`: `ocupante_en(casilla, plantel)` (sale `Turno._ocupante_en`; un solo criterio en `_ids_por_casilla`), `distancia_a_enemiga_de_pie(desde, bando, plantel)` (`Objetivos.de_pie`, oculta incluida; `null` sin ninguna) y `encerrada(casilla, plantel, surcos)` (4 ortogonales, `es_casilla_libre`).
  - `Combate`: detrás de cada `fin_turno` (`_registrar_tras_fin_turno`), `distancia_maestro` (`distancia`, solo el Maestro) y después `encierro` (`unidad`, `casilla`, solo cuando pasa).
  - `MetricasCombate.calcular(escenario, lineas)` (`nucleo/combate/metricas_combate.gd`, estática): claves `rondas`, `secundar`, `eslabones`, `incidentes`, `encono`, `cobardia`, `sellados` (null, T24), `capturas_perdidas` (null, T25), `caidas` (con el Maestro, P-043), `caidas_guardadas` (null, T27), `muertes`, `rescate` (null, T29), `distancia_maestro` y `activas`. Las métricas futuras se llenan ahí y en el esquema `resultado`.
  - `ResultadoCombate.metricas`: la llena `Combate._terminar` después del `cierre`. Esquema `resultado`: `metricas` objeto, con `$defs` locales.
  - `GuardadoCombate.guardar_resultado(combate, base)` y `SUFIJO_RESULTADO` (`_resultado.json`); `herramientas/salida_reproduccion.gd` (`SalidaReproduccion.escribir`), que usa `reproducir.gd`.
  - Tests: `pruebas/combate/test_metricas_combate.gd`, `test_eventos_metricas.gd` (fixture `escenario_eventos_metricas.json`), `pruebas/herramientas/test_salida_reproduccion.gd` y `pruebas/datos/test_metricas_escenarios.gd` (`datos/` real).
- **T24 (sellar)** mergeada a `develop` (una sesión). Primera tarea de la 0a.3. Sin datos nuevos: la huella no cambió.
  - `Sellado` (`nucleo/combate/sellado.gd`, sin estado, en `ReglasCombate.sellado` y `ContextoCombate.sellado`): `porcentaje(vida, vida_max, rango)` (comparación entera), `porcentaje_de(criatura)`, `costo(especie, maestro)`, `lealtad_inicial(maestro)`, `rango_permitido(especie, maestro)`, `alcance()`; `MOTIVO_SELLAR`, `RESULTADO_LOGRADO` / `RESULTADO_FALLIDO`. `DatosFixture.cargar` suma `tablas/sellado.json` y `tablas/costos_mana.json`; `DatosFixture.sellado(costos)`.
  - Apoyos: `Plantel.pergamino_en_blanco()`, `VidaCero.sacar_del_tablero(criatura, surcos)` (también la vida en 0; T25 la reusa), `Porcentajes.tiro` y `sale` (`tirar` = las dos).
  - `Accion.sellar(objetivo)` (`Tipo.SELLAR`; esquema `grabacion`). `ResultadoAccion`: motivos `SIN_PERGAMINO`, `OBJETIVO_NO_SALVAJE`, `NO_SELLABLE`, `RANGO_ALTO`; campos `porcentaje` y `costo`; `evento` lleva el `sellado` solo al aplicar.
  - `Turno`: `_motivo_sellar(id)` es el único chequeo (orden en `_ORDEN_SELLAR`, después de `_motivo_puede_sellar`); `objetivos_para_sellar()`, `motivo_sellar()` (la enemiga que más lejos llegó en el orden; `SIN_OBJETIVOS` sin enemigas) y `previsualizar_sellar(id)`. `Combate.porcentaje_sellado(id)` y `costo_sellado(id)` (salvaje de pie, sellable y de rango alcanzable; si no, `null`).
  - Registro: `accion` → `mana` (motivo `sellar`, sin volcar tiradas) → `tirada` → `sellado` (`objetivo`, `porcentaje`, `tiro` o `null`, `resultado`, `pergamino` o `null`) → `estado`, `surco_cerrado`, `cadena_cortada`.
  - Resultado: `capturas` = `[{unidad, especie, pergamino, lealtad}]` desde los pergaminos ocupados por salvajes (esquema: salen `id` y `camino`). Métrica 7 `sellados` = `[{objetivo, porcentaje, logrado}]`.
  - Pantalla: `LecturaCombate.boton_sellar()`, `vista_previa_sellar`, `marca_sellado`, `linea_sellado`, sucesos de `sellado` (y de la `accion` sellar). `VistaCombate`: botón `Sellar`, `pulsar_sellar()`, `eligiendo_sellar()`, `sellado_mostrado()`; modo excluyente con cavar, Secundar y hechizos. `InterpreteClic.accion(..., modo_sellar)` y `objetivo_sellar_en`. `ClavesTextos`: `ACCION_SELLAR`, `SELLAR_*`, `PERGAMINO_SIN_BLANCO`, `AVISO_SELLAR_*` y `motivo_sellar(motivo)`. Faltan en `es.json`: `aviso.sellar.{accion_usada,mana_insuficiente,fuera_de_alcance,no_sellable,oculta,no_salvaje,sin_objetivos}`.
  - Fixtures: `pruebas/fixtures/combate/sellado.json`, `costos_mana.json`, `costos_mana_chico.json`, `especie_sellar_r2.json`, `especie_no_sellable.json`, `escenario_sellar.json` y `escenario_sellar_combate.json`. Ayudante `pruebas/combate/mesa_sellar.gd` (`MesaSellar`). Tests: `pruebas/combate/test_sellado.gd`, `test_sellar.gd`, `test_sellar_combate.gd`, `pruebas/pantalla/test_lectura_sellar.gd`, `test_vista_sellar.gd` y `pruebas/datos/test_sellar_a.gd` (`datos/` real).
- **Abrir el juego:** F5 en el editor, o `& $env:GODOT_BIN --path .` (PowerShell). Con otra carpeta de datos, agregar `-- --datos=<carpeta>`.
- **Reproducir una grabación por consola** (escribe `registros/<nombre>.jsonl`, o `<nombre>_hasta_N.jsonl`; con los datos de `datos/`): `"%GODOT_BIN%" --headless --path . --script res://herramientas/reproducir.gd -- <grabacion.json> [N]`
- Tests de reglas con fixtures vía `pruebas/unidades/lector_fixture.gd`, y los datos completos de prueba con `pruebas/combate/datos_fixture.gd` (`DatosFixture.cargar()`, mismas claves que el `Cargador`). Con `datos/` real, además del permanente: `test_plantel_escenarios.gd` el test (9) de `test_combate.gd`, y en `pruebas/pantalla/` `test_principal.gd` (2, 10 sobre una copia temporal de `datos/`, y el clic real, y R durante una secuencia) y `test_vista_combate.gd` (con el test 7, C jugado con activas), y `pruebas/datos/test_p003.gd`, `test_p028.gd` y `test_hambre_v16.gd` y `test_escala_x10.gd` y `test_contacto.gd` y `test_robustez_ia.gd` y `test_lanzadera_b.gd` y `test_metricas_escenarios.gd` y `test_sellar_a.gd` y `test_invocar_a.gd` y `test_guardar_caida_a.gd`, y `test_vista_camara.gd`, y `test_plantel_escenarios.gd::test_t21_mana_de_entrada_de_los_escenarios`. 748 tests (la suite completa tarda unos 15 minutos). Los `Control` que tapan el tablero llevan `mouse_filter` IGNORE: si no, el clic no llega a `_unhandled_input`.
- `docs/PREGUNTAS.md`: P-024 `RESPONDIDA` (opción B: en una derrota, la atacante se va; se aplica en T30). P-003 `CERRADA` en T14. P-028 `CERRADA` en T15. P-008 `CERRADA` en T19. Siguen `RESPONDIDA` y se cierran en su tarea: P-002 y P-024 en T30. P-011 a P-023, `CERRADA` en T12. P-025 `CERRADA` en T27 (clase `CAIDA_PROPIA` de `Objetivos`). P-026, P-027 y P-029 `CERRADA` en T41. P-030 a P-036 y P-038 a P-040 `CERRADA` en T44 (respuestas de `Sistema.md` 15 v1.7). P-037 `CERRADA` en T20. P-041 `CERRADA` en T22. P-042 `CERRADA` en T22 (campo `contra` del evento `lanzadera`). P-043 `CERRADA` en T24 (la métrica 9 cuenta al Maestro). P-044 `CERRADA` en T24-ajustes (D-012).
- Al agregar un `class_name` nuevo, la caché de clases de Godot hay que refrescarla (abrir el editor o `--import`) antes de correr los tests: `runtest.cmd` no escanea. `runtest.cmd` corta en el primer test que falla de cada archivo; con `-c` sigue (sirve para listar todas las fallas).
- **T24-ajustes** (tests de mouse sin intermitentes, D-012) mergeada a `develop` (dos sesiones). Solo `pantalla/` y tests.
  - Causa: los tests mandaban la posición en coordenadas del viewport y `Input.parse_input_event` la toma en coordenadas de ventana (inversa de `get_final_transform()`); GdUnit4 minimiza y restaura la ventana entre runners. Además llegan el `warp_mouse` del runner y el cursor real.
  - `VistaCombate.dispositivo_mouse` (por defecto `DISPOSITIVO_CUALQUIERA`: el juego no cambia) y el filtro al principio de `_input` (otro device → `set_input_as_handled`).
  - `MousePrueba` (`pruebas/pantalla/mouse_prueba.gd`): `DISPOSITIVO`, `preparar(vista)`, `a_ventana(evento, final, dispositivo)` (pura: posición por `final`, `relative` por su parte lineal), `mandar`, `mover_a` y `clic_en`. La transformación es la de la ventana principal, leída al mandar.
  - Tests: `pruebas/pantalla/test_mouse_prueba.gd` (conversión sin ventana y ventana de 200 × 120) y `test_vista_dispositivo_mouse.gd`.
- **T25 (huida de las salvajes)** mergeada a `develop` (una sesión). Sin datos nuevos: la huella no cambió.
  - `Huida` (`nucleo/combate/huida.gd`, sin estado, en `ReglasCombate.huida` y `ContextoCombate.huida`): `porcentaje(id, plantel, acobardada)` (0 si no es salvaje de pie, si vida × 100 > umbral × vida_max o si el Encono está en el máximo), `porcentaje_al_empezar` (el único lugar de S-52: sin el +25) y `tirar` → `{}` o `{porcentaje, tiro, resultado}`; `RESULTADO_HUYE` / `RESULTADO_SE_QUEDA`. `DatosFixture.huida(combate)`.
  - `Turno`: paso 2 en `_inicio_del_turno` (`_huir`, después de borrar Erizarse y antes del cambio de modo). Si huye: `VidaCero.sacar_del_tablero` y `terminado`; `empezar` no prepara nada más. `Turno.huida`. Sale `IASalvaje._paso_huida`.
  - `Combate.porcentaje_huida(id)`. Registro: `turno` → `tirada` → `huida` (`unidad`, `porcentaje`, `tiro`, `resultado`) → si huye, `estado` y `surco_cerrado` → `fin_turno` con `posicion: null` (sin `encierro`); si gana, `fin` sin `fin_turno` (como toda acción que gana).
  - Métrica 8: `capturas_perdidas` = `[{unidad, motivo, ronda}]` (`MetricasCombate.MOTIVO_HUIDA` / `MOTIVO_CERO`), desde el evento que precede al `estado` `fuera`; necesita `comportamiento` en las enemigas del escenario. Esquema `resultado` actualizado.
  - Pantalla: marca `LecturaCombate.marca_huida` (`marca.huida` + " N%") y tooltip `linea_huida` (`huida.salvaje.porcentaje`), los dos faltan en `es.json`; suceso `huida` (`huida.salvaje.<especie>`; `huida.salvaje.se_queda` solo si existe). `ClavesTextos`: `MARCA_HUIDA`, `HUIDA_PORCENTAJE`, `HUIDA_SALVAJE`, `HUIDA_SE_QUEDA`.
  - Fixtures: `pruebas/fixtures/combate/especie_huida_100.json`, `especie_huida_1.json`, `escenario_huida.json` (ayudante `MesaHuida`), `escenario_huida_combate.json`, `escenario_huida_tasajero.json` y `pruebas/fixtures/pantalla/escenario_huida_pantalla.json`.
- **T26 (guardar e invocar en combate)** mergeada a `develop` (una sesión). Sin datos nuevos (solo el esquema `grabacion`): la huella no cambió.
  - `CostosMana` (`nucleo/combate/costos_mana.gd`, sin estado, en `ReglasCombate.costos_mana` y `ContextoCombate.costos_mana`): `sellar(especie, maestro)` e `invocar(especie, maestro)` con un solo `_con_descuento` (2.3); `MOTIVO_INVOCAR`. `Sellado.desde_datos(tabla_sellado, costos: CostosMana, ...)` recibe la misma instancia y `Sellado.costo` delega. **T27 suma ahí** `guardar_caida`. `DatosFixture.costos_mana(archivo)`.
  - `Accion.guardar()` y `Accion.invocar(criatura_id, casilla)` (`{"tipo": "invocar", "criatura", "casilla"}`; esquema `grabacion`). `gasta_turno_completo` suma INVOCAR. Motivos nuevos: `SOLO_CRIATURA_DE_LA_TRIBU`, `NO_GUARDADA` y `SIN_CASILLA_LIBRE`.
  - `Turno`: `_motivo_guardar()` y `_motivo_invocar(id, casilla = SIN_POSICION)` (sin casilla = la consulta) son los únicos chequeos; `_dejar_guardada(criatura)` es el efecto de guardar (**T27 lo reusa**). Consultas: `motivo_guardar()`, `guardadas_para_invocar()`, `casillas_para_invocar()`, `motivo_invocar(id)` y `previsualizar_invocar(id, casilla)` (costo, maná, `destaparia`, evento). Guardar termina el turno (S-54); invocar gasta el turno completo (S-53).
  - `Junco.destaparia_al_entrar(id, casilla, plantel)`: la regla del contacto sin mirar si está de pie (la usa `destaparia`).
  - `Combate`: guardar → `accion`, `estado`, `surco_cerrado`, `fin_turno` con `posicion: null` (sin `distancia_maestro` ni `encierro`); invocar → `accion`, `mana` (motivo `invocar`), `estado`, `invocacion` (`unidad`, `casilla`), `destape`. `Combate.costo_invocar(id)` (`null` si no es una guardada de la tribu).
  - Pantalla: `LecturaCombate.boton_guardar()` y `botones_invocar()`, sucesos de la `accion` guardar (`guardar`) y de `invocacion` (`invocar`). `VistaCombate`: botón `Guardar` (`pulsar_guardar`), botones `Invocar_<id>` (`pulsar_invocar(id)`, `invocando()`, `casillas_marcadas()`), modo excluyente con los demás, aviso de destapar en el hover. `InterpreteClic.accion(..., criatura_invocar)`. `ClavesTextos`: `ACCION_GUARDAR`, `GUARDAR`, `GUARDAR_TOOLTIP`, `ACCION_INVOCAR`, `INVOCAR`, `INVOCAR_TOOLTIP`, `AVISO_INVOCAR_*` y `motivo_invocar(motivo)`. Faltan en `es.json`: `aviso.invocar.{ya_se_movio,accion_usada,mana_insuficiente,sin_casilla_libre}`.
  - Fixtures: `pruebas/fixtures/combate/escenario_guardar.json` (ayudante `MesaGuardar`, que también arma `escenario_rival.json` y `escenario_incidente.json`) y `escenario_guardar_invocar_combate.json`. Tests: `pruebas/combate/test_costos_mana.gd`, `test_guardar.gd`, `test_invocar.gd`, `test_guardar_invocar_combate.gd`, `pruebas/pantalla/test_lectura_guardar_invocar.gd`, `test_vista_guardar_invocar.gd` y `pruebas/datos/test_invocar_a.gd` (`datos/` real).
- **T27 (guardar a una caída)** terminada en la rama `tarea/T27-guardar-caida` (una sesión), pendiente de PR a `develop`. Dato nuevo: la huella cambió.
  - Datos: `tablas/combate.json` `vida_al_guardar_caida` = 10 (esquema `combate`, requerido; 11.5 y 11.1 v1.7). Los seis `combate*.json` de `pruebas/fixtures/combate/` lo llevan en 1 (D-009). El costo es la fila `guardar_caida` de `costos_mana.json` y el alcance, `alcance_guardar_caida`.
  - `ReglasCombate.REGLAS`: una regla que otras usan va antes que ellas (`costos_mana` antes que `sellado` y `guardado_caida`). Sin `costos_mana.json`, el rechazo nombra `costos_mana`. `_init` suma `regla_guardado_caida` al final.
  - `CostosMana.guardar_caida(especie, maestro)`. `GuardadoCaida` (`nucleo/combate/guardado_caida.gd`, en `ReglasCombate.guardado_caida` y `ContextoCombate.guardado_caida`): `costo`, `alcance`, `vida` y `MOTIVO_GUARDAR_CAIDA`. `DatosFixture.guardado_caida(costos)`.
  - `Objetivos.Clase.CAIDA_PROPIA` (P-025): exige estado `CAIDA` en el tablero; a una de pie (y al Maestro), `OBJETIVO_NO_CAIDO` (motivo nuevo). `ALIADA` no cambió.
  - `Accion.guardar_caida(objetivo)` (`Tipo.GUARDAR_CAIDA`; esquema `grabacion`). `ResultadoAccion.vida` (`{de, a}`).
  - `Turno`: `_motivo_guardar_caida(id)` es el único chequeo (orden en `_ORDEN_GUARDAR_CAIDA`, después de `_motivo_puede_guardar_caida`: turno terminado, solo el Maestro, acción usada); después `CAIDA_PROPIA`, de la tribu (`OBJETIVO_ENEMIGO`), Manhattan ≤ alcance sin línea (S-57) y maná. El efecto reusa `_dejar_guardada` y pone la vida del dato; gasta la acción, no el movimiento. Consultas `objetivos_para_guardar_caida()`, `motivo_guardar_caida()` (solo mira a las caídas de la tribu; sin ninguna, `SIN_OBJETIVOS`) y `previsualizar_guardar_caida(id)`. `Combate.costo_guardar_caida(id)`.
  - Registro: `accion` → `mana` (motivo `guardar_caida`) → `estado` (`caida` → `guardada`) → `guardado_caida` (`unidad`, `vida`) → `surco_cerrado`. Sin `fin_turno`: el Maestro sigue. Métrica 10 `caidas_guardadas` = `[{unidad, ronda}]` (esquema `resultado`).
  - Pantalla: `LecturaCombate.boton_guardar_caida()`, `vista_previa_guardar_caida(previa)` y los sucesos de la `accion` y de `guardado_caida` (hueco `{caida}`). `VistaCombate`: botón `GuardarCaida`, `pulsar_guardar_caida()`, `eligiendo_caida()`, `guardado_caida_mostrado()`; modo excluyente con los demás. `InterpreteClic.accion(..., modo_guardar_caida)` y `caida_en`. `ClavesTextos`: `ACCION_GUARDAR_CAIDA`, `GUARDAR_CAIDA`, `GUARDAR_CAIDA_TOOLTIP`, `AVISO_GUARDAR_CAIDA_*` y `motivo_guardar_caida(motivo)`. Faltan en `es.json`: `aviso.guardar_caida.{accion_usada,fuera_de_alcance,mana_insuficiente,sin_objetivos}`.
  - Fixtures: `pruebas/fixtures/combate/escenario_guardar_caida.json` (con `MesaGuardar`), `escenario_guardar_caida_combate.json` y `costos_mana_guardar_caida.json`. Tests: `pruebas/combate/test_guardar_caida.gd`, `test_guardado_caida.gd`, `test_guardar_caida_combate.gd`, `pruebas/pantalla/test_lectura_guardar_caida.gd`, `test_vista_guardar_caida.gd` y `pruebas/datos/test_guardar_caida_a.gd` (`datos/` real).
- Siguiente: T28 (B.4, se detalla de a una tarea).
