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
var currentScore = 0
	
func _ready():
	self.connect("player_dead", Callable(self, "_player_dead"))
	spawner.wait_time = waitTimeTotal
	projectileType = randi_range(0, 1)
	spawner.start()
	
func _process(delta):
	currentScore = GlobalVars.get_score()
	set_speed(delta)
	set_wait_time()
	
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
		setProjectileType()

func set_wait_time() -> void:
	if currentScore > 500 && currentScore < 750:
		waitTimeEnd = 8
	elif currentScore > 750 && currentScore < 1000:
		waitTimeEnd = 6
	elif currentScore > 1000 && currentScore < 1300:
		waitTimeStart = 2
		waitTimeEnd = 5
	elif currentScore > 1300:
		waitTimeStart = 2
		waitTimeEnd = 5

func _player_dead() -> void:
	playerIsDead = true

func setProjectileType() -> void:
	if currentScore < GlobalVars.scoreTreshold.one:
		projectileType = randi_range(0, 1)
	elif currentScore > GlobalVars.scoreTreshold.one && currentScore < GlobalVars.scoreTreshold.two:
		projectileType = randi_range(0, 2)
	elif currentScore > GlobalVars.scoreTreshold.two:
		projectileType = randi_range(0, 3)

func set_speed(delta: float) -> void:
	if currentScore >= GlobalVars.scoreTreshold.one && currentScore < GlobalVars.scoreTreshold.two:
		position.y += GlobalVars.speedTreshold.one * delta
	elif currentScore >= GlobalVars.scoreTreshold.two && currentScore < GlobalVars.scoreTreshold.three:
		position.y += GlobalVars.speedTreshold.two * delta
	elif currentScore >= GlobalVars.scoreTreshold.three:
		position.y += GlobalVars.speedTreshold.three * delta
	else:
		position.y += GlobalVars.defaultSpeed * delta
