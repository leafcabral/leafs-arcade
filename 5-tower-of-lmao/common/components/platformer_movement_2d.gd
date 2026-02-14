@tool
@icon("res://common/components/platformer_movement_2d.png")
class_name PlatformerMovement2D
extends Movement2D


signal jumped
signal hit_floor
signal crouched
signal got_up
signal crouch_jump_charged

@export var input_jump := &"jump"

@export_group("Horizontal Movement")
@export_range(0, 1000, 0.1, "or_greater") var max_speed := 600.0
@export_range(0, 5, 0.01, "or_greater") var acceleration_time := 0.1
@export_range(0, 5, 0.01, "or_greater") var deceleration_time := 0.05

@export_group("Vertical Movement")
@export_range(0, 1000, 0.1, "or_greater") var jump_height := 64.0
@export_range(0, 2, 0.01, "or_greater") var time_to_peak := 0.3
@export_range(0, 2, 0.01, "or_greater") var time_to_fall := 0.3
@export_range(0, 5000, 0.1, "or_greater") var terminal_falling_velocity := 2000.0
@export var hold_to_jump := false

@export_group("Crouching")
@export_range(0, 1, 0.01) var crouching_speed_scale := 0.5
@export_range(0, 3, 0.01, "or_greater") var crouch_jump_delay_max := 0.5
@export_range(1, 2, 0.1, "or_greater") var crouch_jump_scale := 1.0
@export_range(0, 2, 0.01, "or_greater") var crouch_jump_buffer_max := 0.1

@export_group("Quality of Life")
@export_range(0, 1, 0.01) var variable_jump_scale := 0.5
@export_range(0, 5, 0.01, "or_greater") var jump_buffer_max := 0.1
@export_range(0, 5, 0.01, "or_greater") var coyote_jump_buffer_max := 0.1

var crouch_jump_ready := false

var jump_buffer := 0.0
var coyote_jump_buffer := 0.0
var crouch_jump_buffer := 0.0

var crouch_jump_delay := 0.0

var is_walking := false
var is_jumping := false:
	set(value):
		if not is_jumping and value:
			jumped.emit()
		is_jumping = value
var is_airbourne := false:
	set(value):
		if is_airbourne and not value:
			hit_floor.emit()
		is_airbourne = value
var is_crouching := false:
	set(value):
		if is_crouching and not value:
			got_up.emit()
		elif not is_crouching and value:
			crouched.emit()
		is_crouching = value
var was_last_jump_crouched := false

var jump_pressed := false
var _crouch_pressed := false


func _update_physics(delta: float) -> void:
	_update_key_presses()

	process_movement(delta)
	process_jump_and_fall(delta)
	
	_update_timers(delta)


func process_movement(delta: float) -> void:
	is_walking = x_direction
	is_crouching = _crouch_pressed
	
	velocity.x = move_toward(
		velocity.x,
		get_x_velocity(),
		get_x_acceleration() * delta
	)


func get_x_velocity() -> float:
	var x_velocity := max_speed * x_direction
	if _crouch_pressed:
		x_velocity *= crouching_speed_scale
	
	return x_velocity


func get_x_acceleration() -> float:
	if x_direction:
		return max_speed / acceleration_time
	else:
		return max_speed / deceleration_time


func process_jump_and_fall(delta: float) -> void:
	apply_gravity(delta)
	
	if should_jump():
		jump()
	elif Input.is_action_just_released(input_jump) and is_jumping:
		velocity.y *= variable_jump_scale
		is_jumping = false


func apply_gravity(delta: float) -> void:
	if not parent.is_on_floor():
		velocity += get_gravity() * delta
		velocity.y = min(velocity.y, terminal_falling_velocity)
		is_airbourne = true
		if velocity.y >= 0:
			is_jumping = false
			was_last_jump_crouched = false
	else:
		is_airbourne = false


func get_gravity() -> Vector2:
	return Vector2(0, 2 * get_true_jump_height() / pow(
			time_to_peak if is_jumping else time_to_fall,
			2
		)
	)


func should_jump() -> bool:
	return (
		(jump_buffer > 0 and parent.is_on_floor())
		or (coyote_jump_buffer > 0 and jump_pressed)
	)


func jump() -> void:
	if crouch_jump_buffer:
		was_last_jump_crouched = true
		crouch_jump_buffer = 0
	velocity.y = get_jump_velocity()
	jump_buffer = 0
	coyote_jump_buffer = 0
	is_jumping = true


func get_jump_velocity() -> float:
	return - (2 * get_true_jump_height()) / time_to_peak


func get_true_jump_height() -> float:
	var true_jump_height = jump_height
	if was_last_jump_crouched:
		true_jump_height *= crouch_jump_scale
	return true_jump_height


func _update_key_presses() -> void:
	if input_disabled:
		jump_pressed = false
		_crouch_pressed = false
		return
	
	jump_pressed = (
		Input.is_action_just_pressed(input_jump) or
		(hold_to_jump and Input.is_action_pressed(input_jump))
	)
	
	_crouch_pressed = Input.is_action_pressed(input_down) and not is_airbourne


func _update_timers(delta: float) -> void:
	if jump_pressed:
		jump_buffer = jump_buffer_max
	if parent.is_on_floor():
		coyote_jump_buffer = coyote_jump_buffer_max
	if _crouch_pressed and parent.is_on_floor():
		crouch_jump_delay = minf(crouch_jump_delay_max, crouch_jump_delay + delta)
		if crouch_jump_delay == crouch_jump_delay_max:
			if not crouch_jump_ready:
				crouch_jump_charged.emit()
				crouch_jump_ready = true
			crouch_jump_buffer = crouch_jump_buffer_max
	else:
		crouch_jump_delay = 0
		crouch_jump_ready = false
	
	jump_buffer = maxf(0, jump_buffer - delta)
	coyote_jump_buffer = maxf(0, coyote_jump_buffer - delta)
	crouch_jump_buffer = maxf(0, crouch_jump_buffer - delta)
