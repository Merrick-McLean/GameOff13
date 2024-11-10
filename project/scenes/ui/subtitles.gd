class_name Subtitles
extends Control

signal line_finished

const DEFAULT_SPEED := 1.0

var regex = RegEx.new()
var speed := DEFAULT_SPEED
var line : ParsedLine :
	set(new_value):
		line = new_value
		
		if line:
			label.text = line.text
		else:
			label.text = ""
		
var char_index := 0.0 :
	set(new_value):
		char_index = new_value
		label.visible_characters = floor(char_index)

var current_speaker : Dialogue.Actor

@onready var label : RichTextLabel = $Label

func _ready() -> void:
	regex.compile("(\\[set [_a-zA-Z]\\w*=\\w+\\])|(\\[call [_a-zA-Z]\\w*])")


func init_new_line(new_speaker: Dialogue.Actor, unparsed_line: String) -> void:
	current_speaker = new_speaker
	line = parse_line(unparsed_line)
	speed = DEFAULT_SPEED

func parse_line(new_line: String) -> ParsedLine:
	var regex = RegEx.new()
	var commands := {}
	
	var regex_matches := regex.search_all(new_line)
	
	var offset := 0
	while true:
		var regex_match := regex.search(new_line, offset)
		
		if not regex_match:
			break
		
		var letter_index := regex_match.get_start()
		offset = regex_match.get_start()
		
		
		if not letter_index in commands:
			commands[letter_index] = []
		
		var command : String = regex_match.get_string()
		command = command.rstrip("]").lstrip("[")
		
		var function_parts := command.split(" ")
		
		if function_parts.size() != 2:
			continue
		
		# trim
		new_line = new_line.erase(regex_match.get_start(), regex_match.get_string().length())
		var function_type := function_parts[0]
		var function_arguments := function_parts[1]
		
		match function_type:
			"set":
				var parts := function_arguments.split("=")
				var variable_name := parts[0]
				var value_name := parts[0]
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
				
				commands[letter_index].append(func() -> void: set(variable_name, value))
			"call":
				var method_name := function_arguments
				commands[letter_index].append(func() -> void: call(method_name))
	
	var parsed_line := ParsedLine.new()
	parsed_line.text = new_line
	parsed_line.commands = commands
	
	return parsed_line


func _process(delta: float) -> void:
	if line and not at_end_of_line():
		talk(delta)


func talk(delta: float) -> void:
	assert(not at_end_of_line())
	
	var old_char_i : int = floor(char_index)
	char_index += speed * delta
	var char_i : int = floor(char_index)
	
	for i in range(old_char_i, char_i):
		for command: Callable in line.commands.get(i, []):
			command.call()
	
	if at_end_of_line():
		line_finished.emit()

func at_end_of_line() -> bool:
	return label.visible_ratio >= 1.0



class ParsedLine:
	var text := ""
	var commands := {}
