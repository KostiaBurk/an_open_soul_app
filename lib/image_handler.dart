import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

Future<List<File>?> pickImages() async {
  final ImagePicker picker = ImagePicker();
  final List<XFile> pickedFiles = await picker.pickMultiImage();

  if (pickedFiles.isEmpty) {  // Убрали проверку на null
    return null;
  }

  List<File> compressedImages = [];

  for (XFile file in pickedFiles) {
    File compressedFile = await compressImage(File(file.path));
    compressedImages.add(compressedFile);
  }

  return compressedImages;
}


Future<File> compressImage(File file) async {
  final targetPath = "${file.path}_compressed.jpg";
  
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 85, // Сжатие до 85% качества
  );

  return File(result?.path ?? file.path);
}
