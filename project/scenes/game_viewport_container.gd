extends SubViewportContainer


func _ready() -> void:
	material.set_shader_parameter(&"u_color_tex", Palette.texture)
	Palette.texture_changed.connect(func(_a, new_texture) -> void: material.set_shader_parameter(&"u_color_tex", new_texture))
