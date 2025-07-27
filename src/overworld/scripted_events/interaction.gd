@tool
@icon("icon_interaction.png")
class_name Interaction extends Area2D

@export var event: ScriptedEvent:
	set(value):
		if not is_inside_tree():
			await ready
		
		event = value
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var msg: = []
	if event == null:
		msg.append("The interaction must have a ScriptedEvent set!")
	return msg


func run() -> void:
	if event != null and not ScriptedEvent.is_cutscene_in_progress():
		event.run()
