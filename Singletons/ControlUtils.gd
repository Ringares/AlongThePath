extends Node


func get_move_direction(from:Vector2, to:Vector2):
	var ang = Vector2.RIGHT.angle_to(to-from)
	if -PI/4 < ang and ang <= PI/4:
		return Vector2.RIGHT
	if PI/4 < ang and ang <= 3*PI/4:
		return Vector2.DOWN
	if 3*PI/4 < ang or ang <= -3*PI/4:
		return Vector2.LEFT
	if -3*PI/4 < ang and ang <= -PI/4:
		return Vector2.UP
