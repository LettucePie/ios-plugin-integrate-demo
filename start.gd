extends Control

@export var target_plugin = "InAppStore"
var help_link = "https://docs.godotengine.org/en/stable/tutorials/platform/ios/plugins_for_ios.html"

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("ios"):
		$Label.text = "Currently Running on iOS."
		if Engine.has_singleton(target_plugin):
			$Label.text += "\n\nEngine Integrated with " + target_plugin + "!"
			$ColorRect.color = Color.GREEN
		else:
			$Label.text += "\n\nFailed to detect " + target_plugin + " ..."
			$Label.text += "\n\nBy now you should have figured out Exporting from Godot to XCODE. "
			$Label.text += "Revisit your Export Template and verify you have checked the Target Plugin. "
			$Label.text += "It can be found under the Options Tab in the Plugins Category."
			$ColorRect.color = Color.RED
	else:
		$Label.text = "This project isn't running on iOS, or the export is missing the \"ios\" feature flag."
		$Label.text += "\n\nRead the Godot Documentation on Exporting to iOS."
		$ColorRect.color = Color.RED
		help_link = "https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html#exporting-for-ios"


func _on_help_pressed():
	OS.shell_open(help_link)
