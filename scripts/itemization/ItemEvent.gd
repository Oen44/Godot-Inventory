class_name ItemEvent
extends Resource
## Base class for item events (use, equip, unequip).
## This class can be extended to create custom events with specific behavior.

## Example usage:
# Create a new script that extends ItemEvent, e.g. HealingPotion.gd
# Override the can_use and on_use methods to define the behavior when the item is used.
# In the ItemBase resource, assign the on_use property to an instance of the custom event script.

# Called to check if the item can be used. Return true if it can be used, false otherwise.
func can_use(_item: Item, _user: Node) -> bool:
	return false

# Called when the item is used. Return true if the item was successfully used, false otherwise.
func on_use(_item: Item, _user: Node) -> bool:
	return false

# Called when the item is equipped. Return false to prevent equipping.
func on_equip(_item: Item, _user: Node) -> bool:
	return false

# Called when the item is unequipped.
func on_unequip(_item: Item, _user: Node) -> void:
	pass
