# AltStore Setup on Windows

This guide explains how to install the MennoTracker iPhone app from a Windows PC
using AltStore Server.
It assumes you have never used AltStore before.

AltStore is the primary v1 install path for the phone app.
It does not install the paired watch app; see [`installing-watch-app.md`](installing-watch-app.md)
for the borrowed-Mac watch workflow.

## What this guide covers

- Installing Apple pairing services on Windows.
- Installing AltStore Server.
- Pairing an iPhone with the PC.
- Installing AltStore on the iPhone.
- Adding the MennoTracker AltStore source so the latest release installs and updates automatically.
- Keeping the app refreshed before the 7-day free-signing limit expires.

## Prerequisites

- Windows 10 or Windows 11.
- iPhone.
- USB-Lightning or USB-C cable for the iPhone.
- Free Apple ID.
- Access to the MennoTracker GitHub repository.
- Ability to download artifacts from GitHub Actions.
- Same Wi-Fi network for the Windows PC and iPhone after setup.

## Important limitations

- This installs the iPhone app only.
- The Apple Watch app may be bundled inside the IPA, but AltStore cannot install it to the watch.
- HealthKit entitlement behavior may be unreliable through AltStore free signing.
- Installed apps expire after 7 days unless refreshed.
- AltStore normally refreshes apps around every 6 days when the PC and phone can see each other.

## Related docs

- [`program.md`](program.md) describes the reduced training program.
- [`installing-watch-app.md`](installing-watch-app.md) explains how to get the watch app onto the wrist.
- [`migrate-to-paid-program.md`](migrate-to-paid-program.md) explains the $99/year TestFlight path.
- [`../PLAN.md`](../PLAN.md) contains the full project plan.

## Mental model

AltStore Server runs on Windows.
The iPhone runs the AltStore app.
GitHub Actions builds an unsigned IPA and publishes it as a GitHub release.
The `iOS Package and Release` workflow also updates `apps.json` at the repo root,
which is the AltStore source manifest.
AltStore on the iPhone polls that manifest, downloads new IPAs over Wi-Fi,
and asks AltStore Server to re-sign and install them with your Apple ID.

## One-time setup

Plan for about 30 minutes.
The exact UI may change, but the expected outcomes below should stay stable.

### 1. Install iTunes for Windows

Download and install the non-Microsoft-Store version of iTunes from Apple.
Do not use the Microsoft Store version for this setup.

Expected outcome:

- iTunes opens normally on Windows.
- Windows can detect the iPhone when plugged in by USB.

Screenshot placeholder:

- `[screenshot: iTunes installed and iPhone visible]`

Why this matters:

- AltStore needs Apple's local pairing services.
- The non-Store iTunes installer provides the services AltStore expects.

### 2. Install iCloud for Windows

Download and install iCloud for Windows from Apple.
Use the Apple-provided installer rather than a Store-only setup when possible.

Expected outcome:

- iCloud for Windows launches.
- Apple support services are present on the PC.

Screenshot placeholder:

- `[screenshot: iCloud for Windows installed]`

Why this matters:

- AltStore relies on Apple's device communication components.
- Installing both iTunes and iCloud avoids many pairing failures.

### 3. Download AltStore Server

Go to `https://altstore.io/`.
Download AltStore for Windows.
Install or extract it according to the AltStore instructions.

Expected outcome:

- AltStore Server is available from the Windows Start menu or tray.
- An AltStore icon can appear in the system tray.

Screenshot placeholder:

- `[screenshot: AltStore Server tray icon]`

### 4. Connect the iPhone by USB

Plug the iPhone into the Windows PC.
Unlock the iPhone.
If prompted, tap `Trust This Computer`.
Enter the iPhone passcode if iOS asks for it.

Expected outcome:

- iTunes can see the iPhone.
- Windows trusts the device pairing.
- The iPhone is unlocked and trusted.

Screenshot placeholder:

- `[screenshot: Trust This Computer prompt]`

### 5. Open AltStore Server

Start AltStore Server on Windows.
Use the tray icon menu.
If Windows Firewall asks for permission, allow local network access.

Expected outcome:

- AltStore Server remains running in the tray.
- The menu contains an install option for AltStore.

Screenshot placeholder:

- `[screenshot: AltStore Server menu]`

### 6. Install AltStore on the iPhone

