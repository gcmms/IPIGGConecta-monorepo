const String _defaultBaseUrl = 'http://10.0.0.154:3000';

/// Shared API base URL used across HTTP clients.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: _defaultBaseUrl,
);
