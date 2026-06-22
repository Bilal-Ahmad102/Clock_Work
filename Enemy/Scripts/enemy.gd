extends CharacterBody2D

@export var attack_cooldown : float = 2.0

@onready var sprite:           AnimatedSprite2D  = %AnimatedSprite2D
@onready var state_machine:    LimboHSM          = $state_machine
@onready var hurtbox:          Area2D            = %Hurtbox
@onready var detection_zone:   Area2D            = %DetectionZone
@onready var attack_zone:      Area2D            = %AttackZone
@onready var health_bar: ProgressBar = %HealthBar
@onready var hitbox: Area2D = %hitbox


# behaviour profile, computed from Captain metrics at spawn
var move_speed:       float = EnemyData.MOVE_SPEED
var base_cooldown:    float = EnemyData.ATTACK_COOLDOWN
var timing_jitter:    float = 0.0    # 0 steady, climbs toward wild
var heavy_chance:     float = 0.4
var stagger_duration: float = EnemyData.STAGGER_DURATION
var recover_duration: float = EnemyData.RECOVER_DURATION


var hp: float = EnemyData.MAX_HP
var player: CharacterBody2D
var player_in_attack_zone: bool =  false

func _ready() -> void:
	if Captain.role == &"":
		Captain.bind_role(&"Orge", [&"Wizards", &"Goblin", &"Archer", &"Nigga"])
	_apply_captain_behaviour()
	_connect_signals()
func _connect_signals():
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	detection_zone.body_entered.connect(_on_detection_area_body_entered)
	detection_zone.body_exited.connect(_on_detection_area_body_exited)
	attack_zone.body_entered.connect(_on_attack_zone_body_entered)
	attack_zone.body_exited.connect(_on_attack_zone_body_exited)


func _process(delta: float) -> void:
	debug_values()
func debug_values() -> void:
	var txt := "\nPoise %.1f" % Captain.poise
	txt += "\nAudience Favor %.1f" % Captain.audience_favor
	txt += "\nVolatility %.1f" % Captain.volatility
	txt += "\nRole Integrity %.1f" % Captain.role_integrity
	txt += "\nForm %.1f" % Captain.form
	%debug_values.text = txt

func is_player_detected():
	if player:
		return true
	else: return null

func _on_detection_area_body_exited(body:Node2D):
	if body.is_in_group("Player"):
		player = null
		Audience.record_hesitation()

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
	Captain.take_damage(amount)
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

func _apply_captain_behaviour() -> void:
	var volatility_factor: float = Captain.volatility / 100.0   # 0 composed, 1 erratic
	var panic: float = 1.0 - (Captain.poise / 100.0)            # 0 calm, 1 panicked

	# the breaking body is forced to lurch faster as the role degrades
	move_speed = EnemyData.MOVE_SPEED * (1.0 + 0.5 * volatility_factor)

	# attack pacing tightens on average but swings wildly
	base_cooldown = EnemyData.ATTACK_COOLDOWN * (1.0 - 0.3 * volatility_factor)
	timing_jitter = 0.7 * volatility_factor

	# it over commits to heavy attacks as control slips
	heavy_chance = clamp(0.4 + 0.4 * volatility_factor, 0.0, 1.0)

	# low poise makes it flinch hard yet snap back into action fast
	stagger_duration = EnemyData.STAGGER_DURATION * (1.0 + 0.4 * panic)
	recover_duration = EnemyData.RECOVER_DURATION * (1.0 - 0.6 * panic)

func next_attack_cooldown() -> float:
	if timing_jitter <= 0.0:
		return base_cooldown
	return base_cooldown * randf_range(1.0 - timing_jitter, 1.0 + timing_jitter)
