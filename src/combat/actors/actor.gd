@tool
@icon("icon_actor.png")
class_name Actor extends Node2D

signal turn_finished

@export var is_player: = false

var has_acted_this_turn: = false

@export var is_active: = false


func start_turn() -> void:
	print(get_parent().name, " starts their turn!")
	
	await get_tree().create_timer(1.5).timeout
	turn_finished.emit()


func melee_attack() -> void:
	print("Attack!")


func _to_string() -> String:
	var msg: = "%s (Actor)" % name
	if not is_active:
		msg += " - INACTIVE"
	elif has_acted_this_turn:
		msg += " - HAS ACTED"
	return msg
