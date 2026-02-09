@tool
class_name PlatformerMovement2D
extends Node2D


signal jumped
signal hit_floor
signal crouched
signal got_up

@export var disabled := false
@export var input_move_left := &"move_left"
@export var input_move_right := &"move_right"
@export var input_jump := &"jump"
@export var input_crouch := &"crouch"

@export_group("Horizontal Movement")
@export_range(0, 1000, 0.1, "or_greater") var max_speed := 600.0
@export_range(0, 5, 0.01, "or_greater") var acceleration_time := 0.1
@export_range(0, 5, 0.01, "or_greater") var deceleration_time := 0.05
@export var directional_snap := true

@export_group("Vertical Movement")
@export_range(0, 1000, 0.1, "or_greater") var jump_height := 64.0
@export_range(0, 2, 0.01, "or_greater") var time_to_peak := 0.3
@export_range(0, 2, 0.01, "or_greater") var time_to_fall := 0.3
@export_range(0, 5000, 0.1, "or_greater") var terminal_falling_velocity := 2000.0
@export var hold_to_jump := false

@export_group("Crouching")
@export_range(0, 1, 0.01) var crouching_speed_scale := 0.5
@export_range(1, 2, 0.1, "or_greater") var crouch_jump_scale := 1.0
@export_range(0, 2, 0.01, "or_greater") var strong_jump_buffer := 0.1

@export_group("Quality of Life")
@export_range(0, 1, 0.01) var variable_jump_scale := 0.5
@export_range(0, 5, 0.01, "or_greater") var jump_buffering_time := 0.05
@export_range(0, 5, 0.01, "or_greater") var coyote_jump_time := 0.1

var velocity := Vector2.ZERO

var jump_buffering := 0.0
var coyote_jump := 0.0
var strong_jump := 0.0

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
var did_super_jump := false

var _left_pressed := false
var _right_pressed := false
var _jump_pressed := false
var _crouch_pressed := false
var _time_left_pressed := 0.0
var _time_right_pressed := 0.0

@onready var parent := get_parent() as CharacterBody2D


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		parent = get_parent()
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not parent is CharacterBody2D:
		warnings.append(
			"PlataformerMovement2D only serves to provide movement for a CharacterBody2D derived node.
			Please, only use it as a child of CharacterBody2D to make it move."
		)
		
	return warnings


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or disabled:
		return
	
	process_physics(delta)
	
	parent.move_and_slide()
	velocity = parent.velocity


func process_physics(delta: float) -> void:
	_update_key_presses(delta)

	process_movement(delta)
	process_jump_and_fall(delta)
	
	parent.velocity = velocity
	
	_update_timers(delta)


func process_movement(delta: float) -> void:
	var direction := get_movement_axis()
	is_walking = direction
	
	var speed := max_speed * direction
	if _crouch_pressed:
		is_crouching = true
		speed *= crouching_speed_scale
	else:
		is_crouching = false
	velocity.x = move_toward(
		velocity.x,
		speed if direction else 0.0,
		max_speed * delta / (acceleration_time if direction else deceleration_time)
	)


func process_jump_and_fall(delta: float) -> void:
	apply_gravity(delta)
	
	if parent.is_on_floor():
		is_airbourne = false
	
	if should_jump():
			velocity.y = get_jump_velocity()
			jump_buffering = 0
			coyote_jump = 0
			is_jumping = true
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
			did_super_jump = false


func should_jump() -> bool:
	return (jump_buffering > 0 and parent.is_on_floor()) or (coyote_jump > 0 and _jump_pressed)


func get_movement_axis() -> float:
	var direction := Input.get_axis(input_move_left, input_move_right)
	if directional_snap and (_left_pressed and _right_pressed):
		var closest_time = minf(_time_left_pressed, _time_right_pressed)
		direction = -1 if closest_time == _time_left_pressed else 1
	return direction


func get_gravity() -> Vector2:
	var final_jump_height = jump_height
	if did_super_jump:
		final_jump_height *= crouch_jump_scale
	return Vector2(0, 2 * final_jump_height / pow(
			time_to_peak if is_jumping else time_to_fall,
			2
		)
	)


func get_jump_velocity() -> float:
	var final_jump_height = jump_height
	if strong_jump:
		final_jump_height *= crouch_jump_scale
		did_super_jump = true
	return - (2 * final_jump_height) / time_to_peak


func _update_key_presses(delta: float) -> void:
	_left_pressed = Input.is_action_pressed("move_left")
	_right_pressed = Input.is_action_pressed("move_right")
	_time_left_pressed = (
			_time_left_pressed + delta if _left_pressed
			else 0.0
	)
	_time_right_pressed = (
			_time_right_pressed + delta if _right_pressed
			else 0.0
	)
	_jump_pressed = (
		Input.is_action_just_pressed(input_jump) or
		(hold_to_jump and Input.is_action_pressed(input_jump))
	)
	_crouch_pressed = Input.is_action_pressed(input_crouch)


func _update_timers(delta: float) -> void:
	if _jump_pressed:
		jump_buffering = jump_buffering_time
	if parent.is_on_floor():
		coyote_jump = coyote_jump_time
	if _crouch_pressed:
		strong_jump = strong_jump_buffer
	
	if jump_buffering > 0:
		jump_buffering = max(0, jump_buffering - delta)
	if coyote_jump > 0:
		coyote_jump = max(0, coyote_jump - delta)
	if strong_jump > 0:
		strong_jump = max(0, strong_jump - delta)
		
