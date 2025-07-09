class GlobalStore {
  // Private constructor
  GlobalStore._privateConstructor();

  // Singleton instance
  static final GlobalStore _instance = GlobalStore._privateConstructor();

  // Factory constructor to return the same instance
  factory GlobalStore() {
    return _instance;
  }
  Map<String, dynamic> csvStats = {};
  Map<String, String> columnsWithTypes = {};
}
