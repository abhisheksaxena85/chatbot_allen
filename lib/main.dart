import 'package:chatbot_allen/color_pallet.dart';
import 'package:chatbot_allen/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner:false,
      theme: ThemeData.light(
        useMaterial3: true,
      ).copyWith(
        scaffoldBackgroundColor: Pallet.whiteColor,
        appBarTheme:const AppBarTheme(
          backgroundColor: Pallet.whiteColor,
        )
      ),

      home:HomePage(),
    );
  }
}