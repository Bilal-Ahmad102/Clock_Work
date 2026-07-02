extends Marker2D



@export var area : Area2D
var checkpointed: bool = false
func _ready() -> void:

	area.body_entered.connect(func(body:Node2D):
		if body.is_in_group("Player") and body.has_method("set_checkpoint") and !checkpointed:
			body.set_checkpoint(self)
			checkpointed = true
			)
