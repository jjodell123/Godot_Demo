## An object that can be opened, inherits from [Interactable].
##
## A [Openable] object can be opened and closed.
## Should be added as child of the parent object.
class_name Openable extends Interactable

## What type of openable object it is. Only a rotating door is implemented, but we could add a case
## for things like a sliding door, and drawer, etc.
enum OpenableType { 
	ROTATING_DOOR,
}

## Whether the openable object is locked and cannot be interacted with by the player.
@export var locked: bool = false
## The [enum Openable.OpenableType] for the object.
@export var open_type: OpenableType = OpenableType.ROTATING_DOOR
## How long it takes to open the object.
@export var open_close_time: float = 0.6
## For rotating doors, how much the door rotates.
@export var rotation_amount_rad: float = PI / 2

## Whether the object is open
var is_open: bool = false
## The angles the object is at when closed.
var closed_angle: Vector3 = Vector3.ZERO
## The angles the object is at when open.
var open_angle: Vector3 = Vector3.ZERO

## The axis of rotation for rotating doors.
const DOOR_AXIS: Vector3 = Vector3(0, 1, 0)


## Called when the node is first loaded, initializes values for the [Openable] object.
func _ready() -> void:
	super()
	closed_angle = parent.rotation
	open_angle = closed_angle + (DOOR_AXIS * rotation_amount_rad)
	update_text_prompt()


## What the object does when the player looks at it. Currently unused, but would be used for 
## special logic like highlighting
func node_focused() -> void:
	super()


## What the object does when the player looks at it. Currently unused, but would be used for 
## special logic like disabling a highlight
func node_unfocused() -> void:
	super()


## What the object does when interacted. Opens the door for an [Openable] object.
func node_interacted() -> void:
	super()
	if not locked:
		open_close_entity()


## Triggers the object to forceably open. Can get around the object being locked.
func target_triggered() -> void:
	if not is_open:
		open_entity()


## Open or close the object.
func open_close_entity() -> void:
	if is_open:
		close_entity()
	else:
		open_entity()
	
	update_text_prompt()


## Handles the logic for opening the object.
func open_entity() -> void:
	is_open = true
	match open_type:
		OpenableType.ROTATING_DOOR:
			var tween = parent.get_tree().create_tween()
			tween.tween_property(parent, "rotation", open_angle, open_close_time )
			tween.tween_interval(open_close_time)
		_:
			pass


## Handles the logic for closing the object.
func close_entity() -> void:
	is_open = false
	match open_type:
		OpenableType.ROTATING_DOOR:
			var tween = parent.get_tree().create_tween()
			tween.tween_property(parent, "rotation", closed_angle, open_close_time )
			tween.tween_interval(open_close_time)
		_:
			pass


## Sets the interaction text that will appear on the player's hud when the object is focused on.
func update_text_prompt() -> void:
	if locked:
		interaction_prompt = "Locked"
	elif is_open:
		interaction_prompt = "Close"
	else:
		interaction_prompt = "Open"
