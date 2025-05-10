import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rural_jobs_app/user_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot)
      {
        if(snapshot.connectionState == ConnectionState.waiting)
          {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Rural jobs app is being initialized',
                    style: TextStyle(color: Colors.cyan, fontSize: 40, fontWeight: FontWeight.bold),),
                ),
              )
            );
          } else if(snapshot.hasError)
          {
            return const MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Text('An error has been occurred',
                      style: TextStyle(color: Colors.cyan, fontSize: 38, fontWeight: FontWeight.bold,),),
                  ),
                )
            );
          } return MaterialApp(debugShowCheckedModeBanner: false,
          title: 'Rural Job App', theme: ThemeData(scaffoldBackgroundColor: Colors.black, primarySwatch: Colors.blue),
          home: UserState(),
        );
      }
    );
  }
}