class_name ShootComponent
extends Node2D


signal finished_reloading


const BULLET: PackedScene = preload("uid://7ojvpihm5shc")

@export_range(0, 5, 0.1) var shot_delay := 2.0
@export var speed := 300.0


@onready var parent_groups := get_parent().get_groups()
@onready var shot_cooldown := Timer.new()


func _ready() -> void:
	add_child(shot_cooldown)
	shot_cooldown.timeout.connect(func(): finished_reloading.emit())
	shot_cooldown.one_shot = true


func shoot(super_parent: Node, direction: Vector2) -> void:
	var bullet: Bullet = BULLET.instantiate()
	bullet.velocity = direction * speed
	bullet.global_position = global_position
	for i in parent_groups:
		bullet.add_to_group(i)
	
	super_parent.add_child(bullet)
	
