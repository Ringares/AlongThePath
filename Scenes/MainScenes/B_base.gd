extends Node2D
class_name BBase

export(String) var type
var b_index = null

var state = 'normal' # normal, del, drop
var drop_step = 0

var tween = Tween.new()
var anim_player = null

func _ready():
	$Sprite.offset = Vector2(64,64)
	anim_player = get_node("AnimationPlayer")
	add_child(tween)
	
#func _unhandled_input(event):
#	if Input.is_action_pressed("ui_accept"):
##		tween_pos_to(Vector2.RIGHT)
#		if anim_player.is_playing():
#			anim_player.stop()
#		else:
#			shake()

func tween_pos_to(pos: Vector2):
	tween.interpolate_property(self, "position",
		self.position, pos, 0.2,
		Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()

func destroy():
	pass

func shake():
	if anim_player != null:
		anim_player.play("shake")
		
func desc():
	return 'type=%s at %s with %s, %s' % [type, b_index, state, drop_step]
