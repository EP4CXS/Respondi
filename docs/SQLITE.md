# SQLite in RESPONDI



## Sign-up already saves automatically



When you tap **Sign Up**, the user is written to SQLite on the device you are running on (emulator, phone, Windows, or browser). You do **not** need to export for the app to work.



Manual `adb` export is only needed if you want to **inspect** that data in **DB Browser on your PC**. The emulator keeps its own private copy; your PC file does not update by itself.



## One file for DB Browser: `data/respondi.db`



| How you run the app | Where data is stored | How to open in DB Browser |

|---------------------|----------------------|---------------------------|

| **Android emulator** | Inside the emulator (`/data/.../databases/respondi.db`) | Run `scripts\sync_android_db.cmd` (see below), open `data\respondi.db` |

| **Windows desktop** (`flutter run -d windows`) | `data/respondi.db` in the project (debug builds) | Open `data\respondi.db` directly — updates on every sign-up |

| **Chrome** | Browser IndexedDB | DB Browser cannot open this |



### Android + DB Browser (recommended workflow)



Use **two terminals**:



1. **Terminal 1** — app:

   ```cmd

   flutter run -d emulator-5554

   ```

2. **Terminal 2** — auto-sync to your PC (use **cmd**, not PowerShell):

   ```cmd

   scripts\sync_android_db.cmd

   ```



Then in DB Browser, open **`data\respondi_latest.db`** (recommended) or **`data\respondi.db`**.

While the sync script runs, files refresh every 2 seconds. If the sync terminal shows **file is being used by another process**, DB Browser locked `respondi.db` — open **`respondi_latest.db`** instead, or close DB Browser.

After sign-up, use **File → Reopen Database** to refresh the table view.



## Location (DDD)



| Layer | Path | Role |

|--------|------|------|

| Core | `lib/core/database/app_database.dart` | Opens DB, schema, migrations |

| Core | `lib/core/database/database_path_resolver.dart` | Platform-specific DB path |

| Core | `lib/core/database/database_constants.dart` | Table/column names |

| Infrastructure | `lib/features/auth/infrastructure/datasources/auth_local_datasource.dart` | SQL for users |

| Infrastructure | `lib/features/auth/infrastructure/repositories/auth_repository_impl.dart` | Uses local datasource |

| Domain | `lib/features/auth/domain/` | No SQLite imports |



## Database file



- Name: `respondi.db`

- Created on first launch via `AppDatabase.initialize()` in `main.dart`

- **Android/iOS**: app databases directory (private to the app)

- **Windows/Linux/macOS (debug)**: `data/respondi.db` in the project folder

- **Windows/Linux/macOS (release)**: platform default databases directory

- **Web (Chrome)**: browser IndexedDB via `sqflite_common_ffi_web`



### Web setup (required once per project)



If Chrome shows `SqfliteFfiWebException`, run:



```bash

dart run sqflite_common_ffi_web:setup

```



This creates `web/sqlite3.wasm` and `web/sqflite_sw.js`.



## Users table



| Column | Type | Notes |

|--------|------|--------|

| `id` | TEXT | UUID |

| `full_name` | TEXT | |

| `email` | TEXT | Unique, lowercased |

| `password_hash` | TEXT | Salted SHA-256 |

| `auth_provider` | `email` | |

| `created_at` | INTEGER | Unix ms |



## Adding new features



1. Add tables in `app_database.dart` `onCreate` / `onUpgrade`.

2. Create `lib/features/<feature>/infrastructure/datasources/<feature>_local_datasource.dart`.

3. Call it from that feature’s repository implementation.



## Manual one-time export (optional)



From the project folder in **cmd**:



```cmd

%LOCALAPPDATA%\Android\sdk\platform-tools\adb.exe exec-out run-as com.example.respondi cat databases/respondi.db > data\respondi.db

```



Package id: `com.example.respondi`

