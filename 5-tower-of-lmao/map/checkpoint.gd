@tool
@icon("res://map/checkpoint_icon.png")
class_name Checkpoint
extends Area2D


signal player_entered(checkpoint: Checkpoint)

@export var area: RectangleShape2D:
	set(value):
		area = value
		update_checkpoin_area()
@export var offset := Vector2i.ZERO:
	set(value):
		offset = value
		update_checkpoin_area()
@export var activated := false:
	set(value):
		activated = value
		var fire := $Fire
		if activated:
			fire.show()
			fire.play("default")
			await fire.animation_finished
			fire.play("active")
		else:
			fire.hide()

var checkpoint_area: CollisionShape2D


func _ready() -> void:
	checkpoint_area = get_node_or_null("CheckpointArea")
	area = RectangleShape2D.new()
	body_entered.connect(_on_body_entered)


func get_shape() -> RectangleShape2D:
	return $CheckpointArea.shape


func get_center() -> Vector2:
	return to_global(get_shape().get_rect().get_center())


func get_base() -> Vector2:
	return to_global(Vector2(get_center().x, get_shape().get_rect().end.y))


func update_checkpoin_area() -> void:
	if checkpoint_area:
		checkpoint_area.shape = area
		checkpoint_area.position = offset


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if not activated:
			player_entered.emit(self)
			activated = true
