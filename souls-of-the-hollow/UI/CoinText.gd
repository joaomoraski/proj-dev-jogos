class_name CoinText
extends Label


func _process(_delta):
	text = str(game_controller.player_coins)
