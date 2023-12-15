extends Control

@export_node_path("Looker") var looker_path
@onready var looker: Looker = get_node(looker_path)

@onready var tab_buttons = %TabButtons.get_children()
@onready var tabs = %Tabs.get_children().slice(1)

var credits_button_scene = preload("res://Looker/Settings/CreditsButton.tscn")


const LOOKER_WITH_CREDITS_HEIGHT = 279


func _ready():
	_view_tab(0)
	
	if looker.is_in_main_menu:
		looker.window_height = LOOKER_WITH_CREDITS_HEIGHT
		var credits_button = credits_button_scene.instantiate()
		%GeneralTab.add_child(credits_button)
	
	for i in range(tabs.size()):
		tab_buttons[i].pressed.connect(_view_tab.bind(i))


func _view_tab(index: int):
	for i in range(tabs.size()):
		tabs[i].visible = i == index
		tab_buttons[i].button_pressed = i == index


func _on_text_speed_slider_focus_entered():
	_view_tab(0)


func _on_master_volume_slider_focus_entered():
	_view_tab(1)
