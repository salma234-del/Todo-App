import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../shared/cubit/cubit.dart';
import '../shared/components/componants.dart';
import '../shared/cubit/states.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleCon = TextEditingController();
  var timeCon = TextEditingController();
  var dateCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertToDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.currentIdx],
              ),
            ),
            floatingActionButton: FloatingActionButton(
                child: Icon(cubit.fbIcon),
                onPressed: () {
                  if (cubit.bottomSheetShow) {
                    if (formKey.currentState!.validate()) {
                      cubit.insertToDatabase(
                          title: titleCon.text,
                          date: dateCon.text,
                          time: timeCon.text);
                    }
                  } else {
                    scaffoldKey.currentState
                        ?.showBottomSheet(
                            elevation: 20,
                            (context) => Container(
                                  color: Colors.grey[100],
                                  padding: const EdgeInsets.all(20),
                                  child: Form(
                                    key: formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        defaultTextField(
                                          controller: titleCon,
                                          type: TextInputType.text,
                                          validate: (value) {
                                            if (value!.isEmpty) {
                                              return 'title must not be empty';
                                            }
                                            return null;
                                          },
                                          label: 'Task Title',
                                          preIcon: Icons.title,
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        defaultTextField(
                                          controller: timeCon,
                                          type: TextInputType.datetime,
                                          ontap: () {
                                            showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            ).then((value) {
                                              if (value != null) {
                                                timeCon.text =
                                                    value.format(context);
                                              }
                                            });
                                          },
                                          validate: (value) {
                                            if (value!.isEmpty) {
                                              return 'time must not be empty';
                                            }
                                            return null;
                                          },
                                          label: 'Task Time',
                                          preIcon: Icons.watch_later_outlined,
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        defaultTextField(
                                          controller: dateCon,
                                          type: TextInputType.datetime,
                                          ontap: () {
                                            showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate:
                                                  DateTime.parse('2024-12-30'),
                                            ).then((value) {
                                              if (value != null) {
                                                dateCon.text =
                                                    DateFormat.yMMMd()
                                                        .format(value);
                                              }
                                            });
                                          },
                                          validate: (value) {
                                            if (value!.isEmpty) {
                                              return 'date must not be empty';
                                            }
                                            return null;
                                          },
                                          label: 'Task Date',
                                          preIcon:
                                              Icons.calendar_today_outlined,
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                        .closed
                        .then((value) {
                      cubit.changeBottomSheet(show: false, icon: Icons.edit);
                    });
                    cubit.changeBottomSheet(show: true, icon: Icons.add);
                  }
                }),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: cubit.currentIdx,
                type: BottomNavigationBarType.fixed,
                onTap: (index) {
                  cubit.changesCurrentIndex(index);
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.menu), label: 'Tasks'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.check_circle_outline), label: 'Done'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.archive_outlined), label: 'Archived'),
                ]),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) => cubit.screens[cubit.currentIdx],
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}
