extends CanvasLayer


const MISSED_TRUE := preload("uid://4bjtxjfandrj")
const MISSED_FALSE := preload("uid://by4chl8jgl7l6")


@onready var misses: Array[Node] = $Misses.get_children()
@onready var misses_length := len(misses)
@onready var score_label: RichTextLabel = $Score/ScoreLabel
@onready var high_score_label: RichTextLabel = $Score/HighScoreLabel


func reset_misses() -> void:
	for miss in misses:
		miss.texture = MISSED_FALSE


func set_misses(num_of_misses: int) -> void:
	for i in min(num_of_misses, misses_length):
		misses[i].texture = MISSED_TRUE
	for i in range(num_of_misses + 1, misses_length):
		misses[i].texture = MISSED_FALSE


func update_score(score: int) -> void:
	score_label.text = str(score)


func update_high_score(high_score: int) -> void:
	const string_start := "[font_size=16][color=\"lightgreen\"]high score:\n"
	high_score_label.text = string_start + str(high_score)
