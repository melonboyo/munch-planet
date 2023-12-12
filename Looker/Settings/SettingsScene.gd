extends Control

@export_node_path("Looker") var looker_path
@onready var looker: Looker = get_node(looker_path)

@onready var tab_buttons = %TabButtons.get_children()
@onready var tabs = %Tabs.get_children().slice(1)


func _ready():
	_view_tab(0)
	
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
