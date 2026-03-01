@tool
class_name MouseDragArea2D
extends Area2D


signal started_holding
signal finished_holding(direction: Vector2)

@export var input_click := &"left_mouse"
@export var track_start := false
@export var slingshot := true
@export var minimum_drag := 10.0
@export var maximum_drag := 100.0

var is_mouse_inside_shape := false
var is_holding := false

var starting_position := Vector2.ZERO
var direction := Vector2.ZERO
var drag_amount := 0.0

@onready var sprite_direction: Sprite2D = get_node_or_null("SpriteDirection")


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	mouse_entered.connect(func(): is_mouse_inside_shape = true)
	mouse_exited.connect(func(): is_mouse_inside_shape = false)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var mouse_position := get_local_mouse_position()
	
	if is_mouse_inside_shape and Input.is_action_just_pressed(input_click):
		started_holding.emit()
		is_holding = true
		if track_start:
			starting_position = mouse_position
	
	if is_holding and Input.is_action_pressed(input_click):
		var distance := (mouse_position - starting_position).limit_length(maximum_drag)
		
		direction = (
			Vector2.ZERO if distance.length() < minimum_drag
			else -distance if slingshot
			else distance
		)
	else:
		if is_holding:
			finished_holding.emit(direction)
		is_holding = false
	
	if sprite_direction:
		update_sprite_direction()


func update_sprite_direction() -> void:
	if is_holding and direction.length() > minimum_drag:
		sprite_direction.visible = true
		sprite_direction.rotation = (direction).angle()
	else:
		sprite_direction.visible = false
