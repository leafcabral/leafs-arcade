class_name FruitManager
extends Path2D


signal spawn_cooldown_finished
signal fruit_sliced
signal unsliced_fruit_left
signal bomb_sliced
signal fruits_depleted

const BOMB_CHANCE := 0.1

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
		var fruit: Fruit
		if should_spawn_bomb and randf() < BOMB_CHANCE:
			fruit = Fruit.create_bomb()
		else:
			fruit = Fruit.create_random_normal()
		fruit.position = get_random_position()
		
		fruits.append(fruit)
		fruit.connect("exited_screen", _on_fruit_exited_screen)
		fruit.connect("sliced", _on_fruit_sliced)
		fruit.connect("exploded", _on_fruit_exploded)
		
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
	if fruit.type == Fruit.Type.NORMAL:
		unsliced_fruit_left.emit()
	erase_fruit(fruit)


func _on_fruit_sliced(fruit: Fruit) -> void:
	if fruit.type == Fruit.Type.NORMAL:
		for i in fruit.create_slices():
			call_deferred("add_child", i)
		fruit_sliced.emit()
		erase_fruit(fruit)
	else:
		fruit.explode()
		
		bomb_sliced.emit()


func _on_fruit_exploded(fruit: Fruit) -> void:
	erase_fruit(fruit)
