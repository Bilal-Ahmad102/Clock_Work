extends Node

## Plays the level's opening monologue once, shortly after the level
## loads. The tree is paused while the balloon runs (the balloon itself
## is switched to PROCESS_MODE_ALWAYS) so the player can't move mid-line.
## Text lives in the .dialogue file — placeholder for now.

@export_file("*.dialogue") var dialogue_path := "res://Dialogue/intro_monologue.dialogue"
@export var title := "start"
@export var start_delay := 0.8
@export var freeze_player := true


func _ready() -> void:
	await get_tree().create_timer(start_delay).timeout
	var resource: DialogueResource = load(dialogue_path)
	if resource == null:
		push_error("IntroMonologue: can't load '%s'" % dialogue_path)
		return
	var balloon := DialogueManager.show_dialogue_balloon(resource, title)
	if freeze_player:
		balloon.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().paused = true
		await DialogueManager.dialogue_ended
		get_tree().paused = false
