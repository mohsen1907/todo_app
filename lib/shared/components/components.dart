import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/Models/task_model.dart';
import 'package:todo_app/Screens/home/cubit/HomeCubit.dart';
import 'package:todo_app/Screens/home/cubit/HomeStates.dart';
import 'package:todo_app/shared/components/constants.dart';

Widget defaultButton(
        {required void Function() function,
        required String text,
        double width = double.infinity,
        double height = 50,
        Color? background,
        double radius = 10}) =>
    Container(
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(radius)),
      width: width,
      child: MaterialButton(
        onPressed: function,
        height: height,
        child: Text(
          text.toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

Widget defaultTextFormField(
        {TextEditingController? controller,
        TextInputType? type,
        FormFieldValidator? validate,
        required IconData prefix,
        String? text,
        String? hintText,
        String? labelText,
        IconData? suffixIcon,
        Function? onTap,
        Function? onSubmit,
        Function? onChange,
        Function? suffixPressed,
        bool isReadOnly = false,
        bool isPassword = false,
        bool isClicable = true}) =>
    TextFormField(
      keyboardType: type,
      initialValue: text,
      controller: controller,
      obscureText: isPassword,
      readOnly: isReadOnly,
      enabled: isClicable,
      validator: validate,
      onFieldSubmitted: (s) {
        onSubmit!(s);
      },
      onChanged: (s) {
        onChange!(s);
      },
      onTap: () {
        onTap!();
      },
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: Icon(prefix),
        suffixIcon: suffixIcon != null
            ? IconButton(
                onPressed: () {
                  suffixPressed!();
                },
                icon: Icon(suffixIcon),
              )
            : null,
        border: OutlineInputBorder(),
      ),
    );

void navigateTo(context, widget) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );

void navigateAndFinish(context, Widget widget) => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => widget),
      (Route<dynamic> route) => false,
    );



Widget taskBuilder(
        List<TaskModel> tasks, cubitContext, List<TaskModel> subTasks,state) =>
    ConditionalBuilder(
        condition: state is !HomeGetTasksLoadingState,
        builder: (context) => ListView.separated(
            itemBuilder: (context, index) {
              print("${index}: ${tasks[index].TaskId}");
              return buildTaskItem(
                  tasks[index], context, cubitContext, subTasks);
            },
            separatorBuilder: (context, index) => myDivider(),
            itemCount: tasks.length),
        fallback: (context) => Center(child: CircularProgressIndicator()));

