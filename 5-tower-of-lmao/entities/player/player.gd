extends CharacterBody2D


@export_range(1, 2, 0.01, "or_greater") var strech_scale := 1.3

@onready var sprite: Sprite2D = $Sprite2D
@onready var sprite_original_scale := sprite.scale
@onready var movement_controller: PlatformerMovement2D = $PlatformerMovement2D


func _physics_process(delta: float) -> void:
	sprite.scale = sprite.scale.move_toward(sprite_original_scale, delta * strech_scale)


func _on_platformer_movement_2d_jumped() -> void:
	sprite.scale = sprite_original_scale
	sprite.scale.y *= strech_scale
	sprite.scale.x /= strech_scale


func _on_platformer_movement_2d_hit_floor() -> void:
	sprite.scale = sprite_original_scale
	sprite.scale.y /= strech_scale
	sprite.scale.x *= strech_scale
