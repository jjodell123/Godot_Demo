extends CharacterBody3D
## The player character class, handles movement, interaction with entities, and hud display.

## The player's walking speed.
@export var walk_speed: float = 5.0
## The player's sprint speed.
@export var sprint_speed: float = 10.0
## The initial jump velocity when a player jumps.
@export var jump_speed: float = 6.0
## The player's mouse sensitivity when looking around.
@export var mouse_accel: float = 0.01
## The player's interaction distance. Anything farther away from the player will not be interactable
@export var interact_length: float = 4.0

## The base node for the player's camera and interaction raycast.
@onready var camera_controller := $CameraController
## The player's camera.
@onready var camera := $CameraController/Camera3D
## The player's interaction raycast.
@onready var interact_raycast := $CameraController/InteractionRaycast
## The hud text showing what the player is interacting with.
@onready var interact_text := $HUD/InteractText
## The hud text displaying "You Win!" when the game ends.
@onready var game_won_label := $HUD/GameWonLabel

## The player's walking speed, adjusted for the fps. What is actually used by the movement function.
@onready var _walk_speed: float = walk_speed * Global.BASE_FPS
## The player's sprint speed, adjusted for the fps. What is actually used by the movement function.
@onready var _sprint_speed: float = sprint_speed * Global.BASE_FPS

## The item held by the player, if anything.
var grabbed_component = null

## How down the player can look.
const CAMERA_X_ROT_MIN: float = -PI / 2
## How far up the player can look.
const CAMERA_X_ROT_MAX: float = PI / 2

## Called when the node is first loaded, initializes values for the player.
func _ready() -> void:
	# Set the mouse to be locked in the window.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Set interaction length based on the player's tuning.
	interact_raycast.target_position = Vector3(0, 0, -interact_length)
	
	game_won_label.visible = false
	
	# Set the global player value so other scripts can easily access it.
	Global.player = self


## Called on any player input that isn't otherwise handled via the project input map.
func _unhandled_input(event: InputEvent) -> void:
	# Handle mouse movement	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			# Rotate the entire player left/right
			rotate_y(-event.relative.x * mouse_accel)
			
			# Rotate just the Camera Controller up/down
			camera_controller.rotate_x(-event.relative.y * mouse_accel)
			camera_controller.rotation.x = clamp( camera_controller.rotation.x, CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX)
	
	# Handle exiting the game
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


## Called on the physics update, used to run physical movement and interactions.
func _physics_process(delta: float) -> void:
	# Handle player movement
	apply_gravity(delta)
	apply_movement_input(delta)
	move_and_slide()
	
	# Handle player interaction
	if grabbed_component:
		update_interact_text(grabbed_component.get_alt_use_text())
		update_grabbed_entity()
	else:
		update_raycast()


## Takes the player's movement inputs and moves the player accordingly.
func apply_movement_input(delta: float) -> void:
	# Set movement speed based on player stance
	var movement_speed = _sprint_speed if Input.is_action_pressed("sprint") else _walk_speed
	
	# Handle horizontal movement
	var movement_input = Input.get_vector("left", "right", "forward", "backward")
	var movement_dir = (transform.basis * Vector3(movement_input.x, 0, movement_input.y)).normalized()
	var movement_vec = movement_dir * movement_speed * delta
	if movement_dir:
		velocity.x = movement_vec.x
		velocity.z = movement_vec.z
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed * delta)
		velocity.z = move_toward(velocity.z, 0, movement_speed * delta)
	
	# Handle jump movement
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed


## Handles gravity for the player.
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


## Handles the player's input interactions with a grabbed object.
func update_grabbed_entity() -> void:
	if Input.is_action_just_pressed("interact"):
		grabbed_component.drop()
	elif Input.is_action_just_pressed("throw"):
		grabbed_component.throw()


## Sets the hud label giving entity interaction details. If the input is empty, hide the hud prompt.
func update_interact_text(new_text: String) -> void:
	interact_text.text = new_text

	# Not technically needed, just good practice to turn something off when it isn't being used
	if new_text == "":
		interact_text.visible = false
	else:
		interact_text.visible = true


## Updates the interaction raycast, the raycast used to detect an interactable object in front of the player.
func update_raycast() -> void:
	# Note: we update the raycast here as opposed to its own _physics_process as we want to use the result
	# immediately afterwards and not wait for the next tick
	interact_raycast.update_raycast_collider()
	
	if Input.is_action_just_pressed("interact"):
		var interactable_collider = interact_raycast.get_interactable_collider()
		if interactable_collider:
			assert(interactable_collider.has_user_signal("interact"), "Interactable component must have the interact signal")
			interactable_collider.emit_signal("interact")


## Tells the player which object is currently grabbed. Specifically sends the [Interactable] node attached to the object.
func set_grabbed_component(component) -> void:
	grabbed_component = component


## Enables the game won text
func show_game_won() -> void:
	game_won_label.visible = true
