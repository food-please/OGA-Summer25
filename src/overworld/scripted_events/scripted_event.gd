@icon("icon_scripted_event.png")
class_name ScriptedEvent extends Node2D


## Execute the cutscene, if possible. Everything happening on the field gamestate will be
## paused and unpaused as the cutscene starts and finishes, respectively.
func run() -> void:
	OverworldEvents.scripted_event_began.emit(self)
	
	# The _execute method may or may not be asynchronous, depending on the particular cutscene.
	@warning_ignore("redundant_await")
	await _execute()
	
	OverworldEvents.scripted_event_finished.emit(self)


## Play out the specific events of the cutscene.
## This method is intended to be overridden by derived cutscene types.
## [br][br]May or may not be asynchronous.
func _execute() -> void:
	pass
