# ARQUITECTURA — Borrador v0.21

> **Dueño:** Arquitecto Técnico
> **Estado:** BORRADOR. Base para `05_Arquitectura.md`. Secciones A.1 a A.7, A.9, A.10 y B.1 a B.5 `DECIDIDO`; A.8 en `PROPUESTA` (tiene filas ya `DECIDIDO`). **T01 a T12 y T34 terminadas** (T05 a T12 y T34: 04/10/2026; la huella ya excluye `escenarios/`). Próximo paso: **T13**, última tarea del hito 0a.1. **Ninguna tarea de 0a está bloqueada.** `Sistema.md` v1.2 respondió S-13 a S-19 y P-011 a P-022 con la lectura ya programada. Quedan abiertas S-20 = P-024 (Sistemas, no bloquea, T30), D-1 (Director, antes de T33) y A-1 (Arquitecto, despliegue manual, 0b) (10.5).
> **Sincronizado con:** `00_Vision.md` v1.0, `Sistema.md` v1.2 y `Mundo.md` v1.0 (04/10/2026).
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
| Quién escribe los esquemas | `DECIDIDO` (03/10/2026): **T03** construye y prueba el validador y el cargador con archivos de prueba en `pruebas/fixtures/`; los esquemas reales de `datos/_esquemas/` se escriben al **principio de T04**, antes que los datos | T03 prueba la herramienta; los esquemas dependen de los números de `Sistema.md` |
| Carpeta de datos | El cargador recibe la carpeta como **parámetro**: no busca `datos/` por su cuenta | Los tests apuntan a fixtures sin trucos |
| Resultado del cargador | Devuelve `errores` y `avisos`, cada uno con archivo, campo y valor esperado. **Con un solo error no entrega ningún dato.** Un JSON con error de sintaxis es un error con archivo y línea | Nunca hay datos a medias. El bloqueo del arranque del juego lo hace la escena principal (T13) leyendo este resultado |

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
| (salida) | `resultado`, `grabacion` | Resultado del combate y combate grabado (A.6, A.7). `resultado` se revisa y `grabacion` se escribe en **T12** |

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

`null` significa "valor por defecto" (ficha, balanza o `maestro.json`); en `posicion`, que la unidad la ubica el jugador en el despliegue (todavía sin tarea: A-1, 10.5); en `golpe_inicial`, que no hay golpe (A.7). El orden de la lista `tribu` es el **orden de la tribu** (desempates de iniciativa y de rescate). Coordenadas `[x, y]` con `y = 0` arriba (borde enemigo).

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
| Chequeo del cargador | Lista de claves que usa el código contra claves del archivo: avisa de las faltantes (sin impedir el arranque) y de las que sobran. La lista de claves usadas **llega como parámetro** (`DECIDIDO`, 03/10/2026). Además, cada clave debe cumplir `^[a-z0-9_]+(\.[a-z0-9_]+)*$` (error) | El Worldbuilder sabe qué falta escribir |
| Huecos desconocidos | El aviso de todo hueco que no sea una forma conocida lo da el **armador de textos (T34)**, no el cargador (`DECIDIDO`, 03/10/2026) | Solo el armador conoce las formas de hueco: una sola lista, sin copias que diverjan |
| Entrega | `textos/es.json` entregado por el Worldbuilder (`Mundo.md` v0.9, 493 claves) y copiado al repositorio por el usuario en T04. Hasta que exista código que use textos, la carga da avisos de claves sobrantes: es lo esperado | Claude Code no edita `datos/textos/` |

### A.2.2 Reglas de transcripción de los datos — `DECIDIDO` (03/10/2026, T04)

Aplicadas al escribir los datos de 0a. Valen para todo dato futuro.

| Regla | Detalle | Motivo |
|---|---|---|
| **Cada número en un solo archivo** | Antes de agregar un número, se busca si ya está en otro archivo de `datos/` | Dos copias de un número terminan diferentes |
| Tablas derivadas | Las tablas de `Sistema.md` que se calculan desde otras **no se guardan**: se usan como comprobación en la revisión. Son: Arrimo por posición (1.3), lealtad inicial por balanza (4.2), factibilidad de resellar (4.4), referencia de días (5.3), cobardía por balanza (10.6), bonos por eslabón (10.2) y los ejemplos numéricos (5/6/7/7 del Encono, 7 de 11.4) | Son vistas para el diseñador, no fuentes |
| Vida y daño del Maestro | Solo en `tablas/balanza.json`. `maestro.json` lleva lo que no depende de la balanza: Movimiento, Alcance, Velocidad, hechizos y valores iniciales (balanza 2, Poder 1, Regeneración 1) | M-01: todo se deriva de la posición |
| Dónde vive cada número | Efecto por paso de Arrimo → `arrimo.json`. Penalización de obediencia por hambre, Saciado y hambre de combate → `hambre.json`. % de huida por especie y números de los rasgos → `especies/`. Costos de hechizos y daño del choque → `hechizos.json`. Costos de sellar, invocar, resellar y guardar caídas, y costo mínimo → `costos_mana.json`. Eventos de lealtad de 5.2 (victoria, rescate, muerte en el grupo con y sin afines, comer a la atacante) → `tablas/lealtad.json`, objeto `eventos` | Mapa para no duplicar |
| Lista de turnos | La Velocidad es una **lista de turnos**: una entrada por especie, dos para el Tasajero (Caza 8 y Cuenta 3) | `Sistema.md` 11.2 |
| Relaciones | `relaciones.json` incluye los pares de la misma especie (Rodauva–Rodauva bien, Ocarra–Ocarra mal) y los pares con el Tasajero del párrafo debajo de la tabla 10.8 (Rodauva y Ocarra mal, Zancajunco bien) | Sin ellos no existe el Encono contra el Tasajero (T19) |
| Estados de lealtad | Cortes fijos (desleal 0–1, dudosa 2–3) más "neutral hasta umbral − 1"; el umbral sale de la balanza | Los estados son relativos a la balanza |
| Formatos no numéricos | "+1 cada 2 días" → cantidad y cada cuántos días. El "—" de descuento → 0. "Solo en turnos pares" → valor de `enum` (significa rondas pares, 2.1). Tramos de sellado con su límite superior incluido (25, 50, 75, 100) y el camino de confianza aparte | Que el dato no dependa de leer texto |
| Obediencia de las salvajes | Se guarda como **tramo** (`"baja"`), no como un número. Los tramos de obediencia usan **los mismos cortes** que los estados de lealtad de 5.1 (`DECIDIDO`, P-003, `Sistema.md` 5.4 v1.1): el límite se lee de `tablas/lealtad.json`. **T14** quita `obediencia.baja.hasta` de `tablas/combate.json` y de su esquema, en el mismo PR que empieza a leer el corte | `Sistema.md` 10.7 dice "se tratan como obediencia ≤ 3" sin dar valor |
| Orden y fórmulas son código | El orden del inicio del turno (11.3), la lista de la IA (11.8) y fórmulas como "a su alcance = Movimiento + Alcance" se programan con tests; solo sus números son dato | Principio de determinismo |
| Fuera de 0a | Las causas y duraciones de enfermedad (8.1) no se cargan todavía: 0a usa solo el −25% por enfermedad (8.2) | Principio 6 |
| Cita de la fuente | Cada objeto transcripto lleva en `_nota` la sección de `Sistema.md` | Revisión y mantenimiento |
| Revisión | Cada entrega de datos trae una **tabla de cotejo** (`valor | archivo y campo | sección`), una tabla de derivadas reproducidas desde los datos y una de números leídos que no se guardaron y dónde están. La revisa el usuario contra `Sistema.md` | La revisión es contra el documento, no contra el JSON |

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
├── .claude/settings.json  permisos de Claude Code (A.5)
├── project.godot
├── docs/              copia de los documentos del estudio (Visión, Sistema, Mundo, Brief, Arquitectura)
│   ├── PREGUNTAS.md   dudas de Claude Code al staff (A.5)
│   └── RESUMENES.md   resumen de cada sesión de programación (A.5)
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
├── pruebas/           tests del núcleo, con la estructura de nucleo/
│   └── fixtures/      datos chicos de prueba, con errores a propósito
├── herramientas/      reproductor de partidas y scripts de consola
└── registros/         salidas de combates (fuera de Git)
```

**Regla de dependencias:** `pantalla/` puede usar `nucleo/`; `nucleo/` nunca usa `pantalla/`. Una utilidad general que nace en una carpeta de capa (hoy `Porcentajes` en `nucleo/combate/`, desde T09) se mueve a `nucleo/comun/` en la primera tarea de otra capa que la use; mientras tanto no depende de nada de su carpeta. `datos/` no tiene código. Cada capa del roadmap suma carpetas dentro de `nucleo/` (por ejemplo, `nucleo/supervivencia/` en 0b) sin tocar las de combate.

### A.5 Convenciones de código — `DECIDIDO` (01/10/2026)

| Tema | Convención |
|---|---|
| Idioma | Términos del juego en **castellano**, como en `Sistema.md` (`secundar`, `encono`, `obediencia`), sin tildes ni ñ en los identificadores (`mana`, `danio`). La API de Godot sigue en inglés |
| Estilo | El de la guía oficial de GDScript: `snake_case` para variables y funciones, `PascalCase` para clases |
| Tipos | GDScript tipado en todo `nucleo/` |
| Números | **Ningún número de balance escrito en el código.** Si aparece uno, es un error |
| Azar | Ninguna tirada fuera del generador con semilla del núcleo |
| Núcleo | Las clases de `nucleo/` extienden `RefCounted` (nunca `Node`) y no usan autoloads: todo lo que necesitan les llega como parámetro |
| Referencias entre entidades | `DECIDIDO` (03/10/2026, para T05): una entidad del núcleo apunta a otra **por su `id` (texto), nunca guardando el objeto**. La criatura guarda `pergamino_id`; el pergamino, `ocupante_id`; quien necesita el objeto lo pide al contenedor (`Plantel`). Los textos y números de una ficha de especie sí se comparten como objeto de solo lectura | Dos `RefCounted` que se apuntan entre sí nunca se liberan (fuga de memoria en Godot). Además, lo que se guarda por `id` se graba y se reproduce sin traducir (A.7, guardado de 0b) |
| Control de versiones | Git con repositorio privado en GitHub. `DECIDIDO` (03/10/2026): **`main`** solo recibe hitos terminados y revisados (con etiqueta `0a.1`, `0a.2`…); **`develop`** solo recibe tareas revisadas. **Una rama por tarea** (`tarea/T05-unidades`), creada desde `develop`; si la tarea lleva varias sesiones, todas usan la misma rama. Claude Code commitea en la rama (con confirmación del usuario) y **nunca** hace push, merge ni rebase, ni toca `main` o `develop`. El usuario abre el pull request, lo revisa y mergea |
| Permisos | `DECIDIDO` (03/10/2026): `.claude/settings.json` en el repositorio. Permitidos sin preguntar: `git status`, `git diff`, `git log`, `git add` y el comando de tests. Con confirmación: `git commit`. Prohibidos: `git push`, comandos sobre `main`, `merge`, `rebase`, `reset --hard`, y editar `docs/00_Vision.md`, `docs/Sistema.md`, `docs/Mundo.md`, `docs/Arquitectura.md`, `docs/Brief*` y `datos/textos/` | Que el flujo de Git y la propiedad de los documentos no dependan solo de la instrucción escrita. El bloqueo por comandos no es infalible: el push lo hace siempre el usuario |
| Preguntas al staff | `DECIDIDO` (03/10/2026): **`docs/PREGUNTAS.md`** es el único canal de dudas de diseño de Claude Code. Entradas `P-001`, `P-002`… con formato fijo (para quién, tarea, fuente, duda, caso, opciones, si bloquea, qué hizo mientras tanto). Estados: `ABIERTA` → `RESPONDIDA` (el usuario pega la respuesta) → `CERRADA` (aplicada en el código). Claude Code nunca responde ni elige una opción, nunca borra entradas y lee las `RESPONDIDA` al empezar cada tarea. **La copia del repositorio manda**: la sincronización de `docs/` nunca la sobrescribe. Si una respuesta cambia una regla, el área la escribe también en su documento | Las dudas del chat se perdían |
| Ciclo de cada tarea | `DECIDIDO` (03/10/2026): rama → modo plan → plan aprobado por el usuario (archivos, un test por renglón del criterio de terminado, dudas) → tests primero → código → **todos** los tests pasan → Claude Code actualiza la sección "Estado actual" de `CLAUDE.md` → entrada de la sesión en `docs/RESUMENES.md` (la de la última sesión es la descripción del PR) → commit confirmado → `/clear` antes de la tarea siguiente. Las tareas grandes se dividen en sesiones dentro de la misma rama | Cada sesión se puede revisar entera |
| Documentos | Al cambiar la versión de un documento del estudio, se copia a `docs/` en un commit propio (`docs: sincronización <fecha>`) antes de seguir programando: Claude Code trabaja con `docs/`, y una copia vieja es una regla vieja. **Excepción:** `docs/PREGUNTAS.md` y `docs/RESUMENES.md` no se sobrescriben; viajan del repositorio al Project |
| `CLAUDE.md` | Dueño: Arquitecto. Su encabezado dice contra qué versión de este documento **se revisó por última vez**; solo cambia cuando cambia `CLAUDE.md`. Que `Arquitectura.md` tenga una versión más nueva **no es una contradicción**. Claude Code solo edita su sección "Estado actual" |
| Resúmenes de sesión | `DECIDIDO` (04/10/2026): **`docs/RESUMENES.md`** es el historial de las sesiones de programación. Al final de **cada sesión** (aunque la tarea siga), Claude Code agrega una entrada al final con formato fijo: tarea y número de sesión, rama, estado, hecho, archivos, tests, criterio de terminado, lecturas declaradas, claves sin texto, preguntas, y qué queda para la próxima sesión. Nunca edita ni borra entradas anteriores: una corrección va en la entrada nueva. La entrada va en el commit de la sesión. Cuando la tarea termina, la última entrada resume la tarea entera y es la descripción del PR. **No es fuente de verdad**: si contradice a `docs/` o al código, mandan ellos. "Estado actual" de `CLAUDE.md` queda como foto corta del presente | El staff y el Arquitecto ven en qué está el código sin abrir el repositorio, y las tareas de varias sesiones no pierden el hilo entre un `/clear` y el siguiente |
| El Brief y `Sistema.md` | `DECIDIDO` (03/10/2026): si la copia del Brief en `docs/` contradice a `Sistema.md`, **manda `Sistema.md`** (es más nuevo: v1.0 reemplazó, por ejemplo, las "7 métricas del Brief" por las 13 de 11.9). Claude Code anota la contradicción en `PREGUNTAS.md` y sigue con `Sistema.md`. Escrita en `CLAUDE.md` v0.9 | Cierra el pendiente de `Sistema.md` 15 sin tener que revisar el Brief línea por línea |

### A.6 Cómo se testea — `DECIDIDO` (01/10/2026)

| Nivel | Qué | Cómo |
|---|---|---|
| Reglas | Cada regla del núcleo con sus casos de `Sistema.md` y del Brief | Tests automáticos con **GdUnit4 v6.2.1** (compatible con Godot 4.7.1), corridos por consola sin abrir el editor |
| Reproducción | Un combate = escenario + semilla + lista de acciones del jugador. Reproducirlo da exactamente el mismo registro | Reproductor en `herramientas/` |
| Previsualizaciones | El núcleo ofrece **calcular sin aplicar**: la pantalla pregunta "¿qué pasaría si…?" y muestra el resultado. Así la previsualización y el resultado real nunca difieren | Un test por previsualización que compara lo previsto con lo aplicado |
| Pantalla | `DECIDIDO` (04/10/2026, T13). La pantalla no tiene reglas, así que casi no tiene tests propios. Se testea: la lógica sin nodos que traduce la entrada en acciones (`RefCounted`, test normal), y con el runner de escenas de GdUnit4 que el arranque se bloquea con datos rotos, que las escenas se crean con los escenarios reales y que las posiciones salen de `map_to_local`. El resto lo comprueba el usuario con una lista de prueba manual en el resumen de la tarea | Tests en `pruebas/pantalla/`; lista manual en `docs/RESUMENES.md` |
| Juego | Los 8 escenarios del Brief, jugados por personas | Métricas exportadas por combate |

**Comando de tests** — `DECIDIDO` (02/10/2026): `addons/gdUnit4/runtest.cmd -a res://pruebas`, desde la raíz del proyecto. Godot se encuentra por la variable de entorno `GODOT_BIN` (configurada en T01 con `setx`); la ruta de la máquina nunca se escribe en un comando ni en un script. Si el comando falla por algo que no es un test, Claude Code para y muestra el error.

