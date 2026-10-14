extends GdUnitTestSuite

# Arquitectura.md B.4 (T30, sesion 3), criterio 15: lo que LecturaCombate arma
# para el ataque nocturno: el golpe inicial (nocturno.base y su complemento), la
# caida de la atacante, los botones del destino (con costo, % y motivo, desde
# Combate.motivo_destino y la regla DestinoAtacante), las lineas de Mundo.md 4.6
# de cada salida y la pantalla de resultado. Fixtures (A.6):
# escenario_nocturno_combate.json (MesaNocturno), escenario_destino_combate.json
# (MesaDestino: Ocarra rango 1, resellar cuesta 2 y tira con 80; semilla 1 sale,
# 26 falla), es_rasgos.json y textos de prueba de las claves nocturno.*.
# Sistema.md 9.2, 9.3 y 4.4.
const _TEXTOS: String = "res://pruebas/fixtures/pantalla/es_rasgos.json"
const _TEXTOS_PRUEBA: Dictionary = {
	"nocturno.base": "Despiertas: {criatura} encima.",
	"nocturno.base.ocarra": "No grazna.",
	"nocturno.atacante.caida": "{criatura} cae y espera.",
	"nocturno.boton.perdonar": "Perdonar",
	"nocturno.boton.sellar": "Sellar de nuevo",
	"nocturno.boton.comer": "Comer",
	"nocturno.perdonar": "Perdonas a {criatura}.",
	"nocturno.perdonar.tribu": "La tribu duerme cerca.",
	"nocturno.perdonar.tooltip": "Se va libre.",
	"nocturno.sellar": "El hilo recoge a {criatura}.",
	"nocturno.sellar.tooltip": "Vuelve sin confianza.",
	"nocturno.comer": "Comes.",
	"nocturno.comer.tooltip": "Te da de comer.",
	"nocturno.comer.zancajunco_suelto": "El Zancajunco come con vos.",
	"pergamino.sin_blanco": "Sin pergamino.",
	"aviso.sellar.mana_insuficiente": "Sin mana.",
	"sellar.fallo": "El hilo se suelta.",
	"panel.mana": "Maná",
	"resultado.atacante_pendiente": "Atacante caída",
	"resultado.lealtad": "Lealtad",
}

var _combate: Combate


func _armador(contexto: ContextoCombate) -> ArmadorTextos:
	var textos: Dictionary = LectorFixture.leer(_TEXTOS, "textos")["datos"]
	textos.merge(_TEXTOS_PRUEBA, true)
	return ArmadorTextos.desde_datos(textos, contexto.azar_textos)


func _lectura(combate_jugado: Combate) -> LecturaCombate:
	_combate = combate_jugado
	assert_str(_combate.error()).is_empty()
	var datos: Dictionary = DatosFixture.cargar()["datos"]
	return LecturaCombate.new(_combate, _armador(_combate.contexto()),
			EstadosUnidad.desde_datos(datos["tablas/hambre.json"], datos["tablas/lealtad.json"]))


# La atacante en 0: victoria sin rondas y su destino pendiente.
func _lectura_destino(escenario: Dictionary = {}, mana: int = -1) -> LecturaCombate:
	var lectura: LecturaCombate = _lectura(MesaDestino.combate(escenario, mana))
	assert_bool(_combate.esperando_destino()).is_true()
	return lectura


func _ultimo(tipo: String) -> Dictionary:
	var encontrado: Dictionary = {}
	for linea in _combate.registro().lineas():
		if linea["tipo"] == tipo:
			encontrado = linea
	return encontrado


func _opciones(botones: Array[Dictionary]) -> Array:
	return botones.map(func(boton: Dictionary) -> String: return boton["opcion"])


func _boton(botones: Array[Dictionary], opcion: String) -> Dictionary:
	for boton in botones:
		if boton["opcion"] == opcion:
			return boton
	return {}


