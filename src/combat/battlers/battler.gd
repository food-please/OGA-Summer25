@tool
@icon("icon_battler.png")
class_name Battler extends Node2D

@export var battler_ring: BattlerRing:
	set(value):
		if not value and battler_ring:
			if battler_ring.angle_changed.is_connected(update_position):
				battler_ring.angle_changed.disconnect(update_position)
			
			if battler_ring.scale_changed.is_connected(update_position):
				battler_ring.scale_changed.disconnect(update_position)
		
		battler_ring = value
		if not is_inside_tree():
			await ready
		
		if battler_ring:
			battler_ring.angle_changed.connect(update_position)
			battler_ring.scale_changed.connect(update_position)
			
			update_position()

## A pseduo-3D representation of the Battler's position on the battlefield.[br][br]
## Note: The Battler's [member Node2D.position] is calculated automatically from the arena position.
## The Battler's position should not be modified. Opt instead to manipulate position through the
## arena_position property.
@export var arena_position: Vector3:
	set(value):
		arena_position = value
		
		if not is_inside_tree():
			await ready
		
		if battler_ring:
			update_position()

## The battler's default position on the battler ring. The battler will return here after executing
## an action, being whacked in the head, dying, etc.
var rest_arena_position: Vector3

@onready var gfx: = $BattlerAnimation as BattlerAnimation


func melee_attack() -> void:
	print("Attack!")


func update_position() -> void:
	position = battler_ring.Vector3_to_position(arena_position)
	gfx.height = -arena_position.z
	gfx.set_facing_from_position(position)
