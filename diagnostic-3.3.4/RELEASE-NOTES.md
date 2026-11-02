# Chase 3.3.4 Windows 11 diagnostic prerelease

This separately distributed test build is based on Windows 3.3.2. The public stable update feed is not changed.

The installer requires Windows 11 (build 22000 or newer) on a compatible x64 system. It uses the same Python/x64 runtime and existing web UI as the Windows 3.3.2 release. Requiring Windows 11 is an installer gate, not proof that the operating system caused the previous failures.

OpenAI failures now distinguish HTTPS certificate verification, DNS resolution, connection timeout/interruption, and upstream service errors. Authentication and usage-limit errors retain their existing categories. Raw upstream messages, access tokens, API keys and user prompts are not included in error messages. This build does not bypass certificate or signature checks and does not automatically retry or apply chat actions.

The deployment's Low reasoning policy remains enforced. Application data and OS-vault credentials remain outside the installed program folder; existing installations use the standard guarded upgrade and snapshot mechanism. No shared feedback credential is included in this public candidate.

Install only after active planning, analysis, sync and import work finishes. After installation, check Settings reports 3.3.4. Send a short new chat message first, then retry the original request and report the exact error category if it fails. Do not send credentials or health records when reporting the result.

Because this is version 3.3.4, normal downgrade protection prevents installing 3.3.2 over it. Returning to the stable channel requires a later stable version or a separately reviewed rollback with a compatible backup.

Local verification is performed on Windows 10 with a separate QA installer gate and synthetic data. Windows 11 device acceptance, and OpenAI connectivity from the affected PC, remain for the tester. No billable/live OpenAI request is made in automated tests. The installer is not Authenticode signed.