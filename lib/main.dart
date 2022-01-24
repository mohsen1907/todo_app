import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/Screens/home/home_layout.dart';
import 'package:todo_app/Screens/login/login_screen.dart';
import 'package:todo_app/shared/bloc_observer.dart';
import 'package:todo_app/shared/components/constants.dart';
import 'package:todo_app/shared/local/cache_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await Firebase.initializeApp();
  await CacheHelper.init();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key, Widget? startWidget}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'todo App',
      theme: ThemeData(
        primarySwatch: primColor,
      ),
      home: CacheHelper.getString(key: "uId")==null?LoginScreen():HomeLayout()
    );
  }
}





