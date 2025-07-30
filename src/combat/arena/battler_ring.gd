@tool
class_name BattlerRing extends Resource

signal angle_changed
signal scale_changed

@export var angle: = 0.0:
	set(value):
		angle = BattlerRing.clamp_angle(value)
		angle_changed.emit()

@export var scale: = Vector2.ONE:
	set(value):
		scale = value
		scale_changed.emit()

var _rotate_tween: Tween = null


static func clamp_angle(value: float) -> float:
	if value > 2*PI:
		return fmod(value, 2*PI)
	elif value < 0:
		return 2*PI + value
	return value


# Rotates the entire ring so that the 'target' angle ends up at the zero position (bottom).
# Speed is measured in rad/s.
func rotate_ring(node_in_tree: Node, target: float, angular_speed: = .5*PI) -> void:
	target = BattlerRing.clamp_angle(target)
	var travel_distance: = get_distance(angle, target)
	if is_equal_approx(travel_distance, 0.0):
		return
	
	# I want to figure out how long the rotation should last. Note that I'm assuming that the 
	#	angular speed is an average value to enable smooth movement.
	var duration: float = abs(travel_distance)/angular_speed
	
	if _rotate_tween:
		_rotate_tween.kill()
	_rotate_tween = node_in_tree.create_tween()
	_rotate_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	_rotate_tween.tween_property(self, "angle", angle + travel_distance, duration)
	await _rotate_tween.finished


## Convert a position value in arena space (3 dimensional, including a z-value which is considered
## to be upwards, i.e. in the 'air') to a screen-space value.
func Vector3_to_position(value: Vector3) -> Vector2:
	var rotated_position = Vector2(value.x, value.y).rotated(angle)
	return Vector2(rotated_position.x*scale.x, rotated_position.y*scale.y)


# Returns the angle in rads that the ring needs to shift from source to reach the destination angle.
func get_distance(source: float, destination: float) -> float:
	if is_equal_approx(destination, source):
		return 0.0
	
	# There are two ways to traverse the ring, and I want the shortest. One will fit within the
	#	bounds of the ring (0-2*PI) the other will cross the 2*PI/0 line.
	# Note that the sign of the following is important. A positive distance indicates a counter-
	#	clockwise movement.
	var distance_a = destination - source
	
	# The second distance is the opposite direction and the rest of the ring (i.e. when adding the
	#	absolute value of the two distances I should get 2*PI for a full circle).
	# Note that the distances move in opposite directions.
	var distance_b = (2*PI) - abs(distance_a)
	distance_b *= sign(distance_a)*-1
	
	if abs(distance_b) < abs(distance_a):
		return distance_b
	return distance_a
