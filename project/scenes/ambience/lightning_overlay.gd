extends Control


@onready var animation_player := $AnimationPlayer
@onready var flash := $Flash

func _ready() -> void:
	flash.visible = false


func _process(delta: float) -> void:
	if Debug.is_just_pressed("test_6"):
		animation_player.stop()
		animation_player.play(["lightning_0", "lightning_1", "lightning_2", "lightning_3"].pick_random())
