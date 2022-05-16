extends ParallaxBackground


var p_layers = []
var motion_sacle = [0.1, 0.12, 0.15, 0.2, 0.5, 0.8]

func _process(delta: float) -> void:
	for i in range(len(get_children())):
		get_children()[i].motion_offset.x += delta * motion_sacle[i] * -10
