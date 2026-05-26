# Installing the Watch App with a Borrowed Mac

This guide describes the v1 workflow for getting the MennoTracker Apple Watch app
onto your wrist when your main development machine is Windows.
It assumes you are willing to borrow a Mac periodically.

The phone app can be installed from Windows with AltStore.
The watch app needs Xcode on macOS under the free Apple ID workflow.
Use [`altstore-setup.md`](altstore-setup.md) for the phone-only path and this document
when you need the watch app installed too.

## Audience

This guide is for a developer who:

- Develops MennoTracker primarily on Windows.
- Has an iPhone paired with an Apple Watch.
- Wants the watch app on the wrist for real workouts.
- Does not yet have a paid Apple Developer Program membership.
- Can borrow a Mac about once every 7 days.

## Why this is necessary

AltStore can install the iPhone app, but it cannot complete the paired Apple Watch
installation flow under the free Apple ID path.
Xcode on macOS can install the iPhone app and trigger the paired watch app install.
That is why the v1 watch workflow uses a borrowed Mac.

The Apple Watch target lives inside `apps/phone/ios/Runner.xcworkspace` so Xcode can
build one iPhone app that contains the watch app bundle.
When the app is run from Xcode to the iPhone, iOS can install the paired watch app.

## Apple's signing tiers

| Capability | Free Apple ID ("personal team") | Apple Developer Program ($99/yr) |
| --- | --- | --- |
| Install iOS app on own device via Xcode | ✅ | ✅ |
| Install iOS app via AltStore | ✅ | ✅ |
| **Install paired watch app** | ✅ via Xcode only | ✅ via Xcode, TestFlight, or ad-hoc |
| **HealthKit on real device via Xcode** | ✅ (personal team grant) | ✅ |
| **HealthKit on real device via AltStore** | ⚠️ flaky (entitlement may be stripped on re-sign) | ✅ |
| TestFlight (no-Mac install) | ❌ | ✅ |
| Provisioning expiry | **7 days** — re-install via Xcode | **TestFlight: 90 days** / **ad-hoc: 12 months** |

## Related docs

- [`program.md`](program.md) describes the reduced training program.
- [`altstore-setup.md`](altstore-setup.md) describes phone installation from Windows.
- [`migrate-to-paid-program.md`](migrate-to-paid-program.md) describes removing this Mac dance.
- [`../PLAN.md`](../PLAN.md) contains the original distribution plan.

## What you need

- A Mac that can run a current Xcode version.
- Xcode installed, or enough time and disk to install it.
- About 40 GB free disk space if Xcode is not already installed.
- Your Apple ID.
- Your iPhone.
- Your paired Apple Watch.
- A USB cable for the iPhone.
- Access to the MennoTracker GitHub repository.
- The Mac, iPhone, and Watch on the same Wi-Fi network.

## Time budget

One-time Mac setup:

- About 45 minutes if Xcode is already installed.
- Add about 30 minutes if Xcode must be installed.
- Xcode download size is large; plan for roughly 40 GB of space.

Per-install flow:

- About 10 minutes of borrowed-Mac time.
- About 2 minutes after pressing Run in Xcode.

## One-time Mac setup

Do this once on the borrowed Mac if possible.
If the Mac is wiped or you use a different Mac, repeat this section.

### 1. Find or prepare the Mac

Use a Mac with Xcode already installed when possible.
If Xcode is missing, install it from the Mac App Store or Apple Developer downloads.
Open Xcode once after installing so it can finish first-launch setup.
Install any required additional components.

Expected outcome:

- Xcode opens without first-launch prompts.
- Xcode can build iOS projects.

### 2. Sign into Xcode

Open Xcode settings.
Go to Accounts.
Add your Apple ID.
Use the free personal team.
You do not need the $99 Apple Developer Program for this workflow.

Expected outcome:

- Xcode shows your Apple ID.
- Xcode shows a personal team for signing.

### 3. Clone MennoTracker on the Mac

Open Terminal on the Mac.
Clone the MennoTracker repository.
Check out the branch or tag you want to install.

Example:

```zsh
git clone <repo-url> MennoTracker
cd MennoTracker
```

Expected outcome:

- The repo exists locally on the Mac.
- `apps/phone/ios/Runner.xcworkspace` is present.

### 4. Open the Xcode workspace

Open this workspace:

```text
apps/phone/ios/Runner.xcworkspace
```

Do not open only the project file if CocoaPods created a workspace.
Use the workspace so the Flutter iOS dependencies resolve correctly.

Expected outcome:

- Xcode opens the Runner workspace.
- The project navigator shows Runner and watch-related targets.

### 5. Set signing for all targets

In Xcode, open each target's `Signing & Capabilities` tab.
Set `Team` to your personal team for each target:

- `Runner`.
- `MennoWatch`.
- `MennoWatchTests`.

