class_name OrderDisplay
extends ColorRect

@onready var order_name: Label = $OrderName
@onready var order_destination: Label = $OrderDestination
@onready var order_value: Label = $Value
@onready var order_duration: Label = $Duration

var order: Order
var _name: String
var desc: String
var money: String
var duration: String
var duration_float: float

var ticking := false

func _process(delta: float) -> void:
	if not ticking:
		return
	
	duration_float -= delta
	if duration_float as int % 60 != 0:
		order_duration.text = "%dm %ds" % [(duration_float as int / 60), (duration_float as int % 60)]
	else:
		order_duration.text = "%dm" % [(duration_float as int / 60)]
	if duration_float < 30.0:
		var red := lerpf(0, 1.0, 1.0 - (duration_float / 30.0))
		order_duration.set_indexed("modulate:r", red)

func start_order_timer() -> void:
	ticking = true

func set_order(value: Order) -> void:
	order = value
	
	var address := "%d %s\n%d %s" % \
		[order.pickup_street_number, order.pickup_street_name, \
		order.destination_street_number, order.destination_street_name]
	set_details(order.name, address, order.value, order.duration)

func set_details(title: String, address: String, value: float, time: float) -> void:
	_name = title
	desc = address
	money = "$%.2f" % [value]
	duration_float = time
	if time as int % 60 != 0:
		duration = "%dm %ds" % [(time as int / 60), (time as int % 60)]
	else:
		duration = "%dm" % [(time as int / 60)]

func _ready() -> void:
	order_name.text = _name
	order_destination.text = desc
	order_value.text = money
	order_duration.text = duration
	order_duration.modulate = Color(0,0,0)
