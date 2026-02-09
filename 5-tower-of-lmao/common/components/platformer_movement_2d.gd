@tool
class_name PlatformerMovement2D
extends Node2D


signal jumped
signal hit_floor

@export var disabled := false
@export var input_move_left := &"move_left"
@export var input_move_right := &"move_right"
@export var input_jump := &"jump"

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

@export_group("Quality of Life")
@export_range(0, 1, 0.01) var variable_jump_scale := 0.5
@export_range(0, 5, 0.01, "or_greater") var jump_buffering_time := 0.05
@export_range(0, 5, 0.01, "or_greater") var coyote_jump_time := 0.1

var velocity := Vector2.ZERO

var jump_buffering := 0.0
var coyote_jump := 0.0

var is_airbourne := false

var _left_pressed := false
var _right_pressed := false
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
	
	process_movement(delta)
	
	parent.move_and_slide()
	velocity = parent.velocity


func process_movement(delta: float) -> void:
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

	_handle_horizontal_movement(delta)
	_handle_vertical_movement(delta)
	
	parent.velocity = velocity
	
	if jump_buffering > 0:
		jump_buffering = max(0, jump_buffering - delta)
	if coyote_jump > 0:
		coyote_jump = max(0, coyote_jump - delta)


func get_gravity() -> Vector2:
	return Vector2(0, 2 * jump_height / pow(
			time_to_peak if velocity.y < 0 else time_to_fall,
			2
		)
	)


func _handle_horizontal_movement(delta: float) -> void:
	var delta_speed := max_speed * delta
	
	var direction := Input.get_axis("move_left", "move_right")
	if directional_snap and (_left_pressed and _right_pressed):
		var closest_time = minf(_time_left_pressed, _time_right_pressed)
		direction = -1 if closest_time == _time_left_pressed else 1
	
	
	if not direction:
		velocity.x = move_toward(velocity.x, 0, delta_speed / deceleration_time)
	else:
		velocity.x = move_toward(velocity.x, direction * max_speed, delta_speed / acceleration_time)


func _handle_vertical_movement(delta: float) -> void:
	var on_floor := parent.is_on_floor()
	
	if on_floor:
		if is_airbourne:
			is_airbourne = false
			hit_floor.emit()
	else:
		velocity += get_gravity() * delta
		velocity.y = min(velocity.y, terminal_falling_velocity)
		is_airbourne = true
	
	if Input.is_action_just_pressed(input_jump) or (hold_to_jump and Input.is_action_pressed(input_jump)):
		jump_buffering = jump_buffering_time
	if on_floor:
		coyote_jump = coyote_jump_time
	
	if (jump_buffering > 0 and on_floor) or (coyote_jump > 0 and Input.is_action_just_pressed(input_jump)):
			velocity.y = - (2 * jump_height) / time_to_peak
			jump_buffering = 0
			coyote_jump = 0
			if not is_airbourne:
				jumped.emit()
	elif Input.is_action_just_released(input_jump) and velocity.y <= 0:
		velocity.y *= variable_jump_scale
