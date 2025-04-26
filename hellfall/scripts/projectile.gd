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

			if projectileType == "fireballs":
				if current_power == 1:
					body.emit_signal("add_haterush_point", 150)
					self.queue_free()
				else:
					body.emit_signal("kill_player")

			elif projectileType == "diecicles":
				if current_power == 2:
					body.emit_signal("add_haterush_point", 100)
					self.queue_free()
				else:
					body.emit_signal("kill_player")
						
			elif projectileType == "hellrocks":
				if current_power == 3:
					body.emit_signal("add_haterush_point", 200)
					self.queue_free()
				else:
					body.emit_signal("kill_player")	
			elif projectileType == "ghosts":
				if current_power == 4:
					body.emit_signal("add_haterush_point", 300)
					self.queue_free()
				else:
					body.emit_signal("kill_player")		
			# Notify the player's CharacterBody2D
