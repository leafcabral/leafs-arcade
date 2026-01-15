class_name Fruit
extends RigidBody2D


signal exited_screen(fruit: Fruit)

const AVG_SPEED := 300.0
const MAX_ANGLE_DELTA := PI / 3

@onready var viewport_size := get_viewport_rect().size


func _ready() -> void:
	launch()


func launch() -> void:
	angular_velocity = randf_range(PI / 2, PI)
	
	var half_sprite_size: Vector2 = $Sprite2D.get_rect().size / 2
	var x_position_ratio := remap(
		global_position.x,
		half_sprite_size.x, viewport_size.x - half_sprite_size.x,
		-1, 1
	)
	
	var x_move_half_screen := viewport_size.x / 4
	var x_move_full_screen := viewport_size.x / 2
	linear_velocity.x = (
		-x_position_ratio * randf_range(x_move_half_screen, x_move_full_screen)
		if abs(x_position_ratio) >= 0.2 else
		[-1, 1].pick_random() * randf_range(x_move_half_screen, x_move_half_screen * 1.1)
	)
	linear_velocity.y = -viewport_size.y * randf_range(1.5, 1.8)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	exited_screen.emit(self)
