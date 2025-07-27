@tool
@icon("icon_player_controller.png")
class_name PlayerController extends GamepieceController

## All [PlayerController] nodes will be members of the group labeled [constant GROUP].
const GROUP: = "_PlayerControllers"

## If the player is closer than this threshold to the clicked/touched cursor position, then their
## speed will be slowed according to how far away the player is.
const SLOW_THRESHOLD_SQUARED: = 50.0

## If the player is closer than this threshold to the clicked/touched cursor position, they will
## stop moving.
const STOP_THRESHOLD_SQUARED: = 20.0

# Keep track of which direction the player is moving.
var _input_dir: = Vector2.ZERO:
	set(value):
		value = value.normalized()
		
		if not _input_dir.is_equal_approx(value):
			_input_dir = value
			if parent:
				parent.velocity = _input_dir * parent.max_speed

# Keep track of whether or not the mouse is pressed (not relevant on gamepad).
var _touch_pressed: = false


func _ready() -> void:
	super._ready()
	add_to_group(GROUP)
	
	set_process(false)
	
	# If the controller is freed, be sure to reset the character's movement.
	tree_exiting.connect(
		func _on_tree_exiting() -> void: _stop_movement()
	)
	
	OverworldEvents.gameplay_paused.connect(
		func _on_gameplay_paused(is_paused: bool) -> void: is_active = !is_paused
	)


func _process(_delta: float) -> void:
	var cursor_pos: = parent.get_global_mouse_position()/parent.global_scale
	var distance_to_cursor_squared: = parent.position.distance_squared_to(cursor_pos)
	
	# There's an edge case where the camera moves and the gp wants to start again. To prevent that
	# from occuring, stop processing until the player moves the cursor again.
	if distance_to_cursor_squared < STOP_THRESHOLD_SQUARED:
		_stop_movement()
		return
	
	_input_dir = parent.global_position.direction_to(parent.get_global_mouse_position())
	if distance_to_cursor_squared < SLOW_THRESHOLD_SQUARED:
		var slow_factor: float = max(
			(distance_to_cursor_squared-STOP_THRESHOLD_SQUARED) / SLOW_THRESHOLD_SQUARED, 0.1)
		parent.velocity = _input_dir * parent.max_speed * slow_factor


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("walk_left") or event.is_action("walk_right") or event.is_action("walk_up")\
			or event.is_action("walk_down"):
		_input_dir = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	
	elif event.is_action_pressed("touch"):
		_touch_pressed = true
		set_process(true)
	
	elif event.is_action_released("touch"):
		_touch_pressed = false
		_stop_movement()
	
	# This is an edge case where the gp was too close to the cursor to move, so the controller 
	# stopped processing.
	elif event is InputEventMouseMotion and not is_processing() and _touch_pressed:
		set_process(true)


func set_is_active(value: bool) -> void:
	super.set_is_active(value)
	if not is_active:
		_stop_movement()


func _stop_movement() -> void:
	set_process(false)
	if parent:
		_input_dir = Vector2.ZERO
