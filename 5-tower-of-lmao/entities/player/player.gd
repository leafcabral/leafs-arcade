class_name Player
extends CharacterBody2D


signal died

@export_range(1, 2, 0.01, "or_greater") var strech_scale := 1.3
@export_range(0, 1, 0.01, "or_greater") var strech_restore_seconds := 0.1
@export_range(0, 1, 0.001, "or_greater") var low_stamina_ticking_time := 0.1
var is_climbing := false

@onready var sprite: AnimatedSprite2D = $Sprites
@onready var sprite_original_scale := sprite.scale
@onready var cape: ClothTrailComponent = $ClothTrailComponent
@onready var movement_controller: PlatformerMovement2D = $PlatformerMovement2D
@onready var wall_movement: WallMovementComponent = $WallMovementComponent
@onready var normal_collision_box: CollisionShape2D = $NormalCollisionBox
@onready var crouch_collision_box: CollisionShape2D = $CrouchCollisionBox
@onready var low_stamina_ticking: Timer = $LowStaminaTicking


func _process(delta: float) -> void:
	restore_strech(delta * strech_scale / strech_restore_seconds)
	update_sprite_animation()
	update_direction()
	if is_low_stamina():
		if low_stamina_ticking.is_stopped():
			low_stamina_ticking.start(low_stamina_ticking_time)
	else:
		low_stamina_ticking.stop()
		reset_low_stamina_animation()


func _physics_process(delta: float) -> void:
	if not is_climbing:
		velocity = movement_controller.process_physics(delta)
	else:
		velocity = wall_movement.process_physics(delta)
	move_and_slide()
	
	_check_hazard_collisions()


func update_sprite_animation() -> void:
	if movement_controller.is_airbourne:
		sprite.play("jump")
	elif velocity.x and movement_controller.is_crouching:
		sprite.play("crouch-walk")
	elif velocity.x:
		sprite.play("walk")
	elif movement_controller.is_crouching:
		sprite.play("crouch")
	else:
		sprite.play("idle")
	


func update_direction() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
		wall_movement.flip_h = false
		cape.position.x = abs(cape.position.x)
	elif velocity.x < 0:
		sprite.flip_h = true
		wall_movement.flip_h = true
		cape.position.x = - abs(cape.position.x)


func strech_sprite(x_amount: float) -> void:
	sprite.scale = sprite_original_scale * Vector2(x_amount, 1 / x_amount)


func restore_strech(by: float) -> void:
	sprite.scale = sprite.scale.move_toward(sprite_original_scale, by)


func is_low_stamina() -> bool:
	return wall_movement.stamina < 50


func reset_low_stamina_animation() -> void:
	var shader_material := material as ShaderMaterial
	shader_material.set_shader_parameter("activated", false)


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
	strech_sprite(1 / strech_scale)


func _on_platformer_movement_2d_hit_floor() -> void:
	strech_sprite(strech_scale)


func _on_platformer_movement_2d_got_up() -> void:
	cape.modulate = Color.WHITE
	sprite.modulate = Color.WHITE
	normal_collision_box.set_deferred("disabled", false)
	await get_tree().process_frame
	crouch_collision_box.set_deferred("disabled", true)


func _on_platformer_movement_2d_crouched() -> void:
	crouch_collision_box.set_deferred("disabled", false)
	await get_tree().process_frame
	normal_collision_box.set_deferred("disabled", true)


func _on_platformer_movement_2d_crouch_jump_charged() -> void:
	cape.modulate = Color.GREEN
	sprite.modulate = Color.GREEN


func _on_wall_movement_component_started_climbing() -> void:
	is_climbing = true


func _on_wall_movement_component_stopped_climbing() -> void:
	is_climbing = false


func _on_low_stamina_ticking_timeout() -> void:
	var shader_material := material as ShaderMaterial
	var will_be_active: bool = not shader_material.get_shader_parameter("activated")
	
	shader_material.set_shader_parameter("activated", will_be_active)
	if will_be_active:
		low_stamina_ticking.start(low_stamina_ticking_time / 2)
	else:
		low_stamina_ticking.start(low_stamina_ticking_time)
	
