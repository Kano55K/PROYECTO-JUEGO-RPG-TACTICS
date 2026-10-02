# ARQUITECTURA — Borrador v0.3

> **Dueño:** Arquitecto Técnico
> **Estado:** BORRADOR. Base para `05_Arquitectura.md`. Secciones A y B `DECIDIDO`. Próximo paso: tarea T01.
> **Contenido:** consolidación de todos los pedidos `PARA ARQUITECTO` de `Decisiones.md` al 01/10/2026 (59 pedidos en 18 bloques → 53 requisitos, sin duplicados y con la terminología actual).
> Las reglas y los números viven en `Sistema.md`; este documento solo dice **qué tiene que soportar el código**.

**Columna Capa:**
- `0a` → rebanada de combate (se construye primero).
- `0b` → loop completo del MVP.
- `0a / 0b` → una parte entra en 0a y el resto en 0b (ver nota).
- `Futura` → no se construye en el MVP; solo se deja el lugar donde se va a enchufar.

La clasificación 0a / 0b sigue el `Brief para el Arquitecto — Prueba 0a` (sección 1). **Columna Origen:** ver el índice de la sección 11.

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
| Textos | Archivo propio con claves (`"caida.rodauva"`), separado de los números | Worldbuilder y Sistemas editan archivos distintos |
| Alternativa descartada por ahora | Tablas en CSV para editar en planilla | Dos formatos y dos cargadores. Se revisa si el balance pide trabajar en planilla |
| Alternativa descartada | Recursos propios de Godot (`.tres`) | Atan los datos al motor y son más verbosos de editar a mano |

**Ejemplo de archivo de escenario** (escenario A del Brief; los números se leen de `Sistema.md`, acá solo ilustran la forma):

```json
{
  "id": "A_dia_1",
  "_nota": "¿Sello al 50% o arriesgo una ronda más?",
  "semilla": 12345,
  "tablero": { "ancho": 8, "alto": 8 },
  "maestro": {
    "balanza": 2, "poder": 1, "regeneracion": 1,
    "vida": null, "mana_entrada": null,
    "posicion": [3, 7]
  },
  "tribu": [
    { "especie": "rodauva", "estado": "suelta", "lealtad": 5,
      "hambre": 0, "saciado": false, "enfermedades": 0,
      "vida": null, "posicion": [4, 7] }
  ],
  "salvajes": [
    { "especie": "ocarra", "vida": null, "posicion": [4, 0] }
  ],
  "toggles": { "afines_contra_cobardia": true }
}
```

`null` significa "usar el valor por defecto de la ficha o de la balanza". Las fichas de especie viven en otro archivo y el escenario solo las nombra.

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
│   ├── especies/      una ficha por especie
│   ├── tablas/        balanza, sellado, obediencia, huida, costos de maná
│   ├── relaciones.json
│   ├── textos/        textos por clave
│   └── escenarios/    escenarios A–H de 0a
├── nucleo/            reglas puras: no usa nodos ni escenas
│   ├── azar/          generador con semilla
│   ├── datos/         cargador y validador
│   ├── unidades/      especie, instancia, Maestro, pergamino
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
| Control de versiones | Git con repositorio privado (por ejemplo, GitHub). Un commit por tarea terminada |

### A.6 Cómo se testea — `DECIDIDO` (01/10/2026)

| Nivel | Qué | Cómo |
|---|---|---|
| Reglas | Cada regla del núcleo con sus casos de `Sistema.md` y del Brief | Tests automáticos con **GdUnit4 v6.2.1** (compatible con Godot 4.7.1), corridos por consola sin abrir el editor |
| Reproducción | Un combate = escenario + semilla + lista de acciones del jugador. Reproducirlo da exactamente el mismo registro | Reproductor en `herramientas/` |
| Previsualizaciones | El núcleo ofrece **calcular sin aplicar**: la pantalla pregunta "¿qué pasaría si…?" y muestra el resultado. Así la previsualización y el resultado real nunca difieren | Un test por previsualización que compara lo previsto con lo aplicado |
| Juego | Los 8 escenarios del Brief, jugados por personas | Métricas exportadas por combate |

