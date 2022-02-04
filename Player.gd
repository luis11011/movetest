extends KinematicBody

export(float) var player_speed: float = 10.0

export(float) var time_to_peak = 0.6 # seconds
export(float) var jump_height = 6.0 # units
export(float) var hop_height = 4.0 # units

export(NodePath) var camera_path: NodePath
onready var camera: PlayerCamera = get_node(camera_path) if camera_path else null

export var run_acceleration = 3.0
export var run_friction = 8.0

onready var gravity = 2.0*jump_height / pow(time_to_peak, 2.0) # hop_height?
onready var jump_speed = gravity * time_to_peak
onready var hop_speed = jump_speed * (hop_height / jump_height)

var target_velocity: Vector3 = Vector3.ZERO
var velocity: Vector3 = Vector3.ZERO
var look_vector: Vector3 = Vector3.FORWARD

func _process(delta):
	target_velocity = Vector3.ZERO
	
	if Input.is_action_pressed("player_forward"):
		target_velocity.z -= 1.0
	
	if Input.is_action_pressed("player_back"):
		target_velocity.z += 1.0
	
	if Input.is_action_pressed("player_left"):
		target_velocity.x -= 1.0

	if Input.is_action_pressed("player_right"):
		target_velocity.x += 1.0
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_speed
		
	if Input.is_action_just_released("ui_accept") and velocity.y > hop_speed:
		velocity.y = hop_speed
		
		
	if target_velocity.length_squared() > 0.0:
		target_velocity = target_velocity.normalized() * 10.0

	camera_control(delta)

func camera_control(delta):
	
	if !camera:
		return
		
	if Input.is_action_pressed("camera_left"):
		var rt = camera.translation - self.translation
		rt = rt.rotated(Vector3.UP, -delta)
		camera.translation = self.translation + rt
		
	if Input.is_action_pressed("camera_right"):
		var rt = camera.translation - self.translation
		rt = rt.rotated(Vector3.UP, delta)
		camera.translation = self.translation + rt
		
	camera.look_at(self.translation + Vector3.UP*2.0, Vector3.UP)
	
	var camera_zx := Utils.zx(self.translation - camera.translation).normalized() * camera.vector.z
	
	camera.translation.y = lerp(camera.translation.y, self.translation.y + camera.vector.y, camera.y_factor * delta)
	camera.translation = Utils.assign_zx(camera.translation, Utils.zx(self.translation) + camera_zx)
	
	if Input.is_action_pressed("camera_up"):
		var rt = camera.translation - self.translation
		rt = rt.rotated(Vector3.RIGHT.rotated(Vector3.UP, deg2rad(camera.rotation_degrees.y)), -delta) # delta?
		camera.translation = self.translation + rt
		
	if Input.is_action_pressed("camera_down"):
		var rt = camera.translation - self.translation
		rt = rt.rotated(Vector3.RIGHT.rotated(Vector3.UP, deg2rad(camera.rotation_degrees.y)), delta) # delta?
		camera.translation = self.translation + rt
	
	
func movement_control(delta):
	
	var f = run_acceleration if velocity.length_squared() > 0.0 else run_friction
	velocity.y -= gravity * delta
	if camera != null:
		target_velocity = target_velocity.rotated(Vector3.UP, deg2rad(camera.rotation_degrees.y))
	velocity = Utils.assign_zx(velocity, lerp(Utils.zx(velocity), Utils.zx(target_velocity), f*delta))
	velocity = self.move_and_slide_with_snap(velocity, Vector3.ZERO, Vector3.UP)
	
	
func _physics_process(delta):
	movement_control(delta)
	
