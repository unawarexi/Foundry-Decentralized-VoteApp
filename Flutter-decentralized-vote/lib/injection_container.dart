import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

/// Initialize all dependency injection bindings.
/// Call this in main() before runApp().
Future<void> initDependencies() async {
  // ── Core Services ──
  // TODO: Register API client, storage, connectivity, etc.

  // ── Repositories ──
  // TODO: Register auth, election, vote, candidate repositories

  // ── Use Cases ──
  // TODO: Register use cases for each feature
}
