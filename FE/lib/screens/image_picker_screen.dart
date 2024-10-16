// screens/image_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:SmartPoopoo/common_widgets.dart';
import 'package:SmartPoopoo/services/chatgpt_service.dart';
import 'package:flutter_tts/flutter_tts.dart'; // TTS 패키지 import
import 'package:SmartPoopoo/screens/chat_bot_screen.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  ImagePickerScreenState createState() => ImagePickerScreenState();
}

class ImagePickerScreenState extends State<ImagePickerScreen> {
  final ChatGptService _chatGptService = ChatGptService();
  final FlutterTts flutterTts = FlutterTts(); // TTS 인스턴스 생성

  List<String> imageUrls = [
    'https://www.nct.org.uk/sites/default/files/3to4.jpg',
    'https://assets.babycenter.com/ims/2009/09sep/poo01_424x302.jpg'
  ];
  String? selectedImageUrl;
  String? imageDescription;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
        ],
        IosTextToSpeechAudioMode.defaultMode);
    await flutterTts.setSharedInstance(true);
  }

  Future<void> _fetchImageDescription(String imageUrl) async {
    try {
      final description = await _chatGptService.fetchImageDescription(imageUrl);
      setState(() {
        imageDescription = description;
      });
    } catch (e) {
      print('Failed to fetch image description: $e');
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("ko-KR"); // 한국어로 설정
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이미지 선택'),
        leading: Semantics(
          label: '뒤로가기', // 톡백이 "뒤로가기"라고 읽음
          button: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back), // 기본 뒤로가기 아이콘
            onPressed: () {
              Navigator.pop(context); // 뒤로가기 기능
            },
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                final imageUrl = imageUrls[index];
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      selectedImageUrl = imageUrl;
                      imageDescription = null; // 설명 초기화
                    });
                    await _fetchImageDescription(imageUrl);
                  },
                  child: Semantics(
                    label: ' 이미지 순서 ${index + 1}',
                    child: Image.network(imageUrl),
                  ),
                );
              },
            ),
          ),
          if (imageDescription != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    imageDescription!,
                    style:
                        const TextStyle(fontSize: 20, fontFamily: "Pretendard"),
                  ),
                  const SizedBox(height: 16),
                  // "설명듣기" 버튼
                  buildMenuButton(
                    context,
                    "설명듣기",
                    () {
                      _speak(imageDescription!); // 설명을 TTS로 읽기
                    },
                    "설명듣기 버튼",
                  ),
                  const SizedBox(height: 16),
                  // "후속 질문하기" 버튼
                  buildMenuButton(
                    context,
                    "후속 질문하기",
                    () {
                      if (imageDescription != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatBotScreen(
                              analysisResult: imageDescription!, // 분석된 내용을 전달
                            ),
                          ),
                        );
                      }
                    },
                    "후속 질문하기 버튼",
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
