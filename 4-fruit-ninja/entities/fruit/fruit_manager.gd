class_name FruitManager
extends Path2D


signal fruit_sliced
signal unsliced_fruit_left
signal bomb_sliced
signal fruits_depleted

const BOMB_CHANCE := 0.1

var fruits_to_spawn: Array[Fruit] = []
var fruits_spawned: Array[Fruit] = []
var fruit_timers: Array[float] = []

@onready var curve_legth := curve.get_baked_length()


func _process(delta: float) -> void:
	if fruit_timers:
		fruit_timers[-1] -= delta
		if fruit_timers[-1] <= 0:
			fruit_timers.pop_back()
			
			var fruit: Fruit = fruits_to_spawn.pop_back()
			fruits_spawned.append(fruit)
			add_child(fruit)


func spawn_fruits(amount: int, should_spawn_bomb: bool) -> void:
	for i in amount:
		var fruit: Fruit
		if should_spawn_bomb and randf() < BOMB_CHANCE:
			fruit = Fruit.create_bomb()
		else:
			fruit = Fruit.create_random_normal()
		fruit.position = get_random_position()
		
		fruits_to_spawn.append(fruit)
		connect_fruit_signals(fruit)
		
		fruit_timers.append(randf())


func get_random_position() -> Vector2:
	return curve.sample_baked(randf_range(0, curve_legth))


func connect_fruit_signals(fruit: Fruit) -> void:
	fruit.connect("exited_screen", _on_fruit_exited_screen)
	fruit.connect("sliced", _on_fruit_sliced)
	fruit.connect("exploded", _on_fruit_exploded)


func clear_fruits() -> void:
	fruits_to_spawn.clear()
	for i in fruits_spawned:
		i.queue_free()
	fruits_spawned.clear()
	fruit_timers.clear()


func erase_fruit(fruit: Fruit) -> void:
	fruit.queue_free()
	fruits_spawned.erase(fruit)
	
	if fruits_spawned.is_empty() and fruits_to_spawn.is_empty():
		fruits_depleted.emit()


func _on_fruit_exited_screen(fruit: Fruit) -> void:
	if fruit.type == Fruit.Type.NORMAL:
		unsliced_fruit_left.emit()
	erase_fruit(fruit)


func _on_fruit_sliced(fruit: Fruit) -> void:
	if fruit.type == Fruit.Type.NORMAL:
		for i in fruit.create_slices():
			call_deferred("add_child", i)
			connect_fruit_signals(i)
		fruit_sliced.emit()
		erase_fruit(fruit)
	elif fruit.type == Fruit.Type.BOMB:
		fruit.explode()
		
		bomb_sliced.emit()


func _on_fruit_exploded(fruit: Fruit) -> void:
	erase_fruit(fruit)
