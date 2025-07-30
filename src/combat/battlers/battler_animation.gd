@tool
class_name BattlerAnimation extends Node2D

# Denotes which direction an object faces, assuming that all objects somewhere in the battler arena
# face the centre of the battler ring.
const Facing: = ["SE", "SW", "NW", "NE",]

@export var current_track: String:
	set(value):
		if value != current_track:
			current_track = value
			
			if not is_inside_tree():
				await ready
			_update_playing_animation()

@export var height: = 0.0:
	set(value):
		height = value
		
		if not is_inside_tree():
			await ready
		_offset.position.y = -height
		
		# Rational behind this calculation: a REALLY small shadow looks goofy, so we'll plan on it
		# shrinking by roughly half if the battler has almost jumped out of the screen.
		var vp_height: = get_viewport_rect().size.y
		var shadow_scale_factor: = 1.0 - 0.5*(height/vp_height)
		_shadow.scale.x = shadow_scale_factor
		_shadow.scale.y = shadow_scale_factor

@export_range(0, 3) var facing: int:
	set(value):
		if facing >= 0 and facing <= 3 and value != facing:
			facing = value
			
			if not is_inside_tree():
				await ready
			_update_playing_animation()

@onready var _anim: = $AnimationPlayer as AnimationPlayer
@onready var _offset: = $Height as Node2D
@onready var _shadow: = $Shadow as Sprite2D


func _ready() -> void:
	current_track = "Idle"


## Convert a position value in 2D space relative to the battle ring centre (origin, considered 0,0)
## into a [enum Facing].
func set_facing_from_position(value: Vector2) -> void:
	# Quandrant indices start at 0 in the top left (corresponds to Cartesian quadrant II) and
	# proceeds clockwise.
	# The modulo operator ensures that a value of 4 will not occur, which would otherwise whenever
	# an object occured on the Vector2.RIGHT axis.
	facing = int((value.angle() + PI) / (PI / 2)) % 4


# Decide which animation should be played given the current track and facing of the battler.
# Usually called after either the current animation or current facing changes.
func _update_playing_animation(preserve_time: = true) -> void:
	var time_ratio: = 0.0
	if preserve_time and _anim.is_playing():
		time_ratio = _anim.current_animation_position / _anim.current_animation_length
	
	var animation_track: String = current_track + Facing[facing]
	print("Trying to play ", animation_track)
	if _anim.has_animation(animation_track):
		_anim.play(animation_track)
		_anim.seek(time_ratio * _anim.current_animation_length, true)
