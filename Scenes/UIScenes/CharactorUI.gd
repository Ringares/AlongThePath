extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var hp_bar = $HBoxContainer/VBoxContainer/HPBar
onready var shield_bar = $HBoxContainer/VBoxContainer/ShieldBar
onready var energy_bar = $HBoxContainer/EnergyBar

var max_hp = 0
var max_shield = 0
var max_energy = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	init_meters({
		'max_hp':100,
		'hp':100,
		'max_shield':100,
		'shield':100,
		'max_enegy': 100,
		'enegy': 0,
	})

func init_meters(data: Dictionary):
	max_hp = data['max_hp']
	hp_bar.max_value = data['max_hp']
	hp_bar.value = data['hp']
	
	max_shield = data['max_shield']
	shield_bar.max_value = data['max_shield']
	shield_bar.value = data['shield']
	
	max_energy = data['max_enegy']
	var enery_ratio = data['enegy'] / data['max_enegy'] * 100
	energy_bar.material.set_shader_param('value', enery_ratio)

func set_hp_display(v):
	hp_bar.value = v

func set_shield_display(v):
	hp_bar.value = v
	
func set_energy_display(v):
	var curr_ratio = energy_bar.material.get_shader_param('value') / 100
	var enery_ratio = (curr_ratio * max_energy + v) / max_energy * 100
	energy_bar.material.set_shader_param('value', enery_ratio)
