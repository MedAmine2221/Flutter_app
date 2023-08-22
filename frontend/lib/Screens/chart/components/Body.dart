import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Importez le package fl_chart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stage_project/Screens/chart/components/background.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Future<List<List<int>>> fetchEvaluations() async {
    final response = await http.get(Uri.parse(
        'https://771c-102-159-212-28.ngrok.io/get_evaluations'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final evaluations =
      (data['evaluations'] as List).map((e) => List<int>.from(e)).toList();
      return evaluations;
    } else {
      throw Exception('Failed to fetch evaluations');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Background(
      child: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: 300, // Set a fixed height for the container
          child: Column(
            children: [
              Text(
                "Employee Evaluation Statistics About the App",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              FutureBuilder<List<List<int>>>(
                future: fetchEvaluations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final evaluations = snapshot.data!;
                    Color getColorForValue(int value) {
                      if (value == 5) {
                        return Colors.blue;
                      } else if (value == 4) {
                        return Colors.green;
                      } else if (value == 3) {
                        return Colors.yellow;
                      } else {
                        return Colors.red;
                      }
                    }
                    return Container(
                      height: 250, // Set a fixed height for the PieChart
                      child: PieChart(
                        PieChartData(
                          sections: evaluations.fold<Map<int, int>>(
                              {}, (map, valueList) {
                            final value = valueList.isNotEmpty
                                ? valueList[0]
                                : 0;
                            map[value] = (map[value] ?? 0) + 1;
                            return map;
                          }).entries.map(
                                (entry) {
                              final value = entry.key;
                              final count = entry.value;
                              final totalEvaluations = evaluations.length;
                              final percentage = (count / totalEvaluations) *
                                  100;

                              return PieChartSectionData(
                                value: count.toDouble(),
                                color: getColorForValue(value),
                                title: '$value stars\n${percentage
                                    .toStringAsFixed(2)}%',
                                titleStyle: TextStyle(fontSize: 12),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    );
                  } else {
                    return Text('No data available');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}