**Fuera de 0a:** la simulación masiva de balance necesita un "jugador automático". Queda como enchufe: como las acciones son datos y los combates se reproducen, se puede sumar después sin cambiar el núcleo.

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
| T01 | Instalar Godot (versión exacta), Git y GdUnit4; crear el proyecto con la estructura de A.4 y un primer `CLAUDE.md` | A.1, A.4, A.5 | Un test de ejemplo corre por consola sin abrir el editor y pasa |
| T02 | Generador de azar con semilla que registra cada tirada | Principio 3 | Misma semilla → misma secuencia de 1.000 tiradas; otra semilla → otra secuencia |
| T03 | Cargador y validador de JSON | A.2 | Un archivo con un error devuelve archivo, campo y valor esperado, y el juego no arranca |
| T04 | Datos de 0a: 6 fichas, tabla de la balanza y relaciones | W-01 | Todo carga sin errores y los números coinciden con `Sistema.md` (revisión del usuario) |
| T05 | Modelo de unidades: especie e instancia, balanza derivada, `vida_max_real`, estados suelta / guardada / caída, pergaminos como entidades | C-01, C-02, M-01, M-03, P-01 | Tests: el Maestro con balanza 2 y 5 tiene la vida y el daño de la tabla; dos Ocarras tienen estados independientes |
| T06 | Tablero y geometría: Manhattan, adyacencia ortogonal, movimiento que atraviesa aliadas y caídas propias, alcance 2 con bloqueo solo por enemigas | K-03 | Un test por cada regla de `Sistema.md` 11.3 y del Brief (reglas 2 y 3) |
| T07 | Cola de iniciativa: Velocidad, desempates, Tasajero con dos entradas (Caza y Cuenta), lugar para la invocada de la ronda siguiente | K-01 | Tests con el orden de la Prueba A y de la Prueba C |
| T08 | Turno: 1 movimiento y 1 acción en cualquier orden; atacar; Erizarse | Brief regla 1 | Tests de turno; no se puede partir el movimiento |
| T09 | Fórmula de daño con porcentajes, planos y rasgos (Lomo de tierra, Hacerse junco, Erizarse); Saciado y enfermedades como parámetros | K-04, K-05, C-07 (0a) | Tests que reproducen los dos ejemplos de `Sistema.md` 11.4 (7 de daño y Rodauva saciada en 2) |
| T10 | Vida en 0: caída, salvaje que sale del tablero, victoria sin enemigas en pie, derrota al caer el Maestro, caídas que mueren y pergaminos que arden | K-08, K-09, P-01 | Tests de cada fila de `Sistema.md` 11.5, salvo el rescate |
| T11 | IA de salvajes base: remate → cercana → acercarse; nadie apunta a una caída | K-07 | Tests de elección de objetivo; huida y Encono quedan con su lugar reservado |
| T12 | Escenario desde JSON, registro de combate y reproductor | B-04, A.6 | Un combate guardado se reproduce con un registro idéntico |
| T13 | Pantalla cenital con placeholders: tablero, unidades, casillas de movimiento y ataque, cola de iniciativa, desglose de daño, resultado básico, recarga del escenario con una tecla | Brief 4 | Los escenarios A y B se juegan de punta a punta con el mouse |

**Hito terminado cuando:** A y B se juegan completos, todos los tests pasan y una partida grabada se reproduce igual.

### B.3 Hito 0a.2 — "La tribu se ve"

Obediencia, maná, afinidad, combos, Secundar, incidentes, Encono, cobardía y hechizos.

| ID | Tarea | Requisitos | Terminada cuando… |
|---|---|---|---|
| T14 | Obediencia en vivo, hambre de combate (+1 al cerrar las rondas 5, 10…) y Arrimo derivado de la balanza | C-03, C-04 | Tests de `Sistema.md` 5.4 y del recálculo en el acto |
| T15 | Afinidad por adyacencia (+1 como máximo; el Maestro es afín de las leales) | Brief regla 7 | Tests con varias afines adyacentes |
| T16 | Cadenas: registro de objetivo, eslabón e instancias participantes; bonos; reglas de corte | K-02, F-02 (enchufe) | Tests de la Prueba A y de cada corte de la regla 6 del Brief |
| T17 | Secundar: inserción en la cola y previsualización | K-01 | Tests; la cola muestra el lugar resultante antes de confirmar |
| T18 | Incidentes con rival aliada, con % en la casilla destino antes de mover | Brief regla 10 | Tests de los dos resultados según la obediencia |
| T19 | Chequeo único de rival enemiga → Encono (contador 0–3) o cobardía (con el toggle de afines), con % al inicio del turno | K-06 | Tests de las dos ramas; escenario E con y sin toggle |
| T20 | IA de salvajes: suma Encono e incidentes entre salvajes | K-07 | Tests: el Tasajero enconado va por la Rodauva |
| T21 | Maná: reserva, `maná_al_entrar`, regeneración al inicio del turno del Maestro, efecto del hambre | M-04 | Tests de tope y de rondas pares |
| T22 | Martillazo, Lanzadera (con choque) y Remiendo, con previsualización del empuje | Anexo 11 | Tests de alcance, bloqueo, choque y "no cura caídas" |
| T23 | Métricas de 0a.2: Secundar, eslabones, incidentes, Encono, cobardía y distancia del Maestro a la enemiga más cercana | B-05 | Cada métrica aparece en el registro exportado |

