import 'package:flutter/material.dart';
import '../models/calculation_data.dart';
import '../services/storage_service.dart';

class SavedCalculationsScreen extends StatefulWidget {
  const SavedCalculationsScreen({super.key});

  @override
  State<SavedCalculationsScreen> createState() => _SavedCalculationsScreenState();
}

class _SavedCalculationsScreenState extends State<SavedCalculationsScreen> {
  final StorageService _storageService = StorageService();
  List<CalculationData> _savedCalculations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCalculations();
  }

  Future<void> _loadSavedCalculations() async {
    setState(() {
      _isLoading = true;
    });

    final calculations = await _storageService.getAllSavedCalculations();
    
    setState(() {
      _savedCalculations = calculations;
      _isLoading = false;
    });
  }

  Future<void> _deleteCalculation(CalculationData calculation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('「${calculation.name}」を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _storageService.deleteCalculationData(calculation.name);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('削除しました')),
        );
        _loadSavedCalculations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('削除に失敗しました')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('保存された計算'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedCalculations.isEmpty
              ? const Center(
                  child: Text('保存された計算はありません'),
                )
              : ListView.builder(
                  itemCount: _savedCalculations.length,
                  itemBuilder: (context, index) {
                    final calculation = _savedCalculations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ListTile(
                        title: Text(
                          calculation.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '保存日時: ${calculation.savedAt.toLocal().toString().substring(0, 16)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCalculation(calculation),
                            ),
                          ],
                        ),
                        onTap: () {
                          // 計算データを選択して前の画面に戻る
                          Navigator.of(context).pop(calculation);
                        },
                      ),
                    );
                  },
                ),
    );
  }
} 