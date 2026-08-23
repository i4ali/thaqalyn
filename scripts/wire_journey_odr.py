"""Wire the per-journey On-Demand Resource packs into the Xcode project.

Adds each complete OnDemandAudio/<journey-id>/ pack as a folder reference tagged with an
ODR ASSET_TAG = its journey id, in the Thaqalayn app target's Resources build phase. The app
requests NSBundleResourceRequest(tags:[journeyId]) and resolves clips from the folder-reference
subdirectory (= journey id). Idempotent: re-running is a no-op once wired. git-revertible.

Run:
  cd <repo> && python3 scripts/wire_journey_odr.py
Then build to verify. To undo: git checkout Thaqalayn.xcodeproj/project.pbxproj
"""
import hashlib
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PBX = os.path.join(ROOT, "Thaqalayn.xcodeproj", "project.pbxproj")
PACKS = os.path.join(ROOT, "scripts", "journey_odr_packs.json")

APP_RESOURCES_PHASE = "73E0BC0D2E3D3AB900E517DE"   # Thaqalayn target's Resources build phase
MAIN_GROUP = "73E0BC062E3D3AB900E517DE"
GROUP_MARKER = "OnDemandAudio"


def uuid(role, key):
    """Deterministic 24-hex-uppercase pbxproj id, stable across runs, from a namespaced hash."""
    return hashlib.md5(f"odr::{role}::{key}".encode()).hexdigest().upper()[:24]


def sub_once(pattern, repl, text, what, flags=0):
    new, n = re.subn(pattern, repl, text, count=1, flags=flags)
    if n != 1:
        raise SystemExit(f"ERROR: anchor not found (or ambiguous) for: {what}")
    return new


def main():
    journeys = sorted(json.load(open(PACKS)).keys())
    if not journeys:
        raise SystemExit("no packs in journey_odr_packs.json")
    for j in journeys:
        pack = os.path.join(ROOT, "OnDemandAudio", j)
        if not os.path.isdir(pack):
            raise SystemExit(f"pack folder missing: {pack}")

    src = open(PBX).read()
    group_uuid = uuid("group", GROUP_MARKER)
    if group_uuid in src or f"/* {GROUP_MARKER} */" in src:
        print("already wired (OnDemandAudio group present) - nothing to do.")
        return

    fileref = {j: uuid("ref", j) for j in journeys}
    buildfile = {j: uuid("build", j) for j in journeys}

    # Collision guard: none of our generated ids may already exist.
    existing = set(re.findall(r"\b[0-9A-F]{24}\b", src))
    for j in journeys:
        for u in (fileref[j], buildfile[j]):
            if u in existing:
                raise SystemExit(f"UUID collision for {j}: {u}")
    if group_uuid in existing:
        raise SystemExit(f"UUID collision for group: {group_uuid}")

    # 1) PBXFileReference: one folder reference per pack (blue folder => preserves the
    #    subdirectory named for the journey id, which the app resolves against).
    refs = "".join(
        f'\t\t{fileref[j]} /* {j} */ = {{isa = PBXFileReference; '
        f'lastKnownFileType = folder; path = {j}; sourceTree = "<group>"; }};\n'
        for j in journeys)
    src = sub_once(r"/\* End PBXFileReference section \*/",
                   refs + "/* End PBXFileReference section */", src, "PBXFileReference end")

    # 2) PBXBuildFile: each folder ref in Resources, tagged ASSET_TAGS = (journeyId).
    builds = "".join(
        f'\t\t{buildfile[j]} /* {j} in Resources */ = {{isa = PBXBuildFile; '
        f'fileRef = {fileref[j]} /* {j} */; settings = {{ASSET_TAGS = ({j}, ); }}; }};\n'
        for j in journeys)
    src = sub_once(r"/\* End PBXBuildFile section \*/",
                   builds + "/* End PBXBuildFile section */", src, "PBXBuildFile end")

    # 3) PBXGroup: an OnDemandAudio group holding the folder refs.
    children = "".join(f"\t\t\t\t{fileref[j]} /* {j} */,\n" for j in journeys)
    group_block = (
        f"\t\t{group_uuid} /* {GROUP_MARKER} */ = {{\n"
        f"\t\t\tisa = PBXGroup;\n"
        f"\t\t\tchildren = (\n{children}\t\t\t);\n"
        f"\t\t\tpath = {GROUP_MARKER};\n"
        f'\t\t\tsourceTree = "<group>";\n'
        f"\t\t}};\n")
    src = sub_once(r"/\* End PBXGroup section \*/",
                   group_block + "/* End PBXGroup section */", src, "PBXGroup end")

    # 4) Reference the group from the project main group (as its first child).
    src = sub_once(
        rf"({MAIN_GROUP} = \{{\s*isa = PBXGroup;\s*children = \()",
        rf"\1\n\t\t\t\t{group_uuid} /* {GROUP_MARKER} */,",
        src, "main group children", flags=re.S)

    # 5) Add the tagged build files to the app target's Resources build phase.
    phase_files = "".join(f"\t\t\t\t{buildfile[j]} /* {j} in Resources */,\n" for j in journeys)
    src = sub_once(
        rf"({APP_RESOURCES_PHASE} /\* Resources \*/ = \{{\s*isa = PBXResourcesBuildPhase;"
        rf"\s*buildActionMask = 2147483647;\s*files = \()(\s*\);)",
        rf"\1\n{phase_files}\t\t\t);",
        src, "app Resources phase files", flags=re.S)

    open(PBX, "w").write(src)
    print(f"wired {len(journeys)} ODR packs: {', '.join(journeys)}")
    print("tags = journey ids; build to verify, `git checkout` the pbxproj to undo.")


if __name__ == "__main__":
    main()
