import 'dart:math';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Graph extends StatefulWidget {
  const Graph({super.key});

  @override
  State<Graph> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<Graph>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Color> gradientColors = const [
    Color.fromARGB(255, 3, 103, 16),
    Color.fromARGB(255, 2, 103, 46),
  ];

  bool showAvg = false;

  final List<FlSpot> originalSpots = const [
    FlSpot(0, 3),
    FlSpot(2.6, 2),
    FlSpot(4.9, 5),
    FlSpot(6.8, 3.1),
    FlSpot(8, 4),
    FlSpot(9.5, 3),
    FlSpot(11, 4),
  ];

  final List<FlSpot> avgSpots = const [
    FlSpot(0, 3.44),
    FlSpot(2.6, 3.44),
    FlSpot(4.9, 3.44),
    FlSpot(6.8, 3.44),
    FlSpot(8, 3.44),
    FlSpot(9.5, 3.44),
    FlSpot(11, 3.44),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        if (showAvg) setState(() {});
      });

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() {
          showAvg = true;
        });
      }
    });
  }

  List<FlSpot> interpolateSpots(double t) {
    List<FlSpot> result = [];
    for (int i = 0; i < originalSpots.length; i++) {
      double x = originalSpots[i].x;
      double y = lerpDouble(originalSpots[i].y, avgSpots[i].y, t)!;
      result.add(FlSpot(x, y));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final t = _controller.isAnimating ? _controller.value : 0.0;

    return Center(
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.7,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LineChart(
                showAvg ? animatedAvgData(t) : mainData(),
                key: showAvg ? ValueKey(t) : null,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: TextButton(
              onPressed: () {
                setState(() {
                  showAvg = !showAvg;
                });
              },
              child: Text(
                'avg',
                style: TextStyle(
                  fontSize: 12,
                  color: showAvg
                      ? Colors.white.withOpacity(0.5)
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData animatedAvgData(double t) {
    final color = ColorTween(
      begin: gradientColors[0],
      end: gradientColors[1],
    ).lerp(0.5)!;

    return LineChartData(
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      gridData: whiteGridData(),
      titlesData: getTitlesData(),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: interpolateSpots(t),
          isCurved: true,
          barWidth: 5,
          gradient: LinearGradient(colors: [color, color]),
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData() {
    return LineChartData(
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      gridData: whiteGridData(),
      titlesData: getTitlesData(),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: originalSpots,
          isCurved: true,
          barWidth: 5,
          gradient: LinearGradient(colors: gradientColors),
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((c) => c.withOpacity(0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  FlGridData whiteGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      drawHorizontalLine: true,
      horizontalInterval: 1,
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) => FlLine(
        color: Colors.white.withOpacity(0.3),
        strokeWidth: 1,
      ),
      getDrawingVerticalLine: (value) => FlLine(
        color: Colors.white.withOpacity(0.3),
        strokeWidth: 1,
      ),
    );
  }

  FlTitlesData getTitlesData() {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: 1,
          getTitlesWidget: (value, meta) {
            const style = TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            );
            Widget text;
            switch (value.toInt()) {
              case 2:
                text = const Text('MAR', style: style);
                break;
              case 5:
                text = const Text('JUN', style: style);
                break;
              case 8:
                text = const Text('SEP', style: style);
                break;
              default:
                text = const Text('', style: style);
                break;
            }

            return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 8,
              child: text,
            );
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}