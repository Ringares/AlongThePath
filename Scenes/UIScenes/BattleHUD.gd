extends Control

signal attack_display_finished(type_cnt)
signal underattack_display_finished(type_cnt)

onready var play_ui = $MarginContainer/VBoxContainer/PlayerUI
onready var ememy_ui = $MarginContainer/VBoxContainer/anchor/EnemyUI
onready var anchor = $MarginContainer/VBoxContainer/anchor
onready var play_indicator = $MarginContainer/VBoxContainer/PlayCollIndicator
onready var enemy_indicator = $MarginContainer/VBoxContainer/EnemyCollIndicator
onready var attack_confirm_timer = $ConfirmTimer
onready var curr_ui = play_ui
onready var curr_indicator = play_indicator


const PLAYER = 'PLAYER'
const ENEMY = 'ENEMY'
var round_state = PLAYER

func _ready():
	

	ememy_ui.set_position(Vector2(anchor.rect_size.x, 0))
	DebugDisplay.add_property(self, "round_state")
	
func switch_round_state():
	if round_state == PLAYER:
		round_state = ENEMY
		curr_ui = ememy_ui
		curr_indicator = enemy_indicator
	elif round_state == ENEMY:
		round_state = PLAYER
		curr_ui = play_ui
		curr_indicator = play_indicator

func process_attack(type):
	attack_confirm_timer.start(1.5)
	curr_indicator.update_info(type)

func _on_ConfirmTimer_timeout():
	emit_signal("attack_display_finished", curr_indicator.type_cnts.duplicate())
	curr_indicator.reset_info()
	switch_round_state()
