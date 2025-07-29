class_name CombatCamera extends Camera2D

@export var battler_ring: BattlerRing:
	set(value):
		if battler_ring == value:
			return
		
		if battler_ring and battler_ring.angle_changed.is_connected(_on_battler_ring_angle_changed):
			battler_ring.angle_changed.disconnect(_on_battler_ring_angle_changed)
			
		battler_ring = value
		if battler_ring:
			battler_ring.angle_changed.connect(_on_battler_ring_angle_changed)

@export var background_width: = 640*3


# Displace the camera by a percentage of the background width (which is the maximum distance that
# the camera may move) based on the ring's rotation, which ranges from 0 to 2PI.
# Note that 2PI and 0 should overlap, i.e. produce the same camera position.
func _on_battler_ring_angle_changed() -> void:
	position.x = (battler_ring.angle / (2 * PI)) * background_width
