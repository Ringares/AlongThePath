extends Node

var ROW = 0
var COL = 0

class Matches:
	var matches = []
	var best_match = null
	
	func append(m: Match):
		matches.append(m)
		if best_match == null or m.count >= best_match.count:
			best_match = m
	
	func size():
		return matches.size()
			
	
class Match:
	var index1 = null
	var index2 = null
	var count = 0

	func _init(_index1, _index2, _count):
		index1 = _index1
		index2 = _index2
		count = _count
	
	func _to_string():
		return "%s<->%s:%s" % [index1, index2, count] 

func is_match_at_index(index: Vector2, type: String, block_list):
	"""
	find matches in row and col
	return [row_matched, col_matched]
	"""
	var row_matched = []
	var col_matched = []
	
	#iter to left
	var t = index.y - 1
	while t >= 0:
		var block = block_list[index.x][t]
		if block != null and block.type == type:
			col_matched.append(block)
			t -= 1
		else:
			break
#
	#iter to right
	t = index.y + 1
	while t <= COL -1:
		var block = block_list[index.x][t]
		if block != null and block.type == type:
			col_matched.append(block)
			t += 1
		else:
			break

	#iter to down
	t = index.x - 1
	while t >= 0:
		var block = block_list[t][index.y]
		if block != null and block.type == type:
			row_matched.append(block)
			t -= 1
		else:
			break

	#iter to up
	t = index.x + 1
	while t <= ROW -1:
		var block = block_list[t][index.y]
		if block != null and block.type == type:
			row_matched.append(block)
			t += 1
		else:
			break

#	print('row_matched ', row_matched)
#	print('col_matched ', col_matched)
	return [row_matched, col_matched]

func search_matches(block_list):
	var matches = Matches.new()
	for i in range(COL):
		for j in range(ROW):
			var b_index = Vector2(i,j)
			var b_type = block_list[i][j].type
			# 判断向右
			if i < COL-1:
				var b2_index = Vector2(i+1,j)
				var b2_type = block_list[i+1][j].type
				swap_index(b_index, b2_index, block_list)
				var cnt = 0
				var match_res = is_match_at_index(b_index, b2_type, block_list)
				cnt += len(match_res[0]) if len(match_res[0]) >= 2 else 0
				cnt += len(match_res[1]) if len(match_res[1]) >= 2 else 0
				cnt += 1 if cnt > 0 else 0
				match_res = is_match_at_index(b2_index, b_type, block_list)
				cnt += len(match_res[0]) if len(match_res[0]) >= 2 else 0
				cnt += len(match_res[1]) if len(match_res[1]) >= 2 else 0
				cnt += 1 if cnt > 0 else 0
				
				if cnt > 0:
					matches.append(Match.new(b_index, b2_index, cnt))
				swap_index(b_index, b2_index, block_list)
			
			#判断向下
			if j < ROW-1:
				var b2_index = Vector2(i,j+1)
				var b2_type = block_list[i][j+1].type
				swap_index(b_index, b2_index, block_list)
				var cnt = 0
				var match_res = is_match_at_index(b_index, b2_type, block_list)
				cnt += len(match_res[0]) if len(match_res[0]) >= 2 else 0
				cnt += len(match_res[1]) if len(match_res[1]) >= 2 else 0
				cnt += 1 if cnt > 0 else 0
				match_res = is_match_at_index(b2_index, b_type, block_list)
				cnt += len(match_res[0]) if len(match_res[0]) >= 2 else 0
				cnt += len(match_res[1]) if len(match_res[1]) >= 2 else 0
				cnt += 1 if cnt > 0 else 0
				
				if cnt > 0:
					matches.append(Match.new(b_index, b2_index, cnt))
				swap_index(b_index, b2_index, block_list)
	return matches
			
func swap_index(index1, index2, block_list):
	var t = block_list[index1.x][index1.y]
	block_list[index1.x][index1.y] = block_list[index2.x][index2.y]
	block_list[index2.x][index2.y] = t
