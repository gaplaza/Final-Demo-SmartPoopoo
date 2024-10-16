import 'package:SmartPoopoo/screens/frame_detection_screen.dart';
import 'package:flutter/material.dart';
import 'package:SmartPoopoo/common_widgets.dart';
import 'package:SmartPoopoo/screens/image_picker_screen.dart';
import 'package:SmartPoopoo/screens/image_detection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData(
        fontFamily: "Pretendard",
        primaryColor: const Color(0xFF445DF6),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? selectedImageUrl;
  String defaultImageUrl =
      'https://www.nct.org.uk/sites/default/files/3to4.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100), // AppBar의 높이를 150으로 설정
          child: AppBar(
            title: Semantics(
              label: '당신의 스마트푸푸입니다. 아래에서 원하는 서비스를 선택하세요.',
              child: const ExcludeSemantics(
                child: Padding(
                  padding: EdgeInsets.only(top: 10), // 위쪽에 20px 패딩 추가
                  child: Text(
                    '스마트푸푸',
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        body: Semantics(
          label: '화면에 총 3개의 버튼이 있습니다. 각각 실시간 탐지, 앨범에서 가져오기, 이미지 탐지입니다.',
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    children: [
                      // 첫 번째 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 140, // 버튼 높이 조정
                        child: buildMenuButton(context, "실시간 탐지", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ImageDetectionScreen(
                                  title: 'Object Detection'),
                            ),
                          );
                        }, "실시간 탐지 버튼"),
                      ),

                      // 두 버튼 사이의 간격을 추가
                      const SizedBox(height: 10),

                      // 두 번째 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 140, // 버튼 높이 조정
                        child: buildMenuButton(context, "앨범에서 가져오기", () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ImagePickerScreen(),
                            ),
                          );

                          if (result != null && result is String) {
                            setState(() {
                              selectedImageUrl = result;
                            });
                          }
                        }, "앨범에서 가져오기 버튼"),
                      ),

                      // 두 버튼 사이의 간격을 추가
                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 140, // 버튼 높이 조정
                        child: buildMenuButton(context, "이미지 탐지", () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FrameDetectionScreen(),
                            ),
                          );

                          if (result != null && result is String) {
                            setState(() {
                              selectedImageUrl = result;
                            });
                          }
                        }, "이미지 탐지 버튼"),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
