extends Control
class_name BattleHUD

export var ROW = 6
export var COL = 6

export(NodePath) onready var player_ui = get_node(player_ui) as CharactorUI
export(NodePath) onready var enemy_ui = get_node(enemy_ui) as CharactorUI
export(NodePath) onready var player_indicator = get_node(player_indicator) as BattleIndicator
export(NodePath) onready var enemy_indicator = get_node(enemy_indicator) as BattleIndicator
export(NodePath) onready var turn_indicator = get_node(turn_indicator) as TurnIndicator


func _ready() -> void:
#	$MarginContainer/VBoxContainer/CenterContainer/TurnIndicator.rect_position = Vector2(width/2 - 64*COL/2 - BG_margin, height/2 - 64*ROW/2 - BG_margin)
	var BG_margin = 10
	turn_indicator.rect_min_size = Vector2(64*COL+2*BG_margin, 64*ROW+2*BG_margin)
	
	
func enemy_ui_glb_pos():
	return enemy_ui.get_ui_golbal_pos()
	
func player_ui_glb_pos():
	return player_ui.get_ui_golbal_pos()
	
func player_indic_glb_pos():
	return player_indicator.get_golbal_pos()
	
func enemy_indic_glb_pos():
	return enemy_indicator.get_golbal_pos()
