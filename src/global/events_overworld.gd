extends Node

## Emitted whenever the game is attempting to begin a new combat instance.
#@warning_ignore("unused_signal")
#signal combat_requested(arena: CombatArena)
#signal combat_requested(party, enemy_party)

## Emitted whenever the gameplay should be paused (for example, during a cutscene or dialog).
## This generally means that controllers need to stop, changes to HP shouldn't happen, etc.
## Note that this signal should not be emitted manually.
@warning_ignore("unused_signal")
signal gameplay_paused(pause: bool)

## Emitted whenever the player enters a new [Room].
@warning_ignore("unused_signal")
signal room_entered(room: Room)

signal scripted_event_began(event: ScriptedEvent)
signal scripted_event_finished(event: ScriptedEvent)

var _event_pool: Array[ScriptedEvent] = []

var _is_paused: = false:
	set(value):
		print("Setting pause to ", value)
		# Note that the overworld may NOT be unpaused while combat is currently in progress.
		if CombatEvents.is_combat_in_progress():
			if value == false:
				push_warning("Attempting to unpause the overworld while combat is in progress." + 
					" OverworldEvents.is_paused will remain true.")
			value = true
		
		if value != _is_paused:
			_is_paused = value
			gameplay_paused.emit(_is_paused)

# Indicates if a cutscene is currently running. [b]This member should not be set externally[/b].
var _is_cutscene_in_progress: = false:
	set(value):
		if _is_cutscene_in_progress != value:
			_is_cutscene_in_progress = value
			_is_paused = _is_cutscene_in_progress


func _ready() -> void:
	# The combat state will be added directly over the Overworld, so it needs to render on top (yet
	# below the ScreenFade).
	CombatEvents.started.connect(
		func _on_combat_started() -> void: _is_paused = _should_overworld_be_paused())
	CombatEvents.finished.connect(
		func _on_combat_finished() -> void: _is_paused = _should_overworld_be_paused())
	
	scripted_event_began.connect(
		func _on_scripted_event_began(event: ScriptedEvent) -> void:
			if not event in _event_pool:
				_event_pool.append(event)
				_is_paused = _should_overworld_be_paused()
	)
	
	scripted_event_finished.connect(
		func _on_scripted_event_began(event: ScriptedEvent) -> void:
			_event_pool.erase(event)
			_is_paused = _should_overworld_be_paused()
	)


func is_paused() -> bool:
	return _is_paused


func _should_overworld_be_paused() -> bool:
	print("\nCheck")
	if CombatEvents.is_combat_in_progress():
		print("Coimbat happening")
		return true
	
	else:
		if not _event_pool.is_empty():
			print("Events in progress, ", _event_pool)
			return true
	
	print("Nuthin")
	return false
