extends PathFollow3D

@export var speed := 5.0
@export var initial_progress := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var path := get_parent() as Path3D
	#var mesh := get_node("MeshInstance3D") as MeshInstance3D
	#if path:
		#var local_position := path.to_local(mesh.global_transform.origin)
		#var closest_offset := path.curve.get_closest_offset(local_position)
		#progress = closest_offset
	progress = initial_progress

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress += speed * delta
