import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_application/shared/cubit/cubit.dart';
import 'package:todo_application/shared/cubit/states.dart';

import '../../shared/components/componants.dart';

class NewTasksScreen extends StatelessWidget {
  const NewTasksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, _) {
          var tasks = AppCubit.get(context).newTasks;
          return buildTasks(tasks: tasks);
        });
  }
}
