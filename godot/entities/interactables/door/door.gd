extends StaticBody3D
## The door object's script. Handles triggered interactions.

## Searches the door's children for an [Interactable] node that can be triggered, then triggers it.
func target_triggered_parent() -> void:
	for child in get_children():
		if child is Interactable and child.has_method("target_triggered"):
			child.target_triggered()
