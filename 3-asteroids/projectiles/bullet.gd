class_name Bullet
extends Area2D


var lifetime := 2.0
var velocity := Vector2()

@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var death_time_explosion: GPUParticles2D = $DeathTimeExplosion


func _ready() -> void:
	lifetime_timer.start(lifetime)


func _physics_process(delta: float) -> void:
	position += velocity * delta


func _on_lifetime_timer_timeout() -> void:
	suicide()


func suicide() -> void:
	$Sprite.visible = false
	$CollisionShape.disabled = true
	death_time_explosion.emitting = true
	await death_time_explosion.finished
	queue_free()
	
