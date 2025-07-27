## A utility class converting between Godot angles (+'ve x axis is 0 rads) and cardinal points.
class_name Directions
extends RefCounted

## Abbreviations for 8 cardinal points (i.e. NW = Northwest, or Vector2[-1, -1]).
const Points: Array[String] = ["W", "W", "N", "E", "E", "E", "S", "W"]

static var _ARC_DIVISIONS: = 2*PI / Points.size()

## The [Vector2i] form of a given cardinal point. That is, North is Vector2i(0, -1), etc.
const MAPPINGS: = {
	#Directions.Points.NW: Vector2i(-1, -1),
	"N": Vector2.UP,
	#Directions.Points.NE: Vector2i(1, -1),
	"E": Vector2.RIGHT,
	#Directions.Points.SE: Vector2i(1, 1),
	"S": Vector2.DOWN,
	#Directions.Points.SW: Vector2i(-1, 1),
	"W": Vector2.LEFT,
}


### Convert an angle, such as from [method Vector2.angle], to a [constant Points].
#static func angle_to_direction(angle: float) -> Points:
	#if angle <= -PI/4 and angle > -3*PI/4:
		#return Points.N
	#elif angle <= PI/4 and angle > -PI/4:
		#return Points.E
	#elif angle <= 3*PI/4 and angle > PI/4:
		#return Points.S
	#
	#return Points.W

## Convert any generic angle into a direction index, based on an 8-direction movement system.
## [br][br]These indices need to match [enum Directions], so will all be positive rather than 
## matching Godot's [method Vector2.angle] method. Consequnetly, index 0 corresponds to a W
## direction, and index 7 corresponds to a SW direction.
static func angle_to_direction(angle: float) -> String:
	# Snap the angle to increments matching 2PI / number of divisions of the circle, which is based
	# on the number of directions found in the Directions constant.
	# Also, ensure that the angle does not wrap around the circle more than once and that it is
	# corrected for Vector2's possible negative angles (i.e. -y in Vector2).
	var rounded_angle = round((angle + PI) / _ARC_DIVISIONS) * _ARC_DIVISIONS
	
	# Convert the snapped angle into an index, based on which division "number" it is.
	var idx: = int(rounded_angle / _ARC_DIVISIONS) % Points.size()
	return Points[idx]


static func vector_to_direction(vector: Vector2) -> String:
	return angle_to_direction(vector.angle())
