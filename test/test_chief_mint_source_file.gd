extends GutTest
## Unit tests for ChiefMintSourceFile

var source: ChiefMintSourceFile
var test_save_path: String = "user://test_source_mints.tres"
var test_def_path: String = "user://test_source_defs.tres"


func before_each():
	# Clean up any existing test files first
	if FileAccess.file_exists(test_save_path):
		DirAccess.remove_absolute(test_save_path)
	if FileAccess.file_exists(test_def_path):
		DirAccess.remove_absolute(test_def_path)
	
	# Create a temporary definitions resource for testing
	var defs = ChiefMintDefinitionsResource.new()
	
	var def1 = ChiefMintDefinitionResource.new()
	def1.name = "First Achievement"
	def1.description = "Complete the first task"
	def1.maximum_progress = 10
	def1.rarity = ChiefMintDefinitionResource.ChiefMintRarity.COMMON
	
	var def2 = ChiefMintDefinitionResource.new()
	def2.name = "Second Achievement"
	def2.description = "Complete the second task"
	def2.maximum_progress = 1
	def2.rarity = ChiefMintDefinitionResource.ChiefMintRarity.UNCOMMON
	
	var def3 = ChiefMintDefinitionResource.new()
	def3.name = "Completion Achievement"
	def3.description = "Complete all achievements"
	def3.maximum_progress = 1
	def3.rarity = ChiefMintDefinitionResource.ChiefMintRarity.COMPLETION
	
	var defs_array: Array[Resource] = []
	defs_array.append(def1)
	defs_array.append(def2)
	defs_array.append(def3)
	defs.definitions = defs_array
	
	ResourceSaver.save(defs, test_def_path)
	
	# Set project settings to use our test files
	ProjectSettings.set_setting(ChiefMintConstants.MINT_DEFINITION_SETTING, test_def_path)
	ProjectSettings.set_setting(ChiefMintConstants.MINT_SOURCE_LOCAL_PATH_SETTING, test_save_path)
	
	# Ensure no save file exists before creating source
	if FileAccess.file_exists(test_save_path):
		DirAccess.remove_absolute(test_save_path)
	
	# Create source instance - this will create a fresh save from definitions
	source = ChiefMintSourceFile.new()
	add_child_autofree(source)


func after_each():
	# Clean up test files
	if FileAccess.file_exists(test_save_path):
		DirAccess.remove_absolute(test_save_path)
	if FileAccess.file_exists(test_def_path):
		DirAccess.remove_absolute(test_def_path)
	
	# Reset project settings
	ProjectSettings.set_setting(ChiefMintConstants.MINT_DEFINITION_SETTING, null)
	ProjectSettings.set_setting(ChiefMintConstants.MINT_SOURCE_LOCAL_PATH_SETTING, null)


func test_get_source_name():
	assert_eq(source.get_source_name(), "file", "Should return 'file' as source name")


func test_load_defs():
	var defs = source.load_defs()
	assert_not_null(defs, "Should load definitions")
	assert_eq(defs.definitions.size(), 3, "Should have 3 definitions")
	assert_eq(defs.definitions[0].name, "First Achievement", "Should load first definition correctly")


func test_load_saved_creates_initial_save():
	var save = source.load_saved()
	assert_not_null(save, "Should create initial save")
	assert_eq(save.mints.size(), 3, "Should have 3 mints")
	assert_eq(save.mints[0].progress.current, 0, "Initial progress should be 0")


func test_increment_progress():
	var mint = source.increment_progress("First Achievement")
	assert_not_null(mint, "Should return mint resource")
	assert_eq(mint.progress.current, 1, "Progress should increment to 1")
	
	source.increment_progress("First Achievement")
	var mint2 = source.increment_progress("First Achievement")
	assert_eq(mint2.progress.current, 3, "Progress should increment to 3")


func test_increment_progress_updates_save_file():
	source.increment_progress("First Achievement")
	
	# Create new source instance to verify save persistence
	var source2 = ChiefMintSourceFile.new()
	var progress = source2.get_progress("First Achievement")
	assert_eq(progress.current, 1, "Progress should persist across instances")


