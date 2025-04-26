extends Node2D

var damnedScene = preload("res://scenes/damned.tscn")
var damned1Texture = preload("res://images/damned1.png")
var damned2Texture = preload("res://images/damned2.png")
var damned3Texture = preload("res://images/damned3.png")
var damned4Texture = preload("res://images/damned4.png")
var damnedList = []
var damnedSpriteIndex

@onready var spawner = $Timer as Timer 

var waitTimeStart = 3
var waitTimeEnd = 10
var waitTimeTotal = 3

var currentScore = 0

func _ready() -> void:
	damnedList.push_back(damned1Texture)
	damnedList.push_back(damned2Texture)
	damnedList.push_back(damned3Texture)
	damnedList.push_back(damned4Texture)
	spawner.wait_time = waitTimeTotal
	damnedSpriteIndex = randi_range(0, damnedList.size() - 1)
	spawner.start()
	
func _process(delta: float) -> void:
	currentScore = GlobalVars.get_score()
	set_speed(delta)


func _on_timer_timeout() -> void:
	var damnedNode = damnedScene.instantiate()
	var rb2d: RigidBody2D = damnedNode.get_child(0)
	var sprite: Sprite2D = rb2d.get_child(0).get_child(0)

	if rb2d:
		rb2d.gravity_scale = set_gravity_scale()
	if sprite: 
		sprite.texture = damnedList.get(damnedSpriteIndex)
		var scaleRange = randf_range(0.05, 0.20)
		sprite.scale = Vector2(scaleRange, scaleRange)


	
	if damnedNode:
		damnedNode.position = position
		get_parent().add_child(damnedNode)
		waitTimeTotal = randi_range(waitTimeStart, waitTimeEnd)
		damnedSpriteIndex = randi_range(0, damnedList.size() - 1)

func set_speed(delta: float) -> void:
	if currentScore >= GlobalVars.scoreTreshold.one && currentScore < GlobalVars.scoreTreshold.two:
		position.y += GlobalVars.speedTreshold.one * delta
	elif currentScore >= GlobalVars.scoreTreshold.two && currentScore < GlobalVars.scoreTreshold.three:
		position.y += GlobalVars.speedTreshold.two * delta
	elif currentScore >= GlobalVars.scoreTreshold.three:
		position.y += GlobalVars.speedTreshold.three * delta
	else:
		position.y += GlobalVars.defaultSpeed * delta

func set_gravity_scale() -> float:
	if currentScore >= GlobalVars.scoreTreshold.one && currentScore < GlobalVars.scoreTreshold.two:
		return randf_range(0.10, 0.25)
	elif currentScore >= GlobalVars.scoreTreshold.two && currentScore < GlobalVars.scoreTreshold.three:
		return randf_range(0.12, 0.25)
	elif currentScore >= GlobalVars.scoreTreshold.three:
		return randf_range(0.15, 0.25)
	else:
		return randf_range(0.05, 0.25)
