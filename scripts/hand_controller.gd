class_name HandController
extends Control

@onready var texrect_back: TextureRect = $TextureRect
@onready var texrect_front: TextureRect = $TextureRect2
@onready var hand_library: HandLibrary = preload("res://resources/andrew_hand.tres")

enum Pose
{
	TOP = 0,
	MIDDLE,
	BOTTOM,
	#SWIPE_LEFT,
	#SWIPE_RIGHT
}

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
		#Pose.SWIPE_LEFT:
			## TODO: start quick left-swipe animation
			#pass
		#Pose.SWIPE_RIGHT:
			## TODO: start quick right-swipe animation
			#pass
