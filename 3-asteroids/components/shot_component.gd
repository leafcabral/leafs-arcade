class_name ShotComponent
extends Node2D


signal finished_reloading


const BULLET: PackedScene = preload("uid://7ojvpihm5shc")

@export_range(0, 5, 0.1) var shot_delay := 2.0
@export var speed := 300.0


@onready var parent := get_parent()
@onready var shot_cooldown := Timer.new()


func _ready() -> void:
	add_child(shot_cooldown)
	shot_cooldown.timeout.connect(func(): finished_reloading.emit())
	shot_cooldown.one_shot = true


func shot(super_parent: Node, direction: Vector2) -> void:
	if can_shot():
		shot_cooldown.start(shot_delay)
		
		var bullet: Bullet = BULLET.instantiate()
		bullet.velocity = direction * speed
		bullet.global_position = global_position
		
		bullet.collision_layer = parent.collision_layer
		bullet.collision_mask =  parent.collision_mask
		Global.apply_groups(parent, bullet)
		
		super_parent.add_child(bullet)

func can_shot() -> bool:
	return shot_cooldown.is_stopped()
