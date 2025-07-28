## Handles player physics, including player collisions (e.g. where is the camera) and interactions
## (e.g. what is in front of the player, right now?).
# Note that the interaction component is only applicable to keyboard/joypad input types.
class_name PlayerPhysics extends Node2D

const GROUP: = "_PlayerPhysicsObjects"

# Keep track of any interactions that have collided with the _interaction_area. 
var _interactions: Array[Interaction] = []

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
				set_process_unhandled_input(false)
			
			elif not _interactions.is_empty():
				set_process_unhandled_input.call_deferred(true)
	)
	
	parent.gfx.direction_changed.connect(
		func _on_direction_changed(new_dir: String) -> void:
			var offset_dir: Vector2 = Directions.MAPPINGS.get(new_dir, "S")
			_interaction_area.rotation = offset_dir.angle()
	)
	
	_interaction_area.area_entered.connect(
		func _on_area_entered(area: Area2D) -> void:
			if area is Interaction and not area in _interactions:
				_interactions.append(area)
				set_process_unhandled_input(true)
	)
	
	_interaction_area.area_exited.connect(
		func _on_area_exited(area: Area2D) -> void:
			if area in _interactions:
				_interactions.erase(area)
				if _interactions.is_empty():
					set_process_unhandled_input(false)
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		if not _interactions.is_empty():
			_interactions.back().run()


## Arrange the player's collision shape to match that of the player character.
func setup(shape: Shape2D) -> void:
	if shape:
		var dup_shape: = shape.duplicate()
		_player_collision_shape.shape = dup_shape
