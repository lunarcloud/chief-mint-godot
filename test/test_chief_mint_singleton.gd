extends GutTest
## Unit tests for ChiefMintSingleton

var singleton: ChiefMintSingleton
var test_save_path: String = "user://test_singleton_mints.tres"
var test_def_path: String


func before_each():
	# Clean up any existing test files first
	if FileAccess.file_exists(test_save_path):
		DirAccess.remove_absolute(test_save_path)
	if FileAccess.file_exists(test_def_path):
		DirAccess.remove_absolute(test_def_path)

	# Create a temporary definitions resource for testing
	var defs = ChiefMintDefinitionsResource.new()

	var def1 = ChiefMintDefinitionResource.new()
	def1.name = "Test Achievement 1"
	def1.description = "Test description 1"
	def1.maximum_progress = 5
	def1.rarity = ChiefMintDefinitionResource.ChiefMintRarity.COMMON

	var def2 = ChiefMintDefinitionResource.new()
	def2.name = "Test Achievement 2"
	def2.description = "Test description 2"
	def2.maximum_progress = 1
	def2.rarity = ChiefMintDefinitionResource.ChiefMintRarity.RARE

	var def3 = ChiefMintDefinitionResource.new()
	def3.name = "Completion"
	def3.description = "Complete all"
	def3.maximum_progress = 1
	def3.rarity = ChiefMintDefinitionResource.ChiefMintRarity.COMPLETION

	var defs_array: Array[Resource] = []
	defs_array.append(def1)
	defs_array.append(def2)
	defs_array.append(def3)
	defs.definitions = defs_array

	test_def_path = "user://test_singleton_defs.tres"
	ResourceSaver.save(defs, test_def_path)

	# Set project settings to use our test files
	ProjectSettings.set_setting(ChiefMintConstants.MINT_DEFINITION_SETTING, test_def_path)
	ProjectSettings.set_setting(ChiefMintConstants.MINT_SOURCE_LOCAL_PATH_SETTING, test_save_path)

	# Ensure no save file exists before creating singleton
	if FileAccess.file_exists(test_save_path):
		DirAccess.remove_absolute(test_save_path)

	# Create singleton instance and call _ready manually
	singleton = ChiefMintSingleton.new()
	add_child_autofree(singleton)
	singleton._ready()


func after_each():
	# Clean up test files
	if FileAccess.file_exists(test_save_path):
		DirAccess.remove_absolute(test_save_path)
	if FileAccess.file_exists(test_def_path):
		DirAccess.remove_absolute(test_def_path)

	# Reset project settings
	ProjectSettings.set_setting(ChiefMintConstants.MINT_DEFINITION_SETTING, null)
	ProjectSettings.set_setting(ChiefMintConstants.MINT_SOURCE_LOCAL_PATH_SETTING, null)


func test_singleton_initializes():
	assert_not_null(singleton, "Singleton should initialize")
	assert_not_null(singleton.source, "Singleton should have a source")
	assert_not_null(singleton.state, "Singleton should have state")


func test_get_source_name():
	var source_name = singleton.get_source_name()
	assert_eq(source_name, "file", "Should return correct source name")


func test_init_resource_from_def():
	var def = ChiefMintDefinitionResource.new()
	def.name = "Test"
	def.maximum_progress = 10

	var resource = singleton.init_resource_from_def(def)
	assert_not_null(resource, "Should create resource")
	assert_eq(resource.definition, def, "Should set definition")
	assert_not_null(resource.progress, "Should create progress")
	assert_eq(resource.progress.current, 0, "Progress should start at 0")


func test_increment_progress():
	singleton.increment_progress("Test Achievement 1")
	var progress = singleton.get_progress("Test Achievement 1")
	assert_eq(progress.current, 1, "Progress should increment to 1")


func test_increment_progress_emits_signal():
	watch_signals(singleton)
	singleton.increment_progress("Test Achievement 1")
	assert_signal_emitted(singleton, "progress_changed", "Should emit progress_changed signal")


