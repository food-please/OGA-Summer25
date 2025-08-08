@tool
extends CombatArena

@export var source_battler: Battler
@export var target_battlers: Array[Battler]
@export var test_action: Script:
	set(value):
		test_action = value
		
		if test_action:
			var new_action: = test_action.new() as BattlerAction
			if new_action == null:
				test_action = null
				printerr("Combat arena needs a script derived from BattlerAction to test.")
		
		update_configuration_warnings()

var action: BattlerAction = null


func _ready() -> void:
	if not Engine.is_editor_hint():
		super._ready()
		
		assert(test_action != null, "Must have a test action to test!")
		assert(source_battler != null, "Must have a source Battler set!")
		
		await get_tree().create_timer(0.5).timeout
		
		print("\nBegin testing action:")
		action = test_action.new()
		await action.execute(source_battler, target_battlers)
		print("\nEnd testing.")
		
		#print("\nBegin testing action:")
		#await test_action.execute(source_battler, target_battlers)
		#print("\nEnd testing.")
		#start()


func _get_configuration_warnings() -> PackedStringArray:
	var msg: PackedStringArray = []
	if test_action == null:
		msg.append("Combat arena needs a test_action of BattlerAction type!")
	return msg
