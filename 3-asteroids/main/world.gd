extends Node


signal score_increased(increase: int)


func _on_child_entered_tree(node: Node) -> void:
	if node is Asteroid:
		if not node.is_connected("asteroid_hit", _on_asteroid_hit):
			node.connect("asteroid_hit", _on_asteroid_hit)


func _on_asteroid_hit(size: int) -> void:
	score_increased.emit(int(100.0 / 2 ** (size - 1)))
