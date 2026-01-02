class_name WrapScreenComponent
extends Node2D
## Plug and Play component that makes its parent wrap around the screen when
## leaving it
##
## Remeber to set [code]border_offset[/code] value so it only wrap around the
## screen when completely outside it, instead of just its center getting outside

@export var border_offset: Vector2

@onready var parent := get_parent()
@onready var viewport_size: Vector2 = get_viewport_rect().size


func _process(_delta: float) -> void:
	if parent is Node2D:
		parent.global_position = wrapVec2(
			parent.global_position,
			-border_offset,
			viewport_size + border_offset
		)


func wrapVec2(vector: Vector2, size_min: Vector2, size_max: Vector2) -> Vector2:
	return Vector2(
		wrapf(vector.x, size_min.x, size_max.x),
		wrapf(vector.y, size_min.y, size_max.y),
	)
