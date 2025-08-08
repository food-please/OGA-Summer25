class_name AttackAction extends BattlerAction


func execute(source: Battler, _targets: Array[Battler] = []) -> void:
	await source.get_tree().process_frame
	print("Fighteth")
	await source.get_tree().create_timer(0.9).timeout
