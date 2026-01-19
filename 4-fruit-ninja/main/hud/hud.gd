extends CanvasLayer


const MISSED_TRUE := preload("uid://4bjtxjfandrj")
const MISSED_FALSE := preload("uid://by4chl8jgl7l6")


@onready var misses: Array[Sprite2D] = [$Miss1, $Miss2, $Miss3]
@onready var misses_length := len(misses)


func reset_misses() -> void:
	for miss in misses:
		miss.texture = MISSED_FALSE


func set_misses(num_of_misses: int) -> void:
	for i in min(num_of_misses, misses_length):
		misses[i].texture = MISSED_TRUE
	for i in range(num_of_misses + 1, misses_length):
		misses[i].texture = MISSED_FALSE
	
