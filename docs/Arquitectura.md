# ARQUITECTURA — Borrador v0.7

> **Dueño:** Arquitecto Técnico
> **Estado:** BORRADOR. Base para `05_Arquitectura.md`. Secciones A.1 a A.7 y B.1 a B.5 `DECIDIDO`; A.8 en `PROPUESTA` (tiene filas ya `DECIDIDO`). **T01 terminada.** Próximo paso: sincronizar `docs/` y seguir con la tarea T02. **No queda ninguna tarea de 0a bloqueada**; T11 espera los desempates de la IA (10.5) antes de empezar.
> **Sincronizado con:** `00_Vision.md` v1.0, `Sistema.md` v0.9 y `Mundo.md` v1.0 (03/10/2026).
> **Contenido:** consolidación de todos los pedidos `PARA ARQUITECTO` de `Decisiones.md` al 01/10/2026 (59 pedidos en 18 bloques → 53 requisitos, sin duplicados y con la terminología actual).
> Las reglas y los números viven en `Sistema.md`; este documento solo dice **qué tiene que soportar el código**.

**Columna Capa:**
- `0a` → rebanada de combate (se construye primero).
- `0b` → loop completo del MVP.
- `0a / 0b` → una parte entra en 0a y el resto en 0b (ver nota).
- `Futura` → no se construye en el MVP; solo se deja el lugar donde se va a enchufar.

La clasificación 0a / 0b sigue el `Brief para el Arquitecto — Prueba 0a` (sección 1). **Columna Origen:** `D` = bloque de `Decisiones.md` (índice en la sección 12); `S` = sección de `Sistema.md`.

---

## A. Decisiones técnicas

### A.1 Motor y plataforma — `DECIDIDO` (01/10/2026)

| Tema | Decisión | Motivo |
|---|---|---|
| Motor | **Godot 4.7.1-stable** (versión estándar, no .NET), fija durante 0a. No se sube a 4.7.2 hasta que GdUnit4 la soporte | 2D isométrico incluido, gratis (MIT), todo en archivos de texto que Claude Code puede leer y editar, editor liviano |
| Lenguaje | **GDScript tipado** (tipos declarados en variables y funciones) | Integrado en el motor; los tipos permiten detectar errores antes de ejecutar y reducen la confusión con la sintaxis de Godot 3 |
| Plataforma | **Solo PC**: Windows; Linux si sale sin costo. Steam como tienda de referencia | Decisión del Director |
| Entorno | Windows, programador intermedio, 10–20 h por semana, con Claude Code | Perfil del usuario |
| Integración con Steam | Enchufe futuro; no se construye en el MVP | Principio 5 |
| Plan B | Phaser + TypeScript, portando el núcleo de reglas | Solo si Godot se vuelve un obstáculo |

**Arquitectura en dos mitades** (`DECIDIDO`, deriva de los principios 1 y 2):
- **Núcleo de reglas:** scripts que no conocen la pantalla (no dependen de nodos de escena). Contienen combate, iniciativa, sellado, obediencia y el generador de azar con semilla. Se testean y se simulan sin abrir ventana.
- **Pantalla:** escenas de Godot que leen el estado del núcleo y le envían las acciones del jugador. Nunca calculan reglas.

### A.2 Formato de los archivos de datos — `DECIDIDO` (01/10/2026)

| Tema | Propuesta | Motivo |
|---|---|---|
| Formato | **JSON** para todo el contenido: fichas, tablas, relaciones, textos y escenarios | Godot lo lee sin extensiones; Claude Code lo edita bien; un solo cargador |
| Validación | Al cargar, cada archivo se valida contra su esquema. Un error dice **archivo, campo y valor esperado**, y el juego no arranca con datos rotos | Un número mal tipeado no puede convertirse en un bug silencioso de balance |
| Notas de diseño | Campo opcional `"_nota"` en cualquier objeto; el código lo ignora | JSON no admite comentarios |
| Textos | Archivo propio con claves (`"caida.rodauva"`), separado de los números. Reglas en **A.2.1** | Worldbuilder y Sistemas editan archivos distintos |
| Alternativa descartada por ahora | Tablas en CSV para editar en planilla | Dos formatos y dos cargadores. Se revisa si el balance pide trabajar en planilla |
| Alternativa descartada | Recursos propios de Godot (`.tres`) | Atan los datos al motor y son más verbosos de editar a mano |

**Esquemas** — `DECIDIDO` (02/10/2026):

| Tema | Decisión | Motivo |
|---|---|---|
| Formato del esquema | **JSON Schema** (draft 2020-12), uno por tipo de archivo, en `datos/_esquemas/` | Estándar: Claude Code lo conoce bien y VS Code autocompleta y marca errores al editar un JSON que declara su `"$schema"` |
| Subconjunto | El validador del juego entiende solo estas palabras: `type`, `properties`, `required`, `additionalProperties`, `items`, `enum`, `minimum`, `maximum`, `minItems`, `maxItems`, `pattern`, `$ref`, `$defs` (más `title` y `description`, que ignora). `type` acepta un tipo o una **lista de tipos** (`["string", "array"]`). Un esquema que use otra palabra es un error | Un validador chico, escrito en T03, que no depende de librerías |
| Estricto | Todo objeto **de campos fijos** lleva `additionalProperties: false`: un campo mal tipeado (`danoi`) es un error, no un campo ignorado | Atrapa los errores de tipeo en el balance |
| Diccionarios | Los objetos de **claves libres** (el mapa de `textos/es.json`) usan `additionalProperties` **como esquema** (texto o lista de textos). El formato de cada clave lo revisa el cargador (`DECIDIDO`, 03/10/2026) | Las claves de texto no se pueden listar de antemano |
| Notas | `_nota` está declarado en cada objeto y `$schema` en la raíz de cada archivo | Se pueden comentar los datos sin romper la validación |
| Enteros | Godot lee **todo número JSON como decimal** (`12` llega como `12.0`). El validador acepta `12.0` como entero y lo convierte; rechaza `12.5` | Si no, todo dato entero fallaría o se colaría un decimal |
| Chequeos cruzados | Lo que un esquema no puede expresar lo revisa el cargador después: el `id` de cada ficha coincide con su archivo; las especies de relaciones y escenarios existen; no hay pares repetidos; la balanza tiene las posiciones 1 a 5; los tramos de sellado son crecientes; los estados de hambre cubren 0–10 sin huecos; los ids de un escenario no se repiten y las posiciones caen dentro del tablero | Mismo mensaje: archivo, campo y valor esperado |
| Mecánica contra número | Los **comportamientos** (efecto de un rasgo, geometría de un hechizo) son un `enum` cerrado programado una vez; sus **números** son dato | Agregar un efecto nuevo es código con su test; ajustarlo, solo dato |
| Saciado | **No se guarda aparte**: es el estado de hambre 0–2 (`Sistema.md` 7.1). El escenario tiene solo `hambre` | Una sola fuente de verdad. Ver la consulta a Sistemas en 10.4 |

Archivos de datos de 0a y su esquema:

| Archivo | Esquema | Contenido (`Sistema.md`) |
|---|---|---|
| `especies/<id>.json` | `especie` | Ficha: rol, rango, sellable, estadísticas, **lista de turnos**, rasgo y % de huida (4.3, 11.2, 11.7) |
| `maestro.json` | `maestro` | Movimiento, alcance, velocidad, hechizos y valores iniciales (1.1, 11.2) |
| `hechizos.json` | `hechizos` | Costo, alcance, geometría y efecto (1.6) |
| `relaciones.json` | `relaciones` | Pares bien / mal; el resto, sin relación (10.8) |
| `tablas/balanza.json` | `balanza` | Las 5 filas de la tabla 1.2 (filas, no fórmulas) |
| `tablas/arrimo.json` | `arrimo` | Efecto de cada paso (1.3) |
| `tablas/sellado.json` | `sellado` | Tramos de vida × rango y camino de confianza (4.1) |
| `tablas/costos_mana.json` | `costos_mana` | Sellar, invocar, resellar y guardar caídas por rango; costo mínimo (2.3) |
| `tablas/hambre.json` | `hambre` | Estados, efecto en daño, obediencia y regeneración; hambre por rondas (2.2, 5.4, 7.1, 7.2) |
| `tablas/lealtad.json` | `lealtad` | Escala, estados, lealtad inicial por camino y al resellar (4.2, 4.4, 5.1) |
| `tablas/combate.json` | `combate` | Combos, afinidad, incidente, Encono, cobardía, obediencia, salvajes, enfermedad, huida, alcances, caída y victoria (8.2, 10, 11) |
| `escenarios/<id>.json` | `escenario` | Contexto de combate (A.7) |
| `textos/es.json` | `textos` | Clave → texto o lista de variantes; huecos entre llaves: `{criatura}` |
| (salida) | `resultado`, `grabacion` | Resultado del combate y combate grabado (A.6, A.7) |

