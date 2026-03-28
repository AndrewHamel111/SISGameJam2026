class_name Player
extends CharacterBody3D

@onready var interior_root: Node3D = $InteriorRoot
@onready var exterior_root: Node3D = $ExteriorRoot

@onready var camera_exterior: Camera3D = $ExteriorRoot/CameraExteriorRoot/CameraExterior
@onready var camera_exterior_root: Node3D = $ExteriorRoot/CameraExteriorRoot
@onready var camera_interior: Camera3D = $InteriorRoot/CameraInterior

var camera_mode: bool = true
var hud: HUDController

# car control
const CAR_TURN_SPEED := 10.0
const MIN_TURN_ANGLE := -1.25
const MAX_TURN_ANGLE := 1.25
const CAR_DECELERATION := 2.5
const CAR_BRAKING := 10.0
const CAR_MAX_SPEED := 25.0
var forward_velocity := 0.0
var turn_angle := 0.0

@export var car_acceleration_curve: Curve

func _ready() -> void:
	hud = get_node("/root/World/CanvasLayer/HUD") as HUDController

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("camera_toggle"):
		toggle_camera_mode()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("turn_left"):
		turn_angle += delta * CAR_TURN_SPEED
		turn_angle = minf(turn_angle, MAX_TURN_ANGLE)
	elif Input.is_action_pressed("turn_right"):
		turn_angle -= delta * CAR_TURN_SPEED
		turn_angle = maxf(turn_angle, MIN_TURN_ANGLE)
	else:
		turn_angle = move_toward(turn_angle, 0, delta * CAR_TURN_SPEED)
	
	if Input.is_action_pressed("accelerate"):
		forward_velocity += delta * car_acceleration_curve.sample(forward_velocity / CAR_MAX_SPEED)
		forward_velocity = minf(forward_velocity, CAR_MAX_SPEED)
	else:
		var deceleration : float = CAR_BRAKING if Input.is_action_pressed("brake") else CAR_DECELERATION
		forward_velocity = move_toward(forward_velocity, 0, delta * deceleration)
	
	if forward_velocity > 0.1:
		var car_turn_angle := lerpf(turn_angle, turn_angle * 0.5, forward_velocity / CAR_MAX_SPEED)
		rotate_y(deg_to_rad(car_turn_angle))
		camera_exterior_root.rotation = Vector3(0, deg_to_rad(turn_angle), 0)
	
	hud.set_speed(roundi(lerpf(0, 50, forward_velocity / CAR_MAX_SPEED)))
	velocity = basis * Vector3(0, 0, 1) * forward_velocity
	move_and_slide()

func toggle_camera_mode() -> void:
	camera_mode = not camera_mode
	camera_interior.current = not camera_mode
	interior_root.visible = not camera_mode
	camera_exterior.current = camera_mode
	exterior_root.visible = camera_mode
