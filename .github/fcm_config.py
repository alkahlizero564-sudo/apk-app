# يجيب google-services.json لتطبيق أندرويد من مشروع Firebase (عبر مفتاح Service account)
import json, sys, time, base64, subprocess, urllib.request, urllib.parse, urllib.error, tempfile, os
sa = json.load(open(sys.argv[1])); pkg = sys.argv[2]; out = sys.argv[3]
def b64u(b): return base64.urlsafe_b64encode(b).rstrip(b"=").decode()
now = int(time.time())
h = b64u(json.dumps({"alg": "RS256", "typ": "JWT"}).encode())
c = b64u(json.dumps({"iss": sa["client_email"], "scope": "https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/firebase", "aud": "https://oauth2.googleapis.com/token", "iat": now, "exp": now + 3600}).encode())
kf = tempfile.NamedTemporaryFile("w", delete=False, suffix=".pem"); kf.write(sa["private_key"]); kf.close()
sig = subprocess.run(["openssl", "dgst", "-sha256", "-sign", kf.name], input=(h + "." + c).encode(), capture_output=True, check=True).stdout
os.unlink(kf.name)
class HE(Exception): pass
def req(url, data=None, method=None, hdr=None):
    r = urllib.request.Request(url, data=data, method=method, headers=hdr or {})
    try:
        with urllib.request.urlopen(r, timeout=60) as f: return json.loads(f.read() or b"{}")
    except urllib.error.HTTPError as e: raise HE("HTTP %s %s: %s" % (e.code, url, e.read().decode()[:500]))
tok = req("https://oauth2.googleapis.com/token", urllib.parse.urlencode({"grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer", "assertion": h + "." + c + "." + b64u(sig)}).encode(), "POST", {"Content-Type": "application/x-www-form-urlencoded"})["access_token"]
A = {"Authorization": "Bearer " + tok, "Content-Type": "application/json"}
P = sa["project_id"]; B = "https://firebase.googleapis.com/v1beta1/"
apps = req(B + "projects/" + P + "/androidApps?pageSize=100", hdr=A).get("apps", [])
app = next((a for a in apps if a.get("packageName") == pkg), None)
if not app:
    try:
        op = req(B + "projects/" + P + "/androidApps", json.dumps({"packageName": pkg, "displayName": pkg}).encode(), "POST", A)
        for i in range(40):
            if op.get("done"): break
            time.sleep(3); op = req(B + op["name"], hdr=A)
        app = op.get("response")
        if app: print("registered new android app in firebase:", pkg)
        else: print("create op error:", op.get("error"))
    except HE as e:
        print("could not register app:", e)
if app:
    cfg = req(B + "projects/" + P + "/androidApps/" + app["appId"] + "/config", hdr=A)
    open(out, "wb").write(base64.b64decode(cfg["configFileContents"]))
    print("google-services.json OK for", pkg)
elif apps:
    cfg = req(B + "projects/" + P + "/androidApps/" + apps[0]["appId"] + "/config", hdr=A)
    j = json.loads(base64.b64decode(cfg["configFileContents"]))
    cl = j["client"][0]; cl["client_info"]["android_client_info"]["package_name"] = pkg; j["client"] = [cl]
    json.dump(j, open(out, "w")); print("fallback: cloned config of", apps[0].get("packageName"), "for", pkg)
else:
    sys.exit("no android app in firebase project " + P + " and could not create one. Add any Android app in Firebase console.")
