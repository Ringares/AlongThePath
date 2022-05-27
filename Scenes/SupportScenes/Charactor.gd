extends Object

class_name Charactor

var max_hp
var max_shield
var max_energy
var max_scan
var hp
var shield
var energy
var scan

var loots = []
var items = []
var abilities = ["BombSkill", "LightningSkill", "ShieldSkill"]

func _init(name):
	var c_data = GameData.CharactorData[name]
	max_hp = int(c_data['hp'])
	max_shield = int(c_data['shield'])
	max_energy = int(c_data['energy'])
	max_scan = int(c_data['scan'])

	hp = max_hp
	shield = 0
	energy = 0
	scan = 0

func take_attack(v):
	var shield_delta = min(shield, v)
	var remain_attack = v - shield_delta
	shield = shield - shield_delta
	hp = max(0, hp - remain_attack)

func boost_shield(v):
	shield = min(max_shield, shield+v)

func boost_energy(v):
	energy = max(min(max_energy, energy+v),0)

func boost_scan(v):
	scan = max(min(max_scan, scan+v),0)
	
func _to_string():
	return "%s,%s,%s,%s" % [hp, shield, energy, scan]
