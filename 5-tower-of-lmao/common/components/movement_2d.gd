@abstract
@icon("res://common/components/movement_2d.png")
class_name Movement2D
extends Node2D


@export var disabled := false
@export var source: CharacterBody2D

@export_group("Input", "input_")
@export var input_disabled := false
@export var input_left := &"move_left"
@export var input_right := &"move_right"
@export var input_up := &"move_up"
@export var input_down := &"move_down"

var x_direction := 0.0
var y_direction := 0.0

var _time_left_pressed := 0.0
var _time_right_pressed := 0.0
var _time_up_pressed := 0.0
var _time_down_pressed := 0.0

var velocity := Vector2.ZERO


func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		update_x_direction(delta)
		update_y_direction(delta)


@warning_ignore("unused_parameter")
func _update_physics(delta: float) -> void:
	pass


func get_updated_velocity(delta: float) -> Vector2:
	if disabled or not source:
		return Vector2.ZERO
	
	velocity = source.velocity
	
	_update_physics(delta)
	
	return velocity


func update_x_direction(delta: float) -> void:
	if input_disabled:
		x_direction = 0
		return
	
	var left_pressed := Input.is_action_pressed(input_left)
	var right_pressed := Input.is_action_pressed(input_right)
	
	_time_left_pressed = _time_left_pressed + delta if left_pressed else 0.0
	_time_right_pressed = _time_right_pressed + delta if right_pressed else 0.0
	var closest_time = minf(_time_left_pressed, _time_right_pressed)
	
	x_direction = Input.get_axis(input_left, input_right)
	if left_pressed and right_pressed:
		x_direction = -1 if closest_time == _time_left_pressed else 1


func update_y_direction(delta: float) -> void:
	if input_disabled:
		y_direction = 0
		return
	
	var left_pressed := Input.is_action_pressed(input_up)
	var right_pressed := Input.is_action_pressed(input_down)
	
	_time_up_pressed = _time_up_pressed + delta if left_pressed else 0.0
	_time_down_pressed = _time_down_pressed + delta if right_pressed else 0.0
	var closest_time = minf(_time_up_pressed, _time_down_pressed)
	
	y_direction = Input.get_axis(input_up, input_down)
	if left_pressed and right_pressed:
		y_direction = -1 if closest_time == _time_up_pressed else 1