**Hito terminado cuando:** C, D, E y H se juegan completos, con todas las previsualizaciones de este hito.

### B.4 Hito 0a.3 — "Sellar, caer y ser rescatado"

| ID | Tarea | Requisitos | Terminada cuando… |
|---|---|---|---|
| T24 | Sellar: tabla vida × rango, acción, distancia ≤ 2, maná, pergamino en blanco; si falla, se pierde el maná | K-10, P-01 | Tests de la tabla; % visible sobre cada salvaje |
| T25 | Huida de salvajes con vida ≤ 25% (% por especie, acobardada, enconada) | Anexo 11 | Tests de `Sistema.md` 11.7; % visible |
| T26 | Guardar en combate (acción de la criatura, adyacente al Maestro) e invocar (turno completo, casilla libre, entra la ronda siguiente) | C-01 | Tests de los dos casos |
| T27 | Guardar a una caída (acción del Maestro, distancia ≤ 2, costo de invocar, queda con 1 de vida) | Anexo 11 | Tests; sobrevive si después el Maestro cae |
| T28 | Huida del Maestro (turno completo, termina al final de la ronda, caídas que mueren) | Anexo 11 | Tests de `Sistema.md` 11.7. **Bloqueada** hasta que Sistemas resuelva si el Maestro que cae después de declarar la huida queda caído o se salva |
| T29 | Rescate: rescatista según lealtad real, desempates del Brief, caídas que quedan atrás; pantalla de resultado completa; "quién puede rescatar ahora" visible | C-04 | Escenario F jugable; tests de desempate |
| T30 | Escenario G: atacante con lógica de salvaje, caída en 0 y tres salidas (perdonar, sellar, comer) | P-02, K-09 | G jugable con sus tres salidas |
| T31 | Panel de parámetros dentro del juego, con toggles y semilla | B-04 | Se edita un escenario sin tocar el JSON |
| T32 | Vista isométrica y lectura de la adyacencia | A.3 | Los 8 escenarios se juegan en isométrica |
| T33 | Métricas completas y exportación por combate | B-05 | Las 7 métricas del Brief se exportan en cada combate |

**0a terminada cuando:** los 8 escenarios se juegan en isométrica, con todas las previsualizaciones y las métricas exportadas. Ahí empiezan los playtests de criterios de éxito.

---

## 0. Bloqueantes de la primera sesión — `PREGUNTA ABIERTA`

| ID | Pedido | Origen | Nota |
|---|---|---|---|
| B-01 | Motor y plataforma objetivo, teniendo en cuenta que se desarrolla con Claude Code y con poca experiencia previa | D16, D18 | **Resuelto** → A.1 |
| B-02 | Alcance técnico de 0a y validación de los hitos 0a.1, 0a.2 y 0a.3 | D16, D18 | Validación en la sección B (`PROPUESTA`) |
| B-03 | ¿0a puede usar vista cenital y postergar la isométrica? | D18 | **Resuelto** → A.3 |
| B-04 | Escenarios de 0a como datos: unidades, posiciones, lealtad y hambre fijas | D18 | Formato resuelto en A.2. Tareas T12 y T31 |
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
| C-06 | Registro de hitos por instancia (primera vez Leal) para la experiencia | 0b | D17 | Por instancia, para que no se pueda farmear bajando y subiendo la lealtad |
| C-07 | Estado **Enfermo** con duración, aplicable a criaturas y al Maestro. Las causas son datos; el efecto es uno solo. Cola de enfermedades (tipo + días restantes) con cura por descanso y por contador de viaje | 0a / 0b | D03, D04, D06 | 0a: solo la **cantidad** de enfermedades como modificador de daño (parámetro del escenario). 0b: cola, contagio y cura |
| C-08 | ¿La simulación de hambre y clima corre solo para las criaturas sueltas? | 0b | D01 | `Sistema.md` 3.1 ya responde el hambre: comen las sueltas y las que estuvieron sueltas en el día. El clima es Capa 2 (Visión, roadmap): en el MVP no se simula |

