extends RayCast3D
## A raycast in front of the player that detects any [Interactable] objects.

## The parent object hit by the raycast.
var collider
## Whether or not the collider object is [Interactable].
var has_interactable: bool = false


## Updates the raycast collider to see what it is hitting and if that object is [Interactable].
func update_raycast_collider() -> void:
	var current_collider = get_collider()
	
	# If the trace result has not changed, return early ,
	if collider == current_collider:
		return
		
	# If collider previously had an [Interactable], unset it since we know we are now focused on something new.
	if has_interactable:
		assert(collider.has_user_signal("unfocus"), "Interactable component must have the unfocus signal")
		collider.emit_signal("unfocus")
		Global.player.update_interact_text("")
		has_interactable = false
		
	collider = current_collider
	
	if not collider:
		return
	
	# Check if the trace result has the [Interactable] component,
	var interactable: Interactable
	for child in collider.get_children():
		if child is Interactable:
			interactable = child
			break
	
	if not interactable:
		return
	
	# Getting here means we have found a new [Interactable], so update it,
	assert(collider.has_user_signal("focus"), "Interactable component must have the focus signal")
	collider.emit_signal("focus")

	Global.player.update_interact_text(interactable.get_interaction_input())
	has_interactable = true


## Get the node with an [Interactable] child.
func get_interactable_collider() -> Node:
	if not has_interactable:
		return null
		
	return collider
