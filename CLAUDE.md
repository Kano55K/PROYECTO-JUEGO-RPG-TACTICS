# CLAUDE.md — Instrucciones para Claude Code

> Versión alineada con `docs/Arquitectura.md` v0.7 más las decisiones del 03/10/2026. Dueño: Arquitecto Técnico.
> Si este archivo y `docs/` se contradicen, **manda `docs/`** y avisás de la contradicción en `docs/PREGUNTAS.md`.

## Qué es este proyecto

Tactics RPG 2D isométrico de captura de criaturas y supervivencia medieval. Estamos construyendo la **prueba 0a** (rebanada de combate), tarea por tarea, según el plan de `docs/Arquitectura.md`, sección B.

## Fuentes de verdad (leelas, no las supongas)

| Documento | Manda sobre |
|---|---|
| `docs/00_Vision.md` | Qué es el juego y su alcance |
| `docs/Sistema.md` | Reglas y números |
| `docs/Mundo.md` | Nombres y textos |
| `docs/Arquitectura.md` | Cómo se construye: estructura, datos, tareas (B.2 a B.4) |
| Brief de la prueba 0a (en `docs/`) | Reglas de 0a y escenarios |
| `docs/PREGUNTAS.md` | Dudas abiertas con el staff y sus respuestas |

- **Nunca cambies una regla para que sea más fácil de programar.**
- **Nunca interpretes en silencio una regla ambigua.** Toda duda va a `docs/PREGUNTAS.md` (sección siguiente).
- **No edites ningún archivo de `docs/` salvo `docs/PREGUNTAS.md`.** Los demás son copias que actualiza el usuario.

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
pruebas/       tests del núcleo, con la misma estructura de carpetas que nucleo/.
pruebas/fixtures/  datos chicos de prueba, con errores a propósito si hace falta.
herramientas/  reproductor y scripts de consola.
registros/     salidas de combates (fuera de Git).
```

- `pantalla/` puede usar `nucleo/`. **`nucleo/` nunca usa `pantalla/`.**
- Todo lo que una clase del núcleo necesita le llega por parámetro (incluida la carpeta de datos).
- El núcleo trabaja en coordenadas de grilla `[x, y]`, con `y = 0` arriba. No sabe si la vista es cenital o isométrica.
- Las previsualizaciones usan **"calcular sin aplicar"**: la misma función que aplica la regla, sin modificar el estado.

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
2. Leé la fila de la tarea en `docs/Arquitectura.md` (B.2 a B.4), las secciones de `docs/Sistema.md` y del Brief que cita, y las entradas de `docs/PREGUNTAS.md` que la afecten.
3. **Proponé un plan** antes de escribir código: archivos que vas a crear o tocar, tests (uno por renglón del criterio de terminado) y dudas. Las dudas de diseño van como entradas nuevas de `PREGUNTAS.md`. Esperá la aprobación.
4. Escribí los tests, después el código, y corré **todos** los tests.
5. Actualizá la sección "Estado actual" de este archivo (solo esa sección).
6. Terminá con este resumen, que el usuario usa como descripción del pull request:

```
## T0X — resumen
- Hecho: …
- Archivos: …
- Tests: N nuevos, total M, todos pasan (sí/no)
- Criterio de terminado: cumplido punto por punto (…)
- Claves de texto nuevas sin texto: …
- Preguntas nuevas en PREGUNTAS.md: P-00X (para quién, bloquea sí/no) … (o "ninguna")
- Preguntas cerradas: …
```

7. Esperá el OK del usuario para el commit.

## Estado actual

- **Terminadas:** T01 (proyecto), T02 (azar con semilla), T03 (validador y cargador).
- **En curso:** T04 (datos de 0a), rama `tarea/T04-datos`. Sesión 1 hecha: los 13 esquemas de entrada corregidos y testeados (`pruebas/datos/test_esquemas.gd`). Falta: actualizar los datos de `datos/` a los esquemas nuevos (`golpe_inicial` en cada escenario, `eventos` en `tablas/lealtad.json`), `d_rivales_balanza4.json`, y que `datos/` cargue entero sin errores.
- Orden de 0a.1: T04 → T05 → T06 → T07 → T08 → T09 → T10 → T12 → **T34** → T13.
- **T11 no se empieza** hasta que Sistemas responda las dudas S-7 a S-9 (`docs/Arquitectura.md` 10.5).
- T04 necesita `datos/textos/es.json` del Worldbuilder; si todavía no está, el resto de T04 se hace igual y se avisa.
