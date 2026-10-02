# Brief para el Arquitecto — Prueba 0a

Oct 1, 2026 · @Joaquín

## 1. Objetivo y alcance

La Prueba 0a es una rebanada de combate: tablero, relaciones, sellado, caída y rescate. Responde una sola pregunta: **¿el combate con relaciones, sellado, caída y rescate genera decisiones interesantes, y se siente la regla de oro dentro del tablero?** Alcance aprobado el 01/10/2026.

| Entra en 0a | Queda para 0b |
| --- | --- |
| Tablero 8×8, iniciativa y Secundar | Mapa del mundo, nodos y viaje |
| 6 fichas (Maestro, Rodauva, Surcón, Ocarra, Zancajunco, Tasajero) y fórmula de daño | Raciones, reparto de comida y cierre del día |
| Combos, afinidad, incidentes, Encono y cobardía | Enfermo como proceso (contagio, cola, cura) |
| Salvajes y su huida | Ritual de sangre y materiales |
| Martillazo, Lanzadera y Remiendo; maná con tope y regeneración | Campamento al raso, guardias y emboscadas |
| Sellar, invocar, guardar y guardar a una caída | Abandono, recuperación, malherido y Poza Tibia |
| Huida del Maestro, caídas y chequeo de rescate | Experiencia y subida de nivel |
| Hambre +1 cada 5 rondas (recalcula la obediencia en vivo) |  |
| Combate del ataque nocturno (escenario G) |  |

**Lo que queda afuera entra como parámetro del escenario:** lealtad y hambre por criatura, Saciado, cantidad de enfermedades, balanza, Poder, Regeneración, vida inicial y maná de entrada.

**Al terminar el combate**, una pantalla de resultado muestra si se ganó (+1 de lealtad), si se perdió con rescatista (cuál) o con permadeath, las muertes y las capturas. Lo que sigue no se simula: así el rescate se testea sin tener definidos los días de recuperación.

## 2. Reglas de combate cerradas para el 0a

Estas reglas completan `Sistema.md` v0.5 y quedan `DECIDIDO`, con valores de test. Si chocan con `Sistema.md`, manda este brief hasta la v0.6.

| # | Tema | Regla |
| --- | --- | --- |
| 1 | Turno | Cada unidad tiene 1 movimiento y 1 acción, en cualquier orden, sin partir el movimiento. Invocar y huir gastan el turno completo |
| 2 | Movimiento | Solo ortogonal. Se atraviesan aliadas y caídas propias, nunca enemigas. No se termina en una casilla ocupada. Sin terreno en 0a |
| 3 | Distancias | Todas Manhattan. Martillazo: ≤ 3, sin bloqueo |
| 4 | Sellar | Acción del Maestro (conserva el movimiento). Distancia ≤ 2. Objetivo: salvaje de pie. Si sale bien, deja el tablero y cuenta como enemiga fuera |
| 5 | Invocar | Aparece en una casilla libre adyacente al Maestro; sin casilla libre, no se puede. Entra en la cola desde la ronda siguiente |
| 6 | Corte de combos | Cortan la cadena: la acción de una enemiga (cada turno del Tasajero cuenta), un aliado que ataca a otro objetivo (incluido un incidente) o que el objetivo salga del tablero. No la cortan las acciones aliadas que no son ataque |
| 7 | Afinidad | +1 de daño como máximo por ataque, aunque haya varias afines adyacentes. Se mira la posición al golpear |
| 8 | "Rival a su alcance" | Distancia Manhattan ≤ Movimiento + Alcance. Dispara Encono y cobardía |
| 9 | Enconada | La acción queda fijada en atacar a la rival; el jugador elige la casilla (y la rival, si hay varias). Si no llega, se acerca lo más posible y pierde la acción |
| 10 | Incidente | Se tira al inicio del turno. Obediencia ≥ 4: pierde la acción. Obediencia ≤ 3: usa la acción para golpear a la rival aliada. En ambos casos conserva el movimiento |
| 11 | Regeneración de maná | Al inicio del turno del Maestro. Hambriento: solo en rondas pares |
| 12 | Hambre en combate | +1 al cerrar las rondas 5, 10, 15…; obediencia y regeneración se recalculan en el acto |
| 13 | Rescatista | Si hay varias posibles: mayor lealtad real; luego la más cercana al Maestro; luego el orden de la tribu |
| 14 | Despliegue | El jugador ubica a sus sueltas en las 2 filas de su borde; las salvajes, en las 2 opuestas. El escenario puede fijar posiciones |
| 15 | Salvajes | No Secundan |

