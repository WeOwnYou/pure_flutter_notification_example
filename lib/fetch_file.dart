import 'package:flutter/services.dart';

Future<String> fetchFileFromAssets(String assetsPath) async {
  await Future.delayed(
    const Duration(seconds: 1),
  );
  return rootBundle.loadString(assetsPath).then((file) => file);
}
