extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var tween = get_node("Tween")
# Called when the node enters the scene tree for the first time.

func _unhandled_input(event):
	if Input.is_action_pressed("ui_accept"):
		if tween.is_active():
			tween.stop_all()
		else:
			tween.interpolate_property($sprite, "position",
					Vector2(0, 0), Vector2(100, 100), 1,
					Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			tween.interpolate_property($sprite, "scale",
					Vector2(1.0,1.0), Vector2(1.5,1.5), 1,
					Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
#			tween.repeat = true
			tween.start()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
