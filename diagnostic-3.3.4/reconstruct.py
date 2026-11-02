import base64, hashlib, json, pathlib, subprocess, urllib.request, zipfile
import bsdiff4
root=pathlib.Path.cwd()
blob=base64.b64decode((root/"diagnostic-3.3.4/payload-delta.base64").read_text(),validate=True)
assert hashlib.sha256(blob).hexdigest()=="4228a139a3303d3add17591797fa7ccd2026a898f0117bce10b9f16d2a2795aa"
archive=root/"delta.zip"; archive.write_bytes(blob)
installer=root/"baseline.exe"
urllib.request.urlretrieve("https://github.com/alastair5924/chase-updates/releases/download/v3.3.2/Chase-Setup-3.3.2-windows-x64.exe",installer)
assert hashlib.sha256(installer.read_bytes()).hexdigest()=="ddccb8c4458cda990dc8fe0451ef74c8fba625440093c981055f082468245b27"
subprocess.run([str(installer),"/VERYSILENT","/SUPPRESSMSGBOXES","/NORESTART","/NOICONS","/DIR="+str(root/"baseline/app")],check=True)
payload=root/"baseline/app"
with zipfile.ZipFile(archive) as z:
 m=json.loads(z.read("manifest.json"))
 for name,info in m["patches"].items():
  p=payload/name
  assert p.resolve().is_relative_to(payload.resolve())
  before=p.read_bytes() if p.is_file() else b""
  assert hashlib.sha256(before).hexdigest()==info["baseline_sha256"]
  patch=z.read("patches/"+name+".bsdiff")
  assert hashlib.sha256(patch).hexdigest()==info["patch_sha256"]
  p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(bsdiff4.patch(before,patch))
 for name in m["removed"]:
  p=payload/name;assert p.resolve().is_relative_to(payload.resolve());p.unlink()
 for name,info in m["files"].items():
  p=payload/name;assert hashlib.sha256(p.read_bytes()).hexdigest()==info["sha256"]
 assert {p.relative_to(payload).as_posix() for p in payload.rglob("*") if p.is_file() and not p.name.startswith("unins")}==set(m["files"])
 assert not any(p.suffix.lower() in {".dpapi",".sqlite3",".gpx",".fit"} for p in payload.rglob("*"))
 (root/"payload-manifest.json").write_text(json.dumps(m))
 with zipfile.ZipFile(root/"payload.zip","w",zipfile.ZIP_DEFLATED) as packed:
  for name in m["files"]:packed.write(payload/name,name)
print("Verified all",len(m["files"]),"locally built payload files")
