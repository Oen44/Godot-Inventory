class_name BaseInventoryModel
extends Control
## Base class for inventory models, providing common functionality for different inventory types.

## Stacks item A with item B, if item B can be stacked with item A
func stack_items(item_a: Item, item_b: Item) -> bool:
	if not item_a.base.stackable or not item_b.base.stackable:
		return false
	
	if item_a.base.id != item_b.base.id:
		return false
	
	if item_b.quantity >= item_a.base.max_stacks:
		return false
	
	var missing_quant = item_b.base.max_stacks - item_b.quantity
	var to_add = min(missing_quant, item_a.quantity)
	item_b.set_quantity(item_b.quantity + to_add)
	item_a.set_quantity(item_a.quantity - to_add)
	
	return true
