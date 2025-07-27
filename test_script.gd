extends ScriptedEvent


func _execute() -> void:
	print("Run event!")
	DialogueManager.show_dialogue_balloon(load("res://test_dlg.dialogue"))
	await DialogueManager.dialogue_ended
	
	print("Done")