**Ejemplo de escenario** (escenario A del Brief):

```json
{
  "$schema": "../_esquemas/escenario.schema.json",
  "id": "a_dia_1",
  "_nota": "¿Sello al 50% o arriesgo una ronda más?",
  "tipo": "test",
  "semilla": 12345,
  "tablero": { "ancho": 8, "alto": 8 },
  "maestro": { "balanza": 2, "poder": 1, "regeneracion": 1,
               "vida": null, "mana_entrada": null, "hambre": 3,
               "enfermedades": 0, "posicion": [3, 7] },
  "tribu": [
    { "id": "rodauva_1", "especie": "rodauva", "estado": "suelta",
      "lealtad": 5, "hambre": 3, "enfermedades": 0,
      "vida": null, "posicion": [4, 7] }
  ],
  "enemigas": [
    { "id": "ocarra_s1", "especie": "ocarra", "comportamiento": "salvaje",
      "vida": null, "posicion": [4, 0] }
  ],
  "pergaminos_en_blanco": 2,
  "golpe_inicial": null,
  "toggles": { "afines_contra_cobardia": false }
}
```

`null` significa "valor por defecto" (ficha, balanza o `maestro.json`); en `posicion`, que la unidad la ubica el jugador en el despliegue; en `golpe_inicial`, que no hay golpe (A.7). El orden de la lista `tribu` es el **orden de la tribu** (desempates de iniciativa y de rescate). Coordenadas `[x, y]` con `y = 0` arriba (borde enemigo).

### A.2.1 Textos — `DECIDIDO` (03/10/2026)

| Tema | Decisión | Motivo |
|---|---|---|
| Dueños | El **Worldbuilder** es dueño del contenido de `textos/es.json` y lo **entrega en JSON**. El **Arquitecto** es dueño del esquema `textos` | Cada área edita lo suyo; el esquema atrapa los errores de formato |
| Claude Code | **Nunca inventa un texto.** Puede agregar una clave nueva al código; si falta en `textos/es.json`, la pantalla muestra `[FALTA: clave]` | Los textos son del Worldbuilder. Una clave faltante se ve en el acto, no pasa desapercibida |
| Huecos | Entre llaves y en minúscula: `{criatura}`, `{comida}`. `Mundo.md` usa `[Criatura]`: al entregar el JSON se escriben con llaves | Un solo formato que el código reemplaza |
| Huecos gramaticales | `DECIDIDO` (03/10/2026), según `Mundo.md` 1.5. Cada hueco de criatura en un rol tiene seis formas, armadas una sola vez desde `especie.<id>.articulo`: `{criatura}`, `{a_criatura}`, `{de_criatura}`, `{criatura_o}`, `{criatura_la}`, `{criatura_ella}`. Valen para cualquier rol (`{a_rival}`, `{de_guardiana}`) | Las especies no comparten género: sin esto sale "la Surcón" |
| Mayúsculas | Automáticas al principio del texto y después de `. ? ! ¿ ¡` | `¿{criatura}?` da "¿La Rodauva?" |
| Resolución de variantes | `<clave>.<especie>` y `<clave>.maestro` **reemplazan** a la clave base si existen. Excepción: `caida.*`, `nocturno.base.*` y `nocturno.raso.*` son **complementos** que se muestran después de la línea base. La lista de prefijos complemento es una constante del armador, con test | Reglas de armado de `Mundo.md` 1.5 |
| Dónde vive | `nucleo/textos/`: arma huecos, mayúsculas y variantes sin nodos, con tests. La pantalla solo pide "clave + datos" y recibe el texto (T34) | Se testea sin abrir ventana, como el resto del núcleo |
| Variantes al azar | Una clave puede tener una **lista** de variantes; la elección sale del **generador de textos**, separado del de combate (A.8) | Agregar o quitar una frase no puede cambiar las tiradas de un combate grabado |
| Variantes por condición en 0a | Cada condición es una **clave propia** (`sellar.fallo.erizada`, `nocturno.comer.zancajunco_suelto`); el código elige la clave. No hay lenguaje de condiciones | Alcanza para 0a. Las condiciones como dato llegan con los eventos de nodo (A.8) |
| Chequeo del cargador | Lista de claves que usa el código contra claves del archivo: avisa de las faltantes (sin impedir el arranque) y de las que sobran. Además, cada clave debe cumplir `^[a-z0-9_]+(\.[a-z0-9_]+)*$` (error) y se avisa de todo hueco que no sea una forma conocida (aviso) | El Worldbuilder sabe qué falta escribir; un hueco mal tipeado no llega a la pantalla |

### A.3 Vista de 0a — `DECIDIDO` (01/10/2026, responde B-03)

| Tema | Propuesta |
|---|---|
| 0a.1 y 0a.2 | **Vista cenital** (casillas cuadradas). Depurar alcance, líneas y distancias Manhattan es mucho más fácil |
| Antes de los playtests de criterios de éxito | **Pasar a isométrica**, como tarea propia del plan |
| Condición técnica | La pantalla convierte casilla ↔ pantalla solo con las funciones del mapa de Godot; el núcleo trabaja en coordenadas de grilla y no sabe qué vista se usa. Así el cambio toca solo la pantalla |
| Riesgo a vigilar | En isométrica, los vecinos **ortogonales** se ven en **diagonal** en pantalla. Las pruebas en cenital no muestran ese problema de lectura; por eso los playtests de criterios van en isométrica |

---

### A.4 Estructura del proyecto — `DECIDIDO` (01/10/2026)

```
juego/
├── CLAUDE.md          instrucciones para Claude Code
├── project.godot
├── docs/              copia de los documentos del estudio (Visión, Sistema, Mundo, Brief, Arquitectura)
├── addons/gdUnit4/    framework de tests
├── datos/             contenido editable (JSON)
│   ├── _esquemas/     un esquema por tipo de archivo (A.2)
│   ├── especies/      una ficha por especie
│   ├── tablas/        balanza, arrimo, sellado, costos de maná, hambre, lealtad, combate
│   ├── maestro.json
│   ├── hechizos.json
│   ├── relaciones.json
│   ├── textos/        textos por clave
│   └── escenarios/    escenarios A–H de 0a (contextos de combate)
├── nucleo/            reglas puras: no usa nodos ni escenas
│   ├── azar/          generador con semilla
│   ├── datos/         cargador y validador
│   ├── unidades/      especie, instancia, Maestro, pergamino
│   ├── textos/        armador de textos: huecos, mayúsculas y variantes (A.2.1)
│   └── combate/       tablero, iniciativa, acciones, daño, cadenas, IA
├── pantalla/          escenas de Godot: tablero, paneles, previsualizaciones
├── pruebas/           tests del núcleo
├── herramientas/      reproductor de partidas y scripts de consola
└── registros/         salidas de combates (fuera de Git)
```

**Regla de dependencias:** `pantalla/` puede usar `nucleo/`; `nucleo/` nunca usa `pantalla/`. `datos/` no tiene código. Cada capa del roadmap suma carpetas dentro de `nucleo/` (por ejemplo, `nucleo/supervivencia/` en 0b) sin tocar las de combate.

### A.5 Convenciones de código — `DECIDIDO` (01/10/2026)

