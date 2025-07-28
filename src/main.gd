extends Node2D

func _ready() -> void:
	OverworldEvents._is_paused = true
	Player.gamepiece = $Player
	ScreenCover.cover()
	await ScreenCover.clear(3.0)
	
	OverworldEvents._is_paused = false
