@tool
class_name GolfBall
extends RigidBody2D


signal stopped_moving
signal started_moving

@export var stop_color := Color("34dda9")

var _should_teleport := false
var _teleport_pos := Vector2.ZERO

@onready var collision_shape: CollisionShape2D = $CollisionShape


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _should_teleport:
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		state.transform.origin = _teleport_pos
		
		_should_teleport = false


func teleport(new_position: Vector2, from_center := true) -> void:
	_should_teleport = true
	_teleport_pos = new_position
	if not from_center: 
		_teleport_pos -= Vector2(0, get_radius())
	sleeping = false


func get_radius() -> float:
	return collision_shape.shape.radius if collision_shape else 0.0


func _on_sleeping_state_changed() -> void:
	if sleeping:
		stopped_moving.emit()
	else:
		started_moving.emit()