| Tema | Convención |
|---|---|
| Idioma | Términos del juego en **castellano**, como en `Sistema.md` (`secundar`, `encono`, `obediencia`), sin tildes ni ñ en los identificadores (`mana`, `danio`). La API de Godot sigue en inglés |
| Estilo | El de la guía oficial de GDScript: `snake_case` para variables y funciones, `PascalCase` para clases |
| Tipos | GDScript tipado en todo `nucleo/` |
| Números | **Ningún número de balance escrito en el código.** Si aparece uno, es un error |
| Azar | Ninguna tirada fuera del generador con semilla del núcleo |
| Núcleo | Las clases de `nucleo/` extienden `RefCounted` (nunca `Node`) y no usan autoloads: todo lo que necesitan les llega como parámetro |
| Control de versiones | Git con repositorio privado en GitHub. `DECIDIDO` (03/10/2026): **`main`** solo recibe hitos terminados y revisados (con etiqueta `0a.1`, `0a.2`…); **`develop`** es la rama de trabajo diario. Claude Code trabaja solo en `develop`, un commit por tarea, y nunca hace push ni toca `main`: eso lo hace el usuario |
| Documentos | Al cambiar la versión de un documento del estudio, se copia a `docs/` en un commit propio (`docs: sincronización <fecha>`) antes de seguir programando: Claude Code trabaja con `docs/`, y una copia vieja es una regla vieja |

### A.6 Cómo se testea — `DECIDIDO` (01/10/2026)

| Nivel | Qué | Cómo |
|---|---|---|
| Reglas | Cada regla del núcleo con sus casos de `Sistema.md` y del Brief | Tests automáticos con **GdUnit4 v6.2.1** (compatible con Godot 4.7.1), corridos por consola sin abrir el editor |
| Reproducción | Un combate = escenario + semilla + lista de acciones del jugador. Reproducirlo da exactamente el mismo registro | Reproductor en `herramientas/` |
| Previsualizaciones | El núcleo ofrece **calcular sin aplicar**: la pantalla pregunta "¿qué pasaría si…?" y muestra el resultado. Así la previsualización y el resultado real nunca difieren | Un test por previsualización que compara lo previsto con lo aplicado |
| Juego | Los 8 escenarios del Brief, jugados por personas | Métricas exportadas por combate |

**Fuera de 0a:** la simulación masiva de balance necesita un "jugador automático". Queda como enchufe: como las acciones son datos y los combates se reproducen, se puede sumar después sin cambiar el núcleo.

### A.7 Contrato del combate — `DECIDIDO` (02/10/2026)

El combate es una caja con **una entrada y una salida**, las dos como datos. 0a la alimenta desde archivos de escenario; 0b, desde la partida (un nodo, una emboscada, un ataque nocturno). La caja no cambia.

| Pieza | Qué es | Esquema |
|---|---|---|
| **Contexto de combate** (entrada) | Tipo (`test`, `nodo`, `emboscada`, `nocturno`), semilla, tablero, Maestro con sus modificadores, tribu en orden, enemigas con su comportamiento (`salvaje` o `atacante_nocturna`), pergaminos en blanco, golpe inicial y toggles | `escenario` |
| **Combate grabado** | Contexto + semilla + decisiones del jugador + huella de los datos. Las tiradas no se guardan: salen de la semilla | `grabacion` |
| **Registro** | Una línea JSON por evento (tirada, daño, cambio de estado), en orden. Dos reproducciones idénticas dan archivos idénticos | Sin esquema: se compara entero |
| **Resultado de combate** (salida) | Desenlace (victoria, derrota, huida), rondas, rescatista o permadeath, estado final de cada unidad, capturas, cambios de lealtad con su motivo, pergaminos ardidos, atacante pendiente de destino y métricas | `resultado` |

**Reglas del contrato:**
- El núcleo **calcula** el resultado; la pantalla **solo lo muestra**; en 0b, el loop **lo aplica** a la partida. Ninguna regla vive en la pantalla de resultado.
- Toda unidad tiene un `id` estable que viaja de la entrada a la salida (`rodauva_1`, `ocarra_s1`). Es lo que permite registrar hitos, métricas, epílogo (G-03) y combos por grupo (F-02).
- Lo que 0a no usa pero 0b sí (por ejemplo, quebranto, M-09) entra como campo nuevo del contexto con valor por defecto, sin tocar el resto.
- **Golpe inicial** (`DECIDIDO`, 03/10/2026; `Sistema.md` 9.2): el campo `golpe_inicial` lleva el `id` de la atacante o `null`. Si hay golpe, el combate lo resuelve como **primer evento del registro, antes de la ronda 1**: ataque normal contra el Maestro con la fórmula 11.4, sin combo y sin sumar Encono. **Si hay golpe o no** (Centinela) lo decide quien arma el contexto: en 0a, el archivo de escenario; en 0b, la noche. La caja de combate no sabe nada de la noche.
- El destino de la atacante nocturna (perdonar, sellar, comer) es una **decisión posterior** al combate: el resultado la deja pendiente y la decisión se registra como una acción más.
- **Guardado de suspensión** (`DECIDIDO`, 03/10/2026; Visión v0.9, 6.6): salir a mitad de un combate guarda la **grabación hasta la última acción confirmada**; retomar es reproducirla sin mostrarla. No hay un segundo sistema que copie el estado de cada unidad, y ninguna tirada se repite porque todas salen de la semilla. Si la huella de los datos no coincide al retomar (por ejemplo, tras un parche), se avisa. En 0a solo se construye la capacidad del reproductor de detenerse en la acción N (T12); el archivo de guardado es 0b.

### A.8 Decisiones técnicas para 0b — `PROPUESTA` (02/10/2026)

No se construye nada de esto en 0a (principio 6). Se escriben ahora para no cerrarles el paso.

| Tema | Propuesta | Motivo |
|---|---|---|
| Guardado de la partida | Un solo espacio que se sobrescribe solo, al cerrar cada día y al entrar en combate. En modo de prueba, guardados libres. La partida se guarda como JSON con el estado de los generadores de azar. **Dentro de un combate:** guardado de suspensión por grabación (`DECIDIDO`, A.7) | Permadeath absoluto. La Visión v0.9 decidió que salir a mitad de un combate retoma el estado exacto |
| Cierre del día | Lista ordenada de pasos (`Sistema.md` 7.9) que se puede **pausar y retomar**: el paso 0 pide una elección y el paso 2 puede abrir un combate | Respeta el orden escrito y permite sumar pasos futuros (F-06) sin tocar los otros |
| Eventos de nodo | Catálogo cerrado de **condiciones** (criatura suelta de tal especie, objeto en inventario, estado del Tasajero, ya visitado…) y **efectos** (comida, material, texto, iniciar combate…). Sin lenguaje de scripts | Testeable; Worldbuilder arma eventos combinando piezas |
| Azar | Una semilla por partida, de la que se derivan generadores separados por sistema (combate, mapa, noche, encuentros, **textos**). El de textos es `DECIDIDO` desde 0a (A.2.1) | Sumar una tirada en el mapa o una frase nueva no cambia los combates de una partida grabada |
| Partida de prueba | La configuración inicial de la partida es un dato; en modo de prueba se pueden cambiar la balanza inicial (Visión v0.9, 10), la duración (30 o 20 días, `Sistema.md` 13) y la semilla | Jugar partidas enteras inclinadas al Soplo sin tocar la clase real |
| Flujo | Máquina de estados de la partida: apertura → Molino → mapa del mundo → mapa de nodos → (evento o combate) → noche → cierre del día → … → epílogo. La pantalla observa la fase; el núcleo la cambia | Mismo principio que el combate: reglas sin pantalla |

---

## B. Plan de construcción de 0a — `DECIDIDO` (01/10/2026)

### B.1 Validación de los hitos del Director

Los tres hitos se aceptan, con cuatro ajustes técnicos:

| Ajuste | Motivo |
|---|---|
| La **caída básica** y el fin del combate pasan a **0a.1** (sin rescate: si cae el Maestro, se pierde) | Si no, 0a.1 necesitaría una regla temporal de "vida en 0" que después habría que reescribir |
| Los **rasgos de combate** entran en **0a.1** | Son parte de las fichas y de la fórmula de daño (`Sistema.md` 11.2 y 11.4) |
| **Maná, obediencia y hambre de combate** entran en **0a.2** | Los hechizos dependen del maná; los incidentes, el Encono y la cobardía dependen de la obediencia |
| **Escenario G**, **panel de parámetros**, **vista isométrica** y **métricas completas** cierran **0a.3** | Son lo último que hace falta antes de los playtests de criterios de éxito |

### B.2 Hito 0a.1 — "Se pelea"

Tablero, movimiento, iniciativa, ataque, rasgos, caída y fin del combate. Vista cenital.

