extends Control
export var main_senese: PackedScene

func _on_Button_play_button_up():
	get_tree().change_scene(main_senese.resource_path)

func _on_Button_quit_button_up():
	get_tree().quit()
