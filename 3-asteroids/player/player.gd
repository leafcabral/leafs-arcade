class_name Player
extends CharacterBody2D


const MOVEMENT_SPEED := 350.0
const TURN_SPEED := TAU

@onready var initial_posiiton: Vector2 = position
@onready var viewport_size: Vector2 = get_viewport_rect().size
@onready var sprite_size: Vector2 = $MainSprite.get_rect().size * scale

@onready var collision_shape: CollisionPolygon2D = $CollisionShape
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2
@onready var health_component: HealthComponent = $HealthComponent
@onready var shot_component: ShotComponent = $ShotComponent


func _ready() -> void:
	$WrapScreenComponent.border_offset = sprite_size / 2


func _physics_process(delta: float) -> void:
	var turn_direction := Input.get_axis("turn_left", "turn_right")
	rotation += turn_direction * TURN_SPEED * delta
	
	var acceleration := MOVEMENT_SPEED * delta
	var direction := Vector2.from_angle(rotation)
	if Input.is_action_pressed("thurster"):
		var max_velocity := direction * MOVEMENT_SPEED
		velocity = velocity.move_toward(max_velocity, acceleration)
		
		if not animation_player.current_animation == "moving":
			animation_player.play("moving")
	else:
		velocity = velocity.move_toward(Vector2(), acceleration / 2)
		
		animation_player.play("RESET")
	
	move_and_slide()
	handle_collisions()
	
	if Input.is_action_pressed("shoot"):
		shot_component.shot(direction)


func handle_collisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider: Node = collision.get_collider()
		
		if not collider.is_in_group("Player"):
			health_component.take_damage()


func take_damage(_damage: float) -> void:
	set_physics_process(false)
	animation_player.play("respawn")
	await animation_player.animation_finished
	animation_player_2.play("invincible")
	
	set_physics_process(true)
	await health_component.invincibility_ended
	animation_player_2.play("RESET")


func respawn() -> void:
	position = initial_posiiton
	velocity = Vector2()


func get_max_health() -> int:
	return health_component.MAX_HEALTH


func get_health() -> float:
	return health_component.health