**Qué datos usa cada test** — `DECIDIDO` (03/10/2026, desde T05). Los tests son código, y cambiar un número de balance no puede obligar a tocar código (principio 1):
- **Tests de reglas** (T05 en adelante): usan **datos de prueba propios** en `pruebas/fixtures/`, con los números del ejemplo de `Sistema.md` que reproducen y la sección citada en `_nota`. Nunca leen `datos/`. Si Sistemas cambia la vida de la Ocarra, ningún test de reglas falla: la mecánica sigue igual.
- **Tests de datos reales**: solo los que comprueban que `datos/` carga y se puede usar entero (el test permanente y, desde T05, la creación del plantel de los 11 escenarios). No comparan números contra `Sistema.md`: eso es la revisión del usuario con la tabla de cotejo (A.2.2).
- Los fixtures se escriben con los **mismos esquemas** que `datos/`, así que no pueden desviarse del formato real.

**Test permanente de datos** — `DECIDIDO` (03/10/2026): desde T04, un test carga **toda la carpeta `datos/`** con el cargador real y exige cero errores (los avisos de claves de texto **sobrantes** se aceptan siempre en 0a: `es.json` trae los textos de 0b, que el código de 0a todavía no usa; las claves **faltantes** las informa T13 con la lista de claves usadas). Cualquier cambio que rompa los datos lo hace fallar.

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

**Formato del registro, la grabación y la huella** — `DECIDIDO` (04/10/2026, T12):

| Pieza | Decisión |
|---|---|
| Quién escribe el registro | `Combate`, nunca las reglas. Antes de cada evento vuelca las tiradas nuevas del generador de combate, así quedan en orden |
| Línea del registro | Un diccionario por evento, con `n` (consecutivo) y `ronda`. Solo enteros, textos, booleanos, listas y diccionarios; claves ordenadas al serializar. Un `float` es un error |
| Eventos de 0a.1 | `inicio` (escenario, semilla, huella) · `ronda` · `turno` (unidad, marca `caza` / `cuenta` / `null`) · `accion` (unidad, origen `jugador` / `ia`, la `Accion` como diccionario, paso de la IA) · `movimiento` (unidad, desde, hasta) · `ataque` (atacante, objetivo, desglose, vida antes y después) · `estado` (unidad, de, a) · `tirada` (lo que registra T02) · `fin_turno` (unidad, posición) · `fin_ronda` · `fin` (desenlace) · `cierre` (levantadas, muertas, pergaminos ardidos, lealtad). Las tareas siguientes **agregan** tipos (incidente, sellado, huida…) sin cambiar estos |
| Métricas | Salen del registro (`Sistema.md` 11.9: "todo sale del registro"). T12 no calcula ninguna; deja en el registro lo necesario para las 1, 9, 11 y 13. Las calculan T23 y T33 |
| Grabación | Versión de formato, **escenario entero** tal como se jugó (el panel de T31 lo cambia), huella y acciones del jugador en orden, cada una con el `id` de su unidad. No guarda decisiones de la IA ni tiradas: salen del estado y de la semilla |
| Acción N | Estado justo después de aplicar la N-ésima acción **del jugador** y de jugar los turnos de la IA que siguen. N = 0: antes de la primera acción del jugador |
| Huella de los datos | SHA-256 de la serialización canónica (claves ordenadas) de los datos cargados, **sin `textos/` ni `escenarios/`, y sin `_nota` ni `$schema`** a ninguna profundidad. Una corrección de texto o de nota no invalida grabaciones; un número de reglas sí. `escenarios/` queda afuera porque la grabación lleva su escenario entero: editar un archivo de escenario no cambia cómo se reproduce (corrección del 04/10/2026, tras T12). Vive en `nucleo/datos/` (la usa también el guardado de 0b) |
| Desincronización | Huella distinta → aviso, y se reproduce igual. Acción grabada que no corresponde (otra unidad, o inválida en ese punto) → error con su número, y se detiene |

### A.8 Decisiones técnicas para 0b — `PROPUESTA` (02/10/2026)

No se construye nada de esto en 0a (principio 6). Se escriben ahora para no cerrarles el paso.

| Tema | Propuesta | Motivo |
|---|---|---|
| Guardado de la partida | Un solo espacio que se sobrescribe solo, al cerrar cada día y al entrar en combate. En modo de prueba, guardados libres. La partida se guarda como JSON con el estado de los generadores de azar. **Dentro de un combate:** guardado de suspensión por grabación (`DECIDIDO`, A.7) | Permadeath absoluto. La Visión v0.9 decidió que salir a mitad de un combate retoma el estado exacto |
| Cierre del día | Lista ordenada de pasos (`Sistema.md` 7.9) que se puede **pausar y retomar**: el paso 0 pide una elección y el paso 2 puede abrir un combate | Respeta el orden escrito y permite sumar pasos futuros (F-06) sin tocar los otros |
| Eventos de nodo | Catálogo cerrado de **condiciones** (criatura suelta de tal especie, objeto en inventario, estado del Tasajero, ya visitado…) y **efectos** (comida, material, texto, iniciar combate…). Sin lenguaje de scripts | Testeable; Worldbuilder arma eventos combinando piezas |
| Azar | Una semilla por partida, de la que se derivan generadores separados por sistema (combate, mapa, noche, encuentros, **textos**). El de textos es `DECIDIDO` desde 0a (A.2.1) | Sumar una tirada en el mapa o una frase nueva no cambia los combates de una partida grabada. **Derivación** (`DECIDIDO`, 04/10/2026, T12): `GeneradorAzar.derivado(semilla, sistema)` toma los primeros 8 bytes del SHA-256 de `"semilla/sistema"`; no depende del orden en que se crean los generadores |
| Partida de prueba | La configuración inicial de la partida es un dato; en modo de prueba se pueden cambiar la balanza inicial (Visión v0.9, 10), la duración (30 o 20 días, `Sistema.md` 13) y la semilla | Jugar partidas enteras inclinadas al Soplo sin tocar la clase real |
| Flujo | Máquina de estados de la partida: apertura → Molino → mapa del mundo → mapa de nodos → (evento o combate) → noche → cierre del día → … → epílogo. La pantalla observa la fase; el núcleo la cambia | Mismo principio que el combate: reglas sin pantalla |

### A.9 Escenarios de 0a — `DECIDIDO` (03/10/2026, T04)

Los 11 archivos de `datos/escenarios/`. Lo que mide cada uno vive en su `_nota`.

| Archivo | Origen | Notas |
|---|---|---|
| `a_dia_1.json` | Arquitecto | El ejemplo de A.2 |
| `b_muro.json` | Sistemas, 11.9 | |
| `c_tasajero.json` | Sistemas, 11.9 | La Rodauva se pasa a guardada desde el panel (T31) |
| `d_rivales_normal.json` · `d_rivales_hambriento.json` | Sistemas, 11.9 | |
| `d_rivales_balanza4.json` | Sistemas, 11.9 y 14 | D normal con balanza 4. **Temporal:** se borra cuando T31 permita cambiar la balanza desde el panel |
| `e_cobardia.json` · `e_cobardia_afines.json` | Sistemas, 11.9 | Sin y con el toggle de afines (10.6) |
| `f_rescate.json` | Sistemas, 11.9 | |
| `g_ataque_nocturno.json` | Arquitecto | Definido abajo |
| `h_soplo.json` | Sistemas, 11.9 | C con balanza 5 y Poder 3 |

**Semillas:** arbitrarias, pero compartidas por las variantes que se comparan: C y H; las tres D; las dos E (11.9). Las 10 semillas de los playtests son de T31 y T33.

**Escenario G** (11.9 lo deja como borrador del Arquitecto):

| Campo | Valor | Motivo |
|---|---|---|
| Tipo | `nocturno` | A.7 |
| Maestro | Balanza 2, hambre 3, **maná de entrada 4** | La mitad de la reserva completa (2.4); coincide con el "tope nocturno 4" de 4.4 |
| Atacante | Ocarra, `atacante_nocturna`, hambre 9 | Famélica y desleal: la condición del abandono nocturno (9.1) |
| Golpe inicial | El `id` de la Ocarra | Golpe de 4 (9.2). No hay otra Ocarra suelta: no hay Centinela |
| Tribu | Rodauva y Zancajunco, lealtad **8** (leales) | El Zancajunco suelto habilita `nocturno.comer.zancajunco_suelto`. Las dos leales: solo las leales defienden al Maestro (S-12, `Sistema.md` 9.2) |
| Pergaminos en blanco | 1 | Sin él no existe la salida "sellar" |

La pregunta de G es "¿alcanza para resellar?": resellar a la Ocarra cuesta 2; con un Martillazo todavía alcanza, con un Remiendo no.

**Valores de los huecos de 11.9** — propuestos por el Arquitecto en T04 y `DECIDIDO` por Sistemas (`Sistema.md` 11.9 v1.1, responde P-004 a P-007). Ya están en los datos; no cambia nada:

