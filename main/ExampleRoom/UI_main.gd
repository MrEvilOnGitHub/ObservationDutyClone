extends Control

class_name UI


export var submi_duration := 5

var current_type_nr: int = 0
var event_types = [
	"hovers",
	"rotators",
	"hiders"
]

var current_room: int = 0

signal kill_event(event_type, room_nr)

onready var event_selection_window := $StopEventButtons
onready var event_selection_open := $OpenEventSelector
onready var death_warning := $DeathWarning
onready var submit_timer := $SubmitTimer
onready var submit_button := $Submitting
onready var sucess_note := $SucessfulDeactivation
onready var sucess_timer := $SucessfulDeactivation/Timer
onready var fail_note := $FailedDeactivation
onready var fail_timer := $FailedDeactivation/Timer

signal swap_cam(forward)


func activate_death_warning():
	death_warning.visible = true


func successful_clear():
	sucess_note.visible = true
	sucess_timer.start()


func failed_clear():
	fail_note.visible = true
	fail_timer.start()


func button_back_pressed():
	emit_signal("swap_cam", false)


func button_forward_pressed():
	emit_signal("swap_cam", true)


func _on_type_switch(_Group: String, ButtonNr: int) -> void:
	current_type_nr = ButtonNr


func _on_room_switch(_Group: String, ButtonNr: int) -> void:
	current_room = ButtonNr


func _on_CancelEvent_pressed() -> void:
	event_selection_window.visible = false
	event_selection_open.visible = true


func _on_OpenEventSelector_pressed() -> void:
	event_selection_open.visible = false
	event_selection_window.visible = true


func _on_ConfirmEvent_pressed() -> void:
	submit_timer.start(submi_duration)
	submit_button.visible = true
	event_selection_window.visible = false


func _on_SubmitTimer_timeout() -> void:
	emit_signal("kill_event", event_types[current_type_nr], current_room)
	event_selection_open.visible = true
	submit_button.visible = false


func _on_SucessfulTimer_timeout() -> void:
	sucess_note.visible = false


func _on_FailedTimer_timeout() -> void:
	sucess_note.visible = false
