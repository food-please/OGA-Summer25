@tool
@icon("icon_gamepiece.png")
class_name Gamepiece extends CharacterBody2D

@export_category("Movement")
@export var max_speed: = 80
@export var acceleration = 1000.0
@export var deceleration = 800.0

@export_category("GFX")
## A [GamepieceAnimation] packed scene that will be automatically added to the gamepiece. Other
## scene types will not be accepted.
@export var animation_scene: PackedScene:
	set(value):
		animation_scene = value
		
		if not is_inside_tree():
			await ready
		
		if gfx:
			gfx.queue_free()
			gfx = null
		
		if animation_scene:
			# Check to make sure that the supplied scene instantiates as a GamepieceAnimation.
			var new_scene: = animation_scene.instantiate()
			gfx = new_scene as GamepieceGFX
			if not gfx:
				printerr("Gamepiece '%s' cannot accept '%s' as " % [name, new_scene.name],
					"gamepiece_gfx_scene. '%s' is not a GamepieceGFX object!" % new_scene.name)
				new_scene.free()
				animation_scene = null
				return
			
			add_child(gfx)

## The visual representation of the gamepiece, set automatically based on [member animation_scene].
## Usually the animation is only changed by the gamepiece itself, though the designer may want to
## play different animations sometimes (such as during a cutscene).
var gfx: GamepieceGFX = null


func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
	
	else:
		# Wait a frame for the gfx setter to run.
		await get_tree().process_frame
		assert(gfx, "Gamepiece %s has no animation scene assigned!" % name)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	move_and_slide()
	
	if is_moving():
		gfx.set_direction(velocity)
		gfx.play("Walk")
	
	else:
		gfx.play("Idle")


func is_moving() -> bool:
	return not velocity.is_equal_approx(Vector2.ZERO)


func get_collision_shape() -> Shape2D:
	return gfx.shape
