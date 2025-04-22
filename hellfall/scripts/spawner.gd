extends Node2D
var fireballsScene = preload("res://scenes/fireBalls.tscn")
var dieciclesScene = preload("res://scenes/diecicles.tscn")
var hellRocksScene = preload("res://scenes/hellRocks.tscn")
var ghostsScene = preload("res://scenes/ghosts.tscn")

var waitTimeStart = 3
var waitTimeEnd = 10
var waitTimeTotal = 3
var projectileType = 0

@onready var spawner = $Timer as Timer # Default direction (can be set by the cannon)
	
signal player_dead
var playerIsDead = false
	
func _ready():
	self.connect("player_dead", Callable(self, "_player_dead"))
	spawner.wait_time = waitTimeTotal
	projectileType = randi_range(0, 3)
	spawner.start()
	
func _process(_delta):
	set_wait_time(GlobalVars.get_score())
	
func _on_timer_timeout():
	var projectile: Node2D
	if projectileType == 0:
		projectile = fireballsScene.instantiate()
	elif projectileType == 1:
		projectile = dieciclesScene.instantiate()
	elif projectileType == 2:
		projectile = hellRocksScene.instantiate()
	elif projectileType == 3:
		projectile = ghostsScene.instantiate()
	if projectile:
		projectile.position = position
		projectile.get_child(0).get_child(0).play("idle")
		if !playerIsDead:
			get_parent().add_child(projectile)
		waitTimeTotal = randi_range(waitTimeStart, waitTimeEnd)
		projectileType = randi_range(0, 3)

func set_wait_time(score: int) -> void:
	if score > 500 && score < 750:
		waitTimeEnd = 8
	elif score > 750 && score < 1000:
		waitTimeEnd = 6
	elif score > 1000 && score < 1300:
		waitTimeStart = 2
		waitTimeEnd = 5
	elif score > 1300:
		waitTimeStart = 2
		waitTimeEnd = 5

func _player_dead() -> void:
	playerIsDead = true
