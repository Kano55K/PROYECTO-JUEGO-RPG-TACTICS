# CLAUDE.md — Instrucciones para Claude Code

> Versión alineada con `docs/Arquitectura.md` v0.7 (03/10/2026). Dueño: Arquitecto Técnico.
> Si este archivo y `docs/` se contradicen, **manda `docs/`** y avisás de la contradicción.

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

- **Nunca cambies una regla para que sea más fácil de programar.**
- **Si una regla es ambigua, no la interpretes en silencio.** Frená y anotala en el resumen final como `PARA SISTEMAS: <duda concreta, con la sección>`. Si podés seguir con el resto de la tarea sin esa respuesta, seguí; si no, pará.
- **No edites nada en `docs/`**: son copias que actualiza el usuario.

## Motor y entorno

- **Godot 4.7.1-stable** (estándar, no .NET). No sugieras actualizar.
- **GDScript tipado**: tipos declarados en toda variable, parámetro y retorno de `nucleo/`.
- **GdUnit4 v6.2.1** para tests. Windows.
- Ojo con la sintaxis de Godot 3 (`yield`, `export var`, `onready var`, `KinematicBody2D`…): está prohibida. Usá la de Godot 4 (`await`, `@export`, `@onready`).

## Arquitectura: dos mitades

```
nucleo/    reglas puras. Clases que extienden RefCounted. Sin Node, sin escenas, sin autoloads.
pantalla/  escenas de Godot. Leen el estado del núcleo y le mandan acciones. Nunca calculan reglas.
datos/     JSON + esquemas. Sin código.
pruebas/   tests del núcleo, con la misma estructura de carpetas que nucleo/.
herramientas/  reproductor y scripts de consola.
registros/ salidas de combates (fuera de Git).
```

- `pantalla/` puede usar `nucleo/`. **`nucleo/` nunca usa `pantalla/`.**
- Todo lo que una clase del núcleo necesita le llega por parámetro.
- El núcleo trabaja en coordenadas de grilla `[x, y]`, con `y = 0` arriba. No sabe si la vista es cenital o isométrica.
- Las previsualizaciones usan **"calcular sin aplicar"**: la misma función que aplica la regla, sin modificar el estado.

## Principios que no se negocian

1. **Ningún número de balance en el código.** Todo número de `Sistema.md` vive en `datos/`. Si escribís un número que no sea 0, 1 o un índice, preguntate de dónde sale; si sale de `Sistema.md`, va a un JSON.
2. **Azar solo con el generador con semilla del núcleo** (`nucleo/azar/`). Nunca `randi()`, `randf()` ni `RandomNumberGenerator` sueltos. Los generadores son objetos que se crean, no globales; el de textos está separado del de combate.
3. **Determinismo**: la iniciativa y el orden de las reglas se implementan tal cual están escritos en `docs/Sistema.md`. Misma semilla + mismas acciones = mismo registro, byte por byte.
4. **Comportamiento contra número**: un efecto nuevo (rasgo, geometría de hechizo) es un valor de `enum` programado una vez, con su test; sus números son dato.
5. **Solo la tarea pedida.** No construyas funciones de tareas o capas futuras. Si hace falta un lugar donde algo se va a enchufar, dejá el lugar (un campo con valor por defecto, un punto de extensión) y nada más.

## Datos

- JSON, un esquema por tipo en `datos/_esquemas/` (JSON Schema 2020-12, solo el subconjunto de `docs/Arquitectura.md` A.2).
- Todo objeto de campos fijos lleva `additionalProperties: false`. Todo objeto admite `_nota`; la raíz admite `$schema`.
- **Campo nuevo → primero el esquema, después el dato, después el código.**
- Godot lee los números JSON como decimales: el validador convierte `12.0` a entero y rechaza `12.5`.
- Un error de datos dice **archivo, campo y valor esperado**, y el juego no arranca.
- Al transcribir números de `docs/Sistema.md` a JSON, citá la sección en `_nota` (ej.: `"_nota": "Sistema.md 4.1"`).

## Textos

- **Nunca inventes un texto que vea el jugador.** `datos/textos/es.json` es del Worldbuilder: no lo edites.
- Podés usar una clave nueva en el código. Si no existe, la pantalla muestra `[FALTA: clave]`, y la listás en tu resumen.
- Claves: `^[a-z0-9_]+(\.[a-z0-9_]+)*$`. Huecos entre llaves: `{criatura}`, `{a_criatura}`, etc. (A.2.1).

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

Para correr una sola carpeta mientras trabajás: `addons/gdUnit4/runtest.cmd -a res://pruebas/azar`. Antes de cerrar una tarea, siempre el comando completo.

**Si el comando falla por algo que no es un test** (no encuentra Godot, `GODOT_BIN` vacía, error de GdUnit4), **no improvises otra forma de correr los tests**: pará y mostrale el error al usuario.

- Escribí los tests **antes** del código, a partir del criterio "Terminada cuando…" de la tarea.
- Cada regla con sus casos de `docs/Sistema.md` y del Brief. Si la tarea cita un ejemplo numérico, el test lo reproduce.
- Una tarea no está terminada si **un solo test** del proyecto falla, aunque sea de otra tarea.

## Git

- Trabajás **solo en `develop`**. Nunca hagas `push`, ni `checkout`, `merge` o `rebase` sobre `main`. Eso lo hace el usuario.
- **Un commit por tarea**, cuando el usuario apruebe el resumen. Mensaje: `T02: generador de azar con semilla`.
- No commitees `registros/` ni archivos `.godot/` de caché.

## Cómo trabajás cada tarea

1. Leé la fila de la tarea en `docs/Arquitectura.md` (B.2 a B.4) y las secciones de `docs/Sistema.md` y del Brief que cita.
2. **Proponé un plan** antes de escribir código: archivos que vas a crear o tocar, tests que vas a escribir (uno por renglón del criterio de terminado) y dudas. Esperá la aprobación.
3. Escribí los tests, después el código, y corré **todos** los tests.
4. Terminá con este resumen:

```
## T0X — resumen
- Hecho: …
- Archivos: …
- Tests: N nuevos, total M, todos pasan (sí/no)
- Criterio de terminado: cumplido punto por punto (…)
- Claves de texto nuevas sin texto: …
- PARA SISTEMAS / PARA ARQUITECTO: … (o "ninguna")
```

5. Esperá el OK del usuario para el commit.

## Estado actual

- **T01 terminada** (02/10/2026).
- Orden de 0a.1: T02 → T03 → T04 → T05 → T06 → T07 → T08 → T09 → T10 → T12 → **T34** → T13.
- **T11 no se empieza** hasta que Sistemas responda las dudas S-7 a S-9 (`docs/Arquitectura.md` 10.5).
- T04 necesita `datos/textos/es.json` del Worldbuilder; si todavía no está, el resto de T04 se hace igual y se avisa.
