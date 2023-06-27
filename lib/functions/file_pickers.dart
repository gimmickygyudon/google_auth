// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<PlatformFile?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'pdf', 'doc', 'png', 'jpeg']
  );

  if (result != null) {
    File file = File(result.files.single.path!);
    PlatformFile fileDescription = result.files.first;

    return fileDescription;
  } else {
    // print("No file selected");
    return null;
  }
}

Future <List<PlatformFile?>> pickFiles() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: ['jpg', 'pdf', 'doc', 'png', 'jpeg']
  );

  if (result != null) {
    List<File> files = result.paths.map((path) => File(path!)).toList();
    List<PlatformFile> fileDescription = result.files;

    return fileDescription;
  } else {
    // print("No file selected");
    return List.empty();
  }
}