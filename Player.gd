extends KinematicBody

const DEADZONE_IN_VALUE = 0.05 * 0.05
const DEADZONE_OUT_VALUE = 0.05 * 0.05

export(float) var player_speed: float = 20.0
var player_speed_squared: float = player_speed * player_speed

export(float) var time_to_peak = 0.6 # seconds
export(float) var jump_height = 6.0 # units
export(float) var hop_height = 4.0 # units

export(NodePath) var camera_path: NodePath = "../PlayerCamera"
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
	
	target_velocity.x = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	target_velocity.y = 0.0;
	target_velocity.z = Input.get_action_strength("player_back") - Input.get_action_strength("player_forward")
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_speed
		
	if Input.is_action_just_released("ui_accept") and velocity.y > hop_speed:
		velocity.y = hop_speed
		
	
	# clamp the target velocity to the max speed
	if target_velocity.length_squared() > DEADZONE_IN_VALUE: # deadzone in
		target_velocity = (target_velocity * (player_speed + 1.0))
		if target_velocity.length_squared() > player_speed_squared + DEADZONE_OUT_VALUE: # deadzone out
			target_velocity = target_velocity.normalized() * player_speed
	

	if camera:
		camera.control(delta, self)	

	
func movement_control(delta):
	
	var f = run_acceleration if velocity.length_squared() > 0.0 else run_friction
	velocity.y -= gravity * delta
	if camera:
		target_velocity = target_velocity.rotated(Vector3.UP, deg2rad(camera.rotation_degrees.y))
	velocity = Utils.assign_zx(velocity, lerp(Utils.zx(velocity), Utils.zx(target_velocity), f*delta))
	velocity = self.move_and_slide_with_snap(velocity, Vector3.ZERO, Vector3.UP)
	
	
func _physics_process(delta):
	movement_control(delta)
	
