"""Wire the Miracle Stories narration packs into the Xcode project as On-Demand Resources.

Each ready pack OnDemandMiracleAudio/miracle-<nn>-<lang>/ becomes a folder reference in the
app target's Resources build phase, tagged ASSET_TAGS = its folder name. The app requests
NSBundleResourceRequest(tags: [tag]) and resolves each paragraph's clip from the folder
reference's subdirectory (= tag) - the same scheme as the Journey packs (wire_journey_odr.py),
kept in its own OnDemandMiracleAudio group so package_journey_odr.py's rebuild of
OnDemandAudio/ can never touch it.

Incremental and idempotent: adds only the packs listed in Thaqalayn/Data/miracle_audio_ready.json
that are not wired yet; re-running is a no-op. To undo: git checkout the pbxproj.

Run:
  cd <repo> && .venv/bin/python scripts/wire_miracle_odr.py
"""
import hashlib
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PBX = os.path.join(ROOT, "Thaqalayn.xcodeproj", "project.pbxproj")
READY = os.path.join(ROOT, "Thaqalayn", "Data", "miracle_audio_ready.json")

APP_RESOURCES_PHASE = "73E0BC0D2E3D3AB900E517DE"   # Thaqalayn target's Resources build phase
MAIN_GROUP = "73E0BC062E3D3AB900E517DE"
GROUP_NAME = "OnDemandMiracleAudio"


def uuid(role: str, key: str) -> str:
    """Deterministic 24-hex pbxproj id, namespaced apart from the Journey packs' ids."""
    return hashlib.md5(f"odr-miracle::{role}::{key}".encode()).hexdigest().upper()[:24]


def sub_once(pattern, repl, text, what, flags=0):
    new, n = re.subn(pattern, repl, text, count=1, flags=flags)
    if n != 1:
        raise SystemExit(f"ERROR: anchor not found (or ambiguous) for: {what}")
    return new


def main() -> int:
    tags = json.load(open(READY))
    for t in tags:
        if not os.path.isdir(os.path.join(ROOT, GROUP_NAME, t)):
            raise SystemExit(f"pack folder missing: {GROUP_NAME}/{t}")

    src = open(PBX).read()
    group_id = uuid("group", GROUP_NAME)
    new = [t for t in tags if uuid("ref", t) not in src]
    if not new:
        print("all ready packs already wired - nothing to do.")
        return 0

    existing = set(re.findall(r"\b[0-9A-F]{24}\b", src))
    for t in new:
        for u in (uuid("ref", t), uuid("build", t)):
            if u in existing:
                raise SystemExit(f"UUID collision for {t}: {u}")

    refs = "".join(
        f'\t\t{uuid("ref", t)} /* {t} */ = {{isa = PBXFileReference; '
        f'lastKnownFileType = folder; path = {t}; sourceTree = "<group>"; }};\n' for t in new)
    src = sub_once(r"/\* End PBXFileReference section \*/",
                   refs + "/* End PBXFileReference section */", src, "PBXFileReference end")

    builds = "".join(
        f'\t\t{uuid("build", t)} /* {t} in Resources */ = {{isa = PBXBuildFile; '
        f'fileRef = {uuid("ref", t)} /* {t} */; settings = {{ASSET_TAGS = ({t}, ); }}; }};\n' for t in new)
    src = sub_once(r"/\* End PBXBuildFile section \*/",
                   builds + "/* End PBXBuildFile section */", src, "PBXBuildFile end")

    children = "".join(f"\t\t\t\t{uuid('ref', t)} /* {t} */,\n" for t in new)
    if group_id in src:
        # Group exists: append the new folder refs to its children.
        src = sub_once(
            rf"({group_id} /\* {GROUP_NAME} \*/ = \{{\s*isa = PBXGroup;\s*children = \()(.*?)(\s*\);)",
            lambda m: m.group(1) + m.group(2) + "\n" + children.rstrip("\n") + m.group(3),
            src, "miracle group children", flags=re.S)
    else:
        group_block = (
            f"\t\t{group_id} /* {GROUP_NAME} */ = {{\n"
            f"\t\t\tisa = PBXGroup;\n"
            f"\t\t\tchildren = (\n{children}\t\t\t);\n"
            f"\t\t\tpath = {GROUP_NAME};\n"
            f'\t\t\tsourceTree = "<group>";\n'
            f"\t\t}};\n")
        src = sub_once(r"/\* End PBXGroup section \*/",
                       group_block + "/* End PBXGroup section */", src, "PBXGroup end")
        src = sub_once(
            rf"({MAIN_GROUP} = \{{\s*isa = PBXGroup;\s*children = \()",
            rf"\1\n\t\t\t\t{group_id} /* {GROUP_NAME} */,",
            src, "main group children", flags=re.S)

    phase_files = "".join(f"\t\t\t\t{uuid('build', t)} /* {t} in Resources */,\n" for t in new)
    src = sub_once(
        rf"({APP_RESOURCES_PHASE} /\* Resources \*/ = \{{\s*isa = PBXResourcesBuildPhase;"
        rf"\s*buildActionMask = 2147483647;\s*files = \()",
        lambda m: m.group(1) + "\n" + phase_files.rstrip("\n"),
        src, "app Resources phase files", flags=re.S)

    open(PBX, "w").write(src)
    print(f"wired {len(new)} pack(s): {', '.join(new)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
