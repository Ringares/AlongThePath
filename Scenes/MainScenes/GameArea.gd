extends Node2D

signal debug_info(info)
signal delete_blocks
signal drop_blocks(blocks)
signal fill_blocks

# game setting
var ROW = 6
var COL = 6
var width = 0
var height = 0

var block_list = []
var blocks = [
	preload("res://Scenes/MainScenes/B_fire.tscn"),
	preload("res://Scenes/MainScenes/B_flash.tscn"),
	preload("res://Scenes/MainScenes/B_forest.tscn"),
	preload("res://Scenes/MainScenes/B_water.tscn"),
#	preload("res://Scenes/MainScenes/B_earth.tscn"),
]

# controling
var is_touching = false
var is_active = true
var press_pos = Vector2.ZERO
var release_pos = Vector2.ZERO
var move_direction = Vector2.ZERO

# game info
var combo_cnt = 0

func _ready():
	connect("delete_blocks", self, "_on_block_destroy")
	connect("drop_blocks", self, "_on_block_drop")
	connect("fill_blocks", self, "_on_block_fill")

	DebugDisplay.add_property(self, 'combo_cnt', '')
	DebugDisplay.add_property(self, 'is_active', '')
	
	randomize()
	var width_height : Vector2 = get_viewport_rect().size
	width = width_height.x
	height = width_height.y
	print(width, height)
	
	var BG_margin = 10
	$BG.rect_position = Vector2(width/2 - 64*COL/2 - BG_margin, height/2 - 64*ROW/2 - BG_margin)
	$BG.rect_size = Vector2(64*COL+2*BG_margin, 64*ROW+2*BG_margin)
	
	# init 2d array
	for i in range(COL):
		block_list.append([])
		for j in range(ROW):
			block_list[i].append(null)
	init_game()
	
func _process(delta):
	if is_active:
		if Input.is_action_just_pressed("ui_touch"):
			is_touching = true
			press_pos = get_global_mouse_position()
			
			var press_index = pos2index(press_pos)
			print("==>\n",press_index)
			if press_index != null and get_block(press_index) != null:
				print(index2pos(pos2index(press_pos)))
				print(get_block(press_index).desc())
				is_match_at_index(pos2index(press_pos), 'fire')
				
		if Input.is_action_just_released("ui_touch"):
			is_touching = false
			
			if move_direction != Vector2.ZERO:
				is_active = false
				var index1 = pos2index(press_pos)
				var index2 = index1 + move_direction
				if is_valid_index(index2):
					exchange_block(index1, index2)
					# check_match
					var is_matched1 = match_blocks(get_block(index1))
					var is_matched2 = match_blocks(get_block(index2))
					if not (is_matched1 or is_matched2):
						yield(get_tree().create_timer(0.35), "timeout")
						exchange_block(index1, index2)
						is_active = true
					else:
						emit_signal("delete_blocks")
					
		
	
func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	if is_touching and pos2index(mouse_pos) != pos2index(press_pos):
		move_direction = ControlUtils.get_move_direction(press_pos, mouse_pos)
	else:
		move_direction = Vector2.ZERO
		

func init_game():
	for i in range(COL):
		for j in range(ROW):
			var is_matched = true
			var new_block
			while is_matched:
				new_block = blocks[randi() % len(blocks)].instance()
				var match_res = is_match_at_index(Vector2(i, j), new_block.type)
				is_matched = len(match_res[0]) >= 2 or len(match_res[1]) >= 2
				
			block_list[i][j] = new_block
			$BlockContainer.add_child(new_block)
			new_block.b_index = Vector2(i, j)
			new_block.position = index2pos(new_block.b_index)
	
func exchange_block(index1:Vector2, index2:Vector2):
	var block1 = block_list[index1.x][index1.y]
	var block2 = block_list[index2.x][index2.y]
	var direction = block2.b_index - block1.b_index
	move_block(block1, direction)
	move_block(block2, -direction)