If Xcode complains that a bundle identifier is unavailable, make it unique.
A simple approach is to append your initials.
For example, change a bundle id ending in `mennotracker` to one ending in
`mennotracker.sm` if those are your initials.

Expected outcome:

- All three targets show your personal team.
- Xcode can create provisioning profiles for them.
- Bundle identifier conflicts are resolved.

### 6. Plug in the iPhone

Connect the iPhone to the Mac with USB.
Unlock the iPhone.
Tap `Trust This Computer` if prompted.
Enter the passcode if iOS asks.

Expected outcome:

- Xcode can see the iPhone as a run destination.
- The iPhone is trusted by the Mac.

### 7. Enable network connection for iPhone and Watch

In Xcode, open `Window` → `Devices and Simulators`.
Select the iPhone.
Check `Connect via network`.
Select the paired Watch if it appears.
Check `Connect via network` for the Watch too.
Keep the Mac, phone, and watch on the same Wi-Fi network.

Expected outcome:

- Xcode can communicate with the iPhone over the network.
- The paired Watch can participate in the install flow.

### 8. Confirm automatic watch install is enabled

On the iPhone, open the Watch app.
Check the app install settings.
Make sure `Automatic Install` is on.

Expected outcome:

- When the iPhone app installs, the watch app can auto-install on the paired Watch.

## Per-install flow

Repeat this section every ~7 days when the free-signing certificate expires.
Also repeat it whenever you want a newer build on the watch.

### 1. Update the repo on the Mac

Open Terminal on the Mac.
Go to the local MennoTracker repo.
Pull the latest code.

```zsh
git pull
```

Expected outcome:

- The Mac has the same code you want to install.

### 2. Open the workspace

Open `apps/phone/ios/Runner.xcworkspace` in Xcode.
Wait for indexing or package resolution if Xcode needs it.

Expected outcome:

- The workspace is open.
- Signing still points to your personal team.

### 3. Select the iPhone run destination

In the Xcode toolbar, choose your iPhone as the run destination.
Do not choose a simulator.
Do not choose only the Watch.
The phone run triggers the paired watch app install.

Expected outcome:

- Xcode is ready to run on the physical iPhone.

### 4. Press Run

Press `⌘R`.
Wait for the build and install.
Expect about 2 minutes for a normal repeat install.

Expected outcome:

- The phone app installs on the iPhone.
- The watch app auto-installs on the paired Watch.

### 5. Verify the watch app

Open the Apple Watch app grid or list.
Find MennoTracker.
Launch it.
If it asks to open the iPhone app, open MennoTracker on the iPhone and start or sync a workout.

Expected outcome:

- MennoTracker launches on the Watch.
- The Watch can show the workout UI when the phone has sent a payload.

## What this gives you that AltStore cannot

- Watch app installed on the wrist.
- Workout logging from the Watch.
- Rest timer haptics from the Watch.
- HealthKit entitlement on a real device through Xcode signing, matching Apple's documented signing behavior.
- A realistic test path for phone-to-watch payloads.

## When the 7 days expire

With a free Apple ID, the installed app will expire after about 7 days.
When it expires, it will simply refuse to launch.
This is expected.
The fix is to redo the per-install flow on the Mac.

## Fallback when no Mac is available

If you cannot borrow a Mac, keep using the phone app through AltStore.
The phone app still provides:

- Full set logging.
- Rest timer.
- Plate calculator.
- Program history.
- Progression suggestions.
- The complete reduced program from [`program.md`](program.md).

In that fallback mode, the watch app sits dormant in the IPA.
It is present as a build artifact but not installed to the wrist.

## Forward path

The long-term fix is enrolling in the Apple Developer Program.
After enrollment, TestFlight can install both phone and watch apps without borrowing a Mac.
See [`migrate-to-paid-program.md`](migrate-to-paid-program.md) for the exact switch-over steps.

## Troubleshooting

### Xcode says the bundle identifier is unavailable

Use a unique bundle identifier for your personal team.
Append your initials or another private suffix.
Apply the change consistently to the affected target.

### The watch app does not appear

Check these items:

- The iPhone is paired with the Watch.
- The Watch is unlocked.
- The Watch has enough battery.
- The iPhone Watch app has Automatic Install enabled.
- Xcode installed to the iPhone, not only to a simulator.
- The Watch and iPhone are on the same Wi-Fi.

### HealthKit does not appear active

Confirm the app was installed from Xcode.
Confirm the Health permission prompt was accepted.
Check the app's Settings screen for the HealthKit availability state.

## Completion checklist

- Xcode is installed and opened once.
- Your Apple ID is added to Xcode.
- Repo is cloned on the Mac.
- `Runner.xcworkspace` opens.
- Runner, MennoWatch, and MennoWatchTests use your personal team.
- iPhone trusts the Mac.
- Network connection is enabled for iPhone and Watch.
- Automatic Install is enabled in the iPhone Watch app.
- `⌘R` installs the phone app.
- MennoTracker appears and launches on the Watch.
