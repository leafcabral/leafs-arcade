class_name Alien
extends CharacterBody2D


signal alien_hit(alien: Alien)


const AVG_SPEED := 175.0

var direction := Vector2.from_angle(randf_range(0, TAU))
var speed := randfn(AVG_SPEED, 50)

@onready var sprite: Sprite2D = $Sprite
@onready var health_component: HealthComponent = $HealthComponent
@onready var shot_component: ShotComponent = $ShotComponent
@onready var death_effect: GPUParticles2D = $DeathEffect
@onready var collision_shape: CollisionShape2D = $CollisionShape


func _ready() -> void:
	shoot_rand_angle()


func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	move_and_slide()
	
	handle_collisions()


func shoot_rand_angle() -> void:
	shot_component.shot(Vector2.from_angle(randf_range(0, TAU)))


func handle_collisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider: Node = collision.get_collider()
		
		if collider is Asteroid:
			direction = direction.bounce(collision.get_normal())


func _on_change_velocity_timeout() -> void:
	direction = direction.rotated(randf_range(0, PI / 2))


func get_width() -> float:
	return sprite.get_rect().size.x


func _on_shot_component_finished_reloading() -> void:
	shoot_rand_angle()


func take_damage(_damage: float) -> void:
	alien_hit.emit(self)


func die() -> void:
	sprite.hide()
	collision_shape.set_deferred("disabled", true)
	death_effect.emitting = true
	
	await death_effect.finished
	queue_free()