### IA de las salvajes: remate

Cada salvaje decide en este orden:

1. **Huida:** con vida ≤ 25%, tira huida al inicio de su turno (porcentaje por especie, `Sistema.md` 11.7).
2. **Encono:** si está enconada, va por su rival (así el Tasajero va por la Rodauva).
3. **Remate:** si puede tumbar a alguna unidad este turno, ataca a esa. Si hay varias, la de menos vida actual.
4. **Cercana:** si no, ataca a la unidad más cercana que pueda alcanzar; si empatan, la de menos vida.
5. **Acercarse:** si no alcanza a nadie, se mueve hacia la unidad más cercana.

Reglas fijas: una acobardada no termina su movimiento más cerca de su rival; la Ocarra ataca desde distancia 2 si puede; nadie apunta a una caída. **Vigilar en el escenario E** que el remate no castigue de más a la Rodauva (8 de vida).

## 3. Escenarios de test

Ocho escenarios fijos, cada uno editable desde el panel de parámetros (sección 4). La balanza es 2 salvo que se indique otra cosa.

| Escenario | Configuración | Qué mide | Señal de alarma |
| --- | --- | --- | --- |
| A. Día 1 | Maestro + Rodauva (lealtad 5) contra 1 Ocarra | ¿Sello al 50% o arriesgo una ronda más? | Siempre se elige lo mismo |
| B. Muro | Maestro + Rodauva contra 2 Ocarras | ¿Reconoce que hay que huir? ¿Guarda a la caída antes? | Huir nunca se lee como opción |
| C. Tasajero | Tribu completa y leal contra el Tasajero | Duración (meta: 2 o 3 rondas) · ¿Llevo a la Rodauva? | Más de 5 rondas, o la Rodauva muere sin decisión |
| D. Rivales aliadas | Ocarra + Zancajunco en la tribu; hambre Normal y después Hambriento | Incidentes por combate · ¿Usa la Lanzadera para separarlas? | 0 incidentes, o castigo puro |
| E. Cobardía | Rodauva leal contra el Tasajero, con y sin Maestro adyacente; toggle de afines (−10 cada una, máx. −20, mínimo 5%) | ¿Sostiene a la asustada? Prueba la propuesta 10.6 | Nunca aparece, o frustra siempre |
| F. Rescate | Maestro con 6 de vida, 1 criatura leal y 1 Neutral, encuentro duro | ¿Guarda caídas antes de caer? ¿Entiende quién lo salva? | El rescate se siente azaroso |
| G. Ataque nocturno | Ocarra desleal atacante; maná de entrada a la mitad | Las 3 salidas: perdonar, sellar, comer · ¿Alcanza el maná para resellar? | Comer es siempre la respuesta |
| H. Soplo | El escenario C con balanza 5 y Poder 3 | ¿El Soplo es una build trampa? | Pierde siempre, o gana más fácil que el Barro |

## 4. Requisitos de datos, interfaz y métricas

Esto define **qué tiene que ser dato y qué tiene que verse**, no cómo se programa. El motor, la plataforma y el formato los decide el Arquitecto.

**Todo número es dato editable sin recompilar:** fichas, tabla de la balanza, tabla de sellado, costos de maná, porcentajes de incidente, Encono, cobardía y huida, pasos de Arrimo y bonos de combo.

**Panel de parámetros por escenario:**

