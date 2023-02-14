import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import '../../modules/archived_tasks/archived_tasks_screen.dart';
import '../../modules/done_tasks/done_tasks_screen.dart';
import '../../modules/new_tasks/new_tasks_screen.dart';
import 'states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIdx = 0;

  List screens = const [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changesCurrentIndex(int index) {
    currentIdx = index;
    emit(AppChangeBottomNavBarState());
  }

  late Database db;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (db, version) {
        debugPrint('database created');
        db
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY , title TEXT , date TEXT , time TEXT , status TEXT)')
            .then((value) {
          debugPrint('table created');
        }).catchError((error) {
          debugPrint('error ${error.toString()} while creating database');
        });
      },
      onOpen: (db) {
        getDataFromDatabase(db);
        debugPrint('database opened');
      },
    ).then((value) {
      db = value;
      emit(AppCreateDatabaseState());
    });
  }

  void insertToDatabase({
    required String title,
    required String date,
    required String time,
  }) async {
    await db.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("$title","$date","$time","new")')
          .then((value) {
        debugPrint('$value inserted successfully');
        emit(AppInsertToDatabaseState());
        getDataFromDatabase(db);
      }).catchError((e) {
        debugPrint('error when inserting new record ${e.toString()}');
      });
      return Future(() {});
    });
  }

  void getDataFromDatabase(db) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDatabaseLoadingState());
    db.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  void updateDatabase({
    required String status,
    required int id,
  }) async {
    db.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?', [status, id]).then((value) {
      getDataFromDatabase(db);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteFromDatabase({required int id}) async {
    db.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(db);
      emit(AppDeleteFromDatabaseSate());
    });
  }

  bool bottomSheetShow = false;
  var fbIcon = Icons.edit;

  void changeBottomSheet({
    required bool show,
    required IconData icon,
  }) {
    bottomSheetShow = show;
    fbIcon = icon;
    emit(AppChangeBottomSheetState());
  }
}
