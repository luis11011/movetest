tool

class_name PlayerCamera
extends Camera

export(float) var y_factor: float = 3.5
export(float) var distance = 3.0 setget set_distance
export(float) var angle = -15.0 setget set_angle

var x_axis := 0.0
var y_axis := 0.0

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

func control(delta, player):
		
	var x_axis_control = float(Input.is_action_pressed("camera_right")) - float(Input.is_action_pressed("camera_left"))
	
	x_axis = lerp(x_axis, x_axis_control, 4.0 * delta)
		
	if x_axis != 0.0:
		var rt = translation - player.translation
		rt = rt.rotated(Vector3.UP, -delta * x_axis)
		translation = player.translation + rt
		
	look_at(player.translation + Vector3.UP*2.0, Vector3.UP)
	
	var camera_zx := Utils.zx(player.translation - translation).normalized() * vector.z
	
	translation.y = lerp(translation.y, player.translation.y + vector.y, y_factor * delta)
	translation = Utils.assign_zx(translation, Utils.zx(player.translation) + camera_zx)
	
	var y_axis_control = float(Input.is_action_pressed("camera_up")) - float(Input.is_action_pressed("camera_down"))
	
	y_axis = lerp(y_axis, y_axis_control, 4.0 * delta)
	
	if y_axis != 0.0:
		var rt = translation - player.translation
		rt = rt.rotated(Vector3.RIGHT.rotated(Vector3.UP, deg2rad(rotation_degrees.y)), y_axis * delta) # delta?
		translation = player.translation + rt
