# Legends of Learning SDK Integration Plugin for Godot

![Logo](icon.png)

## Overview

The **Legends of Learning SDK Integration Plugin for Godot** is an essential Godot addon designed to simplify communication between your game and the Legends of Learning (LoL) platform environment.

It automatically provides a global **Singleton** called **`LoLApi`** which handles all low-level `JavaScriptBridge` messaging, allowing you to focus on game development.



-----

## 🚀 Installation

1.  **Install Plugin:** Download legends-of-learning-sdk-5.4-integration-plugin-for-godot-4.4-vMAJOR.MINOR.PATCH.zip from [GitHub Releases](https://github.com/TheDigitalSpell/legends-of-learning-sdk-integration-plugin-for-godot/releases) or Godot Asset Library. Unzip and copy the `addons/lolapi` folder into the `addons/` directory of your Godot 4 project.
2.  **Enable Plugin:** Go to **Project \> Project Settings \> Plugins** and check the status of the **Legends of Learning SDK Integration Plugin for Godot** is set to **Enable**.
3.  **Export Feature:** For export targeting the LoL platform, go to **Project \> Export \>** and create a new export preset (e.g. **HTML5 - LoLApi**) and add `LoLApi` to the feature list.
4.  **Translation Requirement (Crucial) 🌐:** The plugin relies on the **`TranslationsLoader`** utility class to manage in-game language changes requested by the LoL platform. This utility interacts with Godot's **`TranslationServer`**. You **must** have a primary translation file named **`translations.json`** located in the **root** of your project (`res://translations.json`). This file is required to properly initialize Godot's translation system before the SDK sends a language change.
5. **Optimization for LoL Platform (Mandatory) 📦:** To publish games on LoL using Godot 4, you **must reduce the final build size**. LoL requires a stripped-down HTML export template to meet their size requirements.
      * **Optimization Guide:** [Optimizing Godot Builds for HTML5/LoL](https://thedigitalspell.com/optimizing-godot-builds/)
      * **Optimization Tool:** [godot-lol-web-build-template-builder](https://github.com/ChocolatePinecone/godot-lol-web-build-template-builder)

## 🔌 Core Usage

The wrapper uses the standard Godot **Signals** and **Methods** pattern.

  * **Signals:** For **incoming** messages from the LoL SDK to your game (e.g., "Pause," "Load Data").
  * **Methods:** For **outgoing** messages from your game to LoL SDK (e.g., "Save Data," "Complete Game").

The **`LoLApi`** Singleton is available globally.

### Step 1: Initialize Communication

In your main game script, use the `OS.has_feature()` check to ensure the LoLApi is only initialized when running in the required web environment.

```gdscript
func _ready():
    # ... your game initialization logic ...

    # Godot 4: Check for the HTML5 LoLApi feature
    if OS.has_feature("LoLApi"): 
        # Start the communication handshake
        _init_LoL()
    else:
        print("Running in local mode. LoL SDK features disabled.")
        # Run your local load/initialization logic here

func _on_savedata_loaded():
    # ... your game continue here ...
```

### Step 2: Respond and Send the Ready Signal

The `_init_LoL` method is the key starting point. Use its callback to request save data, and finally, notify the SDK that your game is fully ready.

```gdscript
#region LoL
func _init_LoL():
	LoLApi.init_message_received.connect(_on_LoL_init_message_received)
	LoLApi.start_message_received.connect(_on_LoL_start_message_received)
	LoLApi.translation_message_received.connect(_on_LoL_translation_message_received)
	LoLApi.load_state_message_received.connect(_on_LoL_load_state_message_received)
	LoLApi.save_state_result_message_received.connect(_on_LoL_save_state_result_message_received)
	# ... See demo script for more examples
	
	LoLApi.send_init_message()

func _on_LoL_init_message_received(_payload: Dictionary):
	LoLApi.send_start_message()

func _on_LoL_start_message_received(payload: Dictionary):
	# '{"languageCode":"en","awkAutoSpeak":false,"awkMusicOn":false,"awkSfxOn":false}'}
	LoLApi.send_saves_request_message()
	# Request saves and return LoLApi.load_state_message_received with payload (_on_LoL_load_state_message_received)
	
func _on_LoL_load_state_message_received(payload: Dictionary):
	if not payload.is_empty() and payload.has("data"):
		# ... load_game with payload.data ...
		if payload.has("currentProgress"):
			# ... save payload.currentProgress in a local variable and send current progress to teacher...
			LoLApi.send_progress(SaveData.current_progress, SaveData.max_progress)
	else:
		# ... load_game with default data ...
	await get_tree().process_frame
	# Force save in next frame
	# ... save_game ...
#endregion

func _on_LoL_translation_message_received(payload: Dictionary):
	TranslationsLoader.set_locale(payload.language)
	# ... Refresh language here ...
```

-----

## 📊 Essential Outgoing Methods

Use these methods on the global `LoLApi` Singleton to communicate key game events back to the LoL SDK:

| Method | Purpose |
| :--- | :--- |
| `LoLApi.send_save_state_message(current_progress, max_progress, data)` | Saves the current state. `data` is a Dictionary that is converted to JSON. |
| `LoLApi.send_progress(current_progress, max_progress)` | Sends the player's progress. |
| `LoLApi.send_progress_and_score_message(current_progress, max_progress, score)` | Sends the player's progress and score for tracking. |
| `LoLApi.send_text_to_speech_message(text, code)` | Sends text to be read aloud by the platform's Text-to-Speech service. |
| `LoLApi.send_pause_message()` | Tells the platform that the game is pausing (less common, usually managed by the platform). |
| `LoLApi.send_complete_message()` | Notifies the platform that the game has finished. |

¡Por supuesto! Aquí tienes la misma sección traducida y adaptada al inglés, utilizando exactamente la nomenclatura del plugin de Godot que mencionan tus fuentes, lista para que la pegues en tu `README`:

***

### ⚠️ Important Clarification: Progress vs. Save State

One of the most common mistakes when integrating the LoL API is confusing sending progress with saving the game state. **They are completely independent functions** and should be used together:

*   **Progress (`LoLApi.send_progress_and_score_message`)**: Its sole purpose is to **update the teacher's dashboard** in real-time to show the percentage completed by the student and their score. It is mandatory to send progress increments multiple times during a complete playthrough (LoL recommends a minimum of 8 times).
*   **Save State (`LoLApi.send_save_state_message`)**: Its purpose is to **save the internal state of the game** in the database, allowing the student to close the game and continue later. This uses a `data` Dictionary that is converted to JSON (containing score, exact level, inventory, etc.). **Calling this method does NOT update the teacher's dashboard**. The `current_progress` and `max_progress` parameters sent here act only as an internal backup for your own logic.

### 🎮 Practical Example Flow (9-level game with checkpoints)

**Step 1: The player starts Level 1**
You must notify the teacher of the initial progress.
```gdscript
# Updates the teacher's dashboard
LoLApi.send_progress_and_score_message(1, 9, 0)
```

**Step 2: The player reaches a checkpoint (middle of Level 1)**
The overall level progress hasn't changed for the teacher, but you want to save the student's internal progress so they don't lose their game if they close the browser.
```gdscript
# Saves data for the student. The dictionary contains your game's internal state.
var game_data = {"score": 10, "level": 1.5}
LoLApi.send_save_state_message(1, 9, game_data) 
```

**Step 3: The player advances and loads Level 2**
The player leveled up. First, we update the teacher's screen, and then we save the new game state for the student.
```gdscript
var current_score = 25
var game_data = {"score": current_score, "level": 2.0}

LoLApi.send_progress_and_score_message(2, 9, current_score) # For the teacher
LoLApi.send_save_state_message(2, 9, game_data)              # For the student
```

**Step 4: The student leaves the game and returns the next day (Load)**
When the game starts and you receive the saved data through the SDK's incoming signals, you will retrieve the last state you saved (e.g., `{"score": 25, "level": 2.0}`).

**Step 5: Re-sending the progress (Critical Step)**
Upon loading the game, the platform does not automatically send the progress to the teacher. You must take the retrieved progress data and **manually resend it** so that the teacher's dashboard synchronizes with the loaded game.
```gdscript
# Upon receiving the successful data load signal:
LoLApi.send_progress(2, 9) 
```

**In summary:** Use `send_progress_and_score_message` every time the student advances a significant fraction of the game, and use `send_save_state_message` to save the game file, making sure to re-send the progress to the teacher every time the student loads a saved game.

## 🙏 Acknowledgements and Origin

This Godot 4 plugin is based on and continues the development of the original Godot 3 plugin.

We are highly grateful to **ChocolatePinecone** for their foundational work and have their consent to continue and maintain this plugin for Godot 4.

**Original Godot 3 Plugin:** [https://bitbucket.org/chocolatepinecone/godot-lol-libs](https://bitbucket.org/chocolatepinecone/godot-lol-libs)