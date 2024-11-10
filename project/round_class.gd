extends Node

#get_node(res://scenes/dice_roll.gd)

class_name round

class Round:
	# based on bets and player dice, used for npc bets and liar calls
	var table: Dictionary

	func _init() -> void:
		# reset table values
		table = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0}
		pass

	func _start_round() -> void:
		table = _get_table()
		values = dice_roll._create_player_dice() # signal?
		for i in values:
			table[i] += 1
		_set_table(table)
	
	# returns the current prospective
	func _get_table() -> Dictionary:
		return self.table

	# updates the expected values based on bets made by the npcs
	func _set_table(table: Dictionary) -> void:
		self.table = table
		pass

### DEFAULT ###
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
