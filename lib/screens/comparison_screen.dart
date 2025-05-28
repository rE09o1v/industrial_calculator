import 'package:flutter/material.dart';
import '../models/calculation_data.dart';
import '../services/storage_service.dart';

class ComparisonScreen extends StatefulWidget {
  final CalculationData leftData;
  final CalculationData rightData;

  const ComparisonScreen({
    super.key,
    required this.leftData,
    required this.rightData,
  });

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final Map<int, String> _resultLabels = {
    0: '距離',
    1: '到達時間',
    2: 'T速度',
    3: '円周',
    4: '計算上の減速比',
    5: '回転数',
    6: '回転数',
    7: '回転数',
    8: '処理能力',
    9: '速度',
    10: '処理能力',
    11: 'インバータ',
    12: '変則的速度',
    13: 'インバータ',
  };
  
  final Map<int, String> _resultUnits = {
    0: 'm',
    1: 'min',
    2: 'm/rpm/min',
    3: 'mm',
    4: '1:?',
    5: 'rpm/min',
    6: '1Hz/rpm',
    7: 'm/min',
    8: 'Sec',
    9: 'm/min',
    10: '秒',
    11: 'Hz',
    12: 'Hz',
    13: 'Hz',
  };

  @override
  Widget build(BuildContext context) {
    // 結果のインデックスを統合（左右どちらかに存在する全てのインデックス）
    final Set<int> allResultIndices = {...widget.leftData.results.keys, ...widget.rightData.results.keys};
    final List<int> sortedIndices = allResultIndices.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('計算データ比較'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // データ名と保存日時の表示
            _buildHeaderCard(),
            
            const SizedBox(height: 24),
            
            // 結果の比較表示
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.indigo.withAlpha(51),
                  width: 1
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '計算結果の比較',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const Divider(height: 24),
                    
                    // 横スクロール可能な結果テーブル
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 列ヘッダー
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    '項目',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    widget.leftData.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    widget.rightData.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(
                                  width: 100,
                                  child: Text(
                                    '差分',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // 各結果の比較行
                          ...sortedIndices.map((index) => _buildComparisonRow(index)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ヘッダーカードの構築
  Widget _buildHeaderCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.indigo.withAlpha(51),
          width: 1
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '比較対象',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Divider(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '基準データ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        widget.leftData.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '保存日時: ${widget.leftData.savedAt.toLocal().toString().substring(0, 16)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.compare_arrows),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '比較データ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        widget.rightData.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '保存日時: ${widget.rightData.savedAt.toLocal().toString().substring(0, 16)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 比較行の構築
  Widget _buildComparisonRow(int index) {
    final String label = _resultLabels[index] ?? '未定義';
    final String unit = _resultUnits[index] ?? '';
    
    final double? leftValue = widget.leftData.results[index];
    final double? rightValue = widget.rightData.results[index];
    
    final bool bothHaveValues = leftValue != null && rightValue != null;
    
    // 差分計算
    double? difference;
    Color differenceColor = Colors.black;
    String differenceText = '';
    
    if (bothHaveValues) {
      difference = rightValue! - leftValue!;
      if (difference > 0) {
        differenceColor = Colors.green;
        differenceText = '+${difference.toStringAsFixed(5)}';
      } else if (difference < 0) {
        differenceColor = Colors.red;
        differenceText = difference.toStringAsFixed(5);
      } else {
        differenceColor = Colors.grey;
        differenceText = '±0';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 項目
          SizedBox(
            width: 120,
            child: Text(
              '$label [$unit]',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // 左側の値
          SizedBox(
            width: 120,
            child: Text(
              leftValue?.toStringAsFixed(5) ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 右側の値と差分
          SizedBox(
            width: 120,
            child: Text(
              rightValue?.toStringAsFixed(5) ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 差分
          if (bothHaveValues) ...[
            SizedBox(
              width: 100,
              child: Text(
                '($differenceText)',
                style: TextStyle(
                  color: differenceColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 