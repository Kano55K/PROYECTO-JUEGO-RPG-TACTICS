# 06_Arte_UI.md — Valdelumbre

Dueño: Director de Arte y UI · Versión v0.1 · 08/10/2026

Estados: `DECIDIDO` · `PROPUESTA` · `PREGUNTA ABIERTA`. Lo que toca al motor es `PARA ARQUITECTO` hasta que él lo confirme.

---

## 1. Dirección de estilo — `DECIDIDO` (08/10/2026)

| Tema | Decisión | Motivo |
|---|---|---|
| Referencia de tono | *Final Fantasy Tactics Advance*: limpio, saturado, luminoso. Se toma el **nivel de detalle y la claridad**, no diseños, íconos ni interfaz | Calidez con dientes: luminoso por defecto (Visión). Elegido por el usuario |
| Luz | Una sola fuente, **arriba a la izquierda**. Cara de arriba = la más clara; cara izquierda = media; cara derecha = la más oscura | Una regla fija evita que cada pieza se ilumine distinto |
| Contorno | **Criaturas y Maestro:** contorno completo con `#2b1d2e` (se puede aclarar por dentro, nunca quitar por fuera). **Baldosas:** sin contorno; los bordes se marcan con el tono más oscuro de su rampa | Las unidades tienen que despegarse del tablero |
| Rampas | Cada material usa su rampa en orden. Las sombras van hacia el violeta o el azul, las luces hacia el amarillo. Nada de negro ni blanco puros | Da calidez y unidad sin pensar color por color |
| Lo oscuro | Aparece como **consecuencia** (estado, noche, caída), con la misma paleta bajada de valor. Nunca como decorado del escenario | Visión |
| Lectura | Una pieza se aprueba mirándola **al 100% (×1) y al ×3**, sobre la escena de prueba, no sola | El tablero manda |

## 2. Paleta Valdelumbre v0.1 — `DECIDIDO` (sujeta a la pieza de prueba)

Archivo: `valdelumbre_v01.gpl`. 30 colores. Se amplía solo con motivo escrito en esta sección.

| Rampa | Colores (oscuro → claro) | Uso |
|---|---|---|
| Contorno | `#2b1d2e` | Contorno de unidades, sombra más profunda |
| Pasto | `#2f4a3a` `#3e6b3a` `#5f9440` `#8fbf4a` `#c9e06a` | Pasto, hojas, frutales |
| Tierra | `#4a2e2a` `#74462f` `#a1683d` `#c99459` `#e6c38a` | Tierra, caminos, madera, púas de la Rodauva |
| Piedra | `#3b3a4a` `#5e5c6b` `#8a8590` `#b8b0a8` `#e2dacb` | Muros de Almiar, piedras del Vado |
| Agua | `#1f3a5c` `#2f6b8f` `#4ea3b8` `#8fd6d6` | Acequia, río |
| Uva / fruta | `#4a2348` `#7a3a6b` `#b0568a` `#e08fb0` | Fruta, hocico rosado, flores |
| Oro / otoño | `#c45a2a` `#e89a3c` `#f2d36b` | Hojarasca, fuego, luz cálida, resaltes de UI |
| Rojo | `#8c2a2a` `#c8423a` | Fruta roja, peligro en la UI (siempre con ícono) |
| Crema | `#fff3d6` | Brillos puntuales, texto de UI sobre oscuro |

## 3. Especificaciones técnicas

| Tema | Valor | Estado |
|---|---|---|
| Baldosa | Rombo 2:1 de **32 × 16 px** | `PARA ARQUITECTO` |
| Altura de escalón | **8 px** por nivel | `PARA ARQUITECTO` |
| Resolución base | **640 × 360**, escalado entero ×3 a 1920 × 1080 | `PARA ARQUITECTO` |
| Cuadro de criatura | Rango 1: **32 × 32**. Más grandes: 48 × 48 | `PROPUESTA` |
| Punto de apoyo | Centro del rombo de la casilla (en el cuadro de 32 × 32: píxeles 15–16, fila 23–24) | `PROPUESTA` |
| Direcciones | 2 dibujadas: **frente** (abajo-derecha) y **espalda** (arriba-derecha). Las otras dos, espejadas | `DECIDIDO` (Visión) |
| Archivos | Un `.aseprite` por criatura, con etiquetas por animación y dirección (`reposo_frente`, `reposo_espalda`…) | `PROPUESTA` |
| Formato de exportación | Pendiente: hoja de sprites + JSON, a definir con el Arquitecto | `PREGUNTA ABIERTA` |

## 4. Pieza de prueba (Fase A)

Script: `valdelumbre_lienzos.lua` (crea los tres lienzos con la paleta y una capa GUIA bloqueada).

| Lienzo | Contenido | Para qué |
|---|---|---|
| `huertos_baldosas` | 6 bloques de 32 × 32: pasto · tierra arada · camino · acequia · muro de Almiar · pasto con fruta caída | Probar materiales, luz y escalón |
| `rodauva` | 8 cuadros: reposo de frente (1–4) y de espaldas (5–8), 0,18 s por cuadro | Probar silueta y lectura sobre el terreno |
| `escena_prueba` | Tablero de 6 × 6 (256 × 176) | Juntar todo y mirarlo al ×1 y al ×3 |

## 5. HUD de combate

`PREGUNTA ABIERTA`: wireframe pendiente (próxima sesión). Insumo: la lista **PARA ARTE / UI** de `Sistema.md` 15.

---

## Registro de cambios

| Versión | Fecha | Cambio |
|---|---|---|
| v0.1 | 08/10/2026 | Creación: dirección de estilo, paleta v0.1, especificaciones propuestas y pieza de prueba |