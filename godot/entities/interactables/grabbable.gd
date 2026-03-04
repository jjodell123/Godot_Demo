## An object that can be grabbed, inherits from [Interactable].
##
## A [Grabbable] object can be picked up and dropped, and sometimes thrown.
## Should be added as child of the parent object.
class_name Grabbable extends Interactable

## How far in front of the player the object floats.
@export var pickup_dist: Vector3 = Vector3(0, 0, -2)
## How strongly the object oscillates back in front of the player.
@export var pickup_follow_strength: float = 200.0
## The strength of the throw force when an object is thrown.
@export var throw_strength: float = 1000.0

## The internal var for the objects follow strength, normalized based on fps.
@onready var _pickup_follow_strength: float = pickup_follow_strength * Global.BASE_FPS
## Whether or not the object is throwable.
@onready var can_throw: bool = throw_strength > 0.0

## If the object is currently picked up.
var picked_up: bool = false

## The text describing how to throw the object.
const THROW_TEXT: String = "Throw\n[Mouse Right]"


## Called when the node is first loaded, initializes values for the [Grabbable] object.
func _ready() -> void:
	super()
	if can_throw:
		alt_use_text = THROW_TEXT


## Called on the physics update, used to float the grabbable object in front of the player.
func _physics_process(delta: float) -> void:
	if picked_up:
		var camera_transform: Transform3D = Global.player.camera_controller.global_transform
		var hand_pos: Vector3 = camera_transform.translated_local(pickup_dist).origin
		var move_direction: Vector3 = hand_pos - parent.global_position
		var move_strength = _pickup_follow_strength / parent.mass
		parent.apply_central_force( move_direction * move_strength * delta)


## What the object does when the player looks at it. Currently unused, but would be used for 
## special logic like highlighting
func node_focused() -> void:
	super()


## What the object does when the player looks at it. Currently unused, but would be used for 
## special logic like disabling a highlight
func node_unfocused() -> void:
	super()


## What the object does when interacted. For a [Grabbable] object, pick it up if it is not already held.
func node_interacted() -> void:
	super()
	if not picked_up:
		grab()


## Controls what happens when the object is grabbed.
func grab() -> void:
	picked_up = true
	Global.player.set_grabbed_component(self)
	
	# Adjust RigidBody3D mechanics to reflect the item being grabbed
	parent.gravity_scale = 0.0
	parent.linear_damp = 20.0
	parent.angular_damp = 1.0


## Controls what happens when the object is dropped.
func drop() -> void:
	picked_up = false
	Global.player.set_grabbed_component(null)
	
	# Turn normal RigidBody3D mechanics back on
	parent.gravity_scale = 1.0
	parent.linear_damp = 0.0
	parent.angular_damp = 0.0


## Controls what happens when the object is thrown.
func throw() -> void:
	if not can_throw:
		return
	
	var camera_transform: Transform3D = Global.player.camera_controller.global_transform
	var throw_direction: Vector3 = -camera_transform.basis.z.normalized()
	var throw_strength_adjusted = throw_strength / parent.mass
	parent.apply_central_force(throw_direction * throw_strength_adjusted)
		
	drop()
