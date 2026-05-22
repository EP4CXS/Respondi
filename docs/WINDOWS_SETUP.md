# Run RESPONDI on Windows desktop

Flutter needs **Visual Studio 2022** with the **Desktop development with C++** workload. Without it, `flutter run -d windows` fails.

## Quick install (recommended)

1. **Right-click** `scripts\install_visual_studio.cmd` → **Run as administrator**
2. If Windows asks (UAC), click **Yes**
3. Wait until the installer finishes (often **20–60 minutes**, ~5–10 GB download)
4. Close and reopen your terminal, then run:
   ```powershell
   flutter doctor
   flutter run -d windows
   ```
5. Open **`data\respondi.db`** in DB Browser — sign-ups are saved there in debug builds

Use device id **`windows`** (not `window`).

## Manual install

1. Download [Visual Studio 2022 Community](https://visualstudio.microsoft.com/downloads/) (free)
2. In the installer, check **Desktop development with C++**
3. Leave default components selected (MSVC, Windows SDK, CMake tools)
4. Install, then run `flutter doctor` — the Visual Studio line should show ✓

## Verify

```powershell
flutter doctor -v
```

You want:

```text
[√] Visual Studio - develop Windows apps
```

## After install

```powershell
cd "c:\flutter\FINAL REQUIREMENTS\respondi"
flutter run -d windows
```

Database file (debug): `data\respondi.db`
