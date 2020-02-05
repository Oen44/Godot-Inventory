extends TextureRect

var itemIcon;
var itemName;
var itemValue;
var itemSlot;
var picked = false;

func _init(_itemName, _itemTexture, _itemSlot, _itemValue):
	name = _itemName;
	self.itemName = _itemName;
	self.itemValue = _itemValue;
	texture = _itemTexture;
	self.itemSlot = _itemSlot;
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
