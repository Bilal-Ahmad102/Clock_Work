extends Area2D

## Hidden-room reveal: fades the child `Overlay` (foreground cover) while
## the player stands inside the area, restores it on exit.

@export var hidden_alpha := 0.08
@export var fade_time := 0.25

@onready var overlay: CanvasItem = $Overlay

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		create_tween().tween_property(overlay, "modulate:a", hidden_alpha, fade_time)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		create_tween().tween_property(overlay, "modulate:a", 1.0, fade_time)
