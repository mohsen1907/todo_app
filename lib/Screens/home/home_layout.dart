import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/Screens/home/cubit/HomeCubit.dart';
import 'package:todo_app/Screens/home/cubit/HomeStates.dart';
import 'package:todo_app/Screens/login/login_screen.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/components/constants.dart';

class HomeLayout extends StatelessWidget {
  var scafoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => HomeCubit()..getTasks(),
      child: BlocConsumer<HomeCubit, HomeStates>(
        listener: (context, state) {},
        builder: (context, state) {
          HomeCubit cubit = HomeCubit.get(context);
          return Scaffold(
            key: scafoldKey,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text("Todo App"),
              actions: [
                IconButton(
                    onPressed: () {
                      cubit.logOut();
                      navigateAndFinish(context, LoginScreen());
                    },
                    icon: Icon(Icons.logout)),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: primColor.shade800,
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit.createTask(
                      title: cubit.titleController.text,
                      description: cubit.descriptionController.text,
                      date: cubit.dateController.text,
                      parentId: cubit.dropDownValue,
                    );
                    Navigator.pop(context);
                    cubit.changeBottomSheetState(
                        isShow: false, icon: Icons.edit);
                  }
                } else {
                  scafoldKey.currentState
                      ?.showBottomSheet((bottomSheetContext) => Container(
                            color: Colors.grey[200],
                            padding: EdgeInsets.all(20.0),
                            child: Form(
                              key: formKey,
                              child: BuildTaskFields(context),
                            ),
                          ))
                      .closed
                      .then((value) => {
                            cubit.changeBottomSheetState(
                                isShow: false, icon: Icons.edit),
                          });
                  cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            body: ConditionalBuilder(
                condition: cubit.parentTasks.length > 0 &&
                    state is! HomeGetTasksLoadingState,
                builder: (context) => taskBuilder(
                    cubit.parentTasks, context, cubit.subTasks, state),
                fallback: (context) => Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.menu,
                          size: 100.0,
                          color: Colors.grey,
                        ),
                        Text(
                          "No Tasks Yet, Please Add Some Tasks",
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        )
                      ],
                    ))),
          );
        },
      ),
    );
  }
}