func move_block(block, direction:Vector2, step=1, set_null=false):
	var pre_index = block.b_index
	var post_index = block.b_index + direction * step
	var pre_pos = block.position
	var post_pos = block.position + direction * step * 64
	
	block.tween_pos_to(post_pos)
	block_list[post_index.x][post_index.y] = block
	block.b_index = post_index
	if set_null:
		block_list[pre_index.x][pre_index.y] = null

func match_blocks(block):
	"""
	mask del and drop
	"""
	var is_match = false
	var match_res = is_match_at_index(block.b_index, block.type)
	var row_matched = match_res[0]
	var col_matched = match_res[1]
	if len(row_matched) >= 2 :
		is_match = true
		block.state = 'del'
		for b in row_matched:
			b.state = 'del'
	
	if len(col_matched) >= 2 :
		block.state = 'del'
		is_match = true
		for b in col_matched:
			b.state = 'del'
	return is_match

func fill_blank(index: Vector2):
	pass
	
func is_match_at_index(index: Vector2, type: String):
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
		
	
func index2pos(index: Vector2):
	var zero_pos = Vector2(width/2-64*COL/2, height/2-64*ROW/2)
	return Vector2(zero_pos.x + 64*index.x, zero_pos.y + 64*index.y)
	
func pos2index(pos: Vector2):
	var zero_pos = Vector2(width/2-64*COL/2, height/2-64*ROW/2)
	var rel_x = pos.x - zero_pos.x
	var rel_y = pos.y - zero_pos.y
	
	var index = Vector2(floor(rel_x/64), floor(rel_y/64))
	return index if is_valid_index(index) else null
	
func is_valid_index(index:Vector2):
	if index.x < 0 or index.x > COL-1:
		return false
	if index.y < 0 or index.y > ROW-1:
		return false
	return true
	
func get_block(index: Vector2):
	return block_list[index.x][index.y]
	
func _on_block_destroy():
	var delete_blocks = []
	var drop_blocks = []
	for i in range(COL):
		for j in range(ROW):
			var b = block_list[i][j]
			if b !=null and b.state == 'del':
				b.shake()
				b.modulate = Color(1,1,1,0.5)
				delete_blocks.append(b)
				
				for r in range(b.b_index.y):
					var above_block = block_list[b.b_index.x][r]
					if above_block != null and above_block.state in ['normal', 'drop']:
						print(b.b_index.x, ' ', r)
						above_block.state = 'drop'
						above_block.drop_step += 1
						if !drop_blocks.has(above_block):
							drop_blocks.append(above_block)
	if len(delete_blocks) == 0:
		return
	else:
		combo_cnt += 1
	
	yield(get_tree().create_timer(0.2), "timeout")
	for b in delete_blocks:
		b.queue_free()
		block_list[b.b_index.x][b.b_index.y] = null
	
	emit_signal("drop_blocks", drop_blocks)
	

	
func _on_block_drop(drop_blocks):
	yield(get_tree().create_timer(0.2), "timeout")
	for i in range(drop_blocks.size()-1, -1, -1):
		var b = drop_blocks[i]
		print('drop ', b.desc())
		move_block(b, Vector2.DOWN, b.drop_step, true)
		b.state = 'normal'
		b.drop_step = 0
	var is_match = false
	for b in drop_blocks:
		is_match =  match_blocks(b) or is_match
	if is_match:
		emit_signal("delete_blocks")
	else:
		# fill
		yield(get_tree().create_timer(0.2), "timeout")
		emit_signal("fill_blocks")
	
func _on_block_fill():
	var is_match = false
	for i in range(COL):
		for j in range(ROW-1, -1, -1):
			if block_list[i][j] == null:
				print('fill ', i, j)
				var new_block = blocks[randi() % len(blocks)].instance()
					
				block_list[i][j] = new_block
				$BlockContainer.add_child(new_block)
				new_block.b_index = Vector2(i, j)
#				new_block.position = index2pos(new_block.b_index)
	
				new_block.position = index2pos(Vector2(i,j)) - Vector2(0, 64)
				new_block.tween_pos_to(index2pos(new_block.b_index))
				is_match = match_blocks(new_block) or is_match
	if is_match:
		emit_signal("delete_blocks")
	else:
		combo_cnt = 0
		is_active = true
		
	
	
	

