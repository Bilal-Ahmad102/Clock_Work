extends Sprite2D

func _ready() -> void:
	material.set_shader_parameter("stamina", 0.0)
	PlayerData.stamina_changed.connect(change_stamina)

func change_stamina(_current:int,_max:int) -> void:
	if _current <= 0:
		return
	_animate_to(float(_current) / float(_max))

func _animate_to(target: float) -> void:
	material.set_shader_parameter("stamina", 1-target)
	
