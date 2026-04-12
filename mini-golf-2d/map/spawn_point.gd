@tool
class_name SpawnPoint
extends Node2D


const TEE_MAX_HEIGHT := 65.0

@export_group("Golf Tee", "tee_")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var tee_enabled := true:
	set = set_tee_enabled
@export_range(0, TEE_MAX_HEIGHT, 0.1) var tee_height = TEE_MAX_HEIGHT / 2:
	set = set_tee_height

@onready var tee_box: StaticBody2D = $TeeBox


func get_real_position() -> Vector2:
	return global_position - Vector2(0, tee_height) if tee_enabled else global_position


func set_tee_enabled(enabled: bool) -> void:
	tee_enabled = enabled
	if tee_box:
		tee_box.visible = tee_enabled


func set_tee_height(height: float) -> void:
	tee_height = height
	if tee_box:
		tee_box.position.y = -tee_height
