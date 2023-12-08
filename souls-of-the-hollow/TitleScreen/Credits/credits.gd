extends Node2D

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
	if Input.is_action_just_pressed("interact"):
		show_easter_eggs()

func show_easter_eggs():
	$MadrugadaCodando.set_deferred("visible", true)
	$ArteECodigo.position = Vector2(35,350)
	$ArteECodigo.text = "Arte & Código:
							João Vitor Moraski Lunkes / ChatGPT / Bard / Intellij AI Assistant"
	$MusicasEEfeitos.position = Vector2(35,431)
	$Agradecimentos.text = "Se você está lendo isso, provavelmente descobrir que era só apertar a tecla de interagir.
							Essa foto sou eu a um tempo atrás finalizando um trabalho da faculdade de madrugada.
							Me encontro no mesmo estado para finalizar este.
							Espero realmente que aproveite o jogo.
							Tenta zerar ele um milhão de vezes ai, acho que é possivel."
	
func _on_touch_screen_button_pressed():
	queue_free()
