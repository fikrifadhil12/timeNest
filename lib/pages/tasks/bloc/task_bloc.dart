import 'dart:async';
import 'dart:collection';

import 'package:flutter_app/bloc/bloc_provider.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:flutter_app/pages/tasks/models/tasks.dart';

class TaskBloc implements BlocBase {
  // StreamController untuk daftar tugas
  StreamController<List<Tasks>> _taskController =
      StreamController<List<Tasks>>.broadcast();
  Stream<List<Tasks>> get tasks => _taskController.stream;

  // StreamController untuk statistik tugas
  StreamController<Map<String, int>> _statisticsController =
      StreamController<Map<String, int>>.broadcast();
  Stream<Map<String, int>> get statistics => _statisticsController.stream;

  // StreamController untuk perintah sinkronisasi
  StreamController<int> _cmdController = StreamController<int>.broadcast();

  // Database tugas
  final TaskDB _taskDb;

  late List<Tasks> _tasksList;
  late Filter _lastFilterStatus;

  // Konstruktor TaskBloc
  TaskBloc(this._taskDb) {
    // Inisialisasi dengan memfilter tugas hari ini
    filterTodayTasks();

    // Dengarkan sinkronisasi data dan statistik
    _cmdController.stream.listen((_) {
      _updateTaskStream(_tasksList);
      _fetchStatistics();
    });
  }

 // Ambil statistik tugas
  Future<void> _fetchStatistics() async {
    try {
      final stats = await _taskDb.getTaskStatistics();
      if (!_statisticsController.isClosed) {
        _statisticsController.sink.add(stats);
      }
    } catch (e) {
      print("Error fetching statistics: $e");
    }
  }

// Filter tugas dengan rentang waktu dan status
  Future<void> _filterTask(int taskStartTime, int taskEndTime, TaskStatus status) async {
    try {
      final tasks = await _taskDb.getTasks(
        startDate: taskStartTime,
        endDate: taskEndTime,
        taskStatus: status,
      );
      _updateTaskStream(tasks);
      await _fetchStatistics();
    } catch (e) {
      print("Error filtering tasks: $e");
    }
  }


  // Perbarui stream tugas
  void _updateTaskStream(List<Tasks> tasks) {
    _tasksList = tasks;
    if (!_taskController.isClosed) {
      _taskController.sink.add(UnmodifiableListView<Tasks>(_tasksList));
    }
  }

  // Filter tugas hari ini
  void filterTodayTasks() {
    final dateTime = DateTime.now();

    final startDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final int taskStartTime = startDate.millisecondsSinceEpoch;

    final endDate = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59);
    final int taskEndTime = endDate.millisecondsSinceEpoch;

    _filterTask(taskStartTime, taskEndTime, TaskStatus.PENDING);
    _lastFilterStatus = Filter.byToday();
  }

  // Filter tugas untuk minggu depan
  void filterTasksForNextWeek() {
    final dateTime = DateTime.now();
    final int taskStartTime = DateTime(dateTime.year, dateTime.month, dateTime.day)
        .millisecondsSinceEpoch;
    final int taskEndTime = DateTime(dateTime.year, dateTime.month, dateTime.day + 7, 23, 59)
        .millisecondsSinceEpoch;

    _filterTask(taskStartTime, taskEndTime, TaskStatus.PENDING);
    _lastFilterStatus = Filter.byNextWeek();
  }

  // Filter berdasarkan proyek
  void filterByProject(int projectId) {
    _taskDb.getTasksByProject(projectId, status: TaskStatus.PENDING).then((tasks) {
      if (tasks == null) return;
      _lastFilterStatus = Filter.byProject(projectId);
      _updateTaskStream(tasks);
      _fetchStatistics();
    });
  }

  // Filter berdasarkan label
  void filterByLabel(String labelName) {
    _taskDb.getTasksByLabel(labelName, status: TaskStatus.PENDING).then((tasks) {
      if (tasks == null) return;
      _lastFilterStatus = Filter.byLabel(labelName);
      _updateTaskStream(tasks);
      _fetchStatistics();
    });
  }

  // Filter berdasarkan status
  void filterByStatus(TaskStatus status) {
    _taskDb.getTasks(taskStatus: status).then((tasks) {
      if (tasks == null) return;
      _lastFilterStatus = Filter.byStatus(status);
      _updateTaskStream(tasks);
      _fetchStatistics();
    });
  }

  // Perbarui status tugas
  void updateStatus(int taskID, TaskStatus status) {
    _taskDb.updateTaskStatus(taskID, status).then((_) {
      refresh();
    });
  }

  // Hapus tugas
  void delete(int taskID) {
    _taskDb.deleteTask(taskID).then((_) {
      refresh();
    });
  }

  // Segarkan data berdasarkan filter terakhir
  void refresh() {
    switch (_lastFilterStatus.filterStatus!) {
      case FilterStatus.BY_TODAY:
        filterTodayTasks();
        break;

      case FilterStatus.BY_WEEK:
        filterTasksForNextWeek();
        break;

      case FilterStatus.BY_LABEL:
        filterByLabel(_lastFilterStatus.labelName!);
        break;

      case FilterStatus.BY_PROJECT:
        filterByProject(_lastFilterStatus.projectId!);
        break;

      case FilterStatus.BY_STATUS:
        filterByStatus(_lastFilterStatus.status!);
        break;
    }
    _fetchStatistics();
  }

  // Perbarui filter
  void updateFilters(Filter filter) {
    _lastFilterStatus = filter;
    refresh();
  }

  // Hentikan semua stream
  @override
  void dispose() {
    _taskController.close();
    _statisticsController.close();
    _cmdController.close();
  }
}

// Enum untuk status filter
enum FilterStatus { BY_TODAY, BY_WEEK, BY_PROJECT, BY_LABEL, BY_STATUS }

// Kelas Filter
class Filter {
  String? labelName;
  int? projectId;
  FilterStatus? filterStatus;
  TaskStatus? status;

  Filter.byToday() {
    filterStatus = FilterStatus.BY_TODAY;
  }

  Filter.byNextWeek() {
    filterStatus = FilterStatus.BY_WEEK;
  }

  Filter.byProject(this.projectId) {
    filterStatus = FilterStatus.BY_PROJECT;
  }

  Filter.byLabel(this.labelName) {
    filterStatus = FilterStatus.BY_LABEL;
  }

  Filter.byStatus(this.status) {
    filterStatus = FilterStatus.BY_STATUS;
  }

  bool operator ==(o) =>
      o is Filter &&
      o.labelName == labelName &&
      o.projectId == projectId &&
      o.filterStatus == filterStatus &&
      o.status == status;
}
