# Troubleshooting

## Technical requirements

Environment requirements for local build and CI:

- **macOS** — 12+
- **Xcode** — 14+ (16.x recommended)
- **iOS deployment target** — 16.0 (from Podfile)
- **Ruby** — 3.3+
- **Bundler** — for gems
- **CocoaPods** — 1.16+

### CI (GitHub Actions)

**Secrets** (Settings → Secrets and variables → Actions → Secrets):

- `ASC_KEY_ID` — App Store Connect API key ID
- `ASC_ISSUER_ID` — App Store Connect issuer ID
- `ASC_KEY` — App Store Connect API key (base64 .p8)
- `GH_PAT` — GitHub PAT for Match repo access
- `MATCH_PASSWORD` — Match certificates passphrase

**Variables** (Settings → Secrets and variables → Actions → Variables):

- `APPLE_TEAM_ID`
- `BUNDLE_IDENTIFIER`
- `XC_TARGET_NAME`
- `MATCH_GIT_URL` — Match certificates repo URL
- `LAST_UPLOADED_BUILD_NUMBER` — last uploaded build number (updated after upload)
- `APPLE_APP_ID` — numeric Apple app ID (for upload_to_testflight)

---

## Common issues

### Build & sign

*(Add specific errors and solutions as they occur.)*

### TestFlight upload

*(Add specific errors and solutions as they occur.)*

### Match / certificates

*(Add specific errors and solutions as they occur.)*

### Firebase / GoogleService

*(Add specific errors and solutions as they occur.)*

### IDE / Git not showing changes (e.g. Git-Rider)

The Git repository root is the **parent folder of BaseApp** (e.g. `IceVault`). If you opened the project from the `BaseApp` folder only, the IDE may not detect the VCS root and will not show changes.

**What to do:**

1. **Open from repo root** — Open the parent directory (the folder that contains `BaseApp`) as the project in Rider so that the repository root is the project root.
2. **Or add VCS root** — If you keep opening `BaseApp`: in Rider go to **Settings/Preferences → Version Control**, ensure the parent directory (where `.git` lives) is added as a VCS root.
3. **Refresh** — Use **File → Synchronize** or **Reload All from Disk**; if the issue persists, **File → Invalidate Caches / Restart**.

After that, Git-Rider should list all changes (deleted under `Base/`, new files under `App/`, `Core/`, `.github/`, etc.).

### Other

*(Add specific errors and solutions as they occur.)*
