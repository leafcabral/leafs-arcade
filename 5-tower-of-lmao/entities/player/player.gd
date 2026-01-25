#@tool
extends CharacterBody2D


@export_range(0, 1000, 0.1, "or_greater") var max_speed := 600.0
@export_range(0, 5, 0.01, "or_greater") var time_to_accelerate := 0.3
@export_range(0, 5, 0.01, "or_greater") var time_to_decelerate := 0.0
@export var change_direction_at_same_speed := true
@export_group("Vertical Movement")
@export_range(-10, 10, 0.01) var gravity_multiplier := 1.0
@export var jump_height := 400.0
@export var jump_duration := 0.7
@export_range(0, 1, 0.01) var small_jump_multiplier := 0.5
@export var jump_buffer_total := 0.1
@export var coyote_jump_time := 0.1

var jump_buffer := 0.0
var coyote_jump := 0.0


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_handle_horizontal_movement(delta)
	_handle_vertical_movement(delta)
	
	move_and_slide()


func _handle_horizontal_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var delta_speed := max_speed * delta
	if signf(direction) == signf(velocity.x):
		velocity.x = move_toward(velocity.x, direction * max_speed, delta_speed / time_to_accelerate)
	elif direction and velocity.x and change_direction_at_same_speed:
		velocity.x = - velocity.x
	else:
		velocity.x = move_toward(velocity.x, direction * max_speed, delta_speed / time_to_decelerate)


func _handle_vertical_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta
	
	if Input.is_action_pressed("jump"):
		jump_buffer = jump_buffer_total
	if is_on_floor():
		coyote_jump = coyote_jump_time
	if (jump_buffer > 0 and is_on_floor()) or (coyote_jump > 0 and Input.is_action_just_pressed("jump")):
			velocity.y = - 2 * jump_height * jump_duration
			jump_buffer = 0
			coyote_jump = 0
	elif Input.is_action_just_released("jump") and velocity.y <= 0:
		velocity.y *= small_jump_multiplier
	
	if jump_buffer > 0:
		jump_buffer = max(0, jump_buffer - delta)
	if coyote_jump > 0:
		coyote_jump = max(0, coyote_jump - delta)
