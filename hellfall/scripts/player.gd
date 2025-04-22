extends CharacterBody2D

var length = 100
var startPos: Vector2
var curPos: Vector2
var swiping = false

var threshold = 10

# Long press vars
var press_timer: float = 0.0
var long_press_threshold: float = 0.75  # Seconds to qualify as long press
var stop_long_press: bool = true

# Hate Rush state
@export var hate_rush_swipe_timeout: float = 1.0
var up_swipe_count := 0
var hate_rush_active := false
var last_up_swipe_time := 0.0  # Tracks time of last up swipe

enum Power {
	DEFAULT,
	FREEZE,
	FLAME,
	CRASH,
	GHOST,
	HATERUSH
}
var currentPower: Power = Power.DEFAULT
var prevPower: Power

@onready var player = $"."
@onready var scoreBoard = $"../../scoreBoard" as Control

@onready var defaultBodyAnim = $Animations/DefaultBodyAnimatedSprite2D as AnimatedSprite2D
@onready var maskAnim = $Animations/MaskAnimatedSprite2D as AnimatedSprite2D
@onready var hateRushAnim = $Animations/HateRushAnimatedSprite2D as AnimatedSprite2D
var initialPosition: Vector2

signal kill_player

func _ready() -> void:
	hateRushAnim.hide()
	defaultBodyAnim.play("falling")
	maskAnim.play("eyeBlink")
	initialPosition = position
	self.connect("kill_player", Callable(self, "_kill_player"))

