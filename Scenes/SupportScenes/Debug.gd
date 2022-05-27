extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var p = self.get_parent()


func _physics_process(delta):
	$Container.set_position(get_local_mouse_position())
	$Container/VB/MousePos.text = str(get_global_mouse_position())+'\n'+str(get_local_mouse_position())

func on_debug_info(info):
	print('on_debug_info1'+info)
	$Container/VB/DebugInfo.text = info
