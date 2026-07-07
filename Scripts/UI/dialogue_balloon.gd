extends DialogueManagerExampleBalloon

## Project dialogue balloon: the stock example balloon plus a speaker
## portrait. Portraits are looked up by the line's character name; a
## character with no entry just hides the portrait slot.

@export var portraits: Dictionary[String, Texture2D] = {
	"Marla": preload("res://Assets/JoannaD'ArcIII_v1.9.5/Sprites/Idle/Idle1.png"),
}

@onready var portrait: TextureRect = %Portrait


func apply_dialogue_line() -> void:
	portrait.texture = portraits.get(dialogue_line.character, null)
	portrait.visible = portrait.texture != null
	super()
