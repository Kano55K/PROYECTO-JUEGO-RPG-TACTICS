# CLAUDE.md — Instrucciones para Claude Code

> Revisado por última vez contra `docs/Arquitectura.md` v0.28 (07/10/2026). Dueño: Arquitecto Técnico.
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

Para una sola carpeta mientras trabajás: `addons/gdUnit4/runtest.cmd -a res://pruebas/azar`. Antes de cerrar una tarea, siempre el comando completo.

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
4. Escribí los tests, después el código, y corré **todos** los tests.
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
- **Cámara (desde T42):** la pantalla convierte el mouse con `TileMapLayer.get_local_mouse_position()` y `local_to_map`, nunca con la posición en pantalla. La cámara no toca el núcleo.
- **Test de contacto (desde T43):** si una tarea hace fallar `pruebas/datos/test_contacto.gd` (cambia la ronda del primer ataque de un escenario), no ajustes el test ni las coordenadas: anotalo en `docs/PREGUNTAS.md` y pará.

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
- **T16 (cadenas y combos) TERMINADA** en la rama `tarea/T16-cadenas` (una sesión), pendiente del PR y de la prueba manual.
  - `Afinidad.relacion_afin(a, b, plantel)`: qué es afín, sin posición ni estado. `son_afines` = las dos de pie + `relacion_afin`.
  - `Combo` (`nucleo/combate/combo.gd`, regla sin estado, en `ContextoCombate.combo`): `bono_par(anterior, atacante, plantel)` = `combate.json` `combo.sin_relacion_pct` / `afines_pct` + `Arrimo.ajuste(Arrimo.pasos(maestro), COMBO)`; `bono(eslabon, ...)` divide por `divisor_por_eslabon` k − 2 veces (S-27). Relación del par por `relacion_afin` (S-28).
  - `Cadena` (`nucleo/combate/cadena.gd`, estado, dueño el `Combate`): `aporte`, `eslabon_para` (calcular sin aplicar), `atacar` (solo la tribu; otra objetivo → `otro_objetivo` y eslabón 1), `cortar(motivo)` (un solo `cadena_cortada`), `revisar_objetivo` (`objetivo_fuera` por `Objetivos`), `historial`, `instantanea`. Constantes `MOTIVO_*`.
  - `Turno.empezar(entrada, plantel, tablero, danio, surcos, afinidad, cadena)` (las dos obligatorias). `_aportes` suma el combo; `_atacar_desde` pone `ResultadoAccion.eslabon` y solo al aplicar avanza la cadena; `_resolver` llama a `revisar_objetivo` después de cada acción aplicada. Los tests con un `Turno` suelto pasan `DatosFixture.afinidad()` y `DatosFixture.cadena()` (una nueva cada vez; también `DatosFixture.combo()`).
  - `Combate`: corta con `enemiga` al empezar el turno de una enemiga (detrás de `turno`), con `fin_ronda` en `_cerrar_ronda` (detrás del hambre de combate) y con `fin_combate` en `_terminar` (antes de `fin`); vuelca los cortes de la acción detrás de los surcos. Evento `ataque` con `eslabon`; `instantanea()["cadena"]`. P-029: `objetivo_fuera` gana a `fin_combate`.
  - Pantalla: `LecturaCombate.panel_turno()` suma la cadena en curso (`ClavesTextos.PANEL_CADENA`, falta en `es.json`). El combo sale en el desglose como "Cadena".
  - Fixtures: `escenario_cadena.json` (como el de afinidad, con `tasajero_s1`) y `escenario_cadena_combate.json` (para el `Combate`; `rodauva_s1` encerrada por dos caídas solo termina). `DatosFixture` carga `tablas/arrimo.json`.
- **Abrir el juego:** F5 en el editor, o `& $env:GODOT_BIN --path .` (PowerShell). Con otra carpeta de datos, agregar `-- --datos=<carpeta>`.
- **Reproducir una grabación por consola** (escribe `registros/<nombre>.jsonl`, o `<nombre>_hasta_N.jsonl`; con los datos de `datos/`): `"%GODOT_BIN%" --headless --path . --script res://herramientas/reproducir.gd -- <grabacion.json> [N]`
- Tests de reglas con fixtures vía `pruebas/unidades/lector_fixture.gd`, y los datos completos de prueba con `pruebas/combate/datos_fixture.gd` (`DatosFixture.cargar()`, mismas claves que el `Cargador`). Con `datos/` real, además del permanente: `test_plantel_escenarios.gd` el test (9) de `test_combate.gd`, y en `pruebas/pantalla/` `test_principal.gd` (2, 10 sobre una copia temporal de `datos/`, y el clic real, y R durante una secuencia) y `test_vista_combate.gd` (con el test 7, C jugado con activas), y `pruebas/datos/test_p003.gd` y `test_p028.gd`. 328 tests. Los `Control` que tapan el tablero llevan `mouse_filter` IGNORE: si no, el clic no llega a `_unhandled_input`.
- `docs/PREGUNTAS.md`: P-024 `RESPONDIDA` (opción B: en una derrota, la atacante se va; se aplica en T30). P-003 `CERRADA` en T14. P-028 `CERRADA` en T15. Siguen `RESPONDIDA` y se cierran en su tarea: P-008 en T19, P-002 y P-024 en T30. P-011 a P-023, `CERRADA` en T12. P-025 `ABIERTA` (ARQUITECTO, no bloquea): cómo admite la consulta única a una caída para guardar; se necesita antes de T26. P-026 y P-027 `ABIERTA` (SISTEMAS, no bloquean): desempates de la IA de T39, programados como lecturas declaradas. P-029 `ABIERTA` (ARQUITECTO, no bloquea): motivo del corte cuando el golpe que saca a la objetivo gana el combate; programada la opción A.
- Al agregar un `class_name` nuevo, la caché de clases de Godot hay que refrescarla (abrir el editor o `--import`) antes de correr los tests: `runtest.cmd` no escanea. `runtest.cmd` corta en el primer test que falla de cada archivo; con `-c` sigue (sirve para listar todas las fallas).
- Siguiente: PR de T16 a `develop`. Después, **T17** (Secundar), cuando la detalle `Arquitectura.md`. Ninguna tarea está bloqueada.
