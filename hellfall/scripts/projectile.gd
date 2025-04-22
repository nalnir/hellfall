extends Node2D

@export_enum("fireballs", "diecicles", "hellrocks", "ghosts") var projectileType: String

@onready var area2d = $Area2D as Area2D
@onready var spawner = $"../spawner"

var speed = 3.5

signal bump_speed

func _ready() -> void:
	self.connect("bump_speed", Callable(self, "_bump_speed"))
	area2d.connect("body_entered", Callable(self, "_on_rigid_body_entered"))

func _process(_delta) -> void:
	var score = GlobalVars.get_score()
	position = Vector2(position.x, position.y - speed)
	if score:
		_bump_speed(score)

func _on_rigid_body_entered(body: Node) -> void:
	if body.name == "CharacterBody2D":  # Adjust name as needed
		#var parent = body.get_parent().get_child(0)
		if body:	
			var current_power = body.current_power

			if projectileType == "fireballs":
				if current_power == 1:
					self.queue_free()
				else:
					body.emit_signal("kill_player")

			elif projectileType == "diecicles":
				if current_power == 2:
					self.queue_free()
				else:
					body.emit_signal("kill_player")
						
			elif projectileType == "hellrocks":
				if current_power == 3:
					self.queue_free()
				else:
					body.emit_signal("kill_player")	
			elif projectileType == "ghosts":
				if current_power == 4:
					self.queue_free()
				else:
					body.emit_signal("kill_player")		
			# Notify the player's CharacterBody2D


func _bump_speed(score: int) -> void:
	if score > 500 && score < 750:
		speed = 5
	elif score > 750 && score < 1000:
		speed = 8
	elif score > 1000 && score < 1300:
		speed = 10
	elif score > 1300:
		speed = 10
