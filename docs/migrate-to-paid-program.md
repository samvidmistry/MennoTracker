# Migrating to the Paid Apple Developer Program

This guide explains the exact switch-over from the v1 free-signing workflow to the
paid Apple Developer Program workflow.
It is written for the moment when you decide to pay for Apple signing and want
TestFlight or ad-hoc OTA distribution to replace the borrowed-Mac cycle.

The phone-only free path is documented in [`altstore-setup.md`](altstore-setup.md).
The free watch path is documented in [`installing-watch-app.md`](installing-watch-app.md).
The training program itself is documented in [`program.md`](program.md).

## Cost reminder

Apple Developer Program membership costs:

- $99/year for an individual membership.
- $99/year for an organization membership.

After enrollment, GitHub Actions macOS builds may also consume billed minutes for
private repositories.
See [Costs after enrollment](#costs-after-enrollment) below.

## What changes after enrollment

Before enrollment:

- Phone app installs through AltStore.
- Watch app installs through Xcode on a borrowed Mac.
- Free signing expires after about 7 days.
- TestFlight is unavailable.

After enrollment:

- CI can produce signed builds.
- TestFlight can deliver the phone app.
- The paired watch app can auto-install through TestFlight.
- Ad-hoc OTA distribution becomes possible.
- TestFlight builds last 90 days.
- Ad-hoc profiles last 12 months.

## One-time enrollment

Plan for about 1–3 business days.
Apple may approve faster, but do not schedule a release around same-hour approval.

### 1. Start enrollment

Go to:

```text
https://developer.apple.com/programs/enroll
```

Choose individual or organization enrollment.
Use your existing Apple ID if possible.

Expected outcome:

- Enrollment is started under the Apple ID you will use for App Store Connect.

### 2. Choose membership type

Use individual enrollment if you are publishing under your own name.
Use organization enrollment if MennoTracker should belong to a company or group.

Expected outcome:

- Apple knows which legal identity will own the developer account.

### 3. Provide organization details if needed

For organization enrollment, provide the D-U-N-S number.
D-U-N-S lookup is free.
Make sure the legal entity name matches Apple's records.

Expected outcome:

- Apple can verify the organization.

### 4. Pay and wait for approval

Complete Apple's payment flow.
Wait for the approval email.
Do not proceed with CI signing until the account is active.

Expected outcome:

- Apple sends confirmation that the Developer Program membership is active.
- App Store Connect access is available.

## Bootstrap fastlane match

Do this once after enrollment.
Plan for about 30 minutes.
You need a borrowed Mac or a Mac-capable CI environment such as Codemagic free tier.

### 1. Prepare a Mac environment

Use a borrowed Mac if available.
Install Xcode if it is missing.
Make sure Ruby and Bundler are available through the repo's fastlane setup.

Expected outcome:

- The Mac can run fastlane commands.

### 2. Clone the repository

On the Mac:

```zsh
git clone <repo-url> MennoTracker
cd MennoTracker
cd ci/fastlane
```

Expected outcome:

- You are in `ci/fastlane` on a Mac.

### 3. Create a private certs repository

Create a private GitHub repository for signing certificates.
Example name:

```text
mennotracker-certs
```

Keep this repository private.
It will store encrypted certificates and provisioning profiles managed by fastlane match.

Expected outcome:

- A private certs repo exists.
- You have a URL that fastlane match can use.

### 4. Update Matchfile

Open `ci/fastlane/Matchfile`.
Set the certs repository URL to the private repo you created.
Keep the rest of the placeholders aligned with the app identifiers you will use.

Expected outcome:

- `Matchfile` points at the encrypted certs repo.

### 5. Install fastlane dependencies

Run:

```zsh
bundle install
```

Expected outcome:

- Ruby dependencies are installed.
- `bundle exec fastlane` is available.

### 6. Run bootstrap

Run:

```zsh
bundle exec fastlane ios bootstrap
```

fastlane match will generate certificates and provisioning profiles.
It will upload the encrypted signing material to the private certs repo.
Choose and save the match password when prompted.

Expected outcome:

- Certificates and profiles exist.
- The certs repo contains encrypted match data.
- You have the match password for GitHub Actions.

## Add GitHub Actions secrets

Open the MennoTracker repository on GitHub.
Go to `Settings` → `Secrets and variables` → `Actions`.
Add these five secrets.

### Required secrets

| Secret | Value |
| --- | --- |
| `MATCH_PASSWORD` | Passphrase you set during fastlane match bootstrap. |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Base64 of `username:personal-access-token` for the certs repo. |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Base64-encoded `.p8` key file from App Store Connect. |
| `APP_STORE_CONNECT_API_KEY_ID` | 10-character App Store Connect key ID. |
| `APP_STORE_CONNECT_API_ISSUER_ID` | UUID from the App Store Connect key page. |

### Secret notes

- The PAT for `MATCH_GIT_BASIC_AUTHORIZATION` needs read access to the certs repo.
- For a classic PAT, `repo:read` is enough when available.
- Keep the certs repo private.
- Do not commit `.p8` files to this repository.
- Do not paste secrets into workflow YAML.

### Creating the App Store Connect API key

In App Store Connect:

1. Open `Users and Access`.
2. Open `Keys`.
3. Create or select an API key.
4. Download the `.p8` file once.
5. Record the 10-character key ID.
6. Record the issuer UUID.
7. Base64-encode the `.p8` file for the GitHub secret.

## Flip the dormant workflows on

The repository contains dormant workflows for paid signing.
They are intentionally present but disabled until the account and secrets exist.

Edit these files:

- `.github/workflows/ios-beta.yml`.
- `.github/workflows/ios-adhoc.yml`.

For each file:

- Remove the `# DORMANT` comment block at the top.
- Confirm the workflow has the signing steps enabled.
- Confirm the workflow reads the five secrets listed above.

Optional tag trigger:

```yaml
on:
  push:
    tags:
      - 'v*'
```

Add that trigger if you want every version tag to build automatically.
Leave manual `workflow_dispatch` enabled for controlled releases.

## First TestFlight release

Use this path for the recommended paid workflow.
It removes the borrowed-Mac watch install cycle.

### 1. Create and push a tag

From Windows:

```powershell
git tag v0.2.0
git push --tags
```

Expected outcome:

- The tag appears on GitHub.
- The `ios-beta.yml` workflow starts if tag triggers are enabled.

### 2. Watch the CI build

The `macos-14` runner builds and uploads to TestFlight.
Expect about 12 minutes for a normal run.

Expected outcome:

- fastlane fetches signing assets with match.
- The app builds as a signed IPA.
- fastlane uploads the build to TestFlight.

### 3. Add yourself as an internal tester

Open App Store Connect.
Go to the app's TestFlight section.
Add your Apple ID as an internal tester.
Accept any required tester invitation.

Expected outcome:

- TestFlight lists you as an internal tester.

### 4. Install from TestFlight

Install the TestFlight app on the iPhone.
Open TestFlight.
Install MennoTracker.
Keep the paired Watch nearby and unlocked.

Expected outcome:

- The iPhone app installs through TestFlight.
- The watch app auto-installs on the paired Watch.
- The borrowed-Mac 7-day cycle is no longer needed.

## Ad-hoc OTA alternative

Use ad-hoc OTA if you want a direct install link instead of TestFlight processing.
This is optional.

To enable it:

- Edit `.github/workflows/ios-adhoc.yml` in the same way as `ios-beta.yml`.
- Configure the Firebase App Distribution app id in `ci/fastlane/Fastfile`.
- Configure the Firebase tester groups in `ci/fastlane/Fastfile`.
- Ensure tags also trigger the ad-hoc workflow if desired.

Expected behavior:

- CI creates a signed ad-hoc build.
- Firebase App Distribution sends or exposes an install link.
- The ad-hoc profile is valid for 12 months.

Use this path when:

- You want faster installs than TestFlight.
- You are distributing to a small known tester set.
- You can manage registered devices and Firebase tester groups.

## Costs after enrollment

Apple Developer Program:

- $99/year ongoing.

GitHub Actions macOS minutes:

- A typical build may take about 8 minutes of real macOS time.
- GitHub bills macOS at 10× the Linux rate for private repos.
- That means an 8-minute build can consume about 80 effective minutes.
- Personal accounts have a 2000-minute free tier.
- Pro accounts have a 3000-minute free tier.
- Public repositories get unlimited free macOS minutes.

Cost guardrails:

- Keep macOS workflows manual or tag-only.
- Do not run iOS signing workflows on every push.
- Keep Dart tests on Linux.
- Use caches for CocoaPods, DerivedData, and pub.
- Prefer TestFlight tags for real releases, not every experiment.

## Rollback

To return the paid workflows to dormant mode:

1. Put the dormant comment block back at the top of the workflow files.
2. Disable or remove tag triggers if you added them.
3. Remove the GitHub Actions secrets if you no longer want CI signing.
4. Leave application code unchanged.

No app code change is required for rollback.
The free AltStore path in [`altstore-setup.md`](altstore-setup.md) and the borrowed-Mac
watch path in [`installing-watch-app.md`](installing-watch-app.md) can continue to work.

## Verification checklist

- Apple Developer Program enrollment is approved.
- App Store Connect access works.
- Private certs repo exists.
- `Matchfile` points at the certs repo.
- `bundle install` succeeds in `ci/fastlane`.
- `bundle exec fastlane ios bootstrap` succeeds.
- Five GitHub Actions secrets are present.
- `ios-beta.yml` is no longer dormant.
- Optional tag trigger is configured.
- `git tag v0.2.0 && git push --tags` starts the workflow.
- TestFlight receives a build.
- You are added as an internal tester.
- iPhone installs from TestFlight.
- Paired Watch receives the watch app.