| ID | Tarea | Requisitos | Terminada cuando… |
|---|---|---|---|
| T01 | ✅ **Terminada** (02/10/2026). Instalar Godot (versión exacta), Git y GdUnit4; crear el proyecto con la estructura de A.4 y un primer `CLAUDE.md` | A.1, A.4, A.5 | Un test de ejemplo corre por consola sin abrir el editor y pasa |
| T02 | Generador de azar con semilla que registra cada tirada. Es un **objeto que se crea** (no un global): puede haber varios a la vez, y de una semilla se derivan generadores independientes (combate, textos) | Principio 3, A.7, A.2.1 | Misma semilla → misma secuencia de 1.000 tiradas; otra semilla → otra secuencia; dos generadores con la misma semilla no se interfieren |
| T03 | Cargador y validador de JSON: subconjunto de JSON Schema, enteros de Godot y chequeos cruzados | A.2 | Un archivo con un error devuelve archivo, campo y valor esperado, y el juego no arranca. Tests con: campo mal tipeado, decimal donde va entero, valor fuera de rango, obligatorio faltante, `enum` inválido, especie inexistente, `type` con lista de tipos y diccionario de claves libres (clave con formato inválido) |
| T04 | Datos de 0a según los esquemas de A.2: fichas, Maestro, hechizos, relaciones, 7 tablas, escenarios A y G (Arquitecto) y B a F y H (Sistemas, 03/10/2026), más `d_rivales_balanza4.json`, variante temporal de D con la misma semilla hasta que exista T31. `textos/es.json` del Worldbuilder | W-01, A.2, `Sistema.md` 11.9 | Todo carga sin errores y los números coinciden con `Sistema.md` (revisión del usuario). Los escenarios validan con `_nota` dentro de cada unidad y `"guardada"` como `estado`: si fallan ahí, se corrige el esquema, no el escenario |
| T05 | Modelo de unidades: especie e instancia con `id` estable, balanza derivada, `vida_max_real`, estados suelta / guardada / caída, pergaminos como entidades | C-01, C-02, M-01, M-03, P-01, A.7 | Tests: el Maestro con balanza 2 y 5 tiene la vida y el daño de la tabla; dos Ocarras tienen estados independientes |
| T06 | Tablero y geometría: Manhattan, adyacencia ortogonal, movimiento que atraviesa aliadas y caídas propias, alcance 2 con bloqueo solo por enemigas | K-03 | Un test por cada regla de `Sistema.md` 11.3 y del Brief (reglas 2 y 3) |
| T07 | Cola de iniciativa: Velocidad, desempates, Tasajero con dos entradas (Caza y Cuenta) que son **dos turnos completos** (movimiento y acción en cada uno), lugar para la invocada de la ronda siguiente | K-01, `Sistema.md` 11.2 | Tests con el orden de la Prueba A y de la Prueba C; el Tasajero mueve y actúa en cada una de sus dos entradas |
| T08 | Turno: 1 movimiento y 1 acción en cualquier orden; atacar; Erizarse | Brief regla 1 | Tests de turno; no se puede partir el movimiento |
| T09 | Fórmula de daño con porcentajes, planos y rasgos (Lomo de tierra, Hacerse junco, Erizarse); Saciado (derivado del hambre) y enfermedades como parámetros | K-04, K-05, C-07 (0a) | Tests que reproducen los dos ejemplos de `Sistema.md` 11.4 (7 de daño y Rodauva saciada en 2) |
| T10 | Vida en 0: caída, salvaje que sale del tablero, victoria sin enemigas en pie, derrota al caer el Maestro, caídas que mueren y pergaminos que arden. +1 de lealtad por victoria a las **sueltas al terminar** (de pie, caídas que se levantan, invocadas durante el combate); las guardadas no | K-08, K-09, P-01, `Sistema.md` 5.2 | Tests de cada fila de `Sistema.md` 11.5, salvo el rescate, y del +1 de victoria con una guardada que no lo recibe |
| T11 | IA de salvajes base: Erizarse → remate → cercana → acercarse; nadie apunta a una caída; las salvajes no Secundan; la Ocarra ataca desde distancia 2 si puede. Desempates según la respuesta de Sistemas (10.5). El Tasajero recorre la lista en cada uno de sus dos turnos | K-07, `Sistema.md` 11.8 | Tests de elección de objetivo y de casilla, incluidos los empates; la Rodauva salvaje con vida ≤ 50% y una enemiga adyacente se eriza; huida y Encono quedan con su lugar reservado. **Empieza cuando Sistemas responda 10.5** |
| T12 | Contrato del combate: contexto desde JSON, resultado como objeto, registro y reproductor. El reproductor puede **detenerse en la acción N** (base del guardado de suspensión) | B-04, A.6, A.7 | Un combate grabado se reproduce con un registro idéntico; el resultado valida contra su esquema; reproducir hasta la acción N deja el mismo estado que jugarlo en vivo hasta ahí |
| T34 | Armador de textos en `nucleo/textos/`: huecos gramaticales desde `especie.<id>.articulo`, mayúsculas automáticas, variantes que reemplazan y complementos, elección al azar con el generador de textos. **Se hace antes de T13** (el número es posterior porque los ID no se renumeran) | A.2.1, `Mundo.md` 1.5 | Tests: `¿{criatura}?` → "¿La Rodauva?"; `flac{criatura_o}` con el Surcón → "flaco"; `{a_rival}` con el Surcón → "al Surcón"; una clave `.maestro` reemplaza a la base; `caida.*` se agrega después de la base; clave faltante → `[FALTA: clave]`; misma semilla → mismas variantes |
| T13 | Pantalla cenital con placeholders: tablero, unidades, casillas de movimiento y ataque, cola de iniciativa, desglose de daño, resultado básico (lee el resultado de A.7), recarga del escenario con una tecla. Textos desde `textos/es.json` armados por T34, con `[FALTA: clave]` si no está | Brief 4, A.2.1, T34 | Los escenarios A y B se juegan de punta a punta con el mouse |

**Hito terminado cuando:** A y B se juegan completos, todos los tests pasan y una partida grabada se reproduce igual.

### B.3 Hito 0a.2 — "La tribu se ve"

Obediencia, maná, afinidad, combos, Secundar, incidentes, Encono, cobardía y hechizos.

| ID | Tarea | Requisitos | Terminada cuando… |
|---|---|---|---|
| T14 | Obediencia en vivo, hambre de combate (+1 al cerrar las rondas 5, 10… al Maestro y a toda la tribu en el tablero, **de pie o caída**; no a las guardadas, salvajes ni atacante) y Arrimo derivado de la balanza | C-03, C-04, `Sistema.md` 7.2 | Tests de `Sistema.md` 5.4 y del recálculo en el acto; una caída suma hambre y una caída guardada no |
| T15 | Afinidad por adyacencia (+1 como máximo; el Maestro es afín de las leales). **Solo dentro del mismo bando**: también entre salvajes afines. Las caídas no dan ni reciben | Brief regla 7, `Sistema.md` 10.7, 11.5 | Tests con varias afines adyacentes; Rodauva de la tribu junto a Rodauva salvaje no suma; dos Rodauvas salvajes pegan 3 |
| T16 | Cadenas: registro de objetivo, eslabón e instancias participantes; bonos; reglas de corte. Las salvajes **no encadenan**, pero sus turnos cortan las cadenas de la tribu | K-02, F-02 (enchufe), `Sistema.md` 10.7 | Tests de la Prueba A, de cada corte de la regla 6 del Brief y de dos salvajes seguidas sin bono |
| T17 | Secundar: inserción en la cola y previsualización | K-01 | Tests; la cola muestra el lugar resultante antes de confirmar |
| T18 | Incidentes con rival aliada, con % en la casilla destino antes de mover. Las caídas no provocan ni sufren incidentes | Brief regla 10, `Sistema.md` 11.5 | Tests de los dos resultados según la obediencia y con una rival caída al lado (0%) |
| T19 | Chequeo único de rival enemiga → Encono (contador 0–3) o cobardía (con el toggle de afines), con % al inicio del turno. El Tasajero chequea al inicio de **cada uno de sus dos turnos**, con un **contador único**. **Todo golpe a la rival suma Encono**; el bono rige **solo enconada** y usa el valor **después** de sumar. Una caída no cuenta como rival a su alcance | K-06, `Sistema.md` 10.5, 11.5 | Tests de las dos ramas; escenario E con y sin toggle; Ocarra enconada (daño 4) pega 5 / 6 / 7 / 7; golpe voluntario sube el contador sin bono; Tasajero con dos chequeos por ronda y un solo contador |
| T20 | IA de salvajes: suma huida (lugar reservado para T25), Encono e incidentes entre salvajes, en cada turno del Tasajero | K-07, `Sistema.md` 11.8 | Tests: el Tasajero enconado va por la Rodauva en sus dos turnos; un incidente entre salvajes siempre es ataque |
| T21 | Maná: reserva, `maná_al_entrar`, regeneración al inicio del turno del Maestro, efecto del hambre | M-04 | Tests de tope y de rondas pares |
| T22 | Martillazo, Lanzadera (con choque) y Remiendo, con previsualización del empuje | Anexo 11 | Tests de alcance, bloqueo, choque y "no cura caídas" |
| T23 | Métricas de 0a.2 (parte de las 13 de `Sistema.md` 11.9): usos de Secundar, eslabones promedio, incidentes, Encono, cobardía y distancia media del Maestro a la enemiga más cercana | B-05, `Sistema.md` 11.9 | Cada métrica aparece en el registro exportado |

