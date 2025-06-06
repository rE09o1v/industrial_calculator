import 'package:flutter/material.dart';
import '../models/calculation_data.dart';
import '../services/storage_service.dart';
import '../services/google_drive_service.dart';
import 'comparison_screen.dart';

class SavedCalculationsScreen extends StatefulWidget {
  final bool selectionMode;
  final CalculationData? firstSelected;
  final Map<int, List<Map<String, dynamic>>>? resultUsageMap;
  final Map<int, String>? resultLabels;
  final Map<int, String>? resultUnits;

  const SavedCalculationsScreen({
    super.key, 
    this.selectionMode = false,
    this.firstSelected,
    this.resultUsageMap,
    this.resultLabels,
    this.resultUnits,
  });

  @override
  State<SavedCalculationsScreen> createState() => _SavedCalculationsScreenState();
}

class _SavedCalculationsScreenState extends State<SavedCalculationsScreen> {
  final StorageService _storageService = StorageService();
  final GoogleDriveService _googleDriveService = GoogleDriveService();
  List<CalculationData> _savedCalculations = [];
  bool _isLoading = true;
  bool _isProcessing = false;

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

  // Google Driveにバックアップする
  Future<void> _backupToGoogleDrive() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final success = await _googleDriveService.backupCalculations();
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Driveにバックアップしました')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('バックアップに失敗しました')),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Google Driveから復元する
  Future<void> _restoreFromGoogleDrive() async {
    if (_isProcessing) return;

    // 確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('復元の確認'),
        content: const Text('Google Driveから最新のバックアップを復元しますか？\n現在のデータはすべて上書きされます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('復元する'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final success = await _googleDriveService.restoreLatestBackup();
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('バックアップから復元しました')),
        );
        _loadSavedCalculations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('復元に失敗しました')),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _compareCalculations() async {
    final firstData = await Navigator.push<CalculationData>(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedCalculationsScreen(
          selectionMode: true,
        ),
      ),
    );

    if (firstData == null) return;

    final secondData = await Navigator.push<CalculationData>(
      context,
      MaterialPageRoute(
        builder: (context) => SavedCalculationsScreen(
          selectionMode: true,
          firstSelected: firstData,
          resultUsageMap: widget.resultUsageMap,
          resultLabels: widget.resultLabels,
          resultUnits: widget.resultUnits,
        ),
      ),
    );

    if (secondData == null) return;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComparisonScreen(
          leftData: firstData,
          rightData: secondData,
          resultUsageMap: widget.resultUsageMap ?? {},
          resultLabels: widget.resultLabels ?? {},
          resultUnits: widget.resultUnits ?? {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title;
    if (widget.selectionMode) {
      if (widget.firstSelected != null) {
        title = '比較するデータを選択';
      } else {
        title = '基準データを選択';
      }
    } else {
      title = '保存された計算';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (!widget.selectionMode) ...[
            // バックアップボタン
            IconButton(
              icon: _isProcessing 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    )
                  : const Icon(Icons.backup),
              tooltip: 'Google Driveにバックアップ',
              onPressed: _isProcessing ? null : _backupToGoogleDrive,
            ),
            
            // 復元ボタン
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: 'Google Driveから復元',
              onPressed: _isProcessing ? null : _restoreFromGoogleDrive,
            ),
            
            // 比較ボタン
            IconButton(
              icon: const Icon(Icons.compare),
              tooltip: 'データを比較',
              onPressed: _compareCalculations,
            ),
          ],
        ],
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
                    
                    // 比較モードで最初のデータが選択されている場合、そのデータは表示しない
                    if (widget.selectionMode && 
                        widget.firstSelected != null && 
                        widget.firstSelected!.name == calculation.name) {
                      return const SizedBox.shrink();
                    }
                    
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
                        trailing: widget.selectionMode
                            ? null
                            : Row(
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