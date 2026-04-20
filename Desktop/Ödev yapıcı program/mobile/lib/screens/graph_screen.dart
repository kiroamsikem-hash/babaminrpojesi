import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;
import '../config/theme_v2.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final TextEditingController _functionController = TextEditingController();
  List<FlSpot> _points = [];
  String _errorMessage = '';
  double _minX = -10;
  double _maxX = 10;
  double _minY = -10;
  double _maxY = 10;
  bool _showKeyboard = true;

  @override
  void initState() {
    super.initState();
    _functionController.text = 'x^2';
    _functionController.addListener(_plotFunction);
    _plotFunction();
  }

  void _plotFunction() {
    setState(() {
      _errorMessage = '';
      _points = [];
    });

    try {
      final input = _functionController.text.trim();
      if (input.isEmpty) return;

      Parser p = Parser();
      Expression exp = p.parse(input);
      
      Variable x = Variable('x');
      ContextModel cm = ContextModel();

      List<FlSpot> points = [];
      final step = (_maxX - _minX) / 200;
      
      for (double xVal = _minX; xVal <= _maxX; xVal += step) {
        try {
          cm.bindVariable(x, Number(xVal));
          double yVal = exp.evaluate(EvaluationType.REAL, cm);
          
          if (yVal.isFinite && yVal >= _minY && yVal <= _maxY) {
            points.add(FlSpot(xVal, yVal));
          }
        } catch (e) {
          // Tanımsız nokta
        }
      }

      if (points.isEmpty) {
        setState(() {
          _errorMessage = 'Grafik çizilemedi';
        });
        return;
      }

      setState(() {
        _points = points;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Hatalı fonksiyon';
      });
    }
  }

  void _insertText(String text) {
    final currentText = _functionController.text;
    final selection = _functionController.selection;
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    _functionController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + text.length,
      ),
    );
  }

  void _backspace() {
    final currentText = _functionController.text;
    final selection = _functionController.selection;
    if (selection.start > 0) {
      final newText = currentText.replaceRange(
        selection.start - 1,
        selection.end,
        '',
      );
      _functionController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start - 1,
        ),
      );
    }
  }

  void _clear() {
    _functionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Grafik Çizim'),
        backgroundColor: QuietTechColors.primary,
        actions: [
          IconButton(
            icon: Icon(_showKeyboard ? Icons.keyboard_hide : Icons.keyboard),
            onPressed: () => setState(() => _showKeyboard = !_showKeyboard),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                _minX *= 0.8;
                _maxX *= 0.8;
                _minY *= 0.8;
                _maxY *= 0.8;
              });
              _plotFunction();
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                _minX *= 1.2;
                _maxX *= 1.2;
                _minY *= 1.2;
                _maxY *= 1.2;
              });
              _plotFunction();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _minX = -10;
                _maxX = 10;
                _minY = -10;
                _maxY = 10;
              });
              _plotFunction();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Fonksiyon Girişi
          Container(
            padding: const EdgeInsets.all(16),
            color: QuietTechColors.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'f(x) = ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _functionController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Fonksiyon girin',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),

          // Grafik
          Expanded(
            child: _points.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Fonksiyon girin',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: LineChart(
                      LineChartData(
                        minX: _minX,
                        maxX: _maxX,
                        minY: _minY,
                        maxY: _maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: (_maxY - _minY) / 10,
                          verticalInterval: (_maxX - _minX) / 10,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: value == 0
                                  ? Colors.black.withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.2),
                              strokeWidth: value == 0 ? 2 : 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: value == 0
                                  ? Colors.black.withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.2),
                              strokeWidth: value == 0 ? 2 : 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _points,
                            isCurved: true,
                            color: QuietTechColors.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: QuietTechColors.primary.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Matematiksel Klavye
          if (_showKeyboard) _buildMathKeyboard(),
        ],
      ),
    );
  }

  Widget _buildMathKeyboard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fonksiyonlar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _buildKeyButton('sin(', color: Colors.blue[100]),
                _buildKeyButton('cos(', color: Colors.blue[100]),
                _buildKeyButton('tan(', color: Colors.blue[100]),
                _buildKeyButton('sqrt(', color: Colors.green[100]),
                _buildKeyButton('ln(', color: Colors.green[100]),
                _buildKeyButton('e^', color: Colors.orange[100]),
                _buildKeyButton('abs(', color: Colors.purple[100]),
              ],
            ),
          ),
          // Sayılar ve operatörler
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildKeyButton('x')),
                    Expanded(child: _buildKeyButton('^')),
                    Expanded(child: _buildKeyButton('(')),
                    Expanded(child: _buildKeyButton(')')),
                    Expanded(child: _buildKeyButton('/', color: Colors.orange[100])),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: _buildKeyButton('7')),
                    Expanded(child: _buildKeyButton('8')),
                    Expanded(child: _buildKeyButton('9')),
                    Expanded(child: _buildKeyButton('*', color: Colors.orange[100])),
                    Expanded(child: _buildKeyButton('π')),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: _buildKeyButton('4')),
                    Expanded(child: _buildKeyButton('5')),
                    Expanded(child: _buildKeyButton('6')),
                    Expanded(child: _buildKeyButton('-', color: Colors.orange[100])),
                    Expanded(child: _buildKeyButton('e')),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: _buildKeyButton('1')),
                    Expanded(child: _buildKeyButton('2')),
                    Expanded(child: _buildKeyButton('3')),
                    Expanded(child: _buildKeyButton('+', color: Colors.orange[100])),
                    Expanded(
                      child: _buildKeyButton(
                        '⌫',
                        onPressed: _backspace,
                        color: Colors.red[100],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: _buildKeyButton('0')),
                    Expanded(child: _buildKeyButton('.')),
                    Expanded(
                      flex: 3,
                      child: _buildKeyButton(
                        'Temizle',
                        onPressed: _clear,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyButton(String text, {VoidCallback? onPressed, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: ElevatedButton(
        onPressed: onPressed ?? () => _insertText(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.white,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _functionController.dispose();
    super.dispose();
  }
}
