extends Node3D
## A round target that can be hit, triggering another item to do something.

## The object that receives the trigger when this one is activated.
@export var trigger_entity: Node

## The private variable for the trigger_entity once it has been validated.
var _trigger_entity: Node


## Called when the node is first loaded, initializes the trigger entity.
func _ready() -> void:
	if trigger_entity:
		print(trigger_entity.has_method("target_triggered_parent"))
	if trigger_entity and trigger_entity.has_method("target_triggered_parent"):
		_trigger_entity = trigger_entity


## Called when something hits the parent. Used to update the trigger_entity
func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("projectile"):
		return
	
	if _trigger_entity:
		_trigger_entity.target_triggered_parent()
