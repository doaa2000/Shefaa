# App icon

Two files belong here. Neither is in the repository yet; `dart run
flutter_launcher_icons` fails with a clear message until they are.

| File | What it is for | How it should be exported |
| --- | --- | --- |
| `app_icon.png` | iOS, older Android, and the web favicon | 1024×1024, the mark filling roughly 80% of the square |
| `app_icon_foreground.png` | the Android adaptive icon's foreground layer | 1024×1024, transparent, the mark inside the middle 66% |

The two differ on purpose. iOS rounds the corners of `app_icon.png` and adds
no padding of its own, so a wide margin baked into the file just makes the logo
look small beside every other app. The adaptive foreground is cropped by the
launcher into whatever shape the handset uses — circle, squircle, teardrop —
and only the middle 66% is guaranteed to survive, so that one needs the margin.

The background behind the adaptive foreground is set to white in `pubspec.yaml`,
which is the ground the logo was drawn on.

Then:

    flutter pub get
    dart run flutter_launcher_icons

It writes every mipmap density, the iOS asset catalogue and the web icons. The
generated files are committed like any other source.
