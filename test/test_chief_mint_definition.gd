extends GutTest
## Unit tests for ChiefMintDefinitionResource

func test_initialization():
	var definition = ChiefMintDefinitionResource.new()
	assert_not_null(definition, "Definition should be created")
	assert_eq(definition.resource_name, "Chief Mint Definition Resource", "Should have correct resource name")
	assert_eq(definition.maximum_progress, 1, "Should have default maximum_progress of 1")
	assert_true(definition.display_partial_progress, "Should display partial progress by default")
	assert_eq(definition.rarity, ChiefMintDefinitionResource.ChiefMintRarity.COMMON, "Should have COMMON rarity by default")


func test_is_class_identifies_correctly():
	var definition = ChiefMintDefinitionResource.new()
	assert_true(definition.is_class("ChiefMintDefinitionResource"), "Should identify as ChiefMintDefinitionResource")
	assert_true(definition.is_class("Resource"), "Should identify as Resource")


func test_differences_returns_empty_for_identical_definitions():
	var def1 = ChiefMintDefinitionResource.new()
	def1.name = "Test Achievement"
	def1.description = "Test description"
	def1.maximum_progress = 10
	def1.display_partial_progress = true
	def1.rarity = ChiefMintDefinitionResource.ChiefMintRarity.RARE
	
	var def2 = ChiefMintDefinitionResource.new()
	def2.name = "Test Achievement"
	def2.description = "Test description"
	def2.maximum_progress = 10
	def2.display_partial_progress = true
	def2.rarity = ChiefMintDefinitionResource.ChiefMintRarity.RARE
	
	var diffs = ChiefMintDefinitionResource.differences(def1, def2)
	assert_eq(diffs.size(), 0, "Should have no differences for identical definitions")


func test_differences_detects_name_difference():
	var def1 = ChiefMintDefinitionResource.new()
	def1.name = "Achievement A"
	
	var def2 = ChiefMintDefinitionResource.new()
	def2.name = "Achievement B"
	
	var diffs = ChiefMintDefinitionResource.differences(def1, def2)
	assert_has(diffs, "name", "Should detect name difference")


func test_differences_detects_description_difference():
	var def1 = ChiefMintDefinitionResource.new()
	def1.description = "Description A"
	
	var def2 = ChiefMintDefinitionResource.new()
	def2.description = "Description B"
	
	var diffs = ChiefMintDefinitionResource.differences(def1, def2)
	assert_has(diffs, "description", "Should detect description difference")


func test_differences_detects_maximum_progress_difference():
	var def1 = ChiefMintDefinitionResource.new()
	def1.maximum_progress = 10
	
	var def2 = ChiefMintDefinitionResource.new()
	def2.maximum_progress = 20
	
	var diffs = ChiefMintDefinitionResource.differences(def1, def2)
	assert_has(diffs, "maximum_progress", "Should detect maximum_progress difference")


func test_differences_detects_display_partial_progress_difference():
	var def1 = ChiefMintDefinitionResource.new()
	def1.display_partial_progress = true
	
	var def2 = ChiefMintDefinitionResource.new()
	def2.display_partial_progress = false
	
	var diffs = ChiefMintDefinitionResource.differences(def1, def2)
	assert_has(diffs, "display_partial_progress", "Should detect display_partial_progress difference")


func test_differences_detects_rarity_difference():
	var def1 = ChiefMintDefinitionResource.new()
	def1.rarity = ChiefMintDefinitionResource.ChiefMintRarity.COMMON
	
	var def2 = ChiefMintDefinitionResource.new()
	def2.rarity = ChiefMintDefinitionResource.ChiefMintRarity.RARE
	
	var diffs = ChiefMintDefinitionResource.differences(def1, def2)
	assert_has(diffs, "rarity", "Should detect rarity difference")


func test_differences_detects_multiple_differences():
	var def1 = ChiefMintDefinitionResource.new()
	def1.name = "Achievement A"
	def1.description = "Description A"
	def1.maximum_progress = 10
	
	var def2 = ChiefMintDefinitionResource.new()
	def2.name = "Achievement B"
	def2.description = "Description B"
	def2.maximum_progress = 20
	
	var diffs = ChiefMintDefinitionResource.differences(def1, def2)
	assert_eq(diffs.size(), 3, "Should detect all three differences")
	assert_has(diffs, "name", "Should detect name difference")
	assert_has(diffs, "description", "Should detect description difference")
	assert_has(diffs, "maximum_progress", "Should detect maximum_progress difference")


func test_differences_handles_null_first_parameter():
	var def = ChiefMintDefinitionResource.new()
	var diffs = ChiefMintDefinitionResource.differences(null, def)
	assert_eq(diffs.size(), 0, "Should return empty array when first parameter is null")


func test_differences_handles_null_second_parameter():
	var def = ChiefMintDefinitionResource.new()
	var diffs = ChiefMintDefinitionResource.differences(def, null)
	assert_eq(diffs.size(), 0, "Should return empty array when second parameter is null")


func test_rarity_enum_values():
	assert_eq(ChiefMintDefinitionResource.ChiefMintRarity.COMMON, 0, "COMMON should be 0")
	assert_eq(ChiefMintDefinitionResource.ChiefMintRarity.UNCOMMON, 1, "UNCOMMON should be 1")
	assert_eq(ChiefMintDefinitionResource.ChiefMintRarity.RARE, 2, "RARE should be 2")
	assert_eq(ChiefMintDefinitionResource.ChiefMintRarity.COMPLETION, 3, "COMPLETION should be 3")
