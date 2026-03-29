@tool
class_name DragThrowArea2D
extends Area2D


signal grabbed
signal released(cancelled: bool)

@export var shoot := &"shoot"
@export var cancel_shot := &"cancel_shot"
@export var track_start := false
@export var invert_direction := true
@export var enable_opposite_x := true
@export_group("Range")
@export_range(0, 1000, 0.1) var minimum_drag := 10.0
@export_range(0, 1000, 0.1) var maximum_drag := 100.0
@export_range(-180, 180, 0.1, "radians_as_degrees") var minimum_angle := -180.0
@export_range(-180, 180, 0.1, "radians_as_degrees") var maximum_angle := 180.0


var drag_raw := Vector2.ZERO
var drag := Vector2.ZERO

var _is_mouse_inside_shape := false
var _is_holding := false
var _starting_position := Vector2.ZERO


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	mouse_entered.connect(func(): _is_mouse_inside_shape = true)
	mouse_exited.connect(func(): _is_mouse_inside_shape = false)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var mouse_position := get_local_mouse_position()
	
	if _is_mouse_inside_shape and Input.is_action_just_pressed(shoot):
		set_is_holding(true)
		_is_holding = true
		if track_start:
			_starting_position = mouse_position
	
	if _is_holding and Input.is_action_pressed(shoot) and not Input.is_action_pressed(cancel_shot):
		drag_raw = mouse_position - _starting_position
		drag = -drag_raw if invert_direction else drag_raw
		
		drag = drag.limit_length(maximum_drag)
		if drag.length() < minimum_drag:
			drag = Vector2.ZERO
		clamp_angle()
	else:
		drag_raw = Vector2.ZERO
		if Input.is_action_pressed(cancel_shot):
			set_is_holding(false, true)
		else:
			set_is_holding(false)


func clamp_angle() -> void:
	var should_invert_var := should_invert()
	var angle := drag.angle()
	
	if should_invert_var:
		angle = drag.reflect(Vector2.UP).angle()
	angle = clampf(angle, minimum_angle, maximum_angle)
	
	drag = Vector2.from_angle(angle) * drag.length()
	if should_invert_var:
		drag = drag.reflect(Vector2.UP)


func should_invert() -> bool:
	return drag.x < 0 and enable_opposite_x


func get_global_drag() -> Vector2:
	return to_global(drag)


func get_drag_baked_length() -> float:
	return remap(drag.length(), minimum_drag, maximum_drag, 0.0, 1.0)


func get_drag_percentage() -> float:
	return get_drag_baked_length() * 100


func get_drag_angle_q1() -> float:
	var angle := absf(drag.angle())
	return remap(angle, PI/2, PI, PI/2, 0) if angle > PI/2 else angle


func set_is_holding(value: bool, active := false) -> void:
	var was_holding := _is_holding
	_is_holding = value
	
	if not was_holding and _is_holding:
		grabbed.emit()
	if was_holding and not _is_holding:
		released.emit(active)
