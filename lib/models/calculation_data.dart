import 'dart:convert';

class CalculationData {
  final String name;
  final DateTime savedAt;
  final Map<String, String> inputValues; // コントローラー名: 入力値
  final Map<int, double> results; // 計算インデックス: 結果値

  CalculationData({
    required this.name,
    required this.savedAt,
    required this.inputValues,
    required this.results,
  });

  // JSONからインスタンスを作成
  factory CalculationData.fromJson(Map<String, dynamic> json) {
    Map<String, String> inputs = {};
    Map<int, double> calculationResults = {};
    
    // inputValuesの変換
    if (json['inputValues'] != null) {
      Map<String, dynamic> inputMap = json['inputValues'];
      inputMap.forEach((key, value) {
        inputs[key] = value.toString();
      });
    }
    
    // resultsの変換
    if (json['results'] != null) {
      Map<String, dynamic> resultMap = json['results'];
      resultMap.forEach((key, value) {
        calculationResults[int.parse(key)] = double.parse(value.toString());
      });
    }
    
    return CalculationData(
      name: json['name'] ?? 'Unnamed',
      savedAt: DateTime.parse(json['savedAt']),
      inputValues: inputs,
      results: calculationResults,
    );
  }
  
  // インスタンスからJSONを作成
  Map<String, dynamic> toJson() {
    Map<String, dynamic> resultMap = {};
    results.forEach((key, value) {
      resultMap[key.toString()] = value;
    });
    
    return {
      'name': name,
      'savedAt': savedAt.toIso8601String(),
      'inputValues': inputValues,
      'results': resultMap,
    };
  }
  
  // 文字列表現
  String toFormattedString() {
    return '[$name] ${savedAt.toLocal().toString().substring(0, 16)}';
  }
} 