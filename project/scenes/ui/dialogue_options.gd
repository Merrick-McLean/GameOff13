class_name DialogueOptionsUI
extends Control

signal option_chosen(number: int)

const DialogueOptionUIScene = preload("res://scenes/ui/dialogue_option.tscn")
const DialogueOptionsSeparatorUIScene = preload("res://scenes/ui/dialogue_option_separator.tscn")

var dialogue_options : Array[DialogueOptionUI] = []

@onready var vbox : VBoxContainer = $VBoxContainer

func _ready() -> void:
	for i: int in range(Dialogue.MAX_OPTIONS):
		var dialogue_option : DialogueOptionUI = DialogueOptionUIScene.instantiate()
		dialogue_options.append(dialogue_option)
		dialogue_option.selected.connect(func() -> void: option_chosen.emit(i))
		vbox.add_child(dialogue_option)
		
		if i < Dialogue.MAX_OPTIONS - 1:
			vbox.add_child(DialogueOptionsSeparatorUIScene.instantiate())


func load_options(options: Array[String]) -> void:
	
	assert(options.size() <= Dialogue.MAX_OPTIONS)
	
	for i in range(Dialogue.MAX_OPTIONS):
		var dialogue_option := dialogue_options[i]
		
		if i >= options.size():
			dialogue_option.hide()
			continue
		
		var option_text : String = options[i]
		dialogue_option.show()
		dialogue_option.text = option_text