In AltStore Server, click `Install AltStore on device`.
Select the connected iPhone.
Enter your Apple ID and password when prompted.
If you use two-factor authentication or app-specific passwords, follow Apple's prompt.

Expected outcome:

- AltStore Server starts installing AltStore.
- After a short wait, the AltStore app appears on the iPhone Home Screen.

Screenshot placeholder:

- `[screenshot: AltStore app installed on iPhone]`

### 7. Trust the developer certificate on iPhone

On the iPhone, open Settings.
Go to `General`.
Open `VPN & Device Management`.
Select the Apple ID developer certificate.
Tap `Trust`.
Confirm the trust prompt.

Expected outcome:

- iOS allows AltStore to launch.
- AltStore opens without the untrusted developer warning.

Screenshot placeholder:

- `[screenshot: VPN & Device Management certificate trusted]`

### 8. Pair Mail account in AltStore Server

Open the AltStore Server tray menu.
Use the Mail-related setup option if prompted by AltStore.
Sign in with the mail account AltStore uses for refresh notifications.
If your Apple ID requires it, create an app-specific password at `appleid.apple.com`.

Expected outcome:

- AltStore can send or schedule refresh notifications.
- Refresh warnings are less likely to be missed.

Screenshot placeholder:

- `[screenshot: AltStore Mail pairing complete]`

### 9. Enable Wi-Fi sync in iTunes

Open iTunes.
Select the connected iPhone.
Open the device summary page.
Enable `Sync with this iPhone over Wi-Fi`.
Apply the change.
Keep the phone and PC on the same Wi-Fi network.

Expected outcome:

- AltStore can refresh apps without a USB cable.
- iTunes still sees the iPhone after unplugging, when both devices are on the same network.

Screenshot placeholder:

- `[screenshot: iTunes Wi-Fi sync enabled]`

### 10. Verify AltStore refresh works

Open AltStore on the iPhone.
Go to the apps list.
Use the refresh option for AltStore itself.
Keep AltStore Server running on Windows during the test.

Expected outcome:

- AltStore refresh succeeds.
- The app shows a new expiration date.
- The PC and iPhone can communicate over the local network.

Screenshot placeholder:

- `[screenshot: AltStore refresh successful]`

## Per-build flow

After the one-time setup is complete, the normal install path is via the
MennoTracker AltStore source. Adding the source is a one-time step; future
releases appear in AltStore automatically.

### 1. Add the MennoTracker AltStore source (one-time)

On the iPhone, open AltStore.
Switch to the `Browse` tab.
Tap the `+` icon in the top-right.
Paste the source URL:

```
https://raw.githubusercontent.com/samvidmistry/MennoTracker/master/apps.json
```

Tap `Add Source` and confirm.

Expected outcome:

- A `MennoTracker` source appears under `Browse`.
- A `Menno Tracker` app entry is listed under that source.

### 2. Install Menno Tracker from the source

In the source listing, tap `Menno Tracker`.
Tap `Get` (or `Update` if a sideloaded copy already exists with the same bundle ID).
Enter your Apple ID password (or app-specific password) if prompted.

Expected outcome:

- AltStore Server re-signs the IPA with your Apple ID.
- Menno Tracker appears on the iPhone Home Screen.
- The app launches without an untrusted-developer warning (since AltStore was already trusted).

### 3. Publish a new release

Open GitHub Actions and start the `iOS Package and Release` workflow manually.
Enter the release tag, for example `v0.1.1`.
Bump `CFBundleShortVersionString` in `apps/phone/ios/Runner/Info.plist`
before tagging so AltStore sees the new version as an update.

Expected outcome:

- The workflow builds an unsigned IPA, publishes a GitHub release with the IPA attached,
  and commits an updated `apps.json` to `master`.
- Within a few minutes, AltStore on the iPhone shows an `Update` badge for Menno Tracker.
- Tapping `Update` re-signs the new IPA and installs in place; app data is preserved.

### 4. Manual install (fallback)

Use this only if the source-based flow is unavailable (network issues, source schema bug, etc.).

1. Download `MennoTracker.ipa` from the GitHub release on the Windows PC.
2. Make sure AltStore Server is running and the iPhone is on the same Wi-Fi.
3. Drag the `.ipa` into AltStore Server, select the iPhone, click install.

## Refresh behavior

