class_name Player
extends CharacterBody2D


signal died

@export_range(1, 2, 0.01, "or_greater") var strech_scale := 1.3
@export_range(0, 1, 0.01, "or_greater") var strech_restore_seconds := 0.1

@onready var sprite: AnimatedSprite2D = $Sprites
@onready var sprite_original_scale := sprite.scale
@onready var cape: ClothTrailComponent = $ClothTrailComponent
@onready var movement_controller: PlatformerMovement2D = $PlatformerMovement2D


func _physics_process(delta: float) -> void:
	sprite.scale = sprite.scale.move_toward(
		sprite_original_scale,
		delta * strech_scale / strech_restore_seconds
	)
	update_sprite_animation()
	
	_check_hazard_collisions()


func update_sprite_animation() -> void:
	if velocity.y:
		sprite.play("jump")
	elif velocity.x:
		sprite.play("walk")
	else:
		sprite.play("idle")
		
	if velocity.x > 0:
		sprite.flip_h = false
		cape.position.x = abs(cape.position.x)
	elif velocity.x < 0:
		sprite.flip_h = true
		cape.position.x = - abs(cape.position.x)


func _check_hazard_collisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is TileMapLayer:
			var tilemap := collider as TileMapLayer
			var map_pos := tilemap.local_to_map(
				tilemap.to_local(collision.get_position())
			)
			var tile_data := tilemap.get_cell_tile_data(map_pos)
			
			if tile_data and tile_data.get_custom_data("Hazard"):
				died.emit()


func _on_platformer_movement_2d_jumped() -> void:
	sprite.scale = sprite_original_scale
	sprite.scale.y *= strech_scale
	sprite.scale.x /= strech_scale


func _on_platformer_movement_2d_hit_floor() -> void:
	sprite.scale = sprite_original_scale
	sprite.scale.y /= strech_scale
	sprite.scale.x *= strech_scale
