extends Node2D

onready var follower = $Path2D/PathFollow2D
onready var follower_sprite = $Path2D/PathFollow2D/BlockEnergyJelly
onready var tween = $Tween

func _ready() -> void:
	tween.interpolate_property(follower, 'unit_offset', 0, 1, 2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property(follower_sprite, 'rotation_degrees', 0, 3600, 2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property(follower_sprite, 'scale', follower_sprite.scale, follower_sprite.scale * 0.2, 2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property(follower_sprite, 'modulate:a', 1, 0.5, 2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
