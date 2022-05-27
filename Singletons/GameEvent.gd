extends Node


signal delete_blocks
signal drop_blocks(blocks)
signal fill_blocks

signal collect_block(type, type_cnt) # 某个种类被消除时

#signal attack_evaluate(type_cnt)  # 攻击结算


# 技能相关
signal skill_pressed(skill_obj)
signal skill_execute(skill_obj)



