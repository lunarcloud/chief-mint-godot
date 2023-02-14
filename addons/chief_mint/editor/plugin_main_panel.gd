tool
extends Panel

onready var rows : Control = $Vbox/Acheivements/Rows

onready var panel = $Vbox/Panel

const Row := preload("res://addons/chief_mint/editor/definition_row.tscn")

var editor_scale := 1.0 setget set_editor_scale # set once by the plugin

var definitions: ChiefMintDefinitionsResource


func reload_from_file():
	for node in rows.get_children():
		node.queue_free()
	
	var loadPath = ProjectSettings.get_setting("chief_mint/editor/definitions")
	if loadPath == null or not ResourceLoader.exists(loadPath):
		definitions = null
		return
	
	definitions = load(loadPath)
		
	for def in definitions.definitions:
		var new_row = create_row()
		new_row.set_definition(def)


func set_editor_theme(value: Theme, node = self) -> void:
	for c in node.get_children():
		#if c.has_method("set_editor_theme"):
		#	c.set_editor_theme(value, c)
		#elif 'editor_theme_icon' in c:
		if 'editor_theme_icon' in c:
			if not value.has_icon(c.editor_theme_icon, "EditorIcons"):
				printerr("Icon not found {theme_icon}".format({'theme_icon': c.editor_theme_icon}))
				continue
			var icon := value.get_icon(c.editor_theme_icon, "EditorIcons")
			c.icon = icon
			c.text = ""
			c.icon_align = Button.ALIGN_CENTER
		else:
			self.set_editor_theme(value, c)
	

func set_editor_scale(value: float) -> void:
	editor_scale = value
	panel.rect_min_size.y *= value
	for node in rows.get_children():
		if node.has_method("set_editor_scale"):
			node.set_editor_scale(value)


func get_definitions() -> ChiefMintDefinitionsResource:
	var out := ChiefMintDefinitionsResource.new()
	
	var names_seen := []
	
	for node in rows.get_children():
		if 'definition' in node \
		and node.definition is ChiefMintDefinitionResource \
		and node.definition.name != "" \
		and not names_seen.has(node.definition.name):
			names_seen.append(node.definition.name)
			out.definitions.append(node.definition)
	
	return out


func _on_AddButton_pressed():
	create_row()


func create_row():
	var new_row := Row.instance()
	new_row.definition = ChiefMintDefinitionResource.new()
	new_row.set_editor_scale(editor_scale)
	rows.add_child(new_row)
	new_row.owner = self
	return new_row
	

func _on_SaveButton_pressed():
	definitions = get_definitions()
	var savePath = ProjectSettings.get_setting("chief_mint/editor/definitions")
	print("Trying to save {f}".format({'f': savePath}))
	var err = ResourceSaver.save(savePath, definitions)
	if err == OK:
		print("Saved")
	else:
		printerr("OH NO!")
