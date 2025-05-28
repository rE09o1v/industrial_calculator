import 'package:flutter/material.dart';
import '../models/industrial_calculations.dart';
import '../models/calculation_data.dart';
import '../services/storage_service.dart';
import 'saved_calculations_screen.dart';
import 'comparison_screen.dart';

class IndustrialCalcScreen extends StatefulWidget {
  const IndustrialCalcScreen({super.key});

  @override
  State<IndustrialCalcScreen> createState() => _IndustrialCalcScreenState();
}

class _IndustrialCalcScreenState extends State<IndustrialCalcScreen> {
  final StorageService _storageService = StorageService();

  // 各計算の結果を保持するマップ
  final Map<int, double?> _results = {};
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
    12: 'rpm',
    13: 'Hz',
  };
  
  // 入力フィールド間の関連付け定義
  final Map<String, List<String>> _inputFieldRelations = {
    '_calc7BottlesPerMinuteController': ['_calc8NumberOfBottlesController'],
    '_calc5RatedRpmController': ['_calc6RatedRpmController'],
    '_calc9BottlesPerMinuteController': ['_calc10BottlesPerMinuteController'],
  };
  
  // 各セクション用のFormKey
  final List<GlobalKey<FormState>> _formKeys = List.generate(
    15, 
    (index) => GlobalKey<FormState>()
  );
  
  // 各セクション専用のコントローラー
  // [1] 距離(mm)から距離(m)計算
  final _calc1DistanceMmController = TextEditingController();
  
  // [2] 到達時間(秒)から到達時間(分)計算
  final _calc2ArrivalTimeSecController = TextEditingController();
  
  // [3] 距離(m)と到達時間(分)からT速度計算
  final _calc3DistanceMController = TextEditingController();
  final _calc3ArrivalTimeMinController = TextEditingController();
  
  // [4] ターンテーブル(P.C.D)から円周計算
  final _calc4PcdController = TextEditingController();
  
  // [5] 各モータ定格回転数、T速度、円周から計算上の減速比計算
  final _calc5RatedRpmController = TextEditingController();
  final _calc5TSpeedController = TextEditingController();
  final _calc5CircumferenceController = TextEditingController();
  
  // [6] 各モータ定格回転数と減速比から回転数計算
  final _calc6RatedRpmController = TextEditingController();
  final _calc6ReductionRatioController = TextEditingController();
  
  // [7] 回転数からHz換算計算
  final _calc7RpmController = TextEditingController();
  
  // [8] 円周と回転数から回転数(m/min)計算
  final _calc8CircumferenceController = TextEditingController();
  final _calc8RpmController = TextEditingController();
  
  // [9] 能力本数から処理能力計算
  final _calc9BottlesPerMinuteController = TextEditingController();
  
  // [10] ボトル間隔と能力本数から速度計算
  final _calc10BottleSpacingController = TextEditingController();
  final _calc10BottlesPerMinuteController = TextEditingController();
  
  // [11] 処理能力本数と処理能力から処理能力計算
  final _calc11NumberOfBottlesController = TextEditingController();
  final _calc11ProcessingTimePerBottleController = TextEditingController();
  
  // [12] T速度、円周、回転数からインバータ計算
  final _calc12TSpeedController = TextEditingController();
  final _calc12CircumferenceController = TextEditingController();
  final _calc12HzRpmController = TextEditingController();
  
  // [13] 変則的速度と円周から変則的速度計算
  final _calc13SpeedController = TextEditingController();
  final _calc13CircumferenceController = TextEditingController();

  // [14] 変則的速度(Hz)と回転数(1Hz/rpm)からインバータ計算
  final _calc14IrregularSpeedHzController = TextEditingController();
  final _calc14HzRpmController = TextEditingController();

  // コントローラー名からコントローラーインスタンスを取得するマップ
  late final Map<String, TextEditingController> _controllerMap;

  // 結果を他の計算で使用できるマッピング定義
  final Map<int, List<Map<String, dynamic>>> _resultUsageMap = {
    0: [ // [1] 距離[mm]から距離[m]計算
      {'targetIndex': 2, 'controller': '_calc3DistanceMController', 'label': '距離 (m)'},
    ],
    1: [ // [2] 到達時間[Sec]から到達時間[min]計算
      {'targetIndex': 2, 'controller': '_calc3ArrivalTimeMinController', 'label': '到達時間 (分)'},
    ],
    2: [ // [3] 距離[m]と到達時間[min]からT速度計算
      {'targetIndex': 4, 'controller': '_calc5TSpeedController', 'label': 'T速度 (m/rpm/min)'},
      {'targetIndex': 11, 'controller': '_calc12TSpeedController', 'label': 'T速度 (m/rpm/min)'},
    ],
    3: [ // [4] ターンテーブル[P.C.D]から円周計算
      {'targetIndex': 4, 'controller': '_calc5CircumferenceController', 'label': '円周 (mm)'},
      {'targetIndex': 7, 'controller': '_calc8CircumferenceController', 'label': '円周 (mm)'},
      {'targetIndex': 11, 'controller': '_calc12CircumferenceController', 'label': '円周 (mm)'},
      {'targetIndex': 12, 'controller': '_calc13CircumferenceController', 'label': '円周 (mm)'},
    ],
    4: [], // [5] 各モータ定格回転数、T速度、円周から計算上の減速比計算
    5: [ // [6] 各モータ定格回転数と減速比から回転数計算
      {'targetIndex': 6, 'controller': '_calc7RpmController', 'label': '回転数 (rpm/min)'},
      {'targetIndex': 7, 'controller': '_calc8RpmController', 'label': '回転数 (rpm/min)'},
    ],
    6: [ // [7] 回転数からHz換算計算
      {'targetIndex': 11, 'controller': '_calc12HzRpmController', 'label': '回転数 (1Hz/rpm)'},
      {'targetIndex': 13, 'controller': '_calc14HzRpmController', 'label': '回転数 (1Hz/rpm)'},
    ],
    7: [], // [8] 円周と回転数から回転数(m/min)計算
    8: [ // [9] 能力本数から処理能力計算
      {'targetIndex': 10, 'controller': '_calc11ProcessingTimePerBottleController', 'label': '処理能力 (秒)'},
    ],
    9: [], // [10] ボトル間隔と能力本数から速度計算
    10: [], // [11] 処理能力本数と処理能力から処理能力計算
    11: [], // [12] T速度、円周、回転数からインバータ計算
    12: [ // [13] 変則的速度と円周から変則的速度計算
      {'targetIndex': 13, 'controller': '_calc14IrregularSpeedHzController', 'label': '変則的速度 (rpm)'},
    ],
    13: [], // [14] 変則的速度(Hz)と回転数(1Hz/rpm)からインバータ計算
  };

  @override
  void initState() {
    super.initState();
    // コントローラーマップを初期化
    _controllerMap = {
      '_calc1DistanceMmController': _calc1DistanceMmController,
      '_calc2ArrivalTimeSecController': _calc2ArrivalTimeSecController,
      '_calc3DistanceMController': _calc3DistanceMController,
      '_calc3ArrivalTimeMinController': _calc3ArrivalTimeMinController,
      '_calc4PcdController': _calc4PcdController,
      '_calc5RatedRpmController': _calc5RatedRpmController,
      '_calc5TSpeedController': _calc5TSpeedController,
      '_calc5CircumferenceController': _calc5CircumferenceController,
      '_calc6RatedRpmController': _calc6RatedRpmController,
      '_calc6ReductionRatioController': _calc6ReductionRatioController,
      '_calc7RpmController': _calc7RpmController,
      '_calc8CircumferenceController': _calc8CircumferenceController,
      '_calc8RpmController': _calc8RpmController,
      '_calc9BottlesPerMinuteController': _calc9BottlesPerMinuteController,
      '_calc10BottleSpacingController': _calc10BottleSpacingController,
      '_calc10BottlesPerMinuteController': _calc10BottlesPerMinuteController,
      '_calc11NumberOfBottlesController': _calc11NumberOfBottlesController,
      '_calc11ProcessingTimePerBottleController': _calc11ProcessingTimePerBottleController,
      '_calc12TSpeedController': _calc12TSpeedController,
      '_calc12CircumferenceController': _calc12CircumferenceController,
      '_calc12HzRpmController': _calc12HzRpmController,
      '_calc13SpeedController': _calc13SpeedController,
      '_calc13CircumferenceController': _calc13CircumferenceController,
      '_calc14IrregularSpeedHzController': _calc14IrregularSpeedHzController,
      '_calc14HzRpmController': _calc14HzRpmController,
    };
    
    // 入力フィールド間の関連付けにリスナーを追加
    _inputFieldRelations.forEach((sourceController, targetControllers) {
      final source = _controllerMap[sourceController];
      if (source != null) {
        source.addListener(() {
          // 入力値が変更されたときに関連する他の入力欄に値をコピー
          if (source.text.isNotEmpty) {
            _copyInputToRelatedFields(sourceController, source.text);
          }
        });
      }
    });
  }

  final List<String> _calculationTypes = [
    '[1] 距離(mm)から距離(m)計算',
    '[2] 到達時間(秒)から到達時間(分)計算',
    '[3] 距離(m)と到達時間(分)からT速度計算',
    '[4] ターンテーブル(P.C.D)から円周計算',
    '[5] 各モータ定格回転数、T速度、円周から計算上の減速比計算',
    '[6] 各モータ定格回転数と減速比から回転数計算',
    '[7] 回転数からHz換算計算',
    '[8] 円周と回転数から回転数(m/min)計算',
    '[9] 能力本数から処理能力計算',
    '[10] ボトル間隔と能力本数から速度計算',
    '[11] 処理能力本数と処理能力から処理能力計算',
    '[12] T速度、円周、回転数からインバータ計算',
    '[13] 変則的速度と円周から変則的速度(rpm)計算',
    '[14] 変則的速度(rpm)と回転数(1Hz/rpm)からインバータ計算',
  ];

  void _calculateDistanceM() {
    if (_formKeys[0].currentState!.validate()) {
      final distanceMm = double.parse(_calc1DistanceMmController.text);
      
      setState(() {
        _results[0] = IndustrialCalculations.calculateDistanceM(
          distanceMm: distanceMm,
        );
        _autoSetResultToOtherInputs(0, _results[0]!);
      });
    }
  }

  void _calculateArrivalTimeMin() {
    if (_formKeys[1].currentState!.validate()) {
      final arrivalTimeSec = double.parse(_calc2ArrivalTimeSecController.text);
      
      setState(() {
        _results[1] = IndustrialCalculations.calculateArrivalTimeMin(
          arrivalTimeSec: arrivalTimeSec,
        );
        _autoSetResultToOtherInputs(1, _results[1]!);
      });
    }
  }

  void _calculateTSpeed() {
    if (_formKeys[2].currentState!.validate()) {
      final distanceM = double.parse(_calc3DistanceMController.text);
      final arrivalTimeMin = double.parse(_calc3ArrivalTimeMinController.text);
      
      setState(() {
        _results[2] = IndustrialCalculations.calculateTSpeed(
          distanceM: distanceM,
          arrivalTimeMin: arrivalTimeMin,
        );
        _autoSetResultToOtherInputs(2, _results[2]!);
      });
    }
  }

  void _calculateReductionRatio() {
    if (_formKeys[4].currentState!.validate()) {
      final ratedRpm = double.parse(_calc5RatedRpmController.text);
      final tSpeed = double.parse(_calc5TSpeedController.text);
      final circumference = double.parse(_calc5CircumferenceController.text);
      
      setState(() {
        _results[4] = IndustrialCalculations.calculateReductionRatio(
          ratedRpm: ratedRpm,
          tSpeed: tSpeed,
          circumference: circumference,
        );
        _autoSetResultToOtherInputs(4, _results[4]!);
      });
    }
  }

  void _calculateMotorRpm() {
    if (_formKeys[5].currentState!.validate()) {
      final ratedRpm = double.parse(_calc6RatedRpmController.text);
      final reductionRatio = double.parse(_calc6ReductionRatioController.text);
      
      setState(() {
        _results[5] = IndustrialCalculations.calculateMotorRpm(
          ratedRpm: ratedRpm,
          reductionRatio: reductionRatio,
        );
        _autoSetResultToOtherInputs(5, _results[5]!);
      });
    }
  }

  void _calculateRpmToMeterPerMin() {
    if (_formKeys[7].currentState!.validate()) {
      final circumference = double.parse(_calc8CircumferenceController.text);
      final rpm = double.parse(_calc8RpmController.text);
      
      setState(() {
        _results[7] = IndustrialCalculations.calculateRpmToMeterPerMin(
          circumference: circumference,
          rpm: rpm,
        );
        _autoSetResultToOtherInputs(7, _results[7]!);
      });
    }
  }

  void _calculateSpeed() {
    if (_formKeys[9].currentState!.validate()) {
      final bottleSpacing = double.parse(_calc10BottleSpacingController.text);
      final bottlesPerMinute = double.parse(_calc10BottlesPerMinuteController.text);
      
      setState(() {
        _results[9] = IndustrialCalculations.calculateSpeed(
          bottleSpacing: bottleSpacing,
          bottlesPerMinute: bottlesPerMinute,
        );
        _autoSetResultToOtherInputs(9, _results[9]!);
      });
    }
  }

  void _calculateTotalProcessingTime() {
    if (_formKeys[10].currentState!.validate()) {
      final numberOfBottles = double.parse(_calc11NumberOfBottlesController.text);
      final processingTimePerBottle = double.parse(_calc11ProcessingTimePerBottleController.text);
      
      setState(() {
        _results[10] = IndustrialCalculations.calculateTotalProcessingTime(
          numberOfBottles: numberOfBottles,
          processingTimePerBottle: processingTimePerBottle,
        );
        _autoSetResultToOtherInputs(10, _results[10]!);
      });
    }
  }

  void _calculateCircumference() {
    if (_formKeys[3].currentState!.validate()) {
      final pcd = double.parse(_calc4PcdController.text);
      
      setState(() {
        _results[3] = IndustrialCalculations.calculateCircumference(
          pcd: pcd,
        );
        _autoSetResultToOtherInputs(3, _results[3]!);
      });
    }
  }

  void _calculateHzFromRpm() {
    if (_formKeys[6].currentState!.validate()) {
      final rpm = double.parse(_calc7RpmController.text);
      
      setState(() {
        _results[6] = IndustrialCalculations.calculateHzFromRpm(
          rpm: rpm,
        );
        _autoSetResultToOtherInputs(6, _results[6]!);
      });
    }
  }

  void _calculateProcessingTime() {
    if (_formKeys[8].currentState!.validate()) {
      final bottlesPerMinute = double.parse(_calc9BottlesPerMinuteController.text);
      
      setState(() {
        _results[8] = IndustrialCalculations.calculateProcessingTime(
          bottlesPerMinute: bottlesPerMinute,
        );
        _autoSetResultToOtherInputs(8, _results[8]!);
      });
    }
  }

  void _calculateInverter() {
    if (_formKeys[11].currentState!.validate()) {
      final tSpeed = double.parse(_calc12TSpeedController.text);
      final circumference = double.parse(_calc12CircumferenceController.text);
      final hzRpm = double.parse(_calc12HzRpmController.text);
      
      setState(() {
        _results[11] = IndustrialCalculations.calculateInverter(
          tSpeed: tSpeed,
          circumference: circumference,
          hzRpm: hzRpm,
        );
        _autoSetResultToOtherInputs(11, _results[11]!);
      });
    }
  }

  void _calculateIrregularSpeedHz() {
    if (_formKeys[12].currentState!.validate()) {
      final speed = double.parse(_calc13SpeedController.text);
      final circumference = double.parse(_calc13CircumferenceController.text);
      
      setState(() {
        _results[12] = IndustrialCalculations.calculateIrregularSpeedHz(
          speed: speed,
          circumference: circumference,
        );
        _autoSetResultToOtherInputs(12, _results[12]!);
      });
    }
  }

  void _calculateIrregularSpeedInverter() {
    if (_formKeys[13].currentState!.validate()) {
      final irregularSpeedHz = double.parse(_calc14IrregularSpeedHzController.text);
      final hzRpm = double.parse(_calc14HzRpmController.text);
      
      setState(() {
        _results[13] = IndustrialCalculations.calculateIrregularSpeedInverter(
          irregularSpeedHz: irregularSpeedHz,
          hzRpm: hzRpm,
        );
        _autoSetResultToOtherInputs(13, _results[13]!);
      });
    }
  }

  // 結果の値を別の計算の入力にコピーする
  void _copyResultToInput(int sourceIndex, double value) {
    final targetList = _resultUsageMap[sourceIndex];
    if (targetList == null || targetList.isEmpty) {
      // コピー先が定義されていない場合
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('この結果は他の計算では使用されません'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 一括で全ての対象にコピー
    bool copied = false;
    for (final target in targetList) {
      final controller = _controllerMap[target['controller']];
      if (controller != null) {
        controller.text = value.toStringAsFixed(4);
        copied = true;
      }
    }
    
    if (copied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('結果を他の計算入力欄に自動設定しました'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // 計算結果を他の計算入力に自動設定
  void _autoSetResultToOtherInputs(int sourceIndex, double value) {
    final targetList = _resultUsageMap[sourceIndex];
    if (targetList == null || targetList.isEmpty) {
      return;
    }

    // 自動的に全ての対象にコピー
    for (final target in targetList) {
      final controller = _controllerMap[target['controller']];
      if (controller != null) {
        controller.text = value.toStringAsFixed(4);
      }
    }
  }

  // 入力値を関連する入力欄にコピー
  void _copyInputToRelatedFields(String sourceController, String value) {
    final targetControllers = _inputFieldRelations[sourceController];
    if (targetControllers == null || targetControllers.isEmpty) {
      return;
    }
    
    for (final targetController in targetControllers) {
      final controller = _controllerMap[targetController];
      if (controller != null) {
        // 無限ループを防ぐため、現在の値と異なる場合のみ更新
        if (controller.text != value) {
          controller.text = value;
        }
      }
    }
  }

  @override
  void dispose() {
    // すべてのコントローラーを破棄
    _calc1DistanceMmController.dispose();
    
    _calc2ArrivalTimeSecController.dispose();
    
    _calc3DistanceMController.dispose();
    _calc3ArrivalTimeMinController.dispose();
    
    _calc4PcdController.dispose();
    
    _calc5RatedRpmController.dispose();
    _calc5TSpeedController.dispose();
    _calc5CircumferenceController.dispose();
    
    _calc6RatedRpmController.dispose();
    _calc6ReductionRatioController.dispose();
    
    _calc7RpmController.dispose();
    
    _calc8CircumferenceController.dispose();
    _calc8RpmController.dispose();
    
    _calc9BottlesPerMinuteController.dispose();
    
    _calc10BottleSpacingController.dispose();
    _calc10BottlesPerMinuteController.dispose();
    
    _calc11NumberOfBottlesController.dispose();
    _calc11ProcessingTimePerBottleController.dispose();
    
    _calc12TSpeedController.dispose();
    _calc12CircumferenceController.dispose();
    _calc12HzRpmController.dispose();
    
    _calc13SpeedController.dispose();
    _calc13CircumferenceController.dispose();
    
    _calc14IrregularSpeedHzController.dispose();
    _calc14HzRpmController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('工場設備計算アプリ'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: '現在の計算を保存',
            onPressed: _showSaveDialog,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: '保存された計算を開く',
            onPressed: _openSavedCalculation,
          ),
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: '保存されたデータを比較',
            onPressed: () async {
              // 保存されたデータから最初のデータを選択
              final firstData = await Navigator.push<CalculationData>(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedCalculationsScreen(
                    selectionMode: true,
                  ),
                ),
              );

              if (firstData == null) return;

              // 2つ目のデータを選択
              final secondData = await Navigator.push<CalculationData>(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedCalculationsScreen(
                    selectionMode: true,
                    firstSelected: firstData,
                  ),
                ),
              );

              if (secondData == null || !mounted) return;

              // 比較画面に移動
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComparisonScreen(
                    leftData: firstData,
                    rightData: secondData,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // 計算項目
              ...List.generate(
                    _calculationTypes.length,
                (index) => _buildCalculationCard(index),
              ),
              
              // 現在の計算結果サマリー
              if (_results.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildResultsSummary(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculationCard(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.indigo.withAlpha(51),  // 0.2の不透明度 = 約51のアルファ値
            width: 1
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKeys[index],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // タイトル
                Text(
                  _calculationTypes[index],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const Divider(height: 24),
                
                // 入力フィールド
                _buildInputField(index),
                
                const SizedBox(height: 16),
                
                // 計算ボタンと結果クリアボタン
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _calculateByIndex(index),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                  ),
                  child: const Text('計算する', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    if (_results.containsKey(index) && _results[index] != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _results.remove(index);
                          });
                        },
                        icon: const Icon(Icons.clear),
                        tooltip: '計算結果をクリア',
                        color: Colors.red.shade400,
                      ),
                    ],
                  ],
                ),
                
                // 結果表示
                if (_results.containsKey(index) && _results[index] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_resultLabels[index]} (${_resultUnits[index]})',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _copyResultToInput(index, _results[index]!),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _results[index]!.toStringAsFixed(4),
                                  style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade800,
                                  ),
                                ),
                              ),
                              if (_resultUsageMap[index]!.isNotEmpty)
                                const Tooltip(
                                  message: '他の計算にも自動設定済み',
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(int index) {
    switch (index) {
      case 0: // [1] 距離(mm)から距離(m)計算
        return Column(
          children: [
            TextFormField(
              controller: _calc1DistanceMmController,
              decoration: const InputDecoration(
                labelText: '距離 (mm)',
                border: OutlineInputBorder(),
                helperText: 'ミリメートル単位の距離',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
          ],
        );
        
      case 1: // [2] 到達時間(秒)から到達時間(分)計算
        return Column(
          children: [
            TextFormField(
              controller: _calc2ArrivalTimeSecController,
              decoration: const InputDecoration(
                labelText: '到達時間 (秒)',
                border: OutlineInputBorder(),
                helperText: '秒単位の到達時間',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
          ],
        );
        
      case 2: // [3] 距離(m)と到達時間(分)からT速度計算
        return Column(
          children: [
            TextFormField(
              controller: _calc3DistanceMController,
              decoration: const InputDecoration(
                labelText: '距離 (m)',
                border: OutlineInputBorder(),
                helperText: '[1]で求めた値',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _calc3ArrivalTimeMinController,
              decoration: const InputDecoration(
                labelText: '到達時間 (分)',
                border: OutlineInputBorder(),
                helperText: '[2]で求めた値',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
          ],
        );
        
      case 3: // [4] ターンテーブル(P.C.D)から円周計算
        return Column(
          children: [
            TextFormField(
              controller: _calc4PcdController,
              decoration: const InputDecoration(
                labelText: 'ターンテーブル[P.C.D] (mm)',
                border: OutlineInputBorder(),
                helperText: 'ピッチ円直径',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
          ],
        );
        
      case 4: // [5] 各モータ定格回転数、T速度、円周から計算上の減速比計算
        return Column(
          children: [
            TextFormField(
              controller: _calc5RatedRpmController,
              decoration: const InputDecoration(
                labelText: '各モータ定格回転数 (rpm/min)',
                border: OutlineInputBorder(),
                helperText: 'モータの定格回転数',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _calc5TSpeedController,
              decoration: const InputDecoration(
                labelText: 'T速度 (m/rpm/min)',
                border: OutlineInputBorder(),
                helperText: '[3]で求めた値',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _calc5CircumferenceController,
              decoration: const InputDecoration(
                labelText: '円周 (mm)',
                border: OutlineInputBorder(),
                helperText: '[4]で求めた値',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
          ],
        );
        
      case 5: // [6] 各モータ定格回転数と減速比から回転数計算
        return Column(
          children: [
            TextFormField(
              controller: _calc6RatedRpmController,
              decoration: const InputDecoration(
                labelText: '各モータ定格回転数 (rpm/min)',
                border: OutlineInputBorder(),
                helperText: 'モータの定格回転数',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _calc6ReductionRatioController,
              decoration: const InputDecoration(
                labelText: '減速比 [1:?]',
                border: OutlineInputBorder(),
                helperText: '減速比の値（例：10なら1:10）',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
          ],
        );
        
      case 6: // [7] 回転数からHz換算計算
        return Column(
          children: [
            TextFormField(
              controller: _calc7RpmController,
              decoration: const InputDecoration(
                labelText: '回転数 (rpm/min)',
                border: OutlineInputBorder(),
                helperText: '回転数',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
          ],
        );
        
      case 7: // [8] 円周と回転数から回転数(m/min)計算
        return Column(
          children: [
            TextFormField(
              controller: _calc8CircumferenceController,
              decoration: const InputDecoration(
                labelText: '円周 (mm)',
                border: OutlineInputBorder(),
                helperText: '[9]で求めた値',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _calc8RpmController,
              decoration: const InputDecoration(
                labelText: '回転数 (rpm/min)',
                border: OutlineInputBorder(),
                helperText: '回転数',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
          ],
        );
        
      case 8: // [9] 能力本数から処理能力計算
        return Column(
          children: [
            TextFormField(
              controller: _calc9BottlesPerMinuteController,
              decoration: const InputDecoration(
                labelText: '能力本数 (本/分)',
                border: OutlineInputBorder(),
                helperText: '機械が1分間に処理できるボトル数',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
          ],
        );
        
      case 9: // [10] ボトル間隔と能力本数から速度計算
        return Column(
          children: [
            TextFormField(
              controller: _calc10BottleSpacingController,
              decoration: const InputDecoration(
                labelText: 'ボトル間隔 (mm)',
                border: OutlineInputBorder(),
                helperText: 'ボトルとボトルの間の距離',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _calc10BottlesPerMinuteController,
              decoration: const InputDecoration(
                labelText: '能力本数 (本/分)',
                border: OutlineInputBorder(),
                helperText: '機械が1分間に処理できるボトル数',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
          ],
        );
        
      case 10: // [11] 処理能力本数と処理能力から処理能力計算
        return Column(
          children: [
            TextFormField(
              controller: _calc11NumberOfBottlesController,
              decoration: const InputDecoration(
                labelText: '処理能力本数 (本)',
                border: OutlineInputBorder(),
                helperText: '処理する総本数',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _calc11ProcessingTimePerBottleController,
              decoration: const InputDecoration(
                labelText: '処理能力 (秒)',
                border: OutlineInputBorder(),
                helperText: '1本あたりの処理時間',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
          ],
        );
        
      case 11: // [12] T速度、円周、回転数からインバータ計算
        return Column(
          children: [
            TextFormField(
              controller: _calc12TSpeedController,
              decoration: const InputDecoration(
                labelText: 'T速度 (m/rpm/min)',
                border: OutlineInputBorder(),
                helperText: '[3]で求めた値',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _calc12CircumferenceController,
              decoration: const InputDecoration(
                labelText: '円周 (mm)',
                border: OutlineInputBorder(),
                helperText: '[9]で求めた値',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _calc12HzRpmController,
              decoration: const InputDecoration(
                labelText: '回転数 (1Hz/rpm)',
                border: OutlineInputBorder(),
                helperText: '[11]で求めた値',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
          ],
        );
        
      case 12: // [13] 変則的速度と円周から変則的速度計算
        return Column(
          children: [
            TextFormField(
              controller: _calc13SpeedController,
              decoration: const InputDecoration(
                labelText: '変則的速度 (m/min)',
                border: OutlineInputBorder(),
                helperText: '変則的な速度',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _calc13CircumferenceController,
              decoration: const InputDecoration(
                labelText: '円周 (mm)',
                border: OutlineInputBorder(),
                helperText: '[9]で求めた値',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
          ],
        );
        
      case 13: // [14] 変則的速度(rpm)と回転数(1Hz/rpm)からインバータ計算
        return Column(
          children: [
            TextFormField(
              controller: _calc14IrregularSpeedHzController,
              decoration: const InputDecoration(
                labelText: '変則的速度 (rpm)',
                border: OutlineInputBorder(),
                helperText: '[13]で求めた値',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _calc14HzRpmController,
              decoration: const InputDecoration(
                labelText: '回転数 (1Hz/rpm)',
                border: OutlineInputBorder(),
                helperText: '[7]で求めた値',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositiveNumber,
            ),
          ],
        );
        
      default:
        return const SizedBox.shrink();
    }
  }

  void _calculateByIndex(int index) {
    switch (index) {
      case 0: // [1] 距離(mm)から距離(m)計算
        _calculateDistanceM();
        break;
      case 1: // [2] 到達時間(秒)から到達時間(分)計算
        _calculateArrivalTimeMin();
        break;
      case 2: // [3] 距離(m)と到達時間(分)からT速度計算
        _calculateTSpeed();
        break;
      case 3: // [4] ターンテーブル(P.C.D)から円周計算
        _calculateCircumference();
        break;
      case 4: // [5] 各モータ定格回転数、T速度、円周から計算上の減速比計算
        _calculateReductionRatio();
        break;
      case 5: // [6] 各モータ定格回転数と減速比から回転数計算
        _calculateMotorRpm();
        break;
      case 6: // [7] 回転数からHz換算計算
        _calculateHzFromRpm();
        break;
      case 7: // [8] 円周と回転数から回転数(m/min)計算
        _calculateRpmToMeterPerMin();
        break;
      case 8: // [9] 能力本数から処理能力計算
        _calculateProcessingTime();
        break;
      case 9: // [10] ボトル間隔と能力本数から速度計算
        _calculateSpeed();
        break;
      case 10: // [11] 処理能力本数と処理能力から処理能力計算
        _calculateTotalProcessingTime();
        break;
      case 11: // [12] T速度、円周、回転数からインバータ計算
        _calculateInverter();
        break;
      case 12: // [13] 変則的速度と円周から変則的速度計算
        _calculateIrregularSpeedHz();
        break;
      case 13: // [14] 変則的速度(rpm)と回転数(1Hz/rpm)からインバータ計算
        _calculateIrregularSpeedInverter();
        break;
    }
  }

  String? _validatePositiveNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '値を入力してください';
    }
    if (double.tryParse(value) == null) {
      return '有効な数値を入力してください';
    }
    if (double.parse(value) <= 0) {
      return '0より大きい値を入力してください';
    }
    return null;
  }

  // 保存ダイアログを表示
  Future<void> _showSaveDialog() async {
    // 入力されているデータや結果があるか確認
    bool hasInputs = false;
    for (final controller in _controllerMap.values) {
      if (controller.text.isNotEmpty) {
        hasInputs = true;
        break;
      }
    }

    bool hasResults = _results.isNotEmpty;

    if (!hasInputs && !hasResults) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存するデータがありません')),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController();
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('計算を保存'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '保存名',
                hintText: '例: モーター計算1',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('保存名を入力してください')),
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      await _saveCurrentCalculation(nameController.text.trim());
    }

    nameController.dispose();
  }

  // 現在の計算を保存
  Future<void> _saveCurrentCalculation(String name) async {
    // 入力値を収集
    Map<String, String> inputValues = {};
    _controllerMap.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        inputValues[key] = controller.text;
      }
    });

    // 結果を収集
    Map<int, double> results = {};
    _results.forEach((key, value) {
      if (value != null) {
        results[key] = value;
      }
    });

    // データを作成
    final calculationData = CalculationData(
      name: name,
      savedAt: DateTime.now(),
      inputValues: inputValues,
      results: results,
    );

    // 保存
    final success = await _storageService.saveCalculationData(calculationData);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('計算を保存しました')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存に失敗しました')),
        );
      }
    }
  }

  // 保存された計算を開く
  Future<void> _openSavedCalculation() async {
    final CalculationData? selected = await Navigator.push<CalculationData>(
      context,
      MaterialPageRoute(builder: (context) => const SavedCalculationsScreen()),
    );

    if (selected != null) {
      _loadCalculationData(selected);
    }
  }

  // 計算データを読み込む
  void _loadCalculationData(CalculationData data) {
    // すべての入力フィールドをクリア
    _controllerMap.forEach((key, controller) {
      controller.clear();
    });

    // すべての結果をクリア
    setState(() {
      _results.clear();
    });

    // 保存された入力値を設定
    data.inputValues.forEach((key, value) {
      final controller = _controllerMap[key];
      if (controller != null) {
        controller.text = value;
      }
    });

    // 保存された結果を設定
    setState(() {
      data.results.forEach((key, value) {
        _results[key] = value;
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('「${data.name}」を読み込みました')),
    );
  }

  // 現在の計算結果サマリーを構築
  Widget _buildResultsSummary() {
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
              '現在の計算結果サマリー',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Divider(height: 24),
            
            // 各入力値を表示
            if (_controllerMap.values.any((controller) => controller.text.isNotEmpty)) ...[
              const Text(
                '入力値',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 8),
              ..._buildInputValuesSummary(),
              const Divider(height: 24),
            ],
            
            // 各計算結果を表示
            const Text(
              '計算結果',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            ..._results.entries
                .where((entry) => entry.value != null)
                .map((entry) => _buildResultRow(entry.key, entry.value!)),
          ],
        ),
      ),
    );
  }

  // 入力値のサマリーを構築
  List<Widget> _buildInputValuesSummary() {
    final List<Widget> inputWidgets = [];
    
    // 各コントローラーの名前とその値を取得
    for (final entry in _controllerMap.entries) {
      if (entry.value.text.isEmpty) continue;
      
      // コントローラー名から項目名を取得
      String label = _getInputLabelFromControllerName(entry.key);
      
      inputWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$label：',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                entry.value.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return inputWidgets;
  }
  
  // コントローラー名から表示用ラベルを取得
  String _getInputLabelFromControllerName(String controllerName) {
    // 例: _calc1DistanceMmController → 距離 (mm)
    final Map<String, String> controllerLabels = {
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
      '_calc14IrregularSpeedHzController': '変則的速度 (rpm)',
      '_calc14HzRpmController': '回転数 (1Hz/rpm)',
    };
    
    return controllerLabels[controllerName] ?? controllerName;
  }

  // 計算結果の行を構築
  Widget _buildResultRow(int index, double value) {
    final String label = _resultLabels[index] ?? '未定義';
    final String unit = _resultUnits[index] ?? '';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label：',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${value.toStringAsFixed(4)} [$unit]',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade700,
            ),
          ),
        ],
      ),
    );
  }
} 