- Unidades y posiciones iniciales.
- Por criatura: lealtad real, hambre, Saciado, cantidad de enfermedades, vida actual.
- Del Maestro: balanza, Poder, Regeneración, vida actual y maná de entrada.
- Toggles de propuestas en test: afines contra la cobardía.
- Semilla de azar fija, para reproducir una partida.

**Previsualizaciones obligatorias** (Visión 8: las apuestas se muestran antes):

- % de sellado y % de huida sobre cada salvaje.
- % de incidente en la casilla destino, antes de mover.
- % de Encono y de cobardía al inicio del turno.
- Desglose del daño (porcentajes, luego planos).
- Cola de iniciativa con las marcas Caza y Cuenta del Tasajero.
- Umbral de rescate y quién puede rescatar ahora; caídas en riesgo.

**Registro de combate** con cada tirada y estas métricas por combate:

| Métrica | Para qué |
| --- | --- |
| Rondas | Duración y costo en hambre |
| Usos de Secundar y eslabones promedio | Si los combos son una herramienta real |
| Incidentes, Encono y cobardía | Si las relaciones se ven en el tablero |
| Sellados intentados y logrados | Si la apuesta de sellado es legible |
| Salvajes que huyeron antes del sellado | Si la huida frustra |
| Caídas, caídas guardadas, muertes y rescates | Si la regla de oro aparece |
| Distancia media del Maestro a la enemiga más cercana | Que el Martillazo no esconda al Maestro atrás |

## 5. Dónde está cada número en `Sistema.md`

Los valores viven en `Sistema.md` v0.5; este brief no los repite. Las correcciones de la columna derecha llegan en la v0.6.

| Sistema del 0a | Sección | Corrección pendiente |
| --- | --- | --- |
| Balanza y stats del Maestro | 1.1, 1.2 | — |
| Arrimo | 1.3 | — |
| Hechizos | 1.6 | Pasan a `DECIDIDO` con nombres finales: Martillazo, Lanzadera, Remiendo |
| Maná: regeneración, hambre, costos, combate nocturno | 2.1 a 2.4 | — |
| Pergaminos en combate | 3.1 | — |
| Sellado y resellado | 4.1, 4.4 | — |
| Lealtad, estados y obediencia | 5.1, 5.4 | — |
| Rescate | 6 | Integrar malherido (Visión 6.6); no afecta al 0a |
| Hambre y efectos | 7.1, 7.2 | — |
| Enfermo como modificador de daño | 8.2, 8.4 | — |
| Ataque nocturno y destino de la atacante | 9.2, 9.3 | — |
| Iniciativa, combos, afinidad, incidentes, Encono, cobardía, salvajes | 10.1 a 10.7 | — |
| Relaciones entre especies | 10.8 | — |
| Fichas, tablero, fórmula de daño, caídas, encuentros, huida | 11.1 a 11.7 | Rasgos de combate pasan a `DECIDIDO` |

## 6. Preguntas abiertas y fuera de alcance

**Para la primera sesión del Arquitecto:**

- [ ] Motor de desarrollo y plataforma objetivo (Visión 11).
- [ ] Formato de las tablas de datos y del archivo de escenario.
- [ ] Cuánto cuesta cada previsualización de la sección 4; si alguna es cara, avisar a Sistemas antes de recortarla.

**Para otras áreas, sin bloquear el arranque:**

- [ ] Director Creativo: ¿el 0a usa vista isométrica real o una cenital de prueba? Afecta a Arte y al Arquitecto.
- [ ] Worldbuilder: dos textos para la criatura distraída por su rival aliada y para la que la ataca. Sirven placeholders.
- [ ] Arte / UI: placeholders aceptados para el 0a; las previsualizaciones son obligatorias desde el primer build.

**Fuera de alcance del 0a** (no hace falta resolverlo para empezar): hostilidad del Tasajero y ofrenda (en 0a siempre es hostil), encuentros del Vado y emboscadas, días de recuperación y visita a la Poza Tibia, crecida, experiencia y curva de nivel.
