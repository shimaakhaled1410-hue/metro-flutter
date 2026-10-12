import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  static void show({
    required String title,
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
    TextButton? mainButton,
  }) {
    Get.closeCurrentSnackbar();

    Color accentColor;
    IconData iconData;

    switch (type) {
      case SnackbarType.success:
        accentColor = const Color(0xFF4CAF50);
        iconData = Icons.check_circle_rounded;
        break;
      case SnackbarType.error:
        accentColor = const Color(0xFFE53935);
        iconData = Icons.error_rounded;
        break;
      case SnackbarType.warning:
        accentColor = const Color(0xFFFFA000);
        iconData = Icons.warning_rounded;
        break;
      case SnackbarType.info:
        accentColor = const Color(0xFF1976D2);
        iconData = Icons.info_rounded;
        break;
    }

    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E1E1E),
      borderRadius: 14,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      duration: duration,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      icon: Icon(iconData, color: accentColor, size: 28),
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 12,
        ),
      ),
      mainButton: mainButton,
    );
  }

  static void showWithUndo({
    required String title,
    required String message,
    required VoidCallback onUndo,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      title: title,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          onUndo();
        },
        child: Text(
          'undo'.tr,
          style: const TextStyle(
            color: Color(0xFFFFB300),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  static void success({required String title, required String message}) {
    show(title: title, message: message, type: SnackbarType.success);
  }

  static void error({required String title, required String message}) {
    show(title: title, message: message, type: SnackbarType.error);
  }

  static void warning({required String title, required String message}) {
    show(title: title, message: message, type: SnackbarType.warning);
  }
}