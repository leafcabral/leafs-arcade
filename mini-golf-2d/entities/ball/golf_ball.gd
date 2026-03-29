@tool
class_name GolfBall
extends RigidBody2D


signal stopped_moving
signal started_moving

enum NextAction {
	NONE,
	RESET_LAST,
	RESET_START,
}

@export var stop_color := Color("34dda9")

var next_action := NextAction.NONE
var pos_start := Vector2.ZERO
var pos_last := Vector2.ZERO

@onready var ball_sprite: Sprite2D = $BallSprite


func _ready() -> void:
	pos_start = position
	pos_last = pos_start


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_last"):
		next_action = NextAction.RESET_LAST
		sleeping = false
	if event.is_action_pressed("reset_start"):
		next_action = NextAction.RESET_START
		sleeping = false


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if next_action != NextAction.NONE:
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		
		match next_action:
			NextAction.RESET_LAST:
				position = pos_last
			NextAction.RESET_START:
				position = pos_start
		
		next_action = NextAction.NONE


func _on_sleeping_state_changed() -> void:
	if sleeping:
		stopped_moving.emit()
		ball_sprite.modulate = stop_color
		pos_last = position
	else:
		started_moving.emit()
		ball_sprite.modulate = Color.WHITE
