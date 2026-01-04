extends Node


func time_to_string(time: float, hanging_zero := true, show_ms := false, ommit_hours := true) -> String:
	var seconds := int(time)
	var milliseconds := time - seconds
	
	@warning_ignore("integer_division")
	var hours := seconds / 3600
	seconds %= 3600
	@warning_ignore("integer_division")
	var minutes := seconds / 60
	seconds %= 60

	var format := "%02d:%02d"
	var values := [minutes, seconds]
	if not ommit_hours or hours:
		format = "%02d:" + format
		values.push_front(hours)
	if show_ms:
		format += ".%02d"
		values.push_back(milliseconds)
	if not hanging_zero:
		format = format.remove_chars("02")
	
	return format % values