| Hueco de 11.9 | Valor |
|---|---|
| "Leal" y "Neutral" sin número (Surcón de E; Rodauva y Ocarra de F) | Leal 8, Neutral 5, como en B, C y E. 8 sigue siendo leal con la balanza en 5 (P-004) |
| D y E no nombran al Maestro | Está en los 11, con los valores iniciales salvo F (vida 6), G (maná 4), H (balanza 5, Poder 3) y `d_rivales_balanza4` (P-005) |
| D hambriento: ¿el Maestro también con hambre 6? | No: solo las criaturas. La única diferencia entre las dos D es la obediencia (P-006) |
| Posiciones fijas | Propuestas por Claude Code en T04 y aprobadas por Sistemas **como provisorias** (tabla siguiente; motivo de cada una en P-007). **Ante una alarma de 11.9, primero se descarta que la causa sea la posición; después se toca la regla** |

**Posiciones iniciales provisorias** (P-007). Coordenadas `[x, y]`, `y = 0` arriba; M = Maestro.

| Escenario | Tribu | Enemigas | Lo que buscan |
|---|---|---|---|
| A | M [3,7], Rodauva [4,7] | Ocarra [4,0] | Copia del ejemplo de A.2. La IA de 11.8 manda: la Ocarra va por la Rodauva, y la apuesta de A es la Rodauva, no la vida del Maestro (P-009, `Sistema.md` 11.6). T05 actualiza la `_nota` |
| B | M [3,6], Rodauva [4,7] | Ocarras [0,0] y [7,1] | Llegan en diagonal sin tocarse: juntarlas con la Lanzadera es una jugada real, no un incidente gratis |
| C y H | M [3,6], Rodauva [2,6], Ocarra [3,7], Zancajunco [4,6] | Tasajero [3,0] | Pega en la Cuenta de la ronda 1; la suerte de la Rodauva la decide el jugador |
| D (3 variantes) | M [3,6], Ocarra [3,7], Zancajunco [4,7] | Surcón [3,1], Rodauva [4,1] | Las rivales aliadas empiezan adyacentes: separarlas es la primera decisión |
| E (2 variantes) | M [4,6], Rodauva leal [6,6], Rodauva Neutral [6,7], Surcón [4,7] | Tasajero [0,0] | La primera tirada de cobardía cae en la ronda 2, con la formación elegida |
| F | M [3,6] (vida 6), Rodauva [3,7], Ocarra [4,7] | Zancajunco [3,0], Surcón [4,1] | El Zancajunco tumba al Maestro en la ronda 2 si no se lo bloquea |
| G | M [3,6], Rodauva [2,6], Zancajunco [4,6] | Ocarra atacante [3,4] | Única enemiga fuera de las filas 0–1: acaba de golpear al Maestro dormido |

### A.10 Estado de la construcción — `DECIDIDO` (03/10/2026)

| Tarea | Estado | Fecha | Notas |
|---|---|---|---|
| T01 | ✅ Mergeada | 02/10/2026 | Godot 4.7.1, GdUnit4 6.2.1, estructura, `GODOT_BIN` |
| T02 | ✅ Mergeada | 03/10/2026 | Generador de azar con semilla. 5 tests |
| T03 | ✅ Mergeada | 03/10/2026 | Dos sesiones: validador (15 tests) y cargador con chequeos cruzados |
| T04 | ✅ Mergeada | 03/10/2026 | Cuatro sesiones: esquemas; especies, Maestro, hechizos y relaciones; seis tablas (3a); `combate.json` (3b); escenarios y textos. Test permanente de carga |
| T05 | ✅ Terminada | 04/10/2026 | Dos sesiones: `Especie`, `TablaBalanza`, `Criatura`, `Maestro`; `Pergamino` y `Plantel` (`desde_escenario`, `desde_datos`). 74 tests. Cierra P-004 a P-007 y P-009; P-010 se cierra con el test (8) |
| T06 | ✅ Terminada | 04/10/2026 | `nucleo/combate/tablero.gd`, 89 tests. Filas de despliegue leídas de `combate.json` (`despliegue_filas`, ya existía). El Maestro suma Movimiento y Alcance de `maestro.json`. Lecturas literales declaradas en el plan: una caída enemiga bloquea (S-13), quedarse quieto es una casilla alcanzable, las guardadas no ocupan casilla |
| T07 | ✅ Terminada | 04/10/2026 | `nucleo/combate/cola_iniciativa.gd` (`ColaIniciativa`) y `entrada_cola.gd` (`EntradaCola`). `Maestro` suma `ID` y `velocidad` (de `maestro.json`). Lecturas declaradas: P-011 (= S-14), P-012 y P-013 |
| T08 | ✅ Terminada | 04/10/2026 | `turno.gd`, `accion.gd`, `resultado_accion.gd` y `danio.gd` (`Danio.calcular`: Daño base y mínimo de `combate.json`). `Criatura` suma `erizada`. Erizarse por `rasgo.efecto` y `rasgo.inmovil` de la ficha, nunca por `id`. 115 tests. Lecturas declaradas: P-014 (= S-15) y P-015 (= S-16). Técnicas: mover a la misma casilla se rechaza (`MISMA_CASILLA`); hasta T10, una unidad con vida 0 sigue `suelta` y se la puede atacar; el turno se cierra siempre con `terminar`. Primera entrada de `docs/RESUMENES.md` |
| T09 | ✅ Terminada | 04/10/2026 | `danio.gd` completa 11.4; nuevos `porcentajes.gd` (`Porcentajes.aplicar`, enteros con piso explícito, sin mínimo, K-05), `modificador_danio.gd` y `desglose_danio.gd`. `Criatura` suma `ya_ataco` (lo gasta `Danio.registrar_ataque`, solo al aplicar). `Turno` cambió dos líneas. Sin cambios de datos. 127 tests. Lecturas: P-016 (= S-17) y P-017 (= S-18). Técnicas: `ya_ataco` arranca en `false` porque el `Plantel` se arma por combate (0b la repone); **la tabla de hambre es opcional en `Danio.desde_datos`** (deuda saldada en T12: ahora es obligatoria); `Porcentajes` vive en `nucleo/combate/` sin depender del combate (A.4) |
| T10 | ✅ Terminada | 04/10/2026 | Dos sesiones. **1:** `vida_cero.gd`, `fin_combate.gd`; `Criatura.Estado.FUERA`, `Maestro.caido`; `Turno` rechaza todo con `COMBATE_TERMINADO`. **2:** `cierre.gd` y `resultado_cierre.gd` (`Cierre.desde_datos(...).cerrar(plantel, fin)`: una sola vez; rechaza `EN_CURSO`, `YA_CERRADO`, `HUIDA` sin programar y un fin que no coincide con `FinCombate`); en `nucleo/unidades/`, `Relaciones` (primera clase que lee `relaciones.json`) y `AcumuladorLealtad` con `AnotacionLealtad` y `CambioLealtad`. `Criatura.Estado.MUERTA` y `Plantel.cerrado`, solo en tiempo de ejecución. 145 tests. Cierra P-001. Lecturas: P-018 (= S-13) y P-019 (respondida por el Arquitecto, 10.5). Técnicas: la muerta conserva vida 0 y casilla y pierde el pergamino; "de noche, solo las que pelearon" queda para 0b / T30 |
| T11 | ✅ Terminada | 04/10/2026 | `nucleo/combate/ia/`: `IASalvaje.decidir` → `DecisionIA`, `OpcionAtaque`. `Turno.previsualizar_ataque` comparte `_atacar_desde` con el ataque real; `Tablero.pasos_hasta` (BFS extraído). Umbral de Erizarse como dato (`rasgo.umbral_vida_pct`). 159 tests. Lecturas P-020 (= S-19), P-021 y P-022. Técnica: "prefiere la distancia 2" = la casilla más lejana a la objetivo dentro de su alcance |
| T12 | ✅ Terminada | 04/10/2026 | Dos sesiones. `ContextoCombate`, `Combate`, `RegistroCombate`, `ResultadoCombate`, `Grabacion`, `Reproductor`, `HuellaDatos` (`nucleo/datos/`) y `herramientas/reproducir.gd`. `GeneradorAzar.derivado`. P-019 aplicada (+1 de victoria en `lealtad.json` `eventos.victoria`). Esquemas `resultado` (revisado) y `grabacion` (reescrito; trae a su `$defs` las definiciones locales del escenario porque el validador busca las referencias en la raíz). 179 tests. Cierra P-011 a P-023. Lecturas: `desenlace` con los nombres de `FinCombate`; `atacante_pendiente` = atacante caída sea cual sea el desenlace (S-20); campos futuros en `null` o vacíos, explicados en su `description`. **Ajuste posterior** (`tarea/T12-ajustes`, fila siguiente): la huella excluye `escenarios/` (A.7) |
| T34 | ✅ Terminada | 04/10/2026 | `nucleo/textos/`: `ArmadorTextos` (`armar`, `armar_lineas`, `avisos`, `revisar`, `PREFIJOS_COMPLEMENTO`) y `HuecoCriatura`. Artículo y nombre desde `especie.<id>.articulo` y `especie.<id>.nombre`. `revisar` sobre `es.json`: 0 avisos. 190 tests. Técnicas: una lista de 1 elemento también tira; una variante que existe se usa aunque falte la base; las mayúsculas se aplican por línea, después de llenar los huecos; especie sin artículo o nombre → `[FALTA]` con aviso `ESPECIE_SIN_TEXTO` |
| T12 (ajustes) | ✅ Terminada | 04/10/2026 | Rama `tarea/T12-ajustes`: la huella excluye `escenarios/`; S-20 registrada como P-024 (comentario en `ResultadoCombate.armar`, sin cambiar la lógica) |
| T13 | Siguiente | — | Pantalla cenital, dos sesiones (B.2). Cierra el hito 0a.1 |

