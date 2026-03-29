class_name Order
extends Node

@export var id: int
@export var status: Status = Status.PENDING

@export var pickup_address: String
@export var pickup_street_number: int
@export var pickup_street_name: String

@export var destination_address: String
@export var destination_street_number: int
@export var destination_street_name: String

## reward for successfully completing the order
@export var value: float
## duration in seconds
@export var duration: float
@export var start_time: float

enum Status
{
	PENDING = 0,
	STARTED,
	PICKED_UP,
	COMPLETED,
	FAILED
}

func is_expired() -> bool:
	return (Time.get_ticks_msec() - start_time) / 1000 > duration
