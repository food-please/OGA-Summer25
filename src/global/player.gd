extends Node

const PLAYER_PHYSICS_SCENE: = preload("res://src/overworld/gamepieces/player/player_physics.tscn")

signal gamepiece_changed(new_character: Gamepiece)


var gamepiece: Gamepiece = null:
	set(value):
		if gamepiece == value:
			return
		
		# Free up any player-oriented nodes that should only be present on the active gamepiece.
		if gamepiece:
			for controller in get_tree().get_nodes_in_group(PlayerController.GROUP):
				controller.queue_free()
			
			for physics_object in get_tree().get_nodes_in_group(PlayerPhysics.GROUP):
				physics_object.queue_free()
			
			_give_control_to_ai(gamepiece)
		
		gamepiece = value
		if gamepiece:
			# De-actviate other controllers on this gamepiece. The player controller will override
			# them.
			for controller: GamepieceController \
					in gamepiece.find_children("*", "GamepieceController"):
				controller.is_active = false
			
			_give_control_to_player(gamepiece)
		
		gamepiece_changed.emit(gamepiece)


func _give_control_to_player(gp: Gamepiece) -> void:
	gp.velocity = Vector2.ZERO
	
	var new_controller: = PlayerController.new()
	gamepiece.add_child(new_controller)
	new_controller.owner = gamepiece
	new_controller.name = "PlayerController"
	
	var new_physics_object: = PLAYER_PHYSICS_SCENE.instantiate()
	gamepiece.add_child(new_physics_object)
	new_physics_object.owner = gamepiece
	new_physics_object.setup(gamepiece.get_collision_shape())


# Activate any AI controllers currently on the gamepiece.
func _give_control_to_ai(gp: Gamepiece) -> void:
	gp.velocity = Vector2.ZERO
	
	# Activate any AI controllers currently on the gamepiece.
	for controller: GamepieceController in gp.find_children("*", "GamepieceController"):
		controller.is_active = true
