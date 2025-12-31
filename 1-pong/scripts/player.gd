extends CharacterBody2D

const SPEED := 800.0
@export var type: Global.Type
var ball_follow: Ball
var screen_size: Vector2
var inital_position: Vector2
var size: Vector2
var direction: float

func _ready() -> void:
	inital_position = position
	screen_size = get_viewport().size
	size = $CollisionShape.shape.get_rect().size


func _physics_process(_delta: float) -> void:
	direction = get_direction()
	if direction:
		velocity.y = direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
	position = Global.clamp_position_to_screen(position, size, screen_size)


func get_direction() -> float:
	if type == Global.Type.PLAYER:
		var suffix := "p1" if name == "Player 1" else "p2"
		return Input.get_axis("move_up_"+ suffix, "move_down_" + suffix)
	else:
		var distance := ball_follow.position - position
		return distance.normalized().y
