extends Node2D

@export_enum("fireballs", "diecicles", "hellrocks", "ghosts") var projectileType: String

@onready var area2d = $Area2D as Area2D
@onready var spawner = $"../spawner"

func _ready() -> void:
	area2d.connect("body_entered", Callable(self, "_on_rigid_body_entered"))

func _on_rigid_body_entered(body: Node) -> void:
	if body.name == "CharacterBody2D":  # Adjust name as needed
		#var parent = body.get_parent().get_child(0)
		if body:	
			var current_power = body.current_power
			var unlockHaterushAbility = body.unlockHaterushAbility 
			
			if current_power == 5:
				self.queue_free()
			else:
				if projectileType == "fireballs":
					if current_power == 1:
						handle_add_haterush_points(body, unlockHaterushAbility, 150)
						self.queue_free()
					else:
						body.emit_signal("kill_player")

				elif projectileType == "diecicles":
					if current_power == 2:
						handle_add_haterush_points(body, unlockHaterushAbility, 100)
						self.queue_free()
					else:
						body.emit_signal("kill_player")
							
				elif projectileType == "hellrocks":
					if current_power == 3:
						handle_add_haterush_points(body, unlockHaterushAbility, 200)
						self.queue_free()
					else:
						body.emit_signal("kill_player")	
				elif projectileType == "ghosts":
					if current_power == 4:
						handle_add_haterush_points(body, unlockHaterushAbility, 300)
						self.queue_free()
					else:
						body.emit_signal("kill_player")		
				# Notify the player's CharacterBody2D

func handle_add_haterush_points(body: CharacterBody2D, abilityUnlocked: bool, points: int) -> void:
	if !abilityUnlocked:
		body.emit_signal("add_haterush_point", points)