AltStore-installed apps expire after 7 days with a free Apple ID.
AltStore normally auto-refreshes installed apps every ~6 days.
For auto-refresh to work:

- The Windows PC must be powered on.
- AltStore Server must be running.
- The iPhone must be on the same Wi-Fi network.
- Wi-Fi sync must still work in iTunes.
- The iPhone should not be in a network-isolated guest VLAN.

Manual refresh is simple:

1. Open AltStore on the iPhone.
2. Tap the refresh action for MennoTracker.

## Troubleshooting

### Source fails to load / install: "The data couldn't be read because it isn't in the correct format"

This is a **source-manifest (`apps.json`) decode error**, not a device or
signing problem. AltStore parses the source with Swift `Codable`; any field
whose *type* doesn't match its model throws this exact (unhelpful) message and
aborts the whole source.

**Verified-correct format for `appPermissions` (do not change without reason):**

```json
"appPermissions": {}
```

Use an **empty object with no sub-keys**. This is the officially-documented
empty form and it decodes across *every* AltStore variant. Do NOT write
`"appPermissions": {"entitlements": [], "privacy": []}` or
`{"entitlements": [], "privacy": {}}`:

- **AltStore Classic** (pairs with AltServer) decodes `entitlements` and
  `privacy` as **arrays** of permission objects, so `privacy: {}` fails.
- **Newer / AltStore PAL** decodes `privacy` as a **dictionary**, so
  `privacy: []` fails.
- Any concrete empty value breaks one of the two. Omitting the sub-keys leaves
  both fields optional/absent, so nothing can mismatch.

Only add real `entitlements`/`privacy` entries if the IPA actually ships them
(this app ships none — no entitlements in the binary, no `NS*UsageDescription`
keys in `Info.plist`). `ci/update_altstore_source.py` already writes `{}` by
default; keep it that way.

> **CDN cache gotcha (this wastes the most time):** `raw.githubusercontent.com`
> caches for ~5 minutes and **ignores `?cachebust=` query strings**. After
> pushing an `apps.json` fix, AltStore will keep fetching the *old* copy for up
> to 5 minutes, so re-adding the source immediately shows the *same* error even
> though the fix is live in the repo. To verify the real content, query the
> GitHub API (not cached):
>
> ```bash
> curl -s "https://api.github.com/repos/samvidmistry/MennoTracker/contents/apps.json?ref=master" \
>   -H "Accept: application/vnd.github.raw"
> ```
>
> Then wait for the raw URL to flip over before re-testing in AltStore. A clean
> retry is: remove the source, force-quit AltStore (clears its URL cache),
> re-add the source.

### AltStore can't see my iPhone

Check these items in order:

- Confirm the iPhone and PC are on the same Wi-Fi network.
- Confirm Wi-Fi sync is enabled in iTunes.
- Plug in by USB and confirm iTunes can see the phone.
- Unlock the iPhone.
- Restart AltStore Server from the tray menu.
- Restart iTunes if the phone does not appear.
- Try another USB cable if initial pairing fails.

### Install fails with `invalid signature`

Likely cause:

- Apple ID signing is temporarily rate-limited.

What to do:

- Wait about an hour.
- Try the install again.
- Avoid repeatedly retrying every minute.

### App expired after 7 days

What happened:

- AltStore did not refresh the app before the free-signing window ended.

What to do:

- Open AltStore on the iPhone.
- Manually refresh MennoTracker.
- If refresh fails, reconnect USB and retry.
- Keep AltStore Server running more consistently.

### Mail account not working

Likely cause:

- Apple rejected the normal password for local sign-in.

What to do:

- Go to `https://appleid.apple.com/`.
- Create an app-specific password.
- Use that password in the AltStore Mail setup.

## What this does NOT do

AltStore Server does not install the paired Apple Watch app.
The watch binary can be bundled inside the IPA, but it will sit dormant.
To get the watch app on your wrist, use [`installing-watch-app.md`](installing-watch-app.md).

## Completion checklist

- iTunes non-Store version is installed.
- iCloud for Windows is installed.
- iPhone trusts the Windows PC.
- AltStore Server is running.
- AltStore is installed and trusted on iPhone.
- Mail pairing is configured or intentionally skipped.
- Wi-Fi sync is enabled in iTunes.
- Manual refresh succeeds.
- The MennoTracker AltStore source is added in AltStore.
- Menno Tracker installs from the source and shows updates on new releases.
