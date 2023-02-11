tool
class_name ChiefMintPlugin, "res://addons/chief_mint/icon/icon-small-grey.png"
extends EditorPlugin

const Icon = preload("res://addons/chief_mint/icon/icon-small-grey.png")
const MainPanel = preload("res://addons/chief_mint/plugin_main_panel.tscn")

var main_panel_instance


func _enter_tree():
	main_panel_instance = MainPanel.instance()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	make_visible(false)


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()


func has_main_screen():
	return true


func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func get_plugin_name():
	return "ChiefMint"


func get_plugin_icon() -> Texture:
	return Icon
