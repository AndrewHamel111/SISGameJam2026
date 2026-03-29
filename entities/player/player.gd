class_name Player
extends CharacterBody3D

signal start_order(order: Order)
signal pickup_order(order: Order)
signal deliver_order(order: Order)

@onready var interior_root: Node3D = $InteriorRoot
@onready var exterior_root: Node3D = $ExteriorRoot

@onready var camera_exterior: Camera3D = $ExteriorRoot/CameraExteriorRoot/CameraExterior
@onready var camera_exterior_root: Node3D = $ExteriorRoot/CameraExteriorRoot
@onready var camera_interior: Camera3D = $InteriorRoot/CameraInterior

var camera_mode: bool = false
var hud: HUDController

# progression
var money: float = 50
var points: int = 0
var rating: int = 1
var active_orders: Array[Order]

# phone control
var phone_selected_index : int = 0

# car control
const CAR_TURN_SPEED := 10.0
const MIN_TURN_ANGLE := -1.25
const MAX_TURN_ANGLE := 1.25
const CAR_DECELERATION := 2.5
const CAR_BRAKING := 10.0
const CAR_MAX_SPEED_WITH_GAS := 25.0
const CAR_MAX_SPEED_NO_GAS := 3.0
var max_speed := CAR_MAX_SPEED_WITH_GAS
var forward_velocity := 0.0
var turn_angle := 0.0

# gas
var gas_station: GasStation = null
var gas_remaining := 20.0
var gas_max := 20.0
var gas_usage_rate := 1.1


@export var car_acceleration_curve: Curve

func _ready() -> void:
	hud = get_node("/root/World/CanvasLayer/HUD") as HUDController
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("camera_toggle"):
		toggle_camera_mode()

func _physics_process(delta: float) -> void:
	max_speed = CAR_MAX_SPEED_WITH_GAS
	if gas_remaining <= 0.0:
		max_speed = CAR_MAX_SPEED_NO_GAS

	if Input.is_action_pressed("turn_left"):
		turn_angle += delta * CAR_TURN_SPEED
		turn_angle = minf(turn_angle, MAX_TURN_ANGLE)
	elif Input.is_action_pressed("turn_right"):
		turn_angle -= delta * CAR_TURN_SPEED
		turn_angle = maxf(turn_angle, MIN_TURN_ANGLE)
	else:
		turn_angle = move_toward(turn_angle, 0, delta * CAR_TURN_SPEED)
	
	if Input.is_action_pressed("accelerate"):
		forward_velocity += delta * car_acceleration_curve.sample(forward_velocity / max_speed)
		forward_velocity = minf(forward_velocity, max_speed)
	else:
		var deceleration : float = CAR_BRAKING if Input.is_action_pressed("brake") else CAR_DECELERATION
		forward_velocity = move_toward(forward_velocity, 0, delta * deceleration)
	
	if Input.is_action_just_pressed("phone_down"):
		phone_selected_index += 1
		phone_selected_index = mini(phone_selected_index, 2)
		hud.hand_controller.set_pose(phone_selected_index as HandController.Pose)
		hud.phone_display.select_order(phone_selected_index)
	elif Input.is_action_just_pressed("phone_up"):
		phone_selected_index -= 1
		phone_selected_index = maxi(phone_selected_index, 0)
		hud.hand_controller.set_pose(phone_selected_index as HandController.Pose)
		hud.phone_display.select_order(phone_selected_index)
	if Input.is_action_just_pressed("phone_left"):
		hud.hand_controller.set_pose(HandController.Pose.SWIPE_LEFT)
	elif Input.is_action_just_pressed("phone_right"):
		hud.hand_controller.set_pose(HandController.Pose.SWIPE_RIGHT)
	
	if Input.is_action_just_pressed("phone_confirm"):
		hud.hand_controller.set_pressed(true)
		var order := hud.phone_display.get_order(phone_selected_index)
		if order:
			active_orders.push_back(order)
			start_order.emit(order)
	elif Input.is_action_just_released("phone_confirm"):
		hud.hand_controller.set_pressed(false)
	
	if forward_velocity > 0.1:
		var car_turn_angle := lerpf(turn_angle, turn_angle * 0.5, forward_velocity / max_speed)
		rotate_y(deg_to_rad(car_turn_angle))
		camera_exterior_root.rotation = Vector3(0, deg_to_rad(turn_angle), 0)
	
	hud.set_speed(roundi(lerpf(0, 50, forward_velocity / CAR_MAX_SPEED_WITH_GAS)))
	velocity = basis * Vector3(0, 0, 1) * forward_velocity
	move_and_slide()
	deal_with_gas(delta)

func toggle_camera_mode() -> void:
	camera_mode = not camera_mode
	camera_interior.current = not camera_mode
	interior_root.visible = not camera_mode
	camera_exterior.current = camera_mode
	exterior_root.visible = camera_mode
	
func entered_gas_station(station : GasStation) -> void:
	gas_station = station

func exited_gas_station(_station : GasStation) -> void:
	gas_station = null

func deal_with_gas(delta: float) -> void:
	var gas_velocity : float = forward_velocity
	if gas_velocity > Player.CAR_MAX_SPEED_WITH_GAS:
		gas_velocity = Player.CAR_MAX_SPEED_WITH_GAS

	var velocity_perc := gas_velocity / CAR_MAX_SPEED_WITH_GAS

	gas_remaining -= gas_usage_rate * delta * velocity_perc
	if gas_remaining < 0:
		gas_remaining = 0

	if gas_station:
		if forward_velocity == 0:
			gas_remaining += gas_station.fill_rate * delta
			if gas_remaining > gas_max:
				gas_remaining = gas_max

func add_money(value: float) -> void:
	money += value
	if value > 0:
		points += (value * 100) as int

func add_rating(value: int) -> void:
	rating += value
	rating = clampi(rating, 0, 5)

func house_area_entered(house: House) -> void:
	var orders_to_remove: Array[Order]
	for order in active_orders:
		if order.status == Order.Status.STARTED and order.pickup_address == house.name:
			pickup_order.emit(order)
		elif order.status == Order.Status.PICKED_UP and order.destination_address == house.name:
			deliver_order.emit(order)
			orders_to_remove.push_back(order)
	for order in orders_to_remove:
		active_orders.erase(order)

func handle_timeout() -> void:
	var timed_out_orders : Array[Order]
	for order in active_orders:
		if order.is_expired():
			timed_out_orders.push_back(order)
	for order in timed_out_orders:
		active_orders.erase(order)
