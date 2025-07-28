@icon("icon_scripted_event.png")
class_name ScriptedEvent extends Node2D

# Indicates if a cutscene is currently running. [b]This member should not be set externally[/b].
static var _is_cutscene_in_progress: = false:
	set(value):
		if _is_cutscene_in_progress != value:
			_is_cutscene_in_progress = value
			
			OverworldEvents.is_paused = value
			#OverworldEvents.gameplay_paused.emit(value)


## Returns true if a cutscene is currently running.
static func is_cutscene_in_progress() -> bool:
	return _is_cutscene_in_progress


## Execute the cutscene, if possible. Everything happening on the field gamestate will be
## paused and unpaused as the cutscene starts and finishes, respectively.
func run() -> void:
	_is_cutscene_in_progress = true
	
	# The _execute method may or may not be asynchronous, depending on the particular cutscene.
	@warning_ignore("redundant_await")
	await _execute()
	
	_is_cutscene_in_progress = false


## Play out the specific events of the cutscene.
## This method is intended to be overridden by derived cutscene types.
## [br][br]May or may not be asynchronous.
func _execute() -> void:
	pass
