extends CharacterBody2D
class_name Ball


signal exited_screen


const MAX_SPEED := 1200.0
const INCREMENT := 10.0

@export_range(0, MAX_SPEED, 1) var speed := 600.0

var direction := Vector2.ZERO
var inital_position: Vector2
var size: Vector2
var screen_size: Vector2

@onready var border_collision_player: AudioStreamPlayer = $BorderCollisionPlayer
@onready var player_collision_player: AudioStreamPlayer = $PlayerCollisionPlayer


func _ready() -> void:
	inital_position = position
	screen_size = get_viewport().size
	size = $CollisionShape.shape.get_rect().size
	new_game()


func _process(_delta: float) -> void:
	if is_visible_in_tree():
		hide()
	else:
		show()


func _physics_process(delta: float) -> void:
	velocity = direction * speed
	var frame_velocity := velocity * delta
	
	var collision := move_and_collide(frame_velocity, true)
	if collision:
		var collider := collision.get_collider()
		
		if collider.is_in_group("Paddles"):
			# Y_distance between center of ball from paddle
			# Normalized to -1 to 1
			var y_distance: float = clamp(remap(
				position.y - collider.position.y,
				-collider.size.y/2, collider.size.y/2,
				-1, 1
			), -1, 1)
			direction.x *= -1
			direction.y += y_distance / 2 # Affect but not too much
			direction = direction.normalized()
			
			speed = clamp(speed + INCREMENT, 0, MAX_SPEED)
			
			var x_offset: float = collider.size.x / 3
			position.x += x_offset if collider.position.x < position.x else -x_offset
			
			player_collision_player.play()
		else:
			direction = direction.bounce(collision.get_normal())
			border_collision_player.play()
	move_and_collide(frame_velocity)
	check_if_outside_screen()
	position.y = Global.clamp_position_to_screen(position, size, screen_size).y


func new_game():
	set_physics_process(false)
	set_process(true)
	hide()
	
	position = inital_position
	direction = Vector2.from_angle(randf_range(PI - PI/4, PI + PI/4))
	await get_tree().create_timer(1).timeout
	
	set_physics_process(true)
	set_process(false)
	show()


func check_if_outside_screen():
	var ball_rect: Rect2 = $CollisionShape.shape.get_rect()
	ball_rect.position += position
	if not ball_rect.intersects(get_viewport_rect()):
		exited_screen.emit()
