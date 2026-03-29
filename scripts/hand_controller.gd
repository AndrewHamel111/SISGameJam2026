class_name HandController
extends Control

@onready var texrect_back: TextureRect = $TextureRect
@onready var texrect_front: TextureRect = $TextureRect2
@onready var hand_library: HandLibrary = preload("res://resources/andrew_hand.tres")

@export var touch_offset: float = 30.0
@export var touch_rotation_deg: float = 10.0

enum Pose
{
	TOP = 0,
	MIDDLE,
	BOTTOM,
	SWIPE_LEFT,
	SWIPE_RIGHT
}

var swipe_anim: Pose = Pose.TOP
var anim_frame: int = 0

func set_pose(pose: Pose) -> void:
	match pose:
		Pose.TOP:
			texrect_back.texture = hand_library.top_back
			texrect_front.texture = hand_library.top_front
		Pose.MIDDLE:
			texrect_back.texture = hand_library.middle_back
			texrect_front.texture = hand_library.middle_front
		Pose.BOTTOM:
			texrect_back.texture = hand_library.bottom_back
			texrect_front.texture = hand_library.bottom_front
		Pose.SWIPE_LEFT:
			swipe_anim = pose
			anim_frame = 0
			next_swipe_frame()
		Pose.SWIPE_RIGHT:
			swipe_anim = pose
			anim_frame = 3
			next_swipe_frame()

func next_swipe_frame() -> void:
	if anim_frame == 4 or anim_frame == -1:
		set_pose(Pose.MIDDLE)
		return
	texrect_back.texture = hand_library.swipe_back[anim_frame]
	texrect_front.texture = hand_library.swipe_front[anim_frame]
	anim_frame += 1 if swipe_anim == Pose.SWIPE_LEFT else -1
	get_tree().create_timer(0.05).timeout.connect(next_swipe_frame)

func set_pressed(pressed: bool) -> void:
	if pressed:
		texrect_front.position = Vector2(texrect_front.position.x - touch_offset, texrect_front.position.y)
		texrect_front.rotation_degrees -= touch_rotation_deg
	else:
		texrect_front.position = Vector2(texrect_front.position.x + touch_offset, texrect_front.position.y)
		texrect_front.rotation_degrees += touch_rotation_deg
