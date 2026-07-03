extends Area2D

## Refill shrine (hidden-room reward): restores health and stamina
## when the player touches it.

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	PlayerData.heal(PlayerData.MAX_HEALTH)
	PlayerData.stamina = PlayerData.MAX_STAMINA
	PlayerData.stamina_changed.emit(PlayerData.stamina, PlayerData.MAX_STAMINA)
