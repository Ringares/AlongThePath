extends Node2D

onready var tween = $Tween
onready var node = $Sprite
onready var trail = $Trail
var show_trail = false
var type = null

func _unhandled_input(event):
	if Input.is_action_pressed("ui_accept"):
		set_type('attack')
		attack_to(node.position, get_global_mouse_position())


func _process(delta: float) -> void:
	if show_trail:
		trail.add_point(node.global_position)
		print(trail.get_point_count())
		while trail.get_point_count() > 20:
			trail.remove_point(0)
	

func set_type(_type):
	type = _type
	node.texture = load("res://Asserts/Environment/Props/jelly/block_"+type+"_jelly.png")
	node.modulate = Color(1,1,1,0)
	

func attack_to(from: Vector2, to: Vector2):
	var speed = 1
	node.position = from
	tween.interpolate_property(node, 'position', from, to, speed, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	tween.interpolate_property(node, 'rotation_degrees', 0, 1800, speed, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(node, 'scale', node.scale, node.scale * 0.2, speed, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(node, 'modulate:a', 1, 0.2, speed, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	show_trail = true



func _on_Tween_tween_all_completed() -> void:
	if type == 'attack':
		AudioManager.emit_signal("play_effect_hit")
		
	self.queue_free()