**Hito terminado cuando:** C, D, E y H se juegan completos, con todas las previsualizaciones de este hito.

### B.4 Hito 0a.3 — "Sellar, caer y ser rescatado"

| ID | Tarea | Requisitos | Terminada cuando… |
|---|---|---|---|
| T24 | Sellar: tabla vida × rango, acción, distancia ≤ 2, maná, pergamino en blanco; si falla, se pierde el maná. Texto de fallo propio si la objetivo está erizada | K-10, P-01, `Mundo.md` 5 | Tests de la tabla; % visible sobre cada salvaje |
| T25 | Huida de salvajes con vida ≤ 25% (% por especie, acobardada, enconada). El Tasajero tira al inicio de cada uno de sus dos turnos | Anexo 11, `Sistema.md` 11.7 | Tests de `Sistema.md` 11.7, incluidas las dos tiradas del Tasajero; % visible |
| T26 | Guardar en combate (acción de la criatura, adyacente al Maestro) e invocar (turno completo, casilla libre, entra la ronda siguiente) | C-01 | Tests de los dos casos |
| T27 | Guardar a una caída (acción del Maestro, distancia ≤ 2, costo de invocar, queda con 1 de vida) | Anexo 11 | Tests; sobrevive si después el Maestro cae |
| T28 | Huida del Maestro (turno completo, termina al final de la ronda, caídas que mueren, sin +1 de victoria). Si cae antes del cierre, el combate termina **por caída**: rescate y caídas que mueren. Previsualización al declarar: enemigas que actúan antes del cierre y **daño máximo** sobre el Maestro | Anexo 11, `Sistema.md` 11.7 | Tests de `Sistema.md` 11.7, incluido el Maestro que cae tras declarar; la previsualización coincide con el peor caso aplicado |
| T29 | Rescate: rescatista según lealtad real, desempates del Brief (también las que iban a huir con el Maestro), caídas que quedan atrás; pantalla de resultado completa; "quién puede rescatar ahora" visible | C-04 | Escenario F jugable; tests de desempate |
| T30 | Escenario G: golpe inicial desde el campo `golpe_inicial` (A.7), atacante con lógica de salvaje que no huye, caída en 0 y tres salidas (perdonar, sellar, comer); texto `nocturno.comer.zancajunco_suelto` | P-02, K-09, `Sistema.md` 9.2, `Mundo.md` 4.6 | G jugable con sus tres salidas; con la Ocarra atacante, el primer evento del registro es un golpe de 4 al Maestro, sin combo ni Encono; con `golpe_inicial: null`, no hay golpe |
| T31 | Panel de parámetros dentro del juego, con toggles y semilla | B-04 | Se edita un escenario sin tocar el JSON; D se juega con balanza 4 desde el panel y se borra `d_rivales_balanza4.json` |
| T32 | Vista isométrica y lectura de la adyacencia | A.3 | Los 8 escenarios se juegan en isométrica |
| T33 | Métricas completas y exportación por combate. Si el Director aprueba la encuesta de E y F, una pantalla de 2 o 3 preguntas exportada junto con las métricas. Si los umbrales de alarma llegan como números, se cargan como dato y la exportación marca las alarmas | B-05, `Sistema.md` 11.9, Visión v1.0 (10, 11) | Las **13 métricas de `Sistema.md` 11.9** se exportan en cada combate |

**0a terminada cuando:** los 8 escenarios se juegan en isométrica, con todas las previsualizaciones y las métricas exportadas. Ahí empiezan los playtests de criterios de éxito.

### B.5 Hitos de 0b — `DECIDIDO` (validados por el Director, Visión v1.0, 03/10/2026)

Se construyen en este orden. Las **tareas detalladas se escriben después de los playtests de 0a**, porque esos tests pueden cambiar reglas.

| Hito | Contenido | Requisitos | Terminado cuando… |
|---|---|---|---|
| 0b.1 "Un día" | Partida y guardado, inventario, mapa del día de los Huertos, eventos de nodo, combate enchufado por el contrato, reparto de comida, cierre del día en el Molino | G-01, I-01, W-02, N-01, N-03, C-03, C-05, W-07 | Un día completo, del Molino al Molino, con un combate de nodo |
| 0b.2 "El valle" | Los 3 destinos, viaje, agotamiento y pudrición, Enfermo completo, ritual, camino de confianza, Tasajero y su hostilidad, río | C-07, M-05, I-02 a I-04, W-03 a W-06, W-08 | Una vuelta al Robledal con ritual |
| 0b.3 "La noche" | Abandono y ataque nocturno (enchufa el escenario G), campamento al raso, guardias, emboscadas, recuperación, quebranto y Poza Tibia | N-02, M-03, M-06, M-07, M-09, W-05 | Caer, ser rescatado y curarse en la Poza |
| 0b.4 "30 días" | Experiencia y nivel, plazo, epílogo y métricas de partida | C-06, M-02, M-08, G-02, G-03 | Una partida entera hasta el epílogo |

---

## 0. Bloqueantes de la primera sesión — `PREGUNTA ABIERTA`

| ID | Pedido | Origen | Nota |
|---|---|---|---|
| B-01 | Motor y plataforma objetivo, teniendo en cuenta que se desarrolla con Claude Code y con poca experiencia previa | D16, D18 | **Resuelto** → A.1 |
| B-02 | Alcance técnico de 0a y validación de los hitos 0a.1, 0a.2 y 0a.3 | D16, D18 | **Resuelto** → B |
| B-03 | ¿0a puede usar vista cenital y postergar la isométrica? | D18 | **Resuelto** → A.3 |
| B-04 | Escenarios de 0a como datos: unidades, posiciones, lealtad y hambre fijas | D18 | **Resuelto** → A.2 y A.7. Tareas T12 y T31 |
| B-05 | Registro de las métricas de los criterios de éxito (por ejemplo, % de rondas con el Maestro en primera fila) | D18 | Tareas T12, T23 y T33 |

El Brief agrega dos preguntas que no están en `Decisiones.md`: el **formato de las tablas de datos y del archivo de escenario** (`PROPUESTA` en A.2) y **cuánto cuesta cada previsualización obligatoria**: ninguna es cara si el núcleo ofrece "calcular sin aplicar" (ver A.6). No hace falta recortar ninguna.

---

## 1. Criatura (instancia)

