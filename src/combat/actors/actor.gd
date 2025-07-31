@icon("icon_actor.png")
class_name Actor extends Node2D

signal turn_finished

const GROUP: = "_GROUP_ACTORS"

## Determines the order in which actors will take their turn. Higher initative actors act first.
@export_range(0.0, 1.0, 0.01) var initiative: = 1.0

@export var is_player: = false

var has_acted_this_turn: = false

@export var is_active: = true


func _ready() -> void:
	add_to_group(GROUP)


func start_turn() -> void:
	print(get_parent().name, " starts their turn!")
	
	await get_tree().create_timer(1.5).timeout
	turn_finished.emit()


func _to_string() -> String:
	var msg: = "%s (Actor, initiative: %f)" % [name, initiative]
	if not is_active:
		msg += " - INACTIVE"
	elif has_acted_this_turn:
		msg += " - HAS ACTED"
	return msg