func test_set_progress():
	var mint = source.set_progress("First Achievement", 5)
	assert_not_null(mint, "Should return mint resource")
	assert_eq(mint.progress.current, 5, "Progress should be set to 5")


func test_set_progress_updates_save_file():
	source.set_progress("First Achievement", 7)
	
	# Create new source instance to verify save persistence
	var source2 = ChiefMintSourceFile.new()
	var progress = source2.get_progress("First Achievement")
	assert_eq(progress.current, 7, "Progress should persist across instances")


func test_is_complete_false_initially():
	assert_false(source.is_complete("First Achievement"), "Should not be complete initially")


func test_is_complete_true_when_progress_reaches_maximum():
	source.set_progress("Second Achievement", 1)
	assert_true(source.is_complete("Second Achievement"), "Should be complete when progress reaches maximum")


func test_is_complete_true_when_progress_exceeds_maximum():
	source.set_progress("Second Achievement", 5)
	assert_true(source.is_complete("Second Achievement"), "Should be complete when progress exceeds maximum")


func test_get_progress():
	source.set_progress("First Achievement", 3)
	var progress = source.get_progress("First Achievement")
	assert_not_null(progress, "Should return progress")
	assert_eq(progress.current, 3, "Should return correct current progress")
	assert_eq(progress.maximum, 10, "Should return correct maximum progress")


func test_get_progress_for_nonexistent_achievement():
	var progress = source.get_progress("Nonexistent Achievement")
	assert_null(progress, "Should return null for nonexistent achievement")


func test_clear_all_progress():
	source.set_progress("First Achievement", 5)
	source.set_progress("Second Achievement", 1)
	
	var result = source.clear_all_progress()
	assert_true(result, "Should return true on successful clear")
	
	var progress1 = source.get_progress("First Achievement")
	var progress2 = source.get_progress("Second Achievement")
	assert_eq(progress1.current, 0, "First achievement progress should be reset to 0")
	assert_eq(progress2.current, 0, "Second achievement progress should be reset to 0")


func test_create_save_from_definitions_static_method():
	var defs = source.load_defs()
	var save = ChiefMintSourceFile.create_save_from_definitions(defs)
	
	assert_not_null(save, "Should create save resource")
	assert_eq(save.mints.size(), 3, "Should have 3 mints")
	assert_eq(save.mints[0].progress.current, 0, "Current progress should be 0")
	assert_eq(save.mints[0].progress.maximum, 10, "Maximum should match definition")


func test_completion_achievement_unlocked_signal():
	watch_signals(source)
	
	# Complete all non-completion achievements
	source.set_progress("First Achievement", 10)
	source.set_progress("Second Achievement", 1)
	
	assert_signal_emitted(source, "completion_achievement_unlocked", 
		"Should emit completion_achievement_unlocked signal when all achievements complete")


func test_completion_achievement_auto_completes():
	# Complete all non-completion achievements
	source.set_progress("First Achievement", 10)
	source.set_progress("Second Achievement", 1)
	
	# Check that completion achievement is now complete
	assert_true(source.is_complete("Completion Achievement"), 
		"Completion achievement should auto-complete when all others complete")


func test_completion_achievement_does_not_complete_prematurely():
	# Complete only one achievement
	source.set_progress("First Achievement", 10)
	
	# Verify the second achievement is NOT complete
	var second_progress = source.get_progress("Second Achievement")
	assert_eq(second_progress.current, 0, "Second achievement should still be at 0")
	assert_false(source.is_complete("Second Achievement"), "Second achievement should not be complete")
	
	# Check that completion achievement is not complete yet
	assert_false(source.is_complete("Completion Achievement"), 
		"Completion achievement should not complete until all achievements complete")


func test_completion_achievement_signal_emits_only_once():
	watch_signals(source)
	
	# Complete all non-completion achievements
	source.set_progress("First Achievement", 10)
	source.set_progress("Second Achievement", 1)
	
	assert_signal_emit_count(source, "completion_achievement_unlocked", 1,
		"Should emit signal exactly once")
	
	# Increment again - should not emit signal again
	source.increment_progress("First Achievement")
	
	assert_signal_emit_count(source, "completion_achievement_unlocked", 1,
		"Should not emit signal again after already complete")
