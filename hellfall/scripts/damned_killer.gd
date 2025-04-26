extends Node2D

var currentScore = 0

func _process(delta: float) -> void:
	currentScore = GlobalVars.get_score()
	set_speed(delta)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "damned":  # Adjust name as needed
		if body:	
			body.get_parent().queue_free() # Repl

func set_speed(delta: float) -> void:
	if currentScore >= GlobalVars.scoreTreshold.one && currentScore < GlobalVars.scoreTreshold.two:
		position.y += GlobalVars.speedTreshold.one * delta
	elif currentScore >= GlobalVars.scoreTreshold.two && currentScore < GlobalVars.scoreTreshold.three:
		position.y += GlobalVars.speedTreshold.two * delta
	elif currentScore >= GlobalVars.scoreTreshold.three:
		position.y += GlobalVars.speedTreshold.three * delta
	else:
		position.y += GlobalVars.defaultSpeed * delta