---

## 2. Maestro

| ID | Requisito | Capa | Origen | Nota |
|---|---|---|---|---|
| M-01 | La balanza como **un solo valor** (posición 1–5) del que se derivan todos los efectos de la tabla 1.2 | 0a | D05 | El escenario H usa balanza 5. Nada se guarda dos veces: todo se calcula desde la posición |
| M-02 | Al mover la balanza, recalcular umbral de rescate y ritmo de lealtad, y listar qué criaturas cambian de estado para el aviso de la interfaz | 0b | D05 | Mover la balanza ocurre al subir de nivel. Si M-01 es una función derivada, este recálculo sale gratis |
| M-03 | `vida_max_real` (derivada de la balanza) separada de `vida_max_vigente` (real menos reducciones temporales) | 0a / 0b | D08 | 0a solo usa la real. Las reducciones (debilidad del ritual, malherido) son 0b |
| M-04 | Guardar `maná_al_entrar` al iniciar un combate (tope de regeneración) | 0a | D02 | |
| M-05 | Historial de los tipos de comida que comió el Maestro en los últimos días (dieta variada) | 0b | D05 | |
| M-06 | Contador de **malherido** que corre desde el fin de la recuperación y se apaga en la Poza Tibia | 0b | D17 | Depende de pendientes abiertos de Sistemas (ver 10.3) |
| M-07 | Bloquear los hechizos fuera de combate; invocar fuera de combate descuenta maná | 0b | D08 | En 0a no existe "fuera de combate" |

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
| W-05 | La Poza Tibia como nodo del Vado que cumple "viajar al sanador" | 0b | D15 | |
| W-06 | Hostilidad del Tasajero como variable de la partida, modificada por los eventos del Robledal | 0b | D04 | En 0a el Tasajero siempre es hostil (Brief, sección 6) |

---

## 8. Partida

| ID | Requisito | Capa | Origen | Nota |
|---|---|---|---|---|
| G-01 | Estado inicial: Rodauva suelta, 1 pergamino ocupado y lealtad inicial leída desde datos | 0b | D09 | En 0a el escenario A lo replica como parámetros |

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

### 10.3 Requisitos que esperan respuestas de Sistemas
Ninguno bloquea 0a.
- **M-06** (malherido): ¿la pérdida baja la vida máxima real o es una reducción aparte? Cambia si el contador toca `vida_max_real` o `vida_max_vigente`.
- **C-06** (hitos): cantidades de experiencia por hito y por nivel.
- **W-05** (Poza Tibia): duración de la visita y si ocupa un nodo del día.

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
| v0.3 | 01/10/2026 | A.4, A.5, A.6 y B pasan a `DECIDIDO`. Versiones fijas: Godot 4.7.1-stable y GdUnit4 v6.2.1. Carpetas `docs/` y `addons/` en la estructura. T28 bloqueada por una pregunta a Sistemas. Se escribe `CLAUDE.md` |
| v0.2 | 01/10/2026 | A.2 y A.3 pasan a `DECIDIDO`. Nuevas A.4 (estructura), A.5 (convenciones) y A.6 (testing) en `PROPUESTA`. Nueva sección B: validación de los hitos y plan de 0a en 33 tareas (`PROPUESTA`). B-03 resuelto; respuesta al costo de las previsualizaciones |
| v0.1 | 01/10/2026 | Nueva sección A: motor Godot 4.7 con GDScript tipado y plataforma solo PC (`DECIDIDO`); núcleo de reglas separado de la pantalla; formato JSON con validación y ejemplo de escenario (`PROPUESTA`); vista cenital para 0a.1 y 0a.2 con paso a isométrica antes de los playtests (`PROPUESTA`). B-01 resuelto |
| v0.0 | 01/10/2026 | Creación del borrador: consolidación de los `PARA ARQUITECTO` de `Decisiones.md`, clasificados por módulo y capa, con anexo de `Sistema.md` 14 y `Mundo.md` 9 |
