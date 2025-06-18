import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PerformanceGraphScreen extends StatefulWidget {
  final String userId;
  const PerformanceGraphScreen({super.key, required this.userId});

  @override
  State<PerformanceGraphScreen> createState() => _PerformanceGraphScreenState();
}

class _PerformanceGraphScreenState extends State<PerformanceGraphScreen> {
  List<FlSpot> actualSpots = [];
  List<FlSpot> forecastSpots = [];
  List<String> dates = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPerformanceData();
  }

  Future<void> fetchPerformanceData() async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('performance_results')
        .doc(widget.userId)
        .get();

    if (!doc.exists) {
      setState(() => isLoading = false);
      return;
    }

    final data = doc.data()!;
    final actualData = data['actual'] as List<dynamic>;
    final forecastData = data['forecast'] as List<dynamic>;

    actualSpots = actualData.asMap().entries.map((entry) {
      int index = entry.key;
      double y = double.tryParse(entry.value['y'].toString()) ?? 0;
      return FlSpot(index.toDouble(), y);
    }).toList();

    forecastSpots = forecastData.asMap().entries.map((entry) {
      int index = entry.key + actualSpots.length;
      double y = double.tryParse(entry.value['yhat'].toString()) ?? 0;
      return FlSpot(index.toDouble(), y);
    }).toList();

    dates = [
      ...actualData.map((e) => e['ds'].toString().substring(0, 10)),
      ...forecastData.map((e) => e['ds'].toString().substring(0, 10)),
    ];

    setState(() => isLoading = false);
  } catch (e) {
    print("Error fetching performance data: $e");
    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Performance Prediction")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : actualSpots.isEmpty && forecastSpots.isEmpty
              ? Center(child: Text("No performance data available."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                   LineChartData(
  lineTouchData: LineTouchData(enabled: true),
  titlesData: FlTitlesData(
  leftTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 32,
      getTitlesWidget: (value, meta) {
        return Text(
          value.toStringAsFixed(1),
          style: TextStyle(fontSize: 10),
        );
      },
    ),
  ),
  bottomTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      interval: 3,
      getTitlesWidget: (value, _) {
        int index = value.toInt();
        if (index < dates.length) {
          String date = dates[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              date.substring(5),
              style: TextStyle(fontSize: 10),
            ),
          );
        } else {
          return Text('');
        }
      },
    ),
  ),
  topTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false), // 🔴 Hides top X-axis
  ),
  rightTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false), // (Optional) Hide right Y-axis
  ),
),

  gridData: FlGridData(show: true),
  borderData: FlBorderData(show: true),
  lineBarsData: [
    LineChartBarData(
      spots: actualSpots,
      isCurved: true,
      color: Colors.blue,
      barWidth: 2,
      belowBarData: BarAreaData(show: false),
    ),
    LineChartBarData(
      spots: forecastSpots,
      isCurved: true,
      color: Colors.green,
      barWidth: 2,
      dashArray: [5, 5],
      belowBarData: BarAreaData(show: false),
    ),
  ],
)

                  ),
                ),
    );
  }
}
