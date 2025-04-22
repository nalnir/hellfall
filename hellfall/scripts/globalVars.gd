extends Node

var score: int = 0  # Your global score variable

# Optional: Functions to manipulate score
func add_points(points: int) -> void:
	score += points

func reset_score() -> void:
	score = 0

func get_score() -> int:
	return score
