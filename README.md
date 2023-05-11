# iOS-Plugin-Integrate-Demo for Godot 4.0 #

This Readme and the Demo Project are meant to work together to help people understand how to get iOS Plugins to work with Godot.

There are A LOT of potential pitfalls someone can fall into trying to get this working. It's not entirely at the fault of Godot. It's a complicated procedure.

## Requirements ##

* MacOS and XCODE (or a Linux workaround)
* git
* scons and python
	* I used brew for this
* VulkanSDK (Maybe)
* Godot Export Templates
	* https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html

## Guide ##

1. Run this Project in Editor at least once.
2. Export to XCODE / iOS.
	1. Download Export Templates if you haven't already.
	2. Make your iOS Preset.
	3. Setup your IDs and Export Mode in the Application section of your Preset.
		1. This could not be more vague, I'm sorry. In short, you need to know your Appstore connect Team ID, and your Provisioning Profile UUID. I would recommend keeping the Export Method Debug as Development, and the Release as App Store.
3. Build/Run the Project from XCODE once without any plugins.
	1. If you encounter an Error here, then your Application section is probably wrong, or there is something wrong with your XCODE installation. Follow along the Output Console at the bottom of the editor to diagnose.
	2. Open the IPA in XCODE.
	3. Configure your Device to XCODE (Plug it in and enable developer settings)
	4. Run the Project by hitting the Play Icon near the top. Once the App opens on your device you should see a red square.
4. Return to your export preset and enable the In App Store Plugin, then Export again.
	1. If you encounter an Error here, then something is wrong with the Plugin. This Demo was made on Godot 4.0.2, and the Plugin Headers were compiled on that same source. Consider running this demo on 4.0.2, or compiling new headers on your target version... More on that Later.
	2. Open XCODE normally from the Applications Menu, it should now show your project on the side.
	3. Build the Project to your iPhone again, and you should hopefully now see a green square.

## Setting up other Plugins ##

This Demo comes with the inappstore plugin compiled for 4.0.2 by me. Logistically you have no reason to trust me, and can/should replace my plugin with your own compiled version. You can also download the plugins released here (https://github.com/godotengine/godot-ios-plugins/releases)

At the time of making this the last release is for Godot 3.5; so if you're reading this, using Godot 4.x, and they still haven't released updated versions, continue reading. __Otherwise, please follow the official installation instructions.__ I'm writing this guide with the hope and expectation of it becoming obsolete.

### Sites ###

https://github.com/godotengine/godot-ios-plugins

https://docs.godotengine.org/en/stable/tutorials/platform/ios/ios_plugin.html

- - - -

1. Clone the plugin repository and submodules. This grabs the source code of Godot Engine as well. If you don't need to do that again then clone without `--recursive` around your godot folder or symlink/alias it in.

```bash
git clone --recursive https://github.com/godotengine/godot-ios-plugins.git
```

2. Match the godot repo within to your desired version. As of right now the godot version within is 3.5. Since this guide is intended for 4.0 I imagine you will want to change this. We start by hopping into the godot directory, updating the HEAD with a `fetch` command, then listing the target versions by just saying `tag`. After we are certain on the target version, we `checkout` to it. Replace `git checkout 4.0.2-stable` with your desired version. 

```bash
cd godot
git fetch
git tag
git checkout 4.0.2-stable
```

3. Now we compile the header files, which apparently get compiled first. Run the following command, then once you start seeing [numbers%] blah blah blah, you can cancel the compilation with Control + C. On macOS default terminal, it truly is the Control Key and not the Command Key.

```bash
scons platform=ios target=editor
```

4. Next we generate a static `.a` library within the godot folder. Replace `plugin=inappstore` with your desired plugin. It can be `apn, arkit, camera, gamecenter, inappstore,` or `photo_picker`. Also replace version with your desired version. Do not interrupt this process like before.

```bash
scons target=editor arch=arm64 simulator=no plugin=inappstore version=4.0.2
```

5. Leave the godot directory then access the scripts from the repo root. Replace `inappstore` with your desired plugin, but keep `4.0` as is. Currently the script doesn't support any other input.

```bash
cd ..
./scripts/generate_static_library.sh inappstore debug 4.0
```

then

```bash
./scripts/generate_xcframework.sh inappstore debug 4.0
```

6. We now start the process again, but for the other target types. It's awkward because the scons target types in godot expect `editor, template_release, or template_debug`, whereas the provided scripts for making the .a and xcframework libraries expect `debug, release, or release_debug`. I don't think you need to recompile the Godot Engine (Step 3) for each target as well, just the plugin and the two scripts. Your terminal should something like this...

```bash
cd godot
scons target=template_debug arch=arm64 simulator=no plugin=inappstore version=4.0.2
cd ..
./scripts/generate_static_library.sh inappstore release_debug 4.0
./scripts/generate_xcframework.sh inappstore release_debug 4.0
cd godot
scons target=template_release arch=arm64 simulator=no plugin=inappstore version=4.0.2
cd ..
./scripts/generate_static_library.sh inappstore release 4.0
./scripts/generate_xcframework.sh inappstore release 4.0
```

7. Prepare your personal project for the plugins. On the root folder of your project make a folder called `ios` and a folder within that called `plugins`. It should look similar to the file structure of the demo project.
8. Return to the root folder of the godot-ios-plugins repo. Open the `bin` folder and try to ignore all the individual files. Select and copy just the folders to the clip board. The folder name scheme is plugin.target.xcframework.

```
inappstore.debug.xcframework
inappstore.release_debug.xcframework
inappstore.release.xcframework
```

9. Navigate back or up, then go into the `plugins` folder. You should see all the folders for each plugin. Each of these contains a Readme on __How to Use__ each plugin in code, as well as a `.gdip` file and a bunch of other stuff. Hop into the `inappstore` folder or your desired plugin. Then paste in the folders from clipboard.
10. Now select the `.gdip` file, the Readme, and the folders we just copied in and copy those to your clipboard. Return to the `ios/plugins` folder you made in Step 7, make a new folder named for your plugin, then paste within it.

If you encounter "Invalid Plugin Config File plugin.gdip", then you too now share the confusing experience that consumed a large part of my day. Initially when I followed along the official instructions [Here](https://github.com/godotengine/godot-ios-plugins#instructions) I encountered a lot of issues, and had great difficulty finding answers on this error code. Eventually I tried using the Released 3.5 plugins, and the error went away, but then I couldn't export to XCODE with the plugin enabled. Something about it failing to run Ld /blah/blah/blah/blah. What finally worked was the instructions I have provided you now. I at first assumed I would only need the `template_debug` and `release_debug` targets. It wasn't until I went ahead and just compiled all the different targets out of desperation that it finally worked. 

If you encounter an issue when running the scripts that it failed to copy `A` to `B` because `B` exists, you have to delete `B` then try again. This will probably happen if you, trying to get the plugin working, are checking out the godot repo to different versions and going through the steps again.

This whole thing has a high chance of being read with a rude tone, made out of spite. While I concede this was a frustrating experience, I still ultimately appreciate all the work that has been done to get to this point. Also, from what I understand, this whole system is probably on low priority. I listened in a bit on the 2023 GDC Godot talks, and I'm guessing this whole thing will become a better experience if/when Firebase is officially integrated. Godot 4.0 in general seems targeted for Desktop/PC applications at the moment too.
