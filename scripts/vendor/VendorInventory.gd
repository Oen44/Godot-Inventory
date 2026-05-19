class_name VendorInventory
extends InventoryModel

var _vendor: VendorComponent

var _quick_buy: bool = false

func _ready():
	super._ready()

	config.interactable = false
	config.persistent = false

func set_vendor(vendor: VendorComponent) -> void:
	_clear()
	_vendor = vendor
	
	var vendor_items = vendor.get_items()
	for i in range(vendor_items.size()):
		var item = vendor_items[i]
		if item:
			add_item_at(item, i)

func _inventory_view_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _place_back():
			return
		
		_sell_held_item()

func _on_slot_clicked(slot: InventorySlot, button: MouseButton, ctrl_pressed: bool, _shift_pressed: bool) -> void:
	if _place_back():
		accept_event()
		return
	
	if button == MOUSE_BUTTON_LEFT:
		if _sell_held_item():
			accept_event()
			return
		
		# Buy
		var inventory_item: InventoryItem = slot.get_inventory_item()
		if not inventory_item:
			return
		
		if inventory_item.item.base.stackable:
			if _quantity_selector.visible:
				return
			
			_quantity_selector.set_item(inventory_item.item)
			_quantity_selector.confirmed.connect(_on_quantity_confirmed)
			_quantity_selector.canceled.connect(_on_quantity_canceled)
			_quantity_selector.show()
		else:
			var clone = inventory_item.item.clone(1)
			InventorySystem.pick_up_item(clone)
			accept_event()
	elif button == MOUSE_BUTTON_RIGHT:
		var inventory_item: InventoryItem = slot.get_inventory_item()
		if not inventory_item:
			return
		
		if inventory_item.item.base.stackable:
			if ctrl_pressed:
				buy_item(inventory_item.item.clone(inventory_item.item.quantity))
			else:
				if _quantity_selector.visible:
					return
				
				_quantity_selector.set_item(inventory_item.item)
				_quantity_selector.confirmed.connect(_on_quantity_confirmed)
				_quantity_selector.canceled.connect(_on_quantity_canceled)
				_quantity_selector.show()
				_quick_buy = true
		else:
			buy_item(inventory_item.item.clone(1))

func _sell_held_item() -> bool:
	if InventorySystem.is_holding_item():
		var held_item = InventorySystem.get_held_item()
		var ret = sell_item(held_item)
		
		if not ret:
			var player_inventory = InventorySystem.get_player_inventory()
			player_inventory.add_item(held_item)
		
		InventorySystem.drop_held_item()
		return ret
	
	return false

func sell_item(item: Item) -> bool:
	if not item:
		return false
	
	var worth = item.get_worth()
	var player_inventory = InventorySystem.get_player_inventory()

	if worth <= 0 or not player_inventory.can_create_item_by_id("gold_coin", worth * item.quantity):
		return false

	if item.slot_id != -1:
		var parent_inventory = InventorySystem.get_inventory(item.parent_inventory)
		parent_inventory.remove_item(item)

	player_inventory.create_item_by_id("gold_coin", worth * item.quantity)
	return true

func _on_quantity_confirmed(quantity: int) -> void:
	_quantity_selector.confirmed.disconnect(_on_quantity_confirmed)
	_quantity_selector.canceled.disconnect(_on_quantity_canceled)
	_quantity_selector.hide()

	if quantity <= 0:
		return

	var item: Item = get_item_at(_quantity_selector.item.slot_id)
	if not item:
		return
	
	if quantity > item.quantity:
		return
	
	if _quick_buy:
		buy_item(item.clone(quantity))
		return
	
	var clone = item.clone(quantity)
	InventorySystem.pick_up_item(clone)

func _on_quantity_canceled() -> void:
	_quantity_selector.confirmed.disconnect(_on_quantity_confirmed)
	_quantity_selector.canceled.disconnect(_on_quantity_canceled)
	_quantity_selector.hide()

func buy_item(item: Item) -> bool:
	var player_inventory = InventorySystem.get_player_inventory()

	var cost = item.get_worth() * item.quantity
	var currency = 0
	if item.currency_item:
		currency = player_inventory.get_item_count(item.currency_item.id)
	else:
		currency = player_inventory.get_currency_amount()

	if cost > currency:
		return false

	if not player_inventory.can_add_item(item):
		InventorySystem.drop_held_item()
		return false
	
	var slot_id = item.slot_id
	var success = _vendor.buy_item(slot_id, item)
	if success:
		item.vendor_item = false
		item.price = 0
		item.currency_item = null
		player_inventory.add_item(item)
		InventorySystem.drop_held_item()
		
		## Remove currency
		if item.currency_item:
			player_inventory.remove_item_by_id(item.currency_item.id, cost)
		else:
			player_inventory.remove_currency(cost)
	else:
		InventorySystem.drop_held_item()

	return success

func _place_back() -> bool:
	if InventorySystem.is_holding_item():
		var held_item: Item = InventorySystem.get_held_item()
		if held_item.vendor_item:
			InventorySystem.drop_held_item()
			return true
	
	return false
