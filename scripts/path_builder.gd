extends Path3D

@export var num_cars : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_curve : Curve3D = Curve3D.new()
	new_curve.closed = true
	new_curve.clear_points()
	var i := 1
	while true:
		var point_name := "point%d" % i
		if has_node(point_name):
			var mesh := get_node(point_name) as MeshInstance3D
			new_curve.add_point(mesh.global_transform.origin)
			mesh.visible = false
			i += 1
		else:
			break
	self.set("curve", new_curve)

	var traffic_resource := preload("res://scenes/traffic_car.tscn")
	for j in range(num_cars):
		var traffic_instance := traffic_resource.instantiate()
		add_child(traffic_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
