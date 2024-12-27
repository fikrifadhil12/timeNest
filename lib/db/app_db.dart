import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/tasks/models/task_labels.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app/pages/tasks/models/tasks.dart';

/// This is the singleton database class which handlers all database transactions
/// All the task raw queries is handle here and return a Future<T> with result
class AppDatabase {
  static final AppDatabase _appDatabase = AppDatabase._internal();

  //private internal constructor to make it singleton
  AppDatabase._internal();

  late Database _database;

  static AppDatabase get() {
    return _appDatabase;
  }

  bool didInit = false;

  /// Use this method to access the database which will provide you future of [Database],
  /// because initialization of the database (it has to go through the method channel)
  Future<Database> getDb() async {
    if (!didInit) await _init();
    return _database;
  }

  Future _init() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "tasks.db");
    _database = await openDatabase(path, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    didInit = true;
  }

  /// Create tables when initializing the database
  Future _onCreate(Database db, int version) async {
    await _createProjectTable(db);
    await _createTaskTable(db);
    await _createLabelTable(db);
  }

  /// Re-create tables when upgrading database
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute("DROP TABLE ${Tasks.tblTask}");
    await db.execute("DROP TABLE ${Project.tblProject}");
    await db.execute("DROP TABLE ${TaskLabels.tblTaskLabel}");
    await db.execute("DROP TABLE ${Label.tblLabel}");
    await _createProjectTable(db);
    await _createTaskTable(db);
    await _createLabelTable(db);
  }

  /// Create Project Table
  Future _createProjectTable(Database db) {
    return db.transaction((txn) async {
      txn.execute("CREATE TABLE ${Project.tblProject} ("
          "${Project.dbId} INTEGER PRIMARY KEY AUTOINCREMENT,"
          "${Project.dbName} TEXT,"
          "${Project.dbColorName} TEXT,"
          "${Project.dbColorCode} INTEGER);");
      txn.rawInsert('INSERT INTO '
          '${Project.tblProject}(${Project.dbId},${Project.dbName},${Project.dbColorName},${Project.dbColorCode})'
          ' VALUES(1, "Inbox", "Grey", ${Colors.grey.value});');
    });
  }

  /// Create Task Table
  Future _createTaskTable(Database db) {
    return db.execute("CREATE TABLE ${Tasks.tblTask} ("
        "${Tasks.dbId} INTEGER PRIMARY KEY AUTOINCREMENT,"
        "${Tasks.dbTitle} TEXT,"
        "${Tasks.dbComment} TEXT,"
        "${Tasks.dbDueDate} LONG,"
        "${Tasks.dbPriority} LONG,"
        "${Tasks.dbProjectID} LONG,"
        "${Tasks.dbStatus} LONG," // Task status: 0 = pending, 1 = completed
        "FOREIGN KEY(${Tasks.dbProjectID}) REFERENCES ${Project.tblProject}(${Project.dbId}) ON DELETE CASCADE);");
  }

  /// Create Label and TaskLabels Table
  Future _createLabelTable(Database db) {
    return db.transaction((txn) async {
      await txn.execute("CREATE TABLE ${Label.tblLabel} ("
          "${Label.dbId} INTEGER PRIMARY KEY AUTOINCREMENT,"
          "${Label.dbName} TEXT,"
          "${Label.dbColorName} TEXT,"
          "${Label.dbColorCode} INTEGER);");
      await txn.execute("CREATE TABLE ${TaskLabels.tblTaskLabel} ("
          "${TaskLabels.dbId} INTEGER PRIMARY KEY AUTOINCREMENT,"
          "${TaskLabels.dbTaskId} INTEGER,"
          "${TaskLabels.dbLabelId} INTEGER,"
          "FOREIGN KEY(${TaskLabels.dbTaskId}) REFERENCES ${Tasks.tblTask}(${Tasks.dbId}) ON DELETE CASCADE,"
          "FOREIGN KEY(${TaskLabels.dbLabelId}) REFERENCES ${Label.tblLabel}(${Label.dbId}) ON DELETE CASCADE);");
    });
  }

  /// Function to fetch task statistics: completed and pending
  Future<Map<String, int>> getTaskStatistics() async {
    final db = await getDb();

    // Query to count completed tasks
    final completedCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM ${Tasks.tblTask} WHERE ${Tasks.dbStatus} = 1'));

    // Query to count pending tasks
    final pendingCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM ${Tasks.tblTask} WHERE ${Tasks.dbStatus} = 0'));

    return {
      "completed": completedCount ?? 0,
      "pending": pendingCount ?? 0,
    };
  }

  /// Function to get label colors as Map<labelId, colorCode>
  Future<Map<int, int>> getLabelColors() async {
    final db = await getDb();
    final result = await db.query(Label.tblLabel, columns: [Label.dbId, Label.dbColorCode]);

    return Map.fromIterable(result,
        key: (item) => item[Label.dbId] as int, value: (item) => item[Label.dbColorCode] as int);
  }
}
