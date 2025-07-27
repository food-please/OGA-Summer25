## Allows [method play]ing animations that automatically adapt to the parent [Gamepiece]'s
## direction. Transitions between animations are handled automatically, including changes to
## direction.
## [br][br][b]Note:[/b] This is usually not added to the scene tree directly by the designer.
## Rather, it is typically added to a [Gamepiece] through the [member Gamepiece.animation_scene]
## property.
class_name GamepieceGFX extends CollisionShape2D

## Emitted whenever animation switches direction. The value corresponds to a mapping from
## [member Directions.Points].
signal direction_changed(value: String)

## Name of the animation sequence used to reset animation properties to default. Note that this
## animation is only played for a single frame during animation transitions.
const RESET_SEQUENCE_KEY: = "RESET"

## The animation currently being played.
var current_sequence_id: = "":
	set = play

# The direction faced by the gamepiece.
# [br][br]Animations may optionally be direction-based. Setting the direction will use directional 
# animations if they are available; otherwise non-directional animations will be used.
var _direction: = "S":
	set(value):
		if not value in Directions.Points:
			return
		if _direction == value:
			return
		
		_direction = value
		if _anim.has_animation(current_sequence_id + _direction):
			_swap_animation(current_sequence_id + _direction, true)
		
		elif _anim.has_animation(current_sequence_id):
			_swap_animation(current_sequence_id, true)
		
		direction_changed.emit(_direction)

@onready var _anim: = $AnimationPlayer as AnimationPlayer


## Change the currently playing animation to a new value, if it exists.
## [br][br]Animations may be added with or without a directional suffix (i.e. _n for north/up).
## Directional animations will be preferred with direction-less animations as a fallback.
func play(value: String) -> void:
	if value == current_sequence_id:
		return
	
	if not is_inside_tree():
		await ready
	
	# We need to check to see if the animation is valid.
	# First of all, look for a directional equivalent - e.g. idle_n. If that fails, look for 
	# the new sequence id itself.
	#var sequence_suffix: = Directions.vector_to_direction(direction)
	if _anim.has_animation(value + _direction):
		current_sequence_id = value
		_swap_animation(value + _direction, false)
	
	elif _anim.has_animation(value):
		current_sequence_id = value
		_swap_animation(value, false)


## Change the animation's direction.
## If the currently running animation has a directional variant matching the new direction it will
## be played. Otherwise the direction-less animation will play.
func set_direction(value: Vector2) -> void:
	_direction = Directions.vector_to_direction(value)
	#value = value.normalized()
	#if direction.is_equal_approx(value):
		##print("Too close")
		#return
	#
	##print("Set diretion! ", value)
	#direction = value
	#
	#if not is_inside_tree():
		#await ready
	#
	#var sequence_suffix: = Directions.vector_to_direction(direction)
	#if _anim.has_animation(current_sequence_id + sequence_suffix):
		#_swap_animation(current_sequence_id + sequence_suffix, true)
	#
	#elif _anim.has_animation(current_sequence_id):
		#_swap_animation(current_sequence_id, true)


# Transition to the next animation sequence, accounting for the RESET track and current animation
# elapsed time.
func _swap_animation(next_sequence: String, keep_position: bool) -> void:
	var next_anim = _anim.get_animation(next_sequence)
	
	if next_anim:
		# If keeping the current position, we want to do so as a ratio of the
		# position / animation length to account for animations of different length.
		var current_position_ratio = 0
		if keep_position:
			current_position_ratio = \
				_anim.current_animation_position / _anim.current_animation_length
		
		# RESET the animation immediately to its default reset state before the next sequence.
		# Take advantage of the default RESET animation to clear uncommon changes (i.e. flip_h).
		if _anim.has_animation(RESET_SEQUENCE_KEY):
			_anim.play(RESET_SEQUENCE_KEY)
			_anim.advance(0)
		
		_anim.play(next_sequence)
		_anim.advance(current_position_ratio * next_anim.length)
