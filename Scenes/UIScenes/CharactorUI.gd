extends Control
class_name CharactorUI

onready var hp_bar = $HBoxContainer/VBoxContainer/HPBar
onready var shield_bar = $HBoxContainer/VBoxContainer/ShieldBar
onready var energy_bar = $HBoxContainer/EnergyBar
onready var skill_container = $HBoxContainer/SkillBox

onready var tween = $Tween
onready var anim = $AnimationPlayer

var character: Charactor = null

#func _unhandled_input(event):
#	if Input.is_action_pressed("ui_accept"):
#		energy_bar.material.set_shader_param('value', 10)

func bind(ch: Charactor):
	character = ch

	hp_bar.value = 100.0 * character.hp / character.max_hp
	shield_bar.value = 100.0 * character.shield / character.max_shield
	
	energy_bar.material = energy_bar.material.duplicate()
	energy_bar.material.set_shader_param('value', 100.0 * character.energy / character.max_energy)
	update_ui()
	update_skill_ui()


func update_ui():
	var is_hit = false
	var curr_hp = 100.0 * character.hp / character.max_hp
	var curr_shield = 100.0 * character.shield / character.max_shield
	if curr_hp < hp_bar.value or curr_shield < shield_bar.value:
		is_hit = true

	var curr_energy_r = energy_bar.material.get_shader_param('value')
	var energy_r = 100.0 * character.energy / character.max_energy
	tween.interpolate_property(hp_bar, 'value', hp_bar.value, curr_hp, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(shield_bar, 'value', shield_bar.value, curr_shield, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(energy_bar.material, 'shader_param/value', curr_energy_r, energy_r, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	if is_hit:
		anim.play("attacked")
		yield(get_tree().create_timer(1), "timeout")
		anim.stop()


func update_skill_ui():
	for skill_name in character.abilities:
		var skill = load("res://Scenes/SkillScene/" + skill_name + ".tscn").instance()
		skill_container.add_child(skill)


func get_ui_golbal_pos():
	return energy_bar.rect_global_position + energy_bar.rect_size / 2

	
