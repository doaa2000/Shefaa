# Build-time configuration

The Supabase URL and key are not in the source tree. They are passed at build
time so the same code can point at different projects, and so no key lives in
git history.

## Setup, once per machine

    cp env/dev.example.json env/dev.json

Then fill in `env/dev.json` from **Supabase → Project Settings → API**:

- `SUPABASE_URL` — the Project URL
- `SUPABASE_ANON_KEY` — the `anon` / publishable key

`env/dev.json` is git-ignored. Never commit it.

## Running

From the terminal:

    flutter run --dart-define-from-file=env/dev.json

From VS Code: pick **Shefaa (dev)** in the Run and Debug panel. It reads the
same file, so there is one place to keep the values.

## If the app throws at startup

    StateError: Missing build configuration: SUPABASE_URL, SUPABASE_ANON_KEY

The values did not reach the build. Either `env/dev.json` is missing, or the app
was launched without the flag — plain `flutter run`, or a VS Code configuration
other than the one above. The message names the keys that were empty; it never
prints their values.
