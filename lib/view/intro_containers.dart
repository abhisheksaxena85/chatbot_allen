import 'package:flutter/cupertino.dart';import 'package:flutter/material.dart';import 'package:google_fonts/google_fonts.dart';import '../constants/color_pallet.dart';import 'featureBox.dart';class IntroContainer extends StatelessWidget {  const IntroContainer({super.key});  @override  Widget build(BuildContext context) {    return Column(      children: [        //Greeting-Box Chat Bubble      Container(      width: MediaQuery.of(context).size.width/1.2,      margin:const EdgeInsets.only(bottom: 20,right: 35,top: 50),      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10).copyWith(bottom: 15),      alignment: Alignment.centerLeft,      decoration: BoxDecoration(        color: Colors.white,        border: Border.all(color: Colors.grey.shade600,width: 1),        borderRadius:const BorderRadius.only(topLeft:Radius.circular(0),topRight:Radius.circular(30),bottomLeft: Radius.circular(30),bottomRight:Radius.circular(30)),      ),      child: Text(        "Hi, what do you want to ask today?",        textAlign: TextAlign.start,        style:GoogleFonts.openSans(            textStyle:const TextStyle(                fontSize: 17,                color: Colors.black,                fontWeight: FontWeight.normal            )        ),      ),    ),        //Suggestion title        Container(            alignment: Alignment.centerLeft,            margin: const EdgeInsets.only(left: 10, top: 10),            padding: const EdgeInsets.all(10),            child: Text(              'Here are few features',              style: GoogleFonts.openSans(                textStyle:TextStyle(                  fontSize: 18,                  color: Colors.black,                  fontWeight: FontWeight.w500                ),              )            )),        //Suggestion List        Column(          mainAxisAlignment: MainAxisAlignment.start,          crossAxisAlignment: CrossAxisAlignment.center,          children: [            FeatureBox(              title: 'Gemini-AI',              boxColor: Pallet.firstSuggestionBoxColor,              descriptionText:              'A smarter way to stay organized and informed with Gemini-AI',            ),            FeatureBox(              title: 'LaMDA',              boxColor: Pallet.secondSuggestionBoxColor,              descriptionText:              'A generative language model for dialogue applications that Google introduced in 2021 to enable the Google Assistant to converse on any topic',            ),            FeatureBox(              title: 'Vertex AI',              boxColor: Pallet.secondSuggestionBoxColor,              descriptionText:              'A unified artificial intelligence platform that offers all of Google\'s cloud services, allowing users to build, deploy, and scale machine learning models',            ),          ],        ),      ],    );  }}