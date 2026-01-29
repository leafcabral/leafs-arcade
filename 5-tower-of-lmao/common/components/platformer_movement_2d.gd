@tool
class_name PlatformerMovement2D
extends Node2D


signal jumped
signal hit_floor

const CC_LEFT_NAME := ^"CornerCorrectionLeft"
const CC_MIDDLE_NAME := ^"CornerCorrectionMiddle"
const CC_RIGHT_NAME := ^"CornerCorrectionRight"

@export var disabled := false
@export var input_move_left := &"move_left"
@export var input_move_right := &"move_right"
@export var input_jump := &"jump"

@export_group("Horizontal Movement")
@export_range(0, 1000, 0.1, "or_greater") var max_speed := 600.0
@export_range(0, 5, 0.01, "or_greater") var acceleration_time := 0.1
@export_range(0, 5, 0.01, "or_greater") var deceleration_time := 0.0
@export var directional_snap := true

@export_group("Vertical Movement")
@export_range(-10, 10, 0.01) var gravity_scale := 2.5
@export_range(0, 1000, 0.1, "or_greater") var jump_height := 600.0
@export_range(0, 5, 0.01, "or_greater") var jump_duration := 0.7
@export_range(0, 5000, 0.1, "or_greater") var terminal_falling_velocity := 2000.0
@export_subgroup("Responsiveness")
@export_range(0, 1, 0.01) var variable_jump_scale := 0.5
@export_range(0, 5, 0.01, "or_greater") var jump_buffering_time := 0.05
@export_range(0, 5, 0.01, "or_greater") var coyote_jump_time := 0.1
@export_subgroup("Corner Correction", "corner_correction_")
@export_range(0, 32, 0.01, "or_greater") var corner_correction_amount := 5.0:
	set(value):
		corner_correction_amount = value
		_update_corner_correction_properties()
@export var corner_correction_offset := Vector2.ZERO:
	set(value):
		corner_correction_offset = value
		_update_corner_correction_properties()
@export_range(0, 100, 0.01, "or_greater") var corner_correction_distance_between := 32.0:
	set(value):
		corner_correction_distance_between = value
		_update_corner_correction_properties()
@export_range(0, 128, 0.1, "or_greater") var corner_correction_ray_length := 32.0:
	set(value):
		corner_correction_ray_length = value
		_update_corner_correction_properties()

var velocity := Vector2.ZERO

var jump_buffering := 0.0
var coyote_jump := 0.0

var is_airbourne := false

var _corner_correction_left: RayCast2D
var _corner_correction_middle: ShapeCast2D
var _corner_correction_right: RayCast2D
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


func _ready() -> void:
	_setup_corner_correction_nodes()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or disabled:
		return
	
	process_movement(delta)
	
	parent.move_and_slide()
	velocity = parent.velocity
	
	if parent.velocity.y < 0 and not _corner_correction_middle.is_colliding():
		_try_corner_correction()


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
		velocity += parent.get_gravity() * gravity_scale * delta
		velocity.y = min(velocity.y, terminal_falling_velocity)
		is_airbourne = true
	
	if Input.is_action_pressed(input_jump):
		jump_buffering = jump_buffering_time
	if on_floor:
		coyote_jump = coyote_jump_time
	
	if (jump_buffering > 0 and on_floor) or (coyote_jump > 0 and Input.is_action_just_pressed(input_jump)):
			velocity.y = - 2 * jump_height * jump_duration
			jump_buffering = 0
			coyote_jump = 0
			if not is_airbourne:
				jumped.emit()
	elif Input.is_action_just_released(input_jump) and velocity.y <= 0:
		velocity.y *= variable_jump_scale
	


func _try_corner_correction() -> void:
	var left_colliding := _corner_correction_left.is_colliding()
	var right_colliding := _corner_correction_right.is_colliding()
	
	if left_colliding and not right_colliding:
		parent.position.x += corner_correction_amount
	elif not left_colliding and right_colliding:
		parent.position.x -= corner_correction_amount


func _setup_corner_correction_nodes() -> void:
	_corner_correction_left = get_node_or_null(CC_LEFT_NAME)
	_corner_correction_middle = get_node_or_null(CC_MIDDLE_NAME)
	_corner_correction_right = get_node_or_null(CC_RIGHT_NAME)
	
	if not _corner_correction_left:
		_corner_correction_left = _create_ray_cast(CC_LEFT_NAME)
		add_child(_corner_correction_left)
	if not _corner_correction_middle:
		_corner_correction_middle = _create_shape_cast(CC_MIDDLE_NAME)
		add_child(_corner_correction_middle)
	if not _corner_correction_right:
		_corner_correction_right = _create_ray_cast(CC_RIGHT_NAME)
		add_child(_corner_correction_right)
	
	_update_corner_correction_properties()


func _create_ray_cast(node_name: String) -> RayCast2D:
	var raycast := RayCast2D.new()
	raycast.name = node_name
	raycast.collision_mask = parent.collision_mask
	return raycast


func _create_shape_cast(node_name: String) -> ShapeCast2D:
	var shape_cast := ShapeCast2D.new()
	shape_cast.name = node_name
	shape_cast.shape = RectangleShape2D.new()
	shape_cast.collision_mask = parent.collision_mask
	return shape_cast


func _update_corner_correction_properties() -> void:
	if not (_corner_correction_left and _corner_correction_right and _corner_correction_middle):
		return
	
	var half_distance := corner_correction_distance_between / 2
	var rays: Array[RayCast2D] = [_corner_correction_left, _corner_correction_right]
	for i in 2:
		rays[i].position = corner_correction_offset
		rays[i].position.x += half_distance * [-1, 1][i]
		rays[i].target_position.y = -corner_correction_ray_length
	
	var middle := _corner_correction_middle
	middle.position = corner_correction_offset
	middle.position.y -= corner_correction_ray_length / 2
	middle.target_position = Vector2.ZERO
	middle.shape.size.x = maxf(0, corner_correction_distance_between - 2 * corner_correction_amount)
	middle.shape.size.y = corner_correction_ray_length
