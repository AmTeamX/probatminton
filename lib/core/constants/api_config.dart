class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api',
  );

  static const String supabaseUrl = 'https://obywrvuqmiajsirekqmy.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';

  static const String stripePublishableKey = 'pk_test_...';

  // Equipment pricing (matching API docs)
  static const double racketPrice = 50.0;
  static const double shuttlecockPrice = 20.0;
  static const double ballPrice = 30.0;
  static const double bagPrice = 20.0;
  static const double shoesPrice = bagPrice; // alias for backward compat
  static const double memberHourlyRate = 150.0;
  static const double membershipMonthlyPrice = 199.0;
}
