import 'package:bsmml/components/widgets_functions.dart';
import 'package:flutter/material.dart';

class UserManualScreen extends StatefulWidget {
  const UserManualScreen({super.key});

  @override
  State<UserManualScreen> createState() => _UserManualScreenState();
}

class _UserManualScreenState extends State<UserManualScreen> {
  final Set<int> _expandedItems = <int>{};

  final Map<String, String> manualSections = const {
        "📂   Upload CSV Datasets":
        "Start your analysis by uploading a CSV file.\n\n"
            "• Navigate to the Upload screen.\n"
            "• Select a .csv file from your device.\n"
            "• The app will automatically parse and preview your dataset.\n"
            "• You must upload a CSV to begin any operation in the app.",
    "🛠   Fix Data Issues":
        "Before using machine learning models, it's important to clean your dataset. The Fix Data Issues screen provides essential tools to do that.\n\n"
            "1. Replace Incorrect Values:\n"
            "   • If a column (like Age) has non-numeric values like '/N', replace them with a valid number using this screen.\n"
            "   • This helps avoid errors during conversion and model training.\n\n"
            "2. Rename Column Headers:\n"
            "   • Rename columns to more readable or meaningful names.\n"
            "   • For example, change 'col_1' to 'Age'.\n\n"
            "⚠️ You must complete these steps before encoding or modeling to avoid data integrity issues.",
    "📊   Overview Screen":
        "After uploading, access the Overview screen to see high-level insights about your dataset.\n\n"
            "Metrics displayed include:\n"
            "• Total Rows & Columns\n"
            "• Duplicate Rows Count\n"
            "• List of All Column Names\n"
            "• Total Missing Values\n"
            "• Missing Values Per Column\n"
            "• Column-wise Summary Statistics (using `.describe()`)\n\n"
            "This overview helps you assess your dataset's shape and potential quality issues early on.",
    "🔗   Relationship In Data":
        "Use this feature to explore the relationship between any two columns in your dataset.\n\n"
            "If both columns are numeric:\n"
            "• You'll see a correlation score (from -1 to 1).\n"
            "• A scatter plot and correlation heatmap will be displayed.\n"
            "• The relationship is also labeled (e.g., Strong Positive, No Correlation).\n\n"
            "If one or both columns are categorical:\n"
            "• A bar plot will be shown to compare category distributions.\n\n"
            "This helps you visually understand which features may influence each other and guide your model selection or feature engineering.",
    "🧹   Preprocess Your Data":
        "Preprocessing prepares your dataset for machine learning. Steps are executed in the following fixed order:\n\n"
            "1. Feature Selection:\n"
            "   • Drop irrelevant or unneeded columns to reduce noise.\n\n"
            "2. Handling Missing Values:\n"
            "   • Detects column type (numeric, string, datetime, etc.).\n"
            "   • Fill strategies based on type:\n"
            "     - Numeric: mean, median, zero\n"
            "     - Categorical: mode, custom value\n"
            "     - Other: forward fill (ffill), backward fill (bfill), or drop\n\n"
            "3. Removing Duplicate Rows:\n"
            "   • Eliminates exact row duplicates that can skew model learning.\n\n"
            "4. Fixing Data Types:\n"
            "   • Allows conversion from one type to another (e.g., string → int, object → datetime).\n\n"
            "5. Handling Outliers:\n"
            "   • Methods:\n"
            "     - IQR: Cap values at interquartile range\n"
            "     - Median: Replace outliers with median\n"
            "     - Drop: Remove rows with outliers\n\n"
            "6. Normalizing Numerical Features:\n"
            "   • Scales input values (e.g., MinMax scaling to 0–1).\n"
            "   • ⚠️ Do NOT normalize the target column.\n\n"
            "7. Encoding Categorical Variables:\n"
            "   • One-Hot Encoding: for features (X)\n"
            "   • Label Encoding: strictly for target column (Y)\n"
            "   • ⚠️ Never use One-Hot Encoding for target column – it breaks prediction logic.\n\n"
            "All preprocessing tools are available under the Preprocess screen.",
    "🏷️   Encoding Target Column":
        "The target column (Y) must be encoded using Label Encoding before training a model.\n\n"
            "• This transforms classes like 'Yes'/'No' → 1/0.\n"
            "• Only apply Label Encoding to target, never One-Hot.\n"
            "• Avoid normalizing the target column – it breaks predictions.",
    "⚙️   Classification & Regression":
        "After preprocessing, select a target column for model training.\n\n"
            "• App detects column type automatically:\n"
            "   - Categorical → Classification\n"
            "   - Numeric → Regression\n\n"
            "Available Models:\n"
            "• Classification: Logistic Regression, Random Forest, KNN, XGBoost\n"
            "• Regression: Linear Regression, Decision Tree, Random Forest\n\n"
            "You can customize hyperparameters and view performance:\n"
            "• Accuracy, F1 Score, Precision, Recall\n"
            "• Training vs Testing metrics\n"
            "• Example predictions for validation",
    "🧪   Custom Input Prediction":
        "Test your trained model with custom values using the Custom Prediction screen.\n\n"
            "Steps:\n"
            "1. Enter values for each feature manually.\n"
            "2. Press Submit to get real-time prediction.\n\n"
            "❗ Warning:\n"
            "• If your target was normalized or one-hot encoded, results may be incorrect or fail.",
    "📌   Clustering":
        "Use clustering when your dataset lacks labels (target column).\n\n"
            "Supported Algorithms:\n"
            "• K-Means\n"
            "• DBSCAN\n"
            "• Agglomerative Clustering\n"
            "• Gaussian Mixture Model (GMM)\n"
            "• HDBSCAN\n\n"
            "Configure:\n"
            "• Number of clusters\n"
            "• Epsilon, linkage method, or model-specific parameters\n"
            "• View generated cluster plot after model runs\n"
            "• 📥 You can download the clustering results after execution for further analysis\n\n"
            "This feature helps detect hidden patterns or natural groups in your data.",
    "✅   Best Practices":
        "• Always clean and preprocess data before modeling.\n"
            "• Never normalize or one-hot encode target columns.\n"
            "• Use label encoding for targets only.\n"
            "• Do feature selection to avoid unnecessary columns.\n"
            "• Review data overview before running models.",
    "❓   Troubleshooting": "• File not uploading? Ensure it's a valid .csv format.\n"
        "• Model not predicting? Check if target was encoded (label) and not normalized.\n"
        "• Inconsistent results? Clean all missing and mixed-type values first.",
    "📞   Contact & Support":
        "cs.nasiruddin@gmail.com\nVersion 1.0.0\nDeveloped by Nasir Uddin\nProject Supervisor: Imran Ali"
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: iconButton(context),
        title: const Text(
          "User Manual",
          style: TextStyle(
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Text(
                      "📚 Complete Guide BSMML App",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Decorative line
                  Container(
                    height: 3,
                    width: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.cyan],
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ],
              ),
            ),

            // Manual Sections
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: manualSections.length,
                itemBuilder: (context, index) {
                  final entry = manualSections.entries.elementAt(index);
                  final isExpanded = _expandedItems.contains(index);

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    margin: const EdgeInsets.only(bottom: 6),
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,),
                            childrenPadding: const EdgeInsets.all(0),
                            onExpansionChanged: (expanded) {
                              setState(() {
                                if (expanded) {
                                  _expandedItems.add(index);
                                } else {
                                  _expandedItems.remove(index);
                                }
                              });
                            },
                            title: Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            trailing: AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            children: [
                              Container(
                                width: double.infinity,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.grey.shade300,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "💡 Tip: Follow the sections in order for best results",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
