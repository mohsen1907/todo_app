import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/Screens/home/home_layout.dart';
import 'package:todo_app/Screens/login/cubit/LoginCubit.dart';
import 'package:todo_app/Screens/login/cubit/LoginStates.dart';
import 'package:todo_app/Screens/register/register_screen.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/components/constants.dart';
import 'package:todo_app/shared/local/cache_helper.dart';

class LoginScreen extends StatelessWidget {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginCubit(),
      child: BlocConsumer<LoginCubit,LoginStates>(
        listener: (context,state){
          if(state is LoginSuccessState){
            CacheHelper.putString(key: "uId", value: state.uId).then((value) {
              navigateAndFinish(context, HomeLayout());
            });
          }
        },
        builder: (context,state){
          LoginCubit cubit = LoginCubit.get(context);
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
                            "Login",
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "Login now to manage your tasks",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,

                            ),
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                          defaultTextFormField(
                              type: TextInputType.emailAddress,
                              labelText: "Email",
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return 'You cannot leave the name field Empty';
                                }
                                return null;
                              },
                              prefix: Icons.email,
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
                                return 'You cannot leave the Password field Empty';
                              }
                              return null;
                            },
                            controller: passwordController,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          ConditionalBuilder(
                            condition: state is! LoginLoadingState,
                            fallback: (BuildContext context) =>
                                Center(child: CircularProgressIndicator()),
                            builder: (BuildContext context) {
                              return defaultButton(
                                background: primColor,
                                  width: double.infinity,
                                  function: () async {
                                    if (formKey.currentState!.validate()) {
                                      cubit.userLogin(
                                          email: emailController.text,
                                          password: passwordController.text);
                                    }
                                  },
                                  text: "Login");
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account?',
                              ),
                              TextButton(
                                onPressed: () {
                                  navigateTo(context, RegisterScreen());
                                },
                                child: Text(
                                  'Register Now',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
