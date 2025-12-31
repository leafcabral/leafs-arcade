class_name Bird
extends CharacterBody2D


signal left_screen(emitter: Bird)


@export var speed := 350.0
@export var speed_deviation := Vector2(-50, 100)

var direction := Vector2.UP
var state: Global.BirdState

@onready var _animated_sprite = $AniSprites
@onready var collision_shape := $CollisionShape


func _ready() -> void:
	state = Global.BirdState.ALIVE
	speed += randf_range(speed_deviation.x, speed_deviation.y)
	randomize_direction()


func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		velocity = direction * speed * delta
		
		if state == Global.BirdState.ALIVE:
			handle_collision()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, delta)
	
	move_and_collide(velocity)
	update_animation()


func handle_collision() -> void:
	var collision := move_and_collide(velocity, true)
	if collision:
		direction = collision.get_normal()
		randomize_direction()


func update_animation() -> void:
	match state:
		Global.BirdState.ALIVE:
			_animated_sprite.play(
				"fly-side" if direction.y > 0
				else "fly-up"
			)
			_animated_sprite.flip_h = direction.x < 0
		Global.BirdState.JUST_SHOT:
			_animated_sprite.play("shot")
		Global.BirdState.DEAD:
			_animated_sprite.play("fall")
		Global.BirdState.FLEE:
			_animated_sprite.play("fly-up")
			_animated_sprite.flip_h = direction.x < 0


func randomize_position(position_mean: Vector2, deviation: Vector2) -> void:
	self.position = Vector2(
		randfn(position_mean.x, deviation.x),
		randfn(position_mean.y, deviation.y)
	)


func randomize_direction():
	direction = direction.rotated(randf_range(-PI, PI) / 3)


func get_rect() -> Rect2:
	var rect: Rect2 = collision_shape.shape.get_rect()
	rect.size *= scale * collision_shape.scale
	rect.position += position - rect.size/2
	return rect


func is_hittable_at(pos: Vector2) -> bool:
	return get_rect().has_point(pos) and state == Global.BirdState.ALIVE


func get_shot():
	collision_shape.disabled = true
	velocity = Vector2.ZERO
	
	state = Global.BirdState.JUST_SHOT
	direction = Vector2.ZERO
	await get_tree().create_timer(1).timeout
	state = Global.BirdState.DEAD
	direction = Vector2.DOWN


func flee():
	if state == Global.BirdState.ALIVE:
		collision_shape.disabled = true
		state = Global.BirdState.FLEE
		
		direction = Vector2.UP
		randomize_direction()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	left_screen.emit(self)
