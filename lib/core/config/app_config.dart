class AppConfig {
  /// When true, the app bypasses the activation check and runs in a demo state.
  static const bool isDemoMode = true;

  /// Limits for Demo Mode to prevent commercial use of the public repo.
  static const int maxArticleLimit = 15;
  static const int maxSaleLimit = 50;

  /// The duration of the Demo Mode grace period in days.
  static const int demoTrialDays = 10;

  /// The version of the application.
  static const String version = '1.2.0-demo';
}
