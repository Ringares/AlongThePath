extends Node
class_name BattleManager


onready var battle_hud:BattleHUD = $BattleHUD
onready var battle_area:BattleArea = $BattleArea
onready var move_confirm_timer = $MoveConfirmTimer

var curr_indicator: BattleIndicator = null
var curr_charctor: Charactor = null
var curr_charctor_ui: CharactorUI = null

var block_attack = preload("res://Scenes/BlockScenes/BlockAttack.tscn")

var player: Charactor = null
var enemy: Charactor = null
var remaining_turn := 1

var combo_cnt := 0
var type_cnts = {
		'attack':0,
		'shield':0,
		'energy':0,
		'scan':0,
	}

enum TURN {PLAYER, ENEMY}
var turn_state = TURN.PLAYER


func _ready():
	DebugDisplay.add_property(self, "turn_state")
	DebugDisplay.add_property(self, "remaining_turn")
	DebugDisplay.add_property(self, 'combo_cnt')
	
	GameEvent.connect("skill_pressed", self, "_on_skill_pressed")
	GameEvent.connect("skill_execute", self, "_on_skill_execute")
	GameEvent.connect("collect_block", self, "_on_BattleArea_collect_block")

	# for test
	player = Charactor.new('tractor')
	enemy = Charactor.new('sellmachine')
	load_charactor()

	AudioManager.emit_signal("play_music_battle")


func load_charactor():
	battle_hud.player_ui.bind(player)
	battle_hud.enemy_ui.bind(enemy)
	curr_indicator = battle_hud.player_indicator
	curr_charctor = player
	curr_charctor_ui = battle_hud.player_ui


func switch_turn():
	remaining_turn -= 1
	
	if remaining_turn == 0:
		remaining_turn = 1
		turn_state = 1 - turn_state
		if turn_state == TURN.ENEMY:
			battle_hud.turn_indicator.show_enemy_turn()
			curr_indicator = battle_hud.enemy_indicator
			curr_charctor_ui = battle_hud.enemy_ui
			curr_charctor = enemy
			yield(get_tree().create_timer(2.0), "timeout")
			battle_area.enable_auto = true
		elif turn_state == TURN.PLAYER:
			AudioManager.emit_signal("play_effect_switch2player")
			battle_hud.turn_indicator.show_player_turn()
			curr_indicator = battle_hud.player_indicator
			curr_charctor_ui = battle_hud.player_ui
			curr_charctor = player
			battle_area.enable_auto = false
		
	battle_area.game_state = battle_area.IDEL


func _on_BattleArea_collect_block(type, type_cnt):
	"""
	type: String, attack/shield/energy/scan
	"""
	print("on_BattleArea_collect_block", type, type_cnt)
	if combo_cnt ==0 and type_cnt >= 4:
		remaining_turn += 1
		battle_hud.turn_indicator.show_extra_move()
	move_confirm_timer.start(1.5)
	if type in type_cnts.keys():
		type_cnts[type] += type_cnt
	curr_indicator.update_info(type_cnts)
	combo_cnt += 1


func _on_MoveConfirmTimer_timeout() -> void:
	print('_on_MoveConfirmTimer_timeout')
	
	show_attack()
	
	yield(get_tree().create_timer(1.5), "timeout")
	combo_cnt = 0
	if turn_state == TURN.PLAYER:
		player.boost_shield(type_cnts['shield'])
		player.boost_energy(type_cnts['energy'])
		player.boost_scan(type_cnts['scan'])
		enemy.take_attack(type_cnts['attack'])
	
	if turn_state == TURN.ENEMY:
		enemy.boost_shield(type_cnts['shield'])
		enemy.boost_energy(type_cnts['energy'])
		enemy.boost_scan(type_cnts['scan'])
		player.take_attack(type_cnts['attack'])

	
	battle_hud.player_ui.update_ui()
	battle_hud.enemy_ui.update_ui()
	curr_indicator.reset_info()
	
	print(type_cnts.values(), type_cnts.values().max())
	switch_turn()
	reset_info()


func reset_info():
	type_cnts = {
		'attack':0,
		'shield':0,
		'energy':0,
		'scan':0,
	}
	

func show_attack():
	var attack_from = Vector2.ZERO
	var attack_to = Vector2.ZERO
	var absorb_to = Vector2.ZERO
	if turn_state == TURN.PLAYER:
		attack_from = battle_hud.player_indic_glb_pos()
		attack_to = battle_hud.enemy_ui_glb_pos()
		absorb_to = battle_hud.player_ui_glb_pos()
	elif turn_state == TURN.ENEMY:
		attack_from = battle_hud.enemy_indic_glb_pos()
		attack_to = battle_hud.player_ui_glb_pos()
		absorb_to = battle_hud.enemy_ui_glb_pos()
	
	for type in type_cnts.keys():
		for i in range(type_cnts[type]):
			var attack_block = block_attack.instance()
			add_child(attack_block)
			attack_block.set_type(type)
			if type == 'attack':
				attack_block.attack_to(attack_from, attack_to)
			else:
				attack_block.attack_to(attack_from, absorb_to)
			yield(get_tree().create_timer(0.1), "timeout")


func _on_skill_pressed(skill: Skill):
	if curr_charctor.energy >= skill.cost:
		battle_area.game_state = battle_area.SKILL
		battle_area.curr_skill = skill
	else:
		print("not enought energy")
		AudioManager.emit_signal("play_effect_no_energy")
		

func _on_skill_execute(skill: Skill):
	curr_charctor.energy -= skill.cost
	curr_charctor_ui.update_ui()
	battle_area.game_state = battle_area.RUNNING
#	skill.execute()
	pass
	
