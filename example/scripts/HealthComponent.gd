class_name HealthComponent
extends Node

signal health_changed(health: int, max_health: int)

var _health: int
var _max_health: int

func _ready():
	health_changed.emit(_health, _max_health)

func set_health(value: int) -> void:
	_health = clamp(value, 0, _max_health)
	health_changed.emit(_health, _max_health)

func set_max_health(value: int) -> void:
	_max_health = value
	if _health > _max_health:
		_health = _max_health
	
	health_changed.emit(_health, _max_health)

func add_health(amount: int) -> void:
	set_health(_health + amount)
