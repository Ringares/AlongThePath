extends Control
class_name BattleIndicator

var type_cnts = {
		'attack':0,
		'shield':0,
		'energy':0,
		'scan':0,
	}

var block_indicator = preload("res://Scenes/UIScenes/BlockIndicator.tscn")
onready var container = $HBoxContainer

func _ready():
	for name in type_cnts:
		var b = block_indicator.instance()
		b.name = name
		container.add_child(b)
		b.get_node("TextureRect").texture = load("res://Asserts/Environment/Props/jelly/block_"+name+"_jelly.png")
	reset_info()
	
func reset_info():
	for b in container.get_children():
		b.visible = false
	
func update_info(type_cnts):
	for type in type_cnts.keys():
		if type_cnts[type] > 0:
			container.get_node(type).visible=true
			container.get_node(type).get_node("Label").text = str(type_cnts[type])
		else:
			container.get_node(type).visible=false
			

func get_golbal_pos():
	return container.rect_global_position + container.rect_size / 2
