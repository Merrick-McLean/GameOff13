extends Control




func play() -> void:
	$AnimationPlayer.play("credits")


func _on_liars_dice_physical_ready_for_credits() -> void:
	play()
