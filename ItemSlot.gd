extends TextureRect

var slotIndex;
var item = null;

func _init(_slotIndex):
	self.slotIndex = _slotIndex;
	name = "ItemSlot_%d" % _slotIndex;
	texture = preload("res://images/skil.png");
	mouse_filter = Control.MOUSE_FILTER_PASS;
	
func setItem(newItem):
	add_child(newItem);
	item = newItem;
	item.itemSlot = self;
	
func pickItem():
	item.pickItem();
	remove_child(item);
	get_parent().get_parent().add_child(item);
	item = null;

func putItem(newItem):
	item = newItem;
	item.itemSlot = self;
	item.putItem();
	get_parent().get_parent().remove_child(item);
	add_child(item);
