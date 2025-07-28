## An arena is a combat preset, containing graphical, audio, and enemy information.
class_name CombatArena extends Node2D

## The music that will be automatically played during this combat instance.
@export var music: AudioStream

@onready var camera: Camera2D = $CombatCamera
