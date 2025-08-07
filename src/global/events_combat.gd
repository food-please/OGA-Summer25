extends CanvasLayer

## Emitted whenever the combat initation sequence has begun (start() has been called).
signal started()

## Emitted after combat has finished and the screen has faded.
signal finished(post_combat_event: ScriptedEvent)

var _active_arena: CombatArena = null


func _ready() -> void:
	# The combat state will be added directly over the Overworld, so it needs to render on top (yet
	# below the ScreenFade).
	get_parent().move_child.call_deferred(self, get_parent().get_child_count()-1)
	follow_viewport_enabled = true


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
	
	# Once the screen is covered, add the combat arena and hand logic over to the arena object.
	add_child(_active_arena)
	#_active_arena.turn_queue.players_defeated.connect(
		#func _on_players_defeated() -> void:
			#print("Players lost!!!!"),
		#CONNECT_ONE_SHOT
	#)
	#_active_arena.turn_queue.enemies_defeated.connect(
		#func _on_players_defeated() -> void:
			#print("Players won!!!!"),
		#CONNECT_ONE_SHOT
	#)
	
	_active_arena.screen_covered.connect(finish)
	
	_active_arena.start()


func finish() -> void:
	assert(_active_arena != null, "Attempting to end the combat but there's no active CombatArena!")
	
	_active_arena.queue_free()
	_active_arena = null
	
	# TODO: Pass along a post-combat ScriptedEvent here?
	finished.emit(null)


## Returns all battlers (active and inactive, downed or alive) currently engaged in combat.
## The list is sorted by [member BattlerStats.initiative].
func get_battlers() -> Array[Battler]:
	var battlers: Array[Battler] = []
	battlers.assign(get_tree().get_nodes_in_group(Battler.GROUP))
	
	return battlers


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("ui_cancel"):
		finish()


func is_combat_in_progress() -> bool:
	return not (_active_arena == null)
