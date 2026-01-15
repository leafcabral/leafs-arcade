class_name FruitManager
extends Path2D


signal spawn_cooldown_finished
signal fruits_depleted

const FRUIT := preload("uid://6rsron8monuy")

var fruits: Array[Fruit] = []
var fruit_timers: Array[float] = []

@onready var curve_legth := curve.get_baked_length()


func _process(delta: float) -> void:
	if fruit_timers:
		fruit_timers[0] -= delta
		if fruit_timers[0] <= 0:
			spawn_cooldown_finished.emit()
			fruit_timers.remove_at(0)


func spawn_fruits(amount: int) -> void:
	for i in amount:
		var fruit := FRUIT.instantiate()
		fruit.position = get_random_position()
		
		fruits.append(fruit)
		fruit.connect("exited_screen", _on_fruit_exited_screen)
		fruit.connect("hit", _on_fruit_hit)
		
		fruit_timers.append(randf())


func get_random_position() -> Vector2:
	return curve.sample_baked(randf_range(0, curve_legth))


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
	erase_fruit(fruit)


func _on_fruit_hit(fruit: Fruit) -> void:
	fruit.modulate = Color.AQUAMARINE
