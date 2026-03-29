extends PathFollow3D

@export var speed := 5.0
@export var initial_progress := 0.0
@export var reverse := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var path := get_parent() as Path3D
	#var mesh := get_node("MeshInstance3D") as MeshInstance3D
	#if path:
		#var local_position := path.to_local(mesh.global_transform.origin)
		#var closest_offset := path.curve.get_closest_offset(local_position)
		#progress = closest_offset
	#progress = initial_progress
	progress_ratio = randf()
	reverse = randi_range(0,1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if reverse:
		progress -= speed * delta
		h_offset = -2
	else:
		progress += speed * delta
		h_offset = 0

	# Complete hack, the cars would eventually start following the path below ground if this isn't here.
	var body := get_node("RigidBody3D") as RigidBody3D
	body.global_position.y = 0
