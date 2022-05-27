extends TextureButton
class_name Skill

export(Texture) var icon
export(String) var skill_name
export(int) var cooldown
export(int) var cost

onready var cooldown_progress = $CooldownProgress
onready var countdown_label = $CountdownLabel
onready var timer = $Timer

var curr_cooldown = 0


func _ready() -> void:
	self.texture_normal = icon
	cooldown_progress.max_value = cooldown
	cooldown_progress.value = curr_cooldown
	countdown_label.visible = false


func cooldown():
	curr_cooldown = max(curr_cooldown - 1, 0)
	cooldown_progress.value = curr_cooldown


func is_available(curr_energy: int):
	if curr_energy >= cost and curr_cooldown == 0:
		return true
	else:
		return false


func execute(block_array: Array, tar_index: Vector2, self_chara: Charactor, enemy_chara: Charactor):
	push_error("null implementation of execute")


func _on_Skill_pressed() -> void:
	print('_on_Skill_pressed: ', self)
	GameEvent.emit_signal("skill_pressed", self)

	$AnimationPlayer.play('active')
