class_name HealthComponent
extends Node
## Plug and Play component that gives its parent node health and a way to take
## damage and die (when health drops to 0 or less)
## 
## If the parent node does not have a [code]die()[/code] method, it will
## fallback to [code]queue_free()[/code]


@export var MAX_HEALTH := 3
@export var should_free_after_death := true

var health: float

@onready var parent := get_parent()


func _ready() -> void:
	health = MAX_HEALTH


func take_damage(damage: float = 1.0) -> void:
	health -= damage
	if parent.has_method("take_damage"):
		parent.take_damage(damage)
	
	if health <= 0 and parent.has_method("die"):
		parent.die()
	elif should_free_after_death:
		parent.queue_free()
