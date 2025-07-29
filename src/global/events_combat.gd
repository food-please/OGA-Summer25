extends CanvasLayer

## Emitted whenever the combat initation sequence has begun (start() has been called).
signal started()

## Emitted after combat has finished and the screen has faded.
signal finished

var _active_arena: CombatArena = null


func _ready() -> void:
	# The combat state will be added directly over the Overworld, so it needs to render on top (yet
	# below the ScreenFade).
	get_parent().move_child.call_deferred(self, get_parent().get_child_count()-1)


## Begin a combat. Takes a PackedScene as its only parameter, expecting it to be a CombatState object once
## instantiated.
## This is normally a response to [signal FieldEvents.combat_triggered].
func start(arena: PackedScene) -> void:
	assert(_active_arena == null, "Attempting to start a combat while one is ongoing!")
	
	var new_arena: = arena.instantiate()
	assert(
		new_arena != null,
		"Failed to initiate combat. Provided 'arena' arugment is not a CombatArena."
	)
	_active_arena = new_arena
	
	started.emit()
	await ScreenCover.cover(0.2)
	
	
	add_child(_active_arena)
	
	_active_arena.camera.make_current()
	await ScreenCover.clear(0.2)


func finish() -> void:
	assert(_active_arena != null, "Attempting to end the combat but there's no active CombatArena!")
	
	await ScreenCover.cover(0.2)
	
	_active_arena.queue_free()
	_active_arena = null
	finished.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		finish()


func is_combat_in_progress() -> bool:
	return not (_active_arena == null)
