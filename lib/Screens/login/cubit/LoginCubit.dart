import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'LoginStates.dart';

class LoginCubit extends Cubit<LoginStates>{
  LoginCubit() : super(LoginInitialState());

  static LoginCubit get(context) => BlocProvider.of(context);

  bool isPassword = true;
  IconData suffix = Icons.remove_red_eye_outlined;

  void userLogin({
  required String email,
  required String password,
}){
    emit(LoginLoadingState());
    FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((value) {
      print(value.user?.uid);
      emit(LoginSuccessState(value.user?.uid));
    }).catchError((error){
      print(error);
      emit(LoginErrorState(error));
    });
  }

  changePasswordVisibility() {
    isPassword = !isPassword;
    suffix = isPassword
        ? Icons.remove_red_eye_outlined
        : Icons.visibility_off_outlined;
    emit(LoginChangePasswordVisibilityState());
  }

}