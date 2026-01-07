class_name Alien
extends CharacterBody2D


const AVG_SPEED := 175.0

var direction := Vector2.from_angle(randf_range(0, TAU))
var speed := randfn(AVG_SPEED, 50)

@onready var sprite: Sprite2D = $Sprite


func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	move_and_slide()


func _on_change_velocity_timeout() -> void:
	direction = direction.rotated(randf_range(0, PI / 2))


func get_width() -> float:
	return sprite.get_rect().size.x
