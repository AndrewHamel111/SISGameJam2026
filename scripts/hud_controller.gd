class_name HUDController
extends Control

@onready var label_2: Label = $SpeedDisplay/Label2
@onready var label: Label = $SpeedDisplay/Label
@onready var phone_display: PhoneDisplay = $PhoneDisplay
@onready var hand_controller: HandController = $PhoneDisplay/HandController
@onready var bank_view: BankView = $PhoneDisplay/TextureRect/BankView
@onready var map_view: Minimap = $PhoneDisplay/TextureRect/MapView

func set_speed(speed: int) -> void:
	label.text = "%d MPH" % [speed]
	label_2.text = "%d MPH" % [speed]
