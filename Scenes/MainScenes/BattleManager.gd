extends Node


onready var battle_hud = $BattleHUD
onready var battle_area = $GameArea

var combo_cnt = 0

func _ready():
	DebugDisplay.add_property(self, 'combo_cnt', '')
	battle_area.connect("collect_block", self, "on_BattleArea_collect_block")
	battle_hud.connect("attack_display_finished", self, "on_BattleHUD_attack_display_finished")
	
func on_BattleArea_collect_block(type):
	"""
	type: String, attack/shield/energy/scan
	"""
	battle_hud.process_attack(type)
	combo_cnt += 1

func on_BattleHUD_attack_display_finished(_type_cnts):
	"""
	type_cnts = {
		'attack':0,
		'shield':0,
		'energy':0,
		'scan':0,
	}
	"""
	combo_cnt = 0
	battle_area.game_state = battle_area.IDEL
	