Orden que sigue en 0a.1: T13 → cierre del hito (merge de `develop` a `main`, etiqueta `0a.1`).

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
| T02 | ✅ **Terminada** (03/10/2026). Generador de azar con semilla que registra cada tirada. Es un **objeto que se crea** (no un global): puede haber varios a la vez, y de una semilla se derivan generadores independientes (combate, textos) | Principio 3, A.7, A.2.1 | Misma semilla → misma secuencia de 1.000 tiradas; otra semilla → otra secuencia; dos generadores con la misma semilla no se interfieren |
| T03 | ✅ **Terminada** (03/10/2026, dos sesiones). Cargador y validador de JSON: subconjunto de JSON Schema, enteros de Godot y chequeos cruzados | A.2 | Un archivo con un error devuelve archivo, campo y valor esperado, y el juego no arranca. Tests con: campo mal tipeado, decimal donde va entero, valor fuera de rango, obligatorio faltante, `enum` inválido, especie inexistente, `type` con lista de tipos y diccionario de claves libres (clave con formato inválido) |
| T04 | ✅ **Terminada** (03/10/2026, cuatro sesiones; ver A.2.2 y A.9). Esquemas reales de `datos/_esquemas/` y datos de 0a según A.2: fichas, Maestro, hechizos, relaciones, 7 tablas, escenarios A y G (Arquitecto) y B a F y H (Sistemas, 03/10/2026), más `d_rivales_balanza4.json`, variante temporal de D con la misma semilla hasta que exista T31. `textos/es.json` del Worldbuilder | W-01, A.2, `Sistema.md` 11.9 | Todo carga sin errores y los números coinciden con `Sistema.md` (revisión del usuario). Los escenarios validan con `_nota` dentro de cada unidad y `"guardada"` como `estado`: si fallan ahí, se corrige el esquema, no el escenario |
| T05 | ✅ **Terminada** (04/10/2026, dos sesiones). Modelo de unidades en `nucleo/unidades/`. **Sesión 1:** `Especie` (la ficha, de solo lectura), `Criatura` (instancia: `id`, especie, bando, comportamiento si es enemiga, estado `suelta` / `guardada` / `caida`, vida, lealtad, hambre, enfermedades, posición, `pergamino_id`) y `Maestro` (balanza, Poder, Regeneración, vida, hambre, enfermedades, posición, `mana_entrada` tal cual llega: se resuelve en T21). **Balanza derivada:** una función devuelve la fila de `tablas/balanza.json` para la posición; `vida_max_real` y el daño del Maestro salen de ahí y **nunca se guardan** (M-01). **Sesión 2:** `Pergamino` (`id`, estado en blanco / ocupado / ardido, `ocupante_id`) y `Plantel` (contenedor del combate: el Maestro, las criaturas en el orden de la tribu y los pergaminos, todo buscable por `id`), creado desde `maestro`, `tribu`, `enemigas` y `pergaminos_en_blanco` de un escenario, resolviendo los `null`. Ocupan pergamino: cada criatura de la tribu (suelta o guardada) y la atacante nocturna (`Sistema.md` 3.2); las salvajes no. Ids `pergamino_1`, `pergamino_2`… en orden: tribu, atacantes, en blanco. Referencias por `id` (A.5). **No incluye** métodos que cambien vida, lealtad, hambre o estado por una regla: llegan con T08–T10, T14 y T24–T27. El resto del contexto (tablero, semilla, golpe inicial, toggles) es de T12. Al empezar: cierra P-004 a P-007 (ya aplicadas en T04) y aplica P-009 en la `_nota` de `a_dia_1.json` | C-01, C-02, M-01, M-03, P-01, A.5, A.7, `Sistema.md` 1.2, 3.1, 3.2, 11.2 | Tests (con fixtures, A.6, salvo el 3): (1) con una tabla de balanza de prueba que copia la 1.2, el Maestro con balanza 2 tiene vida 20 y daño 4, y con balanza 5, vida 14 y daño 3, sin esos números en el código; (2) las dos Ocarras salvajes de B son independientes: cambiar la vida de una no toca la otra, y no tienen pergamino (P-010); (3) con `datos/` real, se crea el plantel de los 11 escenarios sin errores, y en F el Maestro queda en 6 con la vida máxima de su balanza; (3b) con fixtures, `vida: null` da la vida máxima de la ficha o de la balanza; (4) en G, la Rodauva, el Zancajunco y la Ocarra atacante ocupan un pergamino cada una y queda 1 en blanco; en A, la Ocarra salvaje no tiene pergamino; (5) dos creaciones del mismo escenario dan los mismos `id` de pergamino; (6) un pergamino ocupado no se vuelve a ocupar y uno ardido no se usa; (7) la ficha del Tasajero tiene dos turnos (8 y 3); (8) las dos Rodauvas de la tribu de E (leal 8 y Neutral 5) tienen lealtad propia y pergaminos distintos (C-02; agregado por P-010) |
| T06 | ✅ **Terminada** (04/10/2026). Tablero y geometría en `nucleo/combate/`, sin turnos ni acciones. `Tablero` desde `{ancho, alto}` del escenario. Consultas puras, que reciben el `Plantel` y no lo modifican: distancia Manhattan; las 4 vecinas ortogonales; **casillas a las que llega una unidad** (camino ortogonal de hasta Movimiento pasos, BFS: atraviesa aliadas y caídas propias, nunca enemigas, y no termina en casilla ocupada); **línea recta entre dos casillas y si la bloquea una enemiga** (base del alcance 2 y, en T22, de la Lanzadera); **casillas a las que puede golpear** una unidad desde una casilla según su Alcance (1: adyacentes; 2: además, en línea recta por encima de aliadas, nunca de enemigas); y **casillas de despliegue** por bando (las 2 filas de cada borde; si el número no está en `datos/`, primero esquema, después dato). "Aliada" y "enemiga" son relativas al bando de quien mueve o golpea. El Movimiento sale de la ficha o de `maestro.json`, sin modificadores (Erizarse es T08) | K-03, `Sistema.md` 11.3 (filas Tablero, Movimiento, Distancias, Despliegue, Adyacencia y Alcance 2) | Un test por regla, con fixtures: Manhattan; diagonal no es adyacente; una enemiga en el camino obliga a rodear y el rodeo cuesta pasos; se atraviesa a una aliada y a una caída propia pero no se termina encima; una enemiga en pasillo hace de muro; la Ocarra pega a distancia 2 en línea por encima de una aliada y no por encima de una enemiga, ni en diagonal; casillas de despliegue de cada bando en un 8 × 8; nada se sale del tablero; las consultas no cambian el `Plantel` |
| T07 | ✅ **Terminada** (04/10/2026). Cola de iniciativa en `nucleo/combate/`, sin ejecutar turnos. **La cola de cada ronda se arma al empezarla** desde el `Plantel`: una entrada por turno (`unidad_id`, marca `caza` / `cuenta` / ninguna, ya actuó o no). Entran las unidades de pie en el tablero; no entran guardadas, caídas ni unidades fuera del tablero. Orden: mayor Velocidad primero, sin azar; empates: bando del jugador antes que el enemigo → Maestro antes que sus criaturas → orden de la tribu; **entre enemigas, el orden de la lista `enemigas` del escenario** (S-14, lectura declarada). El Tasajero tiene **dos entradas** según su lista de turnos, cada una un turno completo con su marca. Durante la ronda: avanzar al siguiente turno **salteando** las entradas cuya unidad ya no puede actuar (cayó, fue guardada, salió del tablero); una unidad que aparece a mitad de ronda (invocada) **no entra hasta la ronda siguiente**, porque la cola ya está armada. Contador de rondas y un punto de **fin de ronda** sin efectos (ahí se enchufan el hambre de combate, T14, y el corte de cadenas, T16). La cola es una **lista ordenada editable**: T17 moverá una entrada detrás de otra (Secundar); hoy no se programa Secundar. La Velocidad sale de la ficha o de `maestro.json` | K-01, `Sistema.md` 10.1, 11.2, 11.3 (filas Orden, Empates y Criatura invocada) | Tests (fixtures): (1) Prueba A: Ocarra, Rodauva, Maestro; (2) Prueba C: Zancajunco, Tasajero (Caza), Ocarra, Rodauva, Maestro, Tasajero (Cuenta), con el empate en 8 a favor del jugador; (3) Maestro empatado con una criatura va antes; (4) las dos Rodauvas de E empatadas siguen el orden de la tribu; (5) las dos Ocarras de B empatadas siguen el orden de `enemigas`; (6) una guardada no entra; una unidad que cae antes de su turno se saltea; una unidad que pasa a suelta a mitad de ronda entra recién en la siguiente; (7) el Tasajero tiene dos entradas con sus marcas y la ronda termina después de la última entrada; (8) el mismo plantel da la misma cola y no se usa el generador de azar. Que el Tasajero **mueva y actúe** en cada entrada se prueba en T08 |
| T08 | ✅ **Terminada** (04/10/2026). Turno de una unidad en `nucleo/combate/`, sin IA ni pantalla. **Un turno por entrada de la cola** (T07): el Tasajero juega dos turnos completos por ronda, uno por entrada. Cada turno tiene **1 movimiento y 1 acción**, en cualquier orden. **Las acciones son datos** (`tipo` + parámetros: `mover` a una casilla, `atacar` a un `id`, `erizarse`, `terminar`) y son **las mismas para el jugador y para la IA** (T11): así T12 las graba tal cual. Toda acción se puede **validar sin aplicar** (devuelve si vale y, si no, un motivo de un `enum`); una acción inválida no cambia nada. **Mover:** a una de las casillas que da `Tablero` (T06), de una sola vez: el movimiento se gasta entero aunque sobren pasos (no se parte). **Atacar:** gasta la acción; la objetivo es una enemiga de pie en una casilla que la unidad golpea desde donde está (T06). El daño sale de **una sola función de daño** en su propio archivo, que en T08 devuelve el Daño base (ficha, o balanza para el Maestro) con mínimo 1, y que **T09 completa con la fórmula 11.4 sin tocar el turno**. La vida baja y no pasa de 0; lo que pasa en 0 es T10. **Erizarse:** solo si la ficha tiene ese rasgo; gasta la acción; la criatura queda erizada **hasta el inicio de su próximo turno** y mientras tanto no puede moverse por sí misma: si ya se movió en el turno, vale; si no, pierde el movimiento (S-15, lectura declarada). El −50% es de T09; que la Lanzadera la mueva, de T22. **Esperar** = `terminar` sin usar la acción: lo que no se usó se pierde (como el orden es libre, da lo mismo que "esperar y después mover"). **Puntos vacíos:** inicio del turno (primero se borra la marca de erizada; después se enchufan, en el orden de 11.3, maná T21, huida T25, Encono o cobardía T19 e incidente T18) y fin del turno (T16, T23). **No se programan:** hechizos, sellar, guardar, invocar ni huir: son tipos de acción nuevos en T22, T24 y T26 a T28 (invocar y huir exigirán el turno sin usar) | K-01, K-03, `Sistema.md` 11.2 (Erizarse, Caza y cuenta), 11.3 (fila Turno de una unidad e inicio del turno) | Tests (fixtures): (1) mover y después atacar, y atacar y después mover; (2) después de mover 1 paso de 4 no se puede volver a mover; (3) no hay segunda acción; (4) se rechaza con motivo, y el `Plantel` no cambia: mover a una casilla no alcanzable; atacar a una aliada, a una caída, fuera de alcance o, con la Ocarra, por encima de una enemiga; (5) con una balanza de prueba, el Maestro pega el daño de su balanza y una criatura el de su ficha, sin esos números en el código; (6) la vida no baja de 0; (7) la Rodauva se eriza: gasta la acción; no puede moverse después en ese turno; si se había movido antes, vale; sigue erizada durante los turnos de las demás y deja de estarlo al empezar su próximo turno, también si es en la ronda siguiente; (8) una especie sin el rasgo no puede erizarse; (9) Prueba C: el Tasajero mueve y ataca en su entrada Caza y otra vez en Cuenta, con movimiento y acción renovados (pasa de T07); (10) terminar sin actuar (esperar) cierra el turno y la cola sigue con la entrada que corresponde; (11) validar una acción no cambia el `Plantel` y da el mismo resultado que aplicarla; (12) el turno no usa el generador de azar |
| T09 | ✅ **Terminada** (04/10/2026). Fórmula de daño completa **dentro de `Danio.calcular`** (T08), sin cambiar quién la llama. **Orden de 11.4:** se suman los porcentajes → se aplican al Daño base redondeando hacia abajo → se suman los planos → mínimo 1. **Aritmética en enteros** (porcentajes en puntos, sin `float`) con el piso explícito: la división entera de GDScript trunca hacia 0, que con negativos no es lo mismo que redondear hacia abajo. **Una función de porcentajes aparte**, sin mínimo: la misma que usará la recolección en 0b (K-05; la recolección puede dar 0, el daño no). **Fuentes que T09 calcula sola**, con sus números en `datos/`: Saciado (hambre 0–2 de la atacante, derivado, nunca un campo aparte), enfermedades (cantidad de la atacante, cada una un porcentaje negativo), Erizarse (objetivo erizada), Lomo de tierra (objetivo con ese rasgo, plano negativo) y Hacerse junco (plano positivo en el **primer ataque del combate** de la atacante: una marca en la criatura que se gasta al **aplicar** un ataque, nunca al validarlo ni con un ataque rechazado). **Fuentes de tareas futuras, como parámetro:** una lista de aportes externos (porcentaje o plano, con su fuente) por donde van a entrar combo (T16), afinidad (T15), Encono y cobardía (T19); hoy solo la usan los tests. **El resultado es un desglose:** Daño base, cada modificador con su fuente, tipo y valor, porcentaje total, daño tras porcentajes, planos, si actuó el mínimo y total. Lo leen la pantalla (T13) y el registro (T12). Los rasgos se reconocen por su efecto en la ficha, nunca por `id`. Las enemigas no tienen `hambre` ni `enfermedades` en el escenario: no reciben Saciado ni enfermedades (S-17, lectura declarada) | K-04, K-05, C-07 (0a), `Sistema.md` 7.1, 8.2, 8.4, 11.2, 11.4 | Tests (fixtures): (1) ejemplo de 11.4: el Maestro (4) con un aporte de combo +50% y uno de afinidad +1 hace 7; (2) la Rodauva saciada hace 2 (2,5 → 2), y con hambre 3 también 2; (3) Saciado con 1 enfermedad = 0%: la Ocarra saciada y enferma hace 4; (4) con 3 enfermedades, el Maestro hace 1; (5) contra una Rodauva erizada, la Ocarra hace 2 y el Tasajero 3; (6) contra el Surcón, el Maestro hace 3 y la Rodauva 1; (7) el Zancajunco hace 6 en su primer ataque y 4 en el segundo; validar y un ataque rechazado no gastan el bono; (8) con porcentajes por debajo de −100% (Rodauva con 3 enfermedades contra una Rodauva erizada) el daño es 1; (9) el desglose reconstruye el total y marca cuándo actuó el mínimo; (10) la función de porcentajes sola, sin mínimo: 1 con −50% da 0, y 5 con −25% da 3; (11) una Ocarra enemiga hace 4 aunque la tribu esté saciada; (12) los tests de T08 siguen pasando sin tocarlos |
| T10 | ✅ **Terminada** (04/10/2026, dos sesiones). Vida en 0, fin del combate y cierre, en `nucleo/combate/`. **Dos sesiones.** **Sesión 1 — vida en 0 y fin del combate.** Después de **aplicar** un ataque, si la objetivo llegó a 0 se resuelve en el acto según 11.5: criatura de la tribu → `caida` (queda en su casilla y la ocupa); salvaje → **sale del tablero** (estado nuevo `fuera`, sin posición; el mismo estado que usarán la huida, T25, y el sellado, T24); atacante nocturna → `caida` (su destino es T30); Maestro → caído y el combate termina **en el acto**. Después de cada acción aplicada se mira el fin: **victoria** si no queda ninguna enemiga en pie en el tablero (dicho así, en general: después también cuentan la huida y el sellado), **derrota** si cayó el Maestro. Con el combate terminado, toda acción se rechaza con su motivo y el resultado de la acción dice que el combate terminó y cómo. **Una unidad en 0 deja de ser objetivo** (corrige la lectura técnica de T08). Nada de esto toca la lealtad. **Sesión 2 — cierre.** Una función de cierre que recibe el `Plantel` y **cómo terminó** (`victoria` o `derrota_por_caida`; el valor `huida` queda en el `enum` sin programar, T26) y devuelve un **cierre** (lo serializa T12): en victoria, las caídas de la tribu se levantan con la vida de `combate.json` (1); en derrota, las caídas de la tribu **mueren**: estado `muerta`, su pergamino **arde** y se aplica muerte en el grupo. Las guardadas no se tocan. **Acumulador de lealtad:** cada cambio se anota con su motivo y su criatura; al final se suma por criatura y se recorta a 0–10 **una sola vez** (números de `tablas/lealtad.json`). Victoria: +1 a las **sueltas al terminar** (de pie, caídas que se levantaron, invocadas durante el combate); las guardadas no. Muerte en el grupo: por cada muerta, −2 a cada suelta y −4 a las de especie afín (relación "bien" de 10.8, suelta por suelta, sin mirar posiciones; P-001); la muerta no recibe nada. El rescate (y su +2), la permadeath y lo que pasa con el Maestro caído **no son de T10**: el cierre solo dice que el Maestro cayó. El hambre de combate de las caídas es T14 | K-08, K-09, P-01, `Sistema.md` 3.2, 5.2, 6, 11.5 | Tests (fixtures), **sesión 1:** (1) la Rodauva de la tribu llega a 0 y queda caída, en su casilla, sin poder ser atacada, y la cola la saltea; (2) una Ocarra salvaje en 0 sale del tablero y su casilla queda libre; (3) la atacante nocturna en 0 queda caída; (4) cae la última enemiga en pie → victoria, y la siguiente acción se rechaza; con dos enemigas, tumbar a una no termina el combate; (5) cae el Maestro → derrota en el acto, aunque queden turnos en la cola. **Sesión 2:** (6) victoria con una caída: se levanta con 1 y recibe el +1; una guardada no lo recibe; (7) derrota con dos caídas: las dos mueren, sus pergaminos arden, y la muerte en el grupo se aplica dos veces; (8) ejemplo de 5.2: muere una Rodauva → la otra Rodauva y el Surcón −4, la Ocarra −2; (9) acumulador: 9, +2 y −2 da 9, no 8; y 1 con −4 da 0, no −3; (10) la muerta no recibe lealtad y una guardada no pierde. Cierra P-001. **Decisión técnica de la sesión 2:** el acumulador de lealtad es general, no del combate (5.2 lo usa también para la noche y el rescate): vive en `nucleo/unidades/`, anota (criatura, cambio, motivo) con los nombres de evento de `tablas/lealtad.json`, y al aplicarse suma por criatura, recorta una vez y devuelve antes / cambio / después. El cierre vive en `nucleo/combate/`, se ejecuta una sola vez y rechaza un combate `EN_CURSO` |
| T11 | ✅ **Terminada** (04/10/2026). IA de las salvajes en `nucleo/combate/ia/`, **sin azar** y **sin tocar `Turno`**: para la unidad del turno, devuelve la **lista de `Accion`** que va a jugar (las mismas del jugador, T08), y quien llama las aplica una por una con `Turno`. La atacante nocturna usa la misma IA (`Sistema.md` 9.2, punto 3). **Orden de 11.8, un paso por función:** (1) huida y (2) Encono: **lugares vacíos** (T25 y T19/T20), que hoy siguen de largo; (3) **Erizarse**: si la especie tiene el rasgo (por efecto, no por `id`), la vida es ≤ al umbral y hay una enemiga **adyacente**, se eriza **sin moverse** y termina; el umbral (50%) es dato, en la ficha junto al rasgo, comparado en enteros; (4) **remate**; (5) **cercana**; (6) **acercarse**, y después `terminar`. **"Puede tumbar" y "puede alcanzar" miran el turno completo** (moverse y atacar, S-8): para cada casilla a la que llega (incluida la suya) y cada objetivo que golpea desde ahí. **El daño de esa previsualización sale del mismo camino que el ataque real** (la misma función que usa `Turno` para atacar, con los mismos aportes): cuando T15 y T16 sumen afinidad y aportes, la IA los ve sin cambios. Si hace falta, `Turno` o `Danio` ganan una consulta "daño desde esta casilla contra esta objetivo" sin modificar nada. **Desempates** (11.8 y S-19): remate → menos vida actual → más cercana → antes en la cola; cercana → más cercana → menos vida → antes en la cola; acercarse → la objetivo más cercana (→ menos vida → antes en la cola), y la casilla alcanzable más cercana a ella → orden de lectura (y menor, después x menor); si ninguna casilla la acerca, no se mueve. **Casilla para golpear:** si ya alcanza desde donde está, no se mueve → la de Alcance 2 prefiere la distancia 2 → la de menos pasos → orden de lectura. "Más cercana" es la distancia Manhattan desde la posición actual de la salvaje. **Reglas fijas:** nadie apunta a una caída ni a una unidad fuera del tablero; las salvajes no Secundan; la regla de la acobardada es de T19/T20. **Una consulta para depurar:** junto con las acciones, la IA devuelve qué paso decidió y por qué (paso, objetivo, casilla), sin textos para el jugador | K-07, `Sistema.md` 9.2 (punto 3), 10.7, 11.8 | Tests (fixtures): (1) remate: entre dos objetivos que puede tumbar, va por la de menos vida, aunque otra esté más cerca; (2) remate moviéndose: la Ocarra salvaje no alcanza desde su casilla, pero moviéndose tumba a la Rodauva y lo hace; (3) remate al Maestro: si puede tumbarlo, lo tumba y el combate termina; (4) cercana: sin remate posible, ataca a la más cercana; empatadas en distancia, a la de menos vida; empatadas en las dos, a la que actúa antes en la cola; (5) casilla: si ya alcanza no se mueve; la Ocarra que puede golpear desde 1 o desde 2 moviéndose elige 2 solo si no alcanzaba desde su casilla; entre casillas iguales, la de menos pasos y después el orden de lectura; (6) acercarse: sin nadie al alcance, termina en la casilla alcanzable más cercana a la objetivo, con el orden de lectura como último desempate; (7) Erizarse: la Rodauva salvaje con vida ≤ 50% y una enemiga adyacente se eriza y no se mueve; con vida > 50%, o sin enemiga adyacente, sigue la lista; con exactamente 4 de 8, se eriza; (8) una especie sin el rasgo, con poca vida y una enemiga adyacente, no se eriza; (9) nadie apunta a una caída aunque pudiera tumbarla; (10) el Tasajero recorre la lista en Caza y otra vez en Cuenta, con el estado del tablero de ese momento; (11) previsualizar y decidir no cambian el `Plantel` ni gastan Hacerse junco; misma situación, mismas acciones; no usa el generador de azar; (12) escenario A con fixture: la Ocarra va por la Rodauva (P-009) | 
| T12 | ✅ **Terminada** (04/10/2026, dos sesiones; la exclusión de `escenarios/` de la huella se hizo después, en `tarea/T12-ajustes`, A.7). Contrato del combate (A.7) en `nucleo/combate/`, con la huella en `nucleo/datos/` y una herramienta en `herramientas/`. **Dos sesiones.** Al empezar: pasa a `CERRADA` las P-011 a P-018 y P-020 a P-022 (`Sistema.md` v1.2 confirmó lo programado; sin cambios de código). **Sesión 1 — contexto, bucle y registro.** `ContextoCombate` se arma desde un escenario (diccionario) y los datos cargados (T03): tipo, semilla, tablero, `Plantel`, `golpe_inicial`, toggles, los generadores de combate y de textos derivados de la semilla (T02, A.8) y las reglas ya creadas (`Danio`, `Cierre`, `Relaciones`). **`Danio.desde_datos` exige la tabla de hambre** (deuda de T09): sin ella falla, sin valor por defecto, y los tests que la omitían pasan el fixture. Un escenario en el que el Maestro, una suelta de la tribu o una enemiga traen `posicion: null` se rechaza con el motivo `DESPLIEGUE_NO_IMPLEMENTADO` (el despliegue manual no es de 0a, A-1); una guardada con `null` es válida porque no ocupa casilla (P-023). `Combate` es el bucle: dueño de la cola (T07) y del turno actual (T08). **Antes de la ronda 1**, en este orden: punto vacío del golpe inicial (T30; en T12 el campo se lee y no se resuelve); toda unidad con vida 0 se resuelve con `VidaCero`, en el orden del `Plantel`; se evalúa `FinCombate` (base de S-10). Después arma la ronda, juega solo los turnos de las enemigas (`IASalvaje`, también la atacante nocturna) y **se detiene** en el primer turno del jugador (Maestro y tribu). API para la pantalla y el reproductor: `esperando_jugador()`, `turno_actual()` (con las consultas de T08), `aplicar(accion)` (solo en turno del jugador; mover y atacar no cierran el turno; `terminar` lo cierra y el bucle sigue hasta el próximo turno del jugador o el fin), `terminado()`, `resultado()`. **El bucle se corta con `FinCombate`, no con la cola**: si la IA tumba al Maestro, no se juega ninguna entrada más. Al terminar, el `Cierre` (T10) corre una vez, solo. Una acción de la IA inválida es un error de programación: el combate se detiene con error, nunca la ignora. Una acción del jugador inválida no cambia nada y no se registra ni se graba. `Accion` pasa a diccionario y vuelve, con ida y vuelta exacta. **Registro** (`RegistroCombate`) con el formato de A.7. **Sesión 2 — resultado, grabación y reproductor.** `ResultadoCombate` sale del `Plantel` y del `ResultadoCierre`, y su diccionario valida contra `resultado.schema.json`. El esquema se revisa: estados `fuera` y `muerta`; los campos de tareas futuras (rescatista, permadeath, capturas, métricas) van en `null` o lista vacía, con `_nota` que dice qué tarea los llena. Lleva desenlace, rondas, `maestro_caido`, estado final de cada unidad (`id`, estado, vida, lealtad, posición), levantadas, muertas, pergaminos ardidos, cambios de lealtad (antes, cambio, después y anotaciones con motivo) y `atacante_pendiente` (`id` de la atacante nocturna caída, o `null`). **P-019:** el motivo es la clave de `tablas/lealtad.json` `eventos`. El +1 de victoria pasa de `combate.json` `lealtad_por_victoria` a `lealtad.json` `eventos.victoria`: esquemas, datos, fixtures y `Cierre` en el mismo PR, con la tabla de cotejo de A.2.2. El `enum` del motivo lista esas claves y un test compara las dos listas. `HuellaDatos`, `Grabacion` (esquema nuevo `grabacion.schema.json`) y `Reproductor.reproducir(grabacion, datos, hasta_n)` según A.7. `instantanea()` en `Plantel` y `Combate` (ronda, lugar en la cola y, por unidad: estado, vida, lealtad, posición, `erizada`, `ya_ataco`, pergamino) para comparar estados. **Herramienta:** `herramientas/reproducir.gd`, por consola: reproduce un archivo de grabación y escribe el registro en `registros/` como `.jsonl`. El comando va en `CLAUDE.md`. **No incluye:** el golpe inicial (T30), las métricas (T23 y T33, desde el registro), guardar la grabación desde la pantalla (T13) ni el archivo de guardado de suspensión (0b) | B-04, A.6, A.7, A.8, P-019, `Sistema.md` 5.2, 9.2, 11.5 | Tests (con fixtures, salvo el 9). **Sesión 1:** (1) el contexto lee semilla, tablero, plantel, golpe inicial y toggles; dos contextos del mismo escenario dan los mismos generadores; `Danio` sin tabla de hambre falla; (2) Prueba A: al empezar, la Ocarra juega sola y el combate se detiene en el turno de la Rodauva; (3) una acción inválida del jugador, o una fuera de su turno, no cambia la `instantanea`, el registro ni la grabación; (4) jugado con acciones de prueba hasta la victoria, el cierre corre una vez, el resultado está disponible y toda acción siguiente se rechaza con `COMBATE_TERMINADO`; (5) la IA tumba al Maestro a mitad de ronda: derrota en el acto, sin ninguna entrada más; (6) al armar: tribu en 0 → caída antes de la ronda 1; Maestro en 0 → derrota con 0 rondas y ningún turno; todas las enemigas en 0 → victoria sin rondas; (7) registro de una ronda de C: orden de los eventos, Tasajero con `caza` y `cuenta`, `fin_turno` con la posición, sin `float`; (8) el mismo contexto con las mismas acciones, dos veces, da registros idénticos línea por línea; (9) con `datos/` real, los 11 escenarios arman su combate y llegan al primer turno del jugador sin errores, y el Maestro o una enemiga con `posicion: null` se rechazan con su motivo y una guardada con `null`, no; (10) los 159 tests anteriores pasan (los que omitían la tabla de hambre, con el fixture). **Sesión 2:** (11) los resultados de victoria (con una caída levantada y una guardada) y de derrota (con muertas) validan contra el esquema con el validador de T03; con la atacante nocturna caída, `atacante_pendiente` es su `id`; (12) P-019: cada motivo es una clave de `eventos`, el +1 sale de `lealtad.json` y el test permanente de datos pasa; (13) la grabación valida contra su esquema y trae el escenario entero, la huella y las acciones con su unidad; (14) reproducir da un registro idéntico al del combate en vivo; (15) reproducir hasta N = 0, 1, una del medio y la última da la misma `instantanea` y el mismo registro (hasta ahí) que jugar en vivo; (16) cambiar un número de un fixture cambia la huella y cambiar solo una `_nota` o un texto no; con otra huella, el reproductor avisa y llega al mismo final; (17) una grabación con una acción imposible se detiene con error en esa acción; (18) `Accion` ida y vuelta por diccionario. Cierra P-019 |
| T34 | ✅ **Terminada** (04/10/2026). Armador de textos en `nucleo/textos/`, sin nodos (A.2.1, `Mundo.md` 1.5). **Una sesión.** `ArmadorTextos.desde_datos(textos, generador)` recibe el diccionario de `textos/es.json` (con la forma del `Cargador`) y **el generador de textos** (`ContextoCombate.azar_textos`; nunca el de combate). **Pedido:** `armar(clave, datos, sujeto = "")` devuelve el texto final; `armar_lineas(...)` devuelve la lista de líneas (base y complementos) para que la pantalla decida cómo mostrarlas; `armar` las une con un salto de línea. **Huecos:** `datos` es un diccionario `nombre → valor`. Un valor **criatura** (un objeto propio, `HuecoCriatura`, con el `id` de especie) llena las seis formas de su rol: `{rol}`, `{a_rol}`, `{de_rol}`, `{rol_o}`, `{rol_la}`, `{rol_ella}`, armadas una sola vez por especie desde sus claves de texto (artículo y nombre; Claude Code confirma en el plan los nombres exactos de esas claves en `es.json`). Contracciones: `a` + `el` = `al`, `de` + `el` = `del`. Cualquier otro valor (texto o entero) es literal (`{porcentaje}`, `{dia}`). Los roles son siempre criaturas: el Maestro como protagonista se resuelve con las claves `.maestro`. **Variantes por condición:** con `sujeto` (`id` de especie o `maestro`) se busca `<clave>.<sujeto>` y, si existe, **reemplaza** a la base. **Complementos:** para las claves que empiezan con un prefijo de la lista constante del armador (`caida.`, `nocturno.base.`, `nocturno.raso.`), la base se muestra siempre y la variante del sujeto, si existe, va **después**, como otra línea. **Variantes al azar:** si el valor de la clave es una lista, se elige una con el generador de textos; un texto suelto **no** consume tirada. **Mayúsculas:** la primera letra del texto y la primera letra después de `. ? ! ¿ ¡` (salteando espacios, saltos de línea y signos de apertura) van en mayúscula, también con tilde; el resto no se toca. **Lo que falta no rompe:** clave inexistente → `[FALTA: clave]`; hueco sin dato → `[FALTA: hueco]`; los dos dejan un aviso. `avisos()` devuelve los avisos de los pedidos (clave, hueco, motivo); nada de `push_error`. **Revisión estática** (pasa de T03 a T34, A.2.1): `revisar(textos)` recorre todo el archivo y avisa de huecos mal formados (mayúsculas o espacios dentro de las llaves, llave sin cerrar, `[Criatura]` sin convertir). Al terminar, Claude Code corre `revisar` sobre `datos/textos/es.json` y, si hay avisos, los anota en `PREGUNTAS.md` para el Worldbuilder (no es un fallo de test: el contenido es suyo). Los textos de varios párrafos usan `\n\n` dentro de un solo texto y no se tocan. **No incluye:** `{duracion}` con `tiempo.dia` / `tiempo.dias` (0b; queda el lugar), elegir qué clave corresponde a cada situación (lo hace quien llama: T13 y siguientes), la lista de claves usadas (T13), editar `datos/textos/` | A.2.1, A.8 (azar), `Mundo.md` 1.5 | Tests con un fixture `pruebas/fixtures/textos/es.json` que valida con el esquema `textos` (nunca `datos/`): (1) `¿{criatura}?` con la Rodauva → "¿La Rodauva?"; (2) con el Surcón: `{a_rival}` → "al Surcón", `{de_rival}` → "del Surcón", `flac{criatura_o}` → "flaco", `{criatura_la}` → "lo", `{criatura_ella}` → "él"; con la Rodauva: "a la Rodauva", "de la Rodauva", "flaca", "la", "ella"; (3) mayúscula después de `. ` y de `¡`, y con tilde ("él" al empezar → "Él"); lo demás queda igual; (4) `<clave>.maestro` y `<clave>.<especie>` reemplazan a la base; sin variante, la base; (5) `caida.*` con variante del sujeto: base y variante en dos líneas; sin variante, solo la base; (6) clave faltante → `[FALTA: clave]` y un aviso; hueco sin dato → `[FALTA: hueco]` y un aviso; (7) lista de variantes: misma semilla → misma secuencia de elecciones; otra semilla → otra; (8) un texto suelto no consume tirada: pedirlo o no antes de una lista no cambia la elección de la lista; (9) `revisar` avisa de `{Criatura}`, `[Criatura]` y `{criatura` sin cerrar, y no avisa de un texto correcto; (10) literal: `{porcentaje}%` con 40 → "40%"; (11) armar textos con el generador de textos durante un combate no cambia su registro ni su `instantanea` |
| T13 | Pantalla cenital con placeholders en `pantalla/`: la **primera tarea con nodos**. **Dos sesiones.** **Regla de la tarea:** la pantalla no calcula ninguna regla. Lee `Combate` (las consultas de T08, `previsualizar_ataque`, `instantanea`, `registro`, `resultado`) y le manda `Accion`. Después de cada cambio **se redibuja desde el núcleo**: nunca guarda una copia propia del estado de reglas. Todo texto que ve el jugador sale de `ArmadorTextos` (T34) con el generador de textos del contexto. Si una clave falta, se ve `[FALTA: clave]` y la clave va al resumen; Claude Code no inventa textos. Las pantallas de desarrollo (selector de escenario, panel de depuración, pantalla de error) pueden mostrar ids y datos técnicos sin clave de texto. **Sesión 1 — arranque, tablero y lectura.** Escena principal `pantalla/principal.tscn`: carga los datos con el `Cargador`. La carpeta sale de un parámetro: por defecto `res://datos`, y por línea de comandos `-- --datos=<carpeta>` para pruebas. Le pasa al cargador la lista de claves de texto que usa la pantalla, armada en `pantalla/claves_textos.gd` (constantes más las que se arman por especie). **Con un error de datos, el juego no arranca:** muestra una pantalla con archivo, campo y valor esperado de cada error, y nada más. Los avisos (claves faltantes o sobrantes, avisos del armador) van a la consola y al panel de depuración, sin bloquear. Selector de escenario: los archivos de `escenarios/`, por `id`. Vista de combate `pantalla/combate/vista_combate.tscn`. El tablero es un `TileMapLayer` con un tileset placeholder de casillas cuadradas. **Toda conversión casilla ↔ pantalla usa `map_to_local` y `local_to_map`** (A.3): ningún cálculo de píxeles a mano, para que T32 cambie solo el tileset. Las unidades son nodos hijos: figura simple, color por bando, nombre de la especie armado por T34, vida en números, y marcas de caída, erizada y Maestro. Además: cola de iniciativa de la ronda (con Caza y Cuenta y la entrada actual), ronda actual y panel de la unidad del turno (vida, lealtad, hambre). Panel de depuración, oculto por defecto: registro crudo y avisos. La sesión 1 termina con el escenario dibujado, la IA ya jugada hasta el primer turno del jugador y sin interacción de juego. **Sesión 2 — jugar.** `pantalla/combate/interprete_clic.gd` (`RefCounted`, sin nodos, con tests): recibe el turno actual y la casilla clicada y devuelve la `Accion` que corresponde. Casilla alcanzable → `mover`; casilla con una objetivo atacable → `atacar`; cualquier otra → nada. Usa las consultas de T08, nunca reglas propias. Botones: Erizarse (solo si `puede_erizarse`) y Esperar / Terminar turno (`terminar`). **Previsualizaciones:** en el turno del jugador se marcan `casillas_para_mover` y `objetivos_para_atacar`. Con el mouse sobre una objetivo, se muestra el desglose de `previsualizar_ataque`: Daño base, cada modificador con su fuente, total, y si actuó el mínimo. Los turnos de la IA ya los jugó el núcleo: la pantalla muestra lo nuevo del registro, sin animaciones. **Fin:** pantalla de resultado básica desde `ResultadoCombate.a_diccionario()`: desenlace, rondas, estado final de cada unidad y cambios de lealtad con su motivo, sin reglas en la pantalla (A.7). Al terminar, se guardan solos la grabación (`.json`) y el registro (`.jsonl`) en `registros/`, con el nombre `<escenario>_<semilla>_<n>`; la herramienta de T12 los reproduce. **Recarga:** una tecla vuelve a leer los datos del disco (con un error, muestra la pantalla de error) y reinicia el escenario actual, así un cambio de balance se prueba sin cerrar el juego. Las teclas son acciones del `InputMap` del proyecto (`recargar`, `depuracion`), no teclas escritas en el código. **No incluye:** animaciones, arte, sonido, vista isométrica (T32), panel de parámetros (T31), hechizos, sellar, guardar, invocar ni huir (no existen todavía), métricas (T23, T33) ni pantalla de rescate (T29) | Brief 4, A.2, A.2.1, A.3, A.6, A.7, T12, T34 | Tests en `pruebas/pantalla/`, con el runner de escenas de GdUnit4 para lo que tiene nodos. **Sesión 1:** (1) con un fixture de datos roto, la escena principal muestra la pantalla de error con archivo y campo, y no muestra el selector; (2) con `datos/` real arranca sin errores y lista los 11 escenarios; (3) la vista de cada uno de los 11 escenarios se crea sin errores y queda esperando al jugador; (4) cada unidad está en `map_to_local` de su casilla, y `local_to_map` de su posición da la casilla; (5) la lista de claves usadas llega al cargador: una clave que falta en un fixture de textos aparece como aviso; (6) la cola que se muestra coincide, entrada por entrada, con la de `ColaIniciativa`. **Sesión 2:** (7) intérprete: un clic en una casilla alcanzable da `mover`; en una objetivo atacable, `atacar`; en una aliada, una casilla no alcanzable o fuera del tablero, nada; con el movimiento gastado, una casilla vacía da nada; (8) el desglose que se muestra con el mouse sobre una objetivo es igual al del evento `ataque` del registro cuando se golpea; (9) jugar A hasta el final mandando acciones por la vista guarda la grabación y el registro, y reproducir esa grabación con `Reproductor` da el mismo registro; (10) recargar con un número cambiado en una copia de fixtures reinicia con el número nuevo, y con un dato roto muestra la pantalla de error. **Prueba manual del usuario** (lista en el resumen de la sesión 2): A y B jugados con el mouse de punta a punta, con al menos una victoria y una derrota; la Rodauva de la tribu se eriza en B; la recarga funciona; la grabación guardada se reproduce por consola |

