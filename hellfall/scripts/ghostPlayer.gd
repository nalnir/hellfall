extends CharacterBody2D

@onready var ghostPlayer := $"."
var currentScore = 0

func _process(delta: float) -> void:
	currentScore = GlobalVars.get_score()
	set_speed(delta)

func set_speed(delta: float) -> void:
	if currentScore >= GlobalVars.scoreTreshold.one && currentScore < GlobalVars.scoreTreshold.two:
		ghostPlayer.position.y += GlobalVars.speedTreshold.one * delta
	elif currentScore >= GlobalVars.scoreTreshold.two && currentScore < GlobalVars.scoreTreshold.three:
		ghostPlayer.position.y += GlobalVars.speedTreshold.two * delta
	elif currentScore >= GlobalVars.scoreTreshold.three:
		ghostPlayer.position.y += GlobalVars.speedTreshold.three * delta
	else:
		ghostPlayer.position.y += GlobalVars.defaultSpeed * delta
