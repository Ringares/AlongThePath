extends Control


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
	for name in type_cnts:
		type_cnts[name] = 0
	for b in container.get_children():
		b.visible = false
	
func update_info(type):
	if type in type_cnts.keys():
		type_cnts[type] += 1
		
		for name in type_cnts:
			if type_cnts[name] > 0:
				print("refresh_display ", name, type_cnts[name])
				container.get_node(name).visible=true
				container.get_node(name).get_node("Label").text = str(type_cnts[name])
			else:
				container.get_node(name).visible=false
