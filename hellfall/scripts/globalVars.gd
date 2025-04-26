extends Node

var score: int = 0  # Your global score variable

var scoreTreshold = {
	"one": 1000,
	"two": 2000,
	"three": 3000
}

var defaultSpeed = 500.0
var speedTreshold = {
	"one": 600.0,
	"two": 700.0,
	"three": 800.0
}

# Optional: Functions to manipulate score
func add_points(points: int) -> void:
	score += points

func reset_score() -> void:
	score = 0

func get_score() -> int:
	return score
