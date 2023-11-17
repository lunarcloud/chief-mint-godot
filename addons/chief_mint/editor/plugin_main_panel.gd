tool
extends Panel
## Plugin Main Panel
## The UI for the Chief Mint editor main window tab

signal saved

const Row := preload("res://addons/chief_mint/editor/definition_row.tscn")

var editor_scale := 1.0 setget set_editor_scale  # set once by the plugin

var definitions: ChiefMintDefinitionsResource

var changed_items: Array = []

onready var rows: Control = $Vbox/Acheivements/Rows

onready var panel = $Vbox/Panel

onready var save_button: Button = $Vbox/Panel/TopUI/SaveButton


func reload_from_file():
	for node in rows.get_children():
		node.queue_free()

	var load_path = ProjectSettings.get_setting(ChiefMintConstants.MINT_DEFINITION_SETTING)
	if load_path == null or not ResourceLoader.exists(load_path):
		definitions = ChiefMintDefinitionsResource.new()
	else:
		definitions = load(load_path)

	var has_completion_mint := false

	# Create rows for every definition, checking that there is only one completion rarity
	for def in definitions.definitions:
		var this_is_completion: bool = (
			def.rarity
			== ChiefMintDefinitionResource.ChiefMintRarity.COMPLETION
		)

		if this_is_completion and has_completion_mint:
			def.rarity = ChiefMintDefinitionResource.ChiefMintRarity.COMMON
		if this_is_completion:
			has_completion_mint = true

		var new_row = create_row()
		new_row.set_definition(def)

	# Add a mint at the top if no mints exist
	if (
		definitions.definitions.size() == 0
		or (
			definitions.definitions.size() == 1
			and (
				definitions.definitions[0].rarity
				== ChiefMintDefinitionResource.ChiefMintRarity.COMPLETION
			)
		)
	):
		create_tbd_def()

	# Add a completion mint at the top if no completion mints exist
	if not has_completion_mint:
		var completion := ChiefMintDefinitionResource.new()
		completion.name = "Completion"
		completion.rarity = ChiefMintDefinitionResource.ChiefMintRarity.COMPLETION
		definitions.definitions.insert(0, completion)

		var new_row = create_row()
		new_row.set_definition(completion)
		rows.move_child(new_row, 0)


func set_editor_theme(value: Theme, node = self) -> void:
	for c in node.get_children():
		#if c.has_method("set_editor_theme"):
		#	c.set_editor_theme(value, c)
		#elif 'editor_theme_icon' in c:
		if "editor_theme_icon" in c:
			if not value.has_icon(c.editor_theme_icon, "EditorIcons"):
				printerr("Icon not found {theme_icon}".format({"theme_icon": c.editor_theme_icon}))
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
	if not is_instance_valid(rows):
		return null

	var out := ChiefMintDefinitionsResource.new()

	var names_seen := []

	for node in rows.get_children():
		if (
			"definition" in node
			and node.definition is ChiefMintDefinitionResource
			and node.definition.name != ""
			and not names_seen.has(node.definition.name)
		):
			names_seen.append(node.definition.name)
			out.definitions.append(node.definition)

	return out


func _on_AddButton_pressed():
	create_row()


func create_tbd_def() -> void:
	var def := ChiefMintDefinitionResource.new()
	def.name = "TBD"
	definitions.definitions.append(def)

	var new_row = create_row()
	new_row.set_definition(def)


func create_row():
	var new_row := Row.instance()
	new_row.definition = ChiefMintDefinitionResource.new()
	new_row.set_editor_scale(editor_scale)
	rows.add_child(new_row)
	new_row.owner = self
	new_row.connect("definition_removed", self, "_on_def_removed")
	new_row.connect("definition_changed", self, "_on_def_changed")
	self.connect("saved", new_row, "on_saved")
	return new_row


func _on_SaveButton_pressed():
	definitions = get_definitions()
	var save_path = ProjectSettings.get_setting(ChiefMintConstants.MINT_DEFINITION_SETTING)
	#print("Trying to save {f}".format({'f': save_path}))
	var err = ResourceSaver.save(save_path, definitions)
	if err == OK:
		#print("Saved {f}".format({'f': save_path}))
		emit_signal("saved")
		changed_items.clear()
		save_button.disabled = true
	else:
		printerr("Failed to save {f}!".format({"f": save_path}))


func _on_def_removed(_definition: ChiefMintDefinitionResource) -> void:
	# two rows implies only a completion row and this one being deleted
	if rows.get_child_count() <= 2:
		create_tbd_def()


func _on_def_changed(unedited_def: ChiefMintDefinitionResource, has_changes: bool) -> void:
	if not has_changes and changed_items.has(unedited_def.name):
		changed_items.erase(unedited_def.name)
	elif has_changes and not changed_items.has(unedited_def.name):
		changed_items.append(unedited_def.name)

	save_button.disabled = changed_items.empty()