| ID | Requisito | Capa | Origen | Nota |
|---|---|---|---|---|
| C-01 | Estado de la criatura: **guardada** o **suelta** | 0a | D01 | En el MVP solo hay dos estados. En 0a se usa al sellar, invocar y guardar |
| C-02 | Varias criaturas de la misma especie como **instancias separadas**, cada una con su lealtad, su hambre y su pergamino | 0a | D10 | Separar la **especie** (ficha fija, dato) de la **instancia** (estado que cambia). El escenario B ya tiene 2 Ocarras |
| C-03 | Hambre 0–10 por ser, con el estado derivado por tabla; apetito y preferencias como datos | 0a / 0b | D06 | 0a: hambre y estado (+1 cada 5 rondas). 0b: apetito y preferencias |
| C-04 | Obediencia calculada en vivo (lealtad − efecto del hambre); el rescate lee la lealtad real | 0a | D06 | Se recalcula en el acto cuando sube el hambre en combate |
| C-05 | Indicador `estuvo_suelta_hoy` y contador de días para el ritmo lento de lealtad (balanza 4–5) | 0b | D02 | |
| C-06 | Registro de hitos por instancia (primera vez Leal) para la experiencia, y registro de **especies ya capturadas** | 0b | D17, S1.4 | Por instancia, para que no se pueda farmear bajando y subiendo la lealtad. La captura da XP una vez por especie |
| C-07 | Estado **Enfermo** con duración, aplicable a criaturas y al Maestro. Las causas son datos; el efecto es uno solo. Cola de enfermedades (tipo + días restantes) con cura por descanso y por contador de viaje | 0a / 0b | D03, D04, D06 | 0a: solo la **cantidad** de enfermedades como modificador de daño (parámetro del escenario). 0b: cola y cura. Sin contagio: `Sistema.md` 8 no lo tiene y el alcance está congelado |
| C-08 | ¿La simulación de hambre y clima corre solo para las criaturas sueltas? | 0b | D01 | `Sistema.md` 3.1 ya responde el hambre: comen las sueltas y las que estuvieron sueltas en el día. El clima es Capa 2 (Visión, roadmap): en el MVP no se simula |

---

## 2. Maestro

| ID | Requisito | Capa | Origen | Nota |
|---|---|---|---|---|
| M-01 | La balanza como **un solo valor** (posición 1–5) del que se derivan todos los efectos de la tabla 1.2 | 0a | D05 | El escenario H usa balanza 5. Nada se guarda dos veces: todo se calcula desde la posición |
| M-02 | Al mover la balanza, recalcular umbral de rescate y ritmo de lealtad, y listar qué criaturas cambian de estado para el aviso de la interfaz | 0b | D05 | Mover la balanza ocurre al subir de nivel. Si M-01 es una función derivada, este recálculo sale gratis |
| M-03 | `vida_max_real` (derivada de la balanza) separada de `vida_max_vigente` (real menos reducciones temporales) | 0a / 0b | D08 | 0a solo usa la real. Las reducciones temporales (debilidad del ritual) son 0b. El quebranto no es una reducción temporal: baja `vida_max_real` (M-06) |
| M-04 | Guardar `maná_al_entrar` al iniciar un combate (tope de regeneración) | 0a | D02 | |
| M-05 | Historial de los tipos de comida que comió el Maestro en los últimos días (dieta variada) | 0b | D05 | |
| M-06 | Contador de **quebranto** que corre desde el fin de la recuperación y se apaga en la Poza Tibia | 0b | D17, S6.1 | Resta 1 de `vida_max_real` por día, mínimo 1, de forma permanente (paso 7 del cierre) |
| M-07 | Bloquear los hechizos fuera de combate; invocar fuera de combate descuenta maná | 0b | D08 | En 0a no existe "fuera de combate" |
| M-08 | XP inmediata y subida de nivel en el **paso 0** del cierre, con el aviso de rescatistas perdidos | 0b | S1.4, S7.9 | Usa la balanza derivada (M-01); el aviso sale de M-02 |
| M-09 | Quebranto: no regenera vida ni maná, tampoco por turno en combate | 0b | S6.1 | Campo nuevo del contexto de combate (A.7) con valor por defecto `false` |

---

## 3. Combate

| ID | Requisito | Capa | Origen | Nota |
|---|---|---|---|---|
| K-01 | Cola de iniciativa **determinista**: empates (jugador > enemigo, Maestro > criaturas, luego orden de la tribu), invocada desde la ronda siguiente, Tasajero con dos entradas e inserción por **Secundar** | 0a | D06, D13 | Se implementa tal cual está escrita (principio de determinismo) |
| K-02 | Registro de objetivo y eslabón para las cadenas de combo | 0a | D06 | Cortes de cadena: Brief, sección 2, regla 6 |
| K-03 | Adyacencia ortogonal; alcance en línea con bloqueo solo por enemigas | 0a | D13 | Todas las distancias son Manhattan (Brief, regla 3) |
| K-04 | Cálculo de daño en el orden de `Sistema.md` 11.4 | 0a | D13 | Porcentajes sumados → redondeo abajo → planos → mínimo 1 |
| K-05 | Modificadores porcentuales sumados y aplicados al total | 0a / 0b | D06 | 0a: daño. 0b: recolección del nodo. **Una sola función** para los dos casos |
| K-06 | Un solo chequeo por rival enemiga que deriva a **Encono** o a **cobardía** según el rol | 0a | D08 | Combate y mixta → Encono; trabajo → cobardía |
| K-07 | IA de salvajes que respete los incidentes y el Encono | 0a | D06 | Orden de decisión en el Brief (huida → Encono → remate → cercana → acercarse) |
| K-08 | Estado **caída**; el combate termina al caer el Maestro; las caídas mueren si se pierde | 0a | D13 | |
| K-09 | La salvaje sale del tablero al llegar a 0; la atacante nocturna queda caída | 0a | D13 | Escenario G |
| K-10 | Probabilidad de sellado leída desde una tabla (vida × rango) | 0a | D02 | |

---

## 4. Pergaminos

| ID | Requisito | Capa | Origen | Nota |
|---|---|---|---|---|
| P-01 | Contador de pergaminos (en blanco y ocupados) y su destrucción ante todo vínculo roto | 0a | D07 | `PROPUESTA` técnica: modelar cada pergamino como **entidad con identidad**, no como un número. Lo pide F-03 a futuro |
| P-02 | La atacante nocturna usa lógica de salvaje durante el combate; su pergamino arde cuando se resuelve su destino | 0a | D08 | Escenario G |

---

## 5. Noche y cierre del día

| ID | Requisito | Capa | Origen | Nota |
|---|---|---|---|---|
| N-01 | Cierre del día en el orden de `Sistema.md` 7.9 | 0b | D08 | Se implementa tal cual está escrito (principio de determinismo) |
| N-02 | Chequeo nocturno de abandono para criaturas sueltas (hambre + lealtad), con resultados leídos desde una tabla; interrupción del sueño | 0b | D04, D06 | El **combate** del ataque nocturno es 0a (escenario G); la **tirada** que lo dispara es 0b |
| N-03 | Registro diario de cobertura de raciones para la lealtad | 0b | D06 | |

---

## 6. Comida, inventario y ritual

| ID | Requisito | Capa | Origen | Nota |
|---|---|---|---|---|
| I-01 | Inventario de comida por tipo; preferencias por criatura como datos | 0b | D03, D06 | |
| I-02 | Inventario de objetos no comestibles: materiales acumulables y cuenco permanente | 0b | D07, D08 | |
| I-03 | El ritual como evento del Molino con requisitos de inventario; límite de 1 por día; contadores de debilidad acumulables | 0b | D07, D08 | |
| I-04 | La **prenda** como requisito que cumple el Maestro o cualquier criatura suelta | 0b | D07 | |

---

## 7. Mundo, nodos y eventos

| ID | Requisito | Capa | Origen | Nota |
|---|---|---|---|---|
| W-01 | Relaciones como tabla par a par leída desde datos | 0a | D03 | Incluye pares de la misma especie (Rodauva–Rodauva bien, Ocarra–Ocarra mal, `Mundo.md`) |
| W-02 | Eventos de nodo como datos (texto, opciones, requisitos) | 0b | D03 | |
| W-03 | Variantes con requisito de criatura suelta: corral caído (bloqueo) y surco que ronca (solo texto) | 0b | D15 | Mismo mecanismo que W-02 |
| W-04 | Textos del raso como datos: emboscadas con variantes, ataque propio con y sin fuego, despertar de habilidades, rebuscar y pudrición por tipo | 0b | D15 | |
| W-05 | La Poza Tibia como nodo del Vado que cumple "viajar al sanador" | 0b | D15, S6.2 | Mientras el Maestro tiene quebranto, **reemplaza el nodo de La crecida**; bañarse ocupa ese nodo y no tiene encuentro, y el río no se puede leer |
| W-06 | Hostilidad del Tasajero como variable de la partida, modificada por los eventos del Robledal, con **registro de la visita** (derrotado: no vuelve en lo que queda de ella) | 0b | D04, S12.10 | En 0a el Tasajero siempre es hostil (Brief, sección 6) |
| W-07 | Tablas de encuentros y emboscadas como datos, con pesos, tope de amenaza por destino y marca "inicia combate" según el rol | 0b | S11.6, S9.4 | Las emboscadas usan las mismas tablas sin las salvajes de trabajo |
| W-08 | Estado del río, previsión del día siguiente y daño al cruzar solo a las sueltas | 0b | S12.11 | La tirada del río es parte del paso 7 del cierre. **El cruce no mata:** vida mínima 1 |

