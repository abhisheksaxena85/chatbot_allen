import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:chatbot_allen/view/animated_streaming_text.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // bool isLoading = false;
  Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  StreamSubscription? _geminiSubscription;
  DateTime? _activeAssistantMessageCreatedAt;
  bool _isAssistantStreaming = false;
  ChatUser currentUser = ChatUser(
      id: "0",
      firstName: "User",
      profileImage:
          "https://static.vecteezy.com/system/resources/previews/005/005/788/original/user-icon-in-trendy-flat-style-isolated-on-grey-background-user-symbol-for-your-web-site-design-logo-app-ui-illustration-eps10-free-vector.jpg");
  ChatUser geminiUser = ChatUser(
      id: "1",
      firstName: "Gemini",
      profileImage:
          "https://hugeicons.com/api/png?uuid=google-gemini-solid-rounded");

  @override
  void dispose() {
    _geminiSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: Text(
          'ChatBot AI',
          style: GoogleFonts.dmSans(
              textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          )),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              tooltip: "New Page",
              onPressed: () {
                setState(() {
                  messages = [];
                });
              },
              icon: Icon(
                Icons.add,
                color: Colors.black,
                size: 28,
              ))
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      currentUser: currentUser,
      onSend: onSend,
      messages: messages,
      inputOptions: InputOptions(
        alwaysShowSend: true,
        inputMaxLines: 2,
        sendButtonBuilder: (Function()? onSend) {
          return IconButton(
            icon: const Icon(Icons.send,
                color: Colors.black), // Set your desired color here
            onPressed: onSend,
          );
        },
        leading: [
          IconButton(
              onPressed: () {
                sendMediaImage();
              },
              icon: const Icon(Icons.image, color: Colors.black))
        ],
        inputDecoration: InputDecoration(
          hintText: "Search...",
          filled: true,
          fillColor: Colors.grey.shade300,
          contentPadding:
              const EdgeInsets.only(left: 15, top: 3, bottom: 3, right: 15),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 0),
              borderRadius: BorderRadius.all(Radius.circular(25))),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 0),
              borderRadius: BorderRadius.all(Radius.circular(25))),
        ),
      ),
      messageOptions: MessageOptions(
        messageTextBuilder: (message, previousMessage, nextMessage) {
          bool msg = message.user.id == '1';
          final style = GoogleFonts.openSans(
            textStyle: TextStyle(
              fontSize: 15,
              color: msg ? Colors.black : Colors.white,
              fontWeight: FontWeight.normal,
            ),
          );

          if (!msg) {
            return Text(message.text, style: style);
          }

          final isActiveStreamingMessage =
              _isAssistantStreaming && message.createdAt == _activeAssistantMessageCreatedAt;
          return AnimatedStreamingText(
            text: message.text,
            style: style,
            isStreaming: isActiveStreamingMessage,
          );
        },
        messageDecorationBuilder: (message, previousMessage, nextMessage) {
          bool msg = message.user.id == '1';
          return BoxDecoration(
            border: msg
                ? Border.all(
                    width: 1,
                    color: Colors.black54,
                  )
                : null,
            borderRadius: msg
                ? const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))
                : const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(0),
                    bottomLeft: Radius.circular(30)),
            color: msg ? Colors.white : Colors.black87,
          );
        },
        textColor: Colors.black,
        currentUserTextColor: Colors.white,
        currentUserContainerColor: Colors.black87,
        showCurrentUserAvatar: false,
        containerColor: Colors.grey.shade100,
      ),
    );
  }

  String _sanitizeGeminiText(String input) {
    return input.replaceAll("**", "").replaceAll("*", "").replaceAll("#", "").trimRight();
  }

  String _extractStreamText(GenerateContentEvent event) {
    final raw = event.content?.parts?.fold<String>(
          "",
          (previous, current) => "$previous${current.text ?? ""}",
        ) ??
        "";
    return _sanitizeGeminiText(raw);
  }

  void onSend(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    try {
      _geminiSubscription?.cancel();

      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }

      // Create the assistant bubble immediately (so it doesn't pop in late).
      final assistantMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: "",
      );
      setState(() {
        _isAssistantStreaming = true;
        _activeAssistantMessageCreatedAt = assistantMessage.createdAt;
        messages = [assistantMessage, ...messages];
      });

      _geminiSubscription = gemini.streamGenerateContent(question, images: images).listen(
        (event) {
          final chunk = _extractStreamText(event);
          if (chunk.isEmpty) return;

          final idx = messages.indexWhere(
            (m) => m.user.id == geminiUser.id && m.createdAt == _activeAssistantMessageCreatedAt,
          );

          if (idx == -1) return;

          final m = messages[idx];
          m.text += chunk;
          setState(() {
            // Trigger rebuild; keep list order.
            messages = [...messages];
          });
        },
        onError: (_) {
          setState(() {
            _isAssistantStreaming = false;
            _activeAssistantMessageCreatedAt = null;
          });
        },
        onDone: () {
          setState(() {
            _isAssistantStreaming = false;
            _activeAssistantMessageCreatedAt = null;
          });
        },
      );
    } catch (e) {
      print(e.toString());
      setState(() {
        _isAssistantStreaming = false;
        _activeAssistantMessageCreatedAt = null;
      });
    }
  }

  void sendMediaImage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final editedPath = await _showImageEditSheet(originalPath: file.path);
    if (editedPath == null) return;

    ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Explain this image",
        medias: [
          ChatMedia(url: editedPath, fileName: "", type: MediaType.image)
        ]);

    onSend(chatMessage);
  }

  Future<String?> _showImageEditSheet({required String originalPath}) async {
    // Keep web behavior simple (image_cropper web setup varies by project).
    if (kIsWeb) return originalPath;

    String currentPath = originalPath;

    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Edit image",
                          style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: "Close",
                          onPressed: () => Navigator.of(context).pop(null),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.file(
                          File(currentPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final cropped = await _cropImage(currentPath);
                              if (cropped == null) return;
                              setSheetState(() {
                                currentPath = cropped;
                              });
                            },
                            icon: const Icon(Icons.tune),
                            label: const Text("Edit"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(currentPath),
                            icon: const Icon(Icons.send),
                            label: const Text("Send"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _cropImage(String path) async {
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Edit image',
          ),
        ],
      );
      return cropped?.path;
    } catch (_) {
      return null;
    }
  }
}
