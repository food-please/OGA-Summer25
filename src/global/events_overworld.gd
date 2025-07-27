extends Node

## Emitted whenever the gameplay should be paused (for example, during a cutscene or dialog).
## This generally means that controllers need to stop, changes to HP shouldn't happen, etc.
@warning_ignore("unused_signal")
signal gameplay_paused(pause: bool)

## Emitted whenever the player enters a new [Room].
@warning_ignore("unused_signal")
signal room_entered(room: Room)
