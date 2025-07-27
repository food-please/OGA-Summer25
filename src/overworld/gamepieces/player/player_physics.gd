## Handles player physics, including player collisions (e.g. where is the camera) and interactions
## (e.g. what is in front of the player, right now?).
# Note that the interaction component is only applicable to keyboard/joypad input types.
class_name PlayerPhysics extends Node2D

const GROUP: = "_PlayerPhysicsObjects"

@onready var _interaction_area: Area2D = $InteractionArea
@onready var _player_collision_shape: CollisionShape2D = $PlayerArea/CollisionShape2D


func _ready() -> void:
	add_to_group(GROUP)
	set_process_unhandled_input(false)
	
	var parent: = get_parent() as Gamepiece
	assert(parent != null, "PlayerPhysics object must be the immediate child" +
		" of a Gamepiece object!")
	
	OverworldEvents.gameplay_paused.connect(
		func _on_gameplay_paused(is_paused: bool) -> void:
			if is_paused:
				print("Pause")
				set_process_unhandled_input(false)
			
	)
	
	parent.gfx.direction_changed.connect(
		func _on_direction_changed(new_dir: String) -> void:
			var offset_dir: Vector2 = Directions.MAPPINGS.get(new_dir, "S")
			_interaction_area.rotation = offset_dir.angle()
	)
	



## Arrange the player's collision shape to match that of the player character.
func setup(shape: Shape2D) -> void:
	if shape:
		var dup_shape: = shape.duplicate()
		_player_collision_shape.shape = dup_shape