**Hito terminado cuando:** A y B se juegan completos con el mouse, todos los tests pasan y una partida grabada desde la pantalla se reproduce igual por consola. Lo comprueba el usuario con la lista manual de T13; después mergea `develop` a `main` con la etiqueta `0a.1`.

### B.3 Hito 0a.2 — "La tribu se ve"

Obediencia, maná, afinidad, combos, Secundar, incidentes, Encono, cobardía y hechizos.

| ID | Tarea | Requisitos | Terminada cuando… |
|---|---|---|---|
| T14 | Obediencia en vivo, hambre de combate (+1 al cerrar las rondas 5, 10… al Maestro y a toda la tribu en el tablero, **de pie o caída**; no a las guardadas, salvajes ni atacante) y Arrimo derivado de la balanza. Los tramos de obediencia usan los cortes de `tablas/lealtad.json` (piso de Neutral y umbral de rescate); se quita `obediencia.baja.hasta` de `tablas/combate.json` y de su esquema (P-003) | C-03, C-04, `Sistema.md` 5.4, 7.2 | Tests de `Sistema.md` 5.4 y del recálculo en el acto; una caída suma hambre y una caída guardada no; si se cambia el piso de Neutral en `lealtad.json`, cambia el tramo de obediencia. Cierra P-003 |
| T15 | Afinidad por adyacencia (+1 como máximo; el Maestro es afín de las leales). **Solo dentro del mismo bando**: también entre salvajes afines. Las caídas no dan ni reciben | Brief regla 7, `Sistema.md` 10.7, 11.5 | Tests con varias afines adyacentes; Rodauva de la tribu junto a Rodauva salvaje no suma; dos Rodauvas salvajes pegan 3 |
| T16 | Cadenas: registro de objetivo, eslabón e instancias participantes; bonos; reglas de corte. Las salvajes **no encadenan**, pero sus turnos cortan las cadenas de la tribu | K-02, F-02 (enchufe), `Sistema.md` 10.7 | Tests de la Prueba A, de cada corte de la regla 6 del Brief y de dos salvajes seguidas sin bono |
| T17 | Secundar: inserción en la cola y previsualización | K-01 | Tests; la cola muestra el lugar resultante antes de confirmar |
| T18 | Incidentes con rival aliada, con % en la casilla destino antes de mover. Las caídas no provocan ni sufren incidentes | Brief regla 10, `Sistema.md` 11.5 | Tests de los dos resultados según la obediencia y con una rival caída al lado (0%) |
| T19 | Chequeo único de rival enemiga → Encono (contador 0–3) o cobardía (con el toggle de afines), con % al inicio del turno. El Tasajero chequea al inicio de **cada uno de sus dos turnos**, con un **contador único**. **Todo golpe a la rival suma Encono**; el bono rige **solo enconada** y usa el valor **después** de sumar. Una caída no cuenta como rival a su alcance | K-06, `Sistema.md` 10.5, 11.5 | Tests de las dos ramas; escenario E con y sin toggle; Ocarra enconada (daño 4) pega 5 / 6 / 7 / 7; golpe voluntario sube el contador sin bono; Tasajero con dos chequeos por ronda y un solo contador; con el toggle, el Maestro adyacente resta solo su −10 propio, no cuenta como afín (P-008: Rodauva leal con solo el Maestro al lado, balanza 2 → 15%). Cierra P-008 |
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
| T29 | Rescate: rescatista según lealtad real, desempates del Brief (también las que iban a huir con el Maestro), caídas que quedan atrás; pantalla de resultado completa; "quién puede rescatar ahora" visible | C-04 | Escenario F jugable; tests de desempate; ejemplo de 5.2: una rescatista con 9 que pierde 2 por una caída que muere queda en 9 |
| T30 | Escenario G: golpe inicial desde el campo `golpe_inicial` (A.7), atacante con lógica de salvaje que no huye, caída en 0 y tres salidas (perdonar, sellar, comer); texto `nocturno.comer.zancajunco_suelto` | P-02, K-09, `Sistema.md` 9.2, `Mundo.md` 4.6 | G jugable con sus tres salidas; con la Ocarra atacante, el primer evento del registro es un golpe de 4 al Maestro, sin combo ni Encono; con `golpe_inicial: null`, no hay golpe; comerla da −2 en total a todas las sueltas, **incluidas sus afines**, sin el −3 extra (P-002, `Sistema.md` 5.2). Cierra P-002 |
| T31 | Panel de parámetros dentro del juego, con toggles y semilla | B-04 | Se edita un escenario sin tocar el JSON; D se juega con balanza 4 desde el panel y se borra `d_rivales_balanza4.json` |
| T32 | Vista isométrica y lectura de la adyacencia | A.3 | Los 8 escenarios se juegan en isométrica |
| T33 | Métricas completas y exportación por combate. Si el Director aprueba la encuesta de E y F, una pantalla de 2 o 3 preguntas exportada junto con las métricas. Los umbrales de alarma de `Sistema.md` 11.9 (ya en números) se cargan como dato y la exportación marca las alarmas | B-05, `Sistema.md` 11.9, Visión v1.0 (10, 11) | Las **13 métricas de `Sistema.md` 11.9** se exportan en cada combate |

