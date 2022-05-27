extends Node

func _ready():
	load_csv()
	print(CharactorData)
	
func load_csv():
	var file = File.new()
	file.open("res://Singletons/charactor.txt", file.READ)
	var header = null
	var datas = []
	while !file.eof_reached():
		var line = file.get_csv_line()
		if line.size() > 1:
			if header == null:
				header = Array(line)
			else:
				datas.append(Array(line))
	file.close()
	
	print(header)
	print(datas)
	for d in datas:
		var name = d[0]
		CharactorData[name] = {}
		for i in range(1, len(header)):
			CharactorData[name][header[i]] = d[i]

var CharactorData = {}
 
