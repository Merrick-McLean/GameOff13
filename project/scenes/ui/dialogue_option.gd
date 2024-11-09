class_name DialogueOptionUI
extends Control

signal selected

@onready var label : Label = $Label

var text := "" : 
	set(new_value):
		text = new_value
		label.text = text
