# CLAUDE.md

## Qué es este proyecto

Tactics RPG 2D isométrico de captura de criaturas y supervivencia medieval. El Maestro pelea junto a su tribu en un tablero por turnos.

**Estamos construyendo la Prueba 0a:** una rebanada de combate en un tablero de 8 × 8. No se toca nada de 0b (mapa, comida, campamento, cierre del día) hasta terminar 0a.

## Fuentes de verdad (carpeta `docs/`)

| Archivo | Manda sobre |
|---|---|
| `00_Vision.md` | Qué es el juego y por qué |
| `Sistema.md` | Reglas y números |
| `Brief_para_el_Arquitecto___Prueba_0a.md` | Alcance de 0a y reglas de combate cerradas. Si choca con `Sistema.md`, manda el Brief |
| `Mundo.md` | Nombres y textos |
| `Arquitectura.md` | Cómo se construye y plan de tareas T01–T33 (sección B) |

Si el código y un documento no coinciden, manda el documento.

**Nunca inventes ni interpretes una regla de diseño.** Si algo es ambiguo o falta, frená, anotá la duda concreta en `docs/PREGUNTAS.md` y preguntá antes de seguir.

## Stack

- **Godot 4.7.1-stable**, versión estándar (no .NET). No se actualiza sin una decisión explícita.
- **GDScript tipado.**
- **GdUnit4 v6.2.1** en `addons/gdUnit4/`.
- Desarrollo en Windows; destino: PC.

## Comandos

Correr todos los tests (desde la raíz del proyecto, con la variable `GODOT_BIN` configurada):

```
addons\gdUnit4\runtest.cmd -a res://pruebas
```

Antes de dar una tarea por terminada, todos los tests tienen que pasar.

## Estructura

```
datos/         contenido editable en JSON (sin código)
nucleo/        reglas puras: azar, datos, unidades, combate
pantalla/      escenas de Godot: muestran el estado y envían acciones
pruebas/       tests del núcleo (test_<modulo>.gd)
herramientas/  reproductor de partidas y scripts de consola
registros/     salidas de combates (fuera de Git)
docs/          documentos del estudio
```

## Reglas de arquitectura (no negociables)

1. **`nucleo/` no conoce la pantalla.** No usa nodos, escenas, `Input` ni nada de `pantalla/`. Sus clases extienden `RefCounted`. `pantalla/` puede usar `nucleo/`, nunca al revés.
2. **Ningún número de balance en el código.** Todo valor de `Sistema.md` se lee de `datos/`. Un número de balance escrito a mano es un error.
3. **Todo el azar pasa por el generador con semilla de `nucleo/azar/`.** Prohibido `randi()`, `randf()` o un `RandomNumberGenerator` suelto.
4. **Determinismo:** la iniciativa y sus desempates se implementan exactamente como en `Sistema.md` 11.3 y en el Brief.
5. **Calcular sin aplicar:** toda previsualización usa la misma función que la acción real, sin modificar el estado. La pantalla nunca calcula reglas por su cuenta.
6. **Nada de capas futuras.** Si algo necesita dejar un lugar para el futuro, seguí la sección 9 de `docs/Arquitectura.md` y no construyas más que eso.
7. **Los datos se validan al cargar.** Un error dice archivo, campo y valor esperado, y el juego no arranca con datos rotos.

## Convenciones

- Términos del juego en castellano, como en `Sistema.md`, sin tildes ni ñ en los identificadores: `secundar`, `encono`, `obediencia`, `mana`, `danio`.
- `snake_case` para variables, funciones y archivos; `PascalCase` para clases.
- Tipos declarados en variables, parámetros y retornos de todo `nucleo/`.
- Un archivo de tests por módulo: `pruebas/test_<modulo>.gd`.

## Godot 4, no Godot 3

| Usar | No usar |
|---|---|
| `@export`, `@onready` | `export`, `onready` |
| `await` | `yield` |
| `TileMapLayer` | `TileMap` |
| `CharacterBody2D` | `KinematicBody2D` |
| `senial.connect(metodo)` | `connect("senial", self, "metodo")` |
| `super()` | `.metodo()` para llamar al padre |

## Forma de trabajo

1. **Una tarea del plan por vez** (T01–T33, sección B de `docs/Arquitectura.md`). Empezá diciendo qué tarea es y cuál es su criterio de "terminada".
2. **Primero los tests** que prueban el criterio; después el código.
3. Al terminar: todos los tests en verde, un resumen corto de lo hecho y un commit con el formato `T07: cola de iniciativa`.
4. Si la tarea pide algo que no está en los documentos, o choca con otra regla, frená y preguntá.
5. No cambies archivos de `docs/`, salvo `docs/PREGUNTAS.md`.
