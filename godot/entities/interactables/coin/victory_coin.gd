extends Area3D
## The logic for the victory coin. When grabbed, the game ends.

## How quickly the coin rotates.
@export var rotation_speed: float = 0.05
## The amplitude of the coin's oscillation.
@export var oscillation_height: float = 0.3
## The frequency of the coin's oscillation.
@export var oscillation_freq: float = 2.0

## The private var for the coin's rotation speed, normilized for the delya factor between frames.
@onready var _rotation_speed: float = rotation_speed * Global.BASE_FPS
## The initial height of the coin, representing the bottom of the oscillation.
@onready var start_y: float = position.y

## The time factor used for the coin's oscillation.
var time: float = 0.0
## Whether or not the win countdown has begun.
var win_started: bool = false

## How long the game waits before closing after the coin is reached.
const GAME_CLOSE_DELAY: float = 3.0


## Called on the physics update, used to run physical coin's oscillation.
func _physics_process(delta: float) -> void:
	time += delta
	
	position.y = start_y + oscillation_height * sin(time * oscillation_freq) + oscillation_height
	
	rotate_y(_rotation_speed * delta)


## Called when something hits the parent. Used to detect if the coin has been reached.
func _on_body_entered(body: Node3D) -> void:
	# Automatically returns if the coin has already been reached.
	if win_started: 
		return
	
	if not body.is_in_group("player"):
		return
	
	win_started = true
	Global.player.show_game_won()
	
	# Wait 3 seconds and close the game
	await get_tree().create_timer(GAME_CLOSE_DELAY).timeout
	get_tree().quit()
	
