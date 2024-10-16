// lib/common_widgets.dart
import 'package:flutter/material.dart';

/// Menu Button 위젯
Widget buildMenuButton(BuildContext context, String title,
    VoidCallback onPressed, String semanticsLabel) {
  return Semantics(
    label: semanticsLabel,
    button: true,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF445DF6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        minimumSize: const Size(200, 60),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: "Pretendard",
          color: Colors.white,
          fontSize: 41,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

/// LoaderState 위젯 (CircularProgressIndicator 사용)
class LoaderState extends StatelessWidget {
  const LoaderState({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 20,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF0000FF),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            // CircularProgressIndicator 사용
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 5.0,
          ),
        ),
      ),
    );
  }
}