**0a terminada cuando:** los 8 escenarios se juegan en isométrica, con todas las previsualizaciones y las métricas exportadas. Ahí empiezan los playtests de criterios de éxito.

### B.5 Hitos de 0b — `DECIDIDO` (validados por el Director, Visión v1.0, 03/10/2026)

Se construyen en este orden. Las **tareas detalladas se escriben después de los playtests de 0a**, porque esos tests pueden cambiar reglas.

| Hito | Contenido | Requisitos | Terminado cuando… |
|---|---|---|---|
| 0b.1 "Un día" | Partida y guardado, inventario, mapa del día de los Huertos, eventos de nodo, combate enchufado por el contrato, reparto de comida, cierre del día en el Molino | G-01, I-01, W-02, N-01, N-03, C-03, C-05, W-07 | Un día completo, del Molino al Molino, con un combate de nodo |
| 0b.2 "El valle" | Los 3 destinos, viaje, agotamiento y pudrición, Enfermo completo, ritual, camino de confianza, Tasajero y su hostilidad, río | C-07, M-05, I-02 a I-04, W-03 a W-06, W-08 | Una vuelta al Robledal con ritual |
| 0b.3 "La noche" | Abandono y ataque nocturno (enchufa el escenario G), campamento al raso, guardias, emboscadas, recuperación, quebranto y Poza Tibia. Ataque nocturno (`Sistema.md` 9.2 v1.1): defienden **solo** las sueltas con lealtad real ≥ umbral, medidas una vez después del golpe inicial; las que miran no están en el tablero, no suman +1 ni rescatan, pero sí sufren los eventos de 5.2; Centinela con cualquier lealtad; golpe inicial letal termina el combate antes de la ronda 1. Variante de escenario `g_sin_leales` (Rodauva y Zancajunco en 5, misma semilla que G) | N-02, M-03, M-06, M-07, M-09, W-05 | Caer, ser rescatado y curarse en la Poza |
| 0b.4 "30 días" | Experiencia y nivel, plazo, epílogo y métricas de partida | C-06, M-02, M-08, G-02, G-03 | Una partida entera hasta el epílogo |

