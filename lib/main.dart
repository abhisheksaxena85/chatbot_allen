import 'package:chatbot_allen/constants/color_pallet.dart';
import 'package:chatbot_allen/speechProvider/spech_text_provider.dart';
import 'package:chatbot_allen/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context)=> speechTextProvider(),
      child: MyApp(),
    )
  );
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
      home: HomePage()
    );
  }
}