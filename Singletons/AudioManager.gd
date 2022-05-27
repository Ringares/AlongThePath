extends Node

# Audio signals
signal play_effect_delete_block
signal play_effect_drop_block
signal play_effect_switch2player
signal play_effect_hit
signal play_effect_no_energy
signal play_music_battle

var num_players = 8
var bus = "master"

var available = []  # The available players.
var queue = []  # The queue of sounds to play.


func _ready():
	# Create the pool of AudioStreamPlayer nodes.
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.connect("finished", self, "_on_stream_finished", [p])
		p.bus = bus
		
	connect("play_effect_delete_block", self, "_on_play_effect_delete_block")
	connect("play_effect_drop_block", self, "_on_play_effect_drop_block")
	connect("play_effect_switch2player", self, "_on_play_effect_switch2player")
	connect("play_effect_hit", self, "_on_play_effect_hit")
	connect("play_effect_no_energy", self, "_on_play_effect_no_energy")
	connect("play_music_battle", self, "_on_play_music_battle")


func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	available.append(stream)


func play(sound_path):
	queue.append(sound_path)


func _process(delta):
	# Play a queued sound if any players are available.
	if not queue.empty() and not available.empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()

func _on_play_effect_delete_block():
	play("res://Asserts/Sound/confirmation_001.ogg")


func _on_play_effect_drop_block():
	play("res://Asserts/Sound/drop_004.ogg")


func _on_play_effect_switch2player():
	pass


func _on_play_effect_hit():
	play("res://Asserts/Sound/Evade.wav")
	

func _on_play_effect_no_energy():
	pass


func _on_play_music_battle():
	play("res://Asserts/Sound/Music.mp3")
