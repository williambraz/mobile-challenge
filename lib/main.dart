import 'package:flutter/material.dart';
import 'package:mobile_challenge/presentation/views/home.dart';
import 'package:mobile_challenge/presentation/views/user_profile.dart';
import 'package:mobile_challenge/utils/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github API',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      routes: {
        AppRoutes.Home: (context) => HomeView(),
        AppRoutes.UserProfile: (context) => UserProfileView(),
      },
    );
  }
}
