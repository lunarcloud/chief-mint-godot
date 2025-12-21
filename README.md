# Chief Mint: Godot Achievements

![Addon Icon](icon.png)

This Godot 4.5+ add-on helps you define, track, and display in-game achievements.

"Local File Storage" achievements are good for an self-distributed or Itch release, where there is no platform-native system.

Other platforms, such as Steam, should be easy to implement (Pull-Requests welcomed) - you just need to extend "ChiefMintSource".

## Testing

This project uses **GUT (Godot Unit Test)** - the most popular testing framework for Godot. Tests are located in the `test/` directory and provide comprehensive coverage of the achievement system.

To run tests:
- **In Godot Editor**: Open the GUT panel and click "Run All"
- **Command line**: 
  1. First import the project: `godot --path . --headless --import`
  2. Then run tests: `godot --path . --headless -s addons/gut/gut_cmdln.gd`

See [TESTING.md](TESTING.md) for detailed testing documentation.

## In Editor

First, setup where you want your mint definitions to live, and what your editor source script/path will be.

![](screenshots/editing_mint_settings.jpg)

![](screenshots/editing_mint_source_settings.jpg)

Then, Define all of your achievements (mints), and save them.

![](screenshots/editing_mints.jpg)

## In Game

You can use or create a variant of the simple notification UI, "ChiefMintSimpleUI".

![](screenshots/using_mints_ingame_ui.jpg)

During the course of your game's logic, you will want to grab the Chief Mint Singleton, and register some progress on that event.

![](screenshots/using_mints_ingame_script.jpg)
