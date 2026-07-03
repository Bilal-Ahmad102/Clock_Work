extends StaticBody2D

## Blockout breakable: ignores hits below `damage_threshold` (light attacks
## flash off it), a single hit at or above the threshold breaks it.
## Must live on collision layer 2 so the player hitbox reaches it. Joins the
## TrainingDummy group so hits carry atk_name and are never recorded to Audience.

signal broke(by_atk: StringName)

@export var damage_threshold: float = 30.0

var _broken := false

func _ready() -> void:
	add_to_group("TrainingDummy")

func take_damage(amount: float, by_atk: StringName = &"") -> void:
	if _broken:
		return
	if amount < damage_threshold:
		var deflect := create_tween()
		deflect.tween_property(self, "modulate", Color(1.5, 1.5, 1.5), 0.06)
		deflect.tween_property(self, "modulate", Color.WHITE, 0.12)
		return
	_broken = true
	broke.emit(by_atk)
	set_deferred("collision_layer", 0)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.1, 0.3)
