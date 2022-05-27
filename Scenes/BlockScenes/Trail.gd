extends Line2D


func _process(delta: float) -> void:
	add_point(get_parent().global_position)
	while get_point_count() > 50:
		remove_point(0)
