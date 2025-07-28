extends Node

## Emitted whenever the gameplay should be paused (for example, during a cutscene or dialog).
## This generally means that controllers need to stop, changes to HP shouldn't happen, etc.
@warning_ignore("unused_signal")
signal gameplay_paused(pause: bool)

## Emitted whenever the player enters a new [Room].
@warning_ignore("unused_signal")
signal room_entered(room: Room)

var is_paused: = false:
	set(value):
		if value != is_paused:
			is_paused = value
			gameplay_paused.emit(is_paused)