---

## 0. Bloqueantes de la primera sesión — resueltos

| ID | Pedido | Origen | Nota |
|---|---|---|---|
| B-01 | Motor y plataforma objetivo, teniendo en cuenta que se desarrolla con Claude Code y con poca experiencia previa | D16, D18 | **Resuelto** → A.1 |
| B-02 | Alcance técnico de 0a y validación de los hitos 0a.1, 0a.2 y 0a.3 | D16, D18 | **Resuelto** → B |
| B-03 | ¿0a puede usar vista cenital y postergar la isométrica? | D18 | **Resuelto** → A.3 |
| B-04 | Escenarios de 0a como datos: unidades, posiciones, lealtad y hambre fijas | D18 | **Resuelto** → A.2 y A.7. Tareas T12 y T31 |
| B-05 | Registro de las métricas de los criterios de éxito (por ejemplo, % de rondas con el Maestro en primera fila) | D18 | **Resuelto** → A.7: el registro existe desde T12 y las métricas salen de él. Se calculan en T23 y T33 |

El Brief agrega dos preguntas que no están en `Decisiones.md`: el **formato de las tablas de datos y del archivo de escenario** (`DECIDIDO` en A.2) y **cuánto cuesta cada previsualización obligatoria**: ninguna es cara si el núcleo ofrece "calcular sin aplicar" (ver A.6). No hace falta recortar ninguna.

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
| K-07 | IA de salvajes que respete los incidentes y el Encono | 0a | D06 | Orden de `Sistema.md` 11.8: huida → Encono → Erizarse → remate → cercana → acercarse, con sus desempates deterministas |
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

### 10.5 Dudas para otras áreas — actualizado 04/10/2026

Las `P-0XX` son de Claude Code y viven en `docs/PREGUNTAS.md`: el usuario pega la respuesta (`RESPONDIDA`) y Claude Code la pasa a `CERRADA` en la tarea que la aplica.

**Resueltas por `Sistema.md` v1.1 (03/10/2026):**

| # | Duda | Respuesta | Se cierra en |
|---|---|---|---|
| P-010 | T05: el criterio (2) pedía pergaminos distintos para dos Ocarras salvajes | Error del criterio: las salvajes no tienen pergamino (3.2). Test (8) con las dos Rodauvas de E | T05 ✅ |
| S-7 a S-9 | IA: empates de objetivo, "puede tumbar" con movimiento, casilla | 11.8 | T11 ✅ |
| S-10 | Golpe inicial nocturno que deja al Maestro en 0 | El combate termina por caída antes de la ronda 1 (9.2). Lugar preparado en T12 | 0b.3 |
| S-11 | Umbrales de alarma en números | En 11.9, aprobados por el Director | T33 |
| S-12 | Ataque nocturno: ¿qué hace una suelta no leal? | Mira: no entra al tablero (9.2) | 0b.3 |
| P-001 | "Afines" en la muerte en el grupo | Relación de especie, suelta por suelta; suma y recorte únicos (5.2) | T10 ✅ |
| P-002 | Comer a la atacante: ¿sus afines −2 o −4? | −2 en total a todas (5.2) | T30 |
| P-003 | Tramos de obediencia contra estados de lealtad | Mismos cortes; cada número en un solo dato (5.4) | T14 |
| P-004 a P-007 | Valores de los escenarios | 11.9 | T05 ✅ |
| P-008 | Toggle de afines: ¿el Maestro cuenta como afín? | No: solo su −10 propio (10.6) | T19 |
| P-009 | Objetivo de la Ocarra en A y B | Manda la IA de 11.8 (11.6) | T05 ✅ |

**Resueltas por `Sistema.md` v1.2 (04/10/2026)** — todas con la lectura ya programada; Claude Code las cierra al empezar T12, sin cambios de código:

| # | Duda | Respuesta |
|---|---|---|
| S-13 = P-018 | ¿Una caída enemiga bloquea el paso y la línea de Alcance 2? | Sí, como de pie; por una caída propia se pasa (11.3) |
| S-14 = P-011 | Empate de Velocidad entre enemigas | Orden de la lista `enemigas`; en 0b, la columna Composición de 11.6 (11.3) |
| P-012 | Unidad que deja de poder actuar a mitad de ronda | Pierde todas sus entradas restantes, incluida la Cuenta del Tasajero (11.3) |
| P-013 | Velocidad del Maestro | Siempre la de `maestro.json` en 0a, y entra en todas las rondas (11.2) |
| S-15 = P-014 | Moverse después de erizarse | No: erizarse cierra el movimiento que quede (11.2, 11.3) |
| S-16 = P-015 | Terminar sin acción | Es esperar y no corta la cadena (10.2, 11.3) |
| S-17 = P-016 | Saciado y enfermedades de las enemigas | No: son solo del Maestro y la tribu (8.2, 9.2, 11.4) |
| S-18 = P-017 | Recorte entre porcentajes y planos | No hay: el único recorte es el mínimo final (11.4) |
| S-19 = P-020 | Objetivo sin remate | Con remate: menos vida → cercana → cola. Sin remate: cercana → menos vida → cola (11.8) |
| P-021 | "Antes en la cola" | El orden de la ronda entera, haya actuado o no (11.8) |
| P-022 | Caída adyacente y Erizarse | Solo cuenta una enemiga de pie (11.8) |

**Resuelta por el Arquitecto (04/10/2026):** P-019 — el motivo de lealtad del resultado es la clave de `tablas/lealtad.json` `eventos`, y el +1 de victoria pasa de `combate.json` a `eventos.victoria` (A.2.2 ya lo ubicaba ahí) → T12, sesión 2.

**P-023** (`docs/PREGUNTAS.md`, para el Arquitecto, 04/10/2026) — **respondida: opción A.** `DESPLIEGUE_NO_IMPLEMENTADO` alcanza solo a las unidades que van al tablero: el Maestro, las sueltas de la tribu y las enemigas. Una guardada con `posicion: null` es válida (no ocupa casilla, A.2 y T06). La redacción de T12 era imprecisa; se corrigió en B.2. Ya programado así: no cambia código ni tests. Se cierra en T12, sesión 2.

**Abiertas** — `PREGUNTA ABIERTA`:

