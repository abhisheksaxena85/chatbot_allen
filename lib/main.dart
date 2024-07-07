import 'package:chatbot_allen/New%20Version/dashboard_screen.dart';
import 'package:chatbot_allen/constants/apiKeys.dart';
import 'package:chatbot_allen/constants/color_pallet.dart';
import 'package:chatbot_allen/speechProvider/spech_text_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() {

  Gemini.init(apiKey: GeminiAIapiKey);

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
      title: 'Allen ChatBot-AI',
      debugShowCheckedModeBanner:false,
      theme: ThemeData.light(
        useMaterial3: true,
      ).copyWith(
        scaffoldBackgroundColor: Pallet.whiteColor,
        appBarTheme:const AppBarTheme(
          backgroundColor: Pallet.whiteColor,
        )
      ),
      home: const DashboardScreen()
    );
  }
}