# (15) El golpe inicial: la base con la atacante como hueco, la linea de su
# especie (complemento, A.2.1) y el danio con la vida del Maestro de -> a.
func test_suceso_golpe_inicial() -> void:
	var lectura: LecturaCombate = _lectura(MesaNocturno.combate(MesaNocturno.escenario()))
	var golpe: Dictionary = _ultimo("golpe_inicial")
	assert_dict(golpe).is_not_empty()
	var lineas: Array[String] = lectura.suceso(golpe)
	assert_int(lineas.size()).is_equal(3)
	assert_str(lineas[0]).is_equal("Despiertas: la Ocarra encima.")
	assert_str(lineas[1]).is_equal("No grazna.")
	assert_str(lineas[2]).contains("−%d (%d → %d)" % [golpe["desglose"]["total"], golpe["vida_antes"],
			golpe["vida_despues"]])


# (15) Al caer la atacante, nocturno.atacante.caida en lugar de caida y su
# complemento. Una caida de la tribu sigue con caida.
func test_suceso_caida_de_la_atacante() -> void:
	var lectura: LecturaCombate = _lectura_destino()
	var lineas: Array[String] = lectura.suceso({"tipo": "estado", "unidad": MesaDestino.ATACANTE, "a": "caida"})
	assert_array(lineas).is_equal(["La Ocarra cae y espera."] as Array[String])
	var de_la_tribu: Array[String] = lectura.suceso({"tipo": "estado", "unidad": MesaDestino.LEAL, "a": "caida"})
	assert_array(de_la_tribu).is_equal(["[FALTA: caida]"] as Array[String])


# (15) Con el destino pendiente, tres botones en el orden de DestinoAtacante.OPCIONES,
# con su texto y su tooltip; sellar lleva el costo y el % de la regla.
func test_botones_destino() -> void:
	var lectura: LecturaCombate = _lectura_destino()
	var botones: Array[Dictionary] = lectura.botones_destino()
	assert_array(_opciones(botones)).is_equal(DestinoAtacante.OPCIONES)
	for boton in botones:
		assert_bool(boton["habilitado"]).is_true()
	assert_str(_boton(botones, "perdonar")["texto"]).is_equal("Perdonar")
	assert_str(_boton(botones, "perdonar")["tooltip"]).is_equal("Se va libre.")
	assert_str(_boton(botones, "comer")["tooltip"]).is_equal("Te da de comer.")
	var regla: DestinoAtacante = _combate.contexto().destino_atacante
	var plantel: Plantel = _combate.contexto().plantel
	var especie: Especie = plantel.criatura(MesaDestino.ATACANTE).especie
	assert_str(_boton(botones, "sellar")["texto"]).is_equal("Sellar de nuevo (%d Maná · %d%%)" % [
			regla.costo(especie, plantel.maestro), regla.porcentaje(especie)])
	assert_str(_boton(botones, "sellar")["tooltip"]).is_equal("Vuelve sin confianza.")


func test_sin_destino_no_hay_botones() -> void:
	var lectura: LecturaCombate = _lectura(MesaDestino.combate(MesaDestino.escenario(false)))
	assert_bool(_combate.esperando_destino()).is_false()
	assert_array(lectura.botones_destino()).is_empty()


# (15) Sellar sin pergamino en blanco o sin mana: deshabilitado, con el motivo en
# el tooltip (pergamino.sin_blanco, aviso.sellar.mana_insuficiente).
func test_sellar_sin_pergamino_o_sin_mana() -> void:
	var sin_pergamino: Dictionary = MesaDestino.escenario()
	sin_pergamino["pergaminos_en_blanco"] = 0
	var boton: Dictionary = _boton(_lectura_destino(sin_pergamino).botones_destino(), "sellar")
	assert_bool(boton["habilitado"]).is_false()
	assert_str(boton["tooltip"]).is_equal("Vuelve sin confianza.\nSin pergamino.")

	boton = _boton(_lectura_destino({}, 1).botones_destino(), "sellar")
	assert_bool(boton["habilitado"]).is_false()
	assert_str(boton["tooltip"]).is_equal("Vuelve sin confianza.\nSin mana.")


