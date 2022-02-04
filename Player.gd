extends KinematicBody

export(float) var player_speed: float = 10.0

export(float) var time_to_peak = 0.6 # seconds
export(float) var jump_height = 4.0 # units

export(NodePath) var camera_path: NodePath
onready var camera: Camera = get_node(camera_path) if camera_path else null

export var run_acceleration = 3.0
export var run_friction = 8.0

onready var gravity = 2.0*jump_height / pow(time_to_peak, 2.0)
onready var jump_speed = gravity * time_to_peak

var target_velocity: Vector3 = Vector3.ZERO
var velocity: Vector3 = Vector3.ZERO
var look_vector: Vector3 = Vector3.FORWARD

func _process(delta):
	target_velocity = Vector3.ZERO
	
	if Input.is_action_pressed("ui_up"):
		target_velocity.z -= 1.0
	
	if Input.is_action_pressed("ui_down"):
		target_velocity.z += 1.0
	
	if Input.is_action_pressed("ui_left"):
		target_velocity.x -= 1.0

	if Input.is_action_pressed("ui_right"):
		target_velocity.x += 1.0
		
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_speed
		
	if target_velocity.length_squared() > 0.0:
		target_velocity = target_velocity.normalized() * 10.0


func camera_control(delta):
	
	if !camera:
		return
		
	camera.look_at(self.translation, Vector3.UP)
	camera.translation.y += (self.translation.y + 2.5 - camera.translation.y) * 3.5 * delta
	look_vector = (self.translation - camera.translation).normalized()
	camera.look_at_from_position(camera.translation, camera.translation + look_vector, Vector3.UP)
	camera.translation = self.translation - look_vector * 10.0
	
func xyz_zx(v: Vector3) -> Vector2:
	return Vector2(v.z, v.x)
	
func zx_xyz(v: Vector2, y: float) -> Vector3:
	return Vector3(v.y, y, v.x)
	
	
func movement_control(delta):
	
	var f = run_acceleration if velocity.length_squared() > 0.0 else run_friction
	
	velocity.y -= gravity * delta

	var tv = xyz_zx(target_velocity)
	tv = tv.rotated(deg2rad(camera.rotation_degrees.y))
	var running_velocity = xyz_zx(velocity)
	
	running_velocity = lerp(running_velocity, tv, f*delta)
	
	velocity = zx_xyz(running_velocity, velocity.y)
	
	velocity = self.move_and_slide(velocity, Vector3.UP)

func _physics_process(delta):
	
	camera_control(delta)
	movement_control(delta)
	
