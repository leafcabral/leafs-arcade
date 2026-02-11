@tool
class_name WallMovementComponent
extends RayCast2D


signal started_climbing
signal stopped_climbing

const DEFAULT_DIRECTION := Vector2.RIGHT

@export var disabled := false

@export_group("Input", "input_")
@export var input_move_left := &"move_left"
@export var input_move_right := &"move_right"
@export var input_climb := &"climb"
@export var input_move_up := &"move_up"
@export var input_move_down := &"move_down"
@export var input_jump := &"jump"

@export_group("Wall Jump", "wall_jump_")
@export_range(0, 1000, 0.1, "or_greater") var wall_jump_horizontal_force := 300.0

var jump_pressed_while_climbing := false
@export_range(0, 128, 0.1) var length := 64.0:
	set(value):
		length = value
		target_position = target_position.normalized() * length
@export var flip_h := false:
	set(value):
		flip_h = value
		target_position.x = absf(target_position.x)
		if flip_h:
			target_position.x *= -1
@export_range(0, 1000, 0.1, "or_greater") var max_speed := 250.0
@export var movement_controller: PlatformerMovement2D

var velocity := Vector2.ZERO
var is_active := false
var parent: CharacterBody2D


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not parent is CharacterBody2D:
		warnings.append(
			"WallMovementComponent only serves to provide wall movement for a CharacterBody2D derived node.
			Please, only use it as a child of CharacterBody2D to make it move."
		)
		
	return warnings


func _enter_tree() -> void:
	parent = get_parent()
	update_configuration_warnings()


func _ready() -> void:
	target_position = DEFAULT_DIRECTION * length
	collision_mask = parent.collision_mask


func _physics_process(_delta: float) -> void:
	if should_climb():
		if not is_active:
			is_active = true
			started_climbing.emit()
	else:
		if is_active:
			is_active = false
			stopped_climbing.emit()


func should_climb() -> bool:
	return (
		is_colliding() and (
			(Input.is_action_pressed(input_climb) and not movement_controller.is_jumping)
			or Input.is_action_just_pressed(input_climb)
		)
	)


func process_physics(delta: float) -> Vector2:
	if disabled and not is_active:
		return Vector2.ZERO
	
	if Input.is_action_just_pressed(input_jump):
		movement_controller.jump()
		if Input.is_action_pressed(input_move_right if flip_h else input_move_left):
			movement_controller.velocity.x = (
				wall_jump_horizontal_force if flip_h
				else - wall_jump_horizontal_force 
			)
		velocity = Vector2.ZERO
		
		return movement_controller.velocity
	
	if Input.is_action_pressed(input_move_up) and can_move_up(delta):
		velocity.y = - max_speed
	elif Input.is_action_pressed(input_move_down) and can_move_down(delta):
		velocity.y = max_speed
	else:
		velocity.y = 0
	
	return velocity


func can_move_up(delta: float) -> bool:
	return _test_if_offset_colliding(-max_speed * delta)


func can_move_down(delta: float) -> bool:
	return _test_if_offset_colliding(max_speed * delta)


func _test_if_offset_colliding(y_offset: float) -> bool:
	var result: bool
	
	position.y += y_offset
	force_raycast_update()
	result = is_colliding()
	position.y -= y_offset
	force_raycast_update()
	
	return result