func _process(delta) -> void:	
	# Update Hate Rush swipe timeout
	if up_swipe_count > 0 and not hate_rush_active:
		last_up_swipe_time += delta
		if last_up_swipe_time >= hate_rush_swipe_timeout:
			reset_haterush()

	# Skip input processing during Hate Rush
	if hate_rush_active:
		hate_rush_cooldown()
		return
		
	if Input.is_action_just_pressed("press"):
		if !swiping:
			swiping = true
			startPos = get_global_mouse_position()
	if Input.is_action_pressed("press"):
		if swiping:
			curPos = get_global_mouse_position()				
			if startPos.distance_to(curPos) >= length:
				# SWIPING
				press_timer = 0.0		
				if abs(startPos.y-curPos.y) <= threshold:
					# SWIPING HORIZONTALLY
					reset_haterush()
					if curPos.x > startPos.x:
						# SWIPING RIGHT -> FREEZE
						if(currentPower != Power.FREEZE):
							prevPower = currentPower
							currentPower = Power.FREEZE
							maskAnim.hide()
							if prevPower == Power.DEFAULT:
								defaultBodyAnim.play("swipeRight")
							else:
								defaultBodyAnim.play("swipeRightFromFlame")
							await get_tree().create_timer(0.2).timeout 
							defaultBodyAnim.play("fallingFreeze")
							maskAnim.show()
					else:
						# SWIPING LEFT -> FLAME
						if(currentPower != Power.FLAME):
							prevPower = currentPower
							currentPower = Power.FLAME
							maskAnim.hide()
							if prevPower == Power.DEFAULT:
								defaultBodyAnim.play("swipeLeft")
							else:
								defaultBodyAnim.play("swipeLeftFromFreeze")
							await get_tree().create_timer(0.2).timeout 
							defaultBodyAnim.play("fallingFlame")
							maskAnim.show()
		
						swiping = false
				elif abs(startPos.x-curPos.x) <= threshold:
					# SWIPING VERTICALLY
					if curPos.y > startPos.y:
						# SWIPING DOWN -> CRASH
						reset_haterush()
						prevPower = currentPower
						currentPower = Power.CRASH
						
						if(player.position.y == initialPosition.y): 
							var tween = create_tween()
							maskAnim.hide()
							defaultBodyAnim.play("crash")
							tween.tween_property(player, "position", Vector2(player.position.x, player.position.y + 350), 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
							await get_tree().create_timer(1).timeout 
							maskAnim.show()
							defaultBodyAnim.play("falling")
							tween = create_tween()
							tween.tween_property(player, "position", Vector2(initialPosition.x, initialPosition.y), 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
							prevPower = currentPower
							currentPower = Power.DEFAULT
					elif curPos.y < startPos.y:
						# SWIPING UP -> HATE RUSH
						up_swipe_count += 1
						last_up_swipe_time = 0.0
						print("up_swipe_count: ", up_swipe_count)  # Reset timer on up swipe
						match up_swipe_count:
							1:
								hateRushAnim.show()
								hateRushAnim.play("stage1")
							2:
								hateRushAnim.play("stage2")
							3:
								hateRushAnim.play("stage3")
								print("ACTIVATE HATERUSH")
								prevPower = currentPower
								currentPower = Power.HATERUSH
								hate_rush_active = true
								hateRushAnim.play("idle")
			else:
				# LONG PRESS -> GHOST CLOACK
				press_timer += 0.1		
				reset_haterush()
				if press_timer >= long_press_threshold:
					
					if stop_long_press: 
						prevPower = currentPower
						currentPower = Power.GHOST
					stop_long_press = false
					maskAnim.hide()
					if prevPower == Power.DEFAULT:
						defaultBodyAnim.play("ghostCloackStart")
						await get_tree().create_timer(0.1).timeout 
						defaultBodyAnim.play("ghostCloackIdle")
					elif prevPower == Power.FLAME:
						defaultBodyAnim.play("ghostCloackFlameStart")
						await get_tree().create_timer(0.1).timeout 
						defaultBodyAnim.play("ghostCloackFlameIdle")
					elif prevPower == Power.FREEZE:
						defaultBodyAnim.play("ghostCloackFreezeStart")
						await get_tree().create_timer(0.1).timeout 
						defaultBodyAnim.play("ghostCloackFreezeIdle")
	else:
		if !stop_long_press:
			press_timer = 0.0
			stop_ghost_cloack()	
		swiping = false

func _kill_player() -> void:
	scoreBoard.get_child(0).emit_signal("is_player_dead")
	self.queue_free()
	
func reset_from_ghostCloak(finishAnim, nextAnim) -> void:
	defaultBodyAnim.play(finishAnim)
	await get_tree().create_timer(0.1).timeout 
	defaultBodyAnim.play(nextAnim)
	maskAnim.show()
	
func stop_ghost_cloack() -> void:
	if prevPower == Power.DEFAULT:
		await reset_from_ghostCloak("ghostCloackFinish", "falling")
		prevPower = currentPower
		currentPower = Power.DEFAULT
	elif prevPower == Power.FLAME:
		await reset_from_ghostCloak("ghostCloackFlameFinish", "fallingFlame")
		prevPower = currentPower
		currentPower = Power.FLAME
	elif prevPower == Power.FREEZE:
		await reset_from_ghostCloak("ghostCloackFreezeFinish", "fallingFreeze")
		prevPower = currentPower
		currentPower = Power.FREEZE
	stop_long_press = true

func reset_haterush() -> void:
	if up_swipe_count == 0:
		return
	match up_swipe_count:
		1:
			hateRushAnim.play("stage1Finish")
			await get_tree().create_timer(1.0).timeout
			hateRushAnim.hide()
		2:
			hateRushAnim.play("stage2Finish")
			await get_tree().create_timer(1.0).timeout
			hateRushAnim.hide()
	up_swipe_count = 0
	last_up_swipe_time = 0.0

func hate_rush_cooldown() -> void:
	await get_tree().create_timer(7.0).timeout
	hate_rush_active = false
	print("HATE RUSH DONE")
	hateRushAnim.play("stage3Finish")
	await get_tree().create_timer(5.0).timeout
	hateRushAnim.hide()
	up_swipe_count = 0	
	prevPower = currentPower
	currentPower = Power.DEFAULT
