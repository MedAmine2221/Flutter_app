import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stage_project/Screens/tasks_calendar/components/background.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Body extends StatefulWidget {
  final String cin;

  Body({
    required this.cin,
  });

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late Future<List<TaskData>> _futureTaskDataList;
  List<TaskData> _taskDataList = [];
  int _currentPage = 0;
  final int _rowsPerPage = 5; // Set the number of rows per page here
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<TaskData>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    _futureTaskDataList = fetchTasks();

  }
  /*Future<List<TaskData>> fetchTasks() async {
    final response = await http.get(
      Uri.parse('https://97d2-160-159-227-220.ngrok.io/afficher_taches_par_employee/${widget.cin}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final taskDataList = List<TaskData>.from(data['taches_projets'].map(
            (item) => TaskData(
          projectSubject: item['projet_sujet'],
          tasks: List<Map<String, dynamic>>.from(item['taches']),
        ),
      ));

      setState(() {
        _taskDataList = taskDataList;
      });

      return taskDataList;
    } else {
      throw Exception('Failed to fetch data');
    }
  }
*/
  Future<List<TaskData>> fetchTasks() async {
    final response = await http.get(
      Uri.parse('https://96cd-196-228-57-39.ngrok.io/afficher_taches_par_employee/${widget.cin}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final taskDataList = List<TaskData>.from(data['taches_projets'].map(
            (item) => TaskData(
          projectSubject: item['projet_sujet'],
          tasks: List<Map<String, dynamic>>.from(item['taches']),
        ),
      ));

      setState(() {
        _taskDataList = taskDataList;

        // Fill _tasksByDate map
        _tasksByDate = {};
        for (var taskData in _taskDataList) {
          for (var task in taskData.tasks) {
            final startDateStr = task['tache_date_debut'];
            final endDateStr = task['tache_date_fin'];

            final dateFormatter = DateFormat("EEE, d MMM yyyy HH:mm:ss 'GMT'");
            final startDate = dateFormatter.parse(startDateStr);
            final endDate = dateFormatter.parse(endDateStr);

            _tasksByDate.update(startDate, (value) => [...value, taskData], ifAbsent: () => [taskData]);
            if (isSameDay(endDate, DateTime.now())) {
              // Show an alert here, using showDialog or any other alert mechanism
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Time Expired'),
                    content: Text('The task "${taskData.projectSubject}" has ended today.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          }
        }
      });

      return taskDataList;
    } else {
      throw Exception('Failed to fetch data');
    }
  }
  List<Map<String, dynamic>> getCurrentPageTasks() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;
    final List<Map<String, dynamic>> currentPageTasks = [];

    if (startIndex < _taskDataList.length) {
      for (var i = startIndex; i < endIndex && i < _taskDataList.length; i++) {
        currentPageTasks.addAll(_taskDataList[i].tasks.map((task) {
          return {
            'projectSubject': _taskDataList[i].projectSubject,
            'tache_description': task['tache_description'],
            'tache_date_debut': task['tache_date_debut'],
            'tache_date_fin': task['tache_date_fin'],
          };
        }));
      }
    }

    return currentPageTasks;
  }


  void goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: FutureBuilder<List<TaskData>>(
        future: _futureTaskDataList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No data available.'),
            );
          } else {
            return ListView(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: TableCalendar(
                      firstDay: DateTime.utc(2023, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,

                      calendarBuilders: CalendarBuilders(
                        // Customize the marker color for each day with tasks
                        markerBuilder: (context, date, tasks) {
                          // Compare dates ignoring time
                          if (_tasksByDate.keys.any((taskDate) => isSameDay(taskDate, date))) {
                            return Container(
                              margin: const EdgeInsets.all(3.5),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },

                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Project')),
                        DataColumn(label: Text('Task')),
                        DataColumn(label: Text('Start')),
                        DataColumn(label: Text('End')),
                      ],
                      rows: [
                        for (var task in getCurrentPageTasks())
                          DataRow(
                            cells: [
                              DataCell(Text('${task['projectSubject']}')),
                              DataCell(Text('${task['tache_description']}')),
                              DataCell(Text('${task['tache_date_debut']}')),
                              DataCell(Text('${task['tache_date_fin']}')),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < (_taskDataList.length / _rowsPerPage).ceil(); i++)
                      GestureDetector(
                        onTap: () => goToPage(i),
                        child: Container(
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _currentPage == i ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            (i + 1).toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class TaskData {
  final String projectSubject;
  final List<Map<String, dynamic>> tasks;

  TaskData({
    required this.projectSubject,
    required this.tasks,
  });
}