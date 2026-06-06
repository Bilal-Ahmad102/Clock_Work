extends Node2D

@onready var tween_composer: TweenComposer = $Sprite2D/TweenComposer

func _on_tween_composer_trigger_fired(trigger_name: Variant) -> void:
	print(trigger_name)