func test_increment_progress_does_not_emit_signal_if_no_change():
	# First, mark achievement as complete
	singleton.set_progress("Test Achievement 2", 1)

	watch_signals(singleton)
	# Try to increment a completed achievement
	singleton.increment_progress("Test Achievement 2")

	assert_signal_not_emitted(
		singleton, "progress_changed", "Should not emit signal when achievement is already complete"
	)


func test_set_progress():
	singleton.set_progress("Test Achievement 1", 3)
	var progress = singleton.get_progress("Test Achievement 1")
	assert_eq(progress.current, 3, "Progress should be set to 3")


func test_set_progress_emits_signal():
	watch_signals(singleton)
	singleton.set_progress("Test Achievement 1", 4)
	assert_signal_emitted(singleton, "progress_changed", "Should emit progress_changed signal")


func test_set_progress_does_not_emit_signal_if_no_change():
	singleton.set_progress("Test Achievement 1", 2)

	watch_signals(singleton)
	singleton.set_progress("Test Achievement 1", 2)

	assert_signal_not_emitted(
		singleton, "progress_changed", "Should not emit signal when progress doesn't change"
	)


func test_is_complete_initially_false():
	assert_false(singleton.is_complete("Test Achievement 1"), "Should not be complete initially")


func test_is_complete_true_after_reaching_maximum():
	singleton.set_progress("Test Achievement 2", 1)
	assert_true(
		singleton.is_complete("Test Achievement 2"), "Should be complete after reaching maximum"
	)


func test_get_progress_returns_correct_values():
	singleton.set_progress("Test Achievement 1", 2)
	var progress = singleton.get_progress("Test Achievement 1")
	assert_eq(progress.current, 2, "Should return correct current progress")
	assert_eq(progress.maximum, 5, "Should return correct maximum progress")


func test_clear_all_progress():
	singleton.set_progress("Test Achievement 1", 3)
	singleton.set_progress("Test Achievement 2", 1)

	var result = singleton.clear_all_progress()
	assert_true(result, "Should successfully clear all progress")

	var progress1 = singleton.get_progress("Test Achievement 1")
	var progress2 = singleton.get_progress("Test Achievement 2")
	assert_eq(progress1.current, 0, "First achievement should be reset")
	assert_eq(progress2.current, 0, "Second achievement should be reset")


func test_loaded_from_source_signal():
	watch_signals(singleton)
	singleton.load_from_source()
	assert_signal_emitted(singleton, "loaded_from_source", "Should emit loaded_from_source signal")


func test_completion_achievement_unlocked_propagates():
	watch_signals(singleton)

	# Complete all non-completion achievements
	singleton.set_progress("Test Achievement 1", 5)
	singleton.set_progress("Test Achievement 2", 1)

	# The singleton should receive and re-emit the completion signal
	assert_signal_emitted(
		singleton,
		"progress_changed",
		"Should emit progress_changed when completion achievement unlocks"
	)


func test_increment_progress_does_not_exceed_when_complete():
	singleton.set_progress("Test Achievement 2", 1)
	assert_true(singleton.is_complete("Test Achievement 2"), "Achievement should be complete")

	var progress_before = singleton.get_progress("Test Achievement 2").current
	singleton.increment_progress("Test Achievement 2")
	var progress_after = singleton.get_progress("Test Achievement 2").current

	assert_eq(
		progress_before,
		progress_after,
		"Progress should not increment when achievement is complete"
	)


func test_get_progress_for_nonexistent_achievement():
	# Should push an error and return a default ChiefMintProgress object
	var progress = singleton.get_progress("Nonexistent Achievement")
	assert_not_null(progress, "Should return a progress object")
	assert_eq(progress.current, 0, "Should have default values for nonexistent achievement")
	assert_push_error(
		"ChiefMint: Cannot get progress - achievement 'Nonexistent Achievement' not found"
	)


func test_is_complete_for_nonexistent_achievement():
	var is_complete = singleton.is_complete("Nonexistent Achievement")
	assert_false(is_complete, "Should return false for nonexistent achievement")
