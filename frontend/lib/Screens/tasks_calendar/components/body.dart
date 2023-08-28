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
  Future<void> _refreshPage() async {
    // Delay for 2 seconds
    await Future.delayed(Duration(seconds: 2));

    // Perform any refresh-related tasks here
    // For example, you might want to fetch updated data or update the UI
    setState(() {
      // Update your state here
    });

    // Call the refresh function again to repeat the process
    _refreshPage();
  }
  @override
  void initState() {
    super.initState();
    _futureTaskDataList = fetchTasks();
    _refreshPage();
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

  Future<void> markTaskAsDone(int taskId) async {
    final response = await http.post(
      Uri.parse('https://9e9b-196-229-191-69.ngrok.io/enregistrer_tache_terminee/$taskId'),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:  Row(
              children: [
                Icon(Icons.done, color: Colors.green), // Icône "Done"
                SizedBox(width: 10), // Espacement entre l'icône et le texte
              ],
            ),
            content: Text('Task marked as done successfully.'),
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
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.sms_failed_outlined, color: Colors.red), // Icône "Done"
                SizedBox(width: 10), // Espacement entre l'icône et le texte
              ],
            ),
            content: Text('Failed to mark task as done'),
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

  Future<List<TaskData>> fetchTasks() async {
    final response = await http.get(
      Uri.parse('https://9e9b-196-229-191-69.ngrok.io/afficher_taches_par_employee/${widget.cin}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Response: $data');
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
  /*
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
*/
  List<TaskWithId> getCurrentPageTasks() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;
    final List<TaskWithId> currentPageTasks = [];

    if (startIndex < _taskDataList.length) {
      for (var i = startIndex; i < endIndex && i < _taskDataList.length; i++) {
        for (var task in _taskDataList[i].tasks) {
          currentPageTasks.add(TaskWithId(
            projectSubject: _taskDataList[i].projectSubject,
            tacheDescription: task['tache_description'],
            tacheDateDebut: task['tache_date_debut'],
            tacheDateFin: task['tache_date_fin'],
            taskId: task['tache_id'],
          ));
        }
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
                        markerBuilder: (context, date, tasks) {
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
                        DataColumn(label: Text('Action')),
                      ],
                      rows: [
                        for (var taskWithId in getCurrentPageTasks())
                          DataRow(
                            cells: [
                              DataCell(Text('${taskWithId.projectSubject}')),
                              DataCell(Text('${taskWithId.tacheDescription}')),
                              DataCell(Text('${taskWithId.tacheDateDebut}')),
                              DataCell(Text('${taskWithId.tacheDateFin}')),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () {
                                    final taskId = taskWithId.taskId;
                                    if (taskId != null) {
                                      markTaskAsDone(taskId);
                                    } else {
                                      print("Error: Task ID is null.");
                                    }
                                  },
                                  child: Text('Mark as Done'),
                                ),
                              ),
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


class TaskWithId {
  final String projectSubject;
  final String tacheDescription;
  final String tacheDateDebut;
  final String tacheDateFin;
  final int taskId;

  TaskWithId({
    required this.projectSubject,
    required this.tacheDescription,
    required this.tacheDateDebut,
    required this.tacheDateFin,
    required this.taskId,
  });
}