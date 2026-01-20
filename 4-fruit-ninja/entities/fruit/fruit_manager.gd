class_name FruitManager
extends Path2D


signal spawn_cooldown_finished
signal fruit_sliced
signal unsliced_fruit_left
signal bomb_sliced
signal fruits_depleted

const FRUIT := preload("uid://6rsron8monuy")
const BOMB_CHANCE := 0.1

@export var sprite_datas: Array[FruitSpriteData]

var fruits: Array[Fruit] = []
var fruit_timers: Array[float] = []

@onready var curve_legth := curve.get_baked_length()


func _process(delta: float) -> void:
	if fruit_timers:
		fruit_timers[0] -= delta
		if fruit_timers[0] <= 0:
			spawn_cooldown_finished.emit()
			fruit_timers.remove_at(0)


func spawn_fruits(amount: int, should_spawn_bomb: bool) -> void:
	for i in amount:
		var fruit: Fruit = FRUIT.instantiate()
		fruit.position = get_random_position()
		fruit.sprite_data = sprite_datas.pick_random()
		if should_spawn_bomb:
			fruit.is_bomb = randf() < BOMB_CHANCE
		
		fruits.append(fruit)
		fruit.connect("exited_screen", _on_fruit_exited_screen)
		fruit.connect("sliced", _on_fruit_sliced)
		
		fruit_timers.append(randf())


func get_random_position() -> Vector2:
	return curve.sample_baked(randf_range(0, curve_legth))


func clear_fruits() -> void:
	for i in fruits:
		i.queue_free()
	fruits.clear()
	fruit_timers.clear()


func pool_unspawned_fruit() -> Fruit:
	for i in fruits:
		if not i.is_inside_tree():
			return i
	return null


func erase_fruit(fruit: Fruit) -> void:
	fruits.erase(fruit)
	fruit.queue_free()
	
	if not fruits:
		fruits_depleted.emit()


func _on_fruit_exited_screen(fruit: Fruit) -> void:
	if not (fruit.is_bomb or fruit.is_sliced):
		unsliced_fruit_left.emit()
	erase_fruit(fruit)


func _on_fruit_sliced(fruit: Fruit) -> void:
	if not fruit.is_bomb:
		for i in 2:
			var fruit_slice := fruit.duplicate()
			fruit_slice.linear_velocity.x *= [-1, 1][i]
			fruit_slice.sprite_half_num = i
			call_deferred("add_child", fruit_slice)
		fruit_sliced.emit()
		erase_fruit(fruit)
	else:
		var fruit_tween := fruit.create_tween()
		var fruit_sprite: Sprite2D = fruit.get_node("Sprite2D")
		fruit_sprite.material = fruit_sprite.material.duplicate()
		fruit_tween.tween_property(fruit_sprite.material, "shader_parameter/white_multiplier", 1, 0.6)
		fruit_tween.tween_callback(erase_fruit.bind(fruit))
		
		bomb_sliced.emit()
		
