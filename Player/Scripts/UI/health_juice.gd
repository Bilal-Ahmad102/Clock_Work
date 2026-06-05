extends Sprite2D

func _ready() -> void:
	material.set_shader_parameter("health", 1.0)
	PlayerData.health_changed.connect(take_damage)

func take_damage(_current:int,_max:int) -> void:
	if _current <= 0:
		return
	_animate_to(float(_current) / float(_max))

func _animate_to(target: float) -> void:
	material.set_shader_parameter("health", target)
	
