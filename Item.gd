extends TextureRect

var itemIcon;
var itemName;
var itemSlot;
var picked = false;

func _init(itemName, itemTexture, itemSlot, itemValue):
	name = itemName;
	self.itemName = itemName;
	texture = itemTexture;
	hint_tooltip = "Name: %s\n\nValue: %d" % [itemName, itemValue];
	self.itemSlot = itemSlot;
	mouse_filter = Control.MOUSE_FILTER_PASS;
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND;
	pass
	
func pickItem():
	mouse_filter = Control.MOUSE_FILTER_IGNORE;
	picked = true;
	pass
	
func putItem():
	rect_global_position = Vector2(0, 0);
	mouse_filter = Control.MOUSE_FILTER_PASS;
	picked = false;
	pass