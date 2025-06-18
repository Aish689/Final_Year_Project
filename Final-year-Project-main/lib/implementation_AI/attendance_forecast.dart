import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';



class LoadForecastScreen extends StatefulWidget {
  final String userId;

  LoadForecastScreen({required this.userId});

  @override
  _LoadForecastScreenState createState() => _LoadForecastScreenState();
}

class _LoadForecastScreenState extends State<LoadForecastScreen> {
  List<dynamic> actualData = [];
  List<dynamic> forecastData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadForecastFromFirebase();
  }

  Future<void> loadForecastFromFirebase() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('forecast_results')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);

        if (data.containsKey('actual') && data.containsKey('forecast')) {
          List<dynamic> rawActual = List.from(data['actual']);
          List<dynamic> rawForecast = List.from(data['forecast']);

          // Filter actual data for current month only
          final filteredActual = rawActual.where((entry) {
            final date = entry['ds'] is Timestamp
                ? (entry['ds'] as Timestamp).toDate()
                : DateTime.tryParse(entry['ds'].toString()) ?? DateTime.now();
            return date.isAfter(startOfMonth.subtract(Duration(days: 1))) &&
                date.month == now.month;
          }).toList();

          setState(() {
            actualData = filteredActual;
            forecastData = rawForecast;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            actualData = [];
            forecastData = [];
          });
        }
      } else {
        setState(() {
          isLoading = false;
          actualData = [];
          forecastData = [];
        });
      }
    } catch (e) {
      debugPrint("Error loading forecast: $e");
      setState(() {
        isLoading = false;
        actualData = [];
        forecastData = [];
      });
    }
  }

  String formatDate(dynamic dateInput) {
    DateTime date;
    if (dateInput is Timestamp) {
      date = dateInput.toDate();
    } else if (dateInput is String) {
      date = DateTime.tryParse(dateInput) ?? DateTime.now();
    } else {
      return "";
    }
    return DateFormat('d MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> actualSpots = [];
    List<FlSpot> forecastSpots = [];
    List<String> xAxisLabels = [];

    // Combine and sort all data to maintain proper x positions
    List<Map<String, dynamic>> combined = [];

    for (var entry in actualData) {
      combined.add({'type': 'actual', 'ds': entry['ds'], 'y': entry['y']});
    }

    for (var entry in forecastData) {
      combined.add({'type': 'forecast', 'ds': entry['ds'], 'yhat': entry['yhat']});
    }

    combined.sort((a, b) {
      DateTime aDate = a['ds'] is Timestamp
          ? (a['ds'] as Timestamp).toDate()
          : DateTime.tryParse(a['ds'].toString()) ?? DateTime.now();
      DateTime bDate = b['ds'] is Timestamp
          ? (b['ds'] as Timestamp).toDate()
          : DateTime.tryParse(b['ds'].toString()) ?? DateTime.now();
      return aDate.compareTo(bDate);
    });

    for (int i = 0; i < combined.length; i++) {
      final entry = combined[i];
      DateTime date = entry['ds'] is Timestamp
          ? (entry['ds'] as Timestamp).toDate()
          : DateTime.tryParse(entry['ds'].toString()) ?? DateTime.now();

      if (entry['type'] == 'actual') {
        final y = entry['y'] is num ? entry['y'].toDouble() : double.tryParse(entry['y'].toString()) ?? 0;
        actualSpots.add(FlSpot(i.toDouble(), y));
      } else if (entry['type'] == 'forecast') {
        final yhat = entry['yhat'] is num ? entry['yhat'].toDouble() : double.tryParse(entry['yhat'].toString()) ?? 0;
        forecastSpots.add(FlSpot(i.toDouble(), yhat));
      }

      xAxisLabels.add(DateFormat('d MMM').format(date));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Attendance Forecast")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : (actualSpots.isEmpty && forecastSpots.isEmpty)
                ? Center(child: Text("No forecast data available for this employee."))
                : Column(
                    children: [
                      Text(
                        "Attendance Forecast for This Month",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: 1.2,
                            lineBarsData: [
                              LineChartBarData(
                                spots: actualSpots,
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 2,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blue.withOpacity(0.2),
                                ),
                              ),
                              LineChartBarData(
                                spots: forecastSpots,
                                isCurved: true,
                                color: Colors.green,
                                barWidth: 2,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.green.withOpacity(0.2),
                                ),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= 0 &&
                                        value.toInt() < xAxisLabels.length) {
                                      return Transform.rotate(
                                        angle: -0.5,
                                        child: Text(
                                          xAxisLabels[value.toInt()],
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      );
                                    }
                                    return SizedBox.shrink();
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 0.5,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(1),
                                      style: TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
