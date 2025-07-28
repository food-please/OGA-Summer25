## Starts and ends combat, and manages the transition between the overworld and combat gamestates.
extends CanvasLayer

var _active_arena: CombatArena = null


#func _ready() -> void:
	#OverworldEvents.combat_requested.connect(start)





## Begin a combat. Takes a PackedScene as its only parameter, expecting it to be a CombatState object once
## instantiated.
## This is normally a response to [signal FieldEvents.combat_triggered].
func start(arena: PackedScene) -> void:
	assert(_active_arena == null, "Attempting to start a combat while one is ongoing!")

	await ScreenCover.cover(0.2)

	var new_arena: = arena.instantiate()
	assert(
		new_arena != null,
		"Failed to initiate combat. Provided 'arena' arugment is not a CombatArena."
	)
	
	_active_arena = new_arena
	add_child(_active_arena)
	
	_active_arena.camera.make_current()
	await ScreenCover.clear(0.2)
