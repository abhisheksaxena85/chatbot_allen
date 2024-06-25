import 'package:chatbot_allen/respository/gemini_services.dart';import 'package:chatbot_allen/speechProvider/spech_text_provider.dart';import 'package:flutter/material.dart';import 'package:flutter_spinkit/flutter_spinkit.dart';import 'package:provider/provider.dart';import 'package:speech_to_text/speech_recognition_result.dart';import 'package:speech_to_text/speech_to_text.dart';class SearchSection extends StatefulWidget {  const SearchSection({super.key});  @override  State<SearchSection> createState() => _SearchSectionState();}class _SearchSectionState extends State<SearchSection> {  TextEditingController promptTextFieldController = TextEditingController();  bool isPromptEmpty = true;  SpeechToText textToSpeech = SpeechToText();  String spokenWords = '';  GeminiAIService service = GeminiAIService();  String isArtPromptResult = '';  late bool isArtPrompt;  bool isWaitingResult = false;  bool ResultLoading = false;  List<String> promptArray = [];  @override  void initState() {    super.initState();    textToSpeechInitialization();  }  Future<void> textToSpeechInitialization() async {    await textToSpeech.initialize(      onStatus: (status) {        if (status == 'notListening') {          setState(() {            // Handle what happens when the speech recognition stops automatically            _performActionOnStop();          });        }      },    );    setState(() {});  }  Future<void> startListening() async {    await textToSpeech.listen(      onResult: onSpeechResult,    );    setState(() {      print('start listening method called');    });  }  Future<void> stopListening() async {    await textToSpeech.stop();    setState(() {});  }  void onSpeechResult(SpeechRecognitionResult result) {    setState(() {      spokenWords = result.recognizedWords;      print(spokenWords);      promptTextFieldController.text = spokenWords;    });  }  void _performActionOnStop() {    print("Speech recognition stopped automatically. Performing action.");    setState(() {      isPromptEmpty = false;    });  }  //Getting data from Gemini API  Future<void> isPromptApiCall(String spokenWords,BuildContext context) async {    isArtPromptResult = await service.isArtPromptAPI(spokenWords);    isArtPrompt = isPromptArt(isArtPromptResult);    Provider.of<speechTextProvider>(context,listen: false).IsArtPrompt(isArtPrompt);    isArtPrompt !=null ? PromptResponse(spokenWords, isArtPrompt):print('Art Prompt bool value is null');    setState(() {});  }  //Cheking if prompt result is command to generate image  bool isPromptArt(String result) {    result = result.trim();    switch (result) {      case 'Yes':      case 'yes':      case 'Yes.':      case 'yes.':      case 'YES':        return true;      case 'NO':      case 'No':      case 'no':      case 'No.':      case 'no.':        return false;      default:        return false;    }  }  @override  Widget build(BuildContext context) {    spokenWords = promptTextFieldController.text.toString().trim();    return Container(        color: Colors.white,        child: Container(            height: 40,            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),            decoration: BoxDecoration(                color: Colors.grey.shade300,                borderRadius: const BorderRadius.all(Radius.circular(15))),            child: Row(              mainAxisAlignment: MainAxisAlignment.center,              crossAxisAlignment: CrossAxisAlignment.center,              children: [                Expanded(                    child: TextField(                          cursorColor: Colors.black,                          mouseCursor: MouseCursor.defer,                          controller: promptTextFieldController,                          onChanged: (value) {                            setState(() {                              if (promptTextFieldController.text != '') {                                isPromptEmpty = false;                              } else {                                isPromptEmpty = true;                              }                            });                          },                          decoration: const InputDecoration(                              hintText: 'Message',                              contentPadding: EdgeInsets.symmetric(                                  vertical: 5, horizontal: 10),                              enabledBorder: OutlineInputBorder(                                  borderSide: BorderSide(                                      color: Colors.transparent, width: 0)),                              focusedBorder: OutlineInputBorder(                                  borderSide: BorderSide(                                      color: Colors.transparent, width: 0))))),                isPromptEmpty                    ? InkWell(                  splashColor: Colors.white,                  child: Container(                      padding: const EdgeInsets.all(10),                      child: textToSpeech.isListening?SpinKitThreeBounce(size:16,color: Colors.black,):Icon(Icons.mic)),                  onTap: () async {                    if (await textToSpeech.hasPermission &&                        textToSpeech.isNotListening) {                      await startListening();                    } else if (textToSpeech.isListening) {                      await stopListening();                      service.isArtPromptAPI(spokenWords);                    } else {                      textToSpeechInitialization();                    }                    setState(() {});                  },                ) : InkWell(                  splashColor: Colors.white,                  onTap:ResultLoading?(){}:spokenWords!=''?() {                    setState(() {                      ResultLoading = true;                      Provider.of<speechTextProvider>(context,listen: false).updateText(spokenWords);                      Provider.of<speechTextProvider>(context,listen: false).setPromptArray(promptArray);                      isPromptApiCall(spokenWords,context);                      promptArray.add(spokenWords); //Adding data to array list                      promptTextFieldController.clear();                      setState((){});                    });                  }:(){},                  child: Container(                      height: 40,                      width: 40,                      decoration: const BoxDecoration(                          color: Colors.black,                          borderRadius: BorderRadius.all(Radius.circular(20))),                      child: ResultLoading? const Padding(                        padding: EdgeInsets.all(10),                        child: CircularProgressIndicator(                          strokeWidth: 2.5,                          strokeCap: StrokeCap.round,                          color: Colors.white),                      ) : const Icon(                        Icons.arrow_upward_outlined,                        color: Colors.white,                      )),                ),              ],            )));  }  void PromptResponse(String prompt,bool isArtPrompt)async{    if(!isArtPrompt){      String promptResult = await service.textPromptResult(prompt);      promptArray.add(promptResult);      Provider.of<speechTextProvider>(context,listen: false).setPromptArray(promptArray);      ResultLoading = false;      isPromptEmpty = true;      setState(() {      });    }  }}