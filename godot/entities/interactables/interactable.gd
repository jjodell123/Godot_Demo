## An object that can be interacted with; a parent type for all interactable classes.
##
## A [Interactable] object is anything the player can press a key to interact with.
## Should be added as child of the parent object.
class_name Interactable extends Node

## The keybind/controller input type used to interact with the object.
@export var interaction_input: String = "interact"
## The text prompt for how to interact with an object.
@export var interaction_prompt: String = "Use"

## The object this class is attached to.
var parent
## An alternate use text, used for specific types of [Interactable] nodes.
var alt_use_text: String =""


## Called when the node is first loaded, initializes values for the [Interactable] object and its signals.
func _ready() -> void:
	parent = get_parent()
	register_signals()


## What the object does when the player looks at it. Currently unused, but would be used for 
## special logic like highlighting
func node_focused() -> void:
	pass


## What the object does when the player looks at it. Currently unused, but would be used for 
## special logic like disabling a highlight
func node_unfocused() -> void:
	pass


## What the object does when interacted. Currently used only by child classes.
func node_interacted() -> void:
	pass


## Connects the signals on the parent class to the functions in the [Interactable] component.
func register_signals() -> void:
	parent.add_user_signal("focus")
	parent.add_user_signal("unfocus")
	parent.add_user_signal("interact")
	
	parent.connect("focus", Callable(self, "node_focused"))
	parent.connect("unfocus", Callable(self, "node_unfocused"))
	parent.connect("interact", Callable(self, "node_interacted"))


## Returns the text for how an [Interactable] component is interacted with by combining the 
## interaction prompt with the interaction key/mouse input
func get_interaction_input() -> String:
	# Immediately return if it can't be interacted with.
	if interaction_prompt == "Locked":
		return interaction_prompt
	
	var interact_event_text: String = ""
	
	# Match the interaction type to its display name
	for input_event in InputMap.action_get_events(interaction_input):
		if input_event is InputEventMouseButton:
			match input_event.button_index:
				1:
					interact_event_text = "Left Mouse"
				_:
					interact_event_text = ""
		elif input_event is InputEventKey:
			interact_event_text = input_event.as_text_physical_keycode()
		
	if interact_event_text == "":
		return ""
	
	return interaction_prompt + "\n[" + interact_event_text + "]"


## Getter for the alt_use_text
func get_alt_use_text() -> String:
	return alt_use_text
