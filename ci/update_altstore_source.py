#!/usr/bin/env python3
"""Update the AltStore source manifest (apps.json) with a new IPA build.

Reads the IPA's Info.plist for version metadata, then prepends (or replaces)
a versions[] entry on the first app in apps.json so AltStore clients can
discover the latest release.

Usage:
    python3 ci/update_altstore_source.py \
        --ipa apps/phone/build/ios/iphoneos/MennoTracker.ipa \
        --tag v0.1.1 \
        --apps-json apps.json \
        [--repo samvidmistry/MennoTracker] \
        [--asset-name MennoTracker.ipa] \
        [--release-notes "What changed"] \
        [--date 2026-05-26T10:26:11Z]

The script is idempotent: re-running with the same version+buildVersion
replaces the existing entry instead of duplicating it.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import plistlib
import sys
import zipfile
from pathlib import Path


DEFAULT_REPO = "samvidmistry/MennoTracker"
DEFAULT_ASSET = "MennoTracker.ipa"


def read_info_plist(ipa_path: Path) -> dict:
    """Pull the main app's Info.plist out of an .ipa (a zip of Payload/<App>.app/)."""
    with zipfile.ZipFile(ipa_path) as zf:
        candidates = [
            n for n in zf.namelist()
            if n.startswith("Payload/")
            and n.endswith("/Info.plist")
            and n.count("/") == 2
        ]
        if not candidates:
            raise RuntimeError(f"No top-level Info.plist found in {ipa_path}")
        with zf.open(candidates[0]) as fp:
            return plistlib.load(fp)


def build_version_entry(
    ipa_path: Path,
    tag: str,
    repo: str,
    asset_name: str,
    release_notes: str | None,
    date_iso: str | None,
) -> dict:
    info = read_info_plist(ipa_path)
    version = info.get("CFBundleShortVersionString")
    build_version = str(info.get("CFBundleVersion", ""))
    min_os = info.get("MinimumOSVersion", "13.0")
    if not version:
        raise RuntimeError("CFBundleShortVersionString missing from IPA Info.plist")

    if date_iso is None:
        date_iso = dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    entry: dict = {
        "version": version,
        "buildVersion": build_version,
        "date": date_iso,
        "size": ipa_path.stat().st_size,
        "downloadURL": f"https://github.com/{repo}/releases/download/{tag}/{asset_name}",
        "minOSVersion": min_os,
    }
    if release_notes:
        entry["localizedDescription"] = release_notes
    return entry


def upsert_version(
    apps_json_path: Path,
    entry: dict,
    *,
    preserve_existing_date: bool = False,
    preserve_existing_notes: bool = False,
) -> dict:
    data = json.loads(apps_json_path.read_text(encoding="utf-8"))
    if not data.get("apps"):
        raise RuntimeError(f"{apps_json_path} has no apps[] to update")
    app = data["apps"][0]
    ensure_current_altstore_schema(app)
    versions = app.setdefault("versions", [])
    existing = next(
        (
            v for v in versions
            if v.get("version") == entry["version"]
            and str(v.get("buildVersion", "")) == entry["buildVersion"]
        ),
        None,
    )
    if existing:
        if preserve_existing_date and "date" in existing:
            entry["date"] = existing["date"]
        if preserve_existing_notes and "localizedDescription" in existing:
            entry["localizedDescription"] = existing["localizedDescription"]

    versions = [
        v for v in versions
        if not (v.get("version") == entry["version"]
                and str(v.get("buildVersion", "")) == entry["buildVersion"])
    ]
    versions.insert(0, entry)
    app["versions"] = versions

    mirror_latest_to_legacy_fields(app, versions[0])
    return data


def ensure_current_altstore_schema(app: dict) -> None:
    if "screenshots" not in app and "screenshotURLs" in app:
        app["screenshots"] = app["screenshotURLs"]
    if "screenshotURLs" not in app:
        screenshots = app.get("screenshots", [])
        if isinstance(screenshots, list) and all(isinstance(item, str) for item in screenshots):
            app["screenshotURLs"] = screenshots
        else:
            app["screenshotURLs"] = []
    # Current AltStore Classic sources require an appPermissions object on every
    # app, or the source fails to decode ("data isn't in the correct format").
    # The phone IPA ships no special entitlements or privacy usage strings, so
    # empty collections match the .ipa and pass AltStore's install-time check.
    if "appPermissions" not in app:
        app["appPermissions"] = {"entitlements": [], "privacy": {}}


# Legacy AltStore/SideStore clients decode these fields directly off the app
# object instead of versions[]. Keep them in sync with the newest entry so
# both schemas resolve to the same IPA after every publish.
LEGACY_FIELD_MAP: tuple[tuple[str, str], ...] = (
    ("version", "version"),
    ("buildVersion", "buildVersion"),
    ("versionDate", "date"),
    ("versionDescription", "localizedDescription"),
    ("size", "size"),
    ("downloadURL", "downloadURL"),
    ("minOSVersion", "minOSVersion"),
)


def mirror_latest_to_legacy_fields(app: dict, latest: dict) -> None:
    for legacy_key, entry_key in LEGACY_FIELD_MAP:
        if entry_key in latest:
            app[legacy_key] = latest[entry_key]
        elif legacy_key == "versionDescription":
            # Keep a sensible default so older clients always have a string here.
            app.setdefault(legacy_key, "Latest release.")


def write_apps_json(apps_json_path: Path, data: dict) -> None:
    text = json.dumps(data, indent=2, ensure_ascii=False)
    apps_json_path.write_text(text + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ipa", required=True, type=Path, help="Path to the .ipa file")
    parser.add_argument("--tag", required=True, help="Git release tag (e.g. v0.1.1)")
    parser.add_argument("--apps-json", required=True, type=Path, help="Path to apps.json")
    parser.add_argument("--repo", default=DEFAULT_REPO, help="GitHub owner/repo")
    parser.add_argument("--asset-name", default=DEFAULT_ASSET, help="Release asset filename")
    parser.add_argument("--release-notes", default=None, help="Optional per-version description")
    parser.add_argument("--date", default=None, help="ISO8601 date override (defaults to now UTC)")
    args = parser.parse_args()

    if not args.ipa.exists():
        print(f"error: IPA not found: {args.ipa}", file=sys.stderr)
        return 1
    if not args.apps_json.exists():
        print(f"error: apps.json not found: {args.apps_json}", file=sys.stderr)
        return 1

    entry = build_version_entry(
        ipa_path=args.ipa,
        tag=args.tag,
        repo=args.repo,
        asset_name=args.asset_name,
        release_notes=args.release_notes,
        date_iso=args.date,
    )
    data = upsert_version(
        args.apps_json,
        entry,
        preserve_existing_date=args.date is None,
        preserve_existing_notes=args.release_notes is None,
    )
    write_apps_json(args.apps_json, data)

    print(f"updated {args.apps_json}: version={entry['version']} build={entry['buildVersion']} size={entry['size']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
