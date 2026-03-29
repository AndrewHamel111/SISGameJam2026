class_name Player
extends CharacterBody3D

signal start_order(order: Order)
signal pickup_order(order: Order)
signal deliver_order(order: Order)

@onready var raycast: RayCast3D = $RayCast3D
@onready var order_success_stream: AudioStreamPlayer3D = $OrderSuccessStream

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
const CAR_DECELERATION_ON_GRASS := 10.0
const CAR_COAST_DECELERATION := 0.5
const CAR_BRAKING := 20.0
const CAR_MAX_SPEED_WITH_GAS := 25.0
const CAR_MAX_SPEED_NO_GAS := 5.0
const CAR_MAX_SPEED_ON_GRASS := 3.0
var max_speed := CAR_MAX_SPEED_WITH_GAS
var forward_velocity := 0.0
var turn_angle := 0.0
var in_reverse := false

var on_grass := false

# gas
var gas_station: GasStation = null
var gas_max := 50.0
var gas_remaining := gas_max * 0.8
var gas_usage_rate := 1.0


@export var car_acceleration_curve: Curve

func _ready() -> void:
	hud = get_node("/root/World/CanvasLayer/HUD") as HUDController
	hud.bank_view.set_money(money)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("camera_toggle"):
		toggle_camera_mode()

func _physics_process(delta: float) -> void:
	max_speed = CAR_MAX_SPEED_WITH_GAS
	if gas_remaining <= 0.0:
		max_speed = CAR_MAX_SPEED_NO_GAS
	if on_grass:
		max_speed = CAR_MAX_SPEED_ON_GRASS

	var max_turn_angle := MAX_TURN_ANGLE if not on_grass else MAX_TURN_ANGLE * 3.0
	var min_turn_angle := MIN_TURN_ANGLE if not on_grass else MIN_TURN_ANGLE * 3.0

	if Input.is_action_pressed("turn_left"):
		turn_angle += delta * CAR_TURN_SPEED
		turn_angle = minf(turn_angle, max_turn_angle)
	elif Input.is_action_pressed("turn_right"):
		turn_angle -= delta * CAR_TURN_SPEED
		turn_angle = maxf(turn_angle, min_turn_angle)
	else:
		turn_angle = move_toward(turn_angle, 0, delta * CAR_TURN_SPEED)

	if Input.is_action_pressed("accelerate"):
		in_reverse = false
		if gas_remaining <= 0:
			forward_velocity = move_toward(forward_velocity, max_speed, delta * CAR_DECELERATION)
		if on_grass:
			forward_velocity = move_toward(forward_velocity, max_speed, delta * CAR_DECELERATION_ON_GRASS)
		else:
			forward_velocity += delta * car_acceleration_curve.sample(forward_velocity / max_speed)
			forward_velocity = minf(forward_velocity, max_speed)
	elif not in_reverse or not Input.is_action_pressed("brake"):
		var deceleration : float = CAR_BRAKING if Input.is_action_pressed("brake") else CAR_DECELERATION
		forward_velocity = move_toward(forward_velocity, 0, delta * deceleration)

	if forward_velocity == 0 and Input.is_action_just_pressed("brake"):
		in_reverse = true

	if in_reverse and Input.is_action_pressed("brake"):
		forward_velocity = move_toward(forward_velocity, -4, delta * CAR_DECELERATION)

	#print("Velocity: ", forward_velocity, " Gas: ", gas_remaining)

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
		hud.phone_display.scroll_apps(-1)
	elif Input.is_action_just_pressed("phone_right"):
		hud.hand_controller.set_pose(HandController.Pose.SWIPE_RIGHT)
		hud.phone_display.scroll_apps(1)
	
	if Input.is_action_just_pressed("phone_confirm"):
		hud.hand_controller.set_pressed(true)
		if hud.phone_display.current_app == PhoneDisplay.App.ORDERS:
			var order_display := hud.phone_display.get_order(phone_selected_index)
			var order := order_display.order
			if order and order.status == Order.Status.PENDING:
				active_orders.push_back(order)
				start_order.emit(order)
				order_display.start_order_timer()
				$ToneAStream.play()
		if hud.phone_display.current_app == PhoneDisplay.App.MAP:
			hud.map_view.toggle_zoom()
			pass
	elif Input.is_action_just_released("phone_confirm"):
		hud.hand_controller.set_pressed(false)

	if true: #forward_velocity > 0.1:
		var car_turn_angle := lerpf(turn_angle, turn_angle * 0.5, forward_velocity / CAR_MAX_SPEED_WITH_GAS)
		if in_reverse:
			car_turn_angle = lerpf(turn_angle, turn_angle * 0.5, -forward_velocity / -10)

		#print( "angle", car_turn_angle )

		rotate_y(deg_to_rad(car_turn_angle))
		camera_exterior_root.rotation = Vector3(0, deg_to_rad(turn_angle), 0)
	
	hud.set_speed(roundi(lerpf(0, 50, forward_velocity / CAR_MAX_SPEED_WITH_GAS)))
	velocity = basis * Vector3(0, 0, 1) * forward_velocity
	move_and_slide()
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var normal := collision.get_normal()
		var my_direction := velocity.normalized()
		var dot := normal.dot(my_direction)
		if dot < -0.7:
			forward_velocity = 0

	deal_with_gas(delta)
	deal_with_grass(delta)
	deal_with_car_wheel(delta)

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
		if forward_velocity == 0 and gas_remaining < gas_max:
			gas_remaining += gas_station.fill_rate * delta
			add_money(-gas_station.cost * delta)
			if not gas_station.pump_stream.playing:
				gas_station.pump_stream.play()
		else:
			if gas_station.pump_stream.playing:
				gas_station.pump_stream.stop()
				gas_station.bell_stream.play()

func deal_with_grass(_delta: float) -> void:
	if raycast.is_colliding():
		#print("Colliding with: ", raycast.get_collider())
		on_grass = false
	else:
		#print("Off road")
		on_grass = true

func deal_with_car_wheel(delta: float) -> void:
	var wheel := get_node("InteriorRoot/CarInterior/car_wheel") as Node3D
	var target_rotation := -turn_angle * 0.5 * 180/PI
	var current_rotation := wheel.rotation_degrees.z
	var new_rotation := lerpf(current_rotation, target_rotation, delta * 5.0)
	#print("new rot: ", new_rotation)
	wheel.rotation_degrees.z = new_rotation

func add_money(value: float) -> void:
	money += value
	hud.bank_view.set_money(money)
	if value > 0:
		points += (value * 100) as int

func add_rating(value: int) -> void:
	rating += value
	rating = clampi(rating, 0, 5)
	hud.phone_display.set_rating(rating)

func house_area_entered(house: House) -> void:
	var orders_to_remove: Array[Order]
	for order in active_orders:
		if order.status == Order.Status.STARTED and order.pickup_address == house.name:
			pickup_order.emit(order)
			$ToneBStream.play()
		elif order.status == Order.Status.PICKED_UP and order.destination_address == house.name:
			deliver_order.emit(order)
			order_success_stream.play()
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
	if timed_out_orders.size() > 0:
		$ToneFailStream.play()
