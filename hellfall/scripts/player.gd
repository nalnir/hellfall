extends CharacterBody2D

@export var length: float = 50.0  # Swipe distance threshold
@export var threshold: float = 10.0  # Directional tolerance
@export var long_press_threshold: float = 0.75  # Seconds for long press
@export var hate_rush_swipe_timeout: float = 1.0  # Seconds before resetting up-swipe counter

# Swipe state
var swiping := false
var start_pos = null
var end_pos := Vector2.ZERO
var cur_pos = null
var touch_index: int = -1  # Track specific touch for multi-touch

# Long press state
var press_timer := 0.0
var press_timer_treshold = 0.20
var is_long_pressing := false
var ghostCloackActive := false

# Hate Rush state
var press_count := 0
var hate_rush_active := false
var timeout := 1.0
var is_adding_swipe_count := false
var hate_rush_cooling_down := false

enum Power { DEFAULT, FREEZE, FLAME, CRASH, GHOST, HATERUSH }
@export var current_power: Power = Power.DEFAULT
var prev_power: Power

@onready var player := $"." as CharacterBody2D
@onready var playerSprites:= $Animations as Node2D
@onready var playerCollider:= $CollisionShape2D as CollisionShape2D
@onready var ghostPlayer := $"../../ghostPlayer" as Node2D
@onready var score_board := $"../../CanvasLayerScore/scoreBoard" as Control
@onready var default_body_anim := $Animations/DefaultBodyAnimatedSprite2D as AnimatedSprite2D
@onready var mask_anim := $Animations/MaskAnimatedSprite2D as AnimatedSprite2D
@onready var hate_rush_anim := $Animations/HateRushAnimatedSprite2D as AnimatedSprite2D
@onready var spawner := $"../../spawner" as Node2D
@onready var miniMenu := $"../../miniMenu" as Control
@onready var progressBar := $"../../CanvasLayerScore/progressBar" as Node2D

var initial_position := Vector2.ZERO

signal kill_player
signal add_haterush_point

var currentScore = 0;
var hateRushBar: TextureProgressBar
var unlockHaterushAbility = false

func _ready() -> void:
	hateRushBar = progressBar.get_child(0)
	hate_rush_anim.hide()
	default_body_anim.play("falling")
	mask_anim.play("eyeBlink")
	initial_position = position
	connect("kill_player", _kill_player)
	connect("add_haterush_point", _add_haterush_point)

func _process(delta: float) -> void:
	currentScore = GlobalVars.get_score()
	set_speed(delta)
	
	# HANDLE HATE RUSH
	if hate_rush_active:
		if !hate_rush_cooling_down:
			hate_rush_cooling_down = true
			hate_rush_cooldown()
		return
	
	# HATE RUSH PRESS
	if currentScore >= GlobalVars.scoreTreshold.one && unlockHaterushAbility:
		if press_count > 0 && !hate_rush_active:
			handle_haterush_states()
			timeout -= delta
			if timeout <= 0.0:
				reset_haterush()
	
	#HANDLE LONG PRESS
	if currentScore >= GlobalVars.scoreTreshold.two:
		if press_timer >= press_timer_treshold:
			handle_long_press()
		if is_long_pressing:
			press_timer += delta
		else:
			if press_timer != 0:
				press_timer = 0
		

func _input(event: InputEvent) -> void:
	if hate_rush_active:
		return
		
	# HANDLE LONG PRESS
	if event is InputEventScreenTouch:
		if event.is_pressed() and !event.is_released():
			is_long_pressing = true
		elif event.is_released() and !event.is_pressed():
			is_long_pressing = false
			await stop_ghost_cloak()
			ghostCloackActive = false
			press_count += 1
			
	elif event is InputEventScreenDrag:
		reset_haterush()
		if start_pos == null:
			start_pos = event.position
		elif event.is_released():
			end_pos = event.position
			handle_swipe()

