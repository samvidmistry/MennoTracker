# MennoWatch borrowed-Mac wiring

Audience: developer opening this repo on a Mac for the first time.
These SwiftUI sources are authored from Windows and are not yet in Xcode.
Use a borrowed Mac to add the watchOS 10+ target and wire these files in.
Keep the target native SwiftUI, single-target style, with no external packages.

## Step 1 - Open the iOS workspace

Open Xcode.
Open `apps/phone/ios/Runner.xcworkspace`.
Wait for indexing to finish.
Confirm the Runner project is visible in the Project navigator.

## Step 2 - Add a Watch App target

Select the Runner project in the Project navigator.
Click `+` to add a target.
Choose `Watch App`.
Use the single-target WatchKit App style.
Set watchOS deployment to 10.0 or newer.
Name the target `MennoWatch`.
Set bundle id to `com.mennotracker.app.watchkitapp`.
Do not create XCTest targets for v1.
Let Xcode create the target and scheme.

## Step 3 - Replace generated sources

Delete the auto-generated `MennoWatch` folder that Xcode created.
Right-click the Runner project.
Choose `Add Files to Runner...`.
Select this folder: `apps/phone/ios/MennoWatch/`.
Choose `Create groups`.
Add the files to the `MennoWatch` target only.
Verify all `.swift` files have MennoWatch target membership.
Verify none of these files are members of the iOS Runner target.

## Step 4 - Use supplied plist and entitlements

Select the `MennoWatch` target.
Open Build Settings.
Set `Info.plist File` to this folder's `Info.plist`.
Set `Code Signing Entitlements` to `MennoWatch.entitlements`.
Remove any generated plist from the target if Xcode made one.
Keep version `0.1.0` and build `1` for the first run.

## Step 5 - Signing and capabilities

Open Signing & Capabilities for `MennoWatch`.
Set Team to your personal team.
Check `Automatically manage signing`.
Add the HealthKit capability.
Add Background Modes.
Enable `Workout processing`.
The borrowed-Mac flow may need these capabilities toggled manually for free signing.

## Step 6 - Verify embed/sign

Select the iOS `Runner` target.
Open Build Phases.
Verify Xcode added an embed/sign step for `MennoWatch.app`.
The IPA should contain `Payload/Runner.app/Watch/MennoWatch.app`.
If the embed step is missing, recreate the Watch App target.

## Step 7 - Deployment target

Set the MennoWatch deployment target to watchOS 10.0.
Keep the Swift language version at the Xcode default Swift 5 setting.
Do not lower the target for older watches in v1.

## Step 8 - Build and run

Plug in and unlock the paired iPhone.
Keep the Apple Watch nearby, unlocked, and on the same network.
Select the iPhone as the run destination.
Press Build & Run.
Verify the Runner phone app installs.
Verify the MennoWatch app appears on the paired Apple Watch.
Start a workout on the phone.
Confirm the watch receives the payload.
Log one set and confirm the phone receives the set completion.
Grant HealthKit permission if the prompt appears during the smoke test.
