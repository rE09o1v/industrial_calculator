import 'package:flutter/material.dart';
import '../widgets/calculator_button.dart';
import 'industrial_calc_screen.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _display = '0';
  String _currentInput = '';
  double _result = 0;
  String _operation = '';
  bool _isNewOperation = true;
  String _memory = '0';
  String _lastOperation = '';
  String _lastNumber = '';

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _clear();
      } else if (buttonText == 'AC') {
        _allClear();
      } else if (buttonText == '=') {
        _calculate();
      } else if (['+', '-', '×', '÷'].contains(buttonText)) {
        _setOperation(buttonText);
      } else if (buttonText == '%') {
        _calculatePercent();
      } else if (buttonText == '+/-') {
        _changeSign();
      } else if (buttonText == '√') {
        _calculateSquareRoot();
      } else if (buttonText == 'x²') {
        _calculateSquare();
      } else if (buttonText == '1/x') {
        _calculateReciprocal();
      } else if (buttonText == 'M+') {
        _memoryAdd();
      } else if (buttonText == 'M-') {
        _memorySubtract();
      } else if (buttonText == 'MR') {
        _memoryRecall();
      } else if (buttonText == 'MC') {
        _memoryClear();
      } else {
        _appendNumber(buttonText);
      }
    });
  }

  void _clear() {
    _display = '0';
    _currentInput = '';
    _isNewOperation = true;
  }

  void _allClear() {
    _display = '0';
    _currentInput = '';
    _result = 0;
    _operation = '';
    _isNewOperation = true;
    _lastOperation = '';
    _lastNumber = '';
  }

  void _appendNumber(String number) {
    if (_isNewOperation) {
      _currentInput = number;
      _isNewOperation = false;
    } else {
      // すでに小数点がある場合は、もう一度追加しない
      if (number == '.' && _currentInput.contains('.')) {
        return;
      }
      _currentInput += number;
    }
    _display = _currentInput;
  }

  void _setOperation(String op) {
    if (_currentInput.isNotEmpty) {
      _calculate();
      _operation = op;
      _isNewOperation = true;
    } else if (_result != 0) {
      _operation = op;
      _isNewOperation = true;
    }
  }

  void _calculate() {
    if (_operation.isEmpty && _currentInput.isEmpty) return;
    
    // 直前の操作を繰り返す場合
    if (_operation.isEmpty && _lastOperation.isNotEmpty && _lastNumber.isNotEmpty) {
      _operation = _lastOperation;
      _currentInput = _lastNumber;
    }

    if (_currentInput.isEmpty) return;

    double secondOperand = double.parse(_currentInput);
    _lastNumber = _currentInput;
    
    if (_operation.isEmpty) {
      _result = secondOperand;
    } else {
      _lastOperation = _operation;
      
      switch (_operation) {
        case '+':
          _result += secondOperand;
          break;
        case '-':
          _result -= secondOperand;
          break;
        case '×':
          _result *= secondOperand;
          break;
        case '÷':
          if (secondOperand != 0) {
            _result /= secondOperand;
          } else {
            _display = 'エラー';
            return;
          }
          break;
      }
    }

    // 整数の場合は小数点を表示しない
    _display = _result % 1 == 0 ? _result.toInt().toString() : _result.toString();
    _isNewOperation = true;
    _currentInput = '';
  }

  void _calculatePercent() {
    if (_currentInput.isEmpty) return;
    
    double value = double.parse(_currentInput);
    
    if (_operation.isEmpty) {
      // 単独で使用する場合は、値を100で割る
      value = value / 100;
    } else {
      // 操作の一部として使用する場合（例：200 + 10%）
      switch (_operation) {
        case '+':
        case '-':
          // 加算・減算の場合は、前の値のパーセンテージとして計算
          value = _result * (value / 100);
          break;
        case '×':
        case '÷':
          // 乗算・除算の場合は、単にパーセンテージとして計算
          value = value / 100;
          break;
      }
    }
    
    _currentInput = value.toString();
    _display = value % 1 == 0 ? value.toInt().toString() : value.toString();
  }

  void _changeSign() {
    if (_currentInput.isEmpty) {
      if (_result != 0) {
        _result = -_result;
        _display = _result % 1 == 0 ? _result.toInt().toString() : _result.toString();
      }
      return;
    }
    
    double value = double.parse(_currentInput);
    value = -value;
    _currentInput = value.toString();
    _display = value % 1 == 0 ? value.toInt().toString() : value.toString();
  }

  void _calculateSquareRoot() {
    double value;
    
    if (_currentInput.isEmpty) {
      value = _result;
    } else {
      value = double.parse(_currentInput);
    }
    
    if (value < 0) {
      _display = 'エラー';
      return;
    }
    
    value = math.sqrt(value);
    if (_currentInput.isEmpty) {
      _result = value;
    } else {
      _currentInput = value.toString();
    }
    
    _display = value % 1 == 0 ? value.toInt().toString() : value.toString();
    _isNewOperation = true;
  }

  void _calculateSquare() {
    double value;
    
    if (_currentInput.isEmpty) {
      value = _result;
    } else {
      value = double.parse(_currentInput);
    }
    
    value = value * value;
    
    if (_currentInput.isEmpty) {
      _result = value;
    } else {
      _currentInput = value.toString();
    }
    
    _display = value % 1 == 0 ? value.toInt().toString() : value.toString();
    _isNewOperation = true;
  }

  void _calculateReciprocal() {
    double value;
    
    if (_currentInput.isEmpty) {
      value = _result;
    } else {
      value = double.parse(_currentInput);
    }
    
    if (value == 0) {
      _display = 'エラー';
      return;
    }
    
    value = 1 / value;
    
    if (_currentInput.isEmpty) {
      _result = value;
    } else {
      _currentInput = value.toString();
    }
    
    _display = value % 1 == 0 ? value.toInt().toString() : value.toString();
    _isNewOperation = true;
  }

  void _memoryAdd() {
    if (_currentInput.isNotEmpty) {
      double memValue = double.parse(_memory);
      memValue += double.parse(_currentInput);
      _memory = memValue.toString();
    } else if (_result != 0) {
      double memValue = double.parse(_memory);
      memValue += _result;
      _memory = memValue.toString();
    }
  }

  void _memorySubtract() {
    if (_currentInput.isNotEmpty) {
      double memValue = double.parse(_memory);
      memValue -= double.parse(_currentInput);
      _memory = memValue.toString();
    } else if (_result != 0) {
      double memValue = double.parse(_memory);
      memValue -= _result;
      _memory = memValue.toString();
    }
  }

  void _memoryRecall() {
    if (_memory != '0') {
      _currentInput = _memory;
      _display = _memory;
      _isNewOperation = false;
    }
  }

  void _memoryClear() {
    _memory = '0';
  }

  void _navigateToIndustrialCalc() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const IndustrialCalcScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('工業機械計算電卓'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: _navigateToIndustrialCalc,
            tooltip: '工業計算',
          ),
        ],
      ),
      body: Column(
        children: [
          // 計算結果表示エリア
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(minHeight: 80),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                _display,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          
          // メモリーインジケーター
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerRight,
            height: 24,
            child: Text(
              _memory != '0' ? 'M' : '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
          ),
          
          const Divider(),
          
          // ボタンエリア
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisCount: 4,
                childAspectRatio: 1.3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  // 1行目
                  CalculatorButton(
                    text: 'MC', 
                    onPressed: () => _onButtonPressed('MC'),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  CalculatorButton(
                    text: 'MR', 
                    onPressed: () => _onButtonPressed('MR'),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  CalculatorButton(
                    text: 'M+', 
                    onPressed: () => _onButtonPressed('M+'),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  CalculatorButton(
                    text: 'M-', 
                    onPressed: () => _onButtonPressed('M-'),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  
                  // 2行目
                  CalculatorButton(
                    text: 'AC', 
                    onPressed: () => _onButtonPressed('AC'),
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  ),
                  CalculatorButton(
                    text: '+/-', 
                    onPressed: () => _onButtonPressed('+/-'),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  CalculatorButton(
                    text: '%', 
                    onPressed: () => _onButtonPressed('%'),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  CalculatorButton(
                    text: '÷', 
                    onPressed: () => _onButtonPressed('÷'),
                    backgroundColor: Colors.orange,
                  ),
                  
                  // 3行目
                  CalculatorButton(text: '7', onPressed: () => _onButtonPressed('7')),
                  CalculatorButton(text: '8', onPressed: () => _onButtonPressed('8')),
                  CalculatorButton(text: '9', onPressed: () => _onButtonPressed('9')),
                  CalculatorButton(
                    text: '×', 
                    onPressed: () => _onButtonPressed('×'),
                    backgroundColor: Colors.orange,
                  ),
                  
                  // 4行目
                  CalculatorButton(text: '4', onPressed: () => _onButtonPressed('4')),
                  CalculatorButton(text: '5', onPressed: () => _onButtonPressed('5')),
                  CalculatorButton(text: '6', onPressed: () => _onButtonPressed('6')),
                  CalculatorButton(
                    text: '-', 
                    onPressed: () => _onButtonPressed('-'),
                    backgroundColor: Colors.orange,
                  ),
                  
                  // 5行目
                  CalculatorButton(text: '1', onPressed: () => _onButtonPressed('1')),
                  CalculatorButton(text: '2', onPressed: () => _onButtonPressed('2')),
                  CalculatorButton(text: '3', onPressed: () => _onButtonPressed('3')),
                  CalculatorButton(
                    text: '+', 
                    onPressed: () => _onButtonPressed('+'),
                    backgroundColor: Colors.orange,
                  ),
                  
                  // 6行目
                  CalculatorButton(
                    text: '0', 
                    onPressed: () => _onButtonPressed('0'),
                    backgroundColor: Colors.white,
                  ),
                  CalculatorButton(text: '.', onPressed: () => _onButtonPressed('.')),
                  CalculatorButton(
                    text: 'C', 
                    onPressed: () => _onButtonPressed('C'),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  CalculatorButton(
                    text: '=', 
                    onPressed: () => _onButtonPressed('='),
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          
          // 追加機能ボタンエリア
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 2.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                CalculatorButton(
                  text: '√', 
                  onPressed: () => _onButtonPressed('√'),
                  backgroundColor: Colors.grey.shade300,
                ),
                CalculatorButton(
                  text: 'x²', 
                  onPressed: () => _onButtonPressed('x²'),
                  backgroundColor: Colors.grey.shade300,
                ),
                CalculatorButton(
                  text: '1/x', 
                  onPressed: () => _onButtonPressed('1/x'),
                  backgroundColor: Colors.grey.shade300,
                ),
              ],
            ),
          ),
          
          // 工業計算へのボタン
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ElevatedButton.icon(
              onPressed: _navigateToIndustrialCalc,
              icon: const Icon(Icons.precision_manufacturing),
              label: const Text('工業計算へ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 