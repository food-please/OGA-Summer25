@icon("icon_turn_queue.png")
class_name CombatTurnQueue extends Node

signal players_defeated
signal enemies_defeated


func start() -> void:
	_next_turn.call_deferred()
	
	await  get_tree().create_timer(5.0).timeout
	$Kangaroo.queue_free()


func get_actors() -> Array[Actor]:
	var actors: Array[Actor] = []
	actors.assign(get_tree().get_nodes_in_group(Actor.GROUP))
	
	actors.sort_custom(_sort_actors)
	return actors


func get_player_battlers() -> Array[Actor]:
	return get_actors().filter(
		func _filter_players(actor: Actor):
			return actor.is_player
	)


func get_enemy_battlers() -> Array[Actor]:
	return get_actors().filter(
		func _filter_players(actor: Actor):
			return not actor.is_player
	)


func get_next_actor() -> Actor:
	var actors: = get_actors().filter(
		func _filter_acted_battlers(actor: Actor) -> bool: return not actor.has_acted_this_turn
	)
	if actors.is_empty():
		return null
	
	return actors.front()


func _sort_actors(a: Actor, b: Actor) -> bool:
	return a.initiative >= b.initiative


func _next_turn() -> void:
	print("\nNext turn")
	
	# Check for battle end conditions, that one side has been downed.
	if _are_players_defeated():
		print("Players lost")
		players_defeated.emit.call_deferred()
		return
	elif _are_enemies_defeated():
		print("Enemies lost")
		enemies_defeated.emit.call_deferred()
		return
	
	var actors: = get_actors()

	# Check for an active actor. If there are none, it may be that the turn has finished and all
	# actors can have their has_acted_this_turn flag reset.
	var next_actor = get_next_actor()
	if not next_actor:
		for actor in actors:
			actor.has_acted_this_turn = false
		
		# If there is no actor now, there is some kind of problem, since this scenario should have
		# been caught by the checks to see which sides are defeated.
		next_actor = get_next_actor()
		if not next_actor:
			players_defeated.emit()
			return
	
	# Connect to the actor's turn_finished signal. The actor is guaranteed to emit the signal, 
	# even if it will be freed at the end of this frame.
	# However, we'll call_defer the next turn, since the current actor may have been downed on its
	# turn and we need a frame to process the change.
	next_actor.turn_finished.connect(
		(func _on_actor_turn_finished(actor: Actor) -> void: 
				actor.has_acted_this_turn = true 
				_next_turn.call_deferred()).bind(next_actor),
			CONNECT_ONE_SHOT
	)
	next_actor.start_turn()


func _are_players_defeated() -> bool:
	for actor in get_player_battlers():
		if actor.is_active:
			return false
	
	return true


func _are_enemies_defeated() -> bool:
	for actor in get_enemy_battlers():
		if actor.is_active:
			return false
	
	return true


func _to_string() -> String:
	var actors: = get_actors()
	
	var msg: = "\n%s (CombatTurnQueue)" % name
	for actor in actors:
		msg += "\n\t" + actor.to_string()
	return msg
