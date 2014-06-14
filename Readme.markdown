# SAMHUDView

Kind of okay HUD. WIP.

SAMHUDView is written in Swift and works with iOS 7 and above. Released under the [MIT license](LICENSE).

## Installation

Simply add the files in the `SAMHUDView` folder to your project or add `SAMHUDView` to your Podfile.

## Usage

Show the HUD like so:

	SAMHUDView.sharedHUD.show(title: "Loading…", loading: true)

…and dismiss it using one of the following:

	SAMHUDView.sharedHUD.dismiss()
	SAMHUDView.sharedHUD.complete(title: "Finished Loading")
	SAMHUDView.sharedHUD.fail(title: "Failed to Load")