func handle_swipe() -> void:
	if !swiping:
		swiping = true
	
		var delta: Vector2 = end_pos - start_pos
		var delta_x: float = abs(delta.x)
		var delta_y: float = abs(delta.y)

		# Only process swipe if movement exceeds threshold
		if delta.length() < threshold:
			swiping = false
			start_pos = null
			return
	
		 # Calculate swipe angle to determine direction more accurately
		var angle = atan2(delta.y, delta.x) * 180 / PI
		var is_horizontal = delta_x > delta_y and delta_x > threshold
		var is_vertical = delta_y > delta_x and delta_y > threshold

		if is_horizontal:
			# Horizontal swipe logic (unchanged)
			if end_pos.x > start_pos.x:
				reset_haterush()
				if current_power != Power.FREEZE:
					prev_power = current_power
					current_power = Power.FREEZE
					mask_anim.hide()
					if prev_power == Power.DEFAULT:
						default_body_anim.play("swipeRight")
					else:
						default_body_anim.play("swipeRightFromFlame")
					await get_tree().create_timer(0.2).timeout 
					default_body_anim.play("fallingFreeze")
					mask_anim.show()
			elif end_pos.x < start_pos.x:
				reset_haterush()
				if current_power != Power.FLAME:
					prev_power = current_power
					current_power = Power.FLAME
					mask_anim.hide()
					if prev_power == Power.DEFAULT:
						default_body_anim.play("swipeLeft")
					else:
						default_body_anim.play("swipeLeftFromFreeze")
					await get_tree().create_timer(0.2).timeout 
					default_body_anim.play("fallingFlame")
					mask_anim.show()
		elif is_vertical:
			# Vertical swipe with stricter angle check
			# Up swipe: angle between -135 and -45 degrees
			# Down swipe: angle between 45 and 135 degrees
			if currentScore >= GlobalVars.scoreTreshold.one:
				if abs(angle) > 45 and abs(angle) < 135:
					if delta.y > 0:  # Swiping down
						reset_haterush()
						prev_power = current_power
						current_power = Power.CRASH
		
						var tween = create_tween()
						tween.set_parallel(true)
						mask_anim.hide()
						default_body_anim.play("crash")
						#tween.tween_property(player, "position", Vector2(player.position.x, player.position.y + 500), 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
						tween.tween_property(playerSprites, "position", Vector2(playerSprites.position.x, playerSprites.position.y + 1000), 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
						tween.tween_property(playerCollider, "position", Vector2(playerCollider.position.x, playerCollider.position.y + 1000), 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
						await get_tree().create_timer(1).timeout 
						mask_anim.show()
						default_body_anim.play("falling")
						tween = create_tween()
						tween.set_parallel(true)
						#tween.tween_property(player, "position", Vector2(player.position.x, player.position.y), 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
						tween.tween_property(playerSprites, "position", Vector2(playerSprites.position.x, playerSprites.position.y - 1000), 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
						tween.tween_property(playerCollider, "position", Vector2(playerCollider.position.x, playerCollider.position.y - 1000), 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
						prev_power = current_power
						current_power = Power.DEFAULT
							
					elif delta.y < 0:  # Swiping up
						print("SWIPING UP")
			
		swiping = false
		start_pos = null
	
func handle_long_press() -> void:
	if !ghostCloackActive:
		reset_haterush()
		ghostCloackActive = true
		prev_power = current_power
		current_power = Power.GHOST
		mask_anim.hide()
		match prev_power:
			Power.DEFAULT:
				default_body_anim.play("ghostCloackStart")
				await get_tree().create_timer(0.1).timeout
				default_body_anim.play("ghostCloackIdle")
			Power.FLAME:
				default_body_anim.play("ghostCloackFlameStart")
				await get_tree().create_timer(0.1).timeout
				default_body_anim.play("ghostCloackFlameIdle")
			Power.FREEZE:
				default_body_anim.play("ghostCloackFreezeStart")
				await get_tree().create_timer(0.1).timeout
				default_body_anim.play("ghostCloackFreezeIdle")

func _kill_player() -> void:
	print("KILLED")
	#score_board.get_child(0).emit_signal("is_player_dead")
	#spawner.emit_signal("player_dead")
	#miniMenu.emit_signal("is_player_dead")
	#queue_free()

func _add_haterush_point(point: int) -> void:
	print("unlockHaterushAbility: ", unlockHaterushAbility)
	if hateRushBar.value >= hateRushBar.max_value:
		unlockHaterushAbility = true
	else:
		hateRushBar.value += point

func set_speed(delta: float) -> void:
	if currentScore >= GlobalVars.scoreTreshold.one && currentScore < GlobalVars.scoreTreshold.two:
		player.position.y += GlobalVars.speedTreshold.one * delta
	elif currentScore >= GlobalVars.scoreTreshold.two && currentScore < GlobalVars.scoreTreshold.three:
		player.position.y += GlobalVars.speedTreshold.two * delta
	elif currentScore >= GlobalVars.scoreTreshold.three:
		player.position.y += GlobalVars.speedTreshold.three * delta
	else:
		player.position.y += GlobalVars.defaultSpeed * delta

func reset_from_ghost_cloak(finish_anim: String, next_anim: String) -> void:
	default_body_anim.play(finish_anim)
	await get_tree().create_timer(0.1).timeout
	default_body_anim.play(next_anim)
	mask_anim.show()

func stop_ghost_cloak() -> void:
	if ghostCloackActive:
		match prev_power:
			Power.DEFAULT:
				await reset_from_ghost_cloak("ghostCloackFinish", "falling")
				prev_power = current_power
				current_power = Power.DEFAULT
			Power.FLAME:
				await reset_from_ghost_cloak("ghostCloackFlameFinish", "fallingFlame")
				prev_power = current_power
				current_power = Power.FLAME
			Power.FREEZE:
				await reset_from_ghost_cloak("ghostCloackFreezeFinish", "fallingFreeze")
				prev_power = current_power
				current_power = Power.FREEZE
				
func handle_haterush_states() -> void:
	if press_count == 1:
		hate_rush_anim.show()
		hate_rush_anim.play("stage1")
	elif press_count == 2:
		hate_rush_anim.play("stage2")
	elif press_count == 3:
		hate_rush_anim.play("stage3")
		hate_rush_active = true

func reset_haterush() -> void:
	#print("reset_haterush: ", reset_haterush)
	timeout = 1.0
	if press_count == 0:
		return
	if press_count == 1:
		hate_rush_anim.play("stage1Finish")
	elif press_count == 2:
		hate_rush_anim.play("stage2Finish")
	press_count = 0

func hate_rush_cooldown() -> void:
	prev_power = current_power
	current_power = Power.HATERUSH
	hate_rush_anim.play("idle")
	reset_haterush_progressbar()
	await get_tree().create_timer(7.0).timeout
	hate_rush_active = false
	press_count = 0
	timeout = 1.0
	current_power = prev_power
	hate_rush_cooling_down = false
	unlockHaterushAbility = false
	hate_rush_anim.play("stage3Finish")
	await get_tree().create_timer(1.0).timeout
	mask_anim.show()
	hate_rush_anim.hide()

func reset_haterush_progressbar() -> void:
	if hateRushBar.value >= 0:
		#hateRushBar.value -= (hateRushBar.value / 7)
		var tween = create_tween()
		tween.tween_property(hateRushBar, "value", 0.0, 7.0).from(hateRushBar.value)
	else: 
		hateRushBar.value = 0

func get_speed_treshold() -> float:
	if currentScore >= GlobalVars.scoreTreshold.one && currentScore < GlobalVars.scoreTreshold.two:
		return GlobalVars.speedTreshold.one
	elif currentScore >= GlobalVars.scoreTreshold.two && currentScore < GlobalVars.scoreTreshold.three:
		return GlobalVars.speedTreshold.two
	elif currentScore >= GlobalVars.scoreTreshold.three:
		return GlobalVars.speedTreshold.three
	else:
		return GlobalVars.defaultSpeed
