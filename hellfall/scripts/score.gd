extends Label

var isPlayerDead: bool = false
var score: int = 0

signal is_player_dead
# Called when the node enters the scene tree for the first time.
func _ready():
	set_score()
	self.connect("is_player_dead", Callable(self, "_is_player_dead")) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	set_score()
	if !isPlayerDead:
		GlobalVars.add_points(1)
	

func _is_player_dead() -> void:
	isPlayerDead = true

func set_score() -> void:
	score = GlobalVars.get_score()
	text = "Score: %d" % score
