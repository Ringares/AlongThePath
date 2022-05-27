extends Node2D
class_name BattleArea

signal delete_blocks
signal drop_blocks(blocks)
signal fill_blocks

# game setting
export var ROW = 6
export var COL = 6
var width = 0
var height = 0

var block_list = []
var blocks = [
	preload("res://Scenes/MainScenes/B_scan.tscn"),
	preload("res://Scenes/MainScenes/B_energy.tscn"),
	preload("res://Scenes/MainScenes/B_shield.tscn"),
	preload("res://Scenes/MainScenes/B_attack.tscn"),
	preload("res://Scenes/MainScenes/B_field.tscn"),
]


# controling
var is_touching = false
var press_pos = Vector2.ZERO
var release_pos = Vector2.ZERO
var move_direction = Vector2.ZERO


# game state
const IDEL = 'IDEL'
const RUNNING = 'RUNNING'
const SKILL = 'SKILL'
var game_state = IDEL
var enable_auto = false


# game info
var panel_pos = Vector2.ZERO
var panel_size = Vector2.ZERO


func _ready():
	MatchControl.ROW = ROW
	MatchControl.COL = COL
	
	connect("delete_blocks", self, "_on_block_destroy")
	connect("drop_blocks", self, "_on_block_drop")
	connect("fill_blocks", self, "_on_block_fill")

	DebugDisplay.add_property(self, 'game_state', '')
	
	randomize()
	var width_height : Vector2 = get_viewport_rect().size
	width = width_height.x
	height = width_height.y
	print(width, height)
	
	var BG_margin = 10
	$BG.rect_position = Vector2(width/2 - 64*COL/2 - BG_margin, height/2 - 64*ROW/2 - BG_margin)
	$BG.rect_size = Vector2(64*COL+2*BG_margin, 64*ROW+2*BG_margin)
	
	panel_pos = Vector2(width/2 - 64*COL/2, height/2 - 64*ROW/2)
	panel_size = Vector2(64*COL, 64*ROW)
	
	
	# init 2d array
	for i in range(COL):
		block_list.append([])
		for _j in range(ROW):
			block_list[i].append(null)
	init_game()


func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		#print(MatchControl.search_matches(block_list))
		enable_auto = !enable_auto
	
	if game_state == IDEL:
		game_state = RUNNING
		if enable_auto:
			var matches = MatchControl.search_matches(block_list)
			if matches.size() > 0:
				take_one_move(matches.best_match.index1, matches.best_match.index2)
			else:
				print("!!! No Matches")
				game_state = IDEL
		else:
			var unhandled = process_input_move(delta)
			if unhandled:
				game_state = IDEL
			else:
				pass
				
	# 技能激活, 选择目标
	elif game_state == SKILL:
		var unhandled = process_input_skill(delta)
		if unhandled:
			game_state = IDEL
		else:
			pass
			
			
	elif game_state == RUNNING:
		pass


func process_input_move(_delta) -> bool:
	"""
	return unhandled flag
	"""
	if Input.is_action_just_pressed("ui_touch"):
		is_touching = true
		press_pos = get_global_mouse_position()
		
		var press_index = pos2index(press_pos)
		print("==>\n",press_index)
		if press_index != null and get_block(press_index) != null:
			print(index2pos(pos2index(press_pos)))
			print(get_block(press_index).desc())
			
	if Input.is_action_just_released("ui_touch"):
		is_touching = false
		
		if move_direction != Vector2.ZERO and pos2index(press_pos) != null:
			var index1 = pos2index(press_pos)
			var index2 = index1 + move_direction
			if is_valid_index(index2):
				return take_one_move(index1, index2)
	return true


func process_input_skill(_delta) -> bool:
	if Input.is_action_just_pressed("ui_touch"):
		# 选定目标, 开始技能
		GameEvent.emit_signal("skill_execute")
	return true


func _physics_process(_delta):
	var mouse_pos = get_global_mouse_position()
	if is_touching and pos2index(mouse_pos) != pos2index(press_pos):
		move_direction = get_move_direction(press_pos, mouse_pos)
	else:
		move_direction = Vector2.ZERO


func init_game():
	for i in range(COL):
		for j in range(ROW):
			var is_matched = true
			var new_block
			while is_matched:
				new_block = blocks[randi() % len(blocks)].instance()
				var match_res = MatchControl.is_match_at_index(Vector2(i, j), new_block.type, block_list)
				is_matched = len(match_res[0]) >= 2 or len(match_res[1]) >= 2
				
			block_list[i][j] = new_block
			$BlockContainer.add_child(new_block)
			new_block.b_index = Vector2(i, j)
			new_block.position = index2pos(new_block.b_index)


func take_one_move(index1, index2):
	exchange_block(index1, index2)
	# check_match
	var is_matched1 = match_blocks(get_block(index1))
	var is_matched2 = match_blocks(get_block(index2))
	if not (is_matched1 or is_matched2):
		yield(get_tree().create_timer(0.35), "timeout")
		exchange_block(index1, index2)
	else:
		emit_signal("delete_blocks")
		return false
	return true


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
	var match_res = MatchControl.is_match_at_index(block.b_index, block.type, block_list)
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


func get_move_direction(from:Vector2, to:Vector2):
	var ang = Vector2.RIGHT.angle_to(to-from)
	if -PI/4 < ang and ang <= PI/4:
		return Vector2.RIGHT
	if PI/4 < ang and ang <= 3*PI/4:
		return Vector2.DOWN
	if 3*PI/4 < ang or ang <= -3*PI/4:
		return Vector2.LEFT
	if -3*PI/4 < ang and ang <= -PI/4:
		return Vector2.UP


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
	
	yield(get_tree().create_timer(0.2), "timeout")
	var deleted_type_cnt = {}
	for b in delete_blocks:
		deleted_type_cnt[b.type] = deleted_type_cnt.get(b.type, 0) + 1
		b.queue_free()
		block_list[b.b_index.x][b.b_index.y] = null
	for k in deleted_type_cnt.keys():
		GameEvent.emit_signal("collect_block", k, deleted_type_cnt[k])
		
	
	AudioManager.emit_signal("play_effect_delete_block")
	emit_signal("drop_blocks", drop_blocks)


func _on_block_drop(drop_blocks):
	yield(get_tree().create_timer(0.2), "timeout")
	for i in range(drop_blocks.size()-1, -1, -1):
		var b = drop_blocks[i]
#		print('drop ', b.desc())
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
	AudioManager.emit_signal("play_effect_drop_block")
	var is_match = false
	for i in range(COL):
		for j in range(ROW-1, -1, -1):
			if block_list[i][j] == null:
#				print('fill ', i, j)
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
