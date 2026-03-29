extends Node3D

var needle_angle_empty: float = -60.0
var needle_angle_full: float = 60.0

var blink_timer: float = 0.0
var blink_state: bool = false
var last_perc: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player := get_node("/root/World/Player") as Player

	var perc : float = player.gas_remaining / player.gas_max
	rotation_degrees = Vector3(0, 0, needle_angle_empty + perc * (needle_angle_full - needle_angle_empty))

	var gas_light := get_node("../gas_light") as Sprite3D
	if perc < 0.2:
		if last_perc > 0.2 or (last_perc > 0.1 and perc < 0.1):
			$"../LowFuelStream".play()
		gas_light.modulate = Color(1.0, 0.0, 0.0)
		blink_timer += _delta
		if blink_timer >= 0.5:
			blink_timer = 0.0
			blink_state = not blink_state
		gas_light.visible = blink_state
	else:
		gas_light.modulate = Color(0.0, 1.0, 0.0)
		gas_light.visible = true
	last_perc = perc
