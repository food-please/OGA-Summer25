@tool
class_name GamepieceController extends Node

@export var is_active: = false:
	set = set_is_active

var parent: Gamepiece = null:
	set(value):
		parent = value
		
		if not Engine.is_editor_hint():
			set_physics_process(parent != null)
			set_process_unhandled_input(parent != null)
		
		else:
			set_physics_process(false)
			set_process_unhandled_input(false)


func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
		set_process_unhandled_input(false)


func _get_configuration_warnings() -> PackedStringArray:
	var msg: = []
	if parent == null:
		msg.append("Must be the child of a Gamepiece node!")
	return msg


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		parent = get_parent() as Gamepiece
		update_configuration_warnings()


func set_is_active(value: bool) -> void:
	is_active = value
	
	if not Engine.is_editor_hint():
		if is_active:
			process_mode = Node.PROCESS_MODE_INHERIT
		else:
			process_mode = Node.PROCESS_MODE_DISABLED
