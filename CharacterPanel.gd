extends Panel

var slots = Array();

func _ready():
	slots.resize(512);
	slots.insert(Global.SlotType.SLOT_HELMET, get_node("Left/SlotHelmet"));
	slots.insert(Global.SlotType.SLOT_ARMOR, get_node("Left/SlotArmor"));
	slots.insert(Global.SlotType.SLOT_FEET, get_node("Left/SlotFeet"));
	slots.insert(Global.SlotType.SLOT_NECK, get_node("Left/SlotNeck"));
	
	slots.insert(Global.SlotType.SLOT_RING, get_node("Right/SlotRing"));
	slots.insert(Global.SlotType.SLOT_RING2, get_node("Right/SlotRing2"));
	slots.insert(Global.SlotType.SLOT_LHAND, get_node("Right/SlotLHand"));
	slots.insert(Global.SlotType.SLOT_RHAND, get_node("Right/SlotRHand"));

func getSlotByType(type):
	if type == Global.SlotType.SLOT_RING:
		return [slots[Global.SlotType.SLOT_RING], slots[Global.SlotType.SLOT_RING2]];
		
	return slots[type];

func getItemByType(type):
	return slots[type].item;
