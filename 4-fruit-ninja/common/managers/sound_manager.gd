extends Node



func play(audio_stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = audio_stream
	player.finished.connect(func(): player.queue_free())
	
	add_child(player)
	player.play()
