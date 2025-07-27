extends Node2D

signal panned

@export var pan_speed: = 1024.0

@export var bounds: = Rect2i(0, 0, 320, 240):
	set = set_bounds

@export var player: Node2D

var _pan_tween: Tween

@onready var _camera: = $Camera2D as Camera2D
@onready var _half_size: = get_viewport().get_visible_rect().size/(2 * global_scale)


func _ready() -> void:
	#assert(player, "The player camera '%s' has no assigned player reference!" % name)
	
	OverworldEvents.room_entered.connect(
		func _on_player_entered_room(room: Room) -> void: set_bounds(room.get_room_bounds())
	)
	
	Player.gamepiece_changed.connect(
		func _on_player_gamepiece_changed(new_char: Gamepiece): 
			player = new_char
	)


func _physics_process(_delta: float) -> void:
	if player != null:
		position = player.position
		
		position.x = _find_closest_bounded_axis_position(position.x, _half_size.x, bounds.position.x, 
			bounds.end.x)
		position.y = _find_closest_bounded_axis_position(position.y, _half_size.y, bounds.position.y, 
			bounds.end.y)


func move_to(destination: Vector2, speed: float) -> void:
	var distance: = (destination-position).length()
	
	set_physics_process(false)
	
	if _pan_tween:
		_pan_tween.kill()
	_pan_tween = create_tween()
	_pan_tween.tween_property(self, "position", destination, distance/speed)
	_pan_tween.tween_callback(
		func(): 
			panned.emit()
			set_physics_process(true)
	)


func place(destination: Vector2) -> void:
	position = destination
	_camera.reset_smoothing()


func set_bounds(value: Rect2i) -> void:
	bounds = value
	
	# New boundaries are set. Therefore, figure out where the camera should move to.
	if not bounds.encloses(Rect2i(position, _half_size*2)):
		var target: = Vector2(
			_find_closest_bounded_axis_position(player.position.x, _half_size.x, 
				bounds.position.x, bounds.end.x),
			_find_closest_bounded_axis_position(player.position.y, _half_size.y, 
				bounds.position.y, bounds.end.y)
		)
		
		move_to(target, pan_speed)
		await panned


func _find_closest_bounded_axis_position(current: float, half_size: float, start_bound: float, 
		end_bound: float) -> float:
	if end_bound-start_bound < half_size*2:
		return (start_bound + (end_bound-start_bound)/2.0)
	elif current + half_size > end_bound:
		return end_bound - half_size
	elif current - half_size < start_bound:
		return start_bound + half_size
	return current
