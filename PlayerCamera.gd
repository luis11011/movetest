tool

class_name PlayerCamera
extends Camera

export(float) var y_factor: float = 3.5
export(float) var distance = 3.0 setget set_distance
export(float) var angle = -15.0 setget set_angle

onready var vector: Vector3 = Vector3.FORWARD

func set_distance(d):
	distance = d
	update_vector()


func set_angle(a):
	angle = a
	update_vector()
	

func update_vector():
	vector = (Vector3.FORWARD * distance).rotated(Vector3.RIGHT, deg2rad(angle))
	translation = vector
	look_at(Vector3.ZERO, Vector3.UP)
	return vector
	
func _ready():
	update_vector()
