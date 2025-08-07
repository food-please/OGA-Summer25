## Provide a number of utility functions useful for filtering a list of Battlers.
class_name BattlerFilter extends RefCounted


static func get_player_battlers(battlers: Array[Battler]) -> Array[Battler]:
	return battlers.filter(
		func _filter_players(battler: Battler):
			return battler.actor.is_player
	)


static func get_enemy_battlers(battlers: Array[Battler]) -> Array[Battler]:
	return battlers.filter(
		func _filter_enemies(battler: Battler):
			return not battler.actor.is_player
	)


static func get_active_battlers(battlers: Array[Battler]) -> Array[Battler]:
	return battlers.filter(func(battler: Battler) -> bool: return battler.actor.is_active)


static func get_live_battlers(battlers: Array[Battler]) -> Array[Battler]:
	return battlers.filter(func(battler: Battler): return battler.stats.health > 0)


## Sort a list of Battlers according to their [member BattlerStats.initiative].
static func sort_by_initiative(battlers: Array[Battler]) -> Array[Battler]:
	var list_copy: = battlers.duplicate()
	list_copy.sort_custom(_sort_battlers)
	
	return list_copy


## Returns the [Actor] with highest [member BattlerStats.initiative] that is active and has not
## yet taken its turn.
static func get_next_actor(battlers: Array[Battler]) -> Actor:
	var list_copy: = battlers.duplicate()
	list_copy.sort_custom(_sort_battlers)
	
	var ready_to_act_battlers: = get_active_battlers(list_copy).filter(
		func _filter_acted_battlers(battler: Battler) -> bool:
			return not battler.actor.has_acted_this_turn
	)
	if ready_to_act_battlers.is_empty():
		return null
	
	return ready_to_act_battlers.front().actor


static func are_players_defeated(battlers: Array[Battler]) -> bool:
	for battler in get_player_battlers(battlers):
		if battler.actor.is_active:
			return false
	
	return true


static func are_enemies_defeated(battlers: Array[Battler]) -> bool:
	for battler in get_enemy_battlers(battlers):
		if battler.actor.is_active:
			return false
	
	return true


static func _sort_battlers(a: Battler, b: Battler) -> bool:
	return a.stats.initiative >= b.stats.initiative
