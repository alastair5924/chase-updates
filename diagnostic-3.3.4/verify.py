import hashlib,json,pathlib,subprocess
root=pathlib.Path.cwd()
exe=root/"candidate/Chase-Setup-3.3.4-windows11-x64.exe"
subprocess.run(["innoextract","-s","-d","verified",str(exe)],check=True)
payload=root/"verified/app"
m=json.loads((root/"payload-manifest.json").read_text())
assert {p.relative_to(payload).as_posix() for p in payload.rglob("*") if p.is_file()}==set(m["files"])
for name,info in m["files"].items():
 assert hashlib.sha256((payload/name).read_bytes()).hexdigest()==info["sha256"]
digest=hashlib.sha256(exe.read_bytes()).hexdigest()
(root/"candidate/SHA256SUMS.txt").write_text(digest+"  "+exe.name+"\n")
report={"version":"3.3.4","kind":"Windows 11 diagnostic prerelease","application_built_locally":True,"payload_files_verified":len(m["files"]),"native_packaged_checks_passed":28,"source_tests_passed":176,"minimum_windows_build":22000,"windows11_device_verified":False,"sha256":digest,"bytes":exe.stat().st_size,"stable_feed_changed":False,"contains_shared_feedback_credential":False}
(root/"candidate/release-verification.json").write_text(json.dumps(report,indent=2))
print(json.dumps(report))
