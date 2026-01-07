class_name Bullet
extends Area2D


var lifetime := 2.0
var velocity := Vector2()
var emitter: Node2D
var emitter_type: StringName

@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var death_time_explosion: GPUParticles2D = $DeathTimeExplosion
@onready var death_collision_explosion: GPUParticles2D = $DeathCollisionExplosion


func _ready() -> void:
	lifetime_timer.start(lifetime)
	
	emitter_type = emitter.get_script().get_global_name()


func _physics_process(delta: float) -> void:
	position += velocity * delta


func _on_lifetime_timer_timeout() -> void:
	delete_itself()


func delete_itself(with_collision := false) -> void:
	$Sprite.visible = false
	$CollisionShape.set_deferred("disabled", true)
	if with_collision:
		death_collision_explosion.emitting = true
		await death_collision_explosion.finished
	else:
		death_time_explosion.emitting = true
		await death_time_explosion.finished
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	var body_script: Script = body.get_script()
	if body_script:
		if body_script.get_global_name() != emitter_type:
			if body.has_node("HealthComponent"):
				body.get_node("HealthComponent").take_damage()
				delete_itself(true)
