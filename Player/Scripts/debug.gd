extends Label
@onready var state_machine: LimboHSM = %state_machine
var added_text : String 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = str(state_machine.get_active_state().name)
	if added_text:
		text += added_text

		added_text = ""
	
func add_debug(_text):
	added_text += "\n"+str(_text)
