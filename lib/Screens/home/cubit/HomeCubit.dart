import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/Models/task_model.dart';
import 'package:todo_app/Screens/home/cubit/HomeStates.dart';
import 'package:todo_app/shared/local/cache_helper.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState());

  static HomeCubit get(context) => BlocProvider.of(context);

  String? uId= CacheHelper.getString(key: "uId");
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var dropDownValue;
  var dateController = TextEditingController();

  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;

    emit(HomeChangeBottomSheetState());
  }

  updateTaskStatus(taskId, status){
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection("tasks")
        .doc(taskId)
        .update({'status' : status}).then((value){
          emit(HomeChangeTaskStatusSuccessState());}).catchError((error){
      emit(HomeChangeTaskStatusErrorState());
    });
  getTasks();
  }

  logOut(){
    CacheHelper.removeString("uId");
    emit(HomeLogoutState());
  }

  updateTask({
    required String? taskId,
    String? title,
    String? description,
    String? date,
    String? parentId,
    bool? status
  }){
    TaskModel taskModel = TaskModel(
      title: title,
      description: description,
      date: date,
      parentId: parentId,
      status: status);
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection("tasks")
        .doc(taskId)
        .update(taskModel.toMap()).then((value){
          emit(HomeChangeTaskSuccessState());
    }).catchError((error){
      emit(HomeChangeTaskErrorState());
    });
  getTasks();
  }

  createTask({
    String? title,
    String? description,
    String? date,
    String? parentId,
  }) {
    TaskModel taskModel = TaskModel(
        title: title,
        description: description,
        date: date,
        status: false,
        parentId: parentId,);
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection("tasks")
        .doc()
        .set(taskModel.toMap())
        .then((value) {
      getTasks();
      emit(HomeCreateTaskSuccessState());
    }).catchError((error) {
      print(error);
      emit(HomeCreateTaskErrorState());
    });
  }

    deleteSubs(taskId){
    subTasks.forEach((subTask) {
      if(subTask.parentId==taskId){
        deleteTask(subTask.TaskId);
      }
    });
    deleteTask(taskId);
    getTasks();
  }

  deleteTask(taskId){
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection("tasks")
        .doc(taskId)
        .delete().then((value){
          emit(HomeDeleteTaskSuccessState());
    }).catchError((error){
      print(error);
          emit(HomeDeleteTaskErrorState());
    });
  }

  List<TaskModel> parentTasks = [];
  List<TaskModel> subTasks = [];

  getTasks(){
    parentTasks = [];
    subTasks = [];
    emit(HomeGetTasksLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId).collection("tasks")
        .get().then((value) {
    value.docs.forEach((element) {
      print("element.id ${element.id}");
      if(TaskModel.fromJosn(element.data(),element.id).parentId!=null)
      {
        subTasks.add(TaskModel.fromJosn(element.data(), element.id));
      }else{
        parentTasks.add(TaskModel.fromJosn(element.data(),element.id));
      }
    });
    //   taskModel = TaskModel.fromJosn(value.data());
      print(parentTasks[0].description);
      emit(HomeGetTasksSuccessState());
    }).catchError((error){
      print(error);
      emit(HomeGetTasksErrorState());
    });
  }



  List<DropdownMenuItem> buildDropdownTestItems() {

    List<DropdownMenuItem> items = [];
    for (var i in parentTasks) {
      items.add(
        DropdownMenuItem<String>(
          value: i.TaskId,
          child: Text("${i.title}"),
        ),
      );
    }
    return items;
  }


}
