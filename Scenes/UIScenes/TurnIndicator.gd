extends ColorRect
class_name TurnIndicator


onready var enemy_turn_label = $EnemyTureLabel
onready var player_turn_label = $PlayerTurnLabel
onready var extra_move_label = $ExtraMoveLabel

var tween = Tween.new()

func _ready():
	add_child(tween)
	modulate = Color(1,1,1,0)


func show_player_turn():
	enemy_turn_label.visible = false
	player_turn_label.visible = true
	extra_move_label.visible = false
#	modulate = Color(1,1,1,1)
	tween.interpolate_property(self, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), 1.5,
		Tween.TRANS_QUINT, Tween.EASE_IN)
	tween.start()


func show_enemy_turn():
	enemy_turn_label.visible = true
	player_turn_label.visible = false
	extra_move_label.visible = false
#	modulate = Color(1,1,1,1)
	tween.interpolate_property(self, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), 1.5,
		Tween.TRANS_QUINT, Tween.EASE_IN)
	tween.start()


func show_extra_move():
	enemy_turn_label.visible = false
	player_turn_label.visible = false
	extra_move_label.visible = true
#	modulate = Color(1,1,1,1)
	tween.interpolate_property(self, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), 1.5,
		Tween.TRANS_QUINT, Tween.EASE_IN)
	tween.start()
