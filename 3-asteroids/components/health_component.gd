class_name HealthComponent
extends Node
## Plug and Play component that gives its parent node health and a way to take
## damage and die (when health drops to 0 or less)
## 
## If the parent node does not have a [code]die()[/code] method, it will
## fallback to [code]queue_free()[/code]


signal took_damage(damage)
signal invincibility_ended
signal died


@export_range(1, 10, 1, "or_greater") var MAX_HEALTH := 3
@export_range(0, 5, 0.1, "suffix:s") var invincibility_time := 0.5
@export var should_free_after_death := false

var health: float

@onready var parent := get_parent()
@onready var hit_cooldown := Timer.new()


func _ready() -> void:
	health = MAX_HEALTH
	
	add_child(hit_cooldown)
	hit_cooldown.timeout.connect(func(): invincibility_ended.emit())
	hit_cooldown.one_shot = true


func take_damage(damage: float = 1.0) -> void:
	if not is_invincible():
		health -= damage
		took_damage.emit(damage)
		
		make_invincible()
		
		if parent.has_method("take_damage"):
			parent.take_damage(damage)
	
	if is_dead():
		died.emit()
		
		if parent.has_method("die"):
			parent.die()
		if should_free_after_death:
			parent.queue_free()


func is_invincible() -> bool:
	return not hit_cooldown.is_stopped()


func make_invincible(time: float = invincibility_time) -> void:
	hit_cooldown.start(time)

func is_dead() -> bool:
	return health <= 0
