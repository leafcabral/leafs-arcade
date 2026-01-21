class_name FruitButton
extends Button


signal pressed_and_animated

enum Type {
	CONFIRM,
	BACK
}

@export var type := Type.CONFIRM
@export var should_spin := true

var fruit: Fruit
var _original_velocity: Vector2


func _ready() -> void:
	if type == Type.CONFIRM:
		fruit = Fruit.create_random_normal()
	else:
		fruit = Fruit.create_bomb()
	if should_spin:
		fruit.apply_random_spin()
	fruit.gravity_scale = 0
	
	fruit.connect("sliced", _on_fruit_sliced)
	add_child(fruit)
	
	fruit.position += fruit.sprite.get_size() / 2
	_original_velocity = fruit.linear_velocity
	fruit.linear_velocity = Vector2.ZERO
	
	size = fruit.sprite.get_size()


func _on_fruit_sliced(_fruit: Fruit) -> void:
	handle_interaction()


func _on_pressed() -> void:
	handle_interaction()


func handle_interaction() -> void:
	if fruit.type == Fruit.Type.NORMAL:
		fruit.linear_velocity.x = _original_velocity.x
		fruit.gravity_scale = 1
		for i in fruit.create_slices():
			call_deferred("add_child", i)
		
		fruit.queue_free()
	elif fruit.type == Fruit.Type.BOMB:
		fruit.connect("exploded", func(bomb: Fruit): bomb.queue_free())
		fruit.explode()
	pressed_and_animated.emit()
