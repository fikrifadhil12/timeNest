import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app/pages/tasks/bloc/task_bloc.dart';
import 'package:flutter_app/pages/tasks/models/tasks.dart';

class StatisticsPage extends StatefulWidget {
  final TaskBloc taskBloc;

  StatisticsPage({required this.taskBloc});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();

    // Meminta data statistik berdasarkan status tugas
    widget.taskBloc.filterByStatus(TaskStatus.COMPLETE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Statisctic"),
      ),
      body: StreamBuilder<Map<String, int>>(
        stream: widget.taskBloc.statistics,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final stats = snapshot.data!;
            final completed = stats['completed'] ?? 0;
            final pending = stats['pending'] ?? 0;

            final bool hasPendingTasks = pending > 0;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: hasPendingTasks ? Colors.green : Colors.grey,
                            value: completed.toDouble(),
                            title: "$completed Selesai",
                            radius: 80,
                            titleStyle: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            color: hasPendingTasks ? Colors.red : Colors.grey,
                            value: pending.toDouble(),
                            title: hasPendingTasks
                                ? "$pending Belum Selesai"
                                : "Semua Selesai",
                            radius: 80,
                            titleStyle: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return Center(child: Text("Tidak ada data tersedia"));
          }
        },
      ),
    );
  }
}