#!/usr/bin/env python3
"""Tiny App Store Connect API helper. Usage: asc.py <GET path> | asc.py state"""
import json, sys, time, urllib.request, urllib.parse
import jwt

KEY_ID = "JDUAKLDB8M"
ISSUER = "f706d3c7-b216-4036-a1b0-d67e0932f6b1"
KEY_PATH = "/Users/muhammadimranali/Documents/appstoreconnect_general.p8"
BASE = "https://api.appstoreconnect.apple.com"


def token():
    now = int(time.time())
    return jwt.encode({"iss": ISSUER, "iat": now, "exp": now + 1100, "aud": "appstoreconnect-v1"},
                      open(KEY_PATH).read(), algorithm="ES256", headers={"kid": KEY_ID})


def req(method, path, body=None, raw=None, ctype="application/json"):
    url = path if path.startswith("http") else BASE + path
    data = raw if raw is not None else (json.dumps(body).encode() if body is not None else None)
    r = urllib.request.Request(url, data=data, method=method,
                               headers={"Authorization": f"Bearer {token()}", "Content-Type": ctype})
    try:
        with urllib.request.urlopen(r) as resp:
            txt = resp.read().decode()
            return json.loads(txt) if txt else {}
    except urllib.error.HTTPError as e:
        print("HTTP", e.code, e.read().decode()[:2000], file=sys.stderr)
        raise


def get(path, **params):
    if params:
        path += ("&" if "?" in path else "?") + urllib.parse.urlencode(params)
    return req("GET", path)


def app_id():
    apps = get("/v1/apps", **{"filter[bundleId]": "MAHR.Partner.Thaqalayn"})["data"]
    return apps[0]["id"]


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "state"
    if cmd == "state":
        aid = app_id()
        print("app", aid)
        vers = get(f"/v1/apps/{aid}/appStoreVersions", **{"limit": 5, "fields[appStoreVersions]": "versionString,appStoreState,appVersionState,createdDate", "include": "build"})
        for v in vers["data"]:
            a = v["attributes"]
            b = (v.get("relationships", {}).get("build", {}).get("data") or {}).get("id")
            print(v["id"], a["versionString"], a.get("appVersionState"), a.get("appStoreState"), "build", b)
        builds = get(f"/v1/builds", **{"filter[app]": aid, "sort": "-uploadedDate", "limit": 5, "fields[builds]": "version,uploadedDate,processingState"})
        for b in builds["data"]:
            print("build", b["id"], b["attributes"])
        subs = get(f"/v1/apps/{aid}/reviewSubmissions", **{"filter[state]": "WAITING_FOR_REVIEW,IN_REVIEW,UNRESOLVED_ISSUES,READY_FOR_REVIEW", "limit": 5})
        for s in subs["data"]:
            print("reviewSubmission", s["id"], s["attributes"])
    else:
        print(json.dumps(get(cmd), indent=1)[:6000])