# (15) Sistema.md 4.4: tras un fallo de sellar quedan solo perdonar y comer.
func test_tras_un_fallo_quedan_perdonar_y_comer() -> void:
	var escenario: Dictionary = MesaDestino.escenario()
	escenario["semilla"] = MesaDestino.SEMILLA_FALLA
	var lectura: LecturaCombate = _lectura_destino(escenario)
	assert_bool(_combate.aplicar(Accion.destino_atacante("sellar")).valida).is_true()
	assert_bool(_combate.esperando_destino()).is_true()
	assert_array(_opciones(lectura.botones_destino())).is_equal(["perdonar", "comer"])
	assert_array(lectura.suceso(_ultimo("destino_atacante"))).is_equal(["El hilo se suelta."] as Array[String])


# (15) Mundo.md 4.6: las lineas de cada salida, como sucesos del destino_atacante.
func test_lineas_de_cada_salida() -> void:
	var lectura: LecturaCombate = _lectura_destino()
	assert_bool(_combate.aplicar(Accion.destino_atacante("perdonar")).valida).is_true()
	assert_array(lectura.suceso(_ultimo("destino_atacante"))).is_equal(
			["Perdonas a la Ocarra.", "La tribu duerme cerca."] as Array[String])

	lectura = _lectura_destino()
	assert_bool(_combate.aplicar(Accion.destino_atacante("sellar")).valida).is_true()
	assert_array(lectura.suceso(_ultimo("destino_atacante"))).is_equal(["El hilo recoge a la Ocarra."] as Array[String])

	# Con el Zancajunco suelto, su linea (la clave la elige la especie de la suelta).
	lectura = _lectura_destino()
	assert_bool(_combate.aplicar(Accion.destino_atacante("comer")).valida).is_true()
	assert_array(lectura.suceso(_ultimo("destino_atacante"))).is_equal(
			["Comes.", "El Zancajunco come con vos."] as Array[String])

	# Sin el Zancajunco suelto (guardado), sin esa linea.
	var sin_zancajunco: Dictionary = MesaDestino.escenario()
	for criatura: Dictionary in sin_zancajunco["tribu"]:
		if criatura["id"] == MesaDestino.DE_DIEZ:
			criatura["estado"] = "guardada"
			criatura["posicion"] = null
	lectura = _lectura_destino(sin_zancajunco)
	assert_bool(_combate.aplicar(Accion.destino_atacante("comer")).valida).is_true()
	assert_array(lectura.suceso(_ultimo("destino_atacante"))).is_equal(["Comes."] as Array[String])


# (15) La pantalla de resultado: pendiente, con la linea de la atacante caida;
# despues de elegir, las lineas del destino y la lealtad final de la noche.
func test_resultado_pendiente_y_final() -> void:
	var lectura: LecturaCombate = _lectura_destino()
	var pendiente: Array[String] = lectura.resultado(_combate.resultado().a_diccionario())
	assert_array(pendiente).contains(["La Ocarra cae y espera."])
	assert_array(pendiente).not_contains(["Perdonas a la Ocarra."])

	assert_bool(_combate.aplicar(Accion.destino_atacante("perdonar")).valida).is_true()
	var final: Array[String] = lectura.resultado(_combate.resultado().a_diccionario())
	assert_array(final).not_contains(["La Ocarra cae y espera."])
	var perdon: int = final.find("Perdonas a la Ocarra.")
	var lealtad: int = final.find("Lealtad")
	assert_int(perdon).is_greater(-1)
	assert_int(lealtad).is_greater(perdon)
	# rodauva_1, leal de 8: +1 de la victoria y +1 del perdon (Sistema.md 9.3 y 5.2).
	assert_array(final).contains(["Rodauva: 8 → 10"])