| # | Para | Duda | Antes de |
|---|---|---|---|
| S-20 = P-024 | Sistemas | `Sistema.md` 9.3 y 11.5: si un combate nocturno termina en **derrota** (cae el Maestro) con la atacante ya caída, ¿su destino queda pendiente (perdonar, sellar o comer, después del rescate) o sigue otra regla (huye, queda libre, muere)? En 0a no pasa: en G es la única enemiga, y si cae se gana. Lectura literal, programada en T12: queda pendiente con cualquier desenlace; si Sistemas da otra regla, cambia una condición de `ResultadoCombate` y un test | T30 (no bloquea) |
| D-1 | Director | ¿Los playtests de E y F incluyen una encuesta corta al final? (Visión 11) | T33 |
| A-1 | Arquitecto | El despliegue manual (`posicion: null`, A.2) no tiene tarea. No hace falta en 0a: los 11 escenarios usan posiciones fijas y T12 rechaza `null`. Se ubica al detallar los encuentros generados de 0b (B.5) | Hito de 0b con encuentros generados |

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
| Huecos gramaticales y mayúsculas automáticas (`Mundo.md` 1.5) → A.2.1, T34. Textos entregados (493 claves) y en el repositorio desde T04 | 0a |
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
| v0.21 | 04/10/2026 | Revisión de coherencia, sin decisiones nuevas: sección 0 marcada como resuelta (B-05 → A.7); el test permanente acepta claves de texto sobrantes en todo 0a (son textos de 0b); la deuda de T09 figura como saldada; el ajuste de la huella figura como hecho en `tarea/T12-ajustes` y no "antes del merge" |
| v0.20 | 04/10/2026 | **T34 terminada** y ajuste de T12 hecho (A.10, B.2). **T13 detallada en dos sesiones**: arranque bloqueado con datos rotos, carpeta de datos por parámetro, claves usadas, selector de escenario, tablero con `TileMapLayer` y conversión solo con `map_to_local` / `local_to_map`, redibujo desde el núcleo, intérprete de clics sin nodos, previsualizaciones, resultado básico, grabación y registro guardados al terminar, recarga desde el disco y prueba manual del usuario. A.6 suma el nivel Pantalla. Cierre del hito 0a.1 en B.2. S-20 registrada como P-024. `CLAUDE.md` v0.20 con la sección Pantalla |
| v0.19 | 04/10/2026 | **T12 terminada** (A.10, B.2). Corrección de A.7: la huella también excluye `escenarios/` (la grabación lleva su escenario entero); se hace en la rama de T12 antes del merge. **T34 detallada**: huecos de criatura con contracciones, variantes que reemplazan y complementos en líneas separadas, elección al azar solo para listas, mayúsculas, faltantes visibles con aviso y revisión estática de huecos mal formados. Nueva S-20 (destino de la atacante caída en una derrota nocturna), lectura declarada que no bloquea |
| v0.18 | 04/10/2026 | **T12, sesión 1 hecha** (A.10). P-023 respondida (opción A): el rechazo por `posicion: null` alcanza solo a las unidades del tablero; redacción de T12 corregida en B.2. Derivación de generadores por SHA-256 de `"semilla/sistema"` en A.8 (`DECIDIDO`). `instantanea()` y `Accion` ↔ diccionario adelantados a la sesión 1 |
| v0.17 | 04/10/2026 | Sincronización con `Sistema.md` v1.2: S-13 a S-19 y P-011 a P-022 resueltas (10.5 reescrita; solo quedan D-1 y A-1). **T11 terminada** (A.10, B.2). **T12 detallada en dos sesiones**: contexto, bucle que se detiene en el turno del jugador, registro, resultado, grabación, huella y reproductor con acción N. Nuevo formato de registro, grabación y huella en A.7. P-019 pasa del principio de T12 a la **sesión 2**, junto con el esquema del resultado. Nueva A-1: despliegue manual sin tarea |
| v0.16 | 04/10/2026 | **T10 terminada** (A.10). **T11 detallada**: lista de acciones del jugador, un paso por función, previsualización por el mismo camino que el ataque real, desempates, umbral de Erizarse como dato y explicación para depurar. P-019 respondida (A con ajuste: el +1 de victoria pasa a `lealtad.json`, en T12). Nueva S-19 (cercana contra menos vida), lectura declarada que no bloquea |
| v0.15 | 04/10/2026 | **T10, sesión 1 hecha** (A.10). T10: el acumulador de lealtad es general y vive en `nucleo/unidades/`; el cierre corre una sola vez. T12: el bucle se corta con `FinCombate` y las unidades que arrancan en 0 se resuelven al armar el contexto. P-018 registrada como la misma duda que S-13 |
| v0.14 | 04/10/2026 | **T09 terminada** (A.10). **T10 detallada en dos sesiones**: vida en 0 y fin del combate; cierre con muertes, pergaminos y acumulador de lealtad. Estado nuevo `fuera` para la salvaje que sale del tablero. T12 se lleva la deuda de T09 (tabla de hambre obligatoria). A.5: el encabezado de `CLAUDE.md` dice contra qué versión se revisó, y no tiene que seguir cada versión de este documento. Nueva S-18 (= P-017, sin recorte intermedio), lectura declarada que no bloquea |
| v0.13 | 04/10/2026 | **T08 terminada** (A.10), con sus lecturas técnicas. **T09 detallada**: aritmética en enteros con piso explícito, función de porcentajes reutilizable (K-05), fuentes propias y aportes externos, desglose, Hacerse junco que se gasta al aplicar. T10: una unidad en 0 deja de ser objetivo. Nuevas en 10.5: S-16 (= P-015, esperar) y S-17 (sin Saciado ni enfermedades para las enemigas), lecturas declaradas que no bloquean |
| v0.12 | 04/10/2026 | **T07 terminada** (A.10). **T08 detallada**: un turno por entrada de la cola, acciones como datos comunes al jugador y a la IA, validar sin aplicar, movimiento entero, ataque con una sola función de daño que T09 completa, Erizarse hasta el inicio del próximo turno, esperar = terminar, puntos vacíos de inicio y fin del turno. Nueva S-15 (Erizarse y movimiento) y registro de P-012 y P-013 en 10.5. Nuevo **`docs/RESUMENES.md`**: historial de sesiones de programación (A.4, A.5). `CLAUDE.md` alineado con v0.12 |
| v0.11 | 04/10/2026 | **T06 terminada** (A.10), con sus lecturas literales. **T07 detallada**: cola armada al empezar cada ronda, entradas salteadas, invocada en la ronda siguiente, punto de fin de ronda, lista editable para Secundar (T17). El movimiento del Tasajero en cada entrada pasa a T08. Nuevas S-13 (caída enemiga bloquea) y S-14 (empate entre enemigas), lecturas declaradas que no bloquean (10.5) |
| v0.10 | 04/10/2026 | **T05 terminada** (A.10). Criterio (2) de T05 corregido y test (8) agregado (responde P-010, 10.5). **T06 detallada**: consultas puras sobre el `Plantel`, movimiento por camino (BFS), línea con bloqueo reutilizable por T22, despliegue y límites de la tarea |
| v0.9 | 03/10/2026 | Sincronización con `Sistema.md` v1.1, que responde P-001 a P-009, S-8, S-10 y S-12 (10.5 reescrita: solo queda abierta D-1). **T05 detallada** en dos sesiones: `Especie`, `Criatura`, `Maestro`, `Pergamino` y `Plantel`, creación desde escenario, balanza derivada y límites de la tarea. Nuevas convenciones: **referencias entre entidades por `id`** (A.5) y **tests de reglas con fixtures, nunca con `datos/`** (A.6). Ante una contradicción, `Sistema.md` manda sobre el Brief (A.5). Criterios nuevos: T10 (afines por especie, suma y recorte únicos), T14 (cortes de obediencia desde `lealtad.json`; sale `obediencia.baja.hasta`), T19 (Maestro fuera del toggle), T29 (ejemplo 9 + 2 − 2), T30 (comer a la atacante). Valores de escenarios `DECIDIDO` (A.9). 0b.3 suma defensoras y `g_sin_leales` (B.5). K-07 con el orden de 11.8 |
| v0.8 | 03/10/2026 | **T01 a T04 terminadas y mergeadas** (nueva A.10). Nueva A.2.2: reglas de transcripción (cada número en un solo archivo, tablas derivadas, mapa de dónde vive cada número, obediencia de salvajes como tramo). Nueva A.9: los 11 escenarios, escenario G definido y valores provisorios. A.2: esquemas reales en T04, carpeta de datos como parámetro, con un error no se entregan datos; esquemas de salida en T12. A.2.1: claves usadas como parámetro; aviso de huecos desconocidos pasa a T34; textos entregados. A.4: `.claude/settings.json`, `docs/PREGUNTAS.md`, `pruebas/fixtures/`. A.5: rama por tarea con PR, permisos, canal `PREGUNTAS.md`, ciclo de cada tarea, `CLAUDE.md`. A.6: comando de tests con `GODOT_BIN` y test permanente de carga. T11 desbloqueada (S-7 a S-9 resueltas por `Sistema.md` 11.8; S-8 por lectura declarada). S-11 resuelta (umbrales en 11.9). Nueva S-12 y registro en 10.5 de las preguntas P-001 a P-009 de `docs/PREGUNTAS.md` (cinco de ellas encontradas por Claude Code en T04), con la tarea que necesita cada respuesta. Eventos de lealtad en `tablas/lealtad.json` (A.2.2). Posiciones provisorias de los escenarios en A.9. T13 bloquea el arranque con datos rotos; T33 carga los umbrales |
| v0.7 | 03/10/2026 | Sincronización con Visión v1.0, `Sistema.md` v0.9 y `Mundo.md` v1.0. Huecos gramaticales, mayúsculas y resolución de variantes `DECIDIDO` (A.2.1); armador en `nucleo/textos/` (A.4) y nueva **T34** antes de T13. Validador: `type` como lista y diccionarios de claves libres (A.2, T03). Claves `sellar.fallo.erizada` y `nocturno.comer.zancajunco_suelto`. Golpe inicial como campo del contexto (A.7, `DECIDIDO`). Escenarios B a F y H en T04, con variante temporal de D en balanza 4 hasta T31. Mandan las 13 métricas de 11.9 (T23, T33). Tasajero con dos turnos completos y contador único (T07, T19, T20, T25); Erizarse en la IA (T11). B.5 pasa a `DECIDIDO`. G-03 suma "solo guardadas". Nueva 10.5 con dudas S-7 a S-11 y D-1; T11 espera S-7 a S-9 |
| v0.6 | 03/10/2026 | Sincronización con Visión v0.9, `Sistema.md` v0.8 y `Mundo.md` v0.8. 10.4 resuelta (S-1 a S-6) y **T28 desbloqueada**; criterios nuevos en T02, T10, T11, T12, T13, T14, T15, T16, T18, T19, T20, T24, T28, T29 y T30. Nueva A.2.1: textos (`DECIDIDO`). Guardado de suspensión por grabación (A.7, `DECIDIDO`). Generador de azar de textos y partida de prueba en A.8. Flujo de Git y sincronización de `docs/` `DECIDIDO` (A.5). Quebranto reemplaza a malherido; C-07 sin contagio; W-08 y G-03 actualizados. Anexo 11 con los pedidos nuevos de `Mundo.md` 9 |
| v0.5 | 02/10/2026 | Sincronización con Visión v0.8 y `Sistema.md` v0.7. T01 terminada. Esquemas JSON y datos de 0a (A.2, `DECIDIDO`); Saciado derivado del hambre. Nueva A.7: contrato del combate (`DECIDIDO`). Nueva A.8: decisiones técnicas para 0b (`PROPUESTA`). Ajustes de criterio en T02, T03, T04, T05, T12 y T13. Nueva B.5: hitos de 0b (`PROPUESTA`). Nuevos requisitos M-08, M-09, W-07, W-08, G-02 y G-03; cambian C-06, M-06, W-05 y W-06. 10.3 resuelta; nueva 10.4 con 6 dudas para Sistemas. B-02 y B-04 resueltos |
| v0.4 | 01/10/2026 | Flujo de Git en A.5 (`PROPUESTA`): `main` para hitos, `develop` para el trabajo diario; Claude Code sin push |
| v0.3 | 01/10/2026 | A.4, A.5, A.6 y B pasan a `DECIDIDO`. Versiones fijas: Godot 4.7.1-stable y GdUnit4 v6.2.1. Carpetas `docs/` y `addons/` en la estructura. T28 bloqueada por una pregunta a Sistemas. Se escribe `CLAUDE.md` |
| v0.2 | 01/10/2026 | A.2 y A.3 pasan a `DECIDIDO`. Nuevas A.4 (estructura), A.5 (convenciones) y A.6 (testing) en `PROPUESTA`. Nueva sección B: validación de los hitos y plan de 0a en 33 tareas (`PROPUESTA`). B-03 resuelto; respuesta al costo de las previsualizaciones |
| v0.1 | 01/10/2026 | Nueva sección A: motor Godot 4.7 con GDScript tipado y plataforma solo PC (`DECIDIDO`); núcleo de reglas separado de la pantalla; formato JSON con validación y ejemplo de escenario (`PROPUESTA`); vista cenital para 0a.1 y 0a.2 con paso a isométrica antes de los playtests (`PROPUESTA`). B-01 resuelto |
| v0.0 | 01/10/2026 | Creación del borrador: consolidación de los `PARA ARQUITECTO` de `Decisiones.md`, clasificados por módulo y capa, con anexo de `Sistema.md` 14 y `Mundo.md` 9 |
