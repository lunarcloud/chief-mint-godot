extends GutTest
## Unit tests for ChiefMintSaveResource

func test_initialization():
	var save = ChiefMintSaveResource.new()
	assert_not_null(save, "Save resource should be created")
	assert_eq(save.resource_name, "Chief Mint Save Resource", "Should have correct resource name")


func test_is_class_identifies_correctly():
	var save = ChiefMintSaveResource.new()
	assert_true(save.is_class("ChiefMintSaveResource"), "Should identify as ChiefMintSaveResource")
	assert_true(save.is_class("Resource"), "Should identify as Resource")


func test_can_store_mints_array():
	var save = ChiefMintSaveResource.new()
	var mint1 = ChiefMintResource.new()
	var def1 = ChiefMintDefinitionResource.new()
	def1.name = "Achievement 1"
	mint1.definition = def1
	
	var mint2 = ChiefMintResource.new()
	var def2 = ChiefMintDefinitionResource.new()
	def2.name = "Achievement 2"
	mint2.definition = def2
	
	var mints_array: Array[Resource] = []
	mints_array.append(mint1)
	mints_array.append(mint2)
	save.mints = mints_array
	assert_eq(save.mints.size(), 2, "Should store two mints")
	assert_eq(save.mints[0].definition.name, "Achievement 1", "Should store first mint correctly")
	assert_eq(save.mints[1].definition.name, "Achievement 2", "Should store second mint correctly")
