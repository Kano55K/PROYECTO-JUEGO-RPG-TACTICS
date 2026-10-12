RESUMENES — Historial de sesiones de programación

Lo escribe Claude Code al final de cada sesión, según CLAUDE.md (sección "Resúmenes de sesión"). Las entradas se agregan al final y nunca se editan ni se borran. No es fuente de verdad: si contradice a docs/ o al código, mandan ellos. El historial empieza en T08. Lo anterior está en los pull requests de T01 a T07 y en Arquitectura.md A.10.
## T08 · sesión 1 · 04/10/2026
- **Rama:** tarea/T08-turno
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:** turno de una unidad en `nucleo/combate/`, una por entrada de la cola de T07 (el Tasajero juega dos turnos completos). 1 movimiento y 1 acción en cualquier orden; las acciones son datos (`mover`, `atacar`, `erizarse`, `terminar`), iguales para el jugador y la IA. `validar` y `aplicar` usan la misma función: validar no cambia el `Plantel` ni el turno, y una acción inválida devuelve un motivo de un `enum` sin cambiar nada. Mover: a una casilla de `Tablero.alcanzables`, de una vez. Atacar: a una enemiga de pie en una casilla que se golpea desde donde está (distingue fuera de alcance y línea bloqueada por una enemiga); el daño sale de una única función (`Danio.calcular`), que hoy da el Daño base (ficha, o balanza del Maestro) con el mínimo de `combate.json`; la vida no baja de 0 y nada más. Erizarse: solo si el `rasgo.efecto` de la ficha es `accion_defensa` (nunca por id); gasta la acción, deja `erizada` y, por `rasgo.inmovil`, cierra el movimiento si no se había usado. La marca se borra al empezar su próximo turno. Terminar sin usar la acción devuelve `espero = true`. Punto de inicio del turno con los 4 pasos de 11.3 comentados (T21, T25, T19, T18) y punto de fin vacío (T16, T23). Consultas para la pantalla y la IA, sin modificar nada: `casillas_para_mover`, `objetivos_para_atacar`, `puede_erizarse`, `puede_terminar`. Lugar para "gasta el turno completo" en `Accion.gasta_turno_completo()` (hoy `false`). Sin cambios de esquema ni de datos.
- **Archivos:** creados `nucleo/combate/turno.gd`, `accion.gd`, `resultado_accion.gd`, `danio.gd`, `pruebas/combate/test_turno.gd`, `pruebas/fixtures/combate/escenario_turno.json`; modificados `nucleo/unidades/criatura.gd` (campo `erizada`), `docs/PREGUNTAS.md`, `CLAUDE.md` (Estado actual).
- **Tests:** 14 nuevos, total 115, todos pasan (sí). Se comprobó además que romper a mano el borrado de la marca o el piso de 0 hace fallar los tests (7c) y (6).
- **Criterio de terminado:** cumplido punto por punto. La fila T08 tiene 12 renglones: (1) mover → atacar y atacar → mover; (2) después de 1 paso de 4 no se vuelve a mover; (3) no hay segunda acción; (4) rechazos con motivo y el `Plantel` intacto: no alcanzable, aliada, caída, fuera de alcance, Ocarra por encima de una enemiga; (5) Maestro con la balanza de prueba (4 en balanza 2, 3 en balanza 5) y criaturas con su ficha; (6) la vida no baja de 0; (7) Erizarse: gasta la acción, no se mueve después, vale si se movió antes, sigue erizada en los turnos de las demás y deja de estarlo al empezar su turno en la ronda siguiente; (8) Ocarra y Maestro no se erizan; (9) Prueba C: el Tasajero mueve y ataca en Caza (12 − 6 = 6) y otra vez en Cuenta (6 − 6 = 0) con movimiento y acción renovados; (10) esperar cierra el turno y la cola sigue con la entrada que corresponde; (11) validar no cambia nada y da el mismo resultado que aplicar; (12) sin azar.
- **Lecturas declaradas:** P-014 (= S-15): erizarse antes de moverse cierra el movimiento; P-015 (= S-16): terminar sin usar la acción es "esperar". Técnicas, sin pregunta: mover a la misma casilla se rechaza (`MISMA_CASILLA`); hasta T10, una unidad con vida 0 sigue `suelta` y se la puede volver a atacar; el turno se cierra siempre con `terminar`, nunca solo.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** nuevas P-014 y P-015 (SISTEMAS, no bloquean); cerradas: ninguna. Aviso: S-16 todavía no figura en la copia de `Arquitectura.md` 10.5 del repositorio.
- **Para la próxima sesión:** nada: tarea terminada.

## T09 · sesión 1 · 04/10/2026
- **Rama:** tarea/T09-danio
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:** fórmula de daño completa de `Sistema.md` 11.4 dentro de `Danio.calcular`, que sigue llamando solo `Turno`. Orden: suma de porcentajes → aplicados al Daño base con redondeo hacia abajo → suma de planos → mínimo de `combate.json`. Aritmética en enteros: `Porcentajes.aplicar(valor, porcentaje)` corrige a mano el truncamiento hacia 0 de GDScript con numeradores negativos; no tiene mínimo y no depende del combate (la recolección de 0b la reusa, K-05). Fuentes propias: Saciado derivado del hambre con los estados de `hambre.json` (`danio_pct` del estado cuyo rango lo contiene); una entrada por enfermedad con `enfermedad_danio_pct` de `combate.json`; Erizarse (`rasgo.efecto` `accion_defensa` y objetivo erizada, `danio_recibido_pct`); Lomo de tierra (`reduccion_plana`, `danio_recibido_plano`); Hacerse junco (`primer_ataque`, `danio_plano`, si la atacante no tiene `ya_ataco`). Rasgos reconocidos por su efecto, nunca por id. Hambre y enfermedades solo para el Maestro y la tribu (S-17). Aportes externos por parámetro (`Array[ModificadorDanio]`, porcentaje o plano, con su fuente) para combo, afinidad, Encono y cobardía: hoy solo los usan los tests. `calcular` devuelve un `DesgloseDanio`: `base`, `modificadores` (fuente, tipo, valor, detalle = id del estado de hambre o del rasgo), `porcentaje_total`, `tras_porcentajes`, `planos_total`, `minimo_aplicado`, `total`. La marca de Hacerse junco (`Criatura.ya_ataco`) la gasta `Danio.registrar_ataque`, que `Turno._atacar` llama solo dentro de `if aplica` (nunca al validar ni con un ataque rechazado). `Turno` cambió dos líneas: `.total` y esa llamada. `ResultadoAccion` no cambió. Sin cambios de esquema ni de datos: todos los números ya estaban en `datos/`.
- **Archivos:** creados `nucleo/combate/porcentajes.gd`, `modificador_danio.gd`, `desglose_danio.gd`, `pruebas/combate/test_danio.gd`, `pruebas/fixtures/combate/escenario_danio.json`, `pruebas/fixtures/combate/hambre.json`; modificados `nucleo/combate/danio.gd`, `nucleo/combate/turno.gd` (2 líneas), `nucleo/unidades/criatura.gd` (campo `ya_ataco`), `docs/PREGUNTAS.md`, `CLAUDE.md` (Estado actual).
- **Tests:** 12 nuevos, total 127, todos pasan (sí). Se comprobó además que quitar la llamada a `registrar_ataque` hace fallar el test (7) y que cambiar el piso por la división truncada hace fallar el (8) (`runtest.cmd` corta en el primer fallo, así que el (10) no llegó a correr en esa prueba).
- **Criterio de terminado:** cumplido punto por punto. (1) Maestro con combo +50% y afinidad +1 hace 7; (2) Rodauva saciada 2 y con hambre 3 también 2 (más el borde: Ocarra con hambre 2 hace 5 y con 3 hace 4); (3) Ocarra saciada con 1 enfermedad, 0%, hace 4; (4) Maestro con 3 enfermedades hace 1; (5) contra una Rodauva erizada, Ocarra 2 y Tasajero 3; (6) contra el Surcón, Maestro 3 y Rodauva 1; (7) Zancajunco 6 en el primer ataque y 4 en el segundo; validar dos veces, un ataque rechazado y `calcular` suelto no gastan el bono; (8) Rodauva con 3 enfermedades contra Rodauva erizada: −125%, tras porcentajes −1, total 1 con el mínimo marcado; (9) el desglose lista los 6 modificadores con fuente, tipo, valor y detalle y el total se rearma desde la lista; (10) `Porcentajes.aplicar`: 1 con −50% da 0, 5 con −25% da 3, 2 con −125% da −1; (11) una Ocarra enemiga hace 4 con la tribu saciada, aunque tenga hambre 0 y 1 enfermedad; (12) los 14 tests de T08 pasan sin tocarlos.
- **Lecturas declaradas:** P-016 (= S-17): las enemigas no reciben Saciado ni enfermedades. P-017: sin recorte intermedio; los planos se suman sobre un daño negativo tras los porcentajes y el único recorte es el mínimo. Técnicas, sin pregunta: la marca `ya_ataco` empieza en `false` porque el `Plantel` se arma en cada combate (reponerla para una tribu persistente es de 0b); `Danio.desde_datos` acepta la tabla de hambre como opcional para no tocar `test_turno.gd` (sin ella nadie recibe porcentaje por hambre; el juego real, T13, tiene que pasarla); `Porcentajes` vive en `nucleo/combate/` sin depender del combate.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** nuevas P-016 y P-017 (SISTEMAS, no bloquean); cerradas: ninguna. Aviso: el encabezado de `CLAUDE.md` y `Arquitectura.md` A.5 todavía dicen "alineado con v0.12" (la copia de `Arquitectura.md` es la v0.13).
- **Para la próxima sesión:** nada: tarea terminada.

## T10 · sesión 1 · 04/10/2026
- **Rama:** tarea/T10-vida-cero
- **Estado:** EN CURSO (sigue en la sesión 2: cierre y lealtad)
- **Hecho:** vida en 0 y fin del combate (`Sistema.md` 11.5). `VidaCero.resolver(unidad_id, plantel)` resuelve en el acto a la unidad que quedó en 0; `Turno._atacar` la llama solo dentro de `if aplica`, justo después de bajar la vida (nunca al validar). Tribu → `CAIDA`, en su casilla, que sigue ocupada; atacante nocturna → `CAIDA` (su pergamino sigue ocupado: su destino es T30); salvaje → estado nuevo `Criatura.Estado.FUERA` y queda sin posición (el mismo estado que usarán la huida, T25, y el sellado, T24; sin campo de motivo porque hoy nadie lo lee); Maestro → `Maestro.caido = true`. `FinCombate.evaluar(plantel)` devuelve `Fin.EN_CURSO`, `VICTORIA` (ninguna enemiga `SUELTA` con posición) o `DERROTA_POR_CAIDA` (Maestro caído, se mira primero). No se guarda: sale del `Plantel`, así lo ven todos los `Turno`, también los que empiezan después. `Turno._resolver` lo mira antes de cada acción: con el combate terminado rechaza todo (también `terminar` y también al validar) con el motivo nuevo `COMBATE_TERMINADO`, y `ResultadoAccion.fin` dice cómo terminó. Después de cada acción aplicada y válida, `resultado.fin` trae el estado del combate; al validar no se adelanta (queda `EN_CURSO`). La caída y la que salió dejan de ser objetivo (`OBJETIVO_CAIDO` y `OBJETIVO_FUERA_DEL_TABLERO`): corrige la lectura técnica de T08. `ColaIniciativa` y `Tablero` sin cambios (ya salteaban lo que no está `SUELTA` e ignoraban lo que no tiene posición). Sin cambios de esquema ni de datos: `FUERA` y `caido` existen solo durante el combate.
- **Archivos:** creados `nucleo/combate/vida_cero.gd`, `nucleo/combate/fin_combate.gd`, `pruebas/combate/test_vida_cero.gd`, `pruebas/fixtures/combate/escenario_vida_cero.json`; modificados `nucleo/combate/turno.gd`, `nucleo/combate/resultado_accion.gd`, `nucleo/unidades/criatura.gd` (`Estado.FUERA`), `nucleo/unidades/maestro.gd` (`caido`), `pruebas/combate/test_turno.gd` (test 6: la salvaje en 0 queda `FUERA`, antes `SUELTA`, avisado en el plan), `docs/PREGUNTAS.md`, `CLAUDE.md` (Estado actual).
- **Tests:** 5 nuevos, total 132, todos pasan (sí). Control: sin la llamada a `VidaCero.resolver`, fallan el test 6 de T08 y los de T10.
- **Criterio de terminado:** sesión 1 cumplida punto por punto. (1) la Rodauva de la tribu en 0 queda caída en [2,6], la casilla sigue ocupada, atacarla se rechaza y la cola la saltea en la misma ronda; validar el golpe no la tumba. (2) la Ocarra salvaje en 0 queda `FUERA`, sin posición, y la Rodauva se mueve a su casilla. (3) la atacante nocturna en 0 queda caída, con su pergamino ocupado. (4) tumbar a una de dos enemigas da `EN_CURSO`; la última da `VICTORIA` y después mover, validar y terminar se rechazan sin cambiar el `Plantel`. (5) cae el Maestro → `DERROTA_POR_CAIDA` en el acto; quedan entradas en la cola, pero el turno de la Rodauva rechaza todo. Falta la sesión 2: puntos 6 a 10.
- **Lecturas declaradas:** P-018: la caída bloquea el paso y la línea de Alcance 2 de la otra banda como si estuviera de pie (lo que ya hacía `Tablero` desde T06). Técnicas, sin pregunta: la cola no saltea al Maestro caído (P-013), pero el turno que sigue rechaza todo; el esquema admite `vida: 0` al cargar y esa unidad no se resuelve hasta que la atacan (ningún escenario lo usa); la erizada que cae conserva la marca (no cambia nada porque no puede ser objetivo).
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** nueva P-018 (SISTEMAS, no bloquea); cerradas: ninguna. P-001 sigue `RESPONDIDA` y se aplica en la sesión 2.
- **Para la próxima sesión:** arrancar por `nucleo/combate/cierre.gd`: una función que recibe el `Plantel` y un `FinCombate.Fin` (agregar `HUIDA` al enum, sin programar, T26) y devuelve el cierre. Agregar `Criatura.Estado.MUERTA`. En victoria, las caídas de la tribu (`bando == TRIBU` y `estado == CAIDA`) se levantan con la vida de `combate.json`; en derrota mueren, su pergamino arde (`Pergamino.arder()`) y se aplica muerte en el grupo; las guardadas no se tocan; la atacante caída no es de T10. Acumulador de lealtad con motivo y criatura, suma y recorte único 0–10 con `tablas/lealtad.json` (+1 de victoria a las sueltas al terminar; −2/−4 por muerta según la relación de especie de 10.8, P-001). Tests 6 a 10 del criterio. Al cerrar, P-001 pasa a `CERRADA`.

## T10 · sesión 2 · 04/10/2026
- **Rama:** tarea/T10-vida-cero
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:** tarea entera (dos sesiones). **Sesión 1, vida en 0 y fin del combate** (`Sistema.md` 11.5): `VidaCero.resolver` se llama solo al aplicar un golpe: tribu y atacante nocturna → `CAIDA`, salvaje → `FUERA` sin posición, Maestro → `caido`. `FinCombate.evaluar` sale del `Plantel` sin guardarse, y con el combate terminado `Turno` rechaza todo con `COMBATE_TERMINADO`. **Sesión 2, cierre y lealtad** (3.2, 5.2, 6, 11.5; P-001): `Cierre.desde_datos(tabla_combate, tabla_lealtad, relaciones).cerrar(plantel, fin)` devuelve un `ResultadoCierre` (`valido`, `motivo`, `fin`, `maestro_caido`, `levantadas`, `muertas`, `lealtad`). Se cierra una sola vez (`Plantel.cerrado`, solo en tiempo de ejecución). Se rechaza sin tocar nada: `YA_CERRADO`, `COMBATE_EN_CURSO`, `NO_IMPLEMENTADO` (`HUIDA`, agregado al enum sin programar, T26) y `FIN_NO_COINCIDE` (el fin no es el de `FinCombate.evaluar`; decisión técnica). **Victoria:** las caídas de la tribu se levantan con `combate.json` `vida_tras_caida`, en su casilla, y las sueltas al terminar anotan `lealtad_por_victoria`; las guardadas no. **Derrota por caída:** las caídas de la tribu pasan al estado nuevo `Criatura.Estado.MUERTA` (solo en tiempo de ejecución), su pergamino arde y por cada muerta cada suelta anota `muerte_en_el_grupo_afines` si su especie se lleva bien con la de la muerta (10.8) o `muerte_en_el_grupo` si no; el cierre solo dice que el Maestro cayó (sin rescate, +2 ni permadeath). La atacante caída y las salvajes no cambian. En `nucleo/unidades/`, sin nada de combate: `Relaciones` (lee `relaciones.json`, pares sin orden, el que no figura es `NINGUNA`; la primera clase que lee relaciones, W-01) y `AcumuladorLealtad` (anota criatura, cambio y motivo; al aplicar suma por criatura, recorta una sola vez con `minimo`/`maximo` de `lealtad.json` y devuelve `CambioLealtad`: antes, cambio, después y anotaciones; se aplica una sola vez). Ningún número de balance en el código. Sin cambios de esquema ni de datos: `vida_tras_caida` y `lealtad_por_victoria` ya estaban en `combate.json`.
- **Archivos:** creados `nucleo/combate/vida_cero.gd`, `nucleo/combate/fin_combate.gd`, `nucleo/combate/cierre.gd`, `nucleo/combate/resultado_cierre.gd`, `nucleo/unidades/relaciones.gd`, `nucleo/unidades/acumulador_lealtad.gd`, `nucleo/unidades/anotacion_lealtad.gd`, `nucleo/unidades/cambio_lealtad.gd`, `pruebas/combate/test_vida_cero.gd`, `pruebas/combate/test_cierre.gd`, `pruebas/unidades/test_acumulador_lealtad.gd`, `pruebas/unidades/test_relaciones.gd`, `pruebas/fixtures/combate/escenario_vida_cero.json`, `pruebas/fixtures/combate/escenario_cierre.json`, `pruebas/fixtures/unidades/lealtad.json`, `pruebas/fixtures/unidades/relaciones.json`; modificados `nucleo/combate/turno.gd`, `nucleo/combate/resultado_accion.gd`, `nucleo/unidades/criatura.gd` (`FUERA`, `MUERTA`), `nucleo/unidades/maestro.gd` (`caido`), `nucleo/unidades/plantel.gd` (`cerrado`), `pruebas/combate/test_turno.gd`, `docs/PREGUNTAS.md`, `CLAUDE.md` (Estado actual).
- **Tests:** 18 nuevos en la tarea (5 en la sesión 1, 13 en la sesión 2: 8 de cierre, 3 de acumulador, 2 de relaciones), total 145, todos pasan (sí). Control: si el cierre confunde la relación "bien" con "mal", fallan los tests (7) y (8).
- **Criterio de terminado:** cumplido punto por punto. (1) a (5): ver T10 · sesión 1. (6) victoria con la Rodauva caída: se levanta con 1 de vida en su casilla y queda en 9 (8 + 1), como las de pie; la guardada sigue en 5; la atacante sigue caída con su pergamino ocupado. (7) derrota con dos Rodauvas caídas: las dos `MUERTA`, sus pergaminos `ARDIDO`; el Surcón 9 − 4 − 4 = 1 y la Ocarra 7 − 2 − 2 = 3, con dos anotaciones cada una. (8) ejemplo de 5.2: muere una Rodauva → la otra Rodauva y el Surcón −4, la Ocarra −2. (9) acumulador: 9 con +2 y −2 da 9 en los dos órdenes; 1 con −4 da 0. (10) la muerta conserva su lealtad y no aparece en los cambios; la guardada no pierde. Además: cerrar en curso, dos veces, con `HUIDA` o con un fin que no coincide se rechaza sin cambiar el `Plantel`.
- **Lecturas declaradas:** P-018 (sesión 1). P-019: el acumulador anota las claves de `lealtad.json` y `"victoria"` para el +1, que no coinciden con el enum `lealtad_cambios.motivo` de `resultado.schema.json` (afecta a T12). Técnicas, sin pregunta: la muerta conserva su vida (0) y su casilla, y pierde el pergamino (`pergamino_id = ""`); "de noche, solo las que pelearon" (5.2) no se programa porque en 0a toda suelta de la tribu está en el tablero (0b / T30); cerrar con un fin distinto del que da `FinCombate.evaluar` se rechaza.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** nuevas P-018 (SISTEMAS, no bloquea; sesión 1) y P-019 (ARQUITECTO, no bloquea); cerrada P-001.
- **Para la próxima sesión:** nada: tarea terminada.

## T11 · sesión 1 · 04/10/2026
- **Rama:** tarea/T11-ia
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:** tarea entera en una sesión. IA de las salvajes (`Sistema.md` 11.8; la atacante nocturna usa la misma, 9.2 punto 3). `IASalvaje.decidir(turno, plantel, cola)` devuelve un `DecisionIA`: la lista de `Accion` de T08 (`[MOVER?, ATACAR, TERMINAR]`, `[ERIZARSE, TERMINAR]` o `[MOVER?, TERMINAR]`) y, para depurar, `paso`, `objetivo_id`, `casilla`, `danio_previsto` y `describir()` (sin textos para el jugador). No aplica nada ni usa azar. Un paso por función, en el orden de 11.8: huida y Encono vacíos (T25, T19/T20), Erizarse (por efecto del rasgo, vida ≤ umbral de la ficha en enteros, enemiga de pie adyacente, sin moverse), remate (menos vida → cercana → cola), cercana (cercana → menos vida → cola, S-19) y acercarse (objetivo más cercana; casilla alcanzable más cercana a ella → orden de lectura; si ninguna la acerca, no se mueve). "Puede tumbar" y "puede alcanzar" miran el turno completo (S-8): cada casilla a la que llega (incluida la suya) contra cada unidad, con `Turno.previsualizar_ataque(desde, objetivo_id)`, que pasa por `_atacar_desde`, la misma función del ataque real (mismas comprobaciones, mismo `Danio.calcular`, mismo punto de aportes `_aportes(desde, objetivo_id)`, vacío hasta T15, T16 y T19) y no gasta Hacerse junco. La consulta va en `Turno` porque es quien sabe desde qué casilla se golpea y qué aportes corresponden. Casilla para golpear: si ya alcanza no se mueve → la más lejana a la objetivo (Alcance 2 prefiere la distancia 2; con Alcance 1 no cambia nada) → menos pasos → orden de lectura. Los pasos salen de `Turno.pasos_para_mover()` sobre `Tablero.pasos_hasta`, que es el BFS de T06 extraído (ahora `alcanzables` lo usa). Nadie apunta a una caída porque `Turno` ya la rechaza. Umbral de Erizarse como dato: `rasgo.umbral_vida_pct` (esquema, después ficha de la Rodauva real y de prueba con `_nota` "Sistema.md 11.8").
- **Archivos:** creados `nucleo/combate/ia/ia_salvaje.gd`, `nucleo/combate/ia/decision_ia.gd`, `nucleo/combate/ia/opcion_ataque.gd`, `pruebas/combate/ia/test_ia_salvaje.gd`, 12 fixtures en `pruebas/fixtures/combate/ia/` (`ia_remate`, `ia_remate_moviendose`, `ia_remate_maestro`, `ia_cercana`, `ia_casilla_quieta`, `ia_casilla_distancia_2`, `ia_casilla_pasos`, `ia_acercarse`, `ia_erizarse`, `ia_caida`, `ia_tasajero`, `ia_junco`); modificados `nucleo/combate/turno.gd`, `nucleo/combate/tablero.gd`, `datos/_esquemas/especie.schema.json`, `datos/especies/rodauva.json`, `pruebas/fixtures/unidades/rodauva.json`, `pruebas/combate/test_turno.gd`, `pruebas/combate/test_tablero.gd`, `docs/PREGUNTAS.md`, `CLAUDE.md` (Estado actual).
- **Tests:** 14 nuevos (12 del criterio, más `test_pasos_hasta_con_rodeo` y `test_previsualizar_ataque`), total 159, todos pasan (sí). Control: con el desempate del remate invertido, falla el test (1).
- **Criterio de terminado:** cumplido punto por punto. (1) la Ocarra puede tumbar a `rodauva_1` (4, adyacente) y a `rodauva_2` (2, moviéndose): va por `rodauva_2`, desde [6,2]. (2) desde [4,0] no alcanza; mueve a [4,3] y tumba a la Rodauva; el daño aplicado es el previsto. (3) tumba al Maestro (4) en vez de pegarle a la Rodauva entera adyacente: `DERROTA_POR_CAIDA`. (4) Rodauva (6, a 1) antes que el Maestro (5, a 2); a la misma distancia, el de menos vida; empatadas en las dos, la Rodauva (antes en la cola) y no el Surcón, que va antes en el Plantel y en orden de lectura. (5) con la objetivo adyacente no se mueve; sin alcance, distancia 2 desde [2,0] (3 pasos) antes que distancia 1 (2 pasos); con Alcance 1, menos pasos ([2,2], [3,3]) antes que [3,1], y orden de lectura entre las de 2. (6) se acerca a [3,0] entre cuatro casillas a 7 de la Rodauva. (7) con 3 y con 4 de 8 se eriza sin moverse; con 5 ataca; con 3 sin enemiga adyacente se mueve y ataca. (8) la Ocarra con 2 de vida y una enemiga adyacente ataca. (9) con la caída adyacente que podría tumbar, ataca a `rodauva_2`. (10) en Caza el Tasajero tumba a la Rodauva; en Cuenta va por el Maestro desde [6,3] (20 → 14). (11) decidir no cambia el `Plantel` ni `ya_ataco`; dos llamadas dan lo mismo; el Zancajunco remata con 4 + 2 y, si ya atacó, prevé 4 y no remata; sin nombres de azar en `nucleo/combate/ia/`. (12) escenario A: ronda 1 se acerca a [4,3] hacia la Rodauva; ronda 2 la golpea desde [4,5] (8 → 4), con el Maestro intacto.
- **Lecturas declaradas:** P-020 (S-19: el remate desempata menos vida → cercana; sin remate, cercana → menos vida); P-021 ("la que actúa antes en la cola" es el orden de la ronda entera, por la primera entrada de la unidad); P-022 (una caída adyacente no hace erizarse: solo las enemigas de pie). Técnicas, sin pregunta: la unidad que no está en la cola va al final, en el orden del Plantel (en 0a no pasa); la IA no mira si la unidad es salvaje o atacante; una ficha con `accion_defensa` sin `umbral_vida_pct` es un error de datos (como `danio_recibido_pct` en `Danio`); "prefiere la distancia 2" se programa como "la más lejana a la objetivo dentro de su alcance", que con Alcance 1 no cambia nada.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** nuevas P-020, P-021 y P-022 (SISTEMAS, no bloquean); cerradas: ninguna. P-019 sigue `RESPONDIDA` y se aplica en T12. Además, se restauró la línea `Respuesta` de P-017, que faltaba desde la corrección del merge de T10 (sin cambiar su contenido).
- **Para la próxima sesión:** nada: tarea terminada.

## T12 · sesión 1 · 04/10/2026
- **Rama:** tarea/T12-contrato
- **Estado:** EN CURSO (sigue en la sesión 2)
- **Hecho:** contexto, bucle y registro del combate (`Arquitectura.md` A.7), más la deuda de T09. `ContextoCombate.armar(escenario, datos)` recibe los datos con la forma del `Cargador` y arma tipo, semilla, `Tablero`, `Plantel`, `golpe_inicial` (leído, sin resolver: T30), toggles, `Danio`, `Relaciones`, `Cierre` y dos generadores derivados de la semilla (`GeneradorAzar.derivado(semilla, sistema)`: primeros 8 bytes del SHA-256 de `"semilla/sistema"`, que no dependen del orden de creación, A.8). Si el Maestro, una suelta de la tribu o una enemiga traen `posicion: null`, lo rechaza con `DESPLIEGUE_NO_IMPLEMENTADO` (P-023). `Combate.empezar(contexto)` es el bucle. Antes de la ronda 1 registra `inicio`, pasa por el punto vacío del golpe inicial, resuelve con `VidaCero` las unidades del tablero que están en 0 (en el orden del Plantel) y evalúa `FinCombate`. Después juega las enemigas con `IASalvaje` y se detiene en el primer turno del jugador. `aplicar` valida antes de registrar: una acción inválida no deja rastro. El corte es por `FinCombate` y no por la cola: registra `fin` y `cierre`, y el `Cierre` corre una sola vez. Una acción inválida de la IA, o una IA que no cierra su turno, deja `error()` y detiene el combate. `RegistroCombate` guarda una línea por evento, con `n` y `ronda` y las claves ordenadas al serializar, y rechaza un `float` (u otro tipo que no sea entero, texto, booleano, null, lista o diccionario). Eventos: `inicio`, `ronda`, `turno`, `accion` (origen y `paso` de la IA), `movimiento`, `ataque` (desglose, vida antes y después), `estado`, `tirada`, `fin_turno`, `fin_ronda`, `fin` y `cierre`. Antes de cada evento se vuelcan las tiradas nuevas del generador de combate. `turno` se registra antes de `Turno.empezar`, así las tiradas del inicio del turno (T18 a T25) quedan dentro de su turno. Se adelantaron a esta sesión `instantanea()` (decisión del usuario: la necesita el test 3) y la ida y vuelta de `Accion` por diccionario (código y test 18). `Danio.desde_datos` exige la tabla de hambre: sin `estados`, devuelve `null`.
- **Archivos:** creados `nucleo/combate/contexto_combate.gd`, `nucleo/combate/combate.gd`, `nucleo/combate/registro_combate.gd`, `pruebas/combate/test_combate.gd`, `pruebas/combate/datos_fixture.gd`, `pruebas/fixtures/combate/contrato/contrato_victoria.json` y `contrato_derrota.json`; modificados `nucleo/azar/generador_azar.gd` (`derivado`), `nucleo/combate/danio.gd`, `accion.gd` (`a_diccionario`, `desde_diccionario`), `resultado_accion.gd` (`desglose`, `FUERA_DE_TURNO`), `turno.gd` (guarda el desglose), `desglose_danio.gd` y `modificador_danio.gd` (`a_diccionario`), `cola_iniciativa.gd` (`lugar()`), `nucleo/unidades/plantel.gd` (`instantanea`, `nombre_estado`, `casilla_a_lista`), `pruebas/azar/test_generador_azar.gd`, `pruebas/combate/test_turno.gd`, `test_vida_cero.gd`, `ia/test_ia_salvaje.gd` (una línea cada uno: pasan `hambre.json`), `docs/PREGUNTAS.md`, `CLAUDE.md` (Estado actual).
- **Tests:** 12 nuevos (9 del criterio, el 18 adelantado, el rechazo de `float` en el registro y `derivado` en el generador); total 171, todos pasan (sí).
- **Criterio de terminado:** sesión 1 cumplida punto por punto. (1) El contexto de C lee semilla 33001, tipo, tablero 8 × 8, plantel, toggles y `golpe_inicial` vacío (en G, el id de la atacante). Dos contextos dan las mismas tiradas de combate y de textos, y las dos secuencias son distintas entre sí. `Danio.desde_datos(combate, {})` es `null`. (2) Prueba A: la Ocarra juega sola (origen `ia`) y el combate espera en `rodauva_1`. (3) Mover fuera de alcance, atacar fuera de alcance, atacar al Maestro y cualquier acción con el combate terminado no cambian `instantanea()`, el registro ni `acciones_jugador()`. (4) `contrato_victoria`: la Ocarra remata a la Rodauva; el Maestro va a [2,5] y la tumba (4); hay una sola línea `cierre` y es la última; la Rodauva se levanta con 1; `Plantel.cerrado`; después todo da `COMBATE_TERMINADO` y `resultado()` es el mismo objeto. (5) `contrato_derrota`: la primera Ocarra remata al Maestro; el registro termina en `ataque`, `estado`, `fin`, `cierre`, con un solo `turno` y sin `fin_turno` ni `fin_ronda`. (6) Tribu en 0: `estado` (ronda 0) antes de la primera `ronda`. Maestro en 0: `inicio`, `estado`, `fin`, `cierre`, con 0 rondas y sin turno. Enemigas en 0: victoria con 0 rondas. (7) Ronda 1 de C: lista exacta de eventos; Tasajero `caza` (se mueve) y `cuenta` (se mueve y ataca al Maestro); `fin_turno` con la posición; `n` consecutivo; ningún `float`; la tirada hecha a mano queda justo antes de la `accion` de la Ocarra. (8) Dos combates de C con las mismas acciones dan `lineas_json()` idénticas. (9) Con `datos/`, los 11 escenarios llegan al turno del jugador sin error. El Maestro o una enemiga sin posición se rechazan; una guardada sin posición, no. (10) Los 159 anteriores pasan; sus números no cambian (la tribu y el Maestro de esos fixtures tienen hambre 3 y las enemigas no reciben Saciado, S-17).
- **Lecturas declaradas:** P-023 (el rechazo por `posicion: null` alcanza solo a las unidades del tablero; decidida con el usuario al aprobar el plan, pendiente del Arquitecto). Técnicas, sin pregunta: antes de la ronda 1, `VidaCero` mira solo a las sueltas (una guardada en 0 no está en juego, como en el `Cierre`); en el registro el Maestro va como `en_pie` / `caido`, los estados y desenlaces en minúsculas, las casillas como `[x, y]` o `null`, y la marca y el `paso` del jugador como `null`; cuando el combate termina a mitad de turno no se registran `fin_turno` ni `fin_ronda`; `inicio` lleva el id del escenario (la grabación lleva el escenario entero). "Una acción fuera de su turno" (test 3) se prueba con el combate terminado: con `Combate`, una acción solo puede llegar en el turno del jugador, y fuera de él se rechaza con `FUERA_DE_TURNO`.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** nueva P-023 (ARQUITECTO, no bloquea); cerradas P-011 a P-018 y P-020 a P-022 (`Sistema.md` v1.2, sin cambios de código). P-019 sigue `RESPONDIDA` (sesión 2).
- **Para la próxima sesión:** `ResultadoCombate` (desde el `Plantel` y el `ResultadoCierre`, validado contra `resultado.schema.json` revisado: estados `fuera` y `muerta`, campos futuros en `null` o lista vacía con `_nota`, `atacante_pendiente`); P-019 (motivo = clave de `lealtad.json` `eventos`; el +1 pasa de `combate.json` `lealtad_por_victoria` a `eventos.victoria` en esquemas, datos, fixtures y `Cierre`, con tabla de cotejo y un test que compara el `enum` con las claves); `HuellaDatos` en `nucleo/datos/` (que llena `ContextoCombate.huella`, hoy vacía en `inicio`); `Grabacion` y `grabacion.schema.json`; `Reproductor.reproducir(grabacion, datos, hasta_n)` sobre `acciones_jugador()` e `instantanea()`; `herramientas/reproducir.gd` y su comando en `CLAUDE.md`; tests 11 a 17. `Combate.resultado()` pasa a devolver el `ResultadoCombate`.

## T12 · sesión 2 · 04/10/2026
- **Rama:** tarea/T12-contrato
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:** contrato del combate entero (`Arquitectura.md` A.7), en dos sesiones. **Sesión 1:** `ContextoCombate.armar(escenario, datos)` (tipo, semilla, `Tablero`, `Plantel`, `golpe_inicial` leído sin resolver, toggles, `Danio`, `Relaciones`, `Cierre`, generadores de combate y de textos con `GeneradorAzar.derivado`; rechazo `DESPLIEGUE_NO_IMPLEMENTADO` solo para las unidades del tablero, P-023); `Combate.empezar(contexto)`, el bucle (punto vacío del golpe inicial, `VidaCero` y `FinCombate` antes de la ronda 1, IA de las enemigas, se detiene en cada turno del jugador, corte por `FinCombate`, `Cierre` una sola vez, `error()` si la IA falla); `RegistroCombate` (una línea por evento con `n` y `ronda`, claves ordenadas, rechaza `float`; eventos `inicio`, `ronda`, `turno`, `accion`, `movimiento`, `ataque`, `estado`, `tirada`, `fin_turno`, `fin_ronda`, `fin`, `cierre`); `Danio.desde_datos` exige la tabla de hambre; `Accion` ↔ diccionario; `Plantel.instantanea()` y `Combate.instantanea()`. **Sesión 2:** P-019 en el orden pedido: esquemas (`lealtad.schema.json` con `eventos.victoria` obligatorio; `combate.schema.json` sin `lealtad_por_victoria`; `resultado.schema.json` con el `enum` de motivos = claves de `eventos`) → datos (`tablas/lealtad.json` suma `victoria: 1`; `tablas/combate.json` pierde `lealtad_por_victoria` y su mención en la `_nota`) → fixtures (las mismas dos copias) → `Cierre` (lee el +1 de `eventos.victoria`). `resultado.schema.json` revisado: `desenlace` con los nombres de `FinCombate` (`derrota_por_caida`), `maestro_caido`, `maestro` (`vida`, `posicion`, `hambre`; `mana` en null hasta T21), `unidades` con `estado` (`suelta`, `guardada`, `caida`, `fuera`, `muerta`), vida, lealtad (null en las enemigas) y posición, `levantadas`, `muertas`, `lealtad_cambios` (antes, cambio, después y anotaciones con motivo), `pergaminos` (en blanco y ardidos, por id de pergamino) y `atacante_pendiente`. En null o lista vacía, con su `description` diciendo qué tarea los llena: `rescatista` y `permadeath` (T29), `capturas` (T24, T30), `metricas` (T23, T33). `ResultadoCombate.armar(...)` y `a_diccionario()`; `Combate.resultado()` lo devuelve, y el evento `cierre` usa la misma conversión de lealtad (la criatura de cada cambio pasa de `criatura` a `id`). `HuellaDatos.calcular(datos)` en `nucleo/datos/`: SHA-256 hex de `JSON.stringify` con claves ordenadas, sin `textos/`, sin `_nota` ni `$schema` a ninguna profundidad; la llena `ContextoCombate` (va en `inicio`). `grabacion.schema.json` reescrito (`version`, `escenario` entero vía `$ref` a `escenario.schema.json`, `huella`, `acciones` `{unidad, accion}` con los 4 tipos de `Accion` de hoy) y `Grabacion` (`FORMATO = 1`, `desde_combate`, `a_diccionario`, `desde_diccionario`); `ContextoCombate.escenario` guarda una copia del escenario tal como se jugó. `Reproductor.reproducir(grabacion, datos, hasta_n)`: avisa si la huella no coincide y sigue; se detiene con error (y `accion_con_error` = N) si el combate no espera al jugador o si la acción es de otra unidad, ilegible o rechazada; pedir más acciones de las que hay es un error. `herramientas/reproducir.gd` (por consola, escribe `registros/<nombre>.jsonl`), probado a mano con una grabación de `contrato_victoria` contra `datos/`: avisó por la huella y escribió el registro completo y el de `hasta_1`.
- **Archivos:** creados `nucleo/combate/contexto_combate.gd`, `combate.gd`, `registro_combate.gd`, `resultado_combate.gd`, `grabacion.gd`, `reproductor.gd`, `nucleo/datos/huella_datos.gd`, `herramientas/reproducir.gd`, `pruebas/combate/test_combate.gd`, `test_contrato.gd`, `datos_fixture.gd`, `pruebas/datos/test_huella_datos.gd`, `pruebas/fixtures/combate/contrato/contrato_victoria.json` y `contrato_derrota.json`; modificados `datos/_esquemas/lealtad.schema.json`, `combate.schema.json`, `resultado.schema.json`, `grabacion.schema.json`, `datos/tablas/lealtad.json`, `datos/tablas/combate.json`, `pruebas/fixtures/unidades/lealtad.json`, `pruebas/fixtures/combate/combate.json`, `nucleo/combate/cierre.gd`, `nucleo/azar/generador_azar.gd`, `nucleo/combate/danio.gd`, `accion.gd`, `resultado_accion.gd`, `turno.gd`, `desglose_danio.gd`, `modificador_danio.gd`, `cola_iniciativa.gd`, `nucleo/unidades/plantel.gd`, `pruebas/azar/test_generador_azar.gd`, `pruebas/combate/test_turno.gd`, `test_vida_cero.gd`, `ia/test_ia_salvaje.gd`, `docs/PREGUNTAS.md`, `CLAUDE.md` (Estado actual).
- **Tests:** 20 nuevos en la tarea (sesión 1: 12; sesión 2: 8, los 11 a 17 con el 16 en dos partes); total 179, todos pasan (sí). En la sesión 2, los tests 4 y 5 de `test_combate.gd` leen el nuevo tipo de `resultado()` con las mismas comprobaciones.
- **Criterio de terminado:** cumplido punto por punto. (1) a (10) y (18): ver T12 · sesión 1. (11) Victoria de `contrato_victoria` con una Surcón guardada: valida contra el esquema; la Rodauva queda suelta con 1 y pasa de 5 a 6 (`victoria`); la guardada no cambia; la Ocarra queda `fuera`, sin lealtad ni posición; los campos futuros, en null o vacíos. Derrota de `contrato_derrota` con la Rodauva en 0: valida, la Rodauva queda `muerta`, `pergamino_1` ardido, `maestro_caido`. G con la atacante en 0: victoria con 0 rondas y `atacante_pendiente = "ocarra_1"`. (12) El `enum` de motivos es igual a las claves y al `required` de `eventos` en `lealtad.schema.json`; el fixture de combate no tiene `lealtad_por_victoria`; con `eventos.victoria = 3`, la Rodauva gana 3; el test permanente de datos pasa. (13) La grabación valida, trae el escenario igual al original (y no cambia si se edita el diccionario después de armar), la huella del contexto (64 hex) y las dos acciones del Maestro; una acción con un campo de más no valida. (14) Reproducir da `lineas_json()` idénticas en `contrato_victoria` (también tras pasar la grabación por texto JSON y el esquema) y en C. (15) C jugado dos rondas (más de 3 acciones): reproducir hasta 0, 1, la del medio y la última da la misma `instantanea` y el mismo registro que en vivo; pedir una de más es error. (16) Cambiar `danio_minimo` cambia la huella; cambiar o borrar una `_nota`, cambiar `$schema` o agregar o cambiar `textos/es.json` no; el orden de las claves no importa. Con otra huella en la grabación, el reproductor avisa y llega a la misma `instantanea` y el mismo registro. (17) Un movimiento imposible en la acción 2 detiene con `accion_con_error = 2` y el estado de N = 1; una acción de otra unidad en la 1, con el de N = 0.
- **Lecturas declaradas:** P-023 (respondida, opción A, ya programada). Sesión 2, sin pregunta: la huella incluye `escenarios/` (A.7 solo excluye `textos/`, `_nota` y `$schema`; editar un escenario hace que toda grabación avise, aunque igual se reproduce); `atacante_pendiente` es la atacante nocturna `caida` al terminar, sea cual sea el desenlace (literal de B.2). Técnicas: `desenlace` con los nombres de `FinCombate` y del registro (`derrota_por_caida`); `ardidos` por id de pergamino; la lealtad de las enemigas, en null; la "_nota" de cada campo futuro va en su `description` (el validador no admite `_nota` dentro de un esquema); el esquema de la grabación trae a su `$defs` las dos definiciones locales del escenario (`criatura_tribu`, `enemiga`), porque el validador busca las referencias locales en la raíz: no se tocaron el validador ni el cargador. Las de la sesión 1 siguen igual.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** nuevas: ninguna en la sesión 2 (P-023 en la sesión 1). Cerradas: P-011 a P-018 y P-020 a P-022 (sesión 1), P-019 y P-023 (sesión 2).
- **Para la próxima sesión:** nada: tarea terminada.

## T12 · ajustes · 04/10/2026
- **Rama:** tarea/T12-ajustes
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:** dos correcciones chicas a T12, ya mergeada. (1) `HuellaDatos.calcular` excluye `escenarios/` además de `textos/`, `_nota` y `$schema` (`Arquitectura.md` v0.19, A.7, "Huella de los datos"). Motivo: la grabación lleva su escenario entero. (2) S-20 de `Arquitectura.md` 10.5 registrada para Sistemas como P-024, sin cambiar la regla. En `ResultadoCombate.armar`, el comentario donde se decide `atacante_pendiente` remite a P-024 y S-20.
- **Archivos:** modificados `nucleo/datos/huella_datos.gd`, `nucleo/combate/resultado_combate.gd` (solo un comentario), `pruebas/datos/test_huella_datos.gd`, `docs/PREGUNTAS.md`, `CLAUDE.md` (Estado actual).
- **Tests:** 0 nuevos (se sumó un caso dentro del test 16); total 179, todos pasan (sí).
- **Criterio de terminado:** cumplido punto por punto. (1) Rama `tarea/T12-ajustes` desde `develop`. (2) Test 16: con `escenario_c.json` agregado como `escenarios/c_tasajero.json`, la huella es la misma que sin él, y cambiar su `semilla` (33001 → 33002) no la cambia. Los casos anteriores siguen igual, incluido "cambiar `danio_minimo` cambia la huella". (3) P-024 registrada. El comentario en `ResultadoCombate` cambió y la lógica no. (4) 179/179.
- **Corrige:** T12 · sesión 2, Lecturas declaradas: "la huella incluye `escenarios/`" ya no vale. Desde A.7 v0.19 la excluye.
- **Lecturas declaradas:** P-024 / S-20: `atacante_pendiente` es la atacante nocturna `caida` al terminar, sea cual sea el desenlace (lectura literal, ya programada en T12). El test 11 la cubre solo en una victoria (caso G). Ningún test arma una derrota con la atacante caída.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** nueva P-024 (SISTEMAS, no bloquea; se necesita antes de T30). Cerradas: ninguna.
- **Para la próxima sesión:** nada: tarea terminada.

## T34 · sesión 1 · 04/10/2026
- **Rama:** tarea/T34-textos
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:** armador de textos en `nucleo/textos/`, sin nodos (`Arquitectura.md` A.2.1, A.8, B.2; `Mundo.md` 1.5). `ArmadorTextos.desde_datos(textos, generador)` recibe `textos/es.json` con la forma del `Cargador` y el generador de textos (`ContextoCombate.azar_textos`). `armar(clave, datos, sujeto)` devuelve el texto y `armar_lineas` la lista de líneas (base y complemento); `armar` las une con `\n`. **Huecos:** un `HuecoCriatura` (id de especie) llena las seis formas de su rol (`{rol}`, `{a_rol}`, `{de_rol}`, `{rol_o}`, `{rol_la}`, `{rol_ella}`). Se arman una sola vez por especie desde `especie.<id>.articulo` y `especie.<id>.nombre`, con las contracciones al / del. Cualquier otro valor va literal. **Variantes:** `<clave>.<sujeto>` reemplaza a la base. Si la clave empieza con un prefijo de `PREFIJOS_COMPLEMENTO` (`caida.`, `nocturno.base.`, `nocturno.raso.`), la base va siempre y la variante va después, en otra línea. Una lista se elige con el generador de textos; un texto suelto no tira. **Mayúsculas:** la primera letra del texto y la primera después de `. ? ! ¿ ¡` (salteando espacios, saltos y signos de apertura) suben, también con tilde. **Lo que falta no rompe:** `[FALTA: clave]` y `[FALTA: hueco]`, cada uno con un aviso en `avisos()` (clave, hueco, motivo), sin `push_error`. **Revisión estática:** `ArmadorTextos.revisar(textos)` avisa de huecos mal formados (mayúsculas o espacios entre llaves), llaves sin cerrar y corchetes sin convertir; no revisa `$schema` ni `_nota`. Sobre `datos/textos/es.json` da **0 avisos**: no hizo falta una pregunta para el Worldbuilder.
- **Archivos:** creados `nucleo/textos/armador_textos.gd`, `nucleo/textos/hueco_criatura.gd`, `pruebas/textos/test_armador_textos.gd`, `pruebas/fixtures/textos/es.json` (copias textuales de `datos/textos/es.json` y dos claves `prueba.*` de prueba, que no son del jugador) y `pruebas/fixtures/textos/es_mal_formado.json`; modificados `CLAUDE.md` (Estado actual) y `docs/RESUMENES.md`.
- **Tests:** 11 nuevos; total 190, todos pasan (sí).
- **Criterio de terminado:** cumplido punto por punto. (1) `comer.elegir` ("¿{criatura}?") con la Rodauva → "¿La Rodauva?". (2) Con el Surcón: "al Surcón", "del Surcón", "flaco", "lo", "él". Con la Rodauva: "a la Rodauva", "de la Rodauva", "flaca", "la", "ella". Y `incidente.distraida` → "La Ocarra no le saca el ojo al Surcón. Se le va el turno mirándolo.". (3) "Él cae. Él se levanta. ¡Él sigue, y la Rodauva no!": la mayúscula sube al empezar, después de ". " y de "¡", con tilde; el resto queda igual. (4) `hambre.estado.famelico` da "Famélico" con `maestro` y "Famélica" con `rodauva` o sin sujeto; `sellar.fallo` con `surcon` da la variante y con `rodauva` la base. (5) `caida` con la Rodauva da dos líneas (base y `caida.rodauva`) unidas por `\n` en `armar`; con el Tasajero, solo la base. La lista de prefijos es la de A.2.1. (6) Clave inexistente → `[FALTA: no.existe]` y aviso `CLAVE_FALTANTE`; sin `rival` → `[FALTA: a_rival]` y `[FALTA: rival_o]` con dos avisos `HUECO_SIN_DATO`; una forma sobre un literal → aviso `HUECO_NO_ES_CRIATURA`. (7) `noche.molino`, 20 pedidos: misma semilla → misma secuencia; otra semilla → otra; siempre una de las 3. (8) Intercalar textos sueltos no cambia las elecciones, y el historial del generador tiene 20 tiradas en los dos casos. (9) `revisar` avisa de `{Criatura}`, `{ criatura }`, `{Rival}` (dentro de una lista), `[Criatura]` y `{criatura` sin cerrar; la clave correcta y la `_nota` no dan aviso; el fixture correcto, ninguno. (10) `sellar.tooltip` con 40 → "40% de que el hilo la sujete. Si se suelta, el maná se pierde igual.". (11) Una ronda de C jugada dos veces, una armando textos con `azar_textos` entre acción y acción: registro (`lineas_json`) e `instantanea` idénticos; el generador de textos tiró y el del otro combate no.
- **Lecturas declaradas:** ninguna de reglas. Técnicas: una lista de 1 elemento también tira (es lista); una variante del sujeto que existe se usa aunque falte la base; las mayúsculas se aplican a cada línea por separado, después de llenar los huecos; si lo primero después de un signo es un número, no sube nada; un artículo que no sea `el` ni `la`, o una especie sin `articulo` o sin `nombre`, da `[FALTA: especie.<id>.articulo]` (o `.nombre`) con aviso `ESPECIE_SIN_TEXTO`; `{duracion}` todavía es un hueco más sin dato (0b).
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** ninguna nueva; cerradas: ninguna. Las `RESPONDIDA` (P-002, P-003, P-008) no son de T34.
- **Para la próxima sesión:** nada: tarea terminada.

## T13 · sesión 1 · 05/10/2026
- **Rama:** tarea/T13-pantalla
- **Estado:** EN CURSO (sigue en la sesión 2)
- **Hecho:** arranque, tablero y lectura del combate, sin interacción de juego (`Arquitectura.md` B.2, A.2.1, A.3, A.6).
  - **Núcleo** (consultas que faltaban para mostrar sin calcular):
    - `Combate.cola()` (la cola de la ronda en curso) y `Combate.entrada_actual()` (su índice, o −1).
    - `EstadosUnidad` en `nucleo/unidades/`: `hambre(valor)` da el id del tramo de `hambre.json` (7.1); `lealtad(valor, umbral)` da desleal, dudosa, neutral o leal (5.1), con el umbral de `fila_balanza()`. `fila_hambre` es estática y ahora la usa también `Danio`, así la búsqueda del tramo vive en un solo lugar.
  - **Pantalla** (`pantalla/`):
    - `principal.tscn` (`Principal`) toma la carpeta del `@export`, de `-- --datos=<carpeta>` (`ArgumentosPantalla`) o, si no hay ninguna, de `res://datos`. Carga en dos pasos: la segunda carga le pasa al `Cargador` `ClavesTextos.usadas(datos)`, que son las constantes más `especie.<id>.nombre` por especie y `hambre.estado.<id>` por estado de hambre.
    - Con un error, muestra solo la pantalla de error (archivo · campo · esperado · recibido) y no arranca.
    - Los avisos van a la consola (las claves faltantes una por una; las sobrantes, solo la cantidad) y al panel de depuración.
    - El selector muestra un botón por `id` de escenario.
    - `combate/vista_combate.tscn` (`VistaCombate`) arma el `ContextoCombate` y el `Combate` (la IA juega hasta el primer turno del jugador), el `ArmadorTextos` con `azar_textos` y `EstadosUnidad`. Se redibuja entera desde `LecturaCombate`, una clase sin nodos que lee `instantanea()`, la cola y el `Plantel` y pide los textos a T34.
    - El tablero es un `TileMapLayer` con el tileset placeholder `casillas_cenital.tres` (damero de dos tiles). Las fichas son hijas del `TileMapLayer` y van en `map_to_local(casilla)`. La cámara se centra con `map_to_local` de las esquinas.
    - `FichaUnidad`: círculo con el color del bando (gris si está caída), aro dorado si es el Maestro, nombre, vida `actual/máx` y marcas (caída, erizada).
    - Interfaz: ronda, cola de la ronda (con Caza y Cuenta, la entrada actual resaltada y las ya jugadas en gris) y panel de la unidad del turno (nombre, vida, lealtad con su estado y hambre con su estado; el Maestro usa la variante `.maestro`).
    - Panel de depuración, oculto: registro crudo y avisos de la carga y del armador. Se abre con la acción `depuracion` (F3) del InputMap.
    - `run/main_scene` apunta a `principal.tscn`.
- **Archivos:**
  - Creados en el núcleo: `nucleo/unidades/estados_unidad.gd`.
  - Creados en la pantalla: `pantalla/principal.tscn`, `principal.gd`, `argumentos.gd`, `claves_textos.gd`, `pantalla/combate/vista_combate.tscn`, `vista_combate.gd`, `ficha_unidad.tscn`, `ficha_unidad.gd`, `lectura_combate.gd`, `casillas_cenital.tres`, `casilla_placeholder.svg`, `figura_placeholder.svg` y `aro_placeholder.svg`.
  - Creados en las pruebas: `pruebas/pantalla/test_principal.gd`, `test_vista_combate.gd`, `test_lectura_combate.gd`, `test_argumentos.gd`, `test_claves_textos.gd`, `pruebas/unidades/test_estados_unidad.gd`, `pruebas/fixtures/pantalla/es.json` (copias textuales de `datos/textos/es.json`) y `pruebas/fixtures/pantalla/textos_incompletos/` (esquema copiado de un fixture del cargador + un `es.json` sin `iniciativa.caza`).
  - Modificados: `nucleo/combate/combate.gd`, `nucleo/combate/danio.gd`, `pruebas/combate/test_combate.gd`, `project.godot` (escena principal y acción `depuracion`), `CLAUDE.md` (Estado actual).
- **Tests:** 16 nuevos, total 206, todos pasan (sí).
  - 13 de pantalla: los 6 del criterio, distribuidos en 5 funciones, y 8 sin nodos.
  - 3 del núcleo: cola y entrada actual, estados de hambre y estados de lealtad.
  - Los tests de escenas usan `scene_runner(auto_free(escena.instantiate()))`, porque con una instancia el runner no la libera: sin `auto_free` quedaban nodos huérfanos y GdUnit4 salía con 101.
- **Criterio de terminado:** sesión 1 cumplida punto por punto.
  - (1) Con `pruebas/fixtures/cargador/un_error_ningun_dato`, la pantalla de error es visible y muestra `especies/rodauva.json` y `vida`; el selector está oculto y no hay vista.
  - (2) Con `res://datos`: sin errores, sin pantalla de error y 11 botones con los `id` de los escenarios, en orden.
  - (3) Los 11 escenarios reales crean su vista: combate sin error, `esperando_jugador()` verdadero y ningún mensaje.
  - (4) En los 11, cada ficha está en `map_to_local` de su casilla de `instantanea()`, `local_to_map` de su posición da la casilla, y hay una ficha por unidad de pie o caída con posición.
  - (5) Con `textos_incompletos`, los avisos traen `iniciativa.caza` (y `maestro.nombre`) como «presente en el archivo», pero no `iniciativa.cuenta`, que sí está. El juego arranca igual.
  - (6) En C, las filas de la cola coinciden entrada por entrada con `combate().cola()` (unidad y marca), la resaltada es `entrada_actual()`, y las filas de Caza y Cuenta dicen "Caza" y "Cuenta".
  - Faltan los tests 7 a 10 y la lista manual (sesión 2).
- **Lecturas declaradas:** ninguna de reglas.
  - Panel: muestra número **y** estado de lealtad y de hambre (B.2 dice "vida, lealtad, hambre"; ningún documento dice que el número se oculte). El hambre de una criatura se pide con su especie como sujeto, y como `es.json` no tiene `hambre.estado.<x>.surcon`, el Surcón sale "Saciada" (base). Es contenido del Worldbuilder, no se tocó.
  - Dos unidades de la misma especie se ven con el mismo nombre (sus `id` están en el panel de depuración).
  - Las unidades sin posición o fuera del tablero no se dibujan.
  - `rasgo.erizarse.nombre` no se reutiliza como marca: nombra la acción, no el estado.
  - Colores, tamaños y la marca `> ` de la entrada actual son de presentación.
- **Claves de texto nuevas sin texto** (se ven como `[FALTA: …]`; nombres propuestos, para el Worldbuilder):
  - `maestro.nombre`: nombre del Maestro en la ficha, la cola y el panel.
  - `combate.ronda`: "Ronda {n}", con `{n}` literal.
  - `iniciativa.titulo`: título de la cola.
  - `panel.vida`, `panel.lealtad`, `panel.hambre`: etiquetas del panel del turno.
  - `marca.caida`, `marca.erizada`: marcas sobre la ficha.
- **Preguntas:** ninguna nueva; cerradas: ninguna. P-024 sigue ABIERTA (no es de T13). P-002, P-003 y P-008 siguen RESPONDIDA (son de T30, T14 y T19).
- **Para la próxima sesión** (tests 7 a 10 y la lista de prueba manual en el resumen final):
  - `pantalla/combate/interprete_clic.gd` (RefCounted, con tests: casilla alcanzable → `mover`; objetivo atacable → `atacar`; cualquier otra → nada).
  - Botones Erizarse (con `puede_erizarse`) y Esperar / Terminar turno.
  - Marcar `casillas_para_mover` y `objetivos_para_atacar`; desglose de `previsualizar_ataque` con el mouse sobre una objetivo.
  - Mostrar lo nuevo del registro después de los turnos de la IA.
  - Pantalla de resultado desde `ResultadoCombate.a_diccionario()`.
  - Guardar sola la grabación (`.json`) y el registro (`.jsonl`) en `registros/<escenario>_<semilla>_<n>`.
  - Acción `recargar` en el InputMap: recarga los datos del disco y reinicia el escenario.

## T13 · sesión 2 · 05/10/2026
- **Rama:** tarea/T13-pantalla
- **Estado:** TERMINADA (pendiente de PR). Esta entrada resume la tarea entera (sesiones 1 y 2).
- **Hecho:** pantalla cenital con placeholders en `pantalla/`, la primera tarea con nodos (`Arquitectura.md` B.2, A.2.1, A.3, A.6, A.7). La pantalla no calcula ninguna regla: lee el núcleo, le manda `Accion` y se redibuja entera después de cada cambio.
  - **Núcleo (sesión 1)** — consultas que faltaban para mostrar sin calcular:
    - `Combate.cola()` y `Combate.entrada_actual()`.
    - `EstadosUnidad`: `hambre(valor)` (7.1) y `lealtad(valor, umbral)` (5.1). `fila_hambre` también la usa `Danio`.
    - En la sesión 2 no hizo falta ninguna consulta nueva.
  - **Arranque (sesión 1)** — `principal.tscn`:
    - La carpeta de datos sale de `@export`, de `-- --datos=` o de `res://datos`. Carga en dos pasos, pasando `ClavesTextos.usadas(datos)`.
    - Con un error, solo se ve la pantalla de error. Los avisos van a la consola y al panel de depuración.
    - El selector muestra un botón por `id` de escenario.
  - **Tablero y lectura (sesión 1)** — `vista_combate.tscn`:
    - `TileMapLayer` con damero placeholder. Las fichas van en `map_to_local`.
    - Interfaz: cola de la ronda (con Caza y Cuenta), ronda y panel de la unidad del turno.
    - Panel de depuración (F3).
    - `LecturaCombate`, sin nodos, traduce el estado en lo que se dibuja y pide los textos al `ArmadorTextos`.
  - **Jugar (sesión 2):**
    - `InterpreteClic` (RefCounted): casilla con una objetivo de `objetivos_para_atacar()` → `atacar`; casilla de `casillas_para_mover()` → `mover`; cualquier otra → nada. Las posiciones salen de `instantanea()`.
    - El clic es la acción `seleccionar` del InputMap (clic izquierdo).
    - Botones:
      - El del rasgo (nombre y tooltip del rasgo de la ficha) se ve solo si `puede_erizarse()`.
      - Esperar / Terminar turno manda `terminar`. Dice "Esperar" si la acción no se usó (P-015) y "Terminar turno" si se usó.
    - Marcas en una capa `Marcas` del mismo tileset, solo en el turno del jugador: azul en `casillas_para_mover`, rojo en las casillas de `objetivos_para_atacar`.
    - Con el mouse sobre una objetivo atacable, el panel muestra el desglose de `previsualizar_ataque` desde la casilla actual: base, cada modificador con su fuente, total y si actuó el mínimo.
  - **Sucesos (sesión 2):** después de cada cambio, lo nuevo del registro pasa a un panel con las últimas 12 líneas.
    - Movimiento, ataque (con el daño y la vida antes → después) y Erizarse.
    - Caída (`caida` con su complemento de especie), Maestro caído (`maestro.caida`) y salida del tablero.
    - Victoria (`combate.victoria`) y, del cierre, levantadas (`caida.levantarse`) y muertas.
    - Tiradas, turnos y rondas no se muestran: están en el panel de depuración.
  - **Fin (sesión 2):**
    - Pantalla de resultado desde `ResultadoCombate.a_diccionario()`: desenlace, rondas, estado final del Maestro y de cada unidad, y cambios de lealtad (antes → después, con cada anotación y su motivo).
    - Su botón vuelve al selector.
    - Al terminar, `GuardadoCombate` guarda solos la grabación (`.json`) y el registro (`.jsonl`) en `registros/<escenario>_<semilla>_<n>`, con `n` el primer número libre.
  - **Recarga (sesión 2):** la acción `recargar` (tecla R) vuelve a leer la carpeta de datos.
    - Con un error, saca la vista y muestra la pantalla de error.
    - Si no, reinicia el escenario abierto, o vuelve al selector si no había ninguno.
    - Después de una pantalla de error, otra R con los datos arreglados vuelve al escenario.
- **Archivos:**
  - **Sesión 1:**
    - Creados en el núcleo: `nucleo/unidades/estados_unidad.gd`.
    - Creados en la pantalla: `pantalla/principal.tscn`, `principal.gd`, `argumentos.gd`, `claves_textos.gd`, `pantalla/combate/vista_combate.tscn`, `vista_combate.gd`, `ficha_unidad.tscn`, `ficha_unidad.gd`, `lectura_combate.gd`, `casillas_cenital.tres`, `casilla_placeholder.svg`, `figura_placeholder.svg` y `aro_placeholder.svg`.
    - Creados en las pruebas: `pruebas/pantalla/test_principal.gd`, `test_vista_combate.gd`, `test_lectura_combate.gd`, `test_argumentos.gd`, `test_claves_textos.gd`, `pruebas/unidades/test_estados_unidad.gd`, `pruebas/fixtures/pantalla/es.json` y `pruebas/fixtures/pantalla/textos_incompletos/`.
    - Modificados: `nucleo/combate/combate.gd`, `nucleo/combate/danio.gd`, `pruebas/combate/test_combate.gd` y `project.godot`.
  - **Sesión 2:**
    - Creados en la pantalla: `pantalla/combate/interprete_clic.gd`, `guardado_combate.gd` y `marcas_placeholder.svg`.
    - Creados en las pruebas: `pruebas/pantalla/test_interprete_clic.gd` y `test_guardado_combate.gd`.
    - Modificados: `pantalla/principal.gd`, `principal.tscn` (`mouse_filter`), `claves_textos.gd`, `pantalla/combate/vista_combate.gd`, `vista_combate.tscn`, `lectura_combate.gd`, `casillas_cenital.tres`, `project.godot` (acciones `recargar` y `seleccionar`), `pruebas/pantalla/test_principal.gd`, `test_vista_combate.gd`, `test_lectura_combate.gd`, `test_claves_textos.gd` y `pruebas/fixtures/pantalla/es.json` (más copias textuales de `datos/textos/es.json`).
  - En las dos sesiones: `CLAUDE.md` (Estado actual) y `docs/RESUMENES.md`.
- **Tests:** 29 nuevos en la tarea (16 en la sesión 1 y 13 en la 2). Total 219, todos pasan (sí).
  - Sesión 2: 4 del intérprete, 2 del guardado, 2 de la vista (8 y 9), 2 de la principal (10, y un clic de mouse real que mueve a la unidad) y 3 de `LecturaCombate` (sucesos, desglose y resultado).
  - El test del clic real encontró un error: `Principal` (un `Control` de pantalla completa) y los contenedores de la cola y los botones se comían el clic antes del `_unhandled_input` de la vista. Ahora tienen `mouse_filter` IGNORE.
  - También se probó a mano el paso 6 de la lista manual: A jugado por consola y guardado con `GuardadoCombate` en `registros/`; la copia se reprodujo con `herramientas/reproducir.gd` y dio un `.jsonl` idéntico byte por byte. Después se borró `registros/`.
- **Criterio de terminado:** cumplido punto por punto.
  - (1) Con datos rotos se ve la pantalla de error con archivo y campo, sin selector.
  - (2) Con `datos/` arranca sin errores y lista los 11 escenarios.
  - (3) Los 11 crean su vista y esperan al jugador.
  - (4) Cada ficha está en `map_to_local` de su casilla, y `local_to_map` de su posición da la casilla.
  - (5) Una clave que falta en un fixture de textos aparece como aviso.
  - (6) La cola mostrada coincide con la del combate, entrada por entrada.
  - (7) Intérprete con `escenario_turno.json` (fixtures):
    - casilla alcanzable → `mover` a esa casilla;
    - la Ocarra salvaje adyacente → `atacar` con su id;
    - la Rodauva aliada, una casilla lejana, `[-1, 0]` y `[8, 8]` → nada;
    - después de mover, una casilla vacía → nada (y la objetivo sigue dando `atacar`).
  - (8) En A, el desglose mostrado con `sobre_casilla` es igual, diccionario completo, al `desglose` del evento `ataque` del registro al golpear.
  - (9) A jugado hasta el final solo con `clic_casilla` y `pulsar_terminar`:
    - se guardaron `a_dia_1_12345_1.json` y `.jsonl`, y la grabación valida contra `grabacion.schema.json`;
    - el `.jsonl` es igual a `lineas_json()`, y `Reproductor.reproducir` da las mismas líneas, sin aviso de huella;
    - la pantalla de resultado es visible.
  - (10) Sobre una copia de `datos/`:
    - con la `vida` de la Ocarra +1 en el archivo, `recargar()` reinicia A con `vida_max_real()` +1, en otra vista y esperando al jugador;
    - con `"vida": "x"`, muestra la pantalla de error con `especies/ocarra.json`, sin selector y sin vista.
- **Lecturas declaradas:** ninguna de reglas. Técnicas y de presentación:
  - El test (10) usa una copia temporal de `datos/` y no "una copia de fixtures" (B.2), porque no hay una carpeta de fixtures completa (escenarios, textos y todos los esquemas) y armarla duplicaría los esquemas. El test no depende de ningún número: lee el valor y le suma 1.
  - Los textos de sucesos, desglose y resultado viven en `LecturaCombate` y no en una clase `TextosCombate` aparte, como decía el plan: es la misma función (traducir el estado en lo que se dibuja).
  - Los sucesos de movimiento, ataque y Erizarse se arman como "nombre · acción" con claves que ya existen (`accion.mover`, `accion.atacar`, el nombre del rasgo), más los números del registro. Son las mismas cuentas del registro, no prosa nueva.
  - El desglose nombra las fuentes con textos que ya existen: hambre con `hambre.estado.<id>` (con el sujeto de la atacante), enfermedad con `enfermo.nombre` y rasgos con `rasgo.<id>.nombre`. Las demás fuentes (combo, afinidad, Encono, cobardía) tienen clave propia.
  - Las marcas, los colores, el máximo de 12 líneas de sucesos, la tecla R y el formato "antes → después" son presentación.
  - Una partida que termina con error del combate no se guarda: solo se guarda al terminar.
- **Claves de texto nuevas sin texto** (se ven como `[FALTA: …]`; nombres propuestos, para el Worldbuilder):
  - **Sesión 1:**
    - `maestro.nombre`, `combate.ronda` (`{n}`) e `iniciativa.titulo`;
    - `panel.vida`, `panel.lealtad` y `panel.hambre`;
    - `marca.caida` y `marca.erizada`.
  - **Sesión 2:**
    - `accion.terminar`: botón "Terminar turno" cuando la acción ya se usó.
    - `marca.fuera`: suceso de una salvaje que sale del tablero.
    - `desglose.base`, `desglose.total` y `desglose.minimo`; `desglose.fuente.combo`, `desglose.fuente.afinidad`, `desglose.fuente.encono` y `desglose.fuente.cobardia` (no aparecen en 0a.1).
    - `resultado.titulo`, `resultado.rondas`, `resultado.lealtad` y `resultado.volver`; `resultado.desenlace.victoria` y `resultado.desenlace.derrota_por_caida`.
    - `estado.suelta`, `estado.guardada`, `estado.caida`, `estado.fuera` y `estado.muerta`.
    - `lealtad.motivo.<evento>`, una por clave de `tablas/lealtad.json` `eventos`: `victoria`, `muerte_en_el_grupo`, `muerte_en_el_grupo_afines`, `rescate`, `perdon_a_leales` y `comer_atacante`.
  - Ya existían y se usan: `accion.mover`, `accion.atacar`, `accion.esperar`, `rasgo.<id>.nombre`, `rasgo.<id>.tooltip`, `caida` (y `caida.<especie>`), `caida.levantarse`, `maestro.caida`, `combate.victoria` y `enfermo.nombre`.
- **Preguntas:** ninguna nueva; cerradas: ninguna. P-024 sigue ABIERTA (no es de T13). P-002, P-003 y P-008 siguen RESPONDIDA (son de T30, T14 y T19).
- **Prueba manual del usuario** (cierra el hito 0a.1). Los comandos son para `cmd`; en PowerShell, `& $env:GODOT_BIN` en lugar de `"%GODOT_BIN%"`.
  1. **Abrir:** F5 en el editor (o `"%GODOT_BIN%" --path .`). Se ve el selector con los 11 escenarios. En la consola solo hay avisos `[textos] falta la clave …`, ningún error.
  2. **A, victoria:** `a_dia_1`.
     - En cada turno del jugador: las casillas azules son a dónde puede moverse la unidad del turno, y las rojas, a quién puede atacar.
     - Clic en una azul para mover; con el mouse sobre una roja se ve el desglose a la derecha; clic en la roja para atacar.
     - "Esperar" o "Terminar turno" pasa el turno. Los turnos de la Ocarra se ven en los sucesos, abajo a la derecha.
     - Jugar hasta ganar. Comprobar que:
       - aparece la pantalla de resultado (desenlace, rondas, unidades y lealtad con su motivo: +1 por la victoria);
       - la consola dice `[registros] guardado: …/registros/a_dia_1_12345_1.json y .jsonl`.
  3. **A, derrota:** botón de volver → `a_dia_1` otra vez. Apretar "Esperar" en todos los turnos, sin mover ni atacar.
     - La Ocarra va por la Rodauva hasta tumbarla y después por el Maestro.
     - Al caer el Maestro: resultado de derrota, con la Rodauva muerta. Se guarda `a_dia_1_12345_2`.
  4. **B con Erizarse:** volver → `b_muro`.
     - En el turno de la Rodauva aparece el botón "Erizarse", con tooltip. Apretarlo: la ficha muestra la marca de erizada y desaparecen las casillas azules.
     - Jugar B hasta el final, ganando o perdiendo.
  5. **Recarga:** con A abierto y el juego corriendo, abrir `datos/especies/ocarra.json`, cambiar `"vida": 12` por `13` y guardar. Apretar R.
     - El escenario se reinicia y la Ocarra tiene 13 de vida.
     - Cambiar a `"vida": "x"`, guardar y apretar R: pantalla de error con `especies/ocarra.json · vida`.
     - Volver a `12`, guardar y apretar R: vuelve A.
     - Dejar el archivo como estaba (`git diff datos/` sin cambios).
  6. **Reproducir por consola** (desde la raíz del proyecto, en `cmd`):
     ```
     copy registros\a_dia_1_12345_1.json registros\copia.json
     "%GODOT_BIN%" --headless --path . --script res://herramientas/reproducir.gd -- res://registros/copia.json
     fc registros\a_dia_1_12345_1.jsonl registros\copia.jsonl
     ```
     - La herramienta imprime `Registro: …/registros/copia.jsonl`, sin `AVISO` de huella (si en el paso 5 los datos quedaron como estaban).
     - `fc` dice que no encontró diferencias.
     - La copia hace falta porque la herramienta escribe `registros/<nombre>.jsonl` y pisaría el registro que guardó la pantalla.
- **Para la próxima sesión:** nada: tarea terminada. Faltan la prueba manual del usuario, el PR y el cierre del hito 0a.1.

## T35 · sesión 1 · 06/10/2026
- **Rama:** tarea/T35-datos-v13
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:**
  - **Esquema `especie`** (A.2.2):
    - Sale `turnos` y entra `velocidad` (opcional en el esquema).
    - El rasgo pasa a `{id, efecto, parámetros}`, con el `enum` `erizarse`, `alabarda`, `surco`, `ocultarse` y `caza_y_cuenta`. Salen `ninguno`, `accion_defensa` (ahora `erizarse`), `reduccion_plana` y `primer_ataque`.
    - Parámetros: `erizarse` (`danio_recibido_pct`, `inmovil`, `umbral_vida_pct`), `surco` (`tope`), `ocultarse` (`bono_plano`) y `caza_y_cuenta` (`modo_inicial`, `umbral_cambio_pct`, `modos`).
    - `modos` es una lista en orden, de 2 o más elementos. Cada modo lleva `id`, `velocidad`, `ataques_por_turno`, `movimiento_partido`, `recibido_pct` y `danio_plano`.
  - **Cargador:** chequeo cruzado nuevo, `_chequear_rasgos`:
    - cada efecto trae sus parámetros y ninguno ajeno;
    - `velocidad` está si y solo si no hay `modos`;
    - el `modo_inicial` existe;
    - los ids de modo no se repiten.
    
    Las fichas sin `rasgo` (fixtures mínimas de T03) no se revisan.
  - **Datos v1.3:**
    - Surcón: vida 24, rasgo `surco` con tope 2.
    - Zancajunco: `ocultarse` +3.
    - Tasajero: daño 5, Caza y Cuenta.
    - Ocarra: `alabarda`.
    - Rodauva: `erizarse`.
    - Escenarios C y H: Tasajero en [3,1], y `_nota` del Tasajero y de la Rodauva al día con 11.2.3.
    - F: `_nota` según 11.9.
  - **Modelo:**
    - `Especie`: sale `turnos()`. Entran `modo_inicial()` y, por modo, `velocidad`, `ataques_por_turno`, `movimiento_partido`, `recibido_pct` y `danio_plano`. Sin modos responde la ficha y los valores neutros (1, false, 0, 0).
    - `Criatura.modo` arranca en el modo inicial (o `""`).
    - Sale `Criatura.ya_ataco`, también de la `instantanea`.
  - **Cola:** una entrada por unidad. La Velocidad y la marca salen de `criatura.modo` al armar la ronda, así que un cambio rige desde la ronda siguiente.
  - **`Danio`:**
    - Salen Lomo de tierra, el +2 de primer ataque y `registrar_ataque`.
    - Erizarse se reconoce por el efecto `erizarse`, igual que en `Turno` y en `IASalvaje`.
    - Queda el lugar comentado para los rasgos de la atacante (T36 y T38).
  - **Hasta T36**, el Tasajero juega su único turno con un ataque (`Turno` sin cambios).
- **Archivos:**
  - **Creados:** `pruebas/fixtures/cargador/rasgos/` (6 fichas con error y 2 válidas).
  - **Modificados:**
    - Datos: `datos/_esquemas/especie.schema.json`; `datos/especies/*.json` (las 5); `datos/escenarios/c_tasajero.json`, `h_soplo.json` y `f_rescate.json`.
    - Núcleo: `nucleo/datos/cargador.gd`; `nucleo/unidades/especie.gd`, `criatura.gd` y `plantel.gd`; `nucleo/combate/cola_iniciativa.gd`, `entrada_cola.gd`, `danio.gd`, `turno.gd` e `ia/ia_salvaje.gd`.
    - Fixtures: `pruebas/fixtures/unidades/` (las 5 especies); `pruebas/fixtures/combate/rodauva_velocidad_5.json`, `escenario_c.json`, `ia/ia_tasajero.json` e `ia/ia_junco.json`.
    - Tests: los de la lista "Tests reescritos o retirados".
- **Tests:** 5 nuevos, total 224, todos pasan (sí).
  - Nuevos: `test_cargador.gd` `test_rasgos_v13`; `test_cola_iniciativa.gd` `test_tasajero_en_cuenta_va_ultimo` y `test_cambio_de_modo_rige_desde_la_ronda_siguiente`; `test_especie.gd` `test_sin_modos_responde_la_ficha_y_valores_neutros` y `test_criatura_arranca_en_el_modo_inicial`.
- **Tests reescritos o retirados** (con la sección de `Sistema.md` v1.3 que los cambia):
  - `unidades/test_especie.gd`: `test_tasajero_tiene_dos_turnos` → `test_tasajero_responde_por_modo`. Los valores de Caza y Cuenta salen del modo (11.2.3).
  - `combate/test_cola_iniciativa.gd`:
    - (2) `test_prueba_c`: 5 entradas, sin la Cuenta (11.2.3, 11.3 Velocidad por modo).
    - (3) `test_maestro_empatado_va_antes_que_su_criatura`: solo cambia la API (`turnos()[0]` pasa a `velocidad("")`), sin cambio de regla.
    - (4) `test_rodauvas_de_e_siguen_el_orden_de_la_tribu` y (6a) `test_guardada_no_entra`: sale la entrada `tasajero_s1:cuenta` (11.2.3).
    - (6b) `test_fuera_del_tablero_se_saltea`: el Tasajero que sale antes de su turno pierde su único turno de la ronda (11.3, fila "Unidad que deja de actuar a mitad de ronda"; el ejemplo de P-012 ya no aplica).
    - (7) `test_tasajero_dos_entradas_y_fin_de_ronda` → `test_tasajero_una_entrada_y_fin_de_ronda` (11.2.3).
  - `combate/test_turno.gd` (9): `test_tasajero_caza_y_cuenta` → `test_tasajero_un_turno_por_ronda`. Un turno por ronda en Caza, un ataque de 5, y en la ronda siguiente movimiento y acción renovados (11.2.3, 11.2 Danio 5).
  - `combate/test_danio.gd`:
    - (5) `test_contra_erizada`: el Tasajero hace 2, no 3 (11.2 Danio 5; 11.2.3, "erizada recibe 2 + 2").
    - (6) `test_contra_lomo_de_tierra`: **retirado**, reemplazado por `test_surcon_no_reduce_el_danio`. El Maestro le hace 4 y la Rodauva 2, sin modificador (11.2, 11.2.1).
    - (7) `test_hacerse_junco`: **retirado**, reemplazado por `test_zancajunco_sin_bono_pasivo`, que pega 4 en el primer ataque y en el segundo (11.2.2: el +3 activo es de T38).
    - (9) `test_desglose`: sin el modificador `hacerse_junco`; 5 modificadores y total 5 (11.2.2).
    - `test_calcular_no_modifica`: compara la `instantanea` en lugar de `ya_ataco` (11.2.2).
  - `combate/ia/test_ia_salvaje.gd`:
    - (10) `test_tasajero_decide_en_cada_turno`: una decisión por ronda en Caza, dos rondas, daño 5. La fixture `ia_tasajero.json` pasa la Rodauva a vida 5 (11.2.3, 11.2).
    - (11) `test_decidir_no_cambia_nada_y_es_determinista`: sin el +2; el daño previsto es 4 y coincide con el ataque real. La fixture `ia_junco.json` pasa la Rodauva a vida 4 y sale la parte de `ya_ataco` (11.2.2).
    - `_foto` mira `modo` en lugar de `ya_ataco`.
  - `combate/test_combate.gd`:
    - (7) `test_registro_de_una_ronda_de_c`: un solo turno del Tasajero, que desde [3,1] ataca al Maestro en la ronda 1 (11.2.3, 11.9).
    - `test_cola_y_entrada_actual_para_la_pantalla`: 5 entradas, sin `cuenta` (11.2.3).
  - `pantalla/test_lectura_combate.gd` `test_filas_cola`: sin "Tasajero · Cuenta" (11.2.3).
  - `pantalla/test_vista_combate.gd` (6) `test_cola_mostrada_es_la_del_combate`: solo la marca `caza` (11.2.3).
  - `pantalla/test_claves_textos.gd` `test_claves_usadas`: rasgos `erizarse`, `alabarda`, `surco`, `hacerse_junco` y `caza_y_cuenta`; ya no está `rasgo.lomo_de_tierra` (11.2.1).
- **Corrige el plan aprobado:** la fixture `pruebas/fixtures/combate/escenario_c.json` también pasa el Tasajero a [3,1]. El plan decía que las posiciones de las fixtures no cambiaban, pero esta fixture es una copia declarada de `c_tasajero.json`, y el test (7) de `test_combate.gd` necesita que el Tasajero alcance a alguien en la ronda 1, que es justamente el motivo del cambio de 11.9.
- **Criterio de terminado:** cumplido punto por punto:
  1. `test_datos_completos.gd` carga `datos/` sin errores. La tabla de cotejo, debajo, la revisa el usuario.
  2. `test_rasgos_v13`: efecto sin su parámetro, parámetro de otro efecto, `velocidad` junto con `modos` (y sin ninguna de las dos), modo inicial inexistente y modos repetidos, cada uno con archivo y campo.
  3. `test_prueba_c`: cinco entradas.
  4. `test_tasajero_en_cuenta_va_ultimo`.
  5. `test_cambio_de_modo_rige_desde_la_ronda_siguiente`.
  6. `test_surcon_no_reduce_el_danio`, con el test de Lomo de tierra retirado y listado.
  7. `test_combate.gd` (9) con `datos/` real: los 11 escenarios llegan al primer turno del jugador.
  8. 224/224, con la lista de reescritos.
- **Tabla de cotejo v1.3** (A.2.2), para revisar contra `Sistema.md`:

  | Valor | Archivo y campo | Sección |
  |---|---|---|
  | 24 | `especies/surcon.json` `vida` | 11.2 |
  | `surco`, tope 2 | `especies/surcon.json` `rasgo.efecto`, `rasgo.tope` | 11.2.1 (Tope) |
  | `ocultarse`, +3 | `especies/zancajunco.json` `rasgo.efecto`, `rasgo.bono_plano` | 11.2.2 (Bono) |
  | 5 | `especies/tasajero.json` `danio` | 11.2 |
  | `caza` | `especies/tasajero.json` `rasgo.modo_inicial` | 11.2.3 (empieza en Caza) |
  | 50 | `especies/tasajero.json` `rasgo.umbral_cambio_pct` | 11.2.3 (Cambio a Cuenta) |
  | Caza: Vel 8, 2 ataques, sin partir, +25, plano 0 | `especies/tasajero.json` `rasgo.modos[0]` | 11.2.3 |
  | Cuenta: Vel 3, 1 ataque, partido, 0, plano −1 | `especies/tasajero.json` `rasgo.modos[1]` | 11.2.3 |
  | Vel 7, `alabarda` | `especies/ocarra.json` `velocidad`, `rasgo.efecto` | 11.2 |
  | Vel 6, `erizarse` −50, inmóvil, umbral 50 | `especies/rodauva.json` | 11.2, 11.8 |
  | Vel 2 / Vel 8 | `especies/surcon.json` / `zancajunco.json` `velocidad` | 11.2 |
  | [3,1] | `escenarios/c_tasajero.json` y `h_soplo.json` `enemigas.tasajero_s1.posicion` | 11.9 (Tasajero en C y H) |

  - **Sin cambios:** el movimiento del Tasajero (4, total también en Cuenta), su vida (30) y su `huida_pct` (25).
  - **Derivadas que reproducen los datos:**
    - Rodauva sola en la zona de Caza: 5 + 5 = 10 ≥ 8; erizada, 2 + 2 (11.2.3).
    - Cuenta: 5 − 1 = 4.
    - El Maestro necesita 6 golpes para debilitar al Surcón: 24 ÷ 4 (11.2, motivos).
  - **Números leídos que no se guardan:** "4 + 3 = 7" del Zancajunco con el bono (11.2.2, 11.9 F). Es la suma de `danio` y `bono_plano`.
  - **Se retiran:** `danio_recibido_plano` −1 (Lomo de tierra) y `danio_plano` +2 (primer ataque).
- **Lecturas declaradas:** ninguna nueva. Decisiones técnicas del plan aprobado:
  - `ninguno` sale del `enum` (la Ocarra usa `alabarda`, sin parámetros) y `accion_defensa` pasa a llamarse `erizarse`.
  - `modos` es una lista en orden, dentro del rasgo.
- **Claves de texto nuevas sin texto:** ninguna.
  - `ClavesTextos.usadas` ya pide `rasgo.surco.*`, `rasgo.alabarda.*` y `rasgo.caza_y_cuenta.*`, que existen en `es.json` v1.1. Desaparece el aviso de las claves de Lomo de tierra.
  - Las grabaciones del playtest 0a.1 cambian de huella: el aviso del reproductor es lo esperado.
- **Preguntas:** ninguna nueva; cerradas: ninguna.
  - P-024 figura `RESPONDIDA` en `CLAUDE.md` y en `Arquitectura.md` B.2.1, pero en `docs/PREGUNTAS.md` sigue `ABIERTA` y sin respuesta: falta pegarla (no afecta a T35, es de T30).
  - P-002, P-003 y P-008 siguen `RESPONDIDA` (son de T30, T14 y T19).
- **Para la próxima sesión:** nada: tarea terminada. Faltan la revisión de la tabla de cotejo, el commit y el PR. Sigue T36.

## T36 · sesión 1 · 06/10/2026
- **Rama:** tarea/T36-turno-modos
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:**
  - **`Turno` generalizado** (`Sistema.md` 11.3 y 11.2.3):
    - El turno lleva `pasos_restantes` (el Movimiento de la ficha o de `maestro.json`) y `ataques_restantes` (los del modo; 1 por defecto). Toman su valor después del inicio del turno, así que el turno se juega con el modo que quedó.
    - Sin movimiento partido, el primer `mover` gasta todos los pasos (igual que antes).
    - Con movimiento partido (Cuenta), `mover` gasta los pasos del camino más corto (`Tablero.pasos_hasta`) y se puede volver a mover antes y después de atacar.
    - `atacar` gasta un ataque. Sin movimiento partido y con más de un ataque (Caza), moverse después del primer ataque se rechaza con el motivo nuevo `MOVER_ENTRE_ATAQUES` hasta usar el último (S-23).
    - Erizarse gasta la acción y cierra el movimiento como antes.
    - `movimiento_usado` pasa a querer decir "sin pasos" y `accion_usada` "usó alguna acción": la pantalla y los tests de T08 los leen sin cambios.
  - **Cambio a Cuenta** (`CambioModo`, nuevo, en `nucleo/combate/`):
    - Es una regla del inicio del turno, no una decisión de la IA, y está en un solo lugar.
    - Va después del lugar de la huida (T25) y antes del de Encono (T19), según 11.8 paso 2.
    - Se compara en enteros: `vida × 100 ≤ vida_max × umbral_cambio_pct`. La criatura pasa al modo final, sin vuelta, y juega ese turno con él.
    - `Turno.cambio_modo` guarda `{de, a}`; el `Combate` lo registra como evento `cambio_modo` (unidad, de, a) detrás del evento `turno`, que sigue con la marca de la cola.
    - `Especie.modo_final()` y `umbral_cambio_pct()`.
  - **Daño** (`Danio`, sin tocar a quien lo llama): el `recibido_pct` del modo de la objetivo entra como porcentaje del paso 1 y el `danio_plano` del modo de la atacante como plano del paso 3 (11.4). Los dos van con la fuente nueva `ModificadorDanio.Fuente.MODO` y el id del modo (`caza` o `cuenta`) como detalle.
  - **Consulta para la pantalla:** `Combate.vida_de_cambio(unidad_id)` devuelve la vida a la que cambia de modo (15 para el Tasajero), o `null` si no tiene modos, ya está en el final o es el Maestro.
  - **`instantanea`:** suma `modo` por criatura (`null` si no tiene modos), como pide A.7 para el hito.
- **Archivos:**
  - **Creados:** `nucleo/combate/cambio_modo.gd`; `pruebas/combate/test_caza_y_cuenta.gd`; `pruebas/fixtures/combate/escenario_caza.json` y `escenario_caza_tribu.json`.
  - **Modificados:**
    - Núcleo: `nucleo/combate/turno.gd`, `danio.gd`, `modificador_danio.gd`, `resultado_accion.gd` y `combate.gd`; `nucleo/unidades/especie.gd` y `plantel.gd`.
    - Tests: `pruebas/combate/test_turno.gd` y `test_danio.gd` (los de la lista "Tests reescritos").
- **Tests:** 9 nuevos, total 233, todos pasan (sí).
- **Tests reescritos** (con la sección de `Sistema.md` que los cambia):
  - `combate/test_turno.gd` (9) `test_tasajero_un_turno_por_ronda`: el segundo ataque en Caza ahora vale (12 − 5 − 5) y el tercero se rechaza con `ACCION_USADA`. En la ronda siguiente vuelve con dos ataques (11.2.3, "2 ataques separados de 5").
  - `combate/test_danio.gd` (7) `test_zancajunco_sin_bono_pasivo`: el Tasajero objetivo pasa a `cuenta` para que el golpe siga siendo 4, porque en Caza recibe +25% (11.2.3, 11.4 paso 1). El caso de Caza está en el test nuevo (5).
  - **Sin tocar** (criterio 8): en `test_turno.gd`, los tests 1 a 8, 10 a 12 y `test_previsualizar_ataque`.
- **Criterio de terminado:** cumplido punto por punto (`test_caza_y_cuenta.gd`, salvo el 8):
  1. `test_caza_dos_ataques`: dos ataques a la misma presa o a dos presas. La Rodauva (8) recibe 5 + 5 y cae en el segundo; erizada, recibe 2 + 2. Si la primera presa cae, el segundo ataque a la otra vale.
  2. `test_caza_no_hay_tercer_ataque`.
  3. `test_caza_orden_mover_y_atacar`: mover → atacar → atacar vale; atacar → mover se rechaza con `MOVER_ENTRE_ATAQUES` y sin cambios; atacar → atacar → mover vale.
  4. `test_cuenta_movimiento_partido`: mover 2, atacar y mover 2 vale; el tercer tramo se rechaza con `MOVIMIENTO_USADO`; pega 5 − 1 = 4, con `MODO` −1 `cuenta` en el desglose.
  5. `test_danio_recibido_por_modo`: la Ocarra le pega 5 en Caza (`MODO` +25 `caza`) y 4 en Cuenta; el Maestro con un combo de +50% le pega 4 × 1,75 = 7.
  6. `test_cambio_a_cuenta`: con 15 de 30 pasa a Cuenta y juega ese turno con 1 ataque y movimiento partido; con 16, no; con la vida otra vez en 30 sigue en Cuenta; `vida_de_cambio` da 15 en Caza y `null` en Cuenta.
  7. `test_ronda_siguiente_con_velocidad_de_cuenta`: la ronda en curso no cambia; la siguiente lo trae último, con Velocidad 3 y marca `cuenta`.
  8. Los tests de T08 de las demás unidades pasan sin cambios (lista de arriba).
  9. `test_registro_caza_y_cuenta`: `cambio_modo` va detrás de `turno` (con la marca `caza`), y hay un evento `ataque` con su desglose por cada uno de los dos golpes.
  10. `test_validar_es_aplicar_en_modos`: validar no cambia la foto ni los pasos ni los ataques que quedan, y da lo mismo que aplicar, en ocho casos de Caza y de Cuenta.
- **Lecturas declaradas:** ninguna nueva (S-23 ya estaba confirmada). Decisiones técnicas del plan aprobado:
  - "Pasa al otro modo" se programa como "pasa al modo final", el último de `modos`. Con los dos modos de los datos es lo mismo.
  - El test del registro usa un Tasajero **de la tribu** (`escenario_caza_tribu.json`), porque `Combate.aplicar` solo acepta acciones del jugador y la IA de dos ataques es de T39. La regla sale del efecto de la ficha, no del bando.
- **Fuera del plan:** el `modo` en la `instantanea`. A.7 lo pide para el hito y el test (9) lo usa.
- **Estado intermedio:** la IA del Tasajero sigue dando un solo ataque en Caza. El paso 6b es de T39, y terminar después de un ataque es válido.
- **Claves de texto nuevas sin texto:** `desglose.fuente.modo`. La pantalla nombra así la fuente nueva hasta T40, que pasa a usar `iniciativa.<modo>`, así que hasta entonces se ve `[FALTA: desglose.fuente.modo]` en el desglose de un golpe al Tasajero o del Tasajero en Cuenta.
- **Preguntas:** ninguna nueva; cerradas: ninguna. P-002, P-003, P-008 y P-024 siguen `RESPONDIDA` (son de T14, T19 y T30).
- **Para la próxima sesión:** nada: tarea terminada. Faltan el commit y el PR. Sigue T37.

## T37 · sesión 1 · 06/10/2026
- **Rama:** tarea/T37-surco
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:**
  - **Estado de los surcos** (`Surcos`, nuevo, en `nucleo/combate/`; `Sistema.md` 11.2.1):
    - El dueño es el `Combate`, que se lo pasa al `Turno`. El `Tablero` lo recibe por parámetro y no guarda nada.
    - Cada surco es `{casilla, duenio_id, orden}`, y apunta al Surcón por id.
    - Quién cava y pisa sale del efecto `surco` de la ficha (`Surcos.es_surcon`), nunca del id.
  - **Tope:** al cavar el tercero, se cierra el más viejo **de ese Surcón**. Cada Surcón tiene su tope (el de su ficha).
  - **Cierre:** una sola función, `Surcos.cerrar_de(duenio_id)`.
    - Hoy la llama `VidaCero` cuando una salvaje queda `fuera`. Guardar, huir y sellar (T24 a T28) van a llamar a la misma.
    - Un Surcón caído conserva sus surcos.
    - Al terminar el combate, los surcos desaparecen con él, sin evento.
  - **Tablero** (11.2.1, 11.3, 1.6):
    - `pasos_hasta` y `alcanzables`: un surco es intransitable, ni se pasa ni se termina ahí, salvo para un Surcón de cualquier bando.
    - La línea del Alcance 2 no mira surcos.
    - `es_casilla_libre`: dentro del tablero, sin unidad (de pie o caída) y sin surco, para cualquiera (S-25).
    - `bloquea_desplazamiento`, para la Lanzadera de T22: fuera del tablero u ocupada bloquea; un surco también, salvo para un Surcón.
  - **Acción `cavar`** (`Accion.cavar(casilla)`):
    - Solo con el efecto `surco`, sin haberse movido ni usado la acción, en una casilla ortogonalmente adyacente y libre. Puede estar junto a enemigas.
    - Gasta el turno completo: después solo vale `terminar`, y no es "esperar".
    - `Turno.se_movio` (nuevo; también le sirve a T38). Motivos nuevos: `YA_SE_MOVIO`, `CASILLA_NO_ADYACENTE` y `CASILLA_NO_LIBRE`.
  - **Registro e `instantanea`** (A.7):
    - `Surcos` lleva un historial de eventos que el `Combate` vuelca después de los eventos `estado` de cada acción, como las tiradas: las reglas no escriben el registro.
    - Eventos: `surco` (unidad, casilla) y `surco_cerrado` (casilla, dueño, motivo `tope` / `duenio_fuera`).
    - La `instantanea` suma `surcos`: `[{casilla, duenio, orden}]`.
  - **Grabación:** el esquema `grabacion` acepta el tipo `cavar` (con `casilla`). `Grabacion.FORMATO` sigue en 1, porque el cambio solo agrega.
- **Archivos:**
  - **Creados:** `nucleo/combate/surcos.gd`; `pruebas/combate/test_surco.gd`; `pruebas/fixtures/combate/escenario_surco.json` y `escenario_surco_tribu.json`.
  - **Modificados:**
    - Núcleo: `nucleo/combate/tablero.gd`, `turno.gd`, `accion.gd`, `resultado_accion.gd`, `vida_cero.gd` y `combate.gd`.
    - Esquema: `datos/_esquemas/grabacion.schema.json`.
- **Tests:** 8 nuevos, total 241, todos pasan (sí). **Tests reescritos:** ninguno. Las firmas nuevas de `Tablero`, `Turno.empezar` y `VidaCero.resolver` son parámetros opcionales al final.
- **Criterio de terminado:** cumplido punto por punto (`test_surco.gd`):
  1. `test_donde_cavar`: adyacente y libre, sí. Diagonal y a distancia 2 dan `CASILLA_NO_ADYACENTE`. Con una de pie, con una caída, con un surco o fuera del tablero dan `CASILLA_NO_LIBRE`. Junto a una enemiga, sí.
  2. `test_costo_turno_completo`: mover y después cavar da `YA_SE_MOVIO`. Después de cavar: mover da `MOVIMIENTO_USADO`, atacar y cavar dan `ACCION_USADA`, y terminar vale con `espero = false`. Sin el efecto da `SIN_RASGO`. Validar no cambia nada.
  3. `test_tope`: el tercero cierra el más viejo (`surco` y después `surco_cerrado` `tope`). Dos Surcones, cuatro surcos: el tercero de uno cierra solo el suyo.
  4. `test_duracion`: el Surcón de la tribu caído conserva su surco, que sigue cerrando el paso. El Surcón salvaje que sale del tablero cierra los dos suyos (`duenio_fuera`).
  5. `test_transito`: la Rodauva no pasa ni termina en el surco, y el rodeo le cuesta 4 pasos en vez de 2 (`Tablero` y `Turno`). El Surcón salvaje atraviesa el surco del de la tribu y termina en él.
  6. `test_linea_por_encima_del_surco`: la Ocarra pega 4 a distancia 2 con un surco en el medio.
  7. `test_casilla_libre_y_desplazamiento`: cada caso de `es_casilla_libre` (incluido que un surco no es libre para un Surcón) y de `bloquea_desplazamiento` (surco: bloquea a la Rodauva y al Maestro, no a los dos Surcones).
  8. `test_registro_instantanea_y_grabacion`: el Surcón de la tribu cava tres veces con `Combate.aplicar`. Cada `accion` cavar va seguida de su `surco`, y el tercero, de `surco_cerrado` `tope`. La `instantanea` trae los dos que quedan. La grabación valida contra el esquema (también tras pasar por JSON) y se reproduce con el mismo registro y la misma `instantanea`. `Accion.cavar` va y vuelve por diccionario.
- **Lecturas declaradas:** ninguna. Decisiones técnicas del plan aprobado:
  - Al pasar el tope, primero `surco` (el nuevo) y después `surco_cerrado` (el viejo).
  - Al terminar el combate no hay evento de cierre: A.7 solo da `tope` y `duenio_fuera`.
  - Orden de las comprobaciones de `cavar`: turno terminado, rasgo, acción usada, se movió, adyacencia, casilla libre.
- **Estado intermedio:**
  - El Surcón salvaje no cava (paso 7 de la IA, T39).
  - La pantalla no dibuja surcos, no tiene botón Cavar y no muestra los eventos nuevos (T40). `LecturaCombate` los ignora.
  - La IA y la pantalla ya respetan los surcos al mover, porque usan las consultas del `Turno`.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** ninguna nueva; cerradas: ninguna. P-002, P-003, P-008 y P-024 siguen `RESPONDIDA` (son de T14, T19 y T30).
- **Para la próxima sesión:** nada: tarea terminada. Faltan el commit y el PR. Sigue T38.

## T38 · sesión 1 · 06/10/2026
- **Rama:** tarea/T38-junco
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:**
  - **Consulta única de objetivo** (`Objetivos`, nueva, en `nucleo/combate/`; `Arquitectura.md` B.2.1):
    - `motivo(objetivo, clase, plantel)` es la única función que mira si una unidad está caída, fuera, guardada u oculta. Devuelve `OBJETIVO_INEXISTENTE`, `OBJETIVO_FUERA_DEL_TABLERO`, `OBJETIVO_CAIDO`, `OBJETIVO_OCULTO` (motivo nuevo) o `NINGUNO`.
    - Clases: `HOSTIL` (ataque, Martillazo, Lanzadera, sellar, Encono) deja afuera a la oculta (S-21). `ALIADA` (Remiendo, guardar) la acepta (S-22).
    - `puede_ser_objetivo`, y `de_pie` para las reglas que no eligen objetivo ("enemiga de pie adyacente").
    - `cuenta_como_rival_a_su_alcance(unidad, rival, plantel)`, para T19 (10.5): la oculta no cuenta.
    - La usan el ataque del `Turno`, y por él `objetivos_para_atacar`, `previsualizar_ataque` y las opciones de la IA. La IA también la usa al acercarse y al erizarse: sale `_enemigas_de_pie`, que miraba los estados por su cuenta. Los motivos del ataque salen en el mismo orden que antes.
  - **Hacerse junco** (`Sistema.md` 11.2.2 v1.4):
    - `Criatura` suma `oculta`, `bono_junco` y `junco_turno_anterior` (lo escribe `Turno._fin_del_turno`).
    - Acción `Accion.hacerse_junco()`: solo con el efecto `ocultarse`, sin haberse movido, sin enemiga de pie adyacente y no dos turnos seguidos. Motivos nuevos: `ENEMIGA_ADYACENTE` y `JUNCO_TURNO_ANTERIOR`. Gasta la acción y cierra el movimiento (S-26). No es esperar.
    - **Bono:** `Danio` suma un plano `RASGO_ATACANTE` (`bono_plano` de la ficha, detalle `hacerse_junco`) si la atacante tiene el bono. Se cobra solo al aplicar el ataque: validar y previsualizar no lo gastan. Es un sí/no, así que ocultarse otra vez con el bono no lo suma dos veces.
    - **Destapes** (`Junco`, nueva, en `nucleo/combate/`, sin estado):
      - Al aplicar su `mover` (conserva el bono) y su `atacar` (cobra el bono).
      - Por contacto, con una sola función, `Junco.revisar_contacto(movida_id, plantel)`, que el `Turno` llama después de cada `mover` aplicado (en Cuenta, después de cada tramo). Mira dónde terminó la unidad, nunca el camino (S-24). La Lanzadera (T22) e invocar (T26) van a llamar a la misma.
      - Destapar y pegar no tiene código propio: sale de que la consulta se hace en el momento del ataque.
    - **Pierde el bono** si recibe un ataque aplicado ya destapada (`Junco.recibir_ataque`).
    - **Fin del combate:** `Cierre.cerrar` borra el estado oculto y el bono (`Junco.limpiar`), sin evento.
  - **Registro, instantánea y grabación** (A.7):
    - Eventos `oculto` (unidad), `destape` (unidad, motivo `mover` / `atacar` / `contacto`, `por`: la unidad que lo destapó, o `null` si no es por contacto) y `bono_perdido` (unidad, atacante).
    - Las reglas los devuelven, el `Turno` los junta en `eventos()` y el `Combate` los vuelca después del evento de la acción, antes de `estado` y `surco`.
    - La `instantanea` suma `oculta` y `bono_junco` por criatura. El esquema `grabacion` acepta el tipo `hacerse_junco`. `Grabacion.FORMATO` sigue en 1.
  - **Deuda de T37** (cambian las firmas, no las reglas):
    - `Tablero.alcanzables` y `pasos_hasta` piden `surcos` y `pisa_surcos`.
    - `Turno.empezar` y `VidaCero.resolver` piden `surcos`. Salen el `Surcos.new()` de reemplazo y el `if surcos != null`.
- **Archivos:**
  - **Creados:**
    - Núcleo: `nucleo/combate/objetivos.gd`, `nucleo/combate/junco.gd`.
    - Tests: `pruebas/combate/test_junco.gd`.
    - Fixtures: `pruebas/fixtures/combate/escenario_junco.json`, `escenario_junco_salvaje.json` y `escenario_junco_tribu.json`.
  - **Modificados:**
    - Núcleo: `nucleo/combate/turno.gd`, `accion.gd`, `resultado_accion.gd`, `danio.gd`, `combate.gd`, `cierre.gd`, `vida_cero.gd`, `tablero.gd` e `ia/ia_salvaje.gd`; `nucleo/unidades/criatura.gd` y `plantel.gd`.
    - Esquema: `datos/_esquemas/grabacion.schema.json`.
    - Tests: los de la deuda (lista abajo).
- **Tests:** 13 nuevos, total 254, todos pasan (sí).
  - **Reescritos por la v1.3:** ninguno.
  - **Cambio de firma por la deuda de T37** (se agrega `Surcos.new()`, o `false` en `pisa_surcos`; ninguna aserción cambia):
    - `pruebas/combate/test_turno.gd`: `Turno.empezar` ×3.
    - `pruebas/combate/test_vida_cero.gd`: `Turno.empezar` ×2.
    - `pruebas/combate/test_danio.gd`: `Turno.empezar` ×1.
    - `pruebas/combate/test_caza_y_cuenta.gd`: `Turno.empezar` ×2.
    - `pruebas/combate/ia/test_ia_salvaje.gd`: `Turno.empezar` ×3.
    - `pruebas/pantalla/test_interprete_clic.gd`: `Turno.empezar` ×1.
    - `pruebas/combate/test_cierre.gd`: `VidaCero.resolver` ×1.
    - `pruebas/combate/test_tablero.gd`: `alcanzables` / `pasos_hasta` ×11.
    - `pruebas/combate/test_surco.gd`: `pasos_hasta` ×3.
- **Criterio de terminado:** cumplido punto por punto (`test_junco.gd`):
  1. `test_activar`: después de mover da `YA_SE_MOVIO`. Con una enemiga de pie adyacente da `ENEMIGA_ADYACENTE`; si está caída, vale. Con una aliada adyacente vale. Después de ocultarse, mover da `MOVIMIENTO_USADO`, atacar y ocultarse dan `ACCION_USADA`, y terminar no es esperar. En el turno siguiente da `JUNCO_TURNO_ANTERIOR`, y en el otro vale. Sin el efecto da `SIN_RASGO`.
  2. `test_no_es_objetivo_hostil`: sin ocultarse, la IA de la Ocarra y la de la Rodauva salvajes eligen al Zancajunco. Oculto: atacarlo da `OBJETIVO_OCULTO`, no está en `objetivos_para_atacar`, la previsualización lo rechaza, la Ocarra ataca a la Rodauva de la tribu y la Rodauva salvaje se acerca a ella.
  3. `test_ocupa_su_casilla`: la Rodauva salvaje no termina en su casilla ni la atraviesa (`Tablero` y `Turno`).
  4. `test_bono`: pega 7 (plano `rasgo_atacante` +3 `hacerse_junco`), y 4 en el ataque siguiente. Oculto → se mueve → se oculta otra vez con el bono → pega 7, no 10.
  5. `test_mover_destapa_y_conserva`: evento `oculto`; al moverse, `destape` `mover`, y conserva el bono.
  6. `test_atacar_destapa_y_cobra`: validar y previsualizar (desde su casilla y desde otra) dan 7 y no cambian nada. Al aplicar pega 7, se destapa (`atacar`) y el bono queda cobrado.
  7. `test_contacto`: la Rodauva salvaje pasa por [4,4], al lado, y termina en [4,5]: no lo destapa. La Ocarra termina en [4,4]: `destape` `contacto` por `ocarra_s1`.
  8. `test_pierde_el_bono`: destapado y con el bono, validar el ataque de la Rodauva salvaje no lo quita. Al aplicarlo, recibe 2 y pierde el bono (`bono_perdido`).
  9. `test_aliada_vale_sobre_oculta`: `ALIADA` vale y `HOSTIL` da `OBJETIVO_OCULTO`. Como aliada, una caída da `OBJETIVO_CAIDO` (P-025) y un id que no existe da `OBJETIVO_INEXISTENTE`.
  10. `test_rival_oculta`: la Ocarra (3 + 2) tiene al Zancajunco a 3. Destapado cuenta; oculto, no; destapado otra vez, sí; a distancia 8, no.
  11. `test_registro_instantanea_y_grabacion`: con `Combate.aplicar` en `escenario_junco_tribu`:
      - el Zancajunco se oculta, la IA de la Ocarra se acerca al Maestro y lo destapa, y en la ronda 2 le pega y le quita el bono;
      - el registro trae `oculto` (detrás de su `accion`), `destape` (detrás del `movimiento`) y `bono_perdido` (detrás del `ataque`);
      - la `instantanea` trae `oculta` y `bono_junco`;
      - la grabación valida contra el esquema y se reproduce con el mismo registro y la misma `instantanea`;
      - `Accion.hacerse_junco` va y vuelve por diccionario;
      - el `Cierre` borra el estado oculto y el bono.
  12. `test_destapar_y_pegar`: con el Zancajunco salvaje oculto, atacarlo da `OBJETIVO_OCULTO`. La Rodauva se mueve al lado (`destape` `contacto`), lo ataca en el mismo turno y vale (2), y el bono se pierde.
  13. `test_cuenta_destapa_en_el_primer_tramo`: el Tasajero en Cuenta termina su primer tramo al lado. El `destape` está en sus eventos antes de cualquier ataque. Después pega 4 y se retira con los 2 pasos que le quedan.
- **Lecturas declaradas:** ninguna. Decisiones técnicas del plan aprobado:
  - El bando no está en la consulta: la Lanzadera es hostil y también vale sobre aliadas (1.6).
  - `ALIADA` deja afuera a la caída mientras siga abierta P-025.
  - Orden de las comprobaciones de `hacerse_junco`: turno terminado, rasgo, acción usada, se movió, enemiga adyacente, turno anterior.
  - Orden de los eventos: el de la acción, los de `Junco`, `estado` y `surco`. Al atacar: primero el destape o el bono de la atacante, después el `bono_perdido` de la objetivo, y al final `VidaCero`.
  - `por` es `null` salvo en el contacto.
  - En el plan figuraba `Junco.cobrar_bono`. Quedó como `Junco.atacar`, que también destapa a la atacante.
- **Estado intermedio:**
  - La IA no se oculta, y el Zancajunco con el bono no avanza (pasos 7 y 8, T39).
  - La pantalla no tiene el botón Hacerse junco, no marca a la oculta y no muestra los eventos nuevos (T40). `LecturaCombate` los ignora.
  - La pantalla ya no deja atacar a una oculta, porque usa `objetivos_para_atacar`.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** nueva P-025 (ARQUITECTO, no bloquea, se necesita antes de T26). Cerradas: ninguna. P-002, P-003, P-008 y P-024 siguen `RESPONDIDA` (son de T14, T19 y T30).
- **Para la próxima sesión:** nada: tarea terminada. Faltan el commit y el PR. Sigue T39.

## T39 · sesión 1 · 06/10/2026
- **Rama:** tarea/T39-ia-v13
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:**
  - **IA v1.3** (`IASalvaje`, `Sistema.md` 11.8 v1.3), con los principios de T11: sin azar, devuelve `Accion`, explica el paso y decidir no cambia nada. Los comentarios siguen la numeración nueva: 1 huida (vacío), 2 cambio de modo, 3 Encono (vacío, con la nota "en Caza, solo el primer ataque va a la rival", T20), 4 Erizarse, 5 remate, 6 cercana, 6b Caza, 7 prepararse y 8 acercarse. Cada rasgo se reconoce por su efecto o por los números del modo, nunca por el id.
    - **Paso 2:** lo resuelve el inicio del turno (T36). `DecisionIA` copia `modo` y `cambio_modo` del turno, y `describir()` los muestra.
    - **Paso 6b, Caza** (el modo da 2 ataques o más sin partir el movimiento): reemplaza a los pasos 5 y 6.
      - Por cada casilla a la que llega, sus presas son las opciones de ataque, que ya pasan por la consulta única.
      - Con 2 presas o más, un ataque a cada una de las dos de menos vida; con 1, los dos ataques a esa.
      - Clave de la casilla: 2 presas > 1 → la que tumba → menos vida sumada → menos pasos → orden de lectura.
      - Si el primer golpe tumba a la única presa, se planea un solo ataque: el segundo se pierde (S-23).
    - **Cuenta** (el modo parte el movimiento):
      - Golpea desde la casilla de menos pasos, y después el orden de lectura.
      - Después se retira a la casilla más lejana de la enemiga de pie más cercana. Esa enemiga no puede estar oculta ni ser la objetivo, si el golpe la tumba. Si ninguna casilla lo aleja, no se mueve.
      - `DecisionIA.retirada`.
    - **Paso 7, prepararse**, solo sin ninguna opción de ataque:
      - **Con el efecto `ocultarse`:** sin el bono y si `hacerse_junco` vale, se oculta.
      - **Con el efecto `surco`:** con menos surcos que el `tope` de la ficha, cava en la casilla de `casillas_para_cavar` más cercana a la enemiga de pie más cercana (sin ocultas), y después el orden de lectura.
      - Si no se cumple nada, sigue al paso 8.
    - **Paso 8:** sin cambios. El Zancajunco con el bono llega acá y avanza: el `Turno` lo destapa y conserva el bono.
    - La IA no planifica destapar y pegar: elige antes de moverse.
  - **`DecisionIA`:**
    - `Paso` suma `CAZA` y `PREPARARSE`.
    - Campos nuevos: `objetivos` (uno por ataque; `objetivo_id` es el primero), `retirada`, `modo`, `cambio_modo` y `sumar_ataque()`.
    - `describir()` dice "paso N" con el número de 11.8 (4, 5, 6, 6b, 7, 8), el modo y "paso 2: de->a".
    - El registro escribe los pasos nuevos como `caza` y `prepararse`.
  - **Consultas nuevas del núcleo** (calcular sin aplicar):
    - `Turno.casillas_para_cavar()`: las vecinas donde `cavar` vale, en orden de lectura. La usan la IA y, en T40, la pantalla.
    - `Turno.surcos_propios()`.
    - `Turno.pasos_para_retirarse(desde)`: casilla → pasos después de moverse a `desde` y atacar. Sin movimiento partido, solo `desde`.
    - `Tablero.pasos_hasta(..., dejada)`: parámetro opcional; la casilla que la unidad deja cuenta como vacía. Los llamados actuales no cambian.
- **Archivos:**
  - Creados (fixtures):
    - `pruebas/fixtures/combate/escenario_f.json` (copia de `datos/escenarios/f_rescate.json`).
    - En `pruebas/fixtures/combate/ia/`: `ia_caza_cruz.json`, `ia_caza_linea.json`, `ia_caza.json`, `ia_cuenta.json`, `ia_surcon.json` e `ia_oculta.json`.
  - Modificados:
    - `nucleo/combate/ia/ia_salvaje.gd`, `nucleo/combate/ia/decision_ia.gd`, `nucleo/combate/turno.gd` y `nucleo/combate/tablero.gd`.
    - `pruebas/combate/ia/test_ia_salvaje.gd`, `pruebas/combate/test_surco.gd`, `pruebas/combate/test_caza_y_cuenta.gd` y `pruebas/combate/test_combate.gd`.
    - `docs/PREGUNTAS.md`, `docs/RESUMENES.md` y `CLAUDE.md` ("Estado actual").
- **Tests:** 11 nuevos (9 del criterio y 2 de las consultas), total 265, todos pasan (sí).
  - **Tests reescritos por la v1.3:**
    - `test_ia_salvaje.gd::test_tasajero_decide_en_cada_turno`, por `Sistema.md` 11.8 paso 6b. En Caza el paso es `CAZA`: contra la Rodauva (5) el primer golpe la tumba y el segundo se pierde (S-23), y al Maestro le da los dos ataques (5 + 5).
    - `test_combate.gd::test_registro_de_una_ronda_de_c`, por `Sistema.md` 11.8 paso 6b. El Tasajero de C pega dos veces al Maestro desde [3,5]: dos pares `accion`/`ataque`.
    - `test_surco.gd::test_registro_instantanea_y_grabacion`, por `Sistema.md` 11.8 paso 7. El Surcón salvaje ahora cava ([6,0] y [7,1]) y en la ronda 3 se acerca. Las cuentas de la tribu se filtran por dueño, y los `orden` de sus surcos pasan a 3 y 5.
- **Criterio de terminado:** cumplido punto por punto (`test_ia_salvaje.gd`):
  1. `test_t39_caza_cruz_y_linea`:
     - En cruz va a la esquina [2,4] y le da un ataque a la Rodauva y otro a la Ocarra (8 → 3 y 12 → 7).
     - En línea y en un bloque de 2 × 2, le da los dos ataques a la Rodauva desde [3,4]: 5 + 5, y cae.
  2. `test_t39_desempates_de_la_caza`, un caso por desempate:
     - 2 presas > 1, aunque la de 1 tumbe.
     - La que tumba, aunque sume más vida.
     - Menos vida sumada.
     - Menos pasos, aunque la otra vaya antes en orden de lectura.
     - Orden de lectura.
     - Con 3 presas, las 2 de menos vida.
     - Con empate de vida, la que va antes en la cola (P-026).
  3. `test_t39_el_primer_golpe_tumba`:
     - Con 2 presas, la Rodauva (5) cae y el segundo ataque va a la Ocarra.
     - Con 1 presa, cae y la decisión lleva un solo ataque; el turno termina bien.
  4. `test_t39_cuenta_golpea_y_se_retira`:
     - Golpea desde [3,3], la de menos pasos (4 de daño), y se retira a [3,1], la casilla de la que salió.
     - Arrinconado en [0,0], ataca y no se mueve.
  5. `test_t39_f_el_zancajunco_se_oculta_avanza_y_embiste`, con `Combate` y fixtures:
     - Ronda 1: `prepararse` (`hacerse_junco`).
     - Ronda 2: `acercarse`, con `destape` `mover` y el bono intacto.
     - Ronda 3: pega 7 al Maestro, que tiene 6: derrota.
     - Si el Maestro lo golpea en la ronda 2, en la 3 pega 4.
  6. `test_t39_surcon_cava_hacia_la_mas_cercana`:
     - Cava en [2,1], hacia el Maestro.
     - Con la Rodauva a la misma distancia, cava hacia ella, que tiene menos vida (P-027).
     - Con el tope lleno no cava y se acerca.
  7. `test_t39_ninguna_ia_elige_a_una_oculta`: con el Zancajunco oculto, ninguna IA lo toma en cuenta:
     - La Caza no lo cuenta como tercera presa.
     - La Cuenta no lo toma como "más cercana" para retirarse.
     - El Surcón no cava hacia él.
     - Acercarse queda probado en el 9.
  8. `test_t39_la_explicacion_dice_el_paso`:
     - `describir()` dice paso 4, 5, 6, 6b, 7 y 8, el modo y "paso 2: caza->cuenta" (con 15 de 30 juega en Cuenta y se retira).
     - En Caza, Cuenta, cavar y ocultarse, decidir no cambia el Plantel ni los surcos y da lo mismo dos veces.
  9. `test_t39_termina_al_lado_de_una_oculta_y_no_la_ataca`: la Rodauva salvaje va hacia el Maestro, termina junto al Zancajunco oculto, lo destapa (`destape` `contacto`) y no lo ataca.
  - Consultas: `test_surco.gd::test_casillas_para_cavar_y_surcos_propios` y `test_caza_y_cuenta.gd::test_pasos_para_retirarse`.
- **Lecturas declaradas:**
  - P-026: presas de la Caza y orden de los dos ataques, por menos vida → antes en la cola.
  - P-027: empate en "la enemiga de pie más cercana", por más cercana → menos vida → antes en la cola.
  - Las dos están programadas con la recomendación de la pregunta, citada en el código.
  - Decisión técnica: dos golpes a la misma presa dan el mismo daño, porque entre uno y otro solo cambia la vida. Con 1 presa, "tumba" es `2 × daño ≥ vida`.
- **Estado intermedio:** la pantalla todavía no muestra a la oculta, los surcos ni los eventos nuevos (T40). `casillas_para_cavar` ya está para el botón Cavar.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:**
  - Nuevas: P-026 y P-027 (SISTEMAS, no bloquean).
  - Cerradas: ninguna.
  - P-002, P-003, P-008 y P-024 siguen `RESPONDIDA`; son de T14, T19 y T30.
  - Nota sin pregunta: la tabla de desempates de 11.8 todavía dice "remate (paso 4)" y "sin remate (paso 5)", con la numeración vieja.
- **Para la próxima sesión:** nada: tarea terminada. Faltan el commit y el PR. Sigue T40.

## T40 · sesión 1 · 06/10/2026
- **Rama:** tarea/T40-pantalla-rasgos
- **Estado:** EN CURSO (sigue en la sesión 2: ritmo de la IA)
- **Hecho:**
  - Núcleo, dos consultas nuevas (las únicas de la tarea):
    - `Combate.zona_amenaza(id)`: lo que golpea (`Tablero.golpeables`) desde cada casilla a la que llega (`Tablero.alcanzables`, con los surcos), sin la suya, en orden de lectura.
    - `Combate.destaparia(id, casilla)`: las ocultas del otro bando que destaparía al terminar ahí. La regla vive en `Junco.destaparia`, que ahora usa `Junco.revisar_contacto`: un solo lugar para 11.2.2 / S-24.
  - Núcleo, ajuste chico: `Turno.EFECTO_ERIZARSE` pasa a público para armar el botón por efecto.
  - `LecturaCombate`:
    - `botones_activas()`: el efecto decide qué botón hay y las consultas del turno si está habilitado. Reemplaza a `boton_rasgo`.
    - `tooltip_unidad(id)`, para cualquier unidad: nombre, vida, rasgo y estado. El estado incluye erizada, oculta, bono, modo, el umbral de `vida_de_cambio` y los surcos contra el tope.
    - Una línea de sucesos por evento nuevo de A.7.
    - La fuente `modo` se nombra con `iniciativa.<modo>`.
    - Las fichas suman modo, oculta y bono.
    - Concordancia (A.2.1) en `marca.caida`, `lealtad.estado.*`, `estado.*` y `hambre.estado.*`.
  - `ClavesTextos`: `modo`, `suceso_destape` y `suceso_cambio`, y las constantes de la v1.3. `usadas` suma los modos y sus cambios desde los datos, y solo las variantes de concordancia que existen en el archivo.
  - `InterpreteClic.accion(..., modo_cavar)`.
  - `VistaCombate`:
    - Botones `Activa_<tipo>` y `pulsar_activa(tipo)` (sale `pulsar_erizarse`). Cavar entra en el modo "elegir casilla", que marca `casillas_para_cavar`.
    - Capas `Surcos` (color del bando del dueño) y `Zona` (zona de Caza de las enemigas con `vida_de_cambio` no null). La acción nueva `zona` (Z) la oculta y la muestra.
    - `PanelUnidad` con el tooltip y `Aviso` con `aviso.destapar`. La oculta se ve semitransparente.
  - Tileset: 5 marcas placeholder nuevas (surco tribu y enemiga, zona, cavar, destino para la sesión 2).
- **Archivos:**
  - Creados: `pruebas/combate/test_zona_y_destape.gd`, `pruebas/pantalla/test_botones_activas.gd`, `pruebas/pantalla/test_vista_rasgos.gd`.
  - Fixtures creadas: `pruebas/fixtures/pantalla/es_rasgos.json`, `especie_prueba.json` y `escenario_especie_prueba.json`.
  - Modificados: `nucleo/combate/combate.gd`, `junco.gd`, `turno.gd`; `pantalla/claves_textos.gd`; `pantalla/combate/lectura_combate.gd`, `interprete_clic.gd`, `vista_combate.gd`, `vista_combate.tscn`, `casillas_cenital.tres`, `marcas_placeholder.svg`; `project.godot`; `pruebas/pantalla/test_claves_textos.gd`, `test_interprete_clic.gd`, `test_lectura_combate.gd`; `CLAUDE.md` (Estado actual).
- **Tests:** 14 nuevos, total 279, todos pasan (sí).
- **Criterio de terminado:** parcial. Cumplidos en esta sesión:
  - 1: `test_zona_amenaza` y `test_destaparia`. El caso del surco en la zona no tiene un test propio: lo cubren los tests de T37 de `Tablero.alcanzables` con surcos, que `zona_amenaza` usa tal cual.
  - 2: `test_botones_salen_del_efecto` y `test_vista_pulsa_la_activa_del_efecto`, con `especie_prueba` y el rasgo `rasgo_prueba`.
  - 3: `test_modo_cavar` y `test_modo_cavar_en_la_vista`.
  - 4: `test_t40_sucesos_de_los_rasgos`.
  - 5: `test_t40_tooltip_de_una_enemiga` y `test_tooltip_de_una_enemiga` (vista).
  - 8: `test_t40_etiquetas_con_concordancia` y `test_claves_de_rasgos_y_variantes`.
  - 9: `test_t40_desglose_nombra_el_modo` y `test_claves_de_rasgos_y_variantes`.
  - Además: `test_aviso_al_mover_junto_a_una_oculta` y `test_zona_de_caza`.
  - Faltan: 6 y 7 (sesión 2).
- **Tests de tareas anteriores reescritos:** ninguno.
- **Lecturas declaradas:** ninguna. Decisiones técnicas del plan aprobado:
  - Variantes en `usadas`: solo las que existen, porque A.2.1 las hace opcionales.
  - Surcos en el tooltip: `rasgo.surco.nombre: n/tope` ("Arar: 1/2"), sin clave nueva.
  - Zona: la dibujan las enemigas de pie con `vida_de_cambio` no null.
  - `iniciativa.caza` e `iniciativa.cuenta` siguen en `FIJAS`: el fixture de `test_principal` (5) no trae especies.
- **Claves de texto nuevas sin texto:** ninguna. Con `datos/` real, las 108 claves de `ClavesTextos.usadas` están todas en `es.json` v1.1. `desglose.fuente.modo` ya no se usa.
- **Preguntas:** ninguna nueva; cerradas: ninguna.
- **Para la próxima sesión:**
  - `SecuenciaIA` (`pantalla/combate/secuencia_ia.gd`).
  - La animación en la vista, con `pausa_ia` exportada, `en_secuencia()`, la entrada bloqueada y la acción `saltar` (Espacio).
  - Test 6 (pausa 0 y `saltar` dan el dibujo del núcleo) y test 7 (C jugado por la vista con activas se reproduce igual).
  - Correr la suite completa, el cierre de la tarea y la lista de prueba manual.

## T40 · sesión 2 · 06/10/2026
- **Rama:** tarea/T40-pantalla-rasgos
- **Estado:** TERMINADA (pendiente de PR y de la prueba manual del usuario)
- **Hecho (la tarea entera):**
  - Sesión 1, rasgos visibles (detalle en `T40 · sesión 1`):
    - Núcleo: `Combate.zona_amenaza(id)` y `Combate.destaparia(id, casilla)`, con la regla del contacto en `Junco.destaparia`.
    - `LecturaCombate`: `botones_activas()` por efecto, `tooltip_unidad(id)`, sucesos de los eventos nuevos de A.7, la fuente `modo` como `iniciativa.<modo>` y concordancia con sujeto.
    - `VistaCombate`: botones de activas, modo cavar, capas `Surcos` y `Zona` (acción `zona`, Z), tooltip y aviso de destapar.
  - Sesión 2, ritmo de la IA:
    - `SecuenciaIA.pasos(lineas, desde)` (`pantalla/combate/secuencia_ia.gd`) copia del registro los `movimiento` y `ataque` de las acciones con origen `ia`. No decide ni calcula.
    - `VistaCombate`:
      - `@export pausa_ia` (0,4 s; es presentación, no va a `datos/`); con 0 no anima.
      - Después de una acción del jugador que hace jugar a la IA, muestra sus pasos de a uno: la unidad resaltada, el destino con la marca `destino` y la vida del registro (`FichaUnidad.mostrar_vida`). Al terminar se redibuja entera desde el núcleo.
      - `en_secuencia()`, `saltar()` y la acción `saltar` (Espacio). La pausa la lleva un nodo `Timer` (`PausaIA`) que se libera con la vista, así R corta la secuencia limpia.
    - Durante la secuencia:
      - se bloquean los clics, los botones (ocultos), las activas y `terminar`;
      - F3 y R andan.
    - Test nuevo del criterio 1, pedido por el usuario: `zona_amenaza` con un surco en el camino del Tasajero. Lo comprobé con una mutación: pasándole a `zona_amenaza` un `Surcos.new()` vacío, el test falla.
- **Corrige:** T40 · sesión 1, criterio 1: el caso del surco en la zona no lo cubrían los tests de T37 (prueban `Tablero`, no el `Combate`). Ahora lo cubre `test_zona_amenaza_con_surco`.
- **Decisiones técnicas de la sesión 2** (en el plan aprobado):
  - Durante la secuencia, el hover (tooltip, desglose y aviso) y la capa de zona se apagan, porque mostrarían el estado final del núcleo con las fichas en posiciones intermedias. Z cambia el interruptor y se ve al final.
  - Los turnos de la IA del arranque (antes del primer turno del jugador) no se animan: no hay dibujo previo, y armarlo desde el escenario sería una copia del estado fuera del núcleo.
- **Archivos (la tarea entera):**
  - Creados:
    - Código: `pantalla/combate/secuencia_ia.gd`.
    - Tests: `pruebas/combate/test_zona_y_destape.gd`; en `pruebas/pantalla/`: `test_botones_activas.gd`, `test_vista_rasgos.gd`, `test_secuencia_ia.gd` y `test_vista_ritmo_ia.gd`.
    - Fixtures: `pruebas/fixtures/pantalla/es_rasgos.json`, `especie_prueba.json` y `escenario_especie_prueba.json`; `pruebas/fixtures/combate/escenario_caza_surco.json`.
  - Modificados:
    - Núcleo: `nucleo/combate/combate.gd`, `junco.gd` y `turno.gd`.
    - Pantalla: `pantalla/claves_textos.gd`; en `pantalla/combate/`: `lectura_combate.gd`, `interprete_clic.gd`, `vista_combate.gd`, `vista_combate.tscn`, `ficha_unidad.gd`, `casillas_cenital.tres` y `marcas_placeholder.svg`.
    - `project.godot` (`zona`, `saltar`).
    - Tests en `pruebas/pantalla/`: `test_claves_textos.gd`, `test_interprete_clic.gd`, `test_lectura_combate.gd`, `test_vista_combate.gd` y `test_principal.gd`.
    - `CLAUDE.md` (Estado actual).
- **Tests:** 22 nuevos en la tarea (14 en la sesión 1 y 8 en la 2), total 287, todos pasan (sí).
- **Criterio de terminado:** cumplido punto por punto:
  - 1: `test_zona_amenaza`, `test_zona_amenaza_con_surco` y `test_destaparia`.
  - 2: `test_botones_salen_del_efecto` y `test_vista_pulsa_la_activa_del_efecto`.
  - 3: `test_modo_cavar` y `test_modo_cavar_en_la_vista`.
  - 4: `test_t40_sucesos_de_los_rasgos`.
  - 5: `test_t40_tooltip_de_una_enemiga` y `test_tooltip_de_una_enemiga`.
  - 6: `test_pausa_cero_dibuja_el_nucleo`, `test_saltar_deja_el_mismo_dibujo` (con la entrada bloqueada y F3 andando), `test_la_secuencia_termina_sola` y `test_recargar_corta_la_secuencia_de_la_ia`. Además, `test_secuencia_ia.gd`.
  - 7: `test_jugar_c_con_activas_se_reproduce_igual`: C con `datos/` real, con activas, animando y saltando cada secuencia. La grabación valida y se reproduce igual, sin aviso de huella.
  - 8: `test_t40_etiquetas_con_concordancia` y `test_claves_de_rasgos_y_variantes`.
  - 9: `test_t40_desglose_nombra_el_modo` y `test_claves_de_rasgos_y_variantes`.
- **Tests de tareas anteriores reescritos:** ninguno. Los helpers de `test_vista_combate.gd`, `test_vista_rasgos.gd` y `test_botones_activas.gd` ponen `pausa_ia = 0`, y sus tests no cambian.
- **Lecturas declaradas:** ninguna.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** ninguna nueva; cerradas: ninguna.
- **Lista de prueba manual (usuario):**
  1. Copiar `es.json` v1.1 si todavía no está (`Mundo.md`, pendientes) y abrir el juego (F5).
  2. C, D normal, E, F y H con el mouse, hasta el final. A y B otra vez (regresión).
  3. Ver al Tasajero cambiar a Cuenta (suceso, ficha y cola) y su umbral en el tooltip.
  4. E: cavar con el Surcón (botón, casillas marcadas, surco con el color del bando, tope con cierre del más viejo).
  5. C: ocultar al Zancajunco, verlo semitransparente con el bono, el aviso al mover junto a una oculta enemiga, destaparlo y ver los sucesos.
  6. La zona de Caza con el Tasajero en Caza; Z la oculta y la muestra.
  7. Ritmo de la IA: después de `terminar`, la IA se ve de a un paso. Espacio salta. R a mitad de una secuencia reinicia sin errores en la consola. F3 abre el panel durante la secuencia.
  8. Anotar los textos `[FALTA]` y los tooltips desactualizados.
  9. Por escenario, anotar si se usó cada activa disponible (señal temprana de la métrica 14, sin umbral, `Sistema.md` 11.9 v1.5).
- **Para la próxima sesión:** nada: tarea terminada. Faltan el commit, el PR y la prueba manual; después, el cierre del hito 0a.1b.

## T14 · sesión 1 · 06/10/2026
- **Rama:** tarea/T14-obediencia
- **Estado:** TERMINADA (pendiente de PR y de la prueba manual del usuario)
- **Hecho:**
  - **Obediencia** (`nucleo/unidades/obediencia.gd`, `Sistema.md` 5.4):
    - `valor(criatura)` = lealtad + la penalización del estado de hambre (`tablas/hambre.json` `estados[].obediencia`, guardada en negativo). Sin recorte; `null` en las enemigas.
    - `tramo(criatura, maestro)` → `baja` / `neutral` / `leal`, con `neutral_desde` y el `umbral_rescate` de la fila de la balanza.
    - Las salvajes y la atacante nocturna dan `salvajes.tramo_obediencia` (`baja`) aunque tengan lealtad (10.7 y 9.2 punto 3). El Maestro no tiene obediencia.
    - No se guarda nunca. Vive en `ContextoCombate.obediencia`.
  - **Cortes compartidos** (5.4, P-003): `EstadosUnidad.corte(valor, neutral_desde, umbral)` es la única comparación con los cortes y la usan la lealtad y la obediencia. `EstadosUnidad` ya no lee `dudosa_hasta` (P-028).
  - **Hambre de combate** (`nucleo/combate/hambre_combate.gd`, 7.2):
    - Al cerrar una ronda múltiplo de `combate.cada_rondas`, suma `combate.suma` (tope `maximo`) al Maestro y a la tribu en el tablero, de pie o caída.
    - No alcanza a guardadas, muertas, unidades fuera, salvajes ni a la atacante.
    - La llama `Combate._cerrar_ronda`. El evento `hambre_combate` (A.7) va justo después del `fin_ronda`, con el número de esa ronda, y lista solo las unidades que cambian.
    - Un combate que termina a mitad de ronda no suma.
  - **Arrimo** (`nucleo/combate/arrimo.gd`, 1.3): `Arrimo.pasos(maestro)` lee `pasos_arrimo` de la fila; `ajuste(pasos, Arrimo.Uso)` usa `tablas/arrimo.json` `por_paso`. Hoy no la usa ninguna regla.
  - **P-003:** salió `obediencia.baja.hasta`, en este orden: esquema `combate`, `datos/tablas/combate.json` y el fixture `combate.json`.
  - **Resultado e instantánea** (A.7): `unidades[].hambre` en el resultado (esquema incluido) y `hambre` en la `instantanea` (Maestro y criaturas). Es un entero en la tribu y `null` en las enemigas.
  - **Pantalla:**
    - `LecturaCombate`: la obediencia (número y tramo) en el panel del turno y en el tooltip de una criatura de la tribu.
    - El suceso `hambre_combate`: la línea `combate.hambre` y, por cada unidad cuyo estado de hambre cambió, "Nombre · <estado nuevo>" con su sujeto.
    - `ClavesTextos`: `PANEL_OBEDIENCIA`, `COMBATE_HAMBRE` y `tramo_obediencia(tramo)`.
- **Tabla de cotejo (A.2.2), para revisar contra `Sistema.md`:**

  | Valor | Archivo y campo | Sección |
  |---|---|---|
  | 4 (piso de Neutral) | `tablas/lealtad.json` `neutral_desde` | 5.1, 5.4 |
  | 6 / 7 / 7 / 8 / 8 | `tablas/balanza.json` `posiciones[].umbral_rescate` | 1.2, 5.4 |
  | 0 / 0 / −2 / −4 | `tablas/hambre.json` `estados[].obediencia` | 5.4, 7.1 |
  | −10 / −20 (leal) · +10 / +20 (baja) | `tablas/combate.json` `obediencia.leal` / `.baja` | 5.4 |
  | `baja` | `tablas/combate.json` `salvajes.tramo_obediencia` | 10.7, 9.2 p.3 |
  | 5 y 1 | `tablas/hambre.json` `combate.cada_rondas` y `combate.suma` | 7.2 |
  | 10 | `tablas/hambre.json` `maximo` | 7.1 |
  | 4 / 3 / 2 / 1 / 0 | `tablas/balanza.json` `posiciones[].pasos_arrimo` | 1.2, 1.3 |
  | −5 / −5 / −5 / +10 | `tablas/arrimo.json` `por_paso.*` | 1.3 |
  | ~~3~~ | quitado (`obediencia.baja.hasta`): es `neutral_desde − 1` | 5.4 (P-003) |

  - **Derivada reproducida** (test 9), 1.3 con la balanza 2: incidente 20 − 15 = 5 %; combo 20 + 30 = +50 % y 40 + 30 = +70 %. Con la balanza 1: 0 % y +80 %.
  - **No guardados:** el "≤ 3" de 5.4 y 10.7 sale de `neutral_desde`; la tabla por posición de 1.3 sale de `pasos_arrimo` × `por_paso`.
- **Archivos:**
  - Creados:
    - Código: `nucleo/unidades/obediencia.gd`, `nucleo/combate/hambre_combate.gd` y `nucleo/combate/arrimo.gd`.
    - Tests: `pruebas/unidades/test_obediencia.gd`, `pruebas/combate/test_hambre_combate.gd`, `pruebas/combate/test_arrimo.gd` y `pruebas/datos/test_p003.gd`.
    - Fixtures: `pruebas/fixtures/combate/arrimo.json` y `escenario_hambre_combate.json`.
  - Modificados:
    - Datos: `datos/_esquemas/combate.schema.json`, `datos/_esquemas/resultado.schema.json` y `datos/tablas/combate.json`.
    - Núcleo: `nucleo/unidades/estados_unidad.gd`, `plantel.gd` y `criatura.gd` (comentario); `nucleo/combate/combate.gd`, `contexto_combate.gd`, `resultado_combate.gd` y `cola_iniciativa.gd` (comentario).
    - Pantalla: `pantalla/claves_textos.gd` y `pantalla/combate/lectura_combate.gd`.
    - Tests y fixtures: `pruebas/fixtures/combate/combate.json`, `pruebas/fixtures/pantalla/es_rasgos.json` (copias textuales de `es.json`: `hambre.estado.hambriento` y `combate.hambre`) y `pruebas/pantalla/test_lectura_combate.gd`.
    - Documentos: `CLAUDE.md` (Estado actual) y `docs/PREGUNTAS.md`.
- **Tests:** 12 nuevos, total 299, todos pasan (sí).
- **Criterio de terminado:** cumplido punto por punto:
  - 1: `test_obediencia_con_la_balanza_2`.
  - 2: `test_cortes_desde_los_datos` (también comprueba que la lealtad usa el mismo corte).
  - 3: `test_salvaje_y_atacante_son_baja`.
  - 4: `test_hambre_de_combate_en_rondas_5_y_10`.
  - 5: `test_recalculo_en_el_acto`.
  - 6: `test_combate_que_termina_en_la_ronda_5_no_suma`.
  - 7: `test_registro_del_hambre_de_combate`.
  - 8: `test_resultado_trae_el_hambre`.
  - 9: `test_arrimo`.
  - 10: `test_p003_sin_baja_hasta` (con `datos/` real); el test permanente de datos pasa.
  - 11: `test_t14_panel_y_tooltip_con_obediencia` y `test_t14_suceso_de_hambre_de_combate`.
  - 12: `addons/gdUnit4/runtest.cmd -a res://pruebas`: 299/299.
- **Tests de tareas anteriores reescritos:** ninguno. Ningún test existente cierra la ronda 5 contra una lista fija, y las aserciones de panel y tooltip de la tribu usan `contains` o `.back()`.
- **Lecturas declaradas:** ninguna de reglas. Lecturas técnicas (en el plan aprobado):
  - En una ronda que dispara el hambre, el evento `hambre_combate` se registra aunque `cambios` quede vacío (todas en el tope).
  - El hambre la aplica `Combate._cerrar_ronda` y no `ColaIniciativa.terminar_ronda`, porque toca el Plantel y el registro.
  - El esquema de escenario no admite lealtad en las enemigas: el test 3 se la pone a la `Criatura`.
  - Los tests 6 y 8 acomodan la posición y la vida de la salvaje antes del ataque que gana.
- **Claves de texto nuevas sin texto** (para el Worldbuilder, nombres propuestos): `panel.obediencia` (etiqueta del panel), `obediencia.tramo.baja`, `obediencia.tramo.neutral` y `obediencia.tramo.leal` (el tramo; sin concordancia: califica a la obediencia). `combate.hambre` ya existía en `es.json`.
- **Preguntas:** nueva P-028 (ARQUITECTO, no bloquea: `dudosa_hasta` repite `neutral_desde − 1`); cerrada P-003.
- **Aviso:** cambió la huella de los datos (salió un campo de `combate.json`). Las grabaciones anteriores dan el aviso de huella; es lo esperado.
- **Lista de prueba manual (usuario):**
  1. Abrir el juego (F5). C y D normal, hasta pasar la ronda 5 (con `terminar` si hace falta).
  2. El panel de cada criatura de la tribu muestra "[FALTA: panel.obediencia]: N ([FALTA: obediencia.tramo.…])"; el del Maestro, no. Pasar el mouse sobre una criatura de la tribu: el tooltip muestra la misma línea; una enemiga, no.
  3. Al cerrar la ronda 5: la línea "La pelea se alarga…" y, si una unidad cambió de estado de hambre, su línea (por ejemplo "Rodauva · Hambrienta").
  4. Después de la ronda 5, el panel muestra el hambre y la obediencia nuevas, y el desglose de una criatura que estaba Saciada ya no suma el +25 %.
  5. D hambriento: las criaturas con lealtad 5 y hambre 6 se ven con obediencia 3 y tramo baja.
- **Para la próxima sesión:** nada: tarea terminada. Faltan el commit, el PR y la prueba manual.

## T14 · sesión 2 · 06/10/2026
- **Rama:** tarea/T14-obediencia
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho (tarea entera):**
  - Sesión 1:
    - **Obediencia** (`nucleo/unidades/obediencia.gd`, `Sistema.md` 5.4): `valor(criatura)` = lealtad + la penalización del estado de hambre, sin recorte y `null` en las enemigas; `tramo(criatura, maestro)` → `baja` / `neutral` / `leal`, con `neutral_desde` y el `umbral_rescate` de la fila de la balanza. Las salvajes y la atacante nocturna dan `salvajes.tramo_obediencia` (10.7 y 9.2 punto 3). No se guarda; vive en `ContextoCombate.obediencia`.
    - **Cortes compartidos** (5.4, P-003): `EstadosUnidad.corte(valor, neutral_desde, umbral)`, usada por la lealtad y la obediencia. `EstadosUnidad` ya no lee `dudosa_hasta` (P-028).
    - **Hambre de combate** (`nucleo/combate/hambre_combate.gd`, 7.2): al cerrar una ronda múltiplo de `combate.cada_rondas`, suma `combate.suma` (tope `maximo`) al Maestro y a la tribu en el tablero, de pie o caída. La llama `Combate._cerrar_ronda`; el evento `hambre_combate` va después del `fin_ronda`. Un combate que termina a mitad de ronda no suma.
    - **Arrimo** (`nucleo/combate/arrimo.gd`, 1.3): `Arrimo.pasos(maestro)` y `ajuste(pasos, Arrimo.Uso)`. Hoy no la usa ninguna regla.
    - **P-003:** salió `obediencia.baja.hasta` (esquema `combate`, `datos/tablas/combate.json` y fixture).
    - **Resultado e instantánea** (A.7): `hambre` por unidad (entero en la tribu, `null` en las enemigas); esquema `resultado` incluido.
    - **Pantalla:** `LecturaCombate` muestra la obediencia en el panel y en el tooltip de la tribu, y el suceso `hambre_combate`. `ClavesTextos`: `PANEL_OBEDIENCIA`, `COMBATE_HAMBRE` y `tramo_obediencia(tramo)`.
  - Sesión 2: el usuario hizo la lista de prueba manual de la sesión 1 (puntos 1 a 5): todo OK. Sin cambios de código; se corrió de nuevo la suite completa.
- **Tabla de cotejo (A.2.2):** la de T14 · sesión 1, sin cambios.
- **Archivos (tarea entera):**
  - Creados: `nucleo/unidades/obediencia.gd`, `nucleo/combate/hambre_combate.gd`, `nucleo/combate/arrimo.gd`; tests `pruebas/unidades/test_obediencia.gd`, `pruebas/combate/test_hambre_combate.gd`, `pruebas/combate/test_arrimo.gd`, `pruebas/datos/test_p003.gd`; fixtures `pruebas/fixtures/combate/arrimo.json` y `escenario_hambre_combate.json`.
  - Modificados: `datos/_esquemas/combate.schema.json`, `resultado.schema.json`, `datos/tablas/combate.json`; `nucleo/unidades/estados_unidad.gd`, `plantel.gd`, `criatura.gd`; `nucleo/combate/combate.gd`, `contexto_combate.gd`, `resultado_combate.gd`, `cola_iniciativa.gd`; `pantalla/claves_textos.gd`, `pantalla/combate/lectura_combate.gd`; `pruebas/fixtures/combate/combate.json`, `pruebas/fixtures/pantalla/es_rasgos.json`, `pruebas/pantalla/test_lectura_combate.gd`; `CLAUDE.md` (Estado actual), `docs/PREGUNTAS.md` y `docs/RESUMENES.md`.
- **Tests:** 12 nuevos, total 299, todos pasan (sí).
- **Criterio de terminado:** cumplido punto por punto (1 `test_obediencia_con_la_balanza_2`, 2 `test_cortes_desde_los_datos`, 3 `test_salvaje_y_atacante_son_baja`, 4 `test_hambre_de_combate_en_rondas_5_y_10`, 5 `test_recalculo_en_el_acto`, 6 `test_combate_que_termina_en_la_ronda_5_no_suma`, 7 `test_registro_del_hambre_de_combate`, 8 `test_resultado_trae_el_hambre`, 9 `test_arrimo`, 10 `test_p003_sin_baja_hasta` y el test permanente de datos, 11 `test_t14_panel_y_tooltip_con_obediencia` y `test_t14_suceso_de_hambre_de_combate`, 12 suite completa 299/299).
- **Tests de tareas anteriores reescritos:** ninguno.
- **Lecturas declaradas:** ninguna de reglas. Técnicas (plan aprobado en la sesión 1): el evento `hambre_combate` se registra aunque `cambios` quede vacío; el hambre la aplica `Combate._cerrar_ronda` y no `ColaIniciativa`; el test 3 pone la lealtad a la `Criatura` enemiga (el esquema de escenario no la admite); los tests 6 y 8 acomodan posición y vida de la salvaje.
- **Claves de texto nuevas sin texto:** `panel.obediencia`, `obediencia.tramo.baja`, `obediencia.tramo.neutral` y `obediencia.tramo.leal`.
- **Preguntas:** nueva P-028 (ARQUITECTO, no bloquea); cerrada P-003. En esta sesión, ninguna.
- **Aviso:** cambió la huella de los datos; las grabaciones anteriores dan el aviso de huella (esperado).
- **Para la próxima sesión:** nada: tarea terminada.

## T15 · sesión 1 · 07/10/2026
- **Rama:** tarea/T15-afinidad
- **Estado:** TERMINADA (pendiente de PR y de la prueba manual del usuario)
- **Hecho:**
  - **P-028** (al empezar), en este orden: esquema → datos → fixtures. Sale `dudosa_hasta` de `datos/_esquemas/lealtad.schema.json` (de `required` y de `properties`), de `datos/tablas/lealtad.json` y del fixture `pruebas/fixtures/unidades/lealtad.json`. La `_nota` y la `description` dicen ahora que Dudosa va de `desleal_hasta + 1` a `neutral_desde − 1`. En el código no hubo que cambiar nada: desde T14, `EstadosUnidad` lee solo `desleal_hasta` y `neutral_desde`.
  - **Afinidad** (`nucleo/combate/afinidad.gd`, `Sistema.md` 10.3, 10.7, 10.8, 11.2.2 y 11.5):
    - `aporte(atacante_id, desde, plantel)` devuelve un `ModificadorDanio` (fuente `AFINIDAD`, plano `combate.json` `afinidad_danio_plano`, detalle `""`) si alguna unidad distinta de la atacante, a distancia 1 de `desde`, es afín. Corta en la primera, así que suma como máximo +1. Si no hay ninguna, devuelve `null`.
    - `son_afines(a, b, plantel)`: tienen que ser del mismo bando y estar las dos de pie (`Objetivos.de_pie`: ni caída, ni guardada, ni fuera). No mira `oculta`. Entre criaturas, el par tiene que ser `bien` en relaciones. Entre el Maestro y una criatura, la criatura tiene que estar en tramo `leal` de `Obediencia`, preguntado en el momento.
    - No guarda estado de combate. Vive en `ContextoCombate.afinidad`, armada con las `Relaciones` y la `Obediencia` que el contexto ya tenía.
  - **Enchufe:** `Turno.empezar(..., surcos, afinidad)`, con el parámetro obligatorio. `Turno._aportes(desde, objetivo_id)` devuelve la afinidad mirada desde `desde`. El único campo nuevo de `Turno` es `_afinidad`, una referencia a la regla, como `_danio`; no se guarda ningún afín, tramo ni bono. `Danio` no cambió. Como la afinidad pasa por `_atacar_desde`, la ven el ataque real, `validar`, `previsualizar_ataque`, la IA y el desglose del mouse. No hay eventos nuevos.
  - Tests con un `Turno` suelto: los 11 llamados pasan `DatosFixture.afinidad()` (relaciones, obediencia y `combate.json` de los fixtures), así que todos corren con la afinidad prendida.
- **Tabla de cotejo (A.2.2), para revisar contra `Sistema.md`:**

  | Valor | Archivo y campo | Sección |
  |---|---|---|
  | 1 (afinidad; también el tope por ataque) | `tablas/combate.json` `afinidad_danio_plano` (ya existía) | 10.3, 10.7, 11.4 paso 3 |
  | ~~3~~ | quitado (`tablas/lealtad.json` `dudosa_hasta`): es `neutral_desde − 1` | 5.1 (P-028) |

  - **Derivada reproducida:** 11.4, ejemplo, da 4 × 1,5 = 6, + 1 = 7 (test 9). 5.1 con la balanza 2 da Desleal 0–1, Dudosa 2–3, Neutral 4–6 y Leal 7–10 (test 12).
  - **No guardado:** el tope "máximo +1 por ataque" sale del mismo plano, porque la afinidad se suma una sola vez.
- **Archivos:**
  - Creados: `nucleo/combate/afinidad.gd`; tests `pruebas/combate/test_afinidad.gd` y `pruebas/datos/test_p028.gd`; fixtures `pruebas/fixtures/combate/escenario_afinidad.json` y `relaciones_junco_afin.json`.
  - Modificados:
    - Datos: `datos/_esquemas/lealtad.schema.json` y `datos/tablas/lealtad.json`.
    - Núcleo: `nucleo/combate/turno.gd`, `contexto_combate.gd` y `combate.gd`.
    - Tests y fixtures: `pruebas/combate/datos_fixture.gd` (`DatosFixture.afinidad(relaciones)`); los helpers de `Turno` de `test_turno`, `test_vida_cero`, `test_danio`, `test_junco`, `test_surco`, `test_caza_y_cuenta`, `ia/test_ia_salvaje` y `pantalla/test_interprete_clic`; `pruebas/pantalla/test_lectura_combate.gd`; `pruebas/fixtures/unidades/lealtad.json`; `pruebas/fixtures/pantalla/es_rasgos.json` (copia textual de `desglose.fuente.afinidad` de `es.json`).
    - Documentos: `CLAUDE.md` (Estado actual) y `docs/PREGUNTAS.md`.
- **Tests:** 13 nuevos (11 en `test_afinidad`, incluido `test_sin_azar`, 1 en `test_lectura_combate` y 1 en `test_p028`). Total 312, todos pasan (sí).
- **Criterio de terminado:** cumplido punto por punto:
  - 1: `test_rodauva_junto_a_rodauva`.
  - 2: `test_maestro_y_leal`.
  - 3: `test_en_el_acto_por_hambre_de_combate` (`HambreCombate.cerrar_ronda(5)` sobre el mismo turno).
  - 4: `test_mismo_bando`.
  - 5: `test_caida_y_guardada_no_dan`.
  - 6: `test_oculta_da_y_recibe`, con `relaciones_junco_afin.json` y su control con las relaciones de siempre.
  - 7: `test_se_mira_desde_la_casilla_del_ataque`.
  - 8: `test_ocarra_a_distancia_2`.
  - 9: `test_ejemplo_11_4`.
  - 10: `test_ia_remata_con_la_afinidad` (sola: no es `REMATE`; con su afín: `REMATE`, y el daño aplicado = `danio_previsto` = 3).
  - 11: `test_t15_desglose_del_registro_y_del_mouse_con_afinidad` (registro = previsualización; la pantalla muestra "Afinidad: +1").
  - 12: `test_p028_sin_dudosa_hasta`; el test permanente de datos pasa.
  - 13: `addons/gdUnit4/runtest.cmd -a res://pruebas`: 312/312.
- **Tests de tareas anteriores reescritos** (`Sistema.md` 10.3: ahora hay una afín al lado). Salieron de correr la suite con la afinidad prendida antes de tocar ninguno, y coinciden con la predicción del plan. Ninguno se borró; cada aserción lleva su comentario con 10.3:
  - `pruebas/combate/test_turno.gd::test_mover_y_atacar_en_cualquier_orden` (2ª mitad): el Maestro en [3,6], con sus leales al lado, deja la vida en 12 − (4 + 1).
  - `test_turno.gd::test_no_hay_segunda_accion`: 12 − (4 + 1).
  - `test_turno.gd::test_danio_de_balanza_y_de_ficha`: el Maestro de la balanza 2 pega 4 + 1; el de la balanza 5, 3 + 1 (umbral 8, las dos siguen leales); la Ocarra junto al Maestro, 4 + 1. El caso de la Rodauva que se mueve a [2,5] no cambia.
  - `test_turno.gd::test_vida_no_baja_de_cero`: la Ocarra junto al Maestro pega 4 + 1.
  - `pruebas/combate/test_vida_cero.gd::test_salvaje_en_cero_sale_del_tablero`: la Rodauva junto al Maestro pega 2 + 1.
  - `test_vida_cero.gd::test_atacante_en_cero_queda_caida`: el Maestro junto a la Rodauva leal pega 4 + 1.
- **Lecturas declaradas:** ninguna de reglas. Técnicas (plan aprobado):
  - `Turno` guarda una referencia a `Afinidad` (sin estado), con el parámetro obligatorio en `empezar`.
  - Una guardada no da afinidad porque `Objetivos.de_pie` la deja fuera, aunque conservara una posición.
  - El Tasajero y las salvajes son del mismo bando (`ENEMIGA`), así que un Zancajunco salvaje junto al Tasajero son afines (10.8 `bien`; "mismo bando", 10.7). Ningún escenario de `datos/escenarios/` los pone juntos hoy.
- **Claves de texto nuevas sin texto:** ninguna (`desglose.fuente.afinidad` ya está en `es.json`).
- **Preguntas:** ninguna nueva. Cerrada P-028.
- **Aviso:** cambió la huella de los datos (salió un campo de `lealtad.json`) y cambia el daño de los ataques con una afín al lado. Las grabaciones anteriores dan el aviso de huella y se juegan distinto (esperado).
- **Lista de prueba manual (usuario):**
  1. Abrir el juego (F5) y elegir C. En el turno del Maestro, con criaturas leales al lado, pasar el mouse sobre una enemiga a su alcance: el desglose muestra "Afinidad: +1" y el total sube en 1.
  2. Mover al Maestro lejos de sus leales y volver a pasar el mouse: no aparece "Afinidad".
  3. Atacar junto a una afín: la vida baja lo que dijo el desglose.
  4. Con una Rodauva de la tribu junto a otra (o junto a un Surcón), su desglose también muestra "Afinidad: +1". Junto a una Rodauva salvaje, no.
- **Para la próxima sesión:** nada: tarea terminada. Faltan la revisión de la tabla de cotejo, el commit, el PR y la prueba manual.

## T16 · sesión 1 · 07/10/2026
- **Rama:** tarea/T16-cadenas
- **Estado:** TERMINADA (pendiente de PR y de la prueba manual del usuario)
- **Hecho:**
  - **Relación afín** (`nucleo/combate/afinidad.gd`): `relacion_afin(a, b, plantel)` es lo que `son_afines` hacía sin mirar si están de pie: mismo bando, par de especies `bien` en relaciones, o el Maestro con una criatura en tramo `leal` de `Obediencia`, preguntado en el momento. `son_afines` es ahora "las dos de pie" + `relacion_afin`, y da lo mismo que antes (los 11 tests de T15 no se tocaron).
  - **Combo** (`nucleo/combate/combo.gd`, `Sistema.md` 10.2 y 1.3): regla sin estado, en `ContextoCombate.combo`.
    - `bono_par(anterior, atacante, plantel)` = la base del par (`combo.afines_pct` si son afines, si no `combo.sin_relacion_pct`) + `Arrimo.ajuste(Arrimo.pasos(maestro), COMBO)`.
    - `bono(eslabon, ...)`: el bono del par dividido por `combo.divisor_por_eslabon` en enteros, eslabón − 2 veces (S-27).
  - **Cadena** (`nucleo/combate/cadena.gd`): es el estado del combate y su dueño es el `Combate`, como `Surcos`. Guarda la objetivo, el eslabón y la lista de participantes en orden (por id, F-02).
    - `aporte` da el `ModificadorDanio` `COMBO` (`PORCENTAJE`) del eslabón siguiente, solo para la tribu y sobre la objetivo de la cadena.
    - `eslabon_para` da el eslabón que sería el golpe (`null` en las enemigas). Calcula sin aplicar.
    - `atacar` avanza la cadena. Solo lo hace la tribu; un golpe a otra objetivo corta con `otro_objetivo` y empieza una cadena nueva en el eslabón 1.
    - `cortar(motivo)` deja exactamente un `cadena_cortada` por cadena. `revisar_objetivo` corta con `objetivo_fuera` si `Objetivos` ya no la acepta como objetivo hostil.
    - También tiene `historial` (lo vuelca el `Combate`) e `instantanea`.
  - **Turno:** `Turno.empezar(..., afinidad, cadena)`, con `cadena` obligatoria.
    - `_aportes(desde, objetivo_id)` suma el combo junto a la afinidad. `Danio` no cambió.
    - `_atacar_desde` llena `ResultadoAccion.eslabon` al validar y al aplicar, y solo al aplicar llama a `Cadena.atacar` (antes de `VidaCero`).
    - `_resolver` llama a `Cadena.revisar_objetivo` después de cada acción aplicada.
    - Mover, Erizarse, Hacerse junco, cavar y esperar no tocan la cadena: no se programó nada para ellas.
  - **Combate:** dónde va cada corte.
    - `enemiga`: al empezar la entrada de una enemiga, detrás del evento `turno` y antes de que juegue.
    - `fin_ronda`: en `_cerrar_ronda`, detrás del `hambre_combate`.
    - `otro_objetivo` y `objetivo_fuera`: se vuelcan detrás de los eventos de la acción (después de los surcos).
    - `fin_combate`: al principio de `_terminar`, antes de `fin`.
    - El evento `ataque` suma `eslabon` (entero en la tribu, `null` en las enemigas). La `instantanea` suma `cadena` (`null`, o `{objetivo, eslabon, ultimo_atacante, participantes}`).
  - **Pantalla:**
    - `LecturaCombate.panel_turno()` suma al final la línea de la cadena en curso: `<panel.cadena>: <objetivo> (<eslabón>)`, con la clave nueva `ClavesTextos.PANEL_CADENA`.
    - El desglose del mouse ya mostraba el bono del eslabón siguiente ("Cadena: +50%"), porque la previsualización pasa por `_aportes`.
  - **Tabla de cotejo (A.2.2):** no hay números nuevos. Se usan los que ya existían:

    | Valor | Archivo y campo | Sección |
    |---|---|---|
    | +20 / +40 | `tablas/combate.json` `combo.sin_relacion_pct` / `afines_pct` | 10.2 |
    | ÷ 2 por eslabón | `tablas/combate.json` `combo.divisor_por_eslabon` | 10.2 |
    | +10 por paso | `tablas/arrimo.json` `por_paso.combo_pts` | 1.3 |
    | Pasos de Arrimo (3 en la balanza 2) | `tablas/balanza.json` `pasos_arrimo` | 1.2 |

    - **Derivadas reproducidas:** 10.2 da +70 / +35 / +17 / +8 (test 3); 1.3 da +20 / +40 en la balanza 5 y +60 / +80 en la 1 (test 4); 11.6, Prueba A, da +50 y 4 × 1,5 = 6 (test 1); 11.4 con afines da 6 + 1 = 7 (test 2).
    - Los datos no cambiaron, así que la huella tampoco.
- **Archivos:**
  - Creados:
    - `nucleo/combate/cadena.gd` y `combo.gd`
    - `pruebas/combate/test_cadena.gd`
    - `pruebas/fixtures/combate/escenario_cadena.json` y `escenario_cadena_combate.json`
  - Modificados:
    - Núcleo: `nucleo/combate/afinidad.gd`, `turno.gd`, `combate.gd`, `contexto_combate.gd` y `resultado_accion.gd`.
    - Pantalla: `pantalla/combate/lectura_combate.gd` y `pantalla/claves_textos.gd`.
    - Tests y fixtures:
      - `pruebas/combate/datos_fixture.gd`: `tablas/arrimo.json`, `DatosFixture.combo()` y `DatosFixture.cadena()`.
      - Solo la firma de los 16 llamados a `Turno.empezar` en `test_turno`, `test_vida_cero`, `test_danio`, `test_junco`, `test_surco`, `test_caza_y_cuenta`, `test_afinidad`, `ia/test_ia_salvaje` y `pantalla/test_interprete_clic`: pasan una `Cadena` nueva cada vez, así que ningún turno suelto encadena con otro.
      - `pruebas/pantalla/test_lectura_combate.gd` y `test_vista_combate.gd` (un comentario).
      - `pruebas/fixtures/pantalla/es_rasgos.json` (copia textual de `desglose.fuente.combo`).
    - Documentos: `CLAUDE.md` (Estado actual) y `docs/PREGUNTAS.md` (P-029).
- **Tests:** 16 nuevos: 15 en `test_cadena`, incluido `test_sin_azar`, y 1 en `test_lectura_combate`. Total 328, todos pasan (sí). Antes de cerrar, comprobé que los tests detectan una falla: con el aporte del combo anulado a propósito, fallan 9 de los 15 de `test_cadena`.
- **Criterio de terminado:** cumplido punto por punto.
  - 1: `test_prueba_a`.
  - 2: `test_afines_y_ejemplo_11_4`.
  - 3: `test_eslabones_sin_tope` (el quinto bono, eslabón 6, da +4).
  - 4: `test_arrimo_por_balanza`.
  - 5: `test_s27_pares_mixtos`.
  - 6: cuatro tests:
    - `test_corta_el_turno_enemigo_aunque_espere`: `rodauva_s1` está encerrada por dos caídas y solo termina; el corte va justo detrás de su `turno`.
    - `test_corta_al_cerrar_la_ronda`.
    - `test_otro_objetivo_empieza_en_1`.
    - `test_objetivo_que_sale_del_tablero`.
  - 7: `test_no_cortan_las_acciones_que_no_son_ataque`.
  - 8: `test_salvajes_no_encadenan`, y en Combate el turno de `surcon_s1` corta la cadena de la tribu (tests 6a y 11).
  - 9: `test_s28_relacion_sin_adyacencia_y_en_el_momento` (lejos, la anterior caída, y la leal que pasa a neutral por el hambre de combate).
  - 10: `test_validar_y_previsualizar_no_avanzan`.
  - 11: `test_registro_instantanea_y_grabacion` (eslabones, un corte por cadena con sus participantes, instantánea, reproducción igual, victoria con un solo corte y `fin_combate` una sola vez).
  - 12: `test_t16_desglose_y_panel_de_la_cadena`.
  - 13: `addons/gdUnit4/runtest.cmd -a res://pruebas`: 328/328.
- **Tests de tareas anteriores cuyo daño cambia** (`Sistema.md` 10.2). Los saqué de correr la suite completa con los combos prendidos y un aviso temporal en cada ataque con `COMBO`, antes de tocar ningún test. El aviso ya no está.
  - `pruebas/pantalla/test_vista_combate.gd::test_jugar_c_con_activas_se_reproduce_igual` (**C**, datos reales): en las rondas 1 y 2, la Ocarra leal y después el Maestro encadenan sobre el Tasajero. Son afines, el bono es +70 y el Maestro pega 8. El test no afirma daños y sigue pasando: lleva un comentario con 10.2 y no cambió ninguna aserción.
  - **Corrige el plan:** había predicho que también cambiaba `test_jugar_a_guarda_y_se_reproduce_igual` (A). No cambia: la Rodauva y el Maestro nunca le pegan a la Ocarra en la misma ronda (la Rodauva pega en la 2, el Maestro en la 3 a la 5).
  - Ningún test viejo falló, y ninguno se reescribió ni se borró.
- **Lecturas declaradas:**
  - S-27 (pares mixtos) y S-28 (relación sin adyacencia y en el momento), tal como las da `Arquitectura.md` 10.5.
  - P-029 (técnica): `objetivo_fuera` gana a `fin_combate`. Hoy `fin_combate` no se da en ningún combate real; su camino está probado con `Cadena.cortar`.
  - Técnicas:
    - `cadena_cortada` por `otro_objetivo` va detrás del `ataque` que la corta, como los demás eventos de la acción.
    - El de `fin_ronda` va detrás del `hambre_combate`, para dejar el hambre "justo después" del `fin_ronda` (A.7).
    - El mismo atacante dos veces seguidas (solo posible con un Tasajero de la tribu, que hoy existe únicamente en un fixture) cuenta como "sin relación", porque `relacion_afin(a, a)` da `false`.
- **Claves de texto nuevas sin texto:** `panel.cadena` (se ve `[FALTA: panel.cadena]`). Los textos `combo.eslabon.*` de `es.json` existen, pero T16 no pide sucesos de eslabón: no se usan.
- **Preguntas:** nueva P-029 (ARQUITECTO, no bloquea). Ninguna cerrada.
- **Aviso:** cambia el daño de los golpes encadenados y el registro (`eslabon` en `ataque` y eventos `cadena_cortada`). Las grabaciones anteriores se reproducen sin aviso de huella, pero dan otro registro (esperado).
- **Lista de prueba manual (usuario):**
  1. Abrir el juego (F5) y elegir C. En la ronda 1, atacar al Tasajero con la Ocarra y no atacar con la Rodauva (moverla o erizarla). En el turno del Maestro, el panel muestra `[FALTA: panel.cadena]: Tasajero (1)`, y con el mouse sobre el Tasajero el desglose muestra "Cadena: +70%".
  2. Atacar con el Maestro: la vida baja lo que dijo el desglose, y el panel pasa a `(2)` mientras dure su turno.
  3. En el turno siguiente de la tribu (después del Tasajero), el panel ya no muestra la cadena: el turno de la enemiga la cortó.
  4. Elegir A y, si la Rodauva y el Maestro llegan a la Ocarra en la misma ronda, pegarle con los dos: el desglose del Maestro muestra "Cadena: +50%".
- **Para la próxima sesión:** nada: tarea terminada. Faltan la revisión de P-029, el commit, el PR y la prueba manual.

## T41 · sesión 1 · 07/10/2026
- **Rama:** tarea/T41-vecinas
- **Estado:** TERMINADA (pendiente de PR y de la prueba manual del usuario)
- **Hecho:**
  - **Al empezar:** P-026, P-027 y P-029 pasan a `CERRADA` ("Cerrada en: T41"). No cambia código.
  - **Geometría** (`nucleo/combate/tablero.gd`, D-001): `Tablero.es_vecina_en_8(a, b)`, estática y pura, con distancia de Chebyshev 1 (la misma casilla no cuenta). Es la única consulta de "vecina en 8". `vecinas` y `adyacentes` (el cuerpo, 4 ortogonales) no cambian.
  - **Afinidad** (`nucleo/combate/afinidad.gd`, `Sistema.md` 10.3 y 10.7 v1.6):
    - Antes la vecindad se miraba con `Tablero.distancia(pos, desde) == 1` (Manhattan, solo las 4 ortogonales). Ahora se mira con `Tablero.es_vecina_en_8`.
    - Nueva `afines_vecinas(atacante_id, desde, plantel)`: los ids de las afines de pie en las 8 vecinas de `desde`, en el orden del `Plantel`, sin contar a la atacante.
    - `aporte` usa `afines_vecinas` y sigue dando como máximo un +1.
    - El resto de T15 no cambia: mismo bando, de pie, oculta incluida, y el Maestro con una leal preguntado en el momento. Combo y Cadena no se tocaron.
  - **Combate:** `afines_desde(unidad_id, casilla)` devuelve las unidades que le darían afinidad desde esa casilla. Calcula sin aplicar.
  - **Pantalla:**
    - Capa nueva `Tablero/Afines`, encima de las fichas, con la marca placeholder `7:0` (un anillo verde punteado en `marcas_placeholder.svg`, que pasa a 512 px de ancho).
    - `VistaCombate.sobre_casilla`: en el turno del jugador, sin elegir cavar y sin una objetivo bajo el mouse, si la casilla es de `casillas_para_mover()` o es la de la unidad del turno, se marcan las casillas de `afines_desde` y el aviso suma `afinidad.tooltip`.
    - Consulta nueva `casillas_afines()`. La capa se limpia en cada hover, en el redibujo (`_dibujar_marcas`) y al empezar la secuencia de la IA, donde el hover ya estaba apagado.
    - `ClavesTextos.AFINIDAD_TOOLTIP` está en `FIJAS`. La clave existe en `es.json` v1.2: no hay `[FALTA]`.
  - **Dato** (`Sistema.md` 7.2 v1.6): `datos/tablas/hambre.json` `combate.cada_rondas` pasa de 5 a 6 y la `_nota` cita 7.2 v1.6. El esquema no cambió. **La huella cambia:** al reproducir grabaciones anteriores, el aviso de huella es lo esperado.
  - **Tabla de cotejo (A.2.2):**

    | Valor | Archivo y campo | Sección |
    |---|---|---|
    | Hambre de combate cada 6 rondas (antes 5) | `tablas/hambre.json` `combate.cada_rondas` | 7.2 v1.6 |
    | +1 de afinidad (sin cambios) | `tablas/combate.json` `afinidad_danio_plano` | 10.3 v1.6 |

  - **Supuesto técnico (presentación, no regla):** si en la misma casilla aplican el aviso de destapar y el de afinidad, se muestran los dos, uno por línea (primero el de destapar).
- **Archivos:**
  - Creados:
    - `pruebas/datos/test_hambre_v16.gd`
    - `pruebas/fixtures/combate/hambre_cada_6.json`
  - Modificados:
    - Datos: `datos/tablas/hambre.json`.
    - Núcleo: `nucleo/combate/tablero.gd`, `afinidad.gd` y `combate.gd`.
    - Pantalla: `pantalla/combate/vista_combate.gd`, `vista_combate.tscn`, `casillas_cenital.tres`, `marcas_placeholder.svg` y `pantalla/claves_textos.gd`.
    - Tests: `pruebas/combate/test_afinidad.gd`, `test_tablero.gd`, `test_hambre_combate.gd`, `test_turno.gd` y `test_cadena.gd`, y `pruebas/pantalla/test_vista_rasgos.gd`.
    - Fixtures: `pruebas/fixtures/pantalla/es_rasgos.json` (copia textual de `afinidad.tooltip`).
    - Documentos: `CLAUDE.md` (Estado actual) y `docs/PREGUNTAS.md`.
- **Tests:** 11 nuevos (7 en `test_afinidad`, 1 en `test_tablero`, 1 en `test_hambre_combate`, 1 en `test_hambre_v16` y 1 en `test_vista_rasgos`). Total 339, todos pasan (sí). En la consola, solo los dos `ERROR` del "Remote Debugger" del runner, que ya salían antes de esta tarea.
- **Criterio de terminado:** cumplido punto por punto.
  - 1: `test_afin_en_diagonal` (la Rodauva pega 3 con la afín en diagonal y 2 sin ella).
  - 2: `test_ortogonal_y_diagonal_dan_uno` (3, una sola fuente `AFINIDAD`; `afines_vecinas` da las dos).
  - 3: `test_a_distancia_2_no_da` (`[x+2, y]` y `[x+2, y+1]`). Además, `test_tablero.gd::test_vecina_en_8`.
  - 4: `test_ocarra_a_distancia_2_afin_en_diagonal` (5 con el Surcón en diagonal de ella; 4 con el Surcón en diagonal de la objetivo).
  - 5: `test_salvajes_en_diagonal_y_bandos`.
  - 6: `test_junco.gd`, `test_zona_y_destape.gd`, `test_caza_y_cuenta.gd`, `ia/` y los de Erizarse de `test_turno.gd` pasan sin cambios (`git diff` vacío en esos archivos).
  - 7: `pruebas/datos/test_hambre_v16.gd` (datos reales: `cada_rondas` vale 6), y el permanente `test_datos_completos.gd` pasa.
  - 8: `test_hambre_combate.gd::test_cada_6_rondas` (cerrar la ronda 5 no suma; cerrar la 6 suma +1). Los tests de T14 siguen con su fixture de 5, sin cambios.
  - 9: `test_ia_remata_con_afin_en_diagonal` (`REMATE`, previsto 3 = aplicado).
  - 10: `test_afines_desde` (esquina `[0,0]` y centro `[3,3]`, con el Maestro y la leal en diagonal, en el orden del Plantel; la `instantanea` no cambia).
  - 11: `test_vista_rasgos.gd::test_marca_y_aviso_de_afinidad` (C: el Zancajunco sobre `[4,5]` marca al Maestro `[3,6]` y muestra el aviso; sobre una casilla alcanzable sin afines, nada; sobre la propia, sí).
  - 12: `addons/gdUnit4/runtest.cmd -a res://pruebas`: 339/339.
- **Tests viejos reescritos** (`Sistema.md` 10.3 v1.6: una afín en diagonal ahora da +1). Salieron de la corrida completa con `-c` antes de tocarlos. Ninguno se borró:
  - `pruebas/combate/test_turno.gd::test_danio_de_balanza_y_de_ficha`: la Rodauva que se mueve a `[2,5]` tiene al Maestro leal `[3,6]` en diagonal. Pega 2 + 1 (antes 2) y la vida de la Ocarra salvaje queda en 12 − 3 (antes 12 − 2).
  - `pruebas/combate/test_turno.gd::test_previsualizar_ataque`: la Ocarra que previsualiza desde `[2,7]` tiene al Maestro leal `[3,6]` en diagonal. Da 4 + 1 (antes 4).
  - `pruebas/combate/test_cadena.gd::test_registro_instantanea_y_grabacion`: en `escenario_cadena_combate`, el Zancajunco leal `[4,5]` y el Maestro `[5,4]` están en diagonal. Cada uno pega 4 + 1 (antes 4). La victoria con `surcon_s1` en 10 de vida sigue saliendo en el segundo golpe (5 + 6); solo cambió el comentario.
  - **Corrige el plan:** había previsto que no cambiaba ninguno de `test_cadena.gd` (solo miré `escenario_cadena.json`, no `escenario_cadena_combate.json`) y que podían cambiar tests con `datos/` reales (`test_combate`, `test_vista_combate`, `test_principal`, `test_lectura_combate`). Esos pasaron sin cambios.
- **Lecturas declaradas:** ninguna.
- **Claves de texto nuevas sin texto:** ninguna (`afinidad.tooltip` ya está en `es.json` v1.2).
- **Preguntas:** ninguna nueva. Cerradas P-026, P-027 y P-029.
- **Aviso:** cambia el daño de los golpes con una afín en diagonal y cambia la huella (`tablas/hambre.json`). Al reproducir grabaciones anteriores, el aviso de huella es lo esperado.
- **Lista de prueba manual (usuario):**
  1. `addons/gdUnit4/runtest.cmd -a res://pruebas`: todo en verde.
  2. F5 y elegir C. En el turno de la Rodauva, pasar el mouse por casillas en diagonal de la Ocarra o del Maestro. Tienen que aparecer el anillo verde sobre la afín y el aviso "Con una afín al lado o en diagonal, pega un poco más fuerte.". Sobre una casilla sin afines alrededor, no aparece nada.
  3. Moverse a una de esas casillas y pasar el mouse sobre una enemiga a su alcance: el desglose muestra "Afinidad: +1".
  4. Jugar C hasta pasar la ronda 6 (con Esperar si hace falta): la línea de hambre de combate tiene que aparecer al cerrar la ronda 6, no la 5.
  5. Durante la secuencia de la IA, el anillo no aparece.
  6. Anotar si el panel de la cadena ("Cadena: Tasajero (2)") se lee bien o si el número parece vida.
- **Para la próxima sesión:** nada: tarea terminada. Faltan el commit, el PR y la prueba manual.

## T42 · sesión 1 · 07/10/2026
- **Rama:** tarea/T42-camara
- **Estado:** TERMINADA (pendiente de PR y de la prueba manual del usuario)
- **Hecho:**
  - **Cómo estaba:** la vista ya tenía un `Camera2D` (`Camara`) y ya convertía el mouse con `TileMapLayer.get_local_mouse_position()` + `local_to_map`, en clic y en hover: no hubo que reemplazar la conversión. Pero `_dibujar_tablero` centraba la cámara en cada `redibujar()`. Ahora el encuadre se hace una sola vez, al abrir, y después la cámara solo la mueve el jugador (D-003).
  - **`EncuadreCamara`** (`pantalla/combate/encuadre_camara.gd`, `RefCounted`, estática, sin nodos):
    - `limites(esquina_a, esquina_b, margen)`: el rectángulo entre `map_to_local` de las esquinas, más el margen.
    - `acotar_zoom` y `acotar_centro(centro, visible, limites)`: lo visible no sale de los límites; en el eje donde es más grande que los límites, queda centrado.
    - `entra_entero` e `inicial(...)`: si el tablero entra con el zoom mínimo, se encuadra entero con el zoom más cercano a 1 que lo muestra entero; si no, se centra en el Maestro (o en el tablero si no tiene posición) con zoom 1 acotado.
  - **`VistaCombate`:**
    - `@export` de presentación: `zoom_minimo` 0,5, `zoom_maximo` 2, `paso_zoom` 0,25, `velocidad_camara` 600 (píxeles de pantalla por segundo) y `margen` 64.
    - `_encuadrar()` en `empezar`. El tamaño sale de `contexto().tablero`, nunca escrito.
    - `_process`: las cuatro direcciones con `Input.get_vector`. `_unhandled_input`: rueda (`camara_acercar`/`camara_alejar`) y arrastre (`InputEventMouseMotion` con `camara_arrastrar` apretada).
    - Consultas y comandos nuevos: `camara()`, `limites_camara()`, `casilla_bajo_mouse()`, `mover_camara(desplazamiento)`, `acercar()` y `alejar()`.
    - Todo movimiento termina en `_acotar_camara()`: acota y, si con el mouse quieto cambió la casilla bajo el mouse, rearma el hover.
    - La cámara anda durante la secuencia de la IA (el hover sigue apagado ahí) y nunca se mueve sola.
  - **InputMap:** `camara_arriba` (↑, W), `camara_abajo` (↓, S), `camara_izquierda` (←, A), `camara_derecha` (→, D), `camara_acercar` (rueda arriba), `camara_alejar` (rueda abajo) y `camara_arrastrar` (botón del medio). No pisan F3, R, Z, Espacio ni el clic izquierdo.
  - **Fixture** `pruebas/fixtures/pantalla/escenario_12x12.json` (valida con `escenario`): Maestro [0,11], Rodauva [1,11], Ocarra salvaje [11,0].
- **Archivos:** creados `pantalla/combate/encuadre_camara.gd`, `pruebas/pantalla/test_encuadre_camara.gd`, `pruebas/pantalla/test_vista_camara.gd`, `pruebas/fixtures/pantalla/escenario_12x12.json`; modificados `pantalla/combate/vista_combate.gd`, `project.godot` (InputMap), `CLAUDE.md` (Estado actual).
- **Tests:** 16 nuevos (7 de `EncuadreCamara`, 9 de la vista), total 355, todos pasan (sí). Ningún test anterior cambió.
- **Criterio de terminado:** cumplido punto por punto:
  1. `test_clic_y_hover_con_la_camara_movida` (zoom y cámara movida, mouse y clic reales: hover en la casilla y movimiento a esa casilla) y `test_hover_sigue_al_mover_la_camara`.
  2. `test_direcciones_no_salen_de_los_limites` (las cuatro acciones, con el zoom de apertura y el máximo) y `test_arrastrar_no_sale_de_los_limites`.
  3. `test_zoom_respeta_minimo_y_maximo` (rueda por `Input.parse_input_event`).
  4. `test_escenarios_abren_dentro_de_los_limites` (los 11 de `datos/` y el de 12 × 12) y `test_sin_entrar_centra_en_el_maestro`.
  5. `test_recargar_a_mitad_de_un_desplazamiento` (sobre `principal.tscn`, con `camara_derecha` apretada).
  6. Los tests de pantalla anteriores pasan sin cambios. Además, `test_camara_durante_la_secuencia_de_la_ia`.
  - Consola: sin errores ni advertencias nuevas. Los dos `ERROR` del debugger remoto (`127.0.0.1:0`) son del arranque de `runtest.cmd`.
- **Lecturas declaradas:** ninguna de reglas. Supuestos de presentación: el encuadre no agranda más allá de zoom 1 (los 8 × 8 se ven igual que antes); el zoom suma o resta un paso y se centra en la cámara, no en el mouse; la velocidad se divide por el zoom (en pantalla se mueve igual con cualquier zoom). Con la ventana de 1152 × 648, el 12 × 12 entra entero con el zoom mínimo 0,5: abre encuadrado entero, no en el Maestro.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** ninguna nueva; ninguna cerrada.
- **Lista de prueba manual:**
  1. F5 → A. Mover la cámara con las flechas y con WASD, acercar y alejar con la rueda, y arrastrar con el botón del medio: no se sale del tablero (más el margen) y el zoom tiene tope en los dos sentidos.
  2. Con la cámara movida y con zoom, jugar A con el mouse: los clics y las marcas azules y rojas caen en la casilla correcta. Con el mouse quieto, mover la cámara con el teclado: el tooltip y las marcas de afinidad pasan a la casilla nueva.
  3. Durante la secuencia de la IA, mover la cámara: no se rompe nada, la secuencia sigue, y la cámara no vuelve sola al centro (tampoco al terminar la secuencia).
  4. Apretar R mientras se desplaza la cámara (tecla sostenida o arrastre): reinicia sin errores en la consola.
  5. Abrir C y E: la cámara encuadra el tablero entero y centrado.
  6. Opcional: en el inspector de `vista_combate.tscn`, probar otros `zoom_minimo`, `velocidad_camara` y `margen`.
- **Para la próxima sesión:** nada: tarea terminada. Faltan el commit, el PR y la prueba manual.

## T43 · sesión 1 · 07/10/2026
- **Rama:** tarea/T43-escenarios-12
- **Estado:** TERMINADA (pendiente de PR, de la prueba manual del usuario y de la aprobación de Sistemas, P-030)
- **Hecho:**
  - **Dato** (`Sistema.md` 11.3 v1.6): `datos/tablas/combate.json` `despliegue_filas` pasa de 2 a 3 (tribu en las filas 9 a 11, enemigas en las 0 a 2), y la `_nota` cita 11.3 v1.6. El esquema ya lo admitía (`integer`, `minimum: 1`). **La huella cambia:** al reproducir grabaciones anteriores, el aviso del reproductor es lo esperado.
  - **Escenarios:** `a_dia_1`, `b_muro`, `c_tasajero`, `d_rivales_normal`, `d_rivales_hambriento`, `d_rivales_balanza4`, `e_cobardia`, `e_cobardia_afines`, `f_rescate` y `h_soplo` pasan a 12 × 12, con las coordenadas de la tabla de abajo. Las `_nota` citan 11.9 v1.6. No cambian las semillas, las lealtades, el hambre ni nada más. Comparten coordenadas: C y H, las tres D y las dos E. `g_ataque_nocturno` no se tocó.
  - **Test permanente** `pruebas/datos/test_contacto.gd` (con `datos/` real). Juega cada escenario con el jugador esperando (solo `terminar`). Lee el registro (`ataque`, `movimiento`, `accion.paso`, `turno.marca`, `oculto`, `destape`, `fin_turno.posicion`), la `instantanea` y consultas del núcleo (`Tablero.despliegue`, `distancia`, `es_vecina_en_8`, `Objetivos.cuenta_como_rival_a_su_alcance`, `ContextoCombate.relaciones`). No calcula reglas por su cuenta. Las coordenadas salieron bien en la primera corrida: no hubo que iterar.
  - Ningún cambio en `nucleo/` ni en `pantalla/`.
  - **Tabla de cotejo (A.2.2):**

    | Valor | Archivo y campo | Sección |
    |---|---|---|
    | Filas de despliegue por bando: 3 (antes 2) | `tablas/combate.json` `despliegue_filas` | 11.3 v1.6 |
    | Tablero 12 × 12 en A a F y H; G en 8 × 8 | `escenarios/*.json` `tablero` | 11.3 y 11.9 v1.6 |

  - **Tabla de coordenadas para A.9** (reemplaza a "Posiciones iniciales provisorias en 8 × 8"; `[x, y]`, `y = 0` arriba; M = Maestro):

    | Escenario | Tribu | Enemigas | Lo que buscan |
    |---|---|---|---|
    | A | M [5,10], Rodauva [6,10] | Ocarra [6,2] | La Ocarra, a 8 de la Rodauva y a 9 del Maestro, va por la Rodauva: se acerca en la ronda 1 y la golpea en la 2 |
    | B | M [4,9], Rodauva [6,10] | Ocarras [4,1] y [6,2] | Cada una va por la unidad que tiene más cerca. Llegan en la ronda 2 a 2 casillas una de otra, sin ser vecinas: juntarlas es una jugada de la Lanzadera (T22) |
    | C y H | M [5,10], Rodauva [4,10], Ocarra [4,11], Zancajunco [6,10] | Tasajero [5,2] | Se acerca en la ronda 1 y caza en la 2. La Rodauva queda en la zona de Caza si el jugador no la mueve. La Ocarra y el Zancajunco no empiezan vecinos |
    | D (3 variantes) | M [5,10], Ocarra [5,11], Zancajunco [6,11] | Surcón [4,2], Rodauva [5,2] | Las rivales aliadas empiezan vecinas. La Rodauva salvaje abre el combate en la ronda 2 |
    | E (2 variantes) | M [4,10], Rodauva leal [6,10], Rodauva Neutral [6,11], Surcón [4,11] | Tasajero [8,2] | A 10 de las Rodauvas: ninguna rival a su alcance en la ronda 1, sí en la 2 |
    | F | M [5,10] (vida 6), Rodauva [5,11], Ocarra [6,11] | Zancajunco [5,2], Surcón [6,2] | Se oculta en la 1, avanza con el bono en la 2 y en la 3 pega 7 al Maestro |
    | G | Sin cambios (8 × 8) | — | — |

- **Archivos:**
  - Creados: `pruebas/datos/test_contacto.gd`.
  - Modificados:
    - Datos: `datos/tablas/combate.json` y los 10 escenarios de arriba.
    - Tests: `pruebas/datos/test_datos_completos.gd` y `pruebas/pantalla/test_vista_camara.gd` (solo un comentario).
    - Documentos: `docs/PREGUNTAS.md` (P-030) y `CLAUDE.md` (Estado actual).
- **Tests:** 10 nuevos (`test_contacto.gd`). Total 365, todos pasan (sí). En la consola, solo los dos `ERROR` del "Remote Debugger" del runner, que ya salían antes.
- **Criterio de terminado:** cumplido punto por punto.
  1. `test_contacto.gd` pasa en los 11 escenarios:
     - `test_tableros_y_zonas` y `test_distancia_minima`: 8; en E, 10.
     - `test_ninguna_enemiga_ataca_en_la_ronda_1`.
     - Uno por escenario: `test_a_ocarra_va_por_la_rodauva`, `test_b_ocarras_llegan_sin_juntarse`, `test_c_y_h_caza_en_la_ronda_2`, `test_d_rivales_vecinas_y_ataque_en_la_ronda_2`, `test_e_rival_a_su_alcance_en_la_ronda_2`, `test_f_zancajunco_oculto_avanza_y_pega_7` y `test_g_llega_al_jugador`.
     - Con los datos viejos, fallaba en las zonas, las distancias, el ataque de la ronda 1 de A, C y H, B en diagonal ([3,0]/[4,1] y [3,3]/[4,4]) y C y H.
  2. `datos/` carga sin errores. Los 11 llegan al primer turno del jugador: `test_combate.gd` (9), `test_vista_combate.gd` (3) y `test_g_llega_al_jugador`.
  3. **Probado:** con el Tasajero de C en [5,5] (distancia 5 al Maestro), fallan cuatro tests: `test_tableros_y_zonas` (fuera de las filas 0 a 2), `test_distancia_minima`, `test_ninguna_enemiga_ataca_en_la_ronda_1` y `test_c_y_h_caza_en_la_ronda_2`. Revertido: C vuelve a [5,2] y el test pasa.
  4. Los tests de T06 (`test_tablero.gd`, con su fixture `pruebas/fixtures/combate/combate.json`) pasan sin cambios.
  5. Tests reescritos (ninguno borrado):
     - `pruebas/datos/test_datos_completos.gd::test_a_dia_1_es_el_ejemplo_de_a2`. **Corrige el plan:** no lo había previsto. Comparaba `a_dia_1` entero con el ejemplo de A.2 en 8 × 8. Por `Sistema.md` 11.9 v1.6 (y A.2: "desde T43, A pasa a 12 × 12"), ahora no compara el tablero, las posiciones ni sus `_nota`; el resto sigue igual al ejemplo.
     - `pruebas/pantalla/test_vista_camara.gd::test_escenarios_abren_dentro_de_los_limites`: solo cambió el comentario ("Los de 8 x 8 entran enteros" → los de 12 × 12 y G), citando 11.9 v1.6. La aserción no cambió.
     - Los demás tests con `datos/` real que preveía el plan (A y C jugados por la vista, el clic real, R durante la secuencia, el desglose de A) pasan sin cambios.
  6. `addons/gdUnit4/runtest.cmd -a res://pruebas`: 365/365.
- **Lecturas declaradas:** ninguna de reglas. Coordenadas propuestas, pendientes de la aprobación de Sistemas (P-030), con dos avisos: en B cada Ocarra va por un objetivo distinto (con las dos a 8, ir las dos por la Rodauva las junta en diagonal), y en C/H la Ocarra pasa detrás de la Rodauva, para no empezar en diagonal con el Zancajunco.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** nueva P-030 (SISTEMAS, no bloquea). Ninguna cerrada.
- **Aviso:** las grabaciones anteriores cambian de huella y de posiciones. El aviso del reproductor es lo esperado (B.3.1).
- **Lista de prueba manual (usuario):**
  1. `addons/gdUnit4/runtest.cmd -a res://pruebas`: todo en verde.
  2. F5. En A, B, C y E, apretar Esperar en todos los turnos y mirar los sucesos: el primer golpe enemigo llega en la ronda 2, no en la 1. En E llega en la 3, pero el Tasajero ya está al alcance de las Rodauvas en la 2.
  3. En F, apretar Esperar: el Zancajunco se oculta en la ronda 1, avanza en la 2 y en la 3 tumba al Maestro.
  4. En B, mirar que las dos Ocarras no terminen pegadas (ni en diagonal) al final de las rondas 1 y 2.
  5. Abrir G: se ve igual que antes, en 8 × 8, y la cámara lo encuadra entero.
  6. Jugar C de verdad, con el mouse: ¿la ronda 1 da tiempo para acomodarse (sacar a la Rodauva de la zona de Caza, esconder al Zancajunco)? Anotarlo para Sistemas, junto con P-030.
- **Para la próxima sesión:** nada: tarea terminada. Faltan el commit, el PR, la prueba manual y la respuesta de P-030.

## T17 · sesión 1 · 07/10/2026
- **Rama:** tarea/T17-secundar
- **Estado:** TERMINADA (pendiente de PR y de la prueba manual del usuario)
- **Hecho:**
  - **Acción** (`Sistema.md` 10.1): `Accion.secundar(aliado_id)`, con `{"tipo": "secundar", "aliado": id}` y la ida y vuelta por diccionario. Primero el esquema: `grabacion.schema.json` suma `secundar` al enum y la propiedad `aliado`.
  - **Cola** (`ColaIniciativa`):
    - `orden_si_secunda` (calcular sin aplicar) y `secundar` usan la misma función, `_reordenar`. Saca la entrada del turno en curso y la pone justo detrás de la de la aliada; el resto no se reordena.
    - Al aplicar, el cursor retrocede uno y la entrada queda pendiente, con `EntradaCola.vuelve = true`.
    - Consultas nuevas: `pendiente(unidad_id, plantel)` y `lugar_de(unidad_id)`.
  - **Turno** (`Turno`):
    - `Turno.empezar(..., cadena, cola)`: la cola es un parámetro obligatorio, como la cadena en T16.
    - **Turno que vuelve y turno nuevo:** lo dice la entrada. Si `entrada.vuelve`, no corre `_inicio_del_turno`; `_preparar` corre siempre. Así, el borrado de Erizarse, el cambio de modo y los puntos de T18, T19, T21 y T25 corren una vez por ronda (S-31).
    - **Regla de quién Secunda:** está toda en `_motivo_puede_secundar`, con el lugar de T19 marcado (enconada o acobardada). Acepta solo a la tribu (`SALVAJE_NO_SECUNDA`) y con el turno sin usar (`YA_SE_MOVIO` y `ACCION_USADA`, S-29).
    - **Rechazos por la aliada** en `_secundar`: `OBJETIVO_INEXISTENTE`, `SECUNDAR_A_SI_MISMA`, `ALIADA_DE_OTRO_BANDO` y `ALIADA_SIN_ENTRADA_PENDIENTE`. Este último cubre la que ya actuó, la caída, la guardada y "más allá del final de la ronda".
    - Al aplicar, el turno se cierra **sin** `_fin_del_turno`: `junco_turno_anterior` se escribe recién cuando el turno termina de verdad. No toca la cadena (10.2).
    - Consultas: `puede_secundar()`, `aliadas_para_secundar()` y `cola_si_secunda(aliado_id)`.
  - **Combate:**
    - Evento `secundar` (`unidad`, `detras_de`, `lugar` desde 0), sin `fin_turno`.
    - Cuando la entrada vuelve, evento **`turno_vuelve`** (`unidad`) en lugar de otro `turno`. Es una decisión técnica: A.7 dice que `turno` va una vez por ronda y que las tareas agregan tipos.
    - La IA no cambia.
  - **Pantalla:**
    - `LecturaCombate`: `boton_secundar()`, `filas_cola_si_secunda(aliado_id)` (armadas con un `_fila_cola` compartido con `filas_cola`) y el suceso "Unidad · Secundar · Aliada".
    - `InterpreteClic.accion(..., modo_secundar)` y `aliada_en`; `objetivo_en` usa el mismo `_unidad_de`.
    - `VistaCombate`:
      - El botón `Secundar` (toggle) aparece solo si hay aliadas válidas.
      - `pulsar_secundar()` y `eligiendo_aliada()`. El modo excluye al de cavar.
      - Las aliadas válidas se marcan con la marca de "elegir" (5:0).
      - Con el mouse sobre una aliada, la cola se redibuja con el orden resultante (`_dibujar_cola`).
      - El clic aplica.
    - `ClavesTextos.ACCION_SECUNDAR` (`accion.secundar`, ya está en `es.json`).
  - **Preguntas:** S-29 a S-31 registradas como P-031 a P-033.
- **Archivos:**
  - Creados: `pruebas/combate/test_secundar.gd` y `pruebas/pantalla/test_vista_secundar.gd` (con sus `.uid`).
  - Modificados:
    - Esquema: `datos/_esquemas/grabacion.schema.json`.
    - Núcleo: `nucleo/combate/accion.gd`, `cola_iniciativa.gd`, `entrada_cola.gd`, `turno.gd`, `combate.gd` y `resultado_accion.gd`.
    - Pantalla: `pantalla/claves_textos.gd` y `pantalla/combate/interprete_clic.gd`, `lectura_combate.gd` y `vista_combate.gd`.
    - Tests: solo se agregó la cola a los llamados a `Turno.empezar`, en `pruebas/combate/ia/test_ia_salvaje.gd` y en `test_afinidad.gd`, `test_cadena.gd`, `test_caza_y_cuenta.gd`, `test_danio.gd`, `test_junco.gd`, `test_surco.gd`, `test_turno.gd` y `test_vida_cero.gd` (`pruebas/combate/`), más `pruebas/pantalla/test_interprete_clic.gd`. Ninguna aserción cambió y ningún test se reescribió.
    - Fixture: `pruebas/fixtures/pantalla/es_rasgos.json` suma `accion.secundar`.
    - Documentos: `docs/PREGUNTAS.md` y `CLAUDE.md` (Estado actual).
- **Tests:** 17 nuevos (15 de núcleo y 2 de pantalla). Total 382, todos pasan (sí), con `test_contacto.gd`. En la consola, solo los dos `ERROR` del "Remote Debugger" del runner, que ya salían antes; `--import`, sin advertencias.
- **Criterio de terminado:** cumplido punto por punto.
  1. `test_prueba_c` y `test_prueba_c_con_el_combate`: Tasajero, Ocarra, Zancajunco, Rodauva y Maestro; el `turno` del Tasajero va antes de que vuelva el Zancajunco.
  2. `test_detras_de_la_ultima`.
  3. `test_rechazos` y `test_rechazos_despues_de_atacar_y_guardada`: enemiga, sí misma, inexistente, caída, guardada, aliada que ya actuó, después de mover y de atacar, y una salvaje. En cada caso, la cola, el lugar, el Plantel y el turno no cambian.
  4. `test_volver_a_secundar` y `test_volver_sin_aliada_detras`.
  5. `test_s31_erizarse_una_vez` y `test_s31_cambio_de_modo_una_vez` (con `escenario_caza_tribu`, el de T36).
  6. `test_cadena_sin_enemigas_en_el_medio` (eslabón 2) y `test_cadena_con_enemiga_en_el_medio` (corte `enemiga`, cadena nueva y eslabón 2 del que Secundó). **Corrige el plan:** no hice la fixture nueva con el Tasajero. Usé `escenario_cadena_combate.json` de T16: la objetivo es el Surcón salvaje y la enemiga del medio es la Rodauva encerrada, que solo espera. Así el resultado no depende de cómo se mueve la IA del Tasajero.
  7. `test_cola_si_secunda`: la cola prevista es la aplicada, y la `instantanea` y `combate.cola()` no cambian.
  8. `test_registro_y_grabacion` y `test_accion_ida_y_vuelta`: la grabación valida contra el esquema y la reproducción da el mismo registro.
  9. `test_boton_hover_y_clic` y `test_sin_aliadas_no_hay_boton`.
  10. `addons/gdUnit4/runtest.cmd -a res://pruebas`: 382/382.
- **Lecturas declaradas:**
  - P-031 (S-29): solo con el turno sin usar.
  - P-032 (S-30): se puede volver a Secundar si queda otra aliada pendiente detrás.
  - P-033 (S-31): el inicio del turno y el cambio de modo corren una vez por ronda.
  - Técnica: el evento `turno_vuelve`.
  - Técnica: si la unidad que Secundó cae o es guardada antes de volver, pierde su entrada (11.3) y su fin del turno no corre.
- **Claves de texto nuevas sin texto:** ninguna (`accion.secundar` ya está en `es.json`).
- **Preguntas:** nuevas P-031, P-032 y P-033 (SISTEMAS, no bloquean). Ninguna cerrada.
- **Lista de prueba manual (usuario):**
  1. `addons/gdUnit4/runtest.cmd -a res://pruebas`: todo en verde.
  2. F5 y elegir C. En el turno del Zancajunco (ronda 1 o 2), apretar Secundar: se marcan la Rodauva, la Ocarra y el Maestro. Pasar el mouse por la Ocarra: la cola muestra al Zancajunco detrás de ella. Clic: actúa el Tasajero, después la Ocarra y después el Zancajunco. En los sucesos se lee "Zancajunco · Secundar · Ocarra".
  3. Pegarle al Tasajero con la Ocarra y después con el Zancajunco: el desglose del segundo golpe muestra "Cadena".
  4. Moverse con una unidad: el botón Secundar desaparece.
  5. En A, la Rodauva puede Secundar al Maestro y actúa después de él.
  6. Apretar Secundar dos veces: sale del modo y vuelven las marcas de mover y atacar.
- **Para la próxima sesión:** nada: tarea terminada. Faltan el commit, el PR y la prueba manual.

## T18 · sesión 1 · 07/10/2026
- **Rama:** tarea/T18-incidentes
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:**
  - **Regla** (`Sistema.md` 10.4 v1.6, 1.3, 5.4, 11.2.2, 11.3 paso 4 y 11.5): `Incidente` (`nucleo/combate/incidente.gd`) es una regla sin estado y vive en `ContextoCombate.incidente`.
    - **Rivales:** mismo bando, de pie por `Objetivos.de_pie` (la oculta cuenta; la caída, la guardada y la que está fuera, no), par `mal` en `relaciones.json` y vecina en 8 por `Tablero.es_vecina_en_8`.
    - **Porcentaje:** base de `combate.json` + `Arrimo.ajuste(pasos, INCIDENTE)`, con piso 0.
    - `consulta` sirve para la tirada y para la pantalla. Una sola tirada por turno y, con 0 %, ninguna.
    - Hoy tiran solo las criaturas de la tribu: las salvajes son de T20.
    - Es una clase aparte de `Turno` porque `Combate.incidente_en` necesita la misma cuenta sin un turno y con una casilla hipotética, y T20 la reusa.
  - `Porcentajes.tirar(azar, pct)`: la convención única de las tiradas en % (`entero(1, 100) <= pct`).
  - **`Turno`:**
    - `empezar` recibe la regla y el generador de combate; los dos son obligatorios.
    - El paso 4 (`_chequear_incidente`) va después de `_preparar` y no corre al volver de Secundar (S-31).
    - **Leal o neutral:** se distrae. Pierde la acción (`ACCION_USADA` para atacar, erizarse, cavar, Hacerse junco y Secundar) y conserva el movimiento.
    - **Baja:** golpea a la rival de menos vida que alcanza desde su casilla; si empatan, a la primera de la tribu. Las rivales golpeables pasan por la misma validación del ataque; si no alcanza a ninguna, se distrae.
    - El golpe va por `_atacar_desde(..., por_incidente)`: `Danio` con la afinidad, `Junco` y `VidaCero`.
    - Queda marcado el lugar de T19 ("la enconada no tira").
  - **`Combate`:**
    - Evento `incidente` (`unidad`, `rivales`, `porcentaje`, `resultado` `distraida`/`golpe`, `objetivo`) detrás de `turno` y de su `tirada`. Si golpea, además un `ataque` normal con `eslabon: null`, y después los eventos de Junco, estados, surcos y el `cadena_cortada`.
    - Si la tirada no sale, solo queda la `tirada`.
    - El `cambio_modo` se registra antes de volcar la tirada, porque pasó antes.
    - `incidente_en(unidad_id, casilla)` calcula sin aplicar.
  - **Pantalla:**
    - Capa `Tablero/Rivales` con una marca placeholder nueva (`8:0`, círculo rojo punteado).
    - En el hover de una casilla para mover o de la propia, se marcan las rivales y el aviso suma `incidente.tooltip` con `{porcentaje}` (si es > 0).
    - Suceso del `incidente` con `incidente.distraida` / `incidente.ataque` y la variante del par de especies como sujeto.
    - `ClavesTextos` suma las tres claves y las variantes por par que están en el archivo.
  - **Datos:** sin cambios; la huella no cambia. Tabla de cotejo:

    | Número | Sección | Dónde | Estado |
    |---|---|---|---|
    | 20 % de incidente | `Sistema.md` 10.4 | `tablas/combate.json` `incidente.base_pct` | ya existía |
    | −5 puntos por paso de Arrimo | `Sistema.md` 1.3 | `tablas/arrimo.json` `por_paso.incidente_pts` | ya existía |
    | Pasos de Arrimo | `Sistema.md` 1.2 | `tablas/balanza.json` `pasos_arrimo` | ya existía |
- **Archivos:**
  - **Creados:**
    - `nucleo/combate/incidente.gd`;
    - `pruebas/combate/test_incidente.gd`;
    - `pruebas/pantalla/test_vista_incidente.gd`;
    - en `pruebas/fixtures/combate/`: `combate_incidente_100.json`, `combate_incidente_0.json`, `escenario_incidente.json` y `escenario_incidente_combate.json`.
  - **Modificados:**
    - en `nucleo/combate/`: `turno.gd`, `combate.gd`, `contexto_combate.gd` y `porcentajes.gd`;
    - `pantalla/claves_textos.gd`;
    - en `pantalla/combate/`: `lectura_combate.gd`, `vista_combate.gd`, `vista_combate.tscn`, `casillas_cenital.tres` y `marcas_placeholder.svg`;
    - `pruebas/combate/datos_fixture.gd`;
    - las llamadas a `Turno.empezar` de `test_afinidad`, `test_cadena`, `test_caza_y_cuenta`, `test_danio`, `test_junco`, `test_secundar`, `test_surco`, `test_turno`, `test_vida_cero`, `ia/test_ia_salvaje` y `pantalla/test_interprete_clic`;
    - `test_combate.gd` y `test_vista_rasgos.gd` (reescritos, abajo);
    - `docs/PREGUNTAS.md`, `CLAUDE.md` ("Estado actual") y este archivo.
- **Tests:** 20 nuevos, total 402; todos pasan, `pruebas/datos/test_contacto.gd` incluido. **Reescritos** (ninguno borrado):
  - `test_combate.gd::test_registro_de_una_ronda_de_c`, por `Sistema.md` 10.4 v1.6 y 11.3 paso 4: en C la Ocarra y el Zancajunco de la tribu son rivales vecinas y cada una tira su incidente (5 %; con la semilla de C no sale). Hay dos `tirada` más y la hecha a mano pasa a ser la 2.
  - `test_vista_rasgos.gd::test_marca_y_aviso_de_afinidad`, por `Sistema.md` 10.4 v1.6: en la propia casilla del Zancajunco, la Ocarra rival en diagonal suma la línea del incidente al aviso (el fixture de textos no la tiene: `[FALTA: incidente.tooltip]`).
  - `test_turno.gd::test_turno_sin_azar` y `test_secundar.gd::test_sin_azar`, por `Sistema.md` 10.4 y 11.3 paso 4: `turno.gd` recibe el generador de combate y solo lo pasa a `Incidente.tirar`. Ahora se prohíben `GeneradorAzar.new`, `GeneradorAzar.derivado`, `.entero(`, `.decimal(`, `randi`, `randf` y `RandomNumberGenerator`.
- **Criterio de terminado:** cumplido punto por punto. Todos los tests están en `test_incidente.gd`, salvo los de pantalla.
  1. `test_rival_en_diagonal_tira_y_a_dos_no`.
  2. `test_caida_guardada_fuera_y_otro_bando_no_y_oculta_si`.
  3. `test_aliada_que_no_es_rival_no_tira`.
  4. `test_leal_se_distrae`.
  5. `test_neutral_se_distrae`.
  6. `test_baja_golpea_a_la_rival`: 4 de daño, 5 con una afín en diagonal.
  7. `test_baja_elige_la_de_menos_vida_y_desempata_por_orden`.
  8. `test_baja_sin_rival_al_alcance_se_distrae`.
  9. `test_base_0_no_tira`: comparado con un generador gemelo.
  10. `test_arrimo_y_piso_0`: balanza 2 → 5 %, 5 → 20 %, 1 → 0 % sin tirada; base 0 con la balanza 2 → 0.
  11. `test_turno_que_vuelve_no_tira`.
  12. `test_golpe_corta_la_cadena_sin_empezar_otra`.
  13. `test_incidente_en_coincide_con_la_tirada`.
  14. `test_registro_y_grabacion`.
  - Extras de la fila de `Arquitectura.md`: `test_tres_rivales_una_tirada`, `test_oculta_provoca_pero_no_se_golpea`, `test_golpe_quita_el_bono` y `test_salvajes_y_maestro_no_tiran`.
  - Pantalla (`test_vista_incidente.gd`): `test_aviso_y_marca_de_incidente` y `test_suceso_del_incidente`.
  - `addons/gdUnit4/runtest.cmd -a res://pruebas`: 402/402.
- **Lecturas declaradas:**
  - P-034 (S-32): la oculta provoca, pero no se golpea.
  - P-035 (S-33): el golpe corta la cadena y no empieza otra.
  - P-036 (S-34): el golpe o la distracción gastan todos los ataques del turno (Tasajero en Caza).
  - P-033 (S-31): el turno que vuelve no tira.
  - Técnica: si la tirada no sale, no hay evento `incidente` (solo la `tirada`).
  - Técnica: el `cambio_modo` va antes de la `tirada` del incidente en el registro.
  - Técnica: con 0 % no se marca la rival en pantalla.
- **Claves de texto nuevas sin texto:** ninguna (`incidente.tooltip`, `incidente.distraida`, `incidente.ataque` y las variantes por par ya están en `es.json`).
- **Preguntas:** nuevas P-034, P-035 y P-036 (SISTEMAS, no bloquean). Ninguna cerrada.
- **Lista de prueba manual (usuario):**
  1. `addons/gdUnit4/runtest.cmd -a res://pruebas`: todo en verde.
  2. F5 y elegir **D Normal** (`d_rivales_normal`). En el turno de la Ocarra o del Zancajunco, pasar el mouse por su propia casilla: se marca la rival vecina con el círculo rojo y el aviso dice "5% de incidente: …". Sobre una casilla alcanzable lejos de la rival, el aviso no lo dice.
  3. Pasar el mouse por una casilla en diagonal a la rival: también avisa (vecinas en 8).
  4. Elegir **H Soplo** (balanza 5): el aviso dice 20 %.
  5. Jugar D Normal o D Hambriento terminando turnos con las rivales juntas hasta ver un incidente. En los sucesos sale la línea de `incidente.distraida.*` (Normal) o `incidente.ataque.*` (Hambriento, con el golpe en el registro). Con F3, la línea `incidente` va detrás de `turno` y de su `tirada`.
  6. La distraída todavía se puede mover, y el botón Secundar y los ataques ya no están.
- **Para la próxima sesión:** nada: tarea terminada. Faltan el commit, el PR y la prueba manual.

## T19 · sesión 1 · 07/10/2026
- **Rama:** tarea/T19-encono
- **Estado:** EN CURSO (sigue en la sesión 2: pantalla)
- **Hecho:**
  - Regla nueva `ChequeoRival` (`nucleo/combate/chequeo_rival.gd`), sin estado, en `ContextoCombate.chequeo_rival`. Hace una sola tirada (S-37) para las criaturas de la tribu con alguna rival enemiga a su alcance (`Objetivos.cuenta_como_rival_a_su_alcance`). La rama sale del `rol`: combate y mixto → Encono, trabajo → cobardía.
    - Encono: base + por punto × contador + Arrimo + tramo, entre 0 y 100. Con el contador en el máximo, enconada sin tirar.
    - Cobardía: base + Arrimo + tramo + Maestro de pie vecino en 8. Con el toggle `afines_contra_cobardia` se suman las afines vecinas en 8 sin el Maestro (P-008), con tope y mínimo 5 %; sin el toggle, piso 0.
    - El lugar de las salvajes queda marcado para T20.
  - Contador `Criatura.encono`: todo golpe aplicado de una criatura de combate o mixta a su rival enemiga suma 1, de cualquier bando. El `Cierre` lo vuelve a 0 y la `instantanea` lo muestra.
  - `Turno`:
    - Estados `enconada` y `acobardada`, y `obligacion` (S-35).
    - La enconada que alcanza solo se mueve a casillas desde donde golpea a su rival, su primer ataque va a la rival y no termina sin atacar. La que no alcanza solo se mueve a las casillas de menor distancia, pierde la acción y no termina mientras pueda acercarse.
    - La acobardada no termina más cerca de ninguna rival (S-36) y pega con −50 % en todos sus ataques.
    - Ninguna de las dos Secunda. La enconada no tira incidente.
    - Bono plano del Encono por `_aportes`: validar, previsualizar y aplicar dan lo mismo.
  - `Combate`:
    - Eventos `chequeo_rival` (detrás de `turno`, `cambio_modo` y su `tirada`, antes del incidente) y `encono` (detrás del `ataque`).
    - `_registrar` vuelca solo las tiradas que corresponden.
    - `rival_en(unidad_id, casilla)` calcula sin aplicar.
  - `test_contacto.gd`: el ayudante juega lo mínimo que obliga una regla. Pasa sin tocar coordenadas ni criterios.
  - P-008 aplicada y `CERRADA`.
- **Archivos:**
  - Creados: `nucleo/combate/chequeo_rival.gd`; `pruebas/combate/test_chequeo_rival.gd`, `test_enconada.gd`, `test_acobardada.gd`; en `pruebas/fixtures/combate/`: `combate_rival_100.json`, `combate_rival_0.json`, `combate_sin_rival.json`, `escenario_rival.json`, `escenario_rival_combate.json`, `escenario_caza_tribu_encono.json`, `especie_rival_prueba.json`, `relaciones_rival_prueba.json`.
  - Modificados en el núcleo: `turno.gd`, `combate.gd`, `contexto_combate.gd`, `objetivos.gd` (parámetro opcional `desde`), `resultado_accion.gd` (8 motivos), `cierre.gd`, `unidades/criatura.gd`, `unidades/plantel.gd`.
  - Modificados en las pruebas: `datos_fixture.gd` (`chequeo_rival`) y los 13 archivos que crean un `Turno` suelto (parámetro nuevo, sin otro cambio), `test_combate.gd`, `test_incidente.gd`, `test_junco.gd`, `test_contacto.gd`.
  - Modificados en docs: `docs/PREGUNTAS.md`, `CLAUDE.md` (Estado actual).
  - Sin cambios en `datos/` ni en `pantalla/`: la huella no cambió.
- **Tests:** 19 nuevos, total 421, todos pasan (sí).
- **Tests viejos reescritos** (ninguno borrado):
  1. `test_combate.gd::test_registro_de_una_ronda_de_c` (10.6 y 11.3 paso 3 v1.6): la Rodauva de C tira su cobardía (15 %: leal, balanza 2, Maestro vecino). Se suman `tirada` y `chequeo_rival`, y cuatro tiradas en lugar de tres.
  2. `test_junco.gd::test_atacar_destapa_y_cobra` (10.5): el golpe del Zancajunco a la Ocarra suma el evento `encono` antes del `destape`.
  3. `test_junco.gd::test_registro_instantanea_y_grabacion` (10.5): entre el `ataque` de la Ocarra salvaje y el `bono_perdido` va su `encono`.
  4. `test_incidente.gd` (10.5 y 10.6, 11.3 paso 3): los turnos del archivo usan `combate_sin_rival.json` para el chequeo, así el generador mide solo el incidente. Cambia solo el ayudante `_turno` y tres llamadas a `Turno.empezar`; las aserciones no cambian. Fallaban por eso `test_rival_en_diagonal_tira_y_a_dos_no`, `test_caida_guardada_fuera_y_otro_bando_no_y_oculta_si`, `test_aliada_que_no_es_rival_no_tira`, `test_base_0_no_tira`, `test_turno_que_vuelve_no_tira` y `test_tres_rivales_una_tirada`.
- **Criterio de terminado:** parcial (sesión 1).
  - Cumplido punto por punto:
    1. `test_porcentaje_del_encono`.
    2. `test_porcentaje_de_la_cobardia`.
    3. `test_toggle_de_afines`.
    4. `test_a_su_alcance`.
    5. `test_rama_por_rol`.
    6. `test_golpe_voluntario_suma_sin_bono`, `test_ocarra_enconada_pega_5_6_7_7` y `test_salvaje_suma_y_cierre_en_0`.
    7. `test_enconada_que_alcanza`.
    8. `test_enconada_que_no_alcanza`.
    9. `test_tasajero_enconado_en_caza`.
    10. `test_pega_la_mitad_y_no_secunda`, `test_no_se_acerca_a_la_rival` y `test_puede_atacar_a_su_rival`.
    11. `test_enconada_no_tira_incidente` y `test_secundo_no_rechequea`.
    12. `test_rival_en`.
    13. `test_registro_del_chequeo_y_del_incidente` y `test_registro_instantanea_y_grabacion`.
    15. (adelantado) El test de contacto y todos los tests pasan.
    16. (adelantado) Tests viejos reescritos y listados arriba.
  - Falta el punto 14 (pantalla).
- **Lecturas declaradas:**
  - S-35, al pie de la letra: la restricción de casillas de la enconada que alcanza dura todo el turno; la del objetivo y la de `terminar` se cumplen con el primer ataque (10.5, Tasajero en Caza).
  - S-36 y S-37, tal cual 10.5 de `Arquitectura.md`.
  - S-31: no rechequea al volver de Secundar.
  - Bono del Encono en todo golpe de la enconada a una rival del chequeo ("voluntario" = sin estar enconada, 10.5).
  - El −50 % de la acobardada rige también en el golpe del incidente ("en todos sus ataques").
  - Técnicas:
    - Con el contador en el máximo, el porcentaje informado es 100 (`seguro`).
    - El evento `encono` sale solo si el contador cambió.
    - Con el toggle, el mínimo de 5 % rige siempre.
    - Sin rivales o con 0 %, no hay `chequeo_rival`.
    - La clave `tipo_chequeo` sale de P-037.
- **Claves de texto nuevas sin texto:** ninguna (el núcleo no usa claves; las de pantalla van en la sesión 2).
- **Preguntas:** nueva P-037 (ARQUITECTO, no bloquea); cerrada P-008.
- **Para la próxima sesión:**
  - Pantalla (punto 14):
    - Con el mouse sobre una casilla alcanzable o la propia, marcar las rivales enemigas a su alcance (`Combate.rival_en`) y sumar al aviso `encono.tooltip` o `cobardia.tooltip` con `{porcentaje}` si es mayor que 0.
    - Contador del Encono en la ficha y en el tooltip.
    - Marcas de enconada y acobardada.
    - Sucesos de `chequeo_rival` y `encono`.
    - El botón de terminar sigue `puede_terminar()`: hoy, con una enconada, el botón puede no responder.
  - Lista de prueba manual en el resumen final.

## T19 · sesión 2 · 08/10/2026
- **Rama:** tarea/T19-encono
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho (la tarea entera, sesiones 1 y 2):**
  - **Regla** (`Sistema.md` 10.5, 10.6, 5.4, 1.3, 11.2.2, 11.3 paso 3 y 11.5 v1.6; K-06): `ChequeoRival` (`nucleo/combate/chequeo_rival.gd`), sin estado, en `ContextoCombate.chequeo_rival`.
    - Una sola tirada (S-37) para las criaturas de la tribu con alguna rival enemiga a su alcance (`Objetivos.cuenta_como_rival_a_su_alcance`, con `desde` opcional). La rama sale del `rol`: combate y mixto → Encono, trabajo → cobardía.
    - **Encono:** base + por punto × contador + Arrimo + tramo, entre 0 y 100. Con el contador en el máximo, enconada sin tirar.
    - **Cobardía:** base + Arrimo + tramo + Maestro de pie vecino en 8. Con el toggle `afines_contra_cobardia`, se suman las afines vecinas en 8 sin el Maestro (P-008), con tope y mínimo 5 %. Sin el toggle, el piso es 0.
    - El lugar de las salvajes queda marcado para T20.
  - **Contador `Criatura.encono`:** todo golpe aplicado de una criatura de combate o mixta a su rival enemiga suma 1, de cualquier bando. El `Cierre` lo vuelve a 0. `plantel.gd` solo cambió en eso: la `instantanea` suma `encono` por criatura.
  - **`Turno`:**
    - Estados `enconada` y `acobardada`, y `obligacion` (`ATACAR` / `ACERCARSE`, S-35).
    - La enconada que alcanza solo se mueve a casillas desde donde golpea a su rival, su primer ataque va a la rival y no termina sin atacar.
    - La que no alcanza solo se mueve a las casillas de menor distancia, pierde la acción y no termina mientras pueda acercarse.
    - La acobardada no termina más cerca de ninguna rival (S-36) y pega con −50 %.
    - Ninguna de las dos Secunda. La enconada no tira incidente.
    - El bono del Encono va por `_aportes`.
  - **`Combate`:**
    - Eventos `chequeo_rival` (detrás de `turno`, `cambio_modo` y su `tirada`, antes del incidente) y `encono` (detrás del `ataque`).
    - `_registrar` vuelca solo las tiradas que corresponden.
    - `rival_en(unidad_id, casilla)` calcula sin aplicar.
  - **`test_contacto.gd`:** el ayudante juega lo mínimo que obliga una regla (`_jugar_lo_obligado`). Pasa sin tocar coordenadas ni criterios.
  - **Pantalla (sesión 2):**
    - **Hover:** con el mouse sobre una casilla para mover o sobre la propia, se marcan las rivales de `Combate.rival_en` en la capa nueva `Tablero/RivalesEnemigas` (marca `9:0`, rombo violeta, distinta del círculo rojo de las rivales aliadas). El aviso suma `encono.tooltip` o `cobardia.tooltip` con `{porcentaje}`. Con 0 % o sin rivales, nada. Durante la secuencia de la IA, el hover sigue bloqueado.
    - **Botón de terminar:** `LecturaCombate.boton_terminar()` reemplaza a `texto_terminar()`. El botón sigue `puede_terminar()`. Si lo bloquea la obligación, el motivo (`ClavesTextos.motivo_terminar`, una clave por motivo) va en el tooltip del botón y al final del panel del turno.
    - **Marcas:** `marca.enconada` y `marca.acobardada` en la ficha y en el tooltip de la unidad del turno, con la especie como sujeto (concordancia).
    - **Contador:** `Encono: n/máx` en el tooltip de toda criatura de Encono, de los dos bandos y también en 0, y en la ficha cuando es mayor que 0.
    - **Sucesos:**
      - `chequeo_rival`: con la primera rival, la reacción del par (`encono.<especie>.<rival>`) o de la especie (`cobardia.<especie>`) si existe; si no, la línea general (`encono.inicio`, `cobardia.inicio`). Resistida: `cobardia.resiste`, con la variante de la especie. `no_enconada` no tiene línea.
      - `encono`: `encono.sube`.
    - **Consultas nuevas del núcleo**, sin cambiar reglas: `ChequeoRival.maximo_encono()` y `ArmadorTextos.tiene(clave)`.
    - `ClavesTextos` suma las claves nuevas y las variantes que están en el archivo: por par, por especie y `cobardia.resiste.<especie>`, nunca `.maestro`.
  - P-008 aplicada y `CERRADA`. P-038 a P-040 nuevas (abajo).
  - **Datos:** sin cambios; la huella no cambió.
- **Archivos (la tarea entera):**
  - **Creados:**
    - `nucleo/combate/chequeo_rival.gd`;
    - `pruebas/combate/test_chequeo_rival.gd`, `test_enconada.gd` y `test_acobardada.gd`;
    - `pruebas/pantalla/test_vista_rival.gd`;
    - en `pruebas/fixtures/combate/`: `combate_rival_100.json`, `combate_rival_0.json`, `combate_sin_rival.json`, `escenario_rival.json`, `escenario_rival_combate.json`, `escenario_caza_tribu_encono.json`, `especie_rival_prueba.json` y `relaciones_rival_prueba.json`;
    - `pruebas/fixtures/pantalla/escenario_cobardia_pantalla.json`.
  - **Modificados en el núcleo:**
    - en `nucleo/combate/`: `turno.gd`, `combate.gd`, `contexto_combate.gd`, `objetivos.gd`, `resultado_accion.gd` (8 motivos) y `cierre.gd`;
    - `nucleo/unidades/criatura.gd` y `plantel.gd`;
    - `nucleo/textos/armador_textos.gd` (`tiene`).
  - **Modificados en la pantalla:**
    - `pantalla/claves_textos.gd`;
    - en `pantalla/combate/`: `lectura_combate.gd`, `vista_combate.gd`, `vista_combate.tscn`, `casillas_cenital.tres` y `marcas_placeholder.svg`.
  - **Modificados en las pruebas:**
    - `datos_fixture.gd` (`chequeo_rival`);
    - los 13 archivos que crean un `Turno` suelto (parámetro nuevo);
    - `test_combate.gd`, `test_incidente.gd`, `test_junco.gd`, `test_contacto.gd`, `test_armador_textos.gd`, `test_claves_textos.gd` y `test_lectura_combate.gd`.
  - **Docs:** `docs/PREGUNTAS.md`, `CLAUDE.md` ("Estado actual") y este archivo.
- **Tests:** 29 nuevos (19 en la sesión 1 y 10 en la 2), total 431; todos pasan, `pruebas/datos/test_contacto.gd` incluido.
- **Tests viejos reescritos** (ninguno borrado):
  1. `test_combate.gd::test_registro_de_una_ronda_de_c`, por 10.6 y 11.3 paso 3 v1.6: la Rodauva de C tira su cobardía (15 %). Se suman `tirada` y `chequeo_rival`, y hay cuatro tiradas en lugar de tres.
  2. `test_junco.gd::test_atacar_destapa_y_cobra`, por 10.5: el golpe del Zancajunco a la Ocarra suma el evento `encono` antes del `destape`.
  3. `test_junco.gd::test_registro_instantanea_y_grabacion`, por 10.5: entre el `ataque` de la Ocarra salvaje y el `bono_perdido` va su `encono`.
  4. `test_incidente.gd`, por 10.5, 10.6 y 11.3 paso 3: los turnos del archivo usan `combate_sin_rival.json` para el chequeo. Cambian solo el ayudante `_turno` y tres llamadas a `Turno.empezar`; las aserciones no cambian.
  5. (Sesión 2) `test_lectura_combate.gd::test_t40_tooltip_de_una_enemiga`, por 10.5 v1.6: el tooltip del Tasajero de C suma su contador, `[FALTA: panel.encono]: 0/3` (el fixture de textos no tiene la clave).
- **Criterio de terminado:** cumplido punto por punto.
  1. `test_porcentaje_del_encono`.
  2. `test_porcentaje_de_la_cobardia`.
  3. `test_toggle_de_afines`.
  4. `test_a_su_alcance`.
  5. `test_rama_por_rol`.
  6. `test_golpe_voluntario_suma_sin_bono`, `test_ocarra_enconada_pega_5_6_7_7` y `test_salvaje_suma_y_cierre_en_0`.
  7. `test_enconada_que_alcanza`.
  8. `test_enconada_que_no_alcanza`.
  9. `test_tasajero_enconado_en_caza`.
  10. `test_pega_la_mitad_y_no_secunda`, `test_no_se_acerca_a_la_rival` y `test_puede_atacar_a_su_rival`.
  11. `test_enconada_no_tira_incidente` y `test_secundo_no_rechequea`.
  12. `test_rival_en`.
  13. `test_registro_del_chequeo_y_del_incidente` y `test_registro_instantanea_y_grabacion`.
  14. Pantalla, en `test_vista_rival.gd`:
      - `test_aviso_y_marca_de_encono`, `test_sin_aviso_con_0` y `test_cobardia_baja_junto_al_maestro` (60 % → 50 %);
      - `test_enconada_no_termina_hasta_atacar` y `test_enconada_que_no_alcanza_debe_acercarse` (botón, motivo, marca y contador);
      - `test_sucesos_del_chequeo_y_del_encono` y `test_contador_y_marca_en_el_tooltip`.
      - Además: `test_maximo_encono`, `test_tiene` y `test_claves_del_encono_y_la_cobardia`.
  15. `addons/gdUnit4/runtest.cmd -a res://pruebas`: 431/431, con el test de contacto. Sin errores ni advertencias nuevas en la salida (los dos `ERROR` del depurador remoto son del arranque del runner de GdUnit4).
  16. Tests viejos reescritos y listados arriba.
- **Lecturas declaradas:**
  - S-35: la restricción de casillas de la enconada que alcanza dura todo el turno → **P-038 (S-38)**.
  - El −50 % de la acobardada rige también en el golpe del incidente → **P-039 (S-39)**.
  - Con el toggle, el mínimo de 5 % rige siempre → **P-040 (S-40)**.
  - S-36 y S-37, tal cual `Arquitectura.md` 10.5.
  - S-31: no rechequea al volver de Secundar.
  - El bono del Encono va en todo golpe de la enconada a una rival del chequeo.
  - Técnicas:
    - Con el contador en el máximo, el porcentaje informado es 100.
    - El evento `encono` sale solo si el contador cambió.
    - Sin rivales o con 0 %, no hay `chequeo_rival`.
    - La clave `tipo_chequeo` es la de P-037.
  - Técnicas de la pantalla:
    - La reacción del par o de la especie reemplaza a la línea general (`Mundo.md` 5).
    - Con varias rivales, la línea nombra a la primera.
    - `no_enconada` no tiene línea.
    - Con 0 %, no se marca la rival.
    - El motivo de no poder terminar va en el panel del turno y en el tooltip del botón (el `Aviso` sigue siendo del hover).
    - `cobardia.resiste.afin` y `cobardia.resiste.maestro` no se muestran: el evento `chequeo_rival` no dice quién la sostuvo, y la pantalla no lo puede recalcular después. Si se quieren, el evento tendría que traerlo (`Arquitectura.md` A.7, decisión del Arquitecto).
- **Claves de texto nuevas sin texto:** `marca.enconada`, `marca.acobardada`, `panel.encono`, `aviso.terminar.debe_atacar_rival` y `aviso.terminar.debe_acercarse`. En pantalla salen como `[FALTA: …]`.
- **Preguntas:** nuevas P-037 (ARQUITECTO), P-038, P-039 y P-040 (SISTEMAS); ninguna bloquea, pero P-038 conviene antes de T20. Cerrada P-008.
- **Lista de prueba manual (usuario):**
  1. `addons/gdUnit4/runtest.cmd -a res://pruebas`: todo en verde.
  2. **C (Tasajero):**
     - Cuando el Tasajero quede a tiro (ronda 2), en el turno de la Rodauva, pasar el mouse por su propia casilla: el Tasajero lleva el rombo violeta y el aviso dice el % de cobardía (leal con la balanza 2: 25 %; 15 % si el Maestro le queda al lado o en diagonal).
     - Pasar el mouse por casillas lejos del Maestro y cerca de él: el % sube y baja.
  3. **F (Rescate):**
     - Con la Ocarra frente al Zancajunco salvaje, el hover avisa del Encono (neutral con la balanza 2: 10 %).
     - Si queda enconada:
       - la ficha dice `[FALTA: marca.enconada]`;
       - el botón de terminar está gris;
       - el panel del turno y el tooltip del botón dicen `[FALTA: aviso.terminar.debe_atacar_rival]` (o `…debe_acercarse` si no llega);
       - solo se marcan casillas desde donde golpea.
     - Después de atacar, el botón se habilita.
     - En los sucesos sale la reacción "La Ocarra baja el cuello como una lanza en ristre…".
  4. **E con el toggle (`e_cobardia_afines`):** en el turno de la Rodauva leal, el % de cobardía baja con la otra Rodauva al lado o en diagonal, y nunca baja de 5 %. En `e_cobardia` (sin el toggle), la misma casilla da más.
  5. **Contador:**
     - Después de cada golpe de la Ocarra al Zancajunco, su ficha muestra `[FALTA: panel.encono]: n/3` y el tooltip lo dice también.
     - Los sucesos dicen "El encono de la Ocarra crece."
     - Con 3, el hover avisa 100 %.
  6. Si la Rodauva queda acobardada: la ficha dice `[FALTA: marca.acobardada]`, no se puede mover más cerca del Tasajero y el botón de terminar sigue habilitado.
- **Para la próxima sesión:** nada: tarea terminada. Faltan el commit, el PR y la prueba manual.

## T20 · sesión 1 · 08/10/2026
- **Rama:** tarea/T20-salvajes
- **Estado:** EN CURSO (sigue en la sesión 2)
- **Hecho:**
  - P-037 pasó a `CERRADA` (sin cambios de código).
  - Las enemigas (salvajes y atacante nocturna) tiran Encono, cobardía e incidentes por la misma función que la tribu:
    - Sale el corte de la tribu de `ChequeoRival.rivales_a_su_alcance`, `Incidente.rivales_vecinas` y `Turno._chequear_incidente`.
    - Sin Arrimo: `Arrimo.pasos_de(criatura, maestro)` da 0 para las enemigas, y es el único lugar de esa regla.
    - Tramo `baja`, que ya daba `Obediencia`.
    - La cobardía de una enemiga no recibe el −10 del Maestro vecino (S-41). Con el toggle restan sus afines de su bando.
    - El empate del golpe del incidente es el orden del Plantel: para las enemigas, el de la lista `enemigas` (P-011).
  - Consultas nuevas del `Turno` para la IA (D-005), las dos calculan sin aplicar:
    - `previsualizar_ataque(..., tras_primer_ataque)`: el segundo ataque de Caza, sin la obligación del Encono.
    - `casillas_para_retirarse(desde, objetivo)`: la retirada que `mover` aceptaría después del golpe. Los ayudantes de `_motivo_destino_rival` reciben `sin_rival`, la que caería con el golpe previsto.
  - IA, paso 3 de 11.8 (`DecisionIA.Paso.ENCONO`, "paso 3"; `paso: "encono"` en el registro):
    - Elige la rival con los desempates de 10.5 (`Criterio.PUEDE_TUMBAR` nuevo) entre las opciones que ya filtra el `Turno`, y la ataca con la tabla de 11.8 (en Cuenta, la de menos pasos y la retirada).
    - Si no la alcanza, se acerca (S-43).
    - En Caza, S-42. La clave del 6b se extrajo a `_clave_caza`, que comparten el 6b y la Caza enconada.
    - `_retirada` usa `casillas_para_retirarse` para todas.
    - La acobardada y la distraída no necesitaron código: los pasos 4 a 8 ya toman casillas y objetivos del `Turno`. Lo prueban los tests.
  - `Combate`: sin cambios. `rival_en`, el registro y `_jugar_ia` ya eran de cualquier bando.
  - Sin cambios de esquema ni de datos: la huella no cambió. No hizo falta el fixture `combate_sin_relaciones.json` del plan.
- **Archivos:**
  - Creados: `pruebas/combate/test_rival_salvajes.gd`, `pruebas/combate/ia/test_ia_encono.gd`, `pruebas/fixtures/combate/escenario_rival_salvajes.json` y `escenario_rival_salvajes_combate.json`.
  - Modificados:
    - Núcleo: `nucleo/combate/arrimo.gd`, `chequeo_rival.gd`, `incidente.gd`, `turno.gd`, `ia/ia_salvaje.gd` y `ia/decision_ia.gd`.
    - Tests: `pruebas/combate/test_enconada.gd`, `test_hambre_combate.gd` y `test_incidente.gd`.
    - Documentación: `docs/PREGUNTAS.md` y `CLAUDE.md` (Estado actual).
- **Tests:** 22 nuevos, total 453, todos pasan (sí).
  - Con `_paso_encono` apagado a mano fallan 8 de los 14 de la IA. Los 4 desempates exigen además "paso 3".
  - `test_vista_camara.gd::test_clic_y_hover_con_la_camara_movida` falló una vez en la suite completa (el hover cayó en la casilla vecina después de mover el mouse 2 píxeles). Pasa solo 3 de 3 veces y en la corrida completa siguiente. No toca nada de T20: es intermitente.
  - Tests viejos reescritos (ninguno borrado):
    - `test_enconada.gd::test_salvaje_suma_y_cierre_en_0` (`Sistema.md` 10.5 y 10.7 v1.6): ahora la salvaje chequea. Con `combate_rival_0.json` tira 10 % y no se encona, así el golpe sigue siendo voluntario.
    - `test_hambre_combate.gd::test_hambre_de_combate_en_rondas_5_y_10` (10.4 y 10.7 v1.6): la Ocarra salvaje y la atacante tiran incidente entre ellas. "Ningún ataque" pasa a "ningún ataque ni incidente que toque a la tribu".
    - `test_incidente.gd::test_salvajes_y_maestro_no_tiran` (10.4 y 10.7 v1.6): solo cambió el comentario. Seguía pasando porque Ocarra–Rodauva no es "mal": ahora dice eso.
- **Criterio de terminado (sesión 1):** cumplido del (1) al (14).
  1. Encono de una salvaje: 35 / 60 / 85; seguro con 3, sin tirar; igual con la balanza 1, 2 y 5.
  2. Cobardía de una salvaje: 80; con el Maestro vecino ortogonal o en diagonal, 80; con el toggle y dos afines (una en diagonal), 60.
  3. La atacante nocturna tira 35; una rival oculta o caída no cuenta; el Maestro nunca es rival.
  4. Incidente entre salvajes:
     - 20 % con la balanza 1, 2 y 5.
     - Con 100 %, golpe a la rival ortogonal; con dos rivales, la de menos vida, y con empate, la primera de `enemigas`.
     - Con la rival en diagonal, se distrae; la enconada no tira.
  5. La enconada va por su rival y no remata a la Rodauva con 1 de vida; el desglose trae el Encono (+1), el contador sube y el daño aplicado es el previsto.
  6. Un test por cada desempate de 10.5.
  7. La enconada que no alcanza va a [5,7] (las de distancia mínima son [5,7], [4,8] y [6,8]) y no ataca a la Rodauva que tiene al lado.
  8. Caza enconada:
     - Va a [6,9] y no a [8,7], que sería la del 6b.
     - Primer ataque a la rival, segundo a la otra presa; con la rival como única presa, los dos a ella.
     - Si el primero la tumba, el segundo va a otra presa o se pierde.
  9. Cuenta enconada: se retira a [6,8] y no a [6,7], que el `Turno` no permite con P-038 en la lectura A.
  10. Acobardada: golpea con −50 % (1) sin quedar más cerca; si solo podría acercarse a su rival, no se mueve.
  11. Distraída: el Zancajunco no se oculta y la Ocarra no ataca; las dos se acercan y terminan.
  12. Cada decisión de los tests de la IA comprueba que decidir no cambia el Plantel, la cola ni el generador, que da lo mismo dos veces y que toda acción valida.
  13. `rival_en` de una enemiga = su `chequeo_rival` del turno siguiente, sin cambiar la `instantanea`.
  14. Registro del chequeo con su tirada, `accion` con `paso: "encono"`, `ataque` con el Encono y `encono` detrás; registro del incidente de una salvaje; las dos grabaciones se reproducen igual.
- **Lecturas declaradas:**
  - S-41, S-42 y S-43, programadas como están en `Arquitectura.md` 10.5 y citadas en el código.
  - P-038 sigue en la lectura A: la retirada de la enconada en Cuenta respeta `CASILLA_SIN_RIVAL`.
  - Técnicas:
    - La enconada que no alcanza y ya está a la menor distancia no se mueve (lo decide `puede_terminar()`).
    - El daño previsto del segundo golpe de Caza a la misma rival no suma el punto de Encono del primero; solo sirve para depurar.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** nuevas: ninguna; cerrada P-037.
- **Para la próxima sesión:**
  - `pruebas/datos/jugador_esperando.gd` (`JugadorEsperando.lo_obligado`, extraído de `test_contacto.gd` sin cambiar su comportamiento) y `test_robustez_ia.gd`: 11 escenarios × 10 semillas, hasta la ronda 12.
  - Comprobar `test_contacto.gd`, que hoy pasa.
  - Pantalla: el tooltip de una enemiga con el % de `rival_en`, y los tests de sucesos de enemigas.
  - La lista de prueba manual.

## T20 · sesión 2 · 08/10/2026
- **Rama:** tarea/T20-salvajes
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho (tarea entera, sesiones 1 y 2):**
  - P-037 pasó a `CERRADA` (sin cambios de código).
  - Las enemigas (salvajes y atacante nocturna) tiran Encono, cobardía e incidentes por la misma función que la tribu (sesión 1):
    - Sale el corte de la tribu de `ChequeoRival.rivales_a_su_alcance`, `Incidente.rivales_vecinas` y `Turno._chequear_incidente`.
    - Sin Arrimo: `Arrimo.pasos_de(criatura, maestro)` da 0 para las enemigas, y es el único lugar de esa regla. Tramo `baja`, que ya daba `Obediencia`.
    - La cobardía de una enemiga no recibe el −10 del Maestro vecino (S-41). Con el toggle restan sus afines de su bando.
    - El empate del golpe del incidente es el orden del Plantel: para las enemigas, el de la lista `enemigas` (P-011).
  - Consultas del `Turno` para la IA (D-005), las dos calculan sin aplicar (sesión 1):
    - `previsualizar_ataque(..., tras_primer_ataque)`: el segundo ataque de Caza, sin la obligación del Encono.
    - `casillas_para_retirarse(desde, objetivo)`: la retirada que `mover` aceptaría después del golpe.
  - IA, paso 3 de 11.8 (`DecisionIA.Paso.ENCONO`, "paso 3"; `paso: "encono"` en el registro), en la sesión 1. Elige la rival con los desempates de 10.5 (`Criterio.PUEDE_TUMBAR`), la ataca con la tabla de 11.8, se acerca si no la alcanza (S-43) y juega la Caza enconada (S-42). La acobardada y la distraída no necesitaron código: los pasos 4 a 8 ya toman casillas y objetivos del `Turno`.
  - **Revisión 1a (sesión 2): segundo golpe de Caza a la misma rival.**
    - La elección de rival (`PUEDE_TUMBAR`) mira un solo golpe y no cambió.
    - La elección de casilla de la Caza enconada sí suma los dos golpes (`_clave_caza`, "tumba" con una sola presa). Contaba el segundo con el daño del primero, sin el punto de Encono que deja el primero.
    - Arreglo en la consulta del `Turno` (D-005): `ChequeoRival.aporte_encono(criatura, golpes_previos)`. `Turno._aportes` pasa 1 con `tras_primer_ataque`, sin ataques hechos y con la obligación `ATACAR`: el primer golpe de la enconada va siempre a una rival del chequeo.
    - La IA usa esa consulta para el segundo golpe a la rival (`_opcion(..., true)`), y `_clave_caza(presas, golpes, casilla)` suma los golpes planeados. En el 6b sin Encono los dos golpes valen lo mismo: no cambia nada.
  - **Revisión 1b (sesión 2):** en `test_vista_camara.gd::test_clic_y_hover_con_la_camara_movida`, el segundo hover pasa por el centro de otra casilla y vuelve al centro de la de destino (antes era +2 px).
  - **`JugadorEsperando.lo_obligado(combate)`** (`pruebas/datos/jugador_esperando.gd`): el ayudante de `test_contacto.gd`, extraído sin cambiar su comportamiento. Devuelve `""` o la falla, y el test la asserta.
  - **`test_robustez_ia.gd`** (A.6): los 11 escenarios de `datos/` × 10 semillas (la del escenario y 1, 2, 3, 7, 42, 99, 1000, 31337 y 2026, en una copia), con el jugador esperando, hasta el fin o la ronda 12. Ningún `error()`. Si falla, el mensaje dice el escenario, la semilla, la ronda, la unidad y la decisión con el motivo del rechazo. No encontró ninguna acción inválida de la IA. Para comprobar que detecta fallas: con `_paso_encono` apagado a mano, C y H fallan con "paso 8 ACERCARSE … -> DEBE_ACERCARSE".
  - **Pantalla (sesión 2):**
    - El tooltip de una enemiga de pie suma `encono.tooltip` / `cobardia.tooltip` con `{porcentaje}` y su especie como sujeto, si `Combate.rival_en` en su casilla da más de 0. Con 0 %, nada.
    - Los sucesos de `chequeo_rival`, `encono` e `incidente` ya eran de cualquier bando: los tests lo comprueban con las mismas claves y variantes que la tribu.
    - Marcas en una enemiga (decisión del usuario): cada paso de `SecuenciaIA` lleva `estado` (`enconada` / `acobardada` / `""`, del `chequeo_rival` de su turno; un `turno` nuevo lo vuelve a `""`). Mientras la secuencia muestra los pasos de esa unidad, su ficha lleva la marca (`LecturaCombate.marca_estado`, que también usan las marcas del turno, y `FichaUnidad.mostrar_marca`). Al terminar o saltar la secuencia se redibuja desde el núcleo y la marca se va. Una enemiga que no se mueve ni ataca no tiene pasos: no muestra la marca, pero los sucesos lo dicen.
  - Sin cambios de esquema ni de datos: la huella no cambió.
- **Archivos (tarea entera):**
  - Creados:
    - `pruebas/combate/test_rival_salvajes.gd` y `pruebas/combate/ia/test_ia_encono.gd`;
    - `pruebas/datos/jugador_esperando.gd` y `pruebas/datos/test_robustez_ia.gd`;
    - `pruebas/pantalla/test_vista_rival_salvajes.gd`;
    - `pruebas/fixtures/combate/escenario_rival_salvajes.json` y `escenario_rival_salvajes_combate.json`.
  - Modificados:
    - Núcleo: `nucleo/combate/arrimo.gd`, `chequeo_rival.gd`, `incidente.gd`, `turno.gd`, `ia/ia_salvaje.gd` y `ia/decision_ia.gd`.
    - Pantalla: `pantalla/combate/lectura_combate.gd`, `secuencia_ia.gd`, `ficha_unidad.gd` y `vista_combate.gd`.
    - Tests: `pruebas/combate/test_enconada.gd`, `test_hambre_combate.gd` y `test_incidente.gd`; `pruebas/datos/test_contacto.gd`; `pruebas/pantalla/test_secuencia_ia.gd` y `test_vista_camara.gd`.
    - Documentación: `docs/PREGUNTAS.md` (P-037), `docs/RESUMENES.md` y `CLAUDE.md` (Estado actual).
- **Tests:** 43 nuevos en la tarea (22 en la sesión 1 y 21 en la 2), total 474.
  - **Todos pasan: sí por partes, no en la suite completa.**
    - Por partes: `res://pruebas/combate` 260/260, `res://pruebas/datos` 84/84 y `res://pruebas/pantalla` 85/85. También pasan `test_robustez_ia.gd` + `pantalla` (97/97) y el resto de `datos` + `pantalla` (157/157).
    - En la suite completa (3 corridas) y en `datos` + `pantalla` juntas fallan los tests de pantalla que usan el mouse real: `test_vista_camara.gd::test_clic_y_hover_con_la_camara_movida`, `test_principal.gd::test_clic_del_mouse_llega_al_tablero` y una vez `test_vista_camara.gd::test_arrastrar_no_sale_de_los_limites`.
    - La casilla bajo el mouse da (3954, 3959), fuera del tablero, ya en el primer hover, que no cambió. Eso apunta al cursor real del sistema y no a una regla. La sesión 1 ya había visto la misma falla, antes de los cambios de esta sesión. No se investigó más: queda para el usuario (ver "Para la próxima sesión").
  - **1b:** `test_vista_camara.gd` corrido 5 veces seguidas (el runner no deja elegir un solo test): `test_clic_y_hover_con_la_camara_movida` pasó las 5 veces. En la 5.ª falló otro test del archivo, `test_arrastrar_no_sale_de_los_limites` (T42), en la línea del arrastre de vuelta. No se reprodujo en 6 corridas más. Su mensaje de falla ahora dice el inicio, las posiciones y los límites.
  - Tests viejos reescritos (ninguno borrado):
    - Sesión 1: `test_enconada.gd::test_salvaje_suma_y_cierre_en_0` (`Sistema.md` 10.5 y 10.7 v1.6), `test_hambre_combate.gd::test_hambre_de_combate_en_rondas_5_y_10` (10.4 y 10.7 v1.6) y `test_incidente.gd::test_salvajes_y_maestro_no_tiran` (10.4 y 10.7 v1.6; solo el comentario).
    - Sesión 2, sin cambio de regla:
      - `test_secuencia_ia.gd::test_pasos_de_la_ia` y `test_solo_la_ia_y_desde`: comparan el paso sin la clave `estado`, que se prueba aparte (T20, pantalla).
      - `test_vista_camara.gd::test_clic_y_hover_con_la_camara_movida`: solo cambió cómo se mueve el mouse (1b).
      - `test_vista_camara.gd::test_arrastrar_no_sale_de_los_limites`: solo el mensaje de falla.
      - `test_contacto.gd::_jugar_lo_obligado`: llama a `JugadorEsperando`, sin cambiar criterios ni coordenadas.
- **Criterio de terminado:** cumplido del (1) al (17). Del (18), parcial: todo pasa por carpetas, y en la corrida completa fallan los tests de pantalla con mouse real (ver Tests).
  - 1 a 14: ver T20 · sesión 1.
  - 1a: arreglado, con test de fixtures del `Turno` (13 de vida; 6 + 7 previsto = aplicado, y 8 + 8 con el contador en el máximo) y de la IA (va a [5,8], que tumba solo con el punto extra, y no a [6,9]; previsto 13 = aplicado).
  - 1b: estable en 5 corridas.
  - 15: `test_robustez_ia.gd`, 11 × 10 sin `error()`.
  - 16: `test_contacto.gd` pasa sin tocar coordenadas ni criterios.
  - 17: sucesos de una enemiga con su línea; tooltip con el 35 % y sin línea con 0 %; marca durante la secuencia.
  - 18: ver Tests. Sin advertencias nuevas (los dos ERROR del depurador remoto ya existían).
- **Lecturas declaradas:**
  - S-41, S-42 y S-43, programadas como están en `Arquitectura.md` 10.5.
  - P-038 sigue en la lectura A: la retirada de la enconada en Cuenta respeta `CASILLA_SIN_RIVAL`.
  - Técnicas:
    - La enconada que no alcanza y ya está a la menor distancia no se mueve (lo decide `puede_terminar()`).
    - El punto de Encono del segundo golpe se prevé solo con la obligación `ATACAR` (la que garantiza que el primer golpe va a una rival del chequeo).
    - La marca de una enemiga se ve solo durante sus pasos de la secuencia.
- **Claves de texto nuevas sin texto:** ninguna nueva. Siguen faltando en `es.json` las de T19: `marca.enconada`, `marca.acobardada`, `panel.encono`, `aviso.terminar.debe_atacar_rival` y `aviso.terminar.debe_acercarse`.
- **Preguntas:** nuevas: ninguna; cerrada: P-037.
- **Lista de prueba manual:**
  1. C: cuando el Tasajero llega a tiro de la Rodauva o la Ocarra (ronda 2), su tooltip muestra el % de Encono. Si se encona, los sucesos lo dicen, durante la secuencia su ficha dice "[FALTA: marca.enconada]" y su primer ataque va a la rival.
  2. F: el Zancajunco salvaje con la Ocarra de la tribu a su alcance: tooltip con el %, y si se encona, va por ella.
  3. B: si las dos Ocarras salvajes quedan vecinas (también en diagonal), el incidente aparece en los sucesos.
  4. G: la Ocarra atacante con el Zancajunco de la tribu a su alcance tira su chequeo (suceso y, si sale, la marca durante su paso).
  5. Una enemiga sin rival a su alcance: su tooltip no tiene línea de %.
  6. F3 durante y después de la secuencia de la IA: `chequeo_rival` e `incidente` de las enemigas en el registro, sin errores. Espacio salta la secuencia y la marca se va.
- **Para la próxima sesión:** correr `addons/gdUnit4/runtest.cmd -a res://pruebas` sin usar el mouse mientras corre (unos 7 minutos). Si los tests de pantalla con mouse pasan, la tarea queda en verde y va el PR. Si siguen fallando, hacen falta una sesión corta y la decisión de qué hacer con esos tests (de T13 y T42).

## T20-ajustes · sesión 1 · 08/10/2026
- **Rama:** tarea/T20-ajustes
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:**
  - `VistaCombate` guarda la posición del último `InputEventMouse` (movimiento o botón) en `_input`, sin marcarlo como manejado. Va en `_input` para guardar también los eventos que se queda un `Control`, como pasaba antes con el cursor.
  - Una sola conversión a casilla, `_casilla_del_mouse()`: inversa de `get_global_transform_with_canvas()` del `TileMapLayer` + `local_to_map`. Sin ningún evento todavía, da `Criatura.SIN_POSICION`. La usan el clic (`seleccionar`), el hover y el rehover de `_acotar_camara` (teclado, zoom y arrastre). Sin cambios en el comportamiento de la cámara.
  - `casilla_bajo_mouse()` sigue con el significado de T42: la casilla del último hover, que ahora sale de esa conversión.
  - Tests de pantalla: el mouse se manda con `Input.parse_input_event` + `Input.flush_buffered_events()`, y se comprueba sin `await` en el medio. Así ningún evento real se mete entre el evento del test y su comprobación.
  - Comprobación a mano: con la lectura vieja (`get_local_mouse_position`) puesta un momento, fallan los tests del mouse, entre ellos los dos nuevos.
- **Archivos:** modificados `pantalla/combate/vista_combate.gd`, `pruebas/pantalla/test_vista_camara.gd` y `pruebas/pantalla/test_principal.gd`. Sin cambios en `nucleo/` ni en `datos/`: la huella no cambió.
- **Tests:** 2 nuevos, total 476, todos pasan. La suite completa pasó 3 veces seguidas, sin usar el mouse; la corrida usando la computadora queda en la prueba manual.
  - Reescritos por D-006 (solo cambió la forma de mandar el mouse; comprueban lo mismo):
    - `test_vista_camara.gd::test_clic_y_hover_con_la_camara_movida`: eventos con `position` en lugar de `simulate_mouse_move` / `simulate_mouse_button_pressed`.
    - `test_vista_camara.gd::test_hover_sigue_al_mover_la_camara`: el evento con `position`. La casilla esperada sale de la inversa del canvas en lugar de `get_local_mouse_position()`.
    - `test_vista_camara.gd::test_arrastrar_no_sale_de_los_limites` y `test_zoom_respeta_minimo_y_maximo`: con flush y sin frames entre el evento y la comprobación.
    - `test_principal.gd::test_clic_del_mouse_llega_al_tablero`: eventos con `position`. Sigue pasando por la GUI de la principal.
  - Nuevos:
    - `test_vista_camara.gd::test_sin_mouse_no_hay_hover` (3).
    - `test_vista_camara.gd::test_el_cursor_real_no_cambia_la_casilla` (4). Usa `Input.warp_mouse` a propósito y comprueba en el mismo frame, porque Windows puede generar un evento real por el warp en el frame siguiente, y ese sí cuenta.
- **Criterio de terminado:** cumplido punto por punto.
  - (1) Clic y hover con la cámara movida y con zoom: `test_clic_y_hover_con_la_camara_movida` y `test_clic_del_mouse_llega_al_tablero`.
  - (2) La cámara se mueve con el mouse quieto y el hover se rearma: `test_hover_sigue_al_mover_la_camara`.
  - (3) Sin evento del mouse no hay hover: test nuevo.
  - (4) El warp no cambia la casilla: test nuevo.
  - (5) Búsqueda en `pantalla/`, `pruebas/` y `herramientas/`: ninguna llamada a `get_local_mouse_position`, `get_global_mouse_position`, `get_mouse_position` ni `simulate_mouse_*`. Solo queda `Input.warp_mouse` en el test (4).
    - Fuera de nuestro código: el `scene_runner` de GdUnit4, al crearse, lleva el cursor real a (0, 0) y trae la ventana al frente (`GdUnitSceneRunnerImpl.gd`, líneas 82 a 88). Es del addon y no se tocó; la vista ya no lee el cursor.
  - (6) 3 corridas seguidas en verde, sin usar el mouse. Falta la corrida usando la computadora (prueba manual).
  - (7) Los tests reescritos están listados arriba.
  - Sin advertencias nuevas: los dos ERROR del depurador remoto ya existían.
- **Lecturas declaradas:** ninguna.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** ninguna nueva ni cerrada.
- **Lista de prueba manual:**
  1. Correr `addons/gdUnit4/runtest.cmd -a res://pruebas` 3 veces seguidas. En una, mover el mouse y cambiar de ventana mientras corre. Las 3 en verde.
  2. F5 → A: hover, clic, arrastre (botón del medio) y rueda funcionan igual que antes, con la cámara movida y con zoom.
  3. Con el mouse quieto sobre el tablero, mover la cámara con WASD o la rueda: el hover (tooltip y marcas) pasa a la casilla que queda debajo.
  4. Al abrir un escenario, antes de mover el mouse, no hay tooltip ni marcas de hover.
  5. Con el mouse sobre un botón de abajo, mover la cámara con WASD: no hay errores en la consola.
- **Para la próxima sesión:** nada: tarea terminada. Sigue T21.

## T21 · sesión 1 · 08/10/2026
- **Rama:** tarea/T21-mana
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:**
  - **Modelo.** `Maestro.mana_entrada` es un entero y se resuelve al crear el `Plantel`: `null` pasa a ser la reserva de la fila de su balanza. Es el tope del combate (M-04) y no cambia. `Maestro.mana` es nuevo: el maná actual, que arranca en `mana_entrada`.
  - **Regla.** `RegeneracionMana` (`nucleo/combate/regeneracion_mana.gd`) no guarda estado y vive en `ContextoCombate.regeneracion_mana`.
    - `aplicar(maestro, ronda)` suma la Regeneración, recortada a `mana_entrada`, y devuelve `{de, a}` solo si el valor cambia.
    - El hambre se mira en ese momento, con `EstadosUnidad.fila_hambre(...)["regen_combate"]`: `siempre`, `rondas_pares` (`ronda % 2 == 0`) o `nunca`.
    - El lugar del quebranto (M-09) queda marcado con un comentario, sin código. Famélico sigue S-44.
  - **Turno.** `Turno.empezar(..., regla_chequeo, regla_mana, azar)`: `regla_mana` es **obligatoria**, y los tests con un turno suelto pasan `DatosFixture.regeneracion_mana()`. El paso 1 de `_inicio_del_turno` corre solo para el Maestro y con `_cola.ronda`. Al volver de Secundar no corre (S-31). Campo público nuevo: `Turno.mana` (`{de, a}` o `{}`).
  - **Combate.** Registra el evento `mana` (`unidad`, `de`, `a`, `motivo: "regeneracion"`) justo después del `turno` del Maestro, solo si el valor cambia, y sin volcar tiradas. La `instantanea` suma `maestro.mana`. El resultado llena `maestro.mana` con un entero, y el esquema `resultado` ya no admite `null` en ese campo.
  - **Cargador.** Chequeo cruzado nuevo `_chequear_mana_entrada`: un `maestro.mana_entrada` mayor que la reserva de su balanza da error con archivo, campo y valor esperado.
  - **Pantalla.** El panel del turno del Maestro y su tooltip muestran `panel.mana: actual/tope` (`ClavesTextos.PANEL_MANA`, `LecturaCombate._linea_mana`). No hay línea de sucesos.
- **Archivos:**
  - Creados: `nucleo/combate/regeneracion_mana.gd`, `pruebas/combate/test_regeneracion_mana.gd`, `pruebas/fixtures/combate/escenario_mana_combate.json` y `pruebas/fixtures/cargador/escenario_mana_entrada/` (esquemas mínimos, `tablas/balanza.json`, `escenarios/mayor.json`, `igual.json` y `nulo.json`).
  - Modificados en el núcleo: `nucleo/unidades/maestro.gd`, `plantel.gd`, `nucleo/combate/contexto_combate.gd`, `turno.gd`, `combate.gd`, `resultado_combate.gd` y `nucleo/datos/cargador.gd`.
  - Modificados en pantalla y datos: `pantalla/claves_textos.gd`, `pantalla/combate/lectura_combate.gd` y `datos/_esquemas/resultado.schema.json`.
  - Modificados en pruebas: `pruebas/combate/datos_fixture.gd`; las 29 llamadas a `Turno.empezar` de 17 archivos de test (cambio mecánico: agregan `DatosFixture.regeneracion_mana()`); `test_contrato.gd`, `test_plantel.gd`, `test_plantel_escenarios.gd`, `test_cargador.gd` y `test_lectura_combate.gd`.
- **Tests:** 15 nuevos, total 491, todos pasan (suite completa en verde y sin advertencias nuevas).
  - Reescritos, por Sistema.md 2.1 y 1.2 (M-04):
    - `test_plantel.gd::test_null_toma_el_valor_por_defecto`: `mana_entrada` era `null` y ahora es la reserva de la fila de la balanza 2 del fixture.
    - `test_contrato.gd::test_resultados_validan_contra_el_esquema`: `maestro.mana` era `null` y ahora es un entero igual a la reserva. Además comprueba que el esquema rechaza `null`.
- **Criterio de terminado:** cumplido punto por punto.
  - (1) `test_plantel.gd::test_t21_mana_entrada_se_resuelve`: balanzas 2 y 4 del fixture, y un valor explícito.
  - (1b) `test_plantel_escenarios.gd::test_t21_mana_de_entrada_de_los_escenarios`: G con 4 y los otros 10 con la reserva de su balanza.
  - (2) `test_normal_suma_su_regeneracion_hasta_el_tope` y `test_en_el_tope_no_hay_evento`.
  - (3) `test_el_tope_es_el_mana_de_entrada`: entrada 4, Regeneración 3.
  - (4) `test_regeneracion_segun_el_hambre` y `test_famelico_conserva_su_mana`.
  - (5) `test_hambre_de_combate_cambia_la_regla_en_el_acto`: pasa de 5 a 6 al cerrar la ronda 5; regenera en la 6 y la 8 y no en la 7.
  - (6) `test_secundar_y_volver_regenera_una_vez`.
  - (7) `test_otros_turnos_no_tocan_el_mana`: `Turno` suelto de la Rodauva y de la Ocarra salvaje, más el registro del combate.
  - (8) `test_el_evento_va_justo_despues_del_turno`.
  - (9) `test_registro_instantanea_y_resultado` (evento exacto e `instantanea`), `test_contrato.gd` (resultado contra el esquema) y `test_grabacion_se_reproduce_igual`.
    - Un combate armado desde un escenario siempre entra en el tope y en T21 nada gasta maná. Por eso la grabación reproducida no tiene eventos `mana`: el test comprueba que el registro sea igual y que no aparezca ninguno.
  - (10) `test_cargador.gd::test_t21_mana_entrada_no_supera_la_reserva`: `mayor` da error en `maestro.mana_entrada`; `igual` y `nulo`, no.
  - (11) Pasan `test_contacto.gd`, `test_robustez_ia.gd` y `test_datos_completos.gd`, sin cambios.
  - (12) `test_lectura_combate.gd::test_t21_mana_en_panel_y_tooltip`.
  - (13) Suite completa en verde. Los tests reescritos están listados arriba.
- **Datos (tabla de cotejo):** sin cambios de datos; solo se leen campos que ya existían. La huella no cambió.

  | Valor | Archivo y campo | Sección |
  |---|---|---|
  | Reserva 7 / 8 / 9 / 10 / 11 | `tablas/balanza.json` `posiciones[].reserva_mana` | 1.2 |
  | Regeneración en combate: Saciado y Normal `siempre`, Hambriento `rondas_pares`, Famélico `nunca` | `tablas/hambre.json` `estados[].regen_combate` | 2.1, 2.2 |
  | Regeneración 1 | escenario `maestro.regeneracion` (inicial en `maestro.json` `iniciales.regeneracion`) | 1.1 |
  | G: maná de entrada 4 | `escenarios/g_ataque_nocturno.json` `maestro.mana_entrada` | 11.9, 2.4 |
- **Lecturas declaradas:** S-31 (P-033; la regeneración corre una vez por ronda) y S-44 (Famélico solo corta la regeneración). "Turnos pares" = rondas pares (2.1, A.2.2).
- **Claves de texto nuevas sin texto:** `panel.mana`.
- **Preguntas:** ninguna nueva ni cerrada.
- **Lista de prueba manual:**
  1. `addons/gdUnit4/runtest.cmd -a res://pruebas`: todo en verde.
  2. F5 → G: el panel del Maestro (en su turno) y su tooltip muestran `[FALTA: panel.mana]: 4/4`.
  3. F5 → A: el Maestro muestra `[FALTA: panel.mana]: 8/8` (reserva de la balanza 2). Con F3, ningún evento `mana` en el registro (está en el tope).
  4. Pasar el mouse por una criatura propia y por una enemiga: su tooltip no muestra maná.
  5. La regeneración visible (panel que cambia y evento `mana` detrás del `turno`) no se puede provocar desde un escenario en T21, porque nada gasta maná. La cubre `test_lectura_combate.gd::test_t21_mana_en_panel_y_tooltip`, que baja el maná a mano. Se verá a mano desde T22 (hechizos).
  6. `git diff develop -- datos/`: solo `_esquemas/resultado.schema.json`.
- **Para la próxima sesión:** nada: tarea terminada. Sigue T22.

## T21-ajustes · sesión 1 · 09/10/2026
- **Rama:** tarea/T21-ajustes
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:** refactor puro (D-008). Las reglas sin estado llegan al `Turno` en un solo objeto. Ninguna regla cambió.
  - `ReglasCombate` (`nucleo/combate/reglas_combate.gd`, `RefCounted`) agrupa `danio`, `afinidad`, `combo`, `incidente`, `chequeo_rival` y `regeneracion_mana`. Se crea con todas, sin valores por defecto. Si una llega nula, `falta` guarda su nombre y sale `push_error("ReglasCombate: falta la regla <nombre>")`. `REGLAS` es la lista que se revisa. Una regla nueva (desde T22) se suma como campo, en `_init` y en `REGLAS`.
  - `combo` no estaba en la firma (el `Turno` la usa a través de la `Cadena`), pero D-008 la nombra y es una regla sin estado. El `Turno` no la lee; el `Combate` la sigue usando para crear la `Cadena`.
  - Quedan fuera `obediencia`, `relaciones`, `hambre_combate` y `cierre`, porque no llegan al `Turno`.
  - `ContextoCombate` arma `reglas` una sola vez en `armar`, con las mismas construcciones y en el mismo orden. Las seis propiedades sueltas quedan como **acceso de lectura** (`get`) a `reglas`, porque es lo que deja menos cambios: `Combate` (`afines_desde`, `incidente_en`, `rival_en`, `Cadena.new(contexto.combo)`), `test_combate.gd` y `test_hambre_combate.gd` siguen igual. Con el contexto no válido devuelven `null`, como antes.
  - `Turno`: las variables privadas de cada regla se cargan desde `reglas` en `_init`. El resto del archivo no cambió.
  - **Firma antes:** `Turno.empezar(entrada, plantel, tablero, danio, surcos, afinidad, cadena, cola, regla_incidente, regla_chequeo, regla_mana, azar)`.
  - **Firma después:** `Turno.empezar(entrada, plantel, tablero, surcos, cadena, cola, reglas: ReglasCombate, azar)`.
  - `danio`, `afinidad`, `regla_incidente`, `regla_chequeo` y `regla_mana` pasan a `reglas`. `entrada`, `plantel`, `tablero`, `surcos`, `cadena`, `cola` y `azar` siguen, en el mismo orden relativo.
  - `DatosFixture.reglas(reemplazos = {})` arma las reglas con los fixtures de siempre y reemplaza las que se le pasen por nombre (`{"chequeo_rival": DatosFixture.chequeo_rival(_BASE_100)}`). Un nombre que no existe da `null` con `push_error`, nunca la regla por defecto.
  - Las 31 llamadas a `Turno.empezar` de 18 archivos de test usan `DatosFixture.reglas(...)`. El `Danio` de cada test salía de los mismos `fixtures/combate/combate.json` + `hambre.json` que usa `DatosFixture.reglas`, así que se dejó de pasar. Se borraron los `_danio` (miembros) y `danio` (locales) que quedaron sin uso por eso. En `test_afinidad`, `test_danio`, `test_incidente` y `test_caza_y_cuenta` el `_danio` sigue, porque se usa en otras cosas.
- **Archivos:**
  - Creados: `nucleo/combate/reglas_combate.gd` y `pruebas/combate/test_reglas_combate.gd`.
  - Modificados en el núcleo: `nucleo/combate/turno.gd`, `contexto_combate.gd` y `combate.gd` (solo la llamada a `Turno.empezar`).
  - Modificados en pruebas: `pruebas/combate/datos_fixture.gd` y, solo en cómo se arma el turno, `test_turno`, `test_vida_cero`, `test_surco`, `test_secundar`, `test_rival_salvajes`, `test_regeneracion_mana`, `test_chequeo_rival`, `test_junco`, `test_incidente`, `test_enconada`, `test_danio`, `test_caza_y_cuenta`, `test_cadena`, `test_afinidad`, `test_acobardada`, `ia/test_ia_salvaje`, `ia/test_ia_encono` y `pruebas/pantalla/test_interprete_clic`.
  - Sin cambios en `datos/`, `pantalla/` ni la IA.
- **Tests:** 1 nuevo, total 492, todos pasan (suite completa en verde). Ningún test reescrito y ninguna aserción cambiada. En la consola, solo los dos `ERROR` del "Remote Debugger" del runner, que ya salían antes, y los seis `push_error` esperados del test nuevo (los captura `assert_error`). `--import`, sin advertencias.
- **Criterio de terminado:** cumplido punto por punto.
  - (1) `test_reglas_combate.gd::test_construccion_incompleta_falla_con_el_nombre_de_la_que_falta`: un solo test que recorre `ReglasCombate.REGLAS`, deja nula una regla por vez y comprueba el `push_error` con su nombre y `falta`. La completa tiene `falta` vacío.
  - (2) `Turno.empezar` ya no recibe ninguna regla suelta (firmas arriba).
  - (3) Las 31 llamadas a `Turno.empezar` de `pruebas/` usan `DatosFixture.reglas(...)`. Las otras llamadas a `DatosFixture.incidente(...)` y `DatosFixture.chequeo_rival(...)` son tests directos de esas reglas, sin turno.
  - (4) `git diff develop -- pruebas/`: ninguna línea con `assert` ni `override_failure_message` cambia. Solo cambia el armado del turno, `DatosFixture.reglas` y el test nuevo.
  - (5) La huella no cambió (sin cambios en `datos/`). Las grabaciones de C del 06/10 al 08/10 ya no se reproducen enteras en `develop`: `c_tasajero_33001_6` corta en la acción 14 con `CASILLA_NO_ALCANZABLE` por las reglas de T19 a T21. Por eso, antes de tocar código, se grabó una partida nueva de C con `develop` (`registros/c_tasajero_33001_7`, 42 acciones del jugador, combate terminado) con un script de la sesión que no queda en el repositorio. Con `develop` se reprodujo sin aviso e idéntica (`registros/c_base_develop.jsonl`). Después del refactor, la reproducción de `copia.json` da sin `AVISO` de huella, y `fc` no encuentra diferencias ni contra la línea base (`fc /b`) ni contra el `.jsonl` original.
  - (6) Pasan `test_contacto.gd`, `test_robustez_ia.gd` y `test_datos_completos.gd`, sin cambios.
  - (7) Suite completa: 492 en verde.
- **Supuestos (sin pregunta, decisiones técnicas de D-008):** `combo` entra en `ReglasCombate` aunque el `Turno` no la lea. Las propiedades sueltas del `ContextoCombate` quedan como acceso de lectura. `ReglasCombate` va justo antes del `azar` en la firma.
- **Lecturas declaradas:** ninguna.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** ninguna nueva ni cerrada.
- **Lista de prueba manual:**
  1. `addons/gdUnit4/runtest.cmd -a res://pruebas`: 492 en verde.
  2. En cmd: `copy registros\c_tasajero_33001_7.json registros\copia.json`, después `"%GODOT_BIN%" --headless --path . --script res://herramientas/reproducir.gd -- res://registros/copia.json` y `fc registros\c_tasajero_33001_7.jsonl registros\copia.jsonl`. Tiene que dar sin `AVISO` y sin diferencias.
  3. F5 → A y C: mover, atacar, Secundar, activas (Erizarse, Hacerse junco, cavar) y hover de afines y rivales, todo igual que antes.
- **Para la próxima sesión:** nada: tarea terminada. Sigue T22.

## T44 · sesión 1 · 09/10/2026
- **Rama:** tarea/T44-escala
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:**
  - **Preguntas.** Con la autorización del usuario (solo esta vez), copié sin cambios las respuestas de `Sistema.md` 15 v1.7 en P-030 a P-036 y P-038 a P-040, y las pasé a `CERRADA` (`Cerrada en: T44`). Ninguna cambia código, salvo P-040.
  - **Datos ×10** (`Sistema.md` 11.1 v1.7, D-009), con la tabla de cotejo de abajo.
    - Las `_nota` que citaban vidas o daños quedaron al día: las 5 especies, `balanza.json`, `combate.json`, la Lanzadera y los escenarios C, D (los tres), E (los dos), F, G y H.
    - Sin cambios de esquema. La huella cambió.
  - **P-040** (`Sistema.md` 10.6 v1.7). `ChequeoRival._pct_cobardia`, con el toggle, ahora da `max(sin_afines + descuento, min(sin_afines, minimo_pct))`, y después el recorte a 0..100. El piso ya no sube la cobardía. Sin afines, el toggle no cambia nada.
  - **`sostenida_por`** (A.7, `Mundo.md` 9.2 v1.3). `_pct_cobardia` devuelve `{porcentaje, sostenida_por, afin}` en la misma cuenta del porcentaje:
    - `"maestro"` si restó el −10 del Maestro vecino.
    - Si no, `"afin"` si el toggle contó alguna afín.
    - Si no, `null`.
    - `consulta` suma las dos claves (`null` y `""` en el Encono).
    - `tirar` las copia **solo** en una `resistida`. `afin` va solo si `sostenida_por` es `"afin"`.
    - `Combate._registrar_chequeo_rival` vuelca al evento las claves que traiga. Constantes: `ChequeoRival.SOSTENIDA_MAESTRO` y `SOSTENIDA_AFIN`.
  - **`afin`** (P-041, decisión del usuario en esta sesión): el id de la primera afín del toggle, en el orden del Plantel. Sin este dato, el hueco `{a_afin}` de `cobardia.resiste.afin` no se podía llenar.
  - **Pantalla.** `LecturaCombate._suceso_chequeo_rival` elige la línea de la resistida según `sostenida_por`, con el sujeto de la especie (para la variante):
    - `"maestro"` → `cobardia.resiste.maestro`.
    - `"afin"` → `cobardia.resiste.afin`, con `{afin}` = la especie de `afin`.
    - `null` o sin la clave (registros viejos) → `cobardia.resiste`.
    - `ClavesTextos`: `COBARDIA_RESISTE_MAESTRO` y `COBARDIA_RESISTE_AFIN` en `FIJAS`. `usadas` suma sus variantes `.<especie>` si están en el archivo.
  - **Números en el código que dependen de la escala:** revisé `nucleo/` y `pantalla/` con un grep. No hay ninguno: `danio_minimo`, `vida_tras_caida` y el choque ya eran dato. El único literal cerca de "vida" es el 100 de un porcentaje (`IASalvaje`, umbral de Erizarse).
- **Tabla de cotejo ×10** (valor | archivo y campo | sección):

  | Valor | Archivo y campo | Sección |
  |---|---|---|
  | 80 / 20 | `especies/rodauva.json` `vida` / `danio` | 11.2 v1.7 |
  | 240 / 30 | `especies/surcon.json` `vida` / `danio` | 11.2 |
  | 120 / 40 | `especies/ocarra.json` `vida` / `danio` | 11.2 |
  | 120 / 40 | `especies/zancajunco.json` `vida` / `danio` | 11.2 |
  | 30 | `especies/zancajunco.json` `rasgo.bono_plano` | 11.2.2, 11.1 |
  | 300 / 50 | `especies/tasajero.json` `vida` / `danio` | 11.2 |
  | −10 | `especies/tasajero.json` `rasgo.modos[cuenta].danio_plano` | 11.2.3, 11.1 |
  | 220 / 200 / 180 / 160 / 140 | `tablas/balanza.json` `posiciones[1..5].vida_max_real` | 1.2 |
  | 50 / 40 / 40 / 30 / 30 | `tablas/balanza.json` `posiciones[1..5].danio_cuerpo` | 1.2 |
  | 10 | `tablas/combate.json` `danio_minimo` | 11.1, 11.4 |
  | 10 | `tablas/combate.json` `vida_tras_caida` | 11.1, 11.5 |
  | 10 | `tablas/combate.json` `afinidad_danio_plano` | 10.3, 11.1 |
  | 10 | `tablas/combate.json` `encono.danio_plano_por_punto` | 10.5, 11.1 |
  | 10 | `hechizos.json` lanzadera `danio_choque` (ya existía) | 1.6, 11.1 |
  | 60 | `escenarios/f_rescate.json` `maestro.vida` | 11.9 |

  **Derivadas reproducidas desde los datos** (`test_escala_x10.gd`):
  - Maestro de A (balanza 2): 200 de vida y 40 de daño.
  - F: 60.
  - Maestro de H (balanza 5): 140 y 30.
  - Tasajero de C: 300, y `vida_de_cambio` 150.
  - F en `test_contacto.gd`: el Zancajunco pega 40 + 30 = 70 al Maestro con 60.

  **Números leídos que no se guardaron:**
  - La vida al guardar una caída (10) no existe en `datos/`: la crea T27.
  - Martillazo `10 × (2 + Poder)` y Remiendo `10 × (3 + Poder)`: sus `base` en `hechizos.json` (2 y 3) siguen como estaban, porque la fórmula nueva no entra en el esquema de hoy (`base + Poder`). Los pasa T22, que los usa por primera vez.
  - Debilidad del ritual y quebranto: 0b.
- **Archivos:**
  - Creados: `pruebas/combate/test_cobardia_v17.gd` y `pruebas/datos/test_escala_x10.gd`.
  - Modificados en datos: `datos/especies/` (las 5), `datos/tablas/balanza.json`, `datos/tablas/combate.json`, `datos/hechizos.json`, y `datos/escenarios/` C, D (los tres), E (los dos), F, G y H (en F, el dato; en el resto, solo `_nota`).
  - Modificados en código: `nucleo/combate/chequeo_rival.gd`, `nucleo/combate/combate.gd`, `pantalla/claves_textos.gd` y `pantalla/combate/lectura_combate.gd`.
  - Modificados en pruebas: `pruebas/combate/test_combate.gd`, `pruebas/datos/test_contacto.gd`, `pruebas/unidades/test_plantel_escenarios.gd`, `pruebas/pantalla/test_claves_textos.gd` y `pruebas/pantalla/test_vista_rival.gd`.
  - Docs: `docs/PREGUNTAS.md`, `docs/RESUMENES.md` y `CLAUDE.md` ("Estado actual").
- **Tests:** 16 nuevos, total 508, todos pasan (suite completa: 508 de 508, 68 suites; en la consola, solo los dos `ERROR` del Remote Debugger del runner y los seis `push_error` esperados de `test_reglas_combate`, como antes).
  - Nuevos:
    - `test_cobardia_v17.gd`: 9.
    - `test_escala_x10.gd`: 4.
    - `test_combate.gd::test_resistida_registra_quien_la_sostuvo`.
    - `test_vista_rival.gd::test_sucesos_de_quien_sostuvo`.
    - `test_claves_textos.gd::test_claves_de_quien_sostuvo`.
  - **Reescritos**, cada uno con su referencia en el comentario:
    1. `pruebas/datos/test_contacto.gd::test_f_zancajunco_oculto_avanza_y_pega_7` → `..._pega_70`: `vida_antes` 6 → 60 y `total` 7 → 70 (`Sistema.md` 11.1 y 11.9 v1.7). Coordenadas y criterios sin tocar.
    2. `pruebas/unidades/test_plantel_escenarios.gd::test_f_maestro_en_6` → `test_f_maestro_en_60`: 6 → 60 (11.1 y 11.9 v1.7).
    3. ⚠️ `pruebas/pantalla/test_claves_textos.gd::test_claves_del_encono_y_la_cobardia`. Es un test con fixtures. Afirmaba `not_contains("cobardia.resiste.maestro")`, y T44 pide justo lo contrario (que `usadas` sume esa clave). Pasa a `contains` de `cobardia.resiste.maestro` y `cobardia.resiste.afin` (`Mundo.md` 9.2 v1.3, A.7 T44). Es la única aserción de un test con fixtures que cambió (ver el criterio 8).
- **Criterio de terminado:**
  - (1) Cumplido: `datos/` carga sin errores (`test_datos_completos`, `test_contenido_fijo`). La tabla de cotejo está arriba, para que el usuario la revise contra `Sistema.md` v1.7.
  - (2) Cumplido: `test_escala_x10.gd` (A 200/40, F 60, H 140/30, Tasajero 300 y 150).
  - (3) Cumplido: `test_contacto.gd` pasa, con F pegando 70 al Maestro con 60. Reescrito con la referencia a 11.9 v1.7, sin tocar coordenadas ni criterios.
  - (4) Cumplido: pasan `test_robustez_ia.gd` y `test_datos_completos.gd`, sin cambios.
  - (5) Cumplido: `test_cobardia_v17.gd`.
    - `test_toggle_sin_afines_no_cambia_nada`: 25 y 25. Con una base de 3 %, 3 y 3 (antes, el toggle la subía a 5).
    - `test_piso_no_sube_la_cobardia`: 3 % con una afín sigue en 3.
    - `test_con_afines_nunca_baja_del_piso`: 12 % con dos afines da 5; 25 % con dos, 5; con una, 15.
    - Las bases de 3 % y 12 % salen de una copia en memoria de `combate.json`, porque `pruebas/fixtures/` no se toca.
  - (6) Cumplido, en 5 tests de `test_cobardia_v17.gd`:
    - Maestro → `maestro`, sin `afin`.
    - Afín sin Maestro → `afin` + `afin: rodauva_2`.
    - Con dos afines, la primera del Plantel.
    - Los dos → `maestro`.
    - Ninguno → `null`; una afín sin el toggle tampoco sostiene.
    - En `acobardada`, `enconada` y `no_enconada`, la clave no va.
    - En el registro de un `Combate`: `test_combate.gd::test_resistida_registra_quien_la_sostuvo` (la Rodauva de la ronda de C resiste con el Maestro vecino).
  - (7) Cumplido: `test_vista_rival.gd::test_sucesos_de_quien_sostuvo` cubre Maestro (con y sin variante de especie), afín (con el nombre), `null` y evento sin la clave.
  - (8) **Parcial, por una contradicción del pedido:** `git diff develop -- pruebas/fixtures/` sale vacío, y ningún test de reglas cambió una aserción. Pero hubo que invertir una aserción de un test de pantalla con fixtures (`test_claves_textos.gd`, la 3 de arriba), porque afirmaba lo contrario de lo que T44 pide. La grabación de C de T21-ajustes (`registros/c_tasajero_33001_7.json`) queda para la prueba manual: tiene que dar el aviso de huella.
  - (9) Cumplido: suite completa en verde (508). Mientras trabajé, la corrí por carpeta.
- **Supuestos y lecturas declaradas:**
  - "Restó alguna afín del toggle" (A.7) lo leo como "el toggle contó al menos una afín vecina". Con los números de hoy no hay diferencia: sin el Maestro vecino, la cobardía sin afines es 20 % o más, así que contar una afín siempre resta. Está en el comentario de `_pct_cobardia`.
  - Las `base` de Martillazo y Remiendo quedan para T22 (ver arriba).
- **Claves de texto nuevas sin texto:** ninguna. `cobardia.resiste.maestro` y `cobardia.resiste.afin` ya están en `es.json` v1.3.
- **Preguntas:**
  - Cerradas: P-030 a P-036 y P-038 a P-040.
  - Nueva: P-041 (ARQUITECTO, no bloquea), sobre el campo `afin` del `chequeo_rival` resistido. Programada la opción A, que eligió el usuario.
- **Lista de prueba manual:**
  1. `addons/gdUnit4/runtest.cmd -a res://pruebas`: todo en verde.
  2. F5 → A: el Maestro muestra 200 de vida, y el desglose de su golpe da 40 de base. El panel dice "Maná", sin `[FALTA]`.
  3. F5 → C: el Tasajero tiene 300, y su tooltip dice que pasa a Cuenta con 150. En Caza, sus dos golpes son de 50.
  4. F5 → F, apretando Esperar en todos los turnos: en la ronda 3, el Zancajunco pega 70 y tumba al Maestro (60).
  5. F5 → E: si la Rodauva resiste la cobardía con el Maestro al lado, el suceso muestra "Se queda porque estás cerca.". En `e_cobardia_afines`, con otra Rodauva o el Surcón vecinos y sin el Maestro, muestra "Se queda porque tiene a la Rodauva cerca." (o "al Surcón").
  6. `git diff develop -- pruebas/fixtures/`: vacío.
  7. Reproducir la grabación de C de T21-ajustes (`copy registros\c_tasajero_33001_7.json registros\copia.json` y `"%GODOT_BIN%" --headless --path . --script res://herramientas/reproducir.gd -- res://registros/copia.json`): tiene que dar el aviso de huella, que es lo esperado (D-009).
- **Para la próxima sesión:** nada: tarea terminada. Sigue T22.

## T22 · sesión 1 · 10/10/2026
- **Rama:** tarea/T22-hechizos
- **Estado:** EN CURSO (sigue en la sesión 2: pantalla y `test_lanzadera_b.gd`)
- **Hecho:**
  - **Preguntas.** P-041 pasó a `CERRADA` (`Cerrada en: T22`), sin cambios de código. Nueva P-042 (Arquitecto): el evento `lanzadera` no dice contra quién chocó y `lanzadera.choque` necesita `{a_otra}`.
  - **Datos (D-010).** Esquema `hechizos`: sale `escala_poder` y entra `por_poder`. `datos/hechizos.json`: Martillazo `base` 20 y `por_poder` 10, Remiendo 30 y 10. La huella cambió. Fixtures nuevos en la escala vieja (D-009): `pruebas/fixtures/combate/hechizos.json` (2/1, 3/1, choque 1) y `hechizos_choque_4.json` (choque 4, para distinguir "entero" de "−50 % con mínimo 1").
  - **Regla `Hechizos`** (`nucleo/combate/hechizos.gd`, sin estado): `desde_datos(hechizos.json, maestro.json)` (null si falta la tabla, un hechizo del Maestro o un parámetro de su efecto), `ids()`, `hechizo(id)` y `valor(id, poder)` = `base + por_poder × Poder`, el único lugar de la fórmula. Está en `ReglasCombate` (campo, `_init` y `REGLAS`), `ContextoCombate.armar` y `DatosFixture.reglas`. La firma de `Turno.empezar` no cambió.
  - **`ContextoCombate.armar`** rechaza un contexto con `ReglasCombate.falta` no vacío: `Motivo.REGLA_FALTANTE` y `regla_faltante` con el nombre.
  - **Una sola fórmula de 11.4.** `Danio.calcular_con_base(base, ...)` hace el cálculo; `calcular` la llama con la base de la ficha o la balanza. En el `Turno`, `_atacar_desde` quedó en los chequeos del ataque y `_golpear` es el golpe compartido con el Martillazo: aportes (afinidad desde la casilla del Maestro, combo, cobardía, Encono), eslabón, vida, cadena, Encono, Junco y `VidaCero`.
  - **Acción.** Un solo tipo con parámetro: `Accion.hechizo(hechizo_id, objetivo_id, sentido = "")` → `{"tipo": "hechizo", "hechizo", "objetivo"[, "sentido"]}`, con ida y vuelta exacta. En el esquema `grabacion`: el tipo `hechizo` y las propiedades `hechizo` y `sentido` (`empujar` | `atraer`). Así la pantalla arma los botones desde los datos (criterio 13).
  - **`Turno._hechizo`** (por `_resolver`, la misma función valida y aplica). Chequea en este orden: turno terminado, `SOLO_MAESTRO`, `HECHIZO_INEXISTENTE`, `ACCION_USADA`, `MANA_INSUFICIENTE`, la objetivo y el sentido. La objetivo: `OBJETIVO_PROPIO` si no `incluye_si_mismo`; `Objetivos` (`HOSTIL` para daño y empuje, `ALIADA` para la cura); bando (`OBJETIVO_ALIADO` en el daño, `OBJETIVO_ENEMIGO` en la cura); geometría por `geometria` (Manhattan libre, línea con `linea_bloqueada`, 4 ortogonales). El sentido: `SENTIDO_INVALIDO` si no está en `modos` o si sobra. Al aplicar: paga el maná, gasta la acción (`ataques_restantes = 0`) y conserva el movimiento. El comportamiento sale de `efecto`, nunca del id.
    - Martillazo (`danio`): `_golpear` con `Hechizos.valor`.
    - Lanzadera (`empuje`): empujar o atraer `casillas` en la línea; `ATRAER_ADYACENTE` si la llevaría hasta el Maestro. Choque con `Tablero.bloquea_desplazamiento`: `danio_choque` fijo, piso 0 y `VidaCero`. Si se mueve: posición nueva y `Junco.revisar_contacto`. No toca cadena, Encono, bono, erizada ni surcos.
    - Remiendo (`cura`): `min(vida máxima, vida + valor)` (Maestro: `vida_max_real` de su balanza; criatura: su ficha). Con la vida completa cura 0 y vale (S-45).
  - **Consultas** (D-005): `objetivos_para_hechizo(id)`, `sentidos_para_hechizo(id, objetivo)` y `previsualizar_hechizo(id, objetivo, sentido)` (= `validar`). `ResultadoAccion` suma `mana` (`{de, a}`), `evento` (el de `lanzadera` o `remiendo`) y `destaparia`.
  - **Registro** (`Combate._ejecutar`): `accion` → `mana` (`motivo: "hechizo"`) → `ataque` (Martillazo, con `eslabon`; `_registrar_ataque` compartido con el ataque) o `lanzadera` / `remiendo` → destape / bono_perdido → estado → surco → cadena_cortada. Ningún evento existente cambió de forma.
- **Tabla de cotejo** (valor | archivo y campo | sección):

  | Valor | Archivo y campo | Sección |
  |---|---|---|
  | 2 / 3 / 20 / 10 | `hechizos.json` martillazo `costo` / `alcance` / `base` / `por_poder` | 1.6, 2.3, 11.1 v1.7, D-010 |
  | 2 / 2 / 1 / 10 | lanzadera `costo` / `alcance` / `casillas` / `danio_choque` | 1.6 (casos borde), 11.1 v1.7 |
  | 4 / 1 / 30 / 10 | remiendo `costo` / `alcance` / `base` / `por_poder` | 1.6, 2.3, 11.1 v1.7 |

  Derivadas (`test_escala_x10.gd::test_hechizos_desde_datos`, con `datos/`): A (Poder 1) Martillazo 30 y Remiendo 40; H (Poder 3) Martillazo 50 y Remiendo 60. Números leídos que no se guardaron: ninguno (los hechizos no tienen descuento de la balanza, 2.3).
- **Archivos:** creados `nucleo/combate/hechizos.gd`, `pruebas/combate/mesa_hechizos.gd`, `test_martillazo.gd`, `test_lanzadera.gd`, `test_remiendo.gd`, `test_hechizos.gd`, `test_hechizos_combate.gd`, `pruebas/fixtures/combate/hechizos.json`, `hechizos_choque_4.json`, `escenario_hechizos.json` y `escenario_hechizos_combate.json`; modificados `datos/_esquemas/hechizos.schema.json`, `datos/_esquemas/grabacion.schema.json`, `datos/hechizos.json`, `nucleo/combate/accion.gd`, `combate.gd`, `contexto_combate.gd`, `danio.gd`, `reglas_combate.gd`, `resultado_accion.gd`, `turno.gd`, `pruebas/combate/datos_fixture.gd`, `test_reglas_combate.gd`, `pruebas/datos/test_escala_x10.gd`, `docs/PREGUNTAS.md` y `CLAUDE.md` (Estado actual).
- **Tests:** 51 nuevos, total 559. Todos los de T22 y todos los de `nucleo/` y `datos/` pasan. En la suite completa fallaron 4 tests de pantalla que no toqué; corridos solos (sus dos archivos enteros) pasan todos: son intermitentes (ver abajo). Test viejo tocado: solo el ayudante `_armar` de `test_reglas_combate.gd`, que pasa a 7 reglas por la firma de `ReglasCombate.new` (ninguna aserción cambió). Ningún test reescrito por una regla.
- **Criterio de terminado (sesión 1):** cumplido punto por punto:
  1. Esquema → datos → fixtures; `datos/` carga (permanente); cotejo arriba; derivadas en `test_escala_x10`.
  2. `test_martillazo.gd`: alcance 3 sí y 4 no; por encima de una enemiga y de un surco; aliada, caída, oculta, fuera, el Maestro y un id inexistente con su motivo; mover antes y después; sin maná, sin cambios.
  3. Base 3 / 5 según Poder; erizada 2; Tasajero en Caza 6; afinidad +1; combo eslabón 2 (+70 %) = 5; `otro_objetivo`; `bono_perdido`; tumba (`FUERA`); previsto = aplicado.
  4. a 7. `test_lanzadera.gd` (geometría, choques, Surcón, tumbar, erizada, destape por contacto, cadena / Encono / bono intactos) y `test_remiendo.gd` (Maestro 10 → 14, aliada 2 → 6, diagonal / enemiga / caída no, oculta sí, Poder 3, topes 20 y 8, vida completa cura 0).
  8. y 11. `test_hechizos_combate.gd`: maná 8 → 6, 7 → 3, 4 → 2 con `mana` `hechizo` justo después de la `accion`; con 1 y con 3 se rechaza sin registrar; eventos `ataque` (eslabón 1), `remiendo` y `lanzadera` iguales a lo previsto; la grabación con los tres valida, pasa por JSON y se reproduce igual (registro e instantánea).
  9. En los tres archivos: después del hechizo, atacar u otro hechizo `ACCION_USADA` y mover vale.
  10. Previsualizar = aplicar en los tres (con choque, sin choque y con destapes); no cambia la instantánea, el maná ni el generador.
  12. `test_contacto`, `test_robustez_ia`, `test_datos_completos` y `test_escala_x10` pasan; suite completa: 555 de 559, con 4 fallas intermitentes de pantalla (abajo).
  12b. `test_reglas_combate.gd::test_contexto_sin_una_regla_se_rechaza`.
- **Tests intermitentes** (suite completa del 10/10/2026; no se tocaron, CLAUDE.md "Tests intermitentes"). Los cuatro leen la casilla del mouse por evento (D-006). Pasan al correr solos `test_principal.gd` (6/6) y `test_vista_camara.gd` (11/11). T22 no toca `pantalla/`.
  - `test_principal.gd::test_clic_del_mouse_llega_al_tablero`: "Expecting true but is false" (línea 114).
  - `test_vista_camara.gd::test_clic_y_hover_con_la_camara_movida`: casilla (41, 34) y (1, 11) en vez de la esperada (líneas 178 y 183). Ya había fallado una vez en T20.
  - `test_vista_camara.gd::test_hover_sigue_al_mover_la_camara`: casilla (87, 44) (línea 208).
  - `test_vista_camara.gd::test_el_cursor_real_no_cambia_la_casilla`: casilla (164, 9) y lista vacía (líneas 246 y 248).
- **Lecturas declaradas:** S-45 (Remiendo con la vida completa vale y cura 0), S-46 (choque entero a la erizada), S-47 (Martillazo solo a enemigas; Lanzadera a los dos bandos, nunca a una oculta) y S-48 (sentido en el eje de la línea; empujar a una adyacente vale). Lectura técnica: la Lanzadera mueve `casillas` (1 en los datos) y solo mira la casilla de destino; con 1 es la regla literal.
- **Claves de texto nuevas sin texto:** ninguna (la sesión 1 no toca la pantalla).
- **Preguntas:** nueva P-042 (Arquitecto, no bloquea la sesión 1; afecta a los sucesos de la sesión 2); cerrada P-041.
- **Para la próxima sesión:** sesión 2 según el plan: botones de hechizos desde `Hechizos.ids()` con su costo y su motivo (consulta nueva `Turno.motivo_hechizo`), modo "elegir objetivo" con marcas, Lanzadera con clic izquierdo = empujar y una acción nueva del InputMap (clic derecho) = atraer, hover (desglose, cura, destinos / choque y destapes), sucesos `lanzadera` (según P-042) y `remiendo`, fixture con un hechizo de otro id, `pruebas/datos/test_lanzadera_b.gd` con `datos/` real y la lista de prueba manual.

## T22 · sesión 2 · 11/10/2026
- **Rama:** tarea/T22-hechizos
- **Estado:** TERMINADA (pendiente de PR). Esta entrada resume la tarea entera y es la descripción del PR.
- **Hecho (sesión 1, detalle en su entrada):**
  - Datos (D-010): `por_poder` en el esquema `hechizos` y en `datos/hechizos.json` (Martillazo 20 + 10 × Poder, Remiendo 30 + 10 × Poder). La huella cambió.
  - Regla `Hechizos` en `ReglasCombate`. `ContextoCombate.armar` rechaza un contexto con una regla faltante (`REGLA_FALTANTE`).
  - `Danio.calcular_con_base` y `Turno._golpear`, compartidos por el ataque y el Martillazo.
  - `Accion.hechizo(hechizo_id, objetivo_id, sentido)` y `Turno._hechizo` (Martillazo, Lanzadera y Remiendo, según `efecto` y `geometria`).
  - Consultas `objetivos_para_hechizo`, `sentidos_para_hechizo` y `previsualizar_hechizo`.
  - Eventos `mana` (`hechizo`), `ataque`, `lanzadera` y `remiendo`.
  - P-041 cerrada.
- **Hecho (sesión 2):**
  - **P-042 (opción A).**
    - Con `choque: true`, el evento `lanzadera` suma `contra`: el id de la unidad de la casilla de destino (de pie o caída), o `null` si el choque es contra el borde o un surco.
    - Sin choque, el campo no va. La previsualización lo trae igual porque sale de la misma función.
    - Lo calcula `Turno._ocupante_en`, con el criterio de `Tablero._ocupantes`.
    - P-042 pasa a `CERRADA`.
  - **`Turno.motivo_hechizo(hechizo_id)`.**
    - Los chequeos previos a la objetivo (turno terminado, `SOLO_MAESTRO`, `HECHIZO_INEXISTENTE`, `ACCION_USADA`, `MANA_INSUFICIENTE`) pasaron a `_motivo_lanzar`, que usan `_hechizo` y la consulta.
    - Si los pasa y no hay objetivos, devuelve el motivo nuevo `SIN_OBJETIVOS`.
  - **Botones.** `LecturaCombate.botones_hechizos()` arma uno por cada id de `Hechizos.ids()`, solo en el turno del Maestro:
    - texto: "nombre (costo Maná)";
    - tooltip: el del hechizo y, si está deshabilitado, una línea con el motivo (`ClavesTextos.motivo_hechizo`).
  - **Modo "elegir objetivo".** En `VistaCombate`:
    - botones `Hechizo_<id>` (toggle), `pulsar_hechizo(id)` y `hechizo_elegido()`;
    - se marcan las objetivos de `objetivos_para_hechizo`;
    - cavar, Secundar y hechizo se excluyen entre sí.
  - **Clic.** `InterpreteClic.accion(..., hechizo_id, alterno)` y `objetivo_hechizo_en`.
    - Un hechizo sin modos va con el clic izquierdo.
    - La Lanzadera empuja con el izquierdo y atrae con el derecho, si ese sentido está en `sentidos_para_hechizo`.
    - Fuera del modo hechizo, el clic derecho no hace nada.
    - Acción nueva del InputMap: `seleccionar_alterno` (clic derecho).
  - **Hover.** Todo sale de `previsualizar_hechizo`:
    - si el resultado trae desglose (Martillazo), se muestra el desglose de T13;
    - si trae evento, se guarda por sentido en `hechizo_mostrado()`:
      - Lanzadera: el destino (capa `Tablero/DestinosHechizo`, marca 6:0) o el choque con su daño y la vida, y `aviso.destapar` si destaparía;
      - Remiendo: "Vida: de → a".
    - `LecturaCombate.vista_previa_hechizo` arma las líneas del panel del desglose.
  - **Sucesos.**
    - `accion` de un hechizo: "Maestro · <nombre del hechizo>".
    - `lanzadera` sin choque: "<objetivo> · Mover".
    - `lanzadera` con choque, con "(−daño · Vida: antes → después)" al final:
      - contra una criatura: `lanzadera.choque`, con `{unidad}` = la objetivo y `{otra}` = la de `contra`;
      - contra el Maestro: `lanzadera.choque.contra_maestro`;
      - contra `null`: `lanzadera.choque.obstaculo` (falta en `es.json`).
    - `remiendo`: "<objetivo> · Vida: de → a".
  - **`ClavesTextos.usadas`** suma:
    - el nombre y el tooltip de cada hechizo de `maestro.json`;
    - el rótulo de cada modo de `hechizos.json`;
    - las claves fijas nuevas;
    - las variantes `lanzadera.choque.<especie>`, solo si están en el archivo.
  - **B con datos reales.** `test_lanzadera_b.gd` encuentra la jugada con las consultas del `Turno` (no está escrita a mano). Con el jugador esperando, en el segundo turno del Maestro (ronda 2):
    - el Maestro se mueve a [4,8] (1 paso);
    - atrae a `ocarra_s2` de [6,8] a [5,8];
    - queda en diagonal con `ocarra_s1` [4,7]: vecinas en 8, como dice la `_nota` de B.
- **Archivos (tarea entera):**
  - Creados en la sesión 1:
    - `nucleo/combate/hechizos.gd`;
    - en `pruebas/combate/`: `mesa_hechizos.gd`, `test_martillazo.gd`, `test_lanzadera.gd`, `test_remiendo.gd`, `test_hechizos.gd` y `test_hechizos_combate.gd`;
    - en `pruebas/fixtures/combate/`: `hechizos.json`, `hechizos_choque_4.json`, `escenario_hechizos.json` y `escenario_hechizos_combate.json`.
  - Creados en la sesión 2:
    - `pruebas/combate/test_motivo_hechizo.gd` y `pruebas/datos/test_lanzadera_b.gd`;
    - `pruebas/pantalla/test_vista_hechizos.gd` y `test_lectura_hechizos.gd`;
    - en `pruebas/fixtures/pantalla/`: `hechizos.json` (`pedrada`, efecto `danio`) y `maestro_hechizos.json`.
  - Modificados en la sesión 1:
    - esquemas `hechizos` y `grabacion`, y `datos/hechizos.json`;
    - en `nucleo/combate/`: `accion.gd`, `combate.gd`, `contexto_combate.gd`, `danio.gd`, `reglas_combate.gd`, `resultado_accion.gd` y `turno.gd`;
    - `pruebas/combate/datos_fixture.gd`, `test_reglas_combate.gd` y `pruebas/datos/test_escala_x10.gd`.
  - Modificados en la sesión 2:
    - `nucleo/combate/turno.gd` y `resultado_accion.gd`;
    - `pantalla/claves_textos.gd`;
    - en `pantalla/combate/`: `interprete_clic.gd`, `lectura_combate.gd`, `vista_combate.gd` y `vista_combate.tscn`;
    - `project.godot`;
    - `pruebas/combate/test_lanzadera.gd`, `pruebas/pantalla/test_interprete_clic.gd` y `test_claves_textos.gd`.
  - Documentación: `docs/PREGUNTAS.md` y `CLAUDE.md` ("Estado actual").
- **Tests:**
  - Nuevos: 51 en la sesión 1 y 21 en la sesión 2. Total: 580.
  - Suite completa del 11/10/2026: 580/580 en verde, sin intermitentes.
  - **Tests viejos reescritos:** uno, el ayudante `_assert_choca` de `test_lanzadera.gd`, por P-042.
    - Ahora recibe `contra` y compara el evento con ese campo.
    - Sus 9 llamadas pasan el id esperado o `null`; ninguna otra aserción cambió.
  - En la sesión 1 también se tocó el ayudante `_armar` de `test_reglas_combate.gd`, por la firma de `ReglasCombate.new`, sin cambiar aserciones.
- **Criterio de terminado:** cumplido punto por punto. Sesión 1 (B.3, criterios 1 a 12b): ver su entrada. Sesión 2:
  - (0) P-042 (`test_lanzadera.gd`):
    - un choque contra una unidad de pie (`rodauva_s1`) o caída (`rodauva_1`) trae su id;
    - contra el borde o un surco, `null`;
    - sin choque no hay clave (`test_p042_sin_choque_no_hay_contra`);
    - lo previsto es igual a lo aplicado en todos (`_lanzar`).
  - (1) Botones y motivos:
    - `test_motivo_hechizo.gd`: `NINGUNO`, `SIN_OBJETIVOS` (con todas las objetivos rechazadas), `MANA_INSUFICIENTE`, `ACCION_USADA`, `SOLO_MAESTRO` y `TURNO_TERMINADO`, cada uno igual al motivo de `validar`;
    - `test_lectura_hechizos.gd` y `test_vista_hechizos.gd`, con `pedrada`: su botón muestra su costo y su modo marca justo los objetivos de la consulta;
    - sin maná, con la acción usada o sin objetivos, el botón está deshabilitado y su tooltip lleva el motivo.
  - (2) Hover = evento (`test_vista_hechizos.gd`):
    - el desglose del Martillazo es igual al del `ataque` registrado;
    - la Lanzadera muestra empujar y atraer con los destinos marcados, y lo de atraer es igual al evento registrado;
    - con una adyacente contra el borde, solo empujar, con choque, igual al evento;
    - lo del Remiendo es igual al `remiendo` registrado.
    - Que lo previsto en los destapes sea lo aplicado lo prueba el núcleo (`test_lanzadera.gd::test_destapa_por_contacto`). La vista los copia de `previsualizar_hechizo`; en el test de la vista vienen vacíos.
  - (3) Clics:
    - `test_interprete_clic.gd`: el izquierdo empuja y el derecho atrae; el derecho sobre una adyacente da `null`, y fuera del modo también;
    - `test_vista_hechizos.gd`: clic derecho real (`parse_input_event` + `flush`), y fuera del modo no hace nada;
    - una partida con los tres hechizos jugada por la vista, guardada con `GuardadoCombate`, da una grabación que valida y se reproduce igual.
  - (4) `test_lectura_hechizos.gd`: una línea con su clave por cada caso de `lanzadera` (sin choque, contra criatura, contra el Maestro, `null`), por `remiendo` y por el nombre en la `accion`.
  - (5) `test_lanzadera_b.gd`: ver arriba.
  - (6) Pasan `test_contacto`, `test_robustez_ia`, el permanente de datos y `test_escala_x10`.
  - (7) Suite completa en verde. Los únicos `push_error` del log son los que los tests provocan a propósito (`is_push_error`): no hay errores ni advertencias nuevas.
- **Lecturas declaradas:** S-45 a S-48 (sesión 1).
- **Supuestos (no bloquean):**
  - `contra` usa el criterio de ocupante de `Tablero._ocupantes`, copiado en un ayudante privado del `Turno`, porque el alcance de la sesión no dejaba tocar `Tablero`.
  - Con 1 casilla de Lanzadera, el choque contra el Maestro no puede pasar. La línea `lanzadera.choque.contra_maestro` está programada y se probó con un evento armado a mano.
  - El PR no lo abro yo: `CLAUDE.md` prohíbe el push y deja el PR al usuario.
- **Claves de texto nuevas sin texto** (propuestas; hoy se ven como `[FALTA]`):
  - `aviso.hechizo.mana_insuficiente`, `aviso.hechizo.accion_usada` y `aviso.hechizo.sin_objetivos`: tooltip del botón deshabilitado;
  - `hechizo.sentido.empujar` y `hechizo.sentido.atraer`: rótulos del hover de la Lanzadera;
  - `lanzadera.choque.obstaculo`: choque contra el borde o un surco.
- **Preguntas:** ninguna nueva en la sesión 2 (P-042 fue de la sesión 1). Cerradas en la tarea: P-041 (sesión 1) y P-042 (sesión 2).
- **Lista de prueba manual** (Windows):
  1. Correr los tests:
     - cmd: `addons\gdUnit4\runtest.cmd -a res://pruebas`
     - PowerShell: `& .\addons\gdUnit4\runtest.cmd -a res://pruebas`

     Todo en verde; tarda unos 10 minutos.
  2. Abrir el juego con F5 en el editor, o:
     - cmd: `"%GODOT_BIN%" --path .`
     - PowerShell: `& $env:GODOT_BIN --path .`

     Elegir A. En el turno del Maestro:
     - se ven tres botones con su costo: "Martillazo (2 Maná)", "Lanzadera (2 Maná)" y "Remiendo (4 Maná)";
     - al pulsar Martillazo se marcan las objetivos;
     - con el mouse sobre la Ocarra se ve el desglose;
     - con clic izquierdo, la vida baja lo que decía el total y el maná baja 2 en el panel.
  3. En el turno siguiente del Maestro, el maná subió 1 (la regeneración de T21).
  4. Remiendo sobre la Rodauva herida o sobre el Maestro: la "Vida: de → a" del hover es la que queda.
  5. Elegir B y jugar "Esperar" hasta el segundo turno del Maestro. Mover al Maestro a [4,8] (un paso hacia arriba) y pulsar Lanzadera:
     - sobre una Ocarra se ven los destinos de empujar y atraer, o el choque con su daño;
     - el clic izquierdo empuja y el derecho atrae;
     - atraer a la Ocarra de la derecha la deja junto a la otra.
  6. Probar dos choques:
     - contra el borde (una unidad pegada al borde, empujada hacia afuera): da "[FALTA: lanzadera.choque.obstaculo] (−10 · Vida: …)";
     - contra otra unidad: da "La … sale despedida y se lleva por delante a …".
  7. Con poco maná, los botones que no alcanzan quedan grises y su tooltip suma el motivo (hoy `[FALTA: aviso.hechizo.mana_insuficiente]`). Con la acción usada, quedan todos grises.
  8. Anotar los `[FALTA]` que aparezcan además de los de la lista de arriba.
- **Para la próxima sesión:** nada: tarea terminada. Falta el commit de la sesión 2 y el PR a `develop`, los dos con la confirmación del usuario.

## T23 · sesión 1 · 11/10/2026
- **Rama:** tarea/T23-metricas
- **Estado:** TERMINADA (pendiente de PR). Esta entrada resume la tarea entera y es la descripción del PR. Cierra el hito 0a.2 cuando pase la prueba manual de abajo.
- **Hecho:**
  - **Deuda de T22.** `Tablero.ocupante_en(casilla, plantel)` es pública y pura: devuelve el id del Maestro o de la criatura que ocupa la casilla (de pie o caída), o `null`.
    - El criterio vive en un solo lugar (`Tablero._ids_por_casilla`), del que sale también `_ocupantes`.
    - Se borró `Turno._ocupante_en` y la Lanzadera (P-042) usa la consulta. Los tests de P-042 pasan sin tocarlos.
  - **Consultas nuevas de `Tablero`** (las usa el `Combate` para los eventos):
    - `distancia_a_enemiga_de_pie(desde, bando, plantel)`: Manhattan a la unidad del otro bando más cercana con `Objetivos.de_pie` (una oculta cuenta), o `null` si no queda ninguna;
    - `encerrada(casilla, plantel, surcos)`: ninguna de las 4 ortogonales es `es_casilla_libre` (fuera del tablero no es libre; por S-25, un surco tampoco).
  - **Eventos nuevos** (A.7, D-011), escritos por el `Combate` justo detrás del `fin_turno`:
    - `distancia_maestro` (`distancia`): en cada `fin_turno` del Maestro;
    - `encierro` (`unidad`, `casilla`): detrás del `fin_turno` de cualquier unidad que termina encerrada, solo cuando pasa.
    - Si el combate termina a mitad de un turno, no hay `fin_turno` ni estos eventos (como antes). Ningún evento existente cambió de forma.
  - **`MetricasCombate.calcular(escenario, lineas)`** (`nucleo/combate/metricas_combate.gd`, sin estado).
    - Del escenario toma solo de qué bando es cada id; nunca mira especies ni reconstruye estados. Solo enteros, `null`, listas y diccionarios.
    - Claves, por número de `Sistema.md` 11.9:
      - 1 `rondas`: `totales` (la última `ronda`), `primer_ataque` (ronda del primer `ataque`, Martillazo y golpe de incidente incluidos, no el choque de la Lanzadera; `null` sin ataques) y `de_pelea` (de esa ronda a la última, inclusive; 0 sin ataques);
      - 2 `secundar.usos`;
      - 3 `eslabones`: `cadenas`, `suma` y `maximo` de las `cadena_cortada` de 2 o más (promedio = suma / cadenas);
      - 4 `incidentes.{tribu,enemigas}.{distraida,golpe}`;
      - 5 `encono.{tribu,enemigas}` (`chequeo_rival` con `enconada`, también las seguras);
      - 6 `cobardia.{tribu,enemigas}.{acobardada,resistida}`;
      - 7 `sellados`, 8 `capturas_perdidas`, 10 `caidas_guardadas` y 12 `rescate`: `null` (los llenan T24, T25, T27 y T29);
      - 9 `caidas`: `[{unidad, ronda}]` de los `estado` que pasan a `caida`, y también a `caido` (el Maestro, P-043);
      - 11 `muertes`: `[{unidad, causa}]` desde el `cierre`, con la causa = el desenlace del `fin`;
      - 13 `distancia_maestro`: `turnos` y `suma` de los no nulos desde la ronda del primer ataque (promedio = suma / turnos);
      - 14 `activas`: `usos` (`[{unidad, erizarse, cavar, hacerse_junco}]`, por el tipo de la `accion`), `surcos`, `ocultos`, `destapes_contacto`, `bonos_cobrados` (ataques con un modificador `rasgo_atacante`), `bonos_perdidos`, `cambios_modo` (`[{unidad, de, a, ronda}]`) y `encierros` (`[{unidad, turnos}]`).
  - **Resultado.** `ResultadoCombate.metricas` lo llena `Combate._terminar` con el registro completo (después del `cierre`). El esquema `resultado` define el objeto entero (con `$defs` locales) y deja 7, 8, 10 y 12 en `null`, cada una con su `description`.
  - **Guardado.**
    - `GuardadoCombate.guardar` escribe además `<escenario>_<semilla>_<n>_resultado.json` si el combate terminó (`guardar_resultado`, `SUFIJO_RESULTADO`).
    - `herramientas/reproducir.gd` escribe `registros/<nombre>_resultado.json` (o `<nombre>_hasta_N_resultado.json`) si el combate reproducido terminó.
    - La escritura pasó a `herramientas/salida_reproduccion.gd` (`SalidaReproduccion.escribir`), que se prueba sin lanzar Godot. El comando no cambió.
- **Archivos:**
  - Creados:
    - `nucleo/combate/metricas_combate.gd` y `herramientas/salida_reproduccion.gd`;
    - `pruebas/combate/test_metricas_combate.gd`, `pruebas/combate/test_eventos_metricas.gd`, `pruebas/herramientas/test_salida_reproduccion.gd` y `pruebas/datos/test_metricas_escenarios.gd`;
    - `pruebas/fixtures/combate/escenario_eventos_metricas.json`.
  - Modificados:
    - `nucleo/combate/tablero.gd`, `turno.gd`, `combate.gd` y `resultado_combate.gd`;
    - `datos/_esquemas/resultado.schema.json` (la huella no cambia: los esquemas no entran);
    - `pantalla/combate/guardado_combate.gd` y `herramientas/reproducir.gd`;
    - `pruebas/combate/test_tablero.gd`, `test_combate.gd` y `test_contrato.gd`, y `pruebas/pantalla/test_guardado_combate.gd`;
    - `docs/PREGUNTAS.md` y `CLAUDE.md` ("Estado actual").
- **Tests:** 19 nuevos, total 599. Suite completa del 11/10/2026: 599/599 en verde (10 min 56 s), sin intermitentes.
  - **Tests viejos reescritos** (A.7, T23):
    - `test_combate.gd::test_registro_de_una_ronda_de_c`: detrás del `fin_turno` del Maestro van `distancia_maestro` y `encierro`. En el fixture de C, el Maestro en [3,6] queda con la tribu en [2,6], [4,6] y [3,7] y el Tasajero en [3,5].
    - `test_contrato.gd::test_resultados_validan_contra_el_esquema`: `metricas` ya no es `null` (comprueba `rondas.totales`).
- **Criterio de terminado:** cumplido punto por punto:
  1. `distancia_maestro`: `test_eventos_metricas.gd` (detrás de cada `fin_turno` del Maestro, con el valor de `Tablero`; la oculta cuenta; ningún turno de criatura lo escribe). El `null` está en `test_tablero.gd`: en un combate, sin enemigas de pie hay victoria antes del `fin_turno`.
  2. `encierro`: `test_eventos_metricas.gd` (el Maestro en el borde, rodeado por la tribu con una caída, con las diagonales libres; sin encierro con una ortogonal libre) y `test_tablero.gd` (surco, esquina, diagonal).
  3. a 7. `test_metricas_combate.gd`, con registros armados a mano.
  8. y 9. `test_contrato.gd`: `test_t23_metricas_de_victoria_y_derrota` y `test_t23_metricas_en_vivo_y_reproducidas`.
  10. `test_guardado_combate.gd::test_t23_guarda_el_resultado` y `test_salida_reproduccion.gd`.
  11. `test_metricas_escenarios.gd`: los 11 escenarios con `JugadorEsperando` hasta el fin o la ronda 12 dan métricas válidas y sin `float`; A, B, C, las tres D y H tienen el primer ataque en la ronda 2.
  12. `test_contacto`, `test_robustez_ia`, `test_datos_completos` y `test_lanzadera_b` pasan.
  13. `test_tablero.gd::test_t23_ocupante_en` (también comprueba que `turno.gd` ya no tiene `_ocupante_en`).
  14. Suite completa: ver "Tests".
- **Lecturas declaradas:**
  - P-043: la métrica 9 incluye la caída del Maestro (`caido`). Lo decidió el usuario en el plan; queda ABIERTA para el Arquitecto.
  - Técnicas, sin pregunta:
    - con los dos eventos, `distancia_maestro` va antes que `encierro`;
    - `eslabones.maximo` vale 0 sin cadenas de 2 o más;
    - `activas.usos` y `activas.encierros` listan solo las unidades con al menos uno, en el orden del escenario (Maestro, tribu, enemigas);
    - la causa de una muerte es el texto del desenlace (`derrota_por_caida`).
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** nueva P-043 (ARQUITECTO, no bloquea). Cerradas: ninguna.
- **Para la próxima sesión:** nada: tarea terminada. Falta la prueba manual de cierre del hito 0a.2.
- **Prueba manual (cierre del hito 0a.2):**
  1. Tests. En `cmd`: `addons\gdUnit4\runtest.cmd -a res://pruebas`; en PowerShell: `& .\addons\gdUnit4\runtest.cmd -a res://pruebas`. Todo en verde (tarda unos 10 minutos).
  2. Abrir el juego: F5 en el editor, o en PowerShell `& $env:GODOT_BIN --path .` (en `cmd`: `"%GODOT_BIN%" --path .`). Jugar con el mouse, de punta a punta: C, D normal, D hambriento, E, E con afines y H.
  3. Después de cada uno, abrir el `registros/<escenario>_<semilla>_<n>_resultado.json` más nuevo y mirar `metricas`:
     - `rondas.totales`, `rondas.primer_ataque` y `rondas.de_pelea`: las rondas del combate, la del primer golpe (de quien sea) y las que hubo desde ahí;
     - `incidentes.tribu` (D): distracciones y golpes entre la Ocarra y el Zancajunco;
     - `encono.tribu` y `encono.enemigas`: veces que una criatura quedó enconada;
     - `cobardia.tribu` (E): tiradas acobardadas y resistidas (con el toggle de afines deberían cambiar);
     - `distancia_maestro.suma` dividido `distancia_maestro.turnos`: la distancia media del Maestro a la enemiga más cercana desde el primer ataque;
     - además: `caidas`, `muertes`, `activas` (Erizarse, cavar, Hacerse junco, surcos, cambio a Cuenta del Tasajero en C y H) y `secundar.usos`.
  4. Reproducir por consola una grabación vieja de C (de antes de T23), con el nombre del archivo que tengas:
     - en `cmd`: `"%GODOT_BIN%" --headless --path . --script res://herramientas/reproducir.gd -- registros\c_tasajero_33001_1.json`;
     - en PowerShell: `& $env:GODOT_BIN --headless --path . --script res://herramientas/reproducir.gd -- registros/c_tasajero_33001_1.json`.
     - Puede salir el AVISO de huella. Si el combate había terminado, tiene que escribir `registros/c_tasajero_33001_1_resultado.json` (lo dice la línea "Resultado:").
  5. Anotar cualquier métrica que no coincida con lo que se vio en pantalla.

## T24 · sesión 1 · 11/10/2026
- **Rama:** tarea/T24-sellar
- **Estado:** TERMINADA (pendiente de PR). Esta entrada resume la tarea entera y es la descripción del PR. Primera tarea del hito 0a.3.
- **Hecho:**
  - **Al empezar:** P-043 pasa a `CERRADA`. Por pedido del usuario, su Respuesta copia la resolución del Arquitecto de `Arquitectura.md`. Sin cambios de código.
  - **Datos: ninguno nuevo** (la huella no cambió). Se leen `tablas/sellado.json`, `tablas/costos_mana.json`, `tablas/balanza.json`, `tablas/lealtad.json`, `tablas/combate.json` (`alcance_sellar`) y `rango`/`sellable` de la ficha.
  - **Regla `Sellado`** (`nucleo/combate/sellado.gd`, sin estado; D-008: en `ReglasCombate`, `ContextoCombate.armar` y `DatosFixture.reglas`). Funciones:
    - `porcentaje(vida, vida_max, rango)`: compara en enteros (`vida × 100 ≤ límite × vida_max`);
    - `costo(especie, maestro)` = `max(mínimo, costo del rango − descuento)`;
    - `lealtad_inicial(maestro)` = base de combate + ajuste de la balanza, nunca menos que el mínimo de la escala;
    - `rango_permitido(especie, maestro)` y `alcance()`.
    - Sin `tablas/sellado.json`, el contexto se rechaza con `REGLA_FALTANTE` y el nombre `sellado`.
  - **Apoyos** (reuso, sin reglas nuevas):
    - `Plantel.pergamino_en_blanco()`;
    - `VidaCero.sacar_del_tablero(criatura, surcos)`: la usan la salvaje en 0 y el sellado, y T25 la va a reusar;
    - `Porcentajes.tiro` y `sale`: `tirar` sigue haciendo una sola llamada al generador.
  - **Acción `Accion.sellar(objetivo)`**: tipo `sellar` en el esquema `grabacion`.
    - Motivos nuevos en `ResultadoAccion`: `SIN_PERGAMINO`, `OBJETIVO_NO_SALVAJE`, `NO_SELLABLE` y `RANGO_ALTO`.
    - Campos nuevos `porcentaje` y `costo` (al validar y al aplicar), y `mana` `{de, a}`.
  - **`Turno._motivo_sellar(id)`** es el único chequeo. Orden:
    1. turno terminado; 2. solo el Maestro; 3. acción usada; 4. sin pergamino;
    5. inexistente; 6. de la tribu; 7. fuera / caída / oculta (`Objetivos` `HOSTIL`, S-21);
    8. no salvaje; 9. fuera de alcance; 10. no sellable; 11. rango alto; 12. maná.
  - **Consultas:**
    - `objetivos_para_sellar()` y `previsualizar_sellar(id)` (= `validar`);
    - `motivo_sellar()`: los pasos 1 a 4, y si no hay ninguna objetivo válida, el motivo de la enemiga que más lejos llegó en el orden (así el tooltip dice "fuera de alcance" o "maná");
    - `Combate.porcentaje_sellado(id)` y `costo_sellado(id)`: para cualquier salvaje de pie, sin mirar distancia, maná ni pergaminos.
  - **Resolución:** gasta la acción y conserva el movimiento. Se paga el maná.
    - Con % > 0 hay una tirada del generador de combate; con 0 no hay tirada y falla (S-50).
    - Si falla, el pergamino no se gasta (S-49), y erizada no cambia el % (S-51).
    - Si sale, el primer pergamino en blanco queda ocupado por ella, pasa a `fuera` y sus surcos se cierran. La cadena se corta por `objetivo_fuera` y la victoria la da `FinCombate`, sin código nuevo (P-029).
  - **Registro** (A.7): `accion` → `mana` (motivo `sellar`) → `tirada` → `sellado` → `estado` → `surco_cerrado` → `cadena_cortada`.
    - El evento `sellado` lleva `objetivo`, `porcentaje`, `tiro` (el número, o `null`), `resultado` (`logrado` / `fallido`) y `pergamino` (o `null`).
    - El `mana` del hechizo y del sellado se registra sin volcar tiradas. Ningún evento existente cambió de forma.
  - **Resultado:** `capturas` = `[{unidad, especie, pergamino, lealtad}]`, sacada de los pergaminos ocupados por salvajes.
    - En el esquema salen `id` y `camino`, que nunca se llenaban (T30 suma lo suyo).
    - La capturada es enemiga: el Cierre no le da el +1 de victoria.
  - **Métrica 7:** `sellados` = `[{objetivo, porcentaje, logrado}]`, en orden (`[]` sin intentos). Su `description` del esquema ya no dice "la llena T24".
  - **Pantalla:**
    - botón **Sellar** con los costos (`Sellar (3/5 Maná)`), solo en el turno del Maestro; deshabilitado, con el motivo en el tooltip;
    - modo "elegir objetivo", excluyente con cavar, Secundar y los hechizos: marca `objetivos_para_sellar`, y el clic izquierdo da `Accion.sellar`;
    - hover en el modo: `sellar.tooltip` y "Maná: de → a";
    - el % sobre cada salvaje, como marca `NN%` en la ficha y como `sellar.tooltip` en su tooltip;
    - sucesos: `sellar.exito`; `sellar.fallo.erizada` si la objetivo está erizada en la `instantanea`; si no, `sellar.fallo` con la variante de la especie;
    - `ClavesTextos.usadas` suma las claves de sellar y las variantes `sellar.fallo.<especie>` que existen.
- **Archivos:**
  - Creados:
    - `nucleo/combate/sellado.gd`;
    - `pruebas/combate/mesa_sellar.gd`, `test_sellado.gd`, `test_sellar.gd` y `test_sellar_combate.gd`;
    - `pruebas/pantalla/test_lectura_sellar.gd` y `test_vista_sellar.gd`;
    - `pruebas/datos/test_sellar_a.gd`;
    - fixtures en `pruebas/fixtures/combate/`: `sellado.json`, `costos_mana.json`, `costos_mana_chico.json`, `especie_sellar_r2.json`, `especie_no_sellable.json`, `escenario_sellar.json` y `escenario_sellar_combate.json`.
  - Modificados:
    - `nucleo/combate/`: `reglas_combate.gd`, `contexto_combate.gd`, `accion.gd`, `resultado_accion.gd`, `turno.gd`, `combate.gd`, `resultado_combate.gd`, `metricas_combate.gd`, `vida_cero.gd` y `porcentajes.gd`;
    - `nucleo/unidades/plantel.gd`;
    - `datos/_esquemas/grabacion.schema.json` y `resultado.schema.json`;
    - `pantalla/claves_textos.gd`, `pantalla/combate/lectura_combate.gd`, `vista_combate.gd` e `interprete_clic.gd`;
    - `pruebas/combate/datos_fixture.gd`, `test_reglas_combate.gd` y `test_metricas_combate.gd`;
    - `pruebas/pantalla/test_claves_textos.gd` y `test_lectura_combate.gd`;
    - `docs/PREGUNTAS.md` y `CLAUDE.md` ("Estado actual").
- **Tests:** 31 nuevos, total 630. Última suite completa del 11/10/2026: 630/630 en verde.
  - **Tests viejos reescritos:**
    - `test_metricas_combate.gd::test_metricas_9_y_11`: `sellados` deja de estar en `null` y pasa a `[]` (D-011, T24);
    - `test_reglas_combate.gd` (`_armar`): `ReglasCombate.new` suma la regla `sellado` (D-008);
    - `test_lectura_combate.gd::test_t40_tooltip_de_una_enemiga`: la ficha del Zancajunco salvaje suma `0%` (`Sistema.md` 4.1: % sobre la salvaje, T24).
  - **Intermitentes:** en dos suites completas fallaron 8 tests de mouse (a veces 9):
    - `test_principal.gd::test_clic_del_mouse_llega_al_tablero`;
    - los 3 de mouse de `test_vista_camara.gd`;
    - 2 de `test_vista_hechizos.gd`;
    - 2 de `test_vista_sellar.gd`.
    - La casilla del mouse salía con coordenadas de pantalla reales: (41,34) donde se esperaba (1,7), y (164,9). Pasan corriendo `pruebas/pantalla` sola, y la tercera suite completa salió en verde sin cambiar código. Parece que eventos del cursor real de la máquina llegan a la ventana de los tests.
    - No se tocó ningún test. Queda para una tarea propia.
- **Criterio de terminado:** cumplido punto por punto:
  1. `test_sellado.gd`: vida máx. 140 con 35/36, 70/71 y 105/106, y vida máx. 33 sin ningún borde entero, en los 3 rangos.
  2. `test_sellado.gd`: costo con balanza 2, 3 y 5; mínimo 1 con `costos_mana_chico.json`; lealtad 2, 1 (3 y 4) y 0.
  3. `test_sellar.gd::test_un_caso_por_motivo_en_orden`: los 12 motivos en orden, sin cambiar nada. `motivo_sellar` coincide salvo en inexistente, de la tribu, fuera y caída: no tienen objetivo, o el combate ya habría terminado. También `test_motivo_sellar_dice_la_que_mas_lejos_llego`.
  4. `test_quienes_no_son_objetivo`: oculta, caída (la atacante), de la tribu, atacante, no sellable, rango alto (balanza 1) y distancia 3.
  5. `test_fallo` (maná, pergamino en blanco, acción usada, movimiento entero y `mover` válido) y `test_erizada_da_el_mismo_porcentaje`.
  6. `test_exito`: fuera, pergamino ocupado, 2 surcos cerrados por `duenio_fuera`, cadena por `objetivo_fuera` y victoria. También `test_exito_sin_ser_la_ultima_sigue_el_combate`.
  7. `test_cero_por_ciento_sin_tirada`.
  8. `test_sellar_combate.gd`: orden del registro, y la grabación con un fallido y un logrado valida y se reproduce igual. El `surco_cerrado` en el orden se comprueba en el turno suelto (6): en el fixture de combate, el Surcón no cava.
  9. `test_resultado_con_capturas_valida` (lealtad 1, sin anotación para la capturada), y la métrica 7 con dos intentos y vacía.
  10. `test_vista_sellar.gd` (botón, motivo, modo, % de la ficha, hover = evento, clic por evento) y `test_lectura_sellar.gd` (fallo, fallo de especie, fallo erizada, logrado, y botón con dos costos).
  11. `test_sellar_a.gd` (`datos/` real): el % mostrado = el del evento = la celda de `tablas/sellado.json`.
  12. `test_contacto`, `test_robustez_ia`, el permanente, `test_lanzadera_b` y `test_metricas_escenarios` pasan.
  13. Suite completa en verde (ver "Intermitentes").
- **Lecturas declaradas:**
  - S-49, S-50 y S-51, ya declaradas en `Arquitectura.md`.
  - Técnicas, sin pregunta:
    - `motivo_sellar` da el motivo más avanzado;
    - `tiro` es el número de la tirada;
    - con % > 0 se tira (la convención de `Porcentajes`).
- **Claves de texto nuevas sin texto:** `aviso.sellar.accion_usada`, `aviso.sellar.mana_insuficiente`, `aviso.sellar.fuera_de_alcance`, `aviso.sellar.no_sellable`, `aviso.sellar.oculta`, `aviso.sellar.no_salvaje` y `aviso.sellar.sin_objetivos`.
- **Preguntas:** nuevas: ninguna. Cerradas: P-043.
- **Para la próxima sesión:** nada: tarea terminada.
- **Prueba manual:**
  1. Tests. En `cmd`: `addons\gdUnit4\runtest.cmd -a res://pruebas`; en PowerShell: `& .\addons\gdUnit4\runtest.cmd -a res://pruebas`. Todo en verde (unos 10 minutos). No muevas el mouse sobre la ventana de Godot mientras corre (ver "Intermitentes").
  2. Abrir el juego: F5, o en PowerShell `& $env:GODOT_BIN --path .` (en `cmd`: `"%GODOT_BIN%" --path .`). Jugar A. La ficha de la Ocarra muestra `5%` desde el principio, y su tooltip dice el %. Al golpearla, baja de tramo (≤ 75 %: 20 %; ≤ 50 %: 50 %; ≤ 25 %: 80 %).
  3. Botón Sellar: gris con la Ocarra lejos, y el tooltip dice por qué (`[FALTA: aviso.sellar.fuera_de_alcance]`). Con el Maestro a 2 o menos, el modo marca a la Ocarra, y el hover dice el % y "Maná: 8 → 5".
  4. Un sellado fallido: el maná baja y el pergamino sigue en blanco (panel F3). Uno logrado: la Ocarra sale del tablero y el combate termina en victoria.
  5. Abrir el `registros/a_dia_1_<semilla>_<n>_resultado.json` más nuevo: `capturas` con la Ocarra y lealtad 2, y `metricas.sellados` con cada intento y su %.
  6. D normal: sellar al Surcón salvaje cierra sus surcos. Si la Rodauva salvaje está erizada y el sellado falla, el suceso es "El hilo resbala entre las púas.".
  7. **H no sirve para esto:** su única enemiga es el Tasajero, que no es sellable (no muestra %). Para ver la balanza en el costo, usar D balanza 4: descuento 1 (Surcón 4, Rodauva 2) y lealtad de la capturada 1.
  8. Anotar los `[FALTA]` que aparezcan.

## T24-ajustes · sesión 1 · 11/10/2026
- **Rama:** tarea/T24-ajustes
- **Estado:** EN CURSO, **bloqueada por P-044** (Arquitecto). La causa de los intermitentes no es la que supone la tarea, y el prompt pide parar en ese caso.
- **Hecho:**
  - **Diagnóstico con evidencia** (registros temporales en `VistaCombate._input` y en los `_mandar` de los tests; ya borrados):
    - Corrida de `pruebas/pantalla` sin tocar el mouse (113/113): la vista recibió 186 movimientos y los tests mandaron 13. Los otros son movimientos en `(0,0)`, uno por frame y por vista viva, con `device=32`. Vienen del `Input.warp_mouse(Vector2.ZERO)` que hace el runner de escenas de GdUnit4 al crearse (`GdUnitSceneRunnerImpl.gd`, líneas 82 a 88).
    - Corrida con el usuario moviendo el mouse sobre la ventana (113/113): 22 eventos reales con la posición del cursor (por ejemplo `(213,88)`) y un clic real en `(1,3)`, todos con `device=32`. Los eventos del test traen también `device=32` (el valor por defecto de un `InputEvent` nuevo).
    - Corrida siguiente de `pruebas/pantalla` (con la opción B puesta): 25 fallas y 2 errores con el síntoma de T24, `(93,80)` donde se esperaba `(1,7)`. También falló el test nuevo con el filtro **desactivado**, y la casilla sí seguía a los eventos del test: el evento llegaba, con otra escala. La corrida siguiente salió 115/115, con la ventana siempre en 1152 × 648 y la transformación final en identidad.
    - **Causa:**
      - Los tests calculan la posición en coordenadas del viewport, y `Input.parse_input_event` la toma en coordenadas de la ventana: le aplica la inversa de `Viewport.get_final_transform()`. Con `canvas_items` + `expand`, esa transformación es la identidad solo si la ventana mide 1152 × 648.
      - GdUnit4 minimiza la ventana al liberar cada runner y la restaura al crear el siguiente (`move_window_to_background` / `move_window_to_foreground`).
      - Test temporal (borrado): con la ventana en 200 × 120, el evento del test para `(1,7)` en `(351,398)` llega como `(2025,2296)` y da `(35,45)`. Minimizar en el mismo frame no cambia nada: el tamaño se actualiza después.
      - Los eventos reales existen y llegan a la vista (hasta un clic), pero no producen las casillas enormes.
  - **Opción A descartada:** `runtest.cmd --headless --ignoreHeadlessMode -a res://pruebas/pantalla` da 10 fallas y 1 error. Ejemplos: `test_principal.gd:114` (el clic no movió a la unidad), `test_vista_camara.gd:180` (`(27,126)`), `test_vista_hechizos.gd:224` (error de script: no hubo vista previa). GdUnit4 avisa que en headless no transporta los `InputEvent`.
  - **Opción B escrita y probada, pero no corrige la causa:**
    - En `VistaCombate`: `dispositivo_mouse` (por defecto `DISPOSITIVO_CUALQUIERA` = −1000) y el filtro al principio de `_input` (otro device → `set_input_as_handled`).
    - `pruebas/pantalla/mouse_prueba.gd` (`MousePrueba.DISPOSITIVO` = 7, `preparar`, `marcar`) y los `_mandar` de los 4 archivos con su device.
    - `test_vista_dispositivo_mouse.gd` (2 tests, pasan).
    - **Queda en `git stash`** ("T24-ajustes: opcion B (costura de device), en pausa por P-044"), no en la rama.
- **Archivos:** modificados `docs/PREGUNTAS.md` y `docs/RESUMENES.md`. Código: ninguno (la rama está igual que `develop`; la opción B, en el stash).
- **Tests:** 0 nuevos en la rama, total 630. Suite completa: no se corrió (no hay cambios de código). `pruebas/pantalla` con la opción B: 115/115 en la última corrida, 25 fallas en la anterior (la falla de ventana).
- **Criterio de terminado:** parcial.
  - Cumplido: 1 (diagnóstico con evidencia, arriba).
  - Faltan 2 a 6: dependen de P-044.
- **Lecturas declaradas:** ninguna.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** nueva P-044 (ARQUITECTO, bloquea sí). Cerradas: ninguna.
- **Texto propuesto para D-012** (si se toma la recomendación de P-044): "Los tests de pantalla mandan el mouse en coordenadas de ventana: el ayudante de los tests (`MousePrueba`) multiplica la posición del viewport por `Viewport.get_final_transform()` antes de `Input.parse_input_event`, y marca el evento con su propio `device`. La vista acepta solo el `device` configurado en `dispositivo_mouse` (por defecto, cualquiera). Así la casilla no depende del tamaño que tenga la ventana cuando GdUnit4 la restaura, y el cursor real de la máquina no pisa los eventos del test. El comando de tests no cambia."
- **Para la próxima sesión:**
  - Con la respuesta de P-044: `git stash pop` en esta rama si sirve la opción B.
  - Con la opción A de P-044: conversión a coordenadas de ventana en `MousePrueba`, y un test que reproduzca la ventana chica (como el experimento de 200 × 120) sin cambiar las aserciones de los 9 tests.
  - Después, las tres suites completas (una con el mouse en movimiento), `CLAUDE.md` y la prueba manual.

## T24-ajustes · sesión 2 · 11/10/2026
- **Rama:** tarea/T24-ajustes
- **Estado:** TERMINADA (pendiente de PR). Esta entrada resume la tarea entera (sesiones 1 y 2).
- **Diagnóstico (sesión 1, en corto):** los tests calculaban la posición del mouse en coordenadas del viewport, y `Input.parse_input_event` la toma en coordenadas de ventana (le aplica la inversa de `Viewport.get_final_transform()`). Con `canvas_items` + `expand` eso es la identidad solo con la ventana en 1152 × 648, y GdUnit4 minimiza y restaura la ventana entre runners: si el tamaño todavía no volvió, la casilla sale corrida (`(35,45)` en lugar de `(1,7)`). Además llegan a la vista eventos que no son del test (el `warp_mouse` del runner y el cursor real, hasta un clic), con el mismo `device` que un evento nuevo. Sin ventana (`--headless`) quedó descartado: 10 fallas. P-044 → D-012.
- **Hecho:**
  - **Filtro de dispositivo** (recuperado del `stash` de la sesión 1, sin cambios): `VistaCombate.dispositivo_mouse` (por defecto `DISPOSITIVO_CUALQUIERA` = −1000: el juego acepta cualquiera) y el filtro al principio de `_input`: un mouse de otro device se marca como manejado y no guarda posición ni llega a botones, clic, hover ni arrastre. Un solo lugar; `nucleo/` sin cambios.
  - **`MousePrueba`** (`pruebas/pantalla/mouse_prueba.gd`), el único camino del mouse de los tests: `DISPOSITIVO` (7), `preparar(vista)`, `a_ventana(evento, final, dispositivo)` (pura: copia con la posición por `final`, el `relative` por su parte lineal, sin traslación, y el device; `global_position` no cambia, como hace Godot), `mandar(evento, dispositivo)` (lee `root.get_final_transform()` en el momento, `parse_input_event` + `flush_buffered_events`), `mover_a` y `clic_en`.
  - Los 4 archivos con `_mandar` propio (`test_principal.gd`, `test_vista_camara.gd`, `test_vista_hechizos.gd`, `test_vista_sellar.gd`) perdieron sus `_mandar`, `_mover_a` y `_clic_en`, y usan `MousePrueba` (también la rueda y el arrastre de la cámara, que manda `relative`). Cada vista se prepara con `MousePrueba.preparar`. Ninguna aserción cambió.
  - P-044 `CERRADA`.
- **Archivos:** creados `pruebas/pantalla/mouse_prueba.gd`, `test_mouse_prueba.gd` y `test_vista_dispositivo_mouse.gd` (con sus `.uid`); modificados `pantalla/combate/vista_combate.gd`, `pruebas/pantalla/test_principal.gd`, `test_vista_camara.gd`, `test_vista_hechizos.gd`, `test_vista_sellar.gd`, `CLAUDE.md`, `docs/PREGUNTAS.md` y `docs/RESUMENES.md`. `docs/Arquitectura.md` v0.43 viene de la sincronización del usuario.
- **Tests:** 6 nuevos, total 636, todos pasan.
  - `test_mouse_prueba.gd`: `test_movimiento_a_ventana` y `test_boton_a_ventana` (conversión sin ventana, con `Transform2D(0, (2,3), 0, (10,20))`), `test_identidad_no_cambia_la_posicion` y `test_ventana_chica`.
  - `test_ventana_chica`: achica la ventana a 200 × 120, espera frames **antes** del evento hasta que el tamaño y la transformación cambian (tope de 120 frames; si no, falla con mensaje), manda hover y clic por `MousePrueba` sin `await` en el medio y comprueba la casilla y el movimiento; `after_test` restaura el tamaño. Comprobado: con la conversión desactivada a propósito (cambio temporal, ya revertido) falla con `(35, 45)`, la casilla del diagnóstico. Determinista: pasó en `pruebas/pantalla`, en 3 corridas seguidas junto con `test_vista_camara.gd` y en las 3 suites.
  - `test_vista_dispositivo_mouse.gd`: `test_otro_dispositivo_no_cambia_la_casilla` y `test_por_defecto_acepta_cualquier_dispositivo`.
- **Suites completas** (`addons/gdUnit4/runtest.cmd -a res://pruebas`, unos 15 minutos cada una):
  1. 636/636, sin tocar el mouse.
  2. 636/636, **con el mouse real moviéndose y haciendo clics** sobre la ventana de tests: un script de PowerShell (fuera del repositorio) movió el cursor del sistema y clickeó solo cuando la ventana bajo el punto era `Proyecto Pokemon (DEBUG)` (241 movimientos y 15 clics).
  3. 636/636, sin tocar el mouse.
- **Búsqueda del criterio 4:** `parse_input_event(` en `pruebas/` da 5 resultados: `mouse_prueba.gd:38` (el único con mouse) y 4 con `InputEventAction` (`test_vista_ritmo_ia.gd:171`, `test_vista_rasgos.gd:74`, `test_vista_camara.gd:370` y `test_principal.gd:140`). Fuera de `MousePrueba`, con mouse: **0**.
- **Criterio de terminado** (B.4, fila T24-ajustes): cumplido. 1 diagnóstico con evidencia (sesión 1); 2 los 9 tests (`test_principal.gd::test_clic_del_mouse_llega_al_tablero`, los 3 de mouse de `test_vista_camara.gd`, los 2 de `test_vista_hechizos.gd` y los 2 de `test_vista_sellar.gd`) pasan en las 3 suites sin cambiar aserciones; la corrida de la sesión 1 con 25 fallas en `pruebas/pantalla` tuvo la misma causa, pero su lista no quedó guardada: en las 3 suites pasa todo `pruebas/pantalla`; 3 tres suites seguidas en verde, la 2 con el mouse moviéndose; 4 el juego con el mouse: falta tu prueba manual (abajo); 5 el comando no cambió (`CLAUDE.md` suma la línea de `MousePrueba`).
- **Consola:** sin errores ni advertencias nuevas: las tres suites dan exactamente la misma lista. Los `ERROR: ReglasCombate: falta la regla …` son los que provocan a propósito `test_reglas_combate.gd` y `test_sellado.gd`, y los dos `ERROR: Remote Debugger` / `remote port` aparecen también corriendo solo `pruebas/azar` (arranque del runner).
- **Supuestos:** la transformación que se usa es la de la ventana principal (`SceneTree.root`), que es la que recibe `parse_input_event`; en los tests es la misma que `get_viewport()` de la vista. `global_position` no se convierte porque Godot tampoco la convierte al despachar.
- **Lecturas declaradas:** ninguna.
- **Claves de texto nuevas sin texto:** ninguna.
- **Preguntas:** nuevas ninguna; cerrada P-044.
- **Nota:** la suite completa ya tarda unos 15 minutos (`CLAUDE.md` todavía dice 4 en las reglas de tests, fuera de "Estado actual").
- **Prueba manual (Windows):**
  1. Dos suites seguidas, en verde. En una, mové el mouse por encima de la ventana de Godot y hacé algún clic mientras corre.
     - `cmd`: `addons\gdUnit4\runtest.cmd -a res://pruebas`
     - PowerShell: `& .\addons\gdUnit4\runtest.cmd -a res://pruebas`
  2. F5 en el editor (o `& $env:GODOT_BIN --path .` en PowerShell, `"%GODOT_BIN%" --path .` en `cmd`) → escenario A: hover sobre casillas y unidades, clic para mover, arrastrar la cámara con el botón del medio, zoom con la rueda, un hechizo (clic izquierdo empuja, derecho atrae) y un sellado con el mouse. Todo tiene que andar igual que antes.
- **Para la próxima sesión:** nada: tarea terminada.

## T25 · sesión 1 · 11/10/2026
- **Rama:** tarea/T25-huida
- **Estado:** TERMINADA (pendiente de PR). La tarea entró en una sesión, con la pantalla.
- **Hecho:**
  - **Regla `Huida`** (`nucleo/combate/huida.gd`, sin estado; D-008: en `ReglasCombate`, `ContextoCombate.armar` y `DatosFixture.reglas`). Lee `tablas/combate.json` `huida_salvaje.umbral_vida_pct` y `acobardada_pts` y `encono.max_puntos`; el % sale de `huida_pct` de cada ficha. Sin un dato da `null` y el contexto se rechaza con `REGLA_FALTANTE`.
    - `porcentaje(id, plantel, acobardada)` da 0 en tres casos: no es una salvaje de pie (la tribu, el Maestro y la atacante nocturna no huyen: 9.2 punto 5), `vida × 100 > umbral × vida_max`, o el Encono está en el máximo (S-52). En los demás, el de la ficha más el +25 si `acobardada`, recortado a 100.
    - `porcentaje_al_empezar` = sin el +25. Es el único lugar de la lectura S-52.
    - `tirar`: con 0 % no toca el generador.
  - **Paso 2 del inicio del turno** (`Turno._huir`, el lugar de T08): después de borrar Erizarse, antes del cambio de modo, del chequeo de rival y del incidente. No corre con `entrada.vuelve` (S-31).
    - Si huye: `VidaCero.sacar_del_tablero` (`fuera`, sin posición, surcos cerrados) y el turno termina. `empezar` no prepara nada más. Las otras entradas de la ronda las saltea la cola, como a cualquiera que sale del tablero.
    - `Turno.huida`: `{porcentaje, tiro, resultado}` o `{}`.
    - Sale el lugar vacío `IASalvaje._paso_huida`: el paso 1 de 11.8 lo hace el inicio del turno.
  - **`Combate`:**
    - `porcentaje_huida(id)`, la consulta para la pantalla (D-005).
    - Evento `huida` (`unidad`, `porcentaje`, `tiro`, `resultado` `huye` / `se_queda`), justo detrás del `turno` (y del `mana`, que nunca coincide) y de su propia `tirada`, solo si hubo tirada.
    - Si huye siguen `estado` (`suelta` → `fuera`), `surco_cerrado` y `fin_turno` con `posicion: null`, sin `encierro` porque no está en el tablero. Si era la última enemiga, `fin` (victoria) y `cierre`.
  - **Métrica 8** (`MetricasCombate`): `capturas_perdidas` = `[{unidad, motivo, ronda}]`, con motivo `huida` o `cero`, en el orden del registro.
    - Cada `estado` a `fuera` mira el evento que lo precede para esa unidad: un `huida` con `huye` da `huida`; un `sellado` `logrado` no cuenta; ninguno de los dos, siendo una enemiga salvaje (`comportamiento` del escenario), da `cero`.
    - Esquema `resultado`: lista de objetos, con la `description` nueva.
  - **Pantalla** (`LecturaCombate`):
    - Marca de la ficha `marca_huida(pct)` = `marca.huida` + " N%". El número va fuera de la clave, así que se ve aunque falte.
    - Línea del tooltip `linea_huida` (`huida.salvaje.porcentaje` con `{porcentaje}`).
    - Las dos salen de `porcentaje_huida`, solo si es > 0.
    - Suceso `huida`: `huye` → `huida.salvaje` con la variante de la especie (están las cinco en `es.json`); `se_queda` → `huida.salvaje.se_queda` (o su variante) solo si existe.
    - `ClavesTextos`: `MARCA_HUIDA` y `HUIDA_PORCENTAJE` en `FIJAS`, y `usadas` suma las variantes de huida y `se_queda` solo si existen (nunca la base `huida.salvaje`).
  - **Mantenimiento:** `CLAUDE.md` dice "unos 15 minutos" para la suite completa.
- **Forma del registro** (A.7):
  - Huye y el combate sigue: `turno` → `tirada` → `huida` → `estado` → `surco_cerrado`* → `fin_turno` (`posicion: null`).
  - Huye la última enemiga: `turno` → `tirada` → `huida` → `estado` → `surco_cerrado`* → `fin` → `cierre`.
  - Se queda: `turno` → `tirada` → `huida` → `cambio_modo`? → `tirada`? → `chequeo_rival`? → …, como antes.
  - Ningún evento existente cambió de forma.
- **Archivos:**
  - Creados: `nucleo/combate/huida.gd`; `pruebas/combate/mesa_huida.gd`, `test_huida.gd` y `test_huida_combate.gd`; `pruebas/pantalla/test_lectura_huida.gd` y `test_vista_huida.gd` (todos con su `.uid`).
  - Fixtures creadas: `pruebas/fixtures/combate/especie_huida_100.json`, `especie_huida_1.json`, `escenario_huida.json`, `escenario_huida_combate.json` y `escenario_huida_tasajero.json`, y `pruebas/fixtures/pantalla/escenario_huida_pantalla.json`.
  - Modificados: `nucleo/combate/combate.gd`, `contexto_combate.gd`, `reglas_combate.gd`, `turno.gd`, `metricas_combate.gd` y `vida_cero.gd` (comentario); `nucleo/combate/ia/ia_salvaje.gd` y `decision_ia.gd`; `pantalla/claves_textos.gd` y `pantalla/combate/lectura_combate.gd`; `datos/_esquemas/resultado.schema.json`; `pruebas/combate/datos_fixture.gd`, `test_metricas_combate.gd` y `test_reglas_combate.gd`; `CLAUDE.md` y `docs/RESUMENES.md`.
- **Tests:** 29 nuevos, total 665, todos pasan (suite completa).
  - `test_huida.gd` (16): umbral con vida máxima 30 (7 tira, 8 no), especie con 0 %, Encono en 3 y en 2, +25 y recorte, regla sin un dato, solo salvajes sin tocar el generador, fuera da 0, huye (fuera, surcos, turno terminado), pierde sus entradas, se queda y la IA juega, se queda y sigue el chequeo de rival, 0 % sin tirada, y el Tasajero (antes del cambio de modo, huye sin cambiar de modo, sobre el umbral solo cambia, al volver no tira).
  - `test_huida_combate.gd` (6): orden del registro al huir y al quedarse, la última que huye da la victoria, el Tasajero tira una vez por ronda durante dos rondas, la grabación se reproduce igual y el resultado con huida valida contra el esquema.
  - `test_metricas_combate.gd::test_metrica_8_capturas_perdidas` (1): una huida, una por cero, una sellada que no cuenta, un sellado fallido que no salva y una tribu y una atacante que no cuentan.
  - `test_lectura_huida.gd` (5) y `test_vista_huida.gd` (1).
- **Tests viejos reescritos:**
  - `test_metricas_combate.gd::test_metricas_9_y_11`: `capturas_perdidas` dejó de ser `null` (D-011, T25, `Sistema.md` 11.9 métrica 8). En la victoria, la Ocarra salvaje que pasa a `fuera` ahora cuenta como `{ocarra_s1, cero, 2}`; en la derrota, `[]`. Además, el escenario mínimo del archivo suma `comportamiento` a las enemigas (la métrica 8 lo lee, como en todo escenario real) y una atacante nocturna.
  - `test_reglas_combate.gd::_armar`: el constructor suma `huida` (D-008). Sin cambios de aserciones.
  - Ningún otro: no hubo tests que compararan la lista de eventos del turno de una salvaje herida.
- **Criterio de terminado:** cumplido.
  1. Porcentaje: `test_huida.gd`, los 5 primeros.
  2. Solo salvajes: `test_solo_salvajes` y `test_fuera_da_cero`.
  3. Huye, pierde sus entradas y la victoria: `test_huye`, `test_huye_pierde_sus_entradas_de_la_ronda` y `test_la_ultima_que_huye_da_la_victoria`.
  4. Se queda: `test_se_queda_y_el_turno_sigue`, `test_se_queda_y_sigue_el_chequeo_de_rival` y `test_se_queda_y_juega`.
  5. Con 0 %: `test_con_cero_no_tira`.
  6. Tasajero: tres tests de turno y `test_tasajero_una_tirada_por_ronda`.
  7. Registro y grabación: `test_huye_registro_en_el_orden_de_a7` y `test_grabacion_se_reproduce_igual`.
  8. Métrica 8 y resultado: `test_metrica_8_capturas_perdidas` y `test_resultado_con_huida_valida`.
  9. `datos/` real: pasan el permanente, `test_contacto`, `test_robustez_ia`, `test_metricas_escenarios`, `test_sellar_a` y `test_lanzadera_b`.
  10. Pantalla: `test_lectura_huida.gd` y `test_vista_huida.gd`. El mouse va por `MousePrueba` (D-012).
  11. Suite completa en verde.
- **Consola:** sin errores ni advertencias nuevas. Los `ERROR: ReglasCombate: falta la regla …` son los que provocan a propósito `test_reglas_combate.gd` y `test_sellado.gd` (suma `huida`, porque el test recorre `REGLAS`), y los dos del `Remote Debugger` son del arranque del runner.
- **Supuestos y lecturas técnicas:**
  - Si la huida gana el combate, no va `fin_turno`: lo mismo que hoy con una acción que gana, porque `_ejecutar` solo registra `fin_turno` con el combate en curso.
  - El `fin_turno` de la que huyó lleva `posicion: null` (`Plantel.casilla_a_lista` de una unidad sin casilla).
  - Una oculta puede huir: `Objetivos.de_pie` la cuenta.
  - Con la fórmula del prompt, una especie con 0 % acobardada daría 25. Hoy no pasa nunca (S-52: el +25 no aplica en el paso 2) y solo lo comprueba el test de la regla.
  - Al huir, la unidad no se destapa (queda `oculta` en una unidad `fuera`, como la salvaje en 0). Ninguna regla la mira; lo limpia el `Cierre`.
- **Lecturas declaradas:** S-52 (ya declarada en `Arquitectura.md` 10.5), en `Huida.porcentaje_al_empezar`.
- **Claves de texto nuevas sin texto:** `marca.huida` (marca de la ficha: en pantalla se ve `[FALTA: marca.huida] 25%`) y `huida.salvaje.porcentaje` (tooltip, con `{porcentaje}`). Opcional, no se ve si falta: `huida.salvaje.se_queda` (con variantes `.<especie>`). Existe y no se usa: `huida.salvaje.tooltip` ("Se fue. Ya no se puede sellar."), porque la unidad que huyó ya no está en el tablero ni tiene tooltip; queda para el Worldbuilder decidir dónde va.
- **Preguntas:** ninguna nueva; ninguna cerrada.
- **Prueba manual (Windows):**
  1. Suite completa, en verde:
     - `cmd`: `addons\gdUnit4\runtest.cmd -a res://pruebas`
     - PowerShell: `& .\addons\gdUnit4\runtest.cmd -a res://pruebas`
  2. Abrir el juego: F5 en el editor, o `"%GODOT_BIN%" --path .` (`cmd`) / `& $env:GODOT_BIN --path .` (PowerShell).
  3. D normal: bajar a la Rodauva salvaje a 25 % o menos. Antes de su turno se ve su % de huida (50 %) en la ficha (`[FALTA: marca.huida] 50%`) y en el tooltip. En su turno, el suceso dice que huyó (su línea de especie) y sale del tablero; si se queda, no hay línea (falta `huida.salvaje.se_queda`) y juega normal.
  4. C: bajar al Tasajero a 25 % o menos (75 de 300). Antes de su turno se ve el 25 %; tira una sola vez por ronda (F3: un `huida` por ronda en el registro), antes de pasar a Cuenta.
  5. A: la Ocarra no muestra % de huida aunque esté en 25 % (su ficha dice 0).
  6. Abrir el `_resultado.json` más nuevo de `registros/`: `metricas.capturas_perdidas` con la que huyó (`huida`) o la que llegó a 0 (`cero`); las selladas no aparecen.
  7. Anotar los `[FALTA]` que aparezcan.
- **Para la próxima sesión:** nada: tarea terminada.


## T26 · sesión 1 · 12/10/2026
- **Rama:** tarea/T26-guardar-invocar
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:**
  - **Costo de maná en un solo lugar:** regla `CostosMana` (`nucleo/combate/costos_mana.gd`, sin estado) con `sellar(especie, maestro)` e `invocar(especie, maestro)`, las dos por `max(mínimo, costo del rango − descuento)` (`Sistema.md` 2.3). Está en `ReglasCombate` (campo, `_init`, `REGLAS`), `ContextoCombate.armar` (+ `contexto.costos_mana`) y `DatosFixture.reglas` / `DatosFixture.costos_mana`. `Sellado.desde_datos` recibe la misma instancia y `Sellado.costo` delega: sellar no cambió de comportamiento y `test_sellado.gd` no se tocó.
  - **Guardar** (`Accion.guardar()`): un solo chequeo, `Turno._motivo_guardar` (turno terminado → `SOLO_CRIATURA_DE_LA_TRIBU` → `ENCONADA` → `ACCION_USADA` → `CASILLA_NO_ADYACENTE`). La acobardada puede. Efecto en `Turno._dejar_guardada`: `guardada`, sin posición, pergamino ocupado, `Surcos.cerrar_de`, pierde erizada, oculta, bono y el límite del junco; conserva vida, hambre, lealtad, enfermedades, Encono y modo. Termina el turno.
  - **Invocar** (`Accion.invocar(criatura_id, casilla)`): un solo chequeo, `Turno._motivo_invocar(id, casilla = SIN_POSICION)` (turno terminado → `SOLO_MAESTRO` → `ACCION_USADA` → `YA_SE_MOVIO` → `OBJETIVO_INEXISTENTE` / `OBJETIVO_ENEMIGO` / `NO_GUARDADA` → `SIN_CASILLA_LIBRE` → `MANA_INSUFICIENTE` → `CASILLA_NO_ADYACENTE` / `CASILLA_NO_LIBRE`). Paga, queda suelta en la casilla, `Junco.revisar_contacto` y gasta el turno completo (después solo `terminar`, que no es esperar). Entra en la cola desde la ronda siguiente sin código nuevo en la cola.
  - **Motivos:** nuevos `SOLO_CRIATURA_DE_LA_TRIBU`, `NO_GUARDADA` y `SIN_CASILLA_LIBRE`. Reusados: `TURNO_TERMINADO`, `ENCONADA`, `ACCION_USADA`, `CASILLA_NO_ADYACENTE`, `SOLO_MAESTRO`, `YA_SE_MOVIO`, `OBJETIVO_INEXISTENTE`, `OBJETIVO_ENEMIGO`, `MANA_INSUFICIENTE` y `CASILLA_NO_LIBRE`.
  - **Consultas** (D-005): `motivo_guardar()`, `guardadas_para_invocar()`, `casillas_para_invocar()`, `motivo_invocar(id)`, `previsualizar_invocar(id, casilla)` y `Combate.costo_invocar(id)`. Para las ocultas que destaparía una invocada, `Junco.destaparia_al_entrar` (la regla de `destaparia` sin pedir que esté de pie; `destaparia` la usa).
  - **Registro** (A.7): guardar → `accion`, `estado`, `surco_cerrado`, `fin_turno` con `posicion: null`; invocar → `accion`, `mana` (motivo `invocar`, D-007), `estado`, `invocacion` (`unidad`, `casilla`), `destape`. Ningún evento existente cambió.
  - **Grabación:** tipos `guardar` e `invocar` (`criatura`, `casilla`) en `datos/_esquemas/grabacion.schema.json`, con ida y vuelta en `Accion`.
  - **Pantalla:** botón `Guardar` (solo si `motivo_guardar` lo deja, tooltip `guardar.tooltip`); en el turno del Maestro, botones `Invocar_<id>` con nombre y costo, deshabilitados con su motivo y `invocar.tooltip`; modo "elegir casilla" con las casillas de la consulta, excluyente con cavar, Secundar, hechizos y sellar; aviso de destapar en el hover; clic izquierdo por `InterpreteClic`; sucesos `guardar` e `invocar`.
- **Archivos:**
  - Creados: `nucleo/combate/costos_mana.gd`; `pruebas/combate/mesa_guardar.gd`, `test_costos_mana.gd`, `test_guardar.gd`, `test_invocar.gd`, `test_guardar_invocar_combate.gd`; `pruebas/pantalla/test_lectura_guardar_invocar.gd`, `test_vista_guardar_invocar.gd`; `pruebas/datos/test_invocar_a.gd`; `pruebas/fixtures/combate/escenario_guardar.json` y `escenario_guardar_invocar_combate.json`.
  - Modificados: `nucleo/combate/accion.gd`, `combate.gd`, `contexto_combate.gd`, `junco.gd`, `reglas_combate.gd`, `resultado_accion.gd`, `sellado.gd`, `turno.gd` y `cierre.gd` (solo un comentario); `pantalla/claves_textos.gd`, `pantalla/combate/interprete_clic.gd`, `lectura_combate.gd` y `vista_combate.gd`; `datos/_esquemas/grabacion.schema.json`; `pruebas/combate/datos_fixture.gd` y `test_reglas_combate.gd`; `CLAUDE.md` y `docs/RESUMENES.md`.
- **Tests:** 47 nuevos, total 712, todos pasan (suite completa).
  - `test_costos_mana.gd` (3), `test_guardar.gd` (14), `test_invocar.gd` (11), `test_guardar_invocar_combate.gd` (9), `test_invocar_a.gd` (1), `test_lectura_guardar_invocar.gd` (3) y `test_vista_guardar_invocar.gd` (6).
- **Tests viejos reescritos:** solo `test_reglas_combate.gd::_armar`: el constructor de `ReglasCombate` suma `costos_mana` (D-008). Sin cambios de aserciones. `DatosFixture.sellado` arma el `CostosMana` del fixture que le pidan (ayudante, no test).
- **Criterio de terminado:** cumplido.
  1. Costo por rango con balanza 2, 3 y 5 y el mínimo: `test_costos_mana.gd`; `test_sellado.gd` pasa sin cambios.
  2. Guardar junto al Maestro, también después de moverse: `test_guardar_junto_al_maestro` y `test_guardar_despues_de_moverse`.
  3. Rechazos sin cambios (diagonal, distancia 2, después de atacar, enconada, distraída, salvaje y Maestro) y la acobardada vale: `test_guardar.gd`.
  4. Efectos (afinidad en el acto, surcos, oculta, erizada, lo que conserva): `test_guardar.gd`. Además, `test_no_toca_la_cadena`.
  5. Invocar con el turno sin usar y lo que se rechaza después: `test_invocar_con_el_turno_sin_usar`.
  6. Rechazos de invocar: `test_con_el_turno_usado_no`, `test_casillas_que_no_valen`, `test_maestro_rodeado`, `test_mana_insuficiente`, `test_criaturas_que_no_se_invocan` y `test_una_criatura_no_invoca`.
  7. Ronda de entrada y S-56: `test_ronda_de_entrada`, `test_guardada_en_la_ronda_se_invoca_en_la_misma` y `test_guardada_en_este_combate`.
  8. Destape por contacto: `test_destapa_por_contacto`.
  9. Hambre de combate: `test_hambre_de_combate` (turnos sueltos y dentro del `Combate`).
  10. Cierre: `test_cierre_victoria` y `test_cierre_derrota`.
  11. Registro y grabación: `test_registro_en_el_orden_de_a7`, `test_surco_cerrado_en_el_registro`, `test_grabacion_se_reproduce_igual` y `test_accion_ida_y_vuelta`.
  12. Consultas = validar = aplicar: `test_consultas_igual_que_validar_y_aplicar` y `test_consulta_de_guardar_igual_que_validar`.
  13. `datos/` real: `test_invocar_a.gd`; pasan el permanente, `test_contacto`, `test_robustez_ia`, `test_metricas_escenarios`, `test_sellar_a` y `test_lanzadera_b`.
  14. Pantalla: `test_lectura_guardar_invocar.gd` y `test_vista_guardar_invocar.gd` (mouse por `MousePrueba`, D-012).
  15. Suite completa: 712 tests, todos pasan.
- **Consola:** sin errores ni advertencias nuevas. Los `ERROR: ReglasCombate: falta la regla …` son los que provocan a propósito `test_reglas_combate.gd` (ahora también `costos_mana`, porque recorre `REGLAS`), `test_sellado.gd` y el test de hechizos, y los dos del `Remote Debugger` son del arranque del runner.
- **Supuestos y lecturas técnicas:**
  - En A, el turno siguiente del Maestro después de que la Rodauva se guarda es de la ronda 1 (Velocidad 6 > 5). `Arquitectura.md` B.4 dice "en la ronda siguiente" y el prompt "en su turno siguiente": el test invoca en la ronda 1 (S-56) y comprueba que la Rodauva juega en la 2.
  - `test_erizada_pierde_la_marca` pone la marca a mano: hoy ninguna regla deja a una criatura erizada al guardarse (el inicio de su turno la borra). Cubre el efecto que T27 va a reusar.
  - Si el contexto no tiene `tablas/costos_mana.json`, la regla que falta se informa como `sellado` (va antes en `REGLAS` y también depende de los costos).
  - `test_hover_avisa_destapar` oculta y mueve al Surcón salvaje a mano para tener una oculta junto a la casilla: prueba que la pantalla muestra lo que dice `previsualizar_invocar`.
- **Lecturas declaradas:** S-53 (invocar solo con el turno sin usar), S-54 (guardar: puede moverse antes, termina el turno, no la enconada ni la distraída, sí la acobardada), S-55 (qué conserva la guardada) y S-56 (guardar e invocar en la misma ronda), todas en `Arquitectura.md` 10.5.
- **Claves de texto nuevas sin texto:** `aviso.invocar.ya_se_movio`, `aviso.invocar.accion_usada`, `aviso.invocar.mana_insuficiente` y `aviso.invocar.sin_casilla_libre` (tooltip del botón de invocar deshabilitado; se ve `[FALTA: …]`). Las demás (`accion.guardar`, `accion.invocar`, `guardar`, `guardar.tooltip`, `invocar`, `invocar.tooltip`) ya están en `es.json`.
- **Preguntas:** ninguna nueva; ninguna cerrada.
- **Prueba manual (Windows):**
  1. Suite completa, en verde (unos 15 minutos):
     - `cmd`: `addons\gdUnit4\runtest.cmd -a res://pruebas`
     - PowerShell: `& .\addons\gdUnit4\runtest.cmd -a res://pruebas`
  2. Abrir el juego: F5 en el editor, o `"%GODOT_BIN%" --path .` (`cmd`) / `& $env:GODOT_BIN --path .` (PowerShell). Elegir A.
  3. En el turno de la Rodauva (empieza al este del Maestro) aparece el botón Guardar. Si se mueve a una casilla en diagonal del Maestro, el botón desaparece. Apretarlo: la Rodauva sale del tablero y el suceso dice el texto de `guardar`.
  4. En el turno siguiente del Maestro, sin moverlo: aparece el botón para invocar a la Rodauva con su costo (2 Maná). Apretarlo: se marcan solo las casillas libres a los lados del Maestro. Clic en una: la Rodauva aparece ahí, el maná baja 2 y el suceso dice el texto de `invocar`.
  5. Mirar la cola: la Rodauva no juega en esa ronda y sí en la siguiente.
  6. Mover al Maestro antes de invocar: el botón de invocar queda deshabilitado, con `[FALTA: aviso.invocar.ya_se_movio]` en el tooltip.
  7. En E, cavar con el Surcón en un turno y, en su turno siguiente, guardarlo (empieza al lado del Maestro): sus surcos desaparecen.
  8. Al terminar A con la Rodauva invocada, en la pantalla de resultado recibe el +1 de victoria.
  9. Anotar los `[FALTA]` que aparezcan.
- **Para la próxima sesión:** nada: tarea terminada.

## T27 · sesión 1 · 12/10/2026
- **Rama:** tarea/T27-guardar-caida
- **Estado:** TERMINADA (pendiente de PR)
- **Hecho:** el Maestro guarda a una caída de su tribu a distancia Manhattan ≤ 2 (`Sistema.md` 11.5, 3.1, 2.3). Paga el costo de la fila propia, gasta su acción y conserva el movimiento. La caída queda guardada, sin posición, con su pergamino y la vida del dato nuevo; sus surcos se cierran. Lo que pasa después (hambre de combate, +1 de victoria, sobrevivir a la derrota, invocarla) sale del código que ya había para las guardadas. Detalle:
  - **Deuda de T26:** `ReglasCombate.REGLAS` pone las reglas que otras usan antes que ellas (`costos_mana` antes que `sellado` y `guardado_caida`). Sin `costos_mana.json`, el rechazo nombra `costos_mana`.
  - **Dato nuevo:** `vida_al_guardar_caida` en `tablas/combate.json`, con esquema, datos y los seis `combate*.json` de fixtures (en 1, D-009). La huella cambió. La `description` de `vida_tras_caida` ya no dice "y al ser guardada caída".
  - **Regla `GuardadoCaida`** (en `ReglasCombate` y `ContextoCombate`): costo (delega en `CostosMana.guardar_caida`), alcance y vida.
  - **Objetivo:** clase `Objetivos.Clase.CAIDA_PROPIA` (P-025) y motivo nuevo `OBJETIVO_NO_CAIDO`. `ALIADA` no cambió.
  - **Acción:** `Accion.guardar_caida(objetivo)`, con un solo chequeo (`Turno._motivo_guardar_caida`) en el orden del prompt. `ResultadoAccion.vida` (`{de, a}`).
  - **Consultas:** `objetivos_para_guardar_caida`, `motivo_guardar_caida` (el motivo más avanzado entre las caídas de la tribu), `previsualizar_guardar_caida` y `Combate.costo_guardar_caida`.
  - **Registro:** `accion` → `mana` (`guardar_caida`) → `estado` → `guardado_caida` (`unidad`, `vida`) → `surco_cerrado`.
  - **Grabación:** tipo `guardar_caida`.
  - **Métrica 10:** `caidas_guardadas` = `[{unidad, ronda}]` (esquema `resultado`).
  - **Pantalla:** botón con costo y motivo, modo "elegir caída" excluyente con los demás, hover con maná y vida, clic y sucesos.
- **Archivos:**
  - Creados:
    - `nucleo/combate/guardado_caida.gd`;
    - `pruebas/fixtures/combate/escenario_guardar_caida.json`, `escenario_guardar_caida_combate.json` y `costos_mana_guardar_caida.json`;
    - tests `pruebas/combate/test_guardar_caida.gd`, `test_guardado_caida.gd`, `test_guardar_caida_combate.gd`, `pruebas/pantalla/test_lectura_guardar_caida.gd`, `test_vista_guardar_caida.gd` y `pruebas/datos/test_guardar_caida_a.gd`.
  - Modificados:
    - núcleo: `nucleo/combate/costos_mana.gd`, `reglas_combate.gd`, `contexto_combate.gd`, `objetivos.gd`, `accion.gd`, `resultado_accion.gd`, `turno.gd`, `combate.gd` y `metricas_combate.gd`;
    - pantalla: `pantalla/claves_textos.gd`, `pantalla/combate/lectura_combate.gd`, `interprete_clic.gd` y `vista_combate.gd`;
    - datos: `datos/_esquemas/combate.schema.json`, `grabacion.schema.json` y `resultado.schema.json`, y `datos/tablas/combate.json`;
    - fixtures y ayudantes: los seis `pruebas/fixtures/combate/combate*.json` (el campo nuevo es requerido por el esquema) y `pruebas/combate/datos_fixture.gd`;
    - tests: `test_reglas_combate.gd`, `test_costos_mana.gd` y `test_metricas_combate.gd`;
    - documentación: `docs/PREGUNTAS.md`, `docs/RESUMENES.md` y `CLAUDE.md`.
- **Tabla de cotejo (A.2.2):**

| Dato | `Sistema.md` | `datos/` | fixture |
|---|---|---|---|
| `tablas/combate.json` `vida_al_guardar_caida` | 10 (11.5; 11.1 v1.7) | 10 | 1 (D-009) |
| `tablas/combate.json` `alcance_guardar_caida` | ≤ 2 (11.5) | 2 | 2 |
| `tablas/costos_mana.json` `guardar_caida` | 2 / 3 / 4 (2.3) | [2, 3, 4] | [2, 3, 4] (y [1, 4, 6], inventado, en `costos_mana_guardar_caida.json`) |
| `tablas/costos_mana.json` `costo_minimo` | 1 (2.3) | 1 | 1 |

- **Tests:** 36 nuevos, total 748, todos pasan.
  - Nuevos por archivo: `test_guardar_caida.gd` (16), `test_guardado_caida.gd` (2), `test_guardar_caida_combate.gd` (6), `test_guardar_caida_a.gd` (2), `test_lectura_guardar_caida.gd` (4) y `test_vista_guardar_caida.gd` (3).
  - Uno más en cada uno de `test_costos_mana.gd`, `test_metricas_combate.gd` y `test_reglas_combate.gd`.
- **Tests viejos reescritos:** ninguna aserción vieja cambió de valor.
  - `test_metricas_combate.gd::test_metricas_9_y_11`: `caidas_guardadas` pasa de `null` a lista vacía (D-011: la métrica 10 la llena T27).
  - `test_reglas_combate.gd::_armar`: el constructor de `ReglasCombate` suma `guardado_caida` (D-008).
  - `test_costos_mana.gd::test_sin_un_dato_no_se_arma`: suma el caso sin `guardar_caida`, que `CostosMana.desde_datos` ahora exige.
- **Criterio de terminado:** cumplido.
  1. Datos:
     - `test_guardado_caida.gd`: el fixture carga y un `combate.json` sin el campo no valida;
     - `test_guardar_caida_a.gd::test_el_dato_carga_en_datos`;
     - pasa el permanente de datos. La tabla de cotejo está arriba.
  2. Deuda de T26: `test_reglas_combate.gd::test_contexto_sin_costos_mana_nombra_costos_mana`.
  3. `CAIDA_PROPIA` y `ALIADA` (el Remiendo no cura a la caída): `test_clase_caida_propia` y `test_aliada_sigue_rechazando_a_la_caida`.
  4. Costo con la balanza 2, 3 y 5 y el mínimo, desde la fila propia: `test_costos_mana.gd::test_guardar_caida_por_rango_con_balanza_2_3_y_5`.
  5. Distancia 1 y 2, por encima de una enemiga, y el Maestro se mueve después: `test_guardar_a_distancia_1_y_2`, `test_guardar_por_encima_de_una_enemiga` y `test_previsualizar_es_lo_que_aplica`.
  6. Rechazos sin cambios (distancia 3, de pie, atacante nocturna caída, acción usada, sin maná y una criatura) y el motivo más avanzado: `test_guardar_caida.gd`.
  7. Surcón caído: `test_surcon_caido_cierra_sus_surcos`.
  8. Supervivencia:
     - con turnos sueltos: `test_la_guardada_no_suma_hambre_de_combate`, `test_la_guardada_sobrevive_si_cae_el_maestro` y `test_en_una_victoria_no_recibe_el_mas_uno`;
     - dentro del `Combate`: `test_derrota_metrica_10_y_resultado`.
  9. S-58: `test_se_invoca_despues_con_esa_vida`.
  10. Registro, grabación y consultas = validar = aplicar: `test_registro_en_el_orden_de_a7`, `test_grabacion_se_reproduce_igual`, `test_accion_ida_y_vuelta` y `test_consultas_son_validar_y_aplicar`.
      - En el registro, el `surco_cerrado` va detrás del `guardado_caida` porque lo vuelca el `_registrar_surcos` de siempre.
      - Que se cierren los surcos se prueba con turnos sueltos (criterio 7). No hay test de combate con un Surcón: el escenario de combate no tiene uno.
  11. Métrica 10:
      - `test_metricas_combate.gd::test_metrica_10_caidas_guardadas`;
      - en el combate, `test_derrota_metrica_10_y_resultado`: el resultado valida contra el esquema.
  12. `datos/` real, A: `test_guardar_caida_a.gd::test_a_el_maestro_guarda_a_la_rodauva_caida`. Pasan el permanente, `test_contacto`, `test_robustez_ia`, `test_metricas_escenarios`, `test_sellar_a`, `test_lanzadera_b` y `test_invocar_a`.
  13. Pantalla: `test_lectura_guardar_caida.gd` y `test_vista_guardar_caida.gd` (mouse por `MousePrueba`, D-012).
  14. Suite completa: 748 tests, todos pasan.
- **Consola:** sin errores ni advertencias nuevas. Los `ERROR: ReglasCombate: falta la regla …` los provocan a propósito los tests de reglas faltantes (ahora también `guardado_caida` y `costos_mana` desde el contexto).
- **Supuestos y lecturas técnicas:**
  - `Objetivos.motivo(Maestro.ID, CAIDA_PROPIA)` da `OBJETIVO_NO_CAIDO`. El Maestro no es una caída que se guarde: su caída termina el combate (11.5).
  - `motivo_guardar_caida` recorre solo a las caídas de la tribu; sin ninguna, da `SIN_OBJETIVOS`. Así el botón no dice "objetivo enemigo" por la atacante nocturna caída. La acción sí la rechaza con `OBJETIVO_ENEMIGO`.
  - El test de A acerca al Maestro a la caída con `casillas_para_mover` solo si no la tiene a su alcance. No toca coordenadas.
- **Lecturas declaradas:**
  - S-55: qué conserva la guardada (se reusa `_dejar_guardada`).
  - S-57: distancia Manhattan, sin mirar la línea; vale por encima de una enemiga.
  - S-58: se invoca en el mismo combate, pagando invocar, con esa vida.
- **Claves de texto nuevas sin texto:** `aviso.guardar_caida.accion_usada`, `aviso.guardar_caida.fuera_de_alcance`, `aviso.guardar_caida.mana_insuficiente` y `aviso.guardar_caida.sin_objetivos`. Van en el tooltip del botón deshabilitado y son pedido de `Mundo.md` 9. Las del botón, su tooltip y el suceso (`accion.guardar_caida`, `guardar_caida.tooltip` y `guardar_caida`) ya están en `es.json`.
- **Preguntas:** ninguna nueva. Cerrada P-025 (clase `CAIDA_PROPIA`).
- **Prueba manual (Windows):**
  1. Suite completa, en verde (unos 15 minutos):
     - `cmd`: `addons\gdUnit4\runtest.cmd -a res://pruebas`
     - PowerShell: `& .\addons\gdUnit4\runtest.cmd -a res://pruebas`
  2. Abrir el juego: F5 en el editor, o `"%GODOT_BIN%" --path .` (`cmd`) / `& $env:GODOT_BIN --path .` (PowerShell). Elegir A y apretar Terminar con la Rodauva hasta que la Ocarra la tumbe.
  3. En el turno del Maestro aparece "Guardar a la caída (2 Maná)". Si la caída está a 3 o más casillas, el botón está deshabilitado, con `[FALTA: aviso.guardar_caida.fuera_de_alcance]` en el tooltip. Al mover al Maestro más cerca, el botón se habilita.
  4. Apretarlo: se marca la Rodauva caída. Con el mouse encima, el panel muestra "Maná: x → x−2" y "Vida: 0 → 10".
  5. Clic: la Rodauva sale del tablero, el maná baja 2 y el suceso dice "Tendés el pergamino hacia la Rodauva…". El Maestro todavía se puede mover.
  6. Seguir con Terminar hasta que la Ocarra tumbe al Maestro: en la pantalla de resultado, la Rodauva sigue guardada, no muerta.
  7. Otra vez A: guardarla y, en el turno siguiente del Maestro, invocarla. Aparece con 10 de vida.
  8. Anotar los `[FALTA]` que aparezcan.
- **Para la próxima sesión:** nada: tarea terminada.
