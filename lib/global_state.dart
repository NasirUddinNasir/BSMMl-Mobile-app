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
  String selectedCatagory ="";
  Map<String, dynamic> csvStats = {};
  String targetColumn = "";
  List<String> columnsForPridict = [];
}
