@tool
class_name PlatformerMovement2D
extends Node2D


@export var disabled := false
@export var input_move_left := &"move_left"
@export var input_move_right := &"move_right"
@export var input_jump := &"jump"

@export_group("Horizontal Movement")
@export_range(0, 1000, 0.1, "or_greater") var max_speed := 600.0
@export_range(0, 5, 0.01, "or_greater") var acceleration_time := 0.3
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

var jump_buffering := 0.0
var coyote_jump := 0.0

var _corner_correction_left: RayCast2D
var _corner_correction_middle: ShapeCast2D
var _corner_correction_right: RayCast2D

@onready var parent := get_parent() as CharacterBody2D


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		parent = get_parent()


func _ready() -> void:
	_setup_corner_correction_nodes()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()
		return
	if disabled:
		return
	
	_handle_horizontal_movement(delta)
	_handle_vertical_movement(delta)
	
	parent.move_and_slide()
	if parent.velocity.y < 0 and not _corner_correction_middle.is_colliding():
		_try_corner_correction()


func _get_configuration_warnings() -> PackedStringArray:
	var errors := PackedStringArray()
	
	if not parent is CharacterBody2D:
		errors.append(
			"PlataformerMovement2D only serves to provide movement for a CharacterBody2D derived node.
			Please, only use it as a child of CharacterBody2D to make it move."
		)
		
	return errors


func _setup_corner_correction_nodes() -> void:
	_corner_correction_left = get_node_or_null("CornerCorrectionLeft")
	_corner_correction_middle = get_node_or_null("CornerCorrectionMiddle")
	_corner_correction_right = get_node_or_null("CornerCorrectionRight")
	
	if not _corner_correction_left:
		_corner_correction_left = RayCast2D.new()
		_corner_correction_left.name = "CornerCorrectionLeft"
		_corner_correction_left.collision_mask = parent.collision_mask
		add_child(_corner_correction_left)
	
	if not _corner_correction_middle:
		_corner_correction_middle = ShapeCast2D.new()
		_corner_correction_middle.name = "CornerCorrectionMiddle"
		_corner_correction_middle.shape = RectangleShape2D.new()
		_corner_correction_middle.collision_mask = parent.collision_mask
		add_child(_corner_correction_middle)
	
	if not _corner_correction_right:
		_corner_correction_right = RayCast2D.new()
		_corner_correction_right.name = "CornerCorrectionRight"
		_corner_correction_right.collision_mask = parent.collision_mask
		add_child(_corner_correction_right)
	
	_update_corner_correction_properties()


func _update_corner_correction_properties() -> void:
	var half_distance := corner_correction_distance_between / 2
	
	if _corner_correction_left:
		_corner_correction_left.position = corner_correction_offset
		_corner_correction_left.position.x -= half_distance
		_corner_correction_left.target_position.y = -corner_correction_ray_length
	
	if _corner_correction_right:
		_corner_correction_right.position = corner_correction_offset
		_corner_correction_right.position.x += half_distance
		_corner_correction_right.target_position.y = -corner_correction_ray_length
	
	if _corner_correction_middle:
		_corner_correction_middle.position = corner_correction_offset
		_corner_correction_middle.position.y -= corner_correction_ray_length / 2
		_corner_correction_middle.target_position = Vector2.ZERO
		var _shape := _corner_correction_middle.shape as RectangleShape2D
		_shape.size.x = corner_correction_distance_between - 2 * corner_correction_amount
		_shape.size.y = corner_correction_ray_length


func _handle_horizontal_movement(delta: float) -> void:
	var direction := Input.get_axis(input_move_left, input_move_right)
	var delta_speed := max_speed * delta
	if signf(direction) == signf(parent.velocity.x):
		parent.velocity.x = move_toward(parent.velocity.x, direction * max_speed, delta_speed / acceleration_time)
	elif direction and parent.velocity.x and directional_snap:
		parent.velocity.x = - parent.velocity.x
	else:
		parent.velocity.x = move_toward(parent.velocity.x, direction * max_speed, delta_speed / deceleration_time)


func _handle_vertical_movement(delta: float) -> void:
	if not parent.is_on_floor():
		parent.velocity += parent.get_gravity() * gravity_scale * delta
		parent.velocity.y = min(parent.velocity.y, terminal_falling_velocity)
	
	if Input.is_action_pressed(input_jump):
		jump_buffering = jump_buffering_time
	if parent.is_on_floor():
		coyote_jump = coyote_jump_time
	if (jump_buffering > 0 and parent.is_on_floor()) or (coyote_jump > 0 and Input.is_action_just_pressed(input_jump)):
			parent.velocity.y = - 2 * jump_height * jump_duration
			jump_buffering = 0
			coyote_jump = 0
	elif Input.is_action_just_released(input_jump) and parent.velocity.y <= 0:
		parent.velocity.y *= variable_jump_scale
	
	if jump_buffering > 0:
		jump_buffering = max(0, jump_buffering - delta)
	if coyote_jump > 0:
		coyote_jump = max(0, coyote_jump - delta)


func _try_corner_correction() -> void:
	var left_colliding := _corner_correction_left.is_colliding()
	var right_colliding := _corner_correction_right.is_colliding()
	
	if left_colliding and not right_colliding:
		parent.position.x += corner_correction_amount
	elif not left_colliding and right_colliding:
		parent.position.x -= corner_correction_amount
