extends Spatial


export var min_update_duration := 10
export var max_update_duration := 20
export var max_active_events_before_death := 4
export var death_countdown := 10

onready var timer := $NewEventTimer
onready var death_timer := $DeathTimer
onready var UI := $UI


var all_possible_events_count: int = 0
var active_objects_count: int = 0
var rooms = []
var events_cleared := 0

func _ready() -> void:
	var children := get_children()
	children.sort()
	for child in children:
		if child is GameRoom:
			rooms.append(child)
			all_possible_events_count += child.get_max_event_count()
	Global.sort_list_of_nodes_by_number_at_end(rooms, "Room")
	Global.events_cleared = 0

	timer.start(rand_range(min_update_duration, max_update_duration))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("force_activate_interaction"):
		if Global.debug_out:
			print("Forced activation")
		activate_random_object()
	elif Input.is_action_just_pressed("clear_oldest_interaction"):
		# TODO: Implement this
		if Global.debug_out:
			print("Force deactivating an event")


func list_select_random(list: Array):
	return list[floor(rand_range(0, len(list)))]


func dict_select_random(dict: Dictionary):
	var keys = dict.keys()
	return dict[list_select_random(keys)]


func dict_select_random_key(dict: Dictionary):
	return list_select_random(dict.keys())


func activate_random_object():
	if active_objects_count == all_possible_events_count:
		return
	var room = list_select_random(rooms)
	var checked = []
	while len(checked) <= len(rooms) and room.is_max_active():
		if not room in checked:
			checked.append(room)
		room = list_select_random(rooms)
	if len(checked) >= len(rooms):
		if Global.debug_out:
			print("Can't activate any more events")
		return

	if Global.debug_out:
		print("Activating random object in ", room.name)
	active_objects_count += 1
	room.activate_random_object()


func _on_spawn_new_event() -> void:
	activate_random_object()
	if active_objects_count >= max_active_events_before_death:
		death_timer.start(death_countdown)
		UI.activate_death_warning()
	timer.start(rand_range(min_update_duration, max_update_duration))


func _on_UI_kill_event(event_type: String, room_nr: int) -> void:
	if rooms[room_nr].deactivate_object_of_type(event_type):
		Global.events_cleared += 1
		active_objects_count -= 1
		UI.successful_clear()
	else:
		UI.failed_clear()


func _on_DeathTimer_timeout() -> void:
	if active_objects_count < max_active_events_before_death:
		return
	if Global.debug_out:
		print("Death timer timeout")
	var err = get_tree().change_scene("res://main/SplashScreens/Death.tscn")
	if err != OK:
		get_tree().quit(err)


func _on_VictoryTimer_timeout() -> void:
	var err = get_tree().change_scene("res://main/SplashScreens/Victory.tscn")
	if err != OK:
		get_tree().quit(err)
