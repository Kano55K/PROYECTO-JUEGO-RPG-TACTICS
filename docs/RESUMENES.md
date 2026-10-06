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