Widget buildTaskItem(
  TaskModel model,
  context,
  cubitContext,
  List<TaskModel> subTasks,
) {
  HomeCubit cubit = HomeCubit.get(cubitContext);
  return Dismissible(
      key: Key("${model.TaskId}"),
      background: Container(
        color: Colors.redAccent,
      ),
      onDismissed: (direction) {
        HomeCubit.get(cubitContext).deleteSubs(model.TaskId);
      },
      child: ExpandablePanel(
        theme: const ExpandableThemeData(
          headerAlignment: ExpandablePanelHeaderAlignment.center,
          tapBodyToExpand: true,
          tapBodyToCollapse: true,
          hasIcon: false,
        ),
        header: Container(
          color: primColor.shade700,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                ExpandableIcon(
                  theme: const ExpandableThemeData(
                    expandIcon: Icons.arrow_right,
                    collapseIcon: Icons.arrow_drop_down,
                    iconColor: Colors.white,
                    iconSize: 28.0,
                    iconPadding: EdgeInsets.only(right: 5),
                    hasIcon: false,
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40.0,
                        child: Text(
                          '${model.date}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${model.title}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                            Text(
                              '${model.description}',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      IconButton(
                        onPressed: () {
                          showMessageDialog(
                              cubitContext, "Edit Task", "subtitle", "Save",
                              () {
                            cubit.updateTask(
                                taskId: model.TaskId,
                                title: cubit.titleController.text,
                                description: cubit.descriptionController.text,
                                date: cubit.dateController.text,
                                parentId: cubit.dropDownValue,
                                status: model.status
                            );
                          }, model);
                        },
                        icon: Icon(Icons.edit),
                        color: Colors.white70,
                      ),
                      Checkbox(
                        checkColor: Colors.white,
                        activeColor: Colors.green,
                        value: model.status,
                        onChanged: (value) {
                          HomeCubit.get(context)
                              .updateTaskStatus(model.TaskId, value);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        collapsed: Container(),
        expanded: Column(children: [
          for (var subTask in subTasks)
            subTask.parentId == model.TaskId
                ? buildSubTaskItem(
                    subTask,
                    context,
                  )
                : Container()
        ]),
      ));
}

Widget buildSubTaskItem(TaskModel model, context) {
  HomeCubit cubit = HomeCubit.get(context);
  return Dismissible(
    key: Key("${model.TaskId}"),
    onDismissed: (direction) {
      HomeCubit.get(context).deleteTask(model.TaskId);
      HomeCubit.get(context).getTasks();
    },
    background: Container(
      color: Colors.red,
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(40, 20, 20, 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40.0,
            child: Text(
              '${model.date}',
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${model.title}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${model.description}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          IconButton(
            onPressed: () {
              showMessageDialog(
                  context, "Edit Task", "subtitle", "Save", () {
                cubit.updateTask(
                  taskId: model.TaskId,
                  title: cubit.titleController.text,
                  description: cubit.descriptionController.text,
                  date: cubit.dateController.text,
                  parentId: cubit.dropDownValue,
                );
              }, model);
            },
            icon: Icon(Icons.edit),
            color: Colors.black45,
          ),
          Checkbox(
            checkColor: Colors.white,
            activeColor: Colors.green,
            value: model.status,
            onChanged: (value) {
              HomeCubit.get(context).updateTaskStatus(model.TaskId, value);
            },
          ),
        ],
      ),
    ),
  );
}

Widget BuildTaskFields(context, {TaskModel? model}) {
  HomeCubit cubit = HomeCubit.get(context);
  // print("From BuildTaskFields ${model}");
  List<DropdownMenuItem<dynamic>>? dropDownItems = [];
  if (model != null) {
    cubit.titleController.text = "${model.title}";
    cubit.descriptionController.text = "${model.description}";
    cubit.dateController.text = "${model.date}";
    if (model.parentId != null) {
      dropDownItems = cubit.buildDropdownTestItems();
      cubit.dropDownValue = "${model.parentId}";
    }
  } else {
    cubit.titleController.value = TextEditingValue.empty;
    cubit.descriptionController.value = TextEditingValue.empty;
    cubit.dateController.value = TextEditingValue.empty;
    cubit.dropDownValue = null;
    dropDownItems = cubit.buildDropdownTestItems();
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      //Title Box
      defaultTextFormField(
          controller: cubit.titleController,
          type: TextInputType.text,
          validate: (value) {
            if (value.isEmpty) {
              return 'title must not be empty';
            }
          },
          labelText: "Task Title",
          prefix: Icons.title),
      SizedBox(
        height: 15,
      ),
      //descriptionBox
      defaultTextFormField(
          controller: cubit.descriptionController,
          type: TextInputType.text,
          validate: (value) {
            if (value.isEmpty) {
              return 'description field must not be empty';
            }
          },
          labelText: "Task Description",
          prefix: Icons.description),

      SizedBox(
        height: 15,
      ),
      //DateBox
      defaultTextFormField(
          controller: cubit.dateController,
          type: TextInputType.text,
          isReadOnly: true,
          labelText: "Date Time",
          prefix: Icons.watch_later,
          onTap: () {
            showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.parse('2022-10-03'))
                .then((value) {
              cubit.dateController.text = DateFormat.yMMMd().format(value!);
            });
          }),
      SizedBox(
        height: 15,
      ),
      DropdownButtonFormField<dynamic>(
        value: cubit.dropDownValue,
        items: dropDownItems,
        onChanged: (value) {
          print(value);
          cubit.dropDownValue = value;
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Choose parent task",
        ),
      )
    ],
  );
}

Future<void> showMessageDialog(BuildContext cubitContext, String title,
    String subtitle, buttonText, buttonFunction, TaskModel model,
    {String CancelButton = ""}) {
  return showDialog<void>(
    context: cubitContext,
    // backdrop enable to hide message when click any where
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: BuildTaskFields(cubitContext, model: model),
        ),
        actions: [
          if (CancelButton != "")
            TextButton(
              child: Text(CancelButton),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          TextButton(
            child: Text(buttonText),
            onPressed: () {
              Navigator.of(context).pop();
              buttonFunction();
            },
          ),
        ],
      );
    },
  );
}

Widget myDivider() => Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey[300],
      ),
    );
