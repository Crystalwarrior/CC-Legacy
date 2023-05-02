extends Area2D

signal item_tracked(item)
signal item_untracked(item)

var _tracked_item = null
var _overlapped_items = []

func _on_area_entered(area):
	if area.is_in_group("interactable"):
		_overlapped_items.append(area)

func _on_area_exited(area):
	if area.is_in_group("interactable"):
		_overlapped_items.erase(area)

func _physics_process(delta):
	if get_tree().has_network_peer() and not is_network_master():
		return

	if not _overlapped_items:
		if _tracked_item:
			emit_signal("item_untracked", _tracked_item)
		_tracked_item = null
	else:
		_overlapped_items.sort_custom(self, "getClosest")
		var new_tracked_item = _overlapped_items[0]
		if _tracked_item and _tracked_item != new_tracked_item:
			emit_signal("item_untracked", _tracked_item)
		_tracked_item = new_tracked_item
		emit_signal("item_tracked", _tracked_item)

func getClosest(a, b):
	return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position)