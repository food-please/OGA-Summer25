extends ScriptedEvent


func _execute() -> void:
	print("Run event!")
	DialogueManager.show_dialogue_balloon(load("res://test_dlg.dialogue"))
	await DialogueManager.dialogue_ended
	
	Combat.start(load("res://src/combat/arena/combat_arena.tscn"))
	print("Done")
