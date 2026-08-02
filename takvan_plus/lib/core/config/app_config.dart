/// Central runtime configuration.
///
/// IMPORTANT: This app never calls TSETMC / CODAL / OpenAI directly with a
/// secret key baked into the client. All of those calls go through
/// `apiBaseUrl`, which must point at YOUR backend (see /takvan_plus_backend).
/// The backend is the only place that holds API keys / does the scraping.
class AppConfig {
  AppConfig._();

  /// Your backend base URL. Swap this for your real deployed domain,
  /// e.g. https://api.boorstech.ir
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.boorstech.ir/v1',
  );

  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'wss://api.boorstech.ir/ws',
  );

  /// Toggle to run the app fully on local mock repositories
  /// (no network calls at all) - useful while the backend isn't ready yet.
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true,
  );

  static const int freeSymbolDetailLimit = 10;

  static const Duration apiTimeout = Duration(seconds: 15);
  static const Duration marketPollInterval = Duration(seconds: 5);
}
