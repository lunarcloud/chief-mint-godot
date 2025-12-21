# GitHub Copilot Instructions for Chief Mint

## Project Overview
This is a Godot 3 add-on for defining, tracking, and displaying in-game achievements (called "mints"). The plugin supports local file storage and is designed to be extensible for platform-specific implementations.

## Code Style and Conventions

### GDScript Style
- Follow GDScript naming conventions:
  - Use `snake_case` for function names and variables
  - Use `PascalCase` for class names
  - Use `UPPER_CASE` for constants
- Use type hints where appropriate for better code clarity
- Keep functions focused and single-purpose

### Project Structure
- Core plugin code is in `addons/chief_mint/`
- Resources are in `addons/chief_mint/resources/`
- UI components are in `addons/chief_mint/ui/`
- Editor tools are in `addons/chief_mint/editor/`
- Source implementations are in `addons/chief_mint/sources/`

### Key Classes
- `ChiefMintSingleton`: Main singleton for managing achievements at runtime
- `ChiefMintSource`: Base class for achievement storage backends (extend this for new platforms)
- `ChiefMintSourceFile`: Local file storage implementation
- `ChiefMintDefinitionResource`: Individual achievement definition
- `ChiefMintDefinitionsResource`: Collection of achievement definitions

## Best Practices

### GDScript
- Use signals for event-driven architecture
- Prefer `export` variables for inspector-editable properties
- Document public APIs with comments
- Handle null/error cases gracefully
- Use `yield` appropriately for asynchronous operations

### Plugin Development
- Maintain backward compatibility where possible
- Keep editor-specific code separate from runtime code
- Use Godot's Resource system for data persistence
- Follow Godot's autoload singleton pattern

### Testing
- Test with demo scenes in `demo_scene/`
- Verify editor functionality in the Godot editor
- Test achievement progression and unlocking

## Architecture Notes
- The plugin uses a source-based architecture where different platforms can be supported by extending `ChiefMintSource`
- Achievement definitions are stored as Godot Resources (`.tres` files)
- Runtime progress is tracked separately from definitions
- The singleton pattern is used for global access to the achievement system

## When Adding Features
- Consider extensibility for different platforms
- Maintain separation between editor and runtime code
- Update example mints and demo scenes if relevant
- Ensure new features work with the existing resource-based workflow
