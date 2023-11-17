tool
class_name ChiefMintPlugin, "res://addons/chief_mint/icon/icon-small-grey.png"
extends EditorPlugin

const Icon = preload("res://addons/chief_mint/icon/icon-small-grey.png")
const MainPanel = preload("res://addons/chief_mint/editor/plugin_main_panel.tscn")

var main_panel_instance


func _define_project_setting(
	p_name: String,
	p_type: int,
	p_hint: int = PROPERTY_HINT_NONE,
	p_hint_string: String = "",
	p_default_val = ""
) -> void:
	# p_default_val can be any type!!

	var property_info: Dictionary = {
		"name": p_name, "type": p_type, "hint": p_hint, "hint_string": p_hint_string
	}

	ProjectSettings.add_property_info(property_info)
	ProjectSettings.set_initial_value(p_name, p_default_val)
	if not ProjectSettings.has_setting(p_name):
		ProjectSettings.set_setting(p_name, p_default_val)


func _enter_tree():
	# Add Main Definitions File to the project settings
	_define_project_setting(
		ChiefMintConstants.MINT_DEFINITION_SETTING,
		TYPE_STRING,
		PROPERTY_HINT_FILE,
		"*.mints",
		ChiefMintConstants.MINT_DEFINITION_DEFAULT
	)

	# Add Main Definitions File to the project settings
	_define_project_setting(
		ChiefMintConstants.MINT_SOURCE_SETTING,
		TYPE_STRING,
		PROPERTY_HINT_FILE,
		"chief_mint_source_*.gd",
		ChiefMintConstants.MINT_SOURCE_DEFAULT
	)

	# Add Local Storage path to the project settings
	_define_project_setting(
		ChiefMintConstants.MINT_SOURCE_LOCAL_PATH_SETTING,
		TYPE_STRING,
		PROPERTY_HINT_PLACEHOLDER_TEXT,
		ChiefMintConstants.MINT_SOURCE_LOCAL_PATH_DEFAULT,
		ChiefMintConstants.MINT_SOURCE_LOCAL_PATH_DEFAULT
	)

	# Registers the ChiefMint node as an autoloaded singleton.
	add_autoload_singleton("ChiefMint", "res://addons/chief_mint/chief_mint_singleton.gd")

	main_panel_instance = MainPanel.instance()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	make_visible(false)

	# Allow UI components to adjust accordingly with editor scaling
	var scale = get_editor_interface().get_editor_scale()
	main_panel_instance.set_editor_scale(scale)

	# Allow UI to use the editor theme
	var theme = get_editor_interface().get_base_control().theme
	main_panel_instance.set_editor_theme(theme)

	# Update the main panel's data
	main_panel_instance.reload_from_file()

	print("Chief Mint Plugin enabled")


func _exit_tree():
	# Unregisters the ChiefMint node from autoloaded singletons.
	remove_autoload_singleton("ChiefMint")

	if main_panel_instance:
		main_panel_instance.queue_free()

	print("Chief Mint Plugin disabled")


func has_main_screen():
	return true


func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func get_plugin_name():
	return "ChiefMint"


func get_plugin_icon() -> Texture:
	return Icon
