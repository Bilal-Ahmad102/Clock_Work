extends Label

@onready var state_machine: LimboHSM = $"../state_machine"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = str(state_machine.get_active_state().name)
	#text += "  : "+str(get_parent().sprite.frame)
	#if state_machine.get_active_state() == state_machine.combo_atk:
		#print(get_parent().sprite.frame)
