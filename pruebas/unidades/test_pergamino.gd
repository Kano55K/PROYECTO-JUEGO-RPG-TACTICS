extends GdUnitTestSuite

# Arquitectura.md B.2 (T05, criterio 6): un pergamino ocupado no se vuelve a
# ocupar y uno ardido no se usa. Sistema.md 3.2.


func test_ocupado_no_se_reocupa() -> void:
	var pergamino: Pergamino = Pergamino.new("pergamino_1")
	assert_int(pergamino.estado).is_equal(Pergamino.Estado.EN_BLANCO)
	assert_bool(pergamino.ocupar("rodauva_1")).is_true()
	assert_int(pergamino.estado).is_equal(Pergamino.Estado.OCUPADO)
	assert_str(pergamino.ocupante_id).is_equal("rodauva_1")

	assert_bool(pergamino.ocupar("ocarra_1")).is_false()
	assert_int(pergamino.estado).is_equal(Pergamino.Estado.OCUPADO)
	assert_str(pergamino.ocupante_id).is_equal("rodauva_1")


func test_ardido_no_se_usa() -> void:
	var pergamino: Pergamino = Pergamino.new("pergamino_1")
	pergamino.ocupar("rodauva_1")
	assert_bool(pergamino.arder()).is_true()
	assert_int(pergamino.estado).is_equal(Pergamino.Estado.ARDIDO)
	assert_str(pergamino.ocupante_id).is_empty()

	assert_bool(pergamino.ocupar("ocarra_1")).is_false()
	assert_bool(pergamino.arder()).is_false()
	assert_int(pergamino.estado).is_equal(Pergamino.Estado.ARDIDO)
	assert_str(pergamino.ocupante_id).is_empty()


# Sistema.md 3.2: solo arde un vinculo roto, y uno en blanco no tiene vinculo.
func test_en_blanco_no_arde() -> void:
	var pergamino: Pergamino = Pergamino.new("pergamino_1")
	assert_bool(pergamino.arder()).is_false()
	assert_int(pergamino.estado).is_equal(Pergamino.Estado.EN_BLANCO)
