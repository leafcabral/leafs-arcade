extends Control


signal dog_jumped


var dog_tween: Tween

@onready var default_bg_color: Color = $ColorRect.color
@onready var dog_node := $Dog


func dog_sniff_and_walk():
	const POSITION_Y :=  470.0
	const SPRITE_OFFSET_X := 60.0
	const START_POSITION := Vector2(0 + SPRITE_OFFSET_X, POSITION_Y)
	const END_POSITION := Vector2(800 - SPRITE_OFFSET_X, POSITION_Y)
	
	cleanup_tween()
	dog_tween = create_tween()
	dog_node.position = Vector2(-82, POSITION_Y)
	dog_node.play("searching")
	
	dog_tween.set_loops()
	
	dog_tween.tween_property(dog_node, "position", END_POSITION, 3.0)
	dog_tween.parallel().tween_property(dog_node, "flip_h", false, 0.0)
	
	dog_tween.tween_property(dog_node, "position", START_POSITION, 3.0)
	dog_tween.parallel().tween_property(dog_node, "flip_h", true, 0.0)


func dog_jump():
	const JUMP_HEIGHT := 150.0
	const JUMP_OFFSET_X := 50.0
	const DISTANCE_JUMP_PEAK := Vector2(JUMP_OFFSET_X / 2, -JUMP_HEIGHT)
	const DISTANCE_JUMP_END := Vector2(JUMP_OFFSET_X, 0)
	
	cleanup_tween()
	dog_tween = create_tween()
	
	dog_tween.tween_callback(func(): dog_node.play("jump"))
	dog_tween.tween_property(
		dog_node, "position", dog_node.position + DISTANCE_JUMP_PEAK, 0.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	dog_tween.tween_property(dog_node, "z_index", 3, 0)
	dog_tween.tween_property(
		dog_node, "position", dog_node.position + DISTANCE_JUMP_END, 0.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	dog_tween.tween_callback(dog_node.hide)
	dog_tween.tween_callback(dog_jumped.emit)


func spawn_dog_with_bird(pos_x: int, num_of_birds: int = 1):
	dog_node.play("caught-" + str(clamp(num_of_birds, 1, 3)))
	spawn_dog_generic(pos_x)


func spawn_dog_laugh(pos_x: int):
	dog_node.play("laugh")
	spawn_dog_generic(pos_x)


func spawn_dog_generic(pos_x: int):
	const dog_caught_pos_y_start: int = 460
	const dog_caught_pos_y_end: int = 345
	
	dog_node.position.x = pos_x
	dog_node.z_index = 3
	
	cleanup_tween()
	dog_tween = create_tween()
	
	dog_tween.tween_callback(dog_node.show)
	dog_tween.tween_property(dog_node, "position:y", dog_caught_pos_y_end, 0.3)
	dog_tween.tween_interval(1.5)
	dog_tween.tween_property(dog_node, "position:y", dog_caught_pos_y_start, 0.3)
	dog_tween.tween_callback(dog_node.hide)


func cleanup_tween() -> void:
	if dog_tween:
		dog_tween.kill()
		dog_tween = null


func is_dog_spawned() -> bool:
	if dog_tween:
		return dog_tween.is_running()
	else:
		return false


func can_spawn_dog() -> bool:
	return not is_dog_spawned()


func change_bg_color(color: Color):
	$ColorRect.color = color
	await get_tree().create_timer(1).timeout
	$ColorRect.color = default_bg_color
