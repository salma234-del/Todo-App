import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_application/shared/cubit/cubit.dart';

Widget defaultTextField({
  required TextEditingController controller,
  required TextInputType type,
  required String? Function(String?) validate,
  Function? onSubmit,
  Function? onChange,
  Function? ontap,
  bool password = false,
  required String label,
  required IconData preIcon,
  IconData? suffIcon,
  Function? suffPressed,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      validator: validate,
      onFieldSubmitted: (value) {
        onSubmit!(value);
      },
      onChanged: (value) {
        onChange!(value);
      },
      onTap: () {
        ontap!();
      },
      obscureText: password,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(preIcon),
        suffixIcon: IconButton(
          icon: Icon(suffIcon),
          onPressed: () {
            suffPressed!();
          },
        ),
        border: const OutlineInputBorder(),
      ),
    );

Widget buildTaskItem(Map item, context) => Dismissible(
      key: Key(item['id'].toString()),
      onDismissed: (direction) {
        AppCubit.get(context).deleteFromDatabase(id: item['id']);
      },
      child: Container(
        width: double.infinity,
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.blue,
              child: Text(
                '${item['time']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['title']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    '${item['date']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context)
                    .updateDatabase(status: 'done', id: item['id']);
              },
              icon: const Icon(Icons.check_box),
              color: Colors.green,
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context)
                    .updateDatabase(status: 'archived', id: item['id']);
              },
              icon: const Icon(Icons.archive),
              color: Colors.grey,
            ),
          ]),
        ),
      ),
    );

Widget buildTasks({required List<Map> tasks}) {
  return ConditionalBuilder(
    condition: tasks.isNotEmpty,
    builder: (context) {
      return ListView.separated(
        itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
        separatorBuilder: (context, index) => const SizedBox(
          height: 20,
        ),
        itemCount: tasks.length,
      );
    },
    fallback: (context) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.menu,
              size: 100,
              color: Colors.grey,
            ),
            Text(
              'No Tasks Yet, Pleasw Add Some Tasks',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    },
  );
}
