import 'package:flutter/material.dart';
import '../models/calculation_data.dart';
import '../services/storage_service.dart';

class ComparisonScreen extends StatefulWidget {
  final CalculationData leftData;
  final CalculationData rightData;
  final Map<int, List<Map<String, dynamic>>> resultUsageMap; // 追加
  final Map<int, String> resultLabels; // 追加
  final Map<int, String> resultUnits; // 追加

  const ComparisonScreen({
    super.key,
    required this.leftData,
    required this.rightData,
    required this.resultUsageMap, // 追加
    required this.resultLabels, // 追加
    required this.resultUnits, // 追加
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
    7: '速度',
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
            
            // 入力値の比較表示
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
                      '入力値の比較',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const Divider(height: 24),
                    
                    // 横スクロール可能な入力値テーブル
                    _buildInputValuesComparisonTable(),
                  ],
                ),
              ),
            ),
            
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
              leftValue?.toStringAsFixed(4) ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 右側の値
          SizedBox(
            width: 120,
            child: Text(
              rightValue?.toStringAsFixed(4) ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 差分
          if (bothHaveValues) ...[
            _buildDifferenceText(leftValue!.toString(), rightValue!.toString()),
          ],
        ],
      ),
    );
  }

  // 入力値の比較テーブルを構築
  Widget _buildInputValuesComparisonTable() {
    final Set<String> allInputKeys = {
      ...widget.leftData.inputValues.keys,
      ...widget.rightData.inputValues.keys,
    };

    if (allInputKeys.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('保存された入力値はありません'),
      );
    }

    // 関連するコントローラーペアを定義（同じ値を共有するコントローラー）
    final Map<String, String> relatedControllers = {
      '_calc5RatedRpmController': '_calc6RatedRpmController',
      '_calc7BottlesPerMinuteController': '_calc8NumberOfBottlesController',
      '_calc9BottlesPerMinuteController': '_calc10BottlesPerMinuteController',
    };

    final Map<String, String> controllerLabels = _getControllerLabels();
    final List<Widget> displayRows = [];
    // 既に表示された関連コントローラーを記録
    final Set<String> processedRelatedControllers = {};

    final List<String> sortedKeys =
        allInputKeys.toList()..sort((a, b) {
          // (ソートロジックは既存のまま)
          final numA =
              int.tryParse(
                a
                        .split('_calc')[1]
                        ?.split('Controller')[0]
                        ?.split(RegExp(r'[A-Za-z]'))[0] ??
                    '0',
              ) ??
              0;
          final numB =
              int.tryParse(
                b
                        .split('_calc')[1]
                        ?.split('Controller')[0]
                        ?.split(RegExp(r'[A-Za-z]'))[0] ??
                    '0',
              ) ??
              0;
          return numA.compareTo(numB);
        });

    for (final inputKey in sortedKeys) {
      // 既に処理された関連コントローラーはスキップ
      if (processedRelatedControllers.contains(inputKey)) {
        continue;
      }

      final String? leftValueText = widget.leftData.inputValues[inputKey];
      final String? rightValueText = widget.rightData.inputValues[inputKey];

      bool leftIsFromResult = false;
      if (leftValueText != null) {
        for (var sourceIndex in widget.resultUsageMap.keys) {
          if (widget.leftData.results.containsKey(sourceIndex) &&
              widget.leftData.results[sourceIndex] != null) {
            var targets = widget.resultUsageMap[sourceIndex]!;
            for (var target in targets) {
              if (target['controller'] == inputKey) {
                if (leftValueText ==
                    widget.leftData.results[sourceIndex]!.toStringAsFixed(4)) {
                  leftIsFromResult = true;
                  break;
                }
              }
            }
          }
          if (leftIsFromResult) break;
        }
      }

      bool rightIsFromResult = false;
      if (rightValueText != null) {
        for (var sourceIndex in widget.resultUsageMap.keys) {
          if (widget.rightData.results.containsKey(sourceIndex) &&
              widget.rightData.results[sourceIndex] != null) {
            var targets = widget.resultUsageMap[sourceIndex]!;
            for (var target in targets) {
              if (target['controller'] == inputKey) {
                if (rightValueText ==
                    widget.rightData.results[sourceIndex]!.toStringAsFixed(4)) {
                  rightIsFromResult = true;
                  break;
                }
              }
            }
          }
          if (rightIsFromResult) break;
        }
      }

      // 左右両方の値が存在し、かつ両方ともそれぞれの計算結果と一致する場合は、この行を表示しない
      if ((leftValueText != null && leftIsFromResult) &&
          (rightValueText != null && rightIsFromResult)) {
        continue; // この行をスキップ
      }
      // 左側の値のみが存在し、かつそれが計算結果と一致する場合もスキップ
      if (leftValueText != null && leftIsFromResult && rightValueText == null) {
        continue; // この行をスキップ
      }
      // 右側の値のみが存在し、かつそれが計算結果と一致する場合もスキップ
      if (rightValueText != null &&
          rightIsFromResult &&
          leftValueText == null) {
        continue; // この行をスキップ
      }

      // 関連するコントローラーを確認し、関連コントローラーとして処理済みにマーク
      final String? relatedController = relatedControllers[inputKey];
      if (relatedController != null) {
        processedRelatedControllers.add(relatedController);
      }

      displayRows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 160,
                child: Text(
                  controllerLabels[inputKey] ?? inputKey,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                width: 120,
                child: Text(
                  leftValueText ?? '-',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        (leftValueText != null && leftIsFromResult)
                            ? Colors.grey
                            : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 120,
                child: Text(
                  rightValueText ?? '-',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        (rightValueText != null && rightIsFromResult)
                            ? Colors.grey
                            : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // 差分表示を追加
              if (leftValueText != null && rightValueText != null) ...[
                _buildDifferenceText(leftValueText, rightValueText),
              ],
            ],
          ),
        ),
      );
    }

    if (displayRows.isEmpty && allInputKeys.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('表示する独立した入力値はありません。\n(すべて計算結果から自動設定された値です)'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              // (ヘッダー行の定義は既存のまま)
              children: [
                SizedBox(
                  width: 160,
                  child: const Text(
                    '項目',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              ],
            ),
          ),
          ...displayRows, // フィルタリングされた行のみ表示
        ],
      ),
    );
  }
  
  // 入力値の各行を構築
  Widget _buildInputValueRow(String key, String label) {
    final String? leftValue = widget.leftData.inputValues[key];
    final String? rightValue = widget.rightData.inputValues[key];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 項目
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // 左側の値
          SizedBox(
            width: 120,
            child: Text(
              leftValue ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 右側の値
          SizedBox(
            width: 120,
            child: Text(
              rightValue ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  // コントローラー名と表示名のマッピングを取得
  Map<String, String> _getControllerLabels() {
    return {
      '_calc1DistanceMmController': '距離 (mm)',
      '_calc2ArrivalTimeSecController': '到達時間 (秒)',
      '_calc3DistanceMController': '距離 (m)',
      '_calc3ArrivalTimeMinController': '到達時間 (分)',
      '_calc4PcdController': 'ターンテーブル[P.C.D] (mm)',
      '_calc5RatedRpmController': '各モータ定格回転数 (rpm/min)',
      '_calc5TSpeedController': 'T速度 (m/rpm/min)',
      '_calc5CircumferenceController': '円周 (mm)',
      '_calc6RatedRpmController': '各モータ定格回転数 (rpm/min)',
      '_calc6ReductionRatioController': '減速比 [1:?]',
      '_calc7RpmController': '回転数 (rpm/min)',
      '_calc8CircumferenceController': '円周 (mm)',
      '_calc8RpmController': '回転数 (rpm/min)',
      '_calc9BottlesPerMinuteController': '能力本数 (本/分)',
      '_calc10BottleSpacingController': 'ボトル間隔 (mm)',
      '_calc10BottlesPerMinuteController': '能力本数 (本/分)',
      '_calc11NumberOfBottlesController': '処理能力本数 (本)',
      '_calc11ProcessingTimePerBottleController': '処理能力 (秒)',
      '_calc12TSpeedController': 'T速度 (m/rpm/min)',
      '_calc12CircumferenceController': '円周 (mm)',
      '_calc12HzRpmController': '回転数 (1Hz/rpm)',
      '_calc13SpeedController': '変則的速度 (m/min)',
      '_calc13CircumferenceController': '円周 (mm)',
      '_calc14IrregularSpeedHzController': '変則的速度 (Hz)',
      '_calc14HzRpmController': '回転数 (1Hz/rpm)',
    };
  }

  // 差分表示を構築
  Widget _buildDifferenceText(String leftValue, String rightValue) {
    try {
      final double left = double.tryParse(leftValue) ?? 0;
      final double right = double.tryParse(rightValue) ?? 0;
      final double difference = right - left;
      Color differenceColor;
      String differenceText;
      
      if (difference > 0) {
        differenceColor = Colors.green;
        differenceText = '+${difference.toStringAsFixed(4)}';
      } else if (difference < 0) {
        differenceColor = Colors.red;
        differenceText = difference.toStringAsFixed(4);
      } else {
        differenceColor = Colors.grey;
        differenceText = '±0';
      }

      return SizedBox(
        width: 100,
        child: Text(
          '($differenceText)',
          style: TextStyle(
            color: differenceColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.end,
        ),
      );
    } catch (e) {
      // 数値変換エラーの場合
      return const SizedBox(
        width: 100,
        child: Text(
          '(比較不可)',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
          textAlign: TextAlign.end,
        ),
      );
    }
  }
} 