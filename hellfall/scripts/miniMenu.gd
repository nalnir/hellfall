extends Control

signal is_player_dead

func _ready():
	self.hide()
	self.connect("is_player_dead", Callable(self, "_is_player_dead"))
	$Box/ReplayButton.pressed.connect(_on_replay_pressed)  
	$Box/BackToMainMenuButton.pressed.connect(_on_quit_pressed) 
	
func _on_replay_pressed():
	self.hide()
	get_tree().reload_current_scene()  

func _on_quit_pressed():
	self.hide()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
func _is_player_dead() -> void:
	self.show()
	
