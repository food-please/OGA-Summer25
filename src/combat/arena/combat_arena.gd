## An arena is a combat preset, containing graphical, audio, and enemy information.
class_name CombatArena extends Node2D

## The music that will be automatically played during this combat instance.
@export var music: AudioStream

@onready var camera: Camera2D = $CombatCamera


func _ready() -> void:
	camera.make_current()
	
	var battler_ring: = BattlerRing.new()
	battler_ring.angle = 0.0
	battler_ring.scale.y = 0.2
	
	$CombatCamera/Battlers/Kangaroo.battler_ring = battler_ring
	$CombatCamera/Battlers/Kangaroo2.battler_ring = battler_ring
	camera.battler_ring = battler_ring
	
	await get_tree().create_timer(0.3).timeout
	
	await ScreenCover.clear(0.4)
	
	await battler_ring.rotate_ring(self, PI + 1)
	
	print(camera.is_current())
	
	await get_tree().create_timer(1.3).timeout
	await ScreenCover.cover(0.2)
	
