extends NinePatchRect

const ItemClass = preload("res://Item.gd");

onready var itemNameLabel = get_node("Item Name");
onready var itemValueLabel = get_node("Item Value");

func display(_item : ItemClass, mousePos : Vector2):
	visible = true;
	itemNameLabel.set_text(_item.itemName);
	itemValueLabel.set_text("Value: %d" % _item.itemValue)
	rect_size = Vector2(128, 64);
	rect_global_position = Vector2(mousePos.x + 5, mousePos.y + 5);
