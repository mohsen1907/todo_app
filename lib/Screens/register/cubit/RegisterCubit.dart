import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_app/Models/user_model.dart';
import 'package:todo_app/shared/local/cache_helper.dart';

import 'RegisterStates.dart';

class RegisterCubit extends Cubit<RegisterStates> {
  RegisterCubit() : super(RegisterInitialState());

  static RegisterCubit get(context) => BlocProvider.of(context);

  bool isPassword = true;
  IconData suffix = Icons.remove_red_eye_outlined;

  userRegister(
      {required String name,
      required String email,
      required String password,
      required String phone}) {
    emit(RegisterLoadingState());
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      userCreate(name: name, email: email, phone: phone, uId: value.user?.uid);
      emit(RegisterSuccessState());
      print(value.user?.email);
    }).catchError((error) {
      print(error);
      Fluttertoast.showToast(msg: error);
      emit(RegisterErrorState(error));
    });
  }


   userRegisterCheck({
     required String name,
     required String email,
     required String phone,
     required String password,
  }) {
    bool isMailValid=true;
    bool isPhoneValid=true;
    FirebaseFirestore.instance.collection('users').get().then((value) {
      value.docs.forEach((element) {
        if (UserModel.fromJson(element.data()).email == email) {
          isMailValid = false;
          emit(RegisterSetEmailError());
        } else if (UserModel.fromJson(element.data()).phone == phone) {
          isPhoneValid = false;
          emit(RegisterSetPhoneError());

        }
      });
      if(isMailValid && isPhoneValid) {
        print("isMailValid: ${isMailValid}");
        print("isPhoneValid: ${isPhoneValid}");
        userRegister(name: name, email: email, password: password, phone: phone);
      }
    });

   }

  userCreate({
    required String name,
    required String email,
    required String phone,
    required String? uId,
  }) {

    CacheHelper.putString(key: "uId", value: uId);
    UserModel userModel =
        UserModel(email: email, name: name, phone: phone, uId: uId);
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set(userModel.toMap())
        .then((value) {
      emit(RegisterCreateUserSuccessState());
    }).catchError((error) {
      emit(RegisterCreateUserErrorState(error));
    });
  }

  changePasswordVisibility() {
    isPassword = !isPassword;
    suffix = isPassword
        ? Icons.remove_red_eye_outlined
        : Icons.visibility_off_outlined;
    emit(RegisterChangePasswordVisibilityState());
  }
}
