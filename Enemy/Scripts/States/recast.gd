# recast.gd
extends LimboState

func _enter() -> void:
	agent.sprite.play("death")
	await agent.sprite.animation_finished
	#agent.hp = EnemyData.MAX_HP
	print("OK")
	#_apply_role()
	#get_root().dispatch(&"idle")

func _apply_role() -> void:
	match EnemyData.current_role:
		EnemyData.CastRole.DEFENSIVE:
			# enemy got more defensive ; Marla was too aggressive
			agent.block_chance    = 0.6
			agent.attack_cooldown = EnemyData.ATTACK_COOLDOWN * 1.5
		EnemyData.CastRole.AGGRESSIVE:
			# enemy got more aggressive ; Marla was too defensive
			agent.block_chance    = 0.05
			agent.attack_cooldown = EnemyData.ATTACK_COOLDOWN * 0.6
		EnemyData.CastRole.NEUTRAL:
			agent.block_chance    = 0.3
			agent.attack_cooldown = EnemyData.ATTACK_COOLDOWN
	EnemyData.reset_scores()
