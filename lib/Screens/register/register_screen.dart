import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_app/Screens/home/home_layout.dart';
import 'package:todo_app/Screens/register/cubit/RegisterCubit.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/components/constants.dart';
import 'cubit/RegisterStates.dart';

class RegisterScreen extends StatelessWidget {
  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => RegisterCubit(),
        child: BlocConsumer<RegisterCubit, RegisterStates>(
          listener: (BuildContext context, state) {
            if(state is RegisterCreateUserSuccessState){
              navigateAndFinish(context, HomeLayout());
            }if(state is RegisterSetEmailError){
              Fluttertoast.showToast(msg: "This mail already registered");
            }if(state is RegisterSetPhoneError){
              Fluttertoast.showToast(msg: "This Phone already registered");
            }
          },
          builder: (BuildContext context, Object? state) {
            RegisterCubit cubit = RegisterCubit.get(context);
            return Scaffold(
              body: Container(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Register",
                              style: TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              "Register now to manage your tasks",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            defaultTextFormField(
                                type: TextInputType.name,
                                labelText: "User Name",
                                validate: (value) {
                                  if (value!.isEmpty) {
                                    return 'You cannot leave the username field Empty';
                                  }
                                  return null;
                                },
                                prefix: Icons.person,
                                controller: nameController),
                            SizedBox(
                              height: 10.0,
                            ),
                            defaultTextFormField(
                                type: TextInputType.emailAddress,
                                labelText: "Email",
                                validate: (value) {
                                  if (value!.isEmpty) {
                                    return 'You cannot leave Email field Empty';
                                  }
                                  return null;
                                },
                                prefix: Icons.mail_outline,
                                controller: emailController),
                            SizedBox(
                              height: 10.0,
                            ),
                            defaultTextFormField(
                              type: TextInputType.visiblePassword,
                              isPassword: cubit.isPassword,
                              prefix: Icons.lock,
                              suffixPressed: () {
                                cubit.changePasswordVisibility();
                              },
                              suffixIcon: cubit.suffix,
                              labelText: "Password",
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return 'You cannot leave password field Empty';
                                }
                                return null;
                              },
                              controller: passwordController,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            defaultTextFormField(
                                type: TextInputType.phone,
                                labelText: "Phone",
                                validate: (value) {
                                  if (value!.isEmpty) {
                                    return 'You cannot leave the Phone field Empty';
                                  }
                                  return null;
                                },
                                prefix: Icons.phone_iphone,
                                controller: phoneController),
                            const SizedBox(
                              height: 20.0,
                            ),
                            ConditionalBuilder(
                              condition: state is! RegisterLoadingState,
                              fallback: (BuildContext context) =>
                                  Center(child: CircularProgressIndicator()),
                              builder: (BuildContext context) {
                                return defaultButton(
                                    width: double.infinity,
                                    background: primColor,
                                    function: () async {
                                      if (formKey.currentState!.validate()) {
                                        cubit.userRegisterCheck(
                                          name: nameController.text,
                                          email: emailController.text,
                                          phone: phoneController.text,
                                          password: passwordController.text,
                                        );
                                      }
                                    },
                                    text: "Register");
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }
}
