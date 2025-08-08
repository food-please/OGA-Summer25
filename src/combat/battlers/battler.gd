@tool
@icon("icon_battler.png")
class_name Battler extends Node2D

const GROUP: = "_GROUP_BATTLERS"

@export_category("GFX")

## A [BattlerAnimation] packed scene that will be automatically added to the Battler. Other
## scene types will not be accepted.
@export var animation_scene: PackedScene:
	set = _set_animation

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

@export_category("")
## Only one Actor may control the Battler.
@export var actor_scene: PackedScene:
	set = _set_actor

@export var stats: BattlerStats

var actor: Actor = null
var gfx: BattlerAnimation = null

## The battler's default position on the battler ring. The battler will return here after executing
## an action, being whacked in the head, dying, etc.
var rest_arena_position: Vector3

#@onready var gfx: = $BattlerAnimation as BattlerAnimation


func _ready() -> void:
	if not Engine.is_editor_hint():
		assert(actor_scene, "Battler '%s' has no Actor assigned!" % name)
		assert(animation_scene, "Battler '%s' has no BattlerAnimation assigned!" % name)
		assert(stats, "Battler '%s' has no BattlerStats assigned!" % name)
		
		add_to_group(GROUP)


func update_position() -> void:
	if battler_ring == null:
		return
	
	position = battler_ring.Vector3_to_position(arena_position)
	
	if gfx:
		gfx.height = -arena_position.z
		gfx.set_facing_from_position(position)


func _set_actor(value: PackedScene) -> void:
	print("Actor setter")
	if value == actor_scene:
		print("Exit here")
		return
	
	actor_scene = value
	
	print("Before await")
	if not is_inside_tree():
		await ready
	print("After await")
	if actor:
		actor.queue_free()
		actor = null
	
	if actor_scene:
		# Check to make sure that the supplied scene instantiates as a GamepieceAnimation.
		var new_scene: = actor_scene.instantiate()
		actor = new_scene as Actor
		if not actor:
			printerr("Battler '%s' cannot accept '%s' as " % [name, new_scene.name],
				"actor_scene. '%s' is not an Actor object!" % new_scene.name)
			new_scene.free()
			actor_scene = null
			return
		
		print("Made actor!")
		add_child(actor)


# We want to call this on ready, rather than wait a frame for it to be set.
func _set_animation(value: PackedScene) -> void:
	if value == animation_scene:
		return
	
	animation_scene = value
	
	if not is_inside_tree():
		await ready
	
	if gfx:
		gfx.queue_free()
		gfx = null
	
	if animation_scene:
		# Check to make sure that the supplied scene instantiates as a GamepieceAnimation.
		var new_scene: = animation_scene.instantiate()
		gfx = new_scene as BattlerAnimation
		if not gfx:
			printerr("Battler '%s' cannot accept '%s' as " % [name, new_scene.name],
				"animation_scene. '%s' is not a BattlerAnimation object!" % new_scene.name)
			new_scene.free()
			animation_scene = null
			return
		
		add_child(gfx)
		update_position()
