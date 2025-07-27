@tool
@icon("icon_room.png")
class_name Room extends Node2D

@export_range(1, 10, 1, "or_greater") var room_width: = 1:
	set(value):
		room_width = value
		
		if not is_inside_tree():
			await ready
		_update_visualizer()

@export_range(1, 10, 1, "or_greater") var room_height: = 1:
	set(value):
		room_height = value
		
		if not is_inside_tree():
			await ready
		_update_visualizer()

@onready var _camera_area: = $CameraArea as Area2D
@onready var _camera_area_shape: = $CameraArea/CollisionShape2D as CollisionShape2D
@onready var _visualizer: = $Visualizer as RoomVisualizer


func _ready() -> void:
	_update_visualizer()
	
	if not Engine.is_editor_hint():
		#_visualizer.hide()
		
		_camera_area.area_entered.connect(
			func _on_camera_area_entered(physics_area: Area2D) -> void:
				if physics_area.owner is PlayerPhysics:
					OverworldEvents.room_entered.emit(self)
		)


func get_room_bounds() -> Rect2:
	return Rect2(
			position.x,
			position.y,
			room_width * Constants.TILE_SIZE.x * Constants.SCREEN_SIZE_TILES.x,
			room_height * Constants.TILE_SIZE.y * Constants.SCREEN_SIZE_TILES.y
		)


func _update_visualizer() -> void:
	var new_bounds: = get_room_bounds()
	new_bounds.position.x = 0
	new_bounds.position.y = 0
	
	_camera_area.position = new_bounds.size/2
	
	_camera_area_shape.shape = RectangleShape2D.new()
	_camera_area_shape.shape.size = new_bounds.size - Vector2(Constants.TILE_SIZE)
	
	if _visualizer:
		_visualizer.draw_dimensions = new_bounds
