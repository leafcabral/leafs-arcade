extends Control


signal paused
signal unpaused


var state_paused := false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if state_paused:
			paused.emit()
			$Paused.show()
		else:
			unpaused.emit()
			$Paused.hide()
		state_paused = not state_paused


func reset_player_score():
	$"Score P1".text = "0"
	$"Score P2".text = "0"


func update_player_score(scores: Dictionary[String, int], prefix := "p"):
	$"Score P1".text = str(scores[prefix + "1"])
	$"Score P2".text = str(scores[prefix + "2"])


func show_message(text: String):
	$Message.text = text
	$Message.show()
	$Message/ClearTimer.start()


func _on_clear_timer_timeout() -> void:
	$Message.hide()
