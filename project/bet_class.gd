extends Node

#class_name bet

class Bet:
	var cur_pid: int
	var cur_amount: int
	var cur_value: int
	
	# can I make this an object with bet.value and bet.amount ??? will the class return these like that outside of this class? recall - talk to ahren
	func _init() -> void:
		self.cur_pid = 0
		self.cur_amount = 0
		self.cur_value = 0
		pass

	# we can also use this for allowing the button/values to be entered in the game - hence why it is a stand alone function
	func _check_cur_bet(amount: int, value: int) -> bool: 
		if (self.cur_amount < amount) || (self.cur_value < value && value <= 6): # do we want more restrictive rules?
			return true
		else:
			return false
	
	func _set_cur_bet(amount: int, value: int) -> void: 
		if _check_cur_bet(amount, value):
			self.cur_amount = amount
			self.cur_value = value
		pass
	
	func _next_turn() -> void:
		if(self.cur_pid == 3):
			self.cur_pid = 0
		else:
			self.cur_pid += 1
		pass
	
	# do we needn a _get_cur_bet()? How would it return the two values? Dict with pid, cur, amount?
	
	func _det_lie() -> bool:
		#_get_cur_amount()
		#_get_cur_value()
		#_get_table()
		# set weighted chance based on table values and amount (e.g. 1 = 0.001 change, 20 = 100%)
		return false
	
		
	### SETTER AND GETTERS ###
	func _get_pid() -> int:
		return self.cur_pid
	
	func _get_value() -> int:
		return self.cur_value
	
	func _get_amount() -> int:
		return self.cur_amount
	
	func _set_pid(pid) -> void: # could be += 1 on current or back to 0 to loop through
		self.cur_bet = pid
		pass
		
	func _set_value(value) -> void:
		self.cur_value = value
		pass
	
	func _set_amount(amount) -> void:
		self.cur_amount = amount
		pass

### DEFAULT ###
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
