extends Control

func _ready():
	$Box/PlayButton.pressed.connect(_on_play_pressed)  
	$Box/QuitButton.pressed.connect(_on_quit_pressed) 
	
func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")  

func _on_quit_pressed():
	get_tree().quit()
