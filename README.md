# PVKK: Teleradio Development Kit (TDK)
**A DevKit to create Teleradio applications that can run inside PVKK's Teleradio using the Godot Engine.**

![Teleradio DevKit Logo](https://github.com/Bippinbits/pvkk-teleradio-devkit/blob/be73ffb1bcd1b197c8904e1fcbe7aaec8ec15492/docs/tdk-logo.png?raw=true)

## Table of Content
1. [Intro](#intro)
2. [Teleradio Hardware Specs](#specs)
3. [Creating a Teleradio App](#create)
4. [Guidelines](#guidelines)
5. [In-Edtor Tools](#tools)
6. [Getting the App into PVKK](#to-pvkk)
    - [Install Application into the Teleradio OS](#install-to-os)
    - [Running an App from a Cartridge](#cartridge)
7. [App Styleguide](#styleguide)

# 1. Intro <a name="intro"></a>
You just made the best decision of your life. Reading this document is the first step to create your very own Teleradio Application that will reach thousands of Planetenverteidigungskanonenkommandanten.

Teleradio Applications can be distributed pre-installed on the Teleradio OS or can be delivered via a Cartridge.


# 2. Teleradio Hardware Specs <a name="specs"></a>
The Teleradio comes with state-of-the-art hardware:
- *Display type:* `600x450px CRT screen`
- *Display refresh rate:* `60Hz`
- *Input devices:* `Four main buttons & Joystick (one axis + two buttons)`
- *Audio System:* `Stereo Speaker`
- *Cartridge Drive:* `8-Track Digital Tapes`

# 3. Creating a new Teleradio App <a name="create"></a>
Creating a new application and testing it in the TDK is pretty easy:
## A fresh start
1. Clone this Repo.
2. Open the Godot project in Godot 4.3 stable.
3. Create a new folder in `res://content/teleradioapps/`.
4. Create a new main scene for your project (e.g. `res://content/teleradioapps/hello_world/HelloWorld.tscn`).
5. Attach a script to the root node that extends `TeleradioContent`.
6. Press the `Refresh` button at the top right in the Godot Editor (next to the green play button).
7. Select your Project from the drop-down list and press the green play button.
## Examples
Alternatively you can also check out the supplied examples.
- Sektorheld 2: `res://content/teleradioapps/sectorsearch/`
- ExampleCounter: `res://content/teleradioapps/example_counter/`
- Boilerplate App: `res://content/teleradioapps/boilerplate/`


# 4. Guidelines <a name="guidelines"></a>
## 4.1 Code <a name="guidelines-code"></a>
- Creating new **global classes should be avoided** to avoid clashing with other apps or parts of PVKK.
- If you absolutely must create a new global class via `class_name foo` you must use the following namespace pattern.
    - The class name must start with `Tdk`, followed by your Apps name and an underscore.
        - ✅ `TdkSectorSearch_Ship`
        - ⛔ `TdkSectorSearchShip`
    - Your Apps name must have at least **four characters** to increase the chances of avoiding collisions with other apps. 
        - ✅ `TdkDoom_Player`
        - ⛔ `TdkD_Player`
- Your app may be interrupted by in-game events like an incoming Teleradio call. This is handled by the Teleradio OS, but there are things you need to do to make sure this works nicely.
    - If your app is interrupted, the root nodes `process_mode` is set to `disabled`.
    - Make sure all child nodes have `process_mode` set to `inherit`.
    - Avoid using tweens or timers that are outside of your apps scope:
        - ✅ `var tween = create_tween()`
        - ⛔ `var tween = get_tree().create_tween()`
    - You can test if your app behaves correctly by toggling the "Interupt App" button in the lower right of the TDK.
- **NEVER** use `get_tree().paused` as this will pause the whole game and not just your app.
## 4.2 Audio <a name="guidelines-audio"></a>
- To have your audio playback come out of the physical Teleradio in PVKK, any `AudioStreamPlayer` need to use `TeleradioApp` as its output `bus`.
- Your app can utilize the available bitcrusher audio effect to make the output sound more ... authentic. See the `TeleradioOS` documentation.

## 4.3 Input <a name="guidelines-input"></a>
- Do not use Godots supplied Input class, using `Input.is_action_pressed` or similar approaches will result in your app interfering with the main games input system.
- Do not use our `InputProcessor` class inside of your app. This also interferes with the main games input.
- To receive input and have the Teleradios hardware respond to it, use the `TeleradioInput` class. The documentation and examples are available inside the TDK (in Godot via <kbd>F1</kbd>).
- The hardware has keybinds pre-defined that always work in the TDK / as long as the player is seated in PVKK:
    - Button 1: <kbd>1</kbd> (number above letters)
    - Button 2: <kbd>2</kbd> (number above letters)
    - Button 3: <kbd>3</kbd> (number above letters)
    - Button 4: <kbd>4</kbd> (number above letters)
    - Joystick Button A: <kbd>Space</kbd>
    - Joystick Button B: <kbd>Alt</kbd>
    - Joystick Axis: <kbd>W</kbd>, <kbd>A</kbd>, <kbd>S</kbd>, <kbd>D</kbd>
- A good scene to look into when implementing input for your app is the InputDebugger. You can find it here: `res://content/teleradio/software/os/apps/inputdebugger/InputDebugger.tscn`

## 4.4 Filesystem <a name="guidelines-filesystem"></a>
- The Teleradio offers a virtual filesystem where your app can store and load persistent data. The documentation inside the TDK for the `TeleradioFilesystem` (in Godot via <kbd>F1</kbd>).
- Avoid using Godots `FileAccess` or `DirAccess` as this can lead to collisions with the main game or other apps.

## 4.5 Teleradio OS <a name="guidelines-os"></a>
- The Teleradio OS offers a variety of functions to enhance your apps experience like a bitcrusher audio or manipulating the Teleradios framerate. It also offers other basic functions like showing an error message, requesting to quit your app or access to the different sub-systems (available via `os.input` or `os.filesystem` when extending from `TeleradioContent`). The documentation is available in Godot via <kbd>F1</kbd>.


# 5. In-Editor Tools and Utility<a name="tools"></a>
The TDK comes with a plugin that makes developing Teleradio apps a bit easier.
## App Launcher
On the top right of the Godot Editor, next to the normal play button, you can find some new options. Via the drop-down list you can select applications and directly start the application via the green play button.
## TDK Audio Check
This tool, located on the bottom of the Editor (next to Output, Debugger, Audio, ...), helps you to check if all `AudioStreamPlayer` nodes are correctly using the `TeleradioApp` bus. 
Just select the folder of your project inside the `teleradioapps` folder. If the tool finds any audio players not using the correct bus, you will be offered an option to fix them all.
## 2D Viewport Tools
As long as the scene you are editing has a script that extends `TeleradioContent`, you will see two new options in the 2D viewports toolbar. Here you can toggle a overlay showing what will be visible in the Teleradio (600x450px) or directly add the Button Label scene.
## Button Label Template
I highly suggest using the TeleradioButtonLabels scene that will make it much easier having labels appear next to the hardware buttons on the Teleradio for two reasons:
1. It is very easy to manage the labels this way.
2. If we ever have to change the Teleradios hardware (rumor has it a Teleradio MK3 might appear at some point), these labels will automatically be updated to match the correct positions.

You can find the scene here and use it as a child in your scene: `res://content/teleradio/shared/TeleradioButtonLabels.tscn` (or add them via the toolbar plugin).

# 6. Getting the App into PVKK <a name="to-pvkk"></a>
This is still something that needs a bit more work - right now the only way is to copy your apps folder and paste it into the same place in the PVKK project.  
In the future support for a mod-like behaviour would be great (using zip or pck files).

## 6.1 Install Application into the Teleradio OS <a name="install-to-os"></a>
To install your app directly into the Teleradio OS you can include a `TeleradioInstallFile.gd` installation file in your apps main folder.  
Example: `res://content/teleradioapps/yourapp/TeleradioInstallFile.gd`.

This file must contain the following code, adapted to your application:
```gdscript
extends Node

func teleradio_autoinstall():
	GameWorld.add_teleradio_entertainment("Sektorheld 2", TeleradioEntry.new(
		load("res://content/teleradioapps/sectorsearch/SectorSearch.tscn"),
		{}, false))
```
There are different categories in which your application categories in which your app can be installed:
- Exams: `GameWorld.add_teleradio_exam(...)`
- Messages: `GameWorld.add_teleradio_message(...)`
- Manuals: `GameWorld.add_teleradio_manual(...)`
- Entertainment: `GameWorld.add_teleradio_entertainment(...)`
- Generic Content, using existing categories or adding a new one:  
`GameWorld.add_teleradio_content(category:String, ...)`

## 6.2 Running an App from a Cartridge <a name="cartridge"></a>
Putting an application into the main PVKK game as a cartridge is not a streamlined process at the moment.
Maybe this will change at some point, but for now it is done manually.

What an application needs if it should appear as a cartridge in game is a cartridge label.
You can find an example label in `docs/cartridge_label_example.psd` in the PSD format (Photoshop/Krita).

# 7. App Styleguide <a name="styleguide"></a>
This section is under construction.
- [ ] Fonts
- [ ] Font sizes
- [ ] Images and icons
- [ ] Colors
