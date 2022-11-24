import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _file = await _imagePicker.pickImage(source: source);

  if (_file != null) {
    return await _file.readAsBytes();
  }
  print('No image selected');
}

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

Widget LoadingView(BuildContext context) {
  const themeColor = Color(0xfff5a623);
  return Container(
    color: Colors.white.withOpacity(0.8),
    child: CircularProgressIndicator(
      color: themeColor.withOpacity(0.2),
    ),
  );
}

