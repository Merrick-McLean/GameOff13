class_name Subtitles
extends Control

signal line_finished
signal line_continued

const DEFAULT_SPEED := 30.0

var regex : RegEx
var speed := DEFAULT_SPEED
var line : ParsedLine :
	set(new_value):
		line = new_value
		
		if line:
			label.text = line.text
		else:
			label.text = ""

var can_skip := true
var pause_time := 0.0
var char_index := 0.0 :
	set(new_value):
		char_index = new_value
		label.visible_characters = floor(max(char_index, 0.0))

var current_speaker : Dialogue.Actor

@onready var label : RichTextLabel = $Label

func _ready() -> void:
	regex = RegEx.new()
	#regex.compile("(\\[set [_a-zA-Z]\\w*=[\\w\\.]+\\])|(\\[call [_a-zA-Z]\\w*])")
	regex.compile("\\[.*?\\]")


func init_new_line(new_speaker: Dialogue.Actor, unparsed_line: String) -> void:
	current_speaker = new_speaker
	speed = DEFAULT_SPEED
	char_index = -1.0
	can_skip = true
	line = parse_line(unparsed_line)

func parse_line(new_line: String) -> ParsedLine:
	var commands := {}
	
	
	var offset := 0
	var untrimmed_amount := 0
	while true:
		var regex_match := regex.search(new_line, offset)
		
		if not regex_match:
			break
		
		var letter_index := regex_match.get_start()
		offset = regex_match.get_end()
		
		
		
		
		var command : String = regex_match.get_string()
		command = command.rstrip("]").lstrip("[")
		
		var function_parts := command.split(" ")
		
		if function_parts.size() != 2:
			untrimmed_amount += regex_match.get_string().length()
			continue
		
		# trim
		new_line = new_line.erase(regex_match.get_start(), regex_match.get_string().length())
		offset = regex_match.get_start()
		
		var function_type := function_parts[0]
		
		
		var command_index := letter_index - untrimmed_amount
		if not command_index in commands:
			commands[command_index] = []
		
		match function_type:
			"set":
				var function_arguments := function_parts[1]
				var parts := function_arguments.split("=")
				var variable_name := parts[0]
				var value_name := parts[1]
				var current_variable_value = get(variable_name)
				var value : Variant = value_name
				
				if current_variable_value is String:
					pass
				elif current_variable_value is int:
					value = int(value_name)
				elif current_variable_value is float:
					value = float(value_name)
				else:
					push_error("Variable type is not supported in dialogue setter")
				
				commands[command_index].append(func() -> void: set(variable_name, value))
			"call":
				var method_name := function_parts[1]
				commands[command_index].append(func() -> void: call(method_name))
			"unskippable":
				can_skip = false
	
	var parsed_line := ParsedLine.new()
	parsed_line.text = new_line
	parsed_line.commands = commands
	
	return parsed_line


func skip_to_end() -> void:
	char_index = INF


func _process(delta: float) -> void:
	if line:
		if not at_end_of_line():
			if can_skip and Input.is_action_just_pressed(&"interact"):
				skip_to_end()
			elif pause_time <= 0.0:
				talk(delta)
			else:
				pause_time = max(pause_time - delta, 0.0)
		else:
			if Input.is_action_just_pressed(&"interact"):
				line_continued.emit()
		
		 


func talk(delta: float) -> void:
	assert(not at_end_of_line())
	
	var old_char_i : int = floor(char_index)
	char_index += speed * delta
	var char_i : int = floor(char_index)
	
	for i in range(old_char_i + 1, char_i + 1):
		for command: Callable in line.commands.get(i, []):
			command.call()
	
	if at_end_of_line():
		line_finished.emit()

func at_end_of_line() -> bool:
	return label.visible_ratio >= 1.0 or label.visible_characters <= -1



class ParsedLine:
	var text := ""
	var commands := {}
