## Keeps reference to the various combat participants, including all [Battler]s and their teams.
## The list allows retrieving Battlers on a spatial basis as well, figuring out where they all are
## related to one another, which ones are next or previous in the list, etc.
class_name BattlerList extends Node

# Cache a refernce to the tree, so that we can lookup the Battler [constant Battler.GROUP].
var _scene_tree: SceneTree


func _init(tree_ref: SceneTree) -> void:
	_scene_tree = tree_ref


## Returns all battlers (active and inactive, downed or alive) currently engaged in combat.
## The list is sorted by [member BattlerStats.initiative].
func get_battlers() -> Array[Battler]:
	var battlers: Array[Battler] = []
	battlers.assign(_scene_tree.get_nodes_in_group(Battler.GROUP))
	
	battlers.sort_custom(_sort_battlers)
	return battlers


func get_player_battlers() -> Array[Battler]:
	return get_battlers().filter(
		func _filter_players(battler: Battler):
			return battler.actor.is_player
	)


func get_enemy_battlers() -> Array[Battler]:
	return get_battlers().filter(
		func _filter_enemies(battler: Battler):
			return not battler.actor.is_player
	)


func get_active_battlers(battlers: Array[Battler]) -> Array[Battler]:
	return battlers.filter(func(battler: Battler) -> bool: return battler.actor.is_active)


func get_live_battlers(battlers: Array[Battler]) -> Array[Battler]:
	return battlers.filter(func(battler: Battler): return battler.stats.health > 0)


## Returns the [Battler] with highest [member BattlerStats.initiative] that is active and has not
## yet taken its turn.
func get_next_actor() -> Actor:
	var ready_to_act_battlers: = get_active_battlers(get_battlers()).filter(
		func _filter_acted_battlers(battler: Battler) -> bool:
			return not battler.actor.has_acted_this_turn
	)
	if ready_to_act_battlers.is_empty():
		return null
	
	return ready_to_act_battlers.front().actor


func are_players_defeated() -> bool:
	for battler in get_player_battlers():
		if battler.actor.is_active:
			return false
	
	return true


func are_enemies_defeated() -> bool:
	for battler in get_enemy_battlers():
		if battler.actor.is_active:
			return false
	
	return true


func _sort_battlers(a: Battler, b: Battler) -> bool:
	return a.stats.initiative >= b.stats.initiative
