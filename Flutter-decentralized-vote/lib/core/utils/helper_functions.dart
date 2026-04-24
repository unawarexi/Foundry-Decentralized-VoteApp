import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class THelperFunctions {
  // Helper function to get a color based on string input
  static Color? getColor(String value) {
    switch (value.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'grey':
        return Colors.grey;
      case 'brown':
        return Colors.brown;
      default:
        return Colors.transparent; // Fallback color if none match
    }
  }


  // Helper function to format currency
  static String formatCurrency(double amount, String locale) {
    final formatter = NumberFormat.currency(locale: locale);
    return formatter.format(amount);
  }

  // Helper function for formatting date
  static String formatDate(DateTime date, String locale) {
    final formatter = DateFormat.yMMMMd(locale);
    return formatter.format(date);
  }

  // Custom Snackbar using GetX
  // static void customSnackbar(
  //   String title,
  //   String message, {
  //   bool isError = false,
  // }) {
  //   Get.snackbar(
  //     title,
  //     message,
  //     snackPosition: SnackPosition.BOTTOM,
  //     backgroundColor: isError ? Colors.red : Colors.green,
  //     colorText: Colors.white,
  //     margin: const EdgeInsets.all(10),
  //   );
  // } 

  // Show custom alert dialog
  static void showAlert(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                if (onConfirm != null) {
                  onConfirm();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Navigate to another screen using GetX
  // static void navigateToScreen(Widget screen) {
  //   Get.to(() => screen);
  // }

  // Truncate text to a given length
  static String truncateText(String text, int length) {
    return text.length > length ? '${text.substring(0, length)}...' : text;
  }

  // Check if dark mode is enabled
  static bool isDarkMode(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  // Get screen size
  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  // Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Remove duplicates from a list
  static List<T> removeDuplicates<T>(List<T> items) {
    return items.toSet().toList();
  }

  // Wrap a list of widgets
  static List<Widget> wrapWidgets(List<Widget> widgets) {
    return widgets
        .map(
          (widget) =>
              Padding(padding: const EdgeInsets.all(8.0), child: widget),
        )
        .toList();
  }
}
