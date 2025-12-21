extends GutTest
## Unit tests for ChiefMintDefinitionsResource

func test_initialization():
	var definitions = ChiefMintDefinitionsResource.new()
	assert_not_null(definitions, "Definitions should be created")
	assert_eq(definitions.resource_name, "Chief Mint Definitions Resource", "Should have correct resource name")


func test_is_class_identifies_correctly():
	var definitions = ChiefMintDefinitionsResource.new()
	assert_true(definitions.is_class("ChiefMintDefinitionsResource"), "Should identify as ChiefMintDefinitionsResource")
	assert_true(definitions.is_class("Resource"), "Should identify as Resource")


func test_can_store_definitions_array():
	var definitions = ChiefMintDefinitionsResource.new()
	var def1 = ChiefMintDefinitionResource.new()
	def1.name = "Achievement 1"
	var def2 = ChiefMintDefinitionResource.new()
	def2.name = "Achievement 2"
	
	var defs_array: Array[Resource] = []
	defs_array.append(def1)
	defs_array.append(def2)
	definitions.definitions = defs_array
	assert_eq(definitions.definitions.size(), 2, "Should store two definitions")
	assert_eq(definitions.definitions[0].name, "Achievement 1", "Should store first definition correctly")
	assert_eq(definitions.definitions[1].name, "Achievement 2", "Should store second definition correctly")
