class GlobalStore {
  // Private constructor
  GlobalStore._privateConstructor();

  // Singleton instance
  static final GlobalStore _instance = GlobalStore._privateConstructor();

  // Factory constructor to return the same instance
  factory GlobalStore() {
    return _instance;
  }

  // The global string variable
  String selectedPredictionModel = "";
  Map<String, dynamic> csvStats = {};
}