---

## 8. Partida

| ID | Requisito | Capa | Origen | Nota |
|---|---|---|---|---|
| G-01 | Estado inicial: Rodauva suelta, 1 pergamino ocupado y lealtad inicial leída desde datos | 0b | D09 | En 0a el escenario A lo replica como parámetros |
| G-02 | Plazo de la partida: contador de días visible; la partida termina al cerrar el último día (30, editable) | 0b | S13 | El fin es un paso más del cierre, no un caso especial |
| G-03 | Registro por instancia para el epílogo: especie, suelta / guardada / perdida al final, lealtad final, **día del último guardado**, flag de **compañera inicial** y, si se perdió, causa y día. Opcional: flag "fue atacante". Orden de lectura, variante "Solo" de `Sistema.md` 13 y variante "solo guardadas" (`epilogo.cierre.solo_guardadas`, `Mundo.md` 4.11) | 0b | S13, `Mundo.md` 9 | Sale de los `id` estables (A.7) |

---

## 9. Capas futuras — solo dejar el enchufe

No se construye nada de esto en el MVP. La última columna dice qué hay que respetar **hoy** para no reescribir después.

| ID | Requisito | Capa | Origen | Enchufe (`PROPUESTA`) |
|---|---|---|---|---|
| F-01 | Barra de zozobra persistente por criatura, congelada al estar guardada, que baja al dormir en el Molino | Mudanza | D12 | La instancia admite campos nuevos sin migrar partidas; "guardada" congela todo estado temporal de forma genérica |
| F-02 | Contador de combos por grupo de cinco criaturas, que se reinicia si cambia algún integrante | Mudanza | D11 | El registro de cadenas (K-02) guarda **qué instancias** participaron, no solo cuántas |
| F-03 | Pergamino de muda como contenedor de pergaminos ocupados; todos arden si la criatura mudada muere | Mudanza | D11 | Pergaminos como entidades (P-01) |
| F-04 | Dato `orgullosa` por criatura | Órdenes | D14 | La ficha de especie acepta campos nuevos con valor por defecto |
| F-05 | Órdenes como acciones sin maná, con costo en lealtad y en el movimiento del Maestro | Órdenes | D14 | Las acciones se definen como datos con costos genéricos (maná, lealtad, movimiento, acción) |
| F-06 | Estado "subyugada" persistente, con maná retenido y chequeo nocturno contra el maná recuperado | Mudanza o Capa 3 | D14 | Los estados de la instancia son extensibles; el cierre del día (N-01) es una lista ordenada de pasos a la que se puede sumar uno |
| F-07 | Contador de quiebres por criatura | Mudanza | D14 | Igual que F-01 |

---

## 10. Notas de consolidación

### 10.1 Terminología actualizada
Los bloques viejos de `Decisiones.md` no se editan, así que algunos pedidos usan nombres reemplazados. Acá figuran con el nombre vigente:

| En `Decisiones.md` | Nombre vigente |
|---|---|
| Esperar | Secundar |
| Provocación | Encono |
| Liderazgo | Arrimo |
| Aporte corporal / "algo que el cuerpo suelta sin daño" | Prenda |
| Golpe / Desplazar / Sanar | Martillazo / Lanzadera / Remiendo |
| Hoyo | Madriguera |

### 10.2 Fusiones
- Estados negativos con duración (D03), Enfermo único (D04) y cola de enfermedades (D06) → **C-07**.
- Chequeo nocturno de abandono (D04) y tirada nocturna (D06) → **N-02**.
- Cola de iniciativa con Secundar (D06) y cola determinista (D13) → **K-01**.
- Motor y alcance de 0a (D16 y D18) → **B-01** y **B-02**.

### 10.3 Requisitos que esperaban respuestas de Sistemas — resueltos (`Sistema.md` v0.7)
- **M-06** → el quebranto (antes "malherido") baja `vida_max_real` (6.1).
- **C-06** → cantidades de XP en 1.4; además, registro de especies capturadas.
- **W-05** → la Poza ocupa el nodo de La crecida, sin encuentro (6.2).

### 10.4 Dudas de programación para Sistemas — **resueltas** (`Sistema.md` v0.8, 03/10/2026)

| # | Duda | Respuesta | Tareas |
|---|---|---|---|
| S-1 | Huida del Maestro: ¿cae o se salva si cae antes del cierre? | Termina **por caída**: rescate y caídas que mueren (11.7) | T28 (desbloqueada), T29 |
| S-2 | ¿El hambre de combate alcanza a las caídas? | Sí, a toda la tribu en el tablero, de pie o caída; no a las guardadas (7.2) | T14 |
| S-3 | ¿Afinidad y combos entre salvajes? | Afinidad sí, solo dentro del mismo bando; combos no, pero sus turnos cortan cadenas (10.7) | T11, T15, T16, T20 |
| S-4 | ¿Cuándo rige el bono del Encono? | Todo golpe a la rival suma; el bono solo enconada, con el valor después de sumar (10.5) | T19 |
| S-5 | ¿Quién recibe el +1 de la victoria? | Las sueltas al terminar: de pie, caídas que se levantan, invocadas; no las guardadas (5.2) | T10 |
| S-6 | ¿Saciado es solo el hambre 0–2? | Sí (7.1) | T04, T09 |
| Extra | — | Las caídas no participan de ninguna relación (11.5) | T15, T18, T19 |

Las dudas S-1 a S-6 están cerradas. Las nuevas están en 10.5.

### 10.5 Dudas abiertas para otras áreas — `PREGUNTA ABIERTA` (03/10/2026)

| # | Para | Duda | Recomendación del Arquitecto | Bloquea |
|---|---|---|---|---|
| S-7 | Sistemas | IA (11.8): con dos objetivos empatados en vida, en remate o cercana, ¿a cuál ataca? | A la que actúa antes en la cola de iniciativa: la cola es visible y el jugador lo puede prever | T11 |
| S-8 | Sistemas | IA: "puede alcanzar" y "puede tumbar", ¿incluyen moverse y después atacar en el mismo turno? | Sí | T11 |
| S-9 | Sistemas | IA: con varias casillas posibles para moverse, ¿cuál elige? | La que la deja más cerca del objetivo; si empatan, la que menos movimiento gasta; si siguen empatadas, orden fijo (arriba, derecha, abajo, izquierda). La Ocarra prefiere quedar a distancia 2 | T11 |
| S-10 | Sistemas | Si el golpe inicial del ataque nocturno deja al Maestro en 0, ¿el combate termina por caída antes de la ronda 1 (rescate y caídas que mueren)? | Sí, por coherencia con 11.5 | 0b.3 (en el escenario G no puede pasar) |
| S-11 | Sistemas / Director | La Visión v1.0 da por aprobados los umbrales de alarma en `Sistema.md` 11.9, pero la v0.9 tiene solo las señales en texto | Pasarlos a números en 11.9; se cargan como dato para T33 | Playtests de criterios (no la programación) |
| D-1 | Director | ¿Los playtests de E y F incluyen una encuesta corta al final? (Visión 11) | — | T33 (0a.3) |

---

## 11. Anexo — `PARA ARQUITECTO` que no están en `Decisiones.md`

`Sistema.md` (sección 14) y `Mundo.md` (sección 9) tienen pedidos propios. Se listan acá para que el plan no quede incompleto; **varios son de 0a**.

**De `Sistema.md` 14:**

