class_name Order
extends Node

@export var id: int

@export var pickup_street_number: int
@export var pickup_street_name: String

@export var destination_street_number: int
@export var destination_street_name: String

## reward for successfully completing the order
@export var value: float
## duration in seconds
@export var duration: float
