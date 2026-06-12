extends CharacterBody2D

@export var attack_cooldown : float = 2.0

@onready var sprite:           AnimatedSprite2D  = %AnimatedSprite2D
@onready var state_machine:    LimboHSM          = $state_machine
@onready var hurtbox:          Area2D            = %Hurtbox
@onready var detection_zone:   Area2D            = %DetectionZone
@onready var attack_zone:      Area2D            = %AttackZone
@onready var health_bar: ProgressBar = %HealthBar
@onready var hitbox: Area2D = %hitbox

var hp: float = EnemyData.MAX_HP
var player: CharacterBody2D
var player_in_attack_zone: bool =  false

func _ready() -> void:
	
	_connect_signals()
func _connect_signals():
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	detection_zone.body_entered.connect(_on_detection_area_body_entered)
	detection_zone.body_exited.connect(_on_detection_area_body_exited)
	attack_zone.body_entered.connect(_on_attack_zone_body_entered)
	attack_zone.body_exited.connect(_on_attack_zone_body_exited)

func is_player_detected():
	if player:
		return true
	else: return null

func _on_detection_area_body_exited(body:Node2D):
	if body.is_in_group("Player"):
		player = null

func _on_detection_area_body_entered(body:Node2D):
	if body.is_in_group("Player"):
		player = body
		
func _on_attack_zone_body_exited(body:Node2D):
	if body.is_in_group("Player"):
		player_in_attack_zone = false

func _on_attack_zone_body_entered(body:Node2D):
	if body.is_in_group("Player"):
		player_in_attack_zone = true

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.has_method("_activate_hitbox"):
		take_damage(area.hitbox_damage)

func take_damage(amount: float) -> void:
	hp = max(0.0, hp - amount)
	if hp <= 0.0:
		state_machine.dispatch(&"recast")
	else:
		state_machine.dispatch(&"stagger")
	health_bar.value = hp
	
	
func face_player() -> void:
	if player:
		hitbox.change_face(sprite.flip_h)
		sprite.flip_h = player.global_position.x < global_position.x
