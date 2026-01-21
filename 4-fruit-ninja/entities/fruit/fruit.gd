class_name Fruit
extends RigidBody2D


signal exited_screen(fruit: Fruit)
signal sliced(fruit: Fruit)
signal exploded(fruit: Fruit)

enum Type {
	NORMAL,
	NORMAL_SLICE,
	BOMB,
}

const FRUIT_SCENE = preload("uid://6rsron8monuy")
const AVG_SPEED := 300.0
const MAX_ANGLE_DELTA := PI / 3
const BOMB_EXPLODE_TIME := 0.6

@export var sprite_data: FruitSpriteData
@export var type := Type.NORMAL

var sprite: Texture2D

@onready var viewport_size := get_viewport_rect().size
@onready var sprite_2d: Sprite2D = $Sprite2D


static func create_random_normal() -> Fruit:
	var fruit: Fruit = FRUIT_SCENE.instantiate()
	fruit.sprite_data = FruitSpriteData.get_random_normal()
	fruit.sprite = fruit.sprite_data.full
	return fruit


static func create_bomb() -> Fruit:
	var fruit: Fruit = FRUIT_SCENE.instantiate()
	fruit.sprite = FruitSpriteData.get_bomb_sprite()
	fruit.type = Type.BOMB
	return fruit


func _ready() -> void:
	match type:
		Type.NORMAL:
			$BombFireTrail.queue_free()
			launch()
		Type.BOMB:
			$BombFireTrail.show()
			launch()
	
	sprite_2d.texture = sprite


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


func create_slices() -> Array[Fruit]:
	var slices: Array[Fruit] = []
	
	if type == Type.NORMAL:
		for i in 2:
			var slice: Fruit = duplicate()
			slice.type = Type.NORMAL_SLICE
			slice.linear_velocity *= [-1,1][i]
			slice.sprite = sprite_data.halfs[i]
			
			slices.append(slice)
	return slices


func explode() -> void:
	if type == Type.BOMB:
		sprite_2d.material = sprite_2d.material.duplicate()
		
		var tween := create_tween()
		tween.tween_property(sprite_2d.material, "shader_parameter/white_multiplier", 1, BOMB_EXPLODE_TIME)
		tween.tween_callback(exploded.emit.bind(self))


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	exited_screen.emit(self)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		$Area2D.queue_free()
		sliced.emit(self)
