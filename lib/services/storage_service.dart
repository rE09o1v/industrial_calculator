import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_data.dart';

class StorageService {
  static const String _keyPrefix = 'industrial_calc_';
  static const String _savedCalcsKey = 'saved_calculations_list';
  
  // 保存された計算リストを取得
  Future<List<String>> getSavedCalculationNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_savedCalcsKey) ?? [];
  }
  
  // 計算データを保存
  Future<bool> saveCalculationData(CalculationData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // データをJSON形式で保存
      final jsonData = jsonEncode(data.toJson());
      final key = _keyPrefix + data.name;
      await prefs.setString(key, jsonData);
      
      // 保存済み計算リストを更新
      List<String> savedCalcs = await getSavedCalculationNames();
      if (!savedCalcs.contains(data.name)) {
        savedCalcs.add(data.name);
        await prefs.setStringList(_savedCalcsKey, savedCalcs);
      }
      
      return true;
    } catch (e) {
      print('Error saving calculation data: $e');
      return false;
    }
  }
  
  // 計算データを読み込み
  Future<CalculationData?> loadCalculationData(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + name;
      
      final jsonData = prefs.getString(key);
      if (jsonData == null) {
        return null;
      }
      
      final Map<String, dynamic> decodedData = jsonDecode(jsonData);
      return CalculationData.fromJson(decodedData);
    } catch (e) {
      print('Error loading calculation data: $e');
      return null;
    }
  }
  
  // 保存されている全ての計算データを取得
  Future<List<CalculationData>> getAllSavedCalculations() async {
    final names = await getSavedCalculationNames();
    final List<CalculationData> results = [];
    
    for (final name in names) {
      final data = await loadCalculationData(name);
      if (data != null) {
        results.add(data);
      }
    }
    
    // 保存日時の新しい順にソート
    results.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    
    return results;
  }
  
  // 計算データを削除
  Future<bool> deleteCalculationData(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPrefix + name;
      
      // データを削除
      await prefs.remove(key);
      
      // 保存済み計算リストから削除
      List<String> savedCalcs = await getSavedCalculationNames();
      savedCalcs.remove(name);
      await prefs.setStringList(_savedCalcsKey, savedCalcs);
      
      return true;
    } catch (e) {
      print('Error deleting calculation data: $e');
      return false;
    }
  }
} 