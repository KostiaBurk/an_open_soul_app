import 'package:flutter_sound/flutter_sound.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:developer'; // <-- Добавляем импорт для логирования

class AudioRecorder {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false; 
  String? _audioPath;

  bool get isRecording => _isRecording;  

  AudioRecorder() {
    _recorder = FlutterSoundRecorder();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    try {
      await _recorder!.openRecorder();
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw Exception("Microphone permission not granted");
      }
    } catch (e) {
      log("Error initializing recorder: $e"); // <-- Используем log вместо print
    }
  }

  Future<void> startRecording() async {
    try {
      final directory = Directory.systemTemp.path;
      _audioPath = '$directory/${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder!.startRecorder(toFile: _audioPath);
      _isRecording = true;
      log("Recording started..."); // <-- Используем log вместо print
    } catch (e) {
      log("Error starting recording: $e");
    }
  }

  Future<String?> stopRecording() async {
    try {
      await _recorder!.stopRecorder();
      _isRecording = false;
      log("Recording stopped...");
      return _uploadAudio();
    } catch (e) {
      log("Error stopping recording: $e");
      return null;
    }
  }

  Future<String?> _uploadAudio() async {
    if (_audioPath == null) return null;
    try {
      File file = File(_audioPath!);
      String fileName = 'diary_audio/${DateTime.now().millisecondsSinceEpoch}.aac';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      log("Audio uploaded: $downloadUrl"); // <-- Используем log вместо print
      return downloadUrl;
    } catch (e) {
      log("Error uploading audio: $e");
      return null;
    }
  }
}