| Pedido | Capa |
|---|---|
| Geometría de los hechizos: Martillazo a distancia sin bloqueo; Lanzadera en línea con bloqueo por enemigas; choque con 1 de daño | 0a |
| Guardar a una caída: alcance 2, costo de invocar, queda con 1 de vida | 0a |
| Huida del Maestro al final de la ronda; huida de salvajes con probabilidad por especie | 0a |
| Mapa del día: 4 columnas × 2 nodos, con composición por destino como datos | 0b |
| Contador de agotamiento por destino; raciones con fecha de pudrición; marcas "podrida" y "dudosa" con tirada al comer | 0b |
| Contador de confianza por nodo de avistamiento | 0b |
| Campamento: guardias repetidas por defecto, fuego, habilidades por especie distinta, tirada de emboscada y ronda de sorpresa | 0b |

**De `Mundo.md` 9:**

| Pedido | Capa |
|---|---|
| Textos de huida, caída, levantarse, rescate, guardar a una caída y huida del Maestro como datos, con variantes (afines, varias caídas) | 0a |
| Texto de apertura, línea del umbral de rescate y texto de las dos frutas iniciales | 0b |
| Línea de prenda por emisor; textos matutinos de "lo que diste" con variantes | 0b |
| Evento de la hornacina con variante "ya visitado"; dos caminos al Roble Viejo como estructura del mapa de nodos | 0b |
| Variantes con criatura suelta en el colgadero (Rodauva) y en el juncal (Ocarra) | 0b |
| Emboscadas por destino con variantes; textos del ataque nocturno por criatura | 0b |
| Escenario G con variante de texto por Zancajunco suelto (`nocturno.comer.zancajunco_suelto`); fallo de sellado con texto propio si la Rodauva está erizada (`sellar.fallo.erizada`) (T24, T30) | 0a |
| Huecos gramaticales y mayúsculas automáticas (`Mundo.md` 1.5) → A.2.1, T34 | 0a |
| Textos rotativos sin repetición consecutiva y marca de "primera visita" por destino | 0b |
| Regla de testigos al comer a una criatura (`PROPUESTA` de Mundo, 4.12), contador de veces que el Maestro comió y guardadas presentes en ese momento | 0b |
| Líneas de hambre solo al cambiar de estado; aviso de muerte por hambre antes del reparto | 0b |
| Línea de Enfermo según causa y quién la sufre; la de acumulación reemplaza a la de entrada | 0b |
| Etapa de confianza derivada del contador por nodo; evento único al cruzar el umbral de rescate de la compañera | 0b |
| Hitos del plazo y etapa de las golondrinas derivados del dato de duración | 0b |

**Del Brief 0a (sección 4), sin repetir acá:** panel de parámetros por escenario, previsualizaciones obligatorias y registro de combate con métricas.

---

## 12. Índice de origen

| Código | Bloque de `Decisiones.md` | Línea |
|---|---|---|
| D01 | 30/09 — Sistema de magia | 56 |
| D02 | 30/09 — Números de magia y lealtad | 115 |
| D03 | 30/09 — Mundo: región inicial y criaturas del MVP | 170 |
| D04 | 30/09 — Alcance del MVP: estados, abandono y criaturas | 224 |
| D05 | 30/09 — La balanza del Maestro, su dieta y la despensa del Tasajero | 271 |
| D06 | 30/09 — Combos, rivalidad y obediencia | 374 |
| D07 | 01/10 — Balanza, pergaminos, cobardía y Mudanza | 490 |
| D08 | 01/10 — Sincronización, cobardía, pergaminos y curación | 574 |
| D09 | 01/10 — Compañera inicial y Visión v0.5 | 647 |
| D10 | 01/10 — La Rodauva como piso de supervivencia y la Muda colectiva | 719 |
| D11 | 01/10 — Muda colectiva: definición | 760 |
| D12 | 01/10 — La barra de zozobra | 809 |
| D13 | 01/10 — Estadísticas físicas, iniciativa y caídas | 883 |
| D14 | 01/10 — La involución, las órdenes y la subyugación | 983 |
| D15 | 01/10 — Mundo: geografía, avistamientos, sanador y textos del raso | 1046 |
| D16 | 01/10 — Aprobaciones, cierres y congelamiento del alcance | 1098 |
| D17 | 01/10 — Campamento, secuelas, experiencia y Visión v0.7 | 1145 |
| D18 | 01/10 — Capa 0 dividida y criterios de éxito | 1180 |

---

## 13. Registro de cambios

| Versión | Fecha | Cambio |
|---|---|---|
| v0.7 | 03/10/2026 | Sincronización con Visión v1.0, `Sistema.md` v0.9 y `Mundo.md` v1.0. Huecos gramaticales, mayúsculas y resolución de variantes `DECIDIDO` (A.2.1); armador en `nucleo/textos/` (A.4) y nueva **T34** antes de T13. Validador: `type` como lista y diccionarios de claves libres (A.2, T03). Claves `sellar.fallo.erizada` y `nocturno.comer.zancajunco_suelto`. Golpe inicial como campo del contexto (A.7, `DECIDIDO`). Escenarios B a F y H en T04, con variante temporal de D en balanza 4 hasta T31. Mandan las 13 métricas de 11.9 (T23, T33). Tasajero con dos turnos completos y contador único (T07, T19, T20, T25); Erizarse en la IA (T11). B.5 pasa a `DECIDIDO`. G-03 suma "solo guardadas". Nueva 10.5 con dudas S-7 a S-11 y D-1; T11 espera S-7 a S-9 |
| v0.6 | 03/10/2026 | Sincronización con Visión v0.9, `Sistema.md` v0.8 y `Mundo.md` v0.8. 10.4 resuelta (S-1 a S-6) y **T28 desbloqueada**; criterios nuevos en T02, T10, T11, T12, T13, T14, T15, T16, T18, T19, T20, T24, T28, T29 y T30. Nueva A.2.1: textos (`DECIDIDO`). Guardado de suspensión por grabación (A.7, `DECIDIDO`). Generador de azar de textos y partida de prueba en A.8. Flujo de Git y sincronización de `docs/` `DECIDIDO` (A.5). Quebranto reemplaza a malherido; C-07 sin contagio; W-08 y G-03 actualizados. Anexo 11 con los pedidos nuevos de `Mundo.md` 9 |
| v0.5 | 02/10/2026 | Sincronización con Visión v0.8 y `Sistema.md` v0.7. T01 terminada. Esquemas JSON y datos de 0a (A.2, `DECIDIDO`); Saciado derivado del hambre. Nueva A.7: contrato del combate (`DECIDIDO`). Nueva A.8: decisiones técnicas para 0b (`PROPUESTA`). Ajustes de criterio en T02, T03, T04, T05, T12 y T13. Nueva B.5: hitos de 0b (`PROPUESTA`). Nuevos requisitos M-08, M-09, W-07, W-08, G-02 y G-03; cambian C-06, M-06, W-05 y W-06. 10.3 resuelta; nueva 10.4 con 6 dudas para Sistemas. B-02 y B-04 resueltos |
| v0.4 | 01/10/2026 | Flujo de Git en A.5 (`PROPUESTA`): `main` para hitos, `develop` para el trabajo diario; Claude Code sin push |
| v0.3 | 01/10/2026 | A.4, A.5, A.6 y B pasan a `DECIDIDO`. Versiones fijas: Godot 4.7.1-stable y GdUnit4 v6.2.1. Carpetas `docs/` y `addons/` en la estructura. T28 bloqueada por una pregunta a Sistemas. Se escribe `CLAUDE.md` |
| v0.2 | 01/10/2026 | A.2 y A.3 pasan a `DECIDIDO`. Nuevas A.4 (estructura), A.5 (convenciones) y A.6 (testing) en `PROPUESTA`. Nueva sección B: validación de los hitos y plan de 0a en 33 tareas (`PROPUESTA`). B-03 resuelto; respuesta al costo de las previsualizaciones |
| v0.1 | 01/10/2026 | Nueva sección A: motor Godot 4.7 con GDScript tipado y plataforma solo PC (`DECIDIDO`); núcleo de reglas separado de la pantalla; formato JSON con validación y ejemplo de escenario (`PROPUESTA`); vista cenital para 0a.1 y 0a.2 con paso a isométrica antes de los playtests (`PROPUESTA`). B-01 resuelto |
| v0.0 | 01/10/2026 | Creación del borrador: consolidación de los `PARA ARQUITECTO` de `Decisiones.md`, clasificados por módulo y capa, con anexo de `Sistema.md` 14 y `Mundo.md` 9 |
