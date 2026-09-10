/// Environment configuration.
///
/// Values are injected at build time with `--dart-define`, so no key is
/// hard-coded in the source tree and dev / staging / prod can point at
/// different Supabase projects:
///
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=sb_publishable_xxx \
///     --dart-define=APP_FLAVOR=dev
///
/// For day-to-day work put those in `.vscode/launch.json` or a `--dart-define-from-file`
/// JSON file that is git-ignored.
abstract class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static const String flavor =
      String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev');

  static bool get isProduction => flavor == 'prod';

  /// Fails fast at startup with an actionable message instead of letting the
  /// app boot and then have every Supabase call fail with a confusing error.
  static void assertConfigured() {
    final missing = <String>[
      if (supabaseUrl.isEmpty) 'https://gnzbyekpmbqxyuqofszt.supabase.co',
      if (supabaseAnonKey.isEmpty) 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImduemJ5ZWtwbWJxeHl1cW9mc3p0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0MTE0MzIsImV4cCI6MjA4NTk4NzQzMn0.uAHI_sdQcuPQh89jOhVdN4n3BUa2131a2LsH150CmjQ',
    ];

    if (missing.isNotEmpty) {
      throw StateError(
        'Missing build configuration: ${missing.join(', ')}. '
        'Pass them with --dart-define, e.g. '
        '--dart-define=SUPABASE_URL=https://gnzbyekpmbqxyuqofszt.supabase.co',
      );
    }
  }
}
