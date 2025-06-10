//import 'package:an_open_soul_app/widgets/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:an_open_soul_app/native/camera_merge_channel.dart';
import 'dart:math' as math;


//import 'dart:convert'; // Добавляем импорт
//import 'package:logger/logger.dart';
//final Logger _logger = Logger();

//import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';





class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function(XFile file) onMediaCaptured;
  final String userName; // ✅ Добавляем userName
   final bool isViewingSentMedia; // ✅ Новый параметр
   
   
   
  

  const CameraScreen({
  super.key,
  required this.cameras,
  required this.onMediaCaptured,
  this.userName = "Unknown", // ✅ Устанавливаем значение по умолчанию
  this.isViewingSentMedia = false, // ✅ По умолчанию это камера, а не просмотр видео
 

});



  @override
  CameraScreenState createState() => CameraScreenState();
}
double _dragOffset = 0.0; // ⬅ Переменная для анимации свайпа вниз
bool _isPreviewMode = true; // ✅ Добавляем переменную (true = предпросмотр, false = видео из чата)
class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  bool _isVideoMode = false;
  bool _isRecording = false;
  bool _isProcessingVideo = false;

  XFile? _capturedFile;
  int _recordingTime = 0;
  Timer? _timer;
  final GlobalKey _cameraPreviewKey = GlobalKey();
  bool _isFrontCamera = false; // ✅ Флаг для отслеживания камеры
  List<XFile> videoSegments = []; // список всех фрагментов
  //double _lastDx = 0.5;
//double _lastDy = 0.5;


  // ignore: prefer_final_fields
  
  

  
  
  
  

  VideoPlayerController? _videoController;
  
bool _showFocusIndicator = false;
//Offset? _focusIndicatorPosition; // для анимации
Offset? _focusPoint;




  bool _isCapturedFileVideo() {
  return _capturedFile != null && _capturedFile!.path.toLowerCase().endsWith('.mp4');
}

  

@override
void initState() {
  super.initState();

  // Если isViewingSentMedia == false, инициализируем камеру
  if (!widget.isViewingSentMedia && widget.cameras.isNotEmpty) {
    _initializeCamera(widget.cameras.first);
  }

  // Если мы просматриваем отправленное видео, отключаем предпросмотр
  _isPreviewMode = !widget.isViewingSentMedia;
}






@override
void dispose() {
  // ✅ Проверяем перед удалением, чтобы избежать ошибки
  if (_isCameraInitialized) {
  _controller.dispose();
}

  _timer?.cancel();
  _videoController?.dispose();
  super.dispose();
}




Future<void> _initializeCamera(CameraDescription camera) async {
  _controller = CameraController(
    camera,
    ResolutionPreset.veryHigh, // Use high resolution for better quality
    enableAudio: true,
  );

  try {
    await _controller.initialize();

    // Enable autofocus and autoexposure
    await _controller.setFocusMode(FocusMode.auto);
    await _controller.setExposureMode(ExposureMode.auto);

    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
  } catch (e) {
    debugPrint('Camera initialization error: $e');
  }
}

Future<void> _switchCamera() async {
  if (widget.cameras.length < 2) {
    debugPrint("❌ Вторая камера не найдена");
    return;
  }

  bool wasRecording = _isRecording;

  if (wasRecording) {
    try {
      XFile segment = await _controller.stopVideoRecording();
      debugPrint("✅ Видео сегмент сохранён перед переключением камеры: ${segment.path}");

      final fileExists = await File(segment.path).exists();
      final fileSize = await File(segment.path).length();
      debugPrint("🧪 Сегмент существует: $fileExists, размер: $fileSize байт");

      if (fileExists && fileSize > 0) {
        videoSegments.add(segment);
      } else {
        debugPrint("⚠️ Пропускаем битый сегмент: ${segment.path}");
      }
    } catch (e) {
      debugPrint("❌ Ошибка при остановке записи перед переключением камеры: $e");
    }
  }

  try {
    CameraDescription newCamera = _isFrontCamera
        ? widget.cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => widget.cameras.first,
          )
        : widget.cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => widget.cameras.last,
          );

    setState(() {
      _isCameraInitialized = false; // Временно отключаем предпросмотр
      _isFrontCamera = !_isFrontCamera;
    });

    debugPrint("🔁 Переключение на: ${newCamera.lensDirection}");

    await _controller.dispose();
    await _initializeCamera(newCamera);
    await Future.delayed(const Duration(milliseconds: 500));
    

    if (wasRecording) {
      await _continueRecording();
    }
  } catch (e) {
    debugPrint("❌ Ошибка при переключении камеры: $e");
  }
}



Future<void> _continueRecording() async {
  if (!_controller.value.isInitialized) {
    debugPrint("❌ Камера не инициализирована. Невозможно продолжить запись.");
    return;
  }

  try {
    debugPrint("Продолжаем запись на новой камере...");
    await _controller.startVideoRecording();
    setState(() {
      _isRecording = true;
    });
    debugPrint("✅ Запись продолжается.");
  } catch (e) {
    debugPrint("❌ Ошибка при продолжении записи: $e");
  }
}




void _setFocusOnTap(TapUpDetails details) async {
  if (!_controller.value.isInitialized) return;

  // Получаем RenderBox превью камеры
  final RenderBox box = _cameraPreviewKey.currentContext!.findRenderObject() as RenderBox;
  final Offset localPosition = box.globalToLocal(details.globalPosition);
  final Size previewSize = box.size;

  final double dx = localPosition.dx / previewSize.width;
  final double dy = localPosition.dy / previewSize.height;

  final adjustedDx = dx.clamp(0.0, 1.0);
  final adjustedDy = dy.clamp(0.0, 1.0);

  try {
    await _controller.setFocusPoint(Offset(adjustedDx, adjustedDy));
    await _controller.setExposurePoint(Offset(adjustedDx, adjustedDy));
  } catch (e) {
    debugPrint("❌ Ошибка фокуса: $e");
  }

  // Сохраняем глобальные координаты (для Positioned)
  setState(() {
    _focusPoint = details.globalPosition;
    _showFocusIndicator = true;
  });

  Future.delayed(const Duration(seconds: 1), () {
    if (mounted) {
      setState(() {
        _showFocusIndicator = false;
      });
    }
  });

  debugPrint("📍Фокус установлен на: dx=$adjustedDx, dy=$adjustedDy");
}













Future<void> _captureMedia() async {
  if (!_controller.value.isInitialized) return;

  if (_isRecording && _isVideoMode) {
    try {
      // ⏹ Останавливаем запись
      XFile segment = await _controller.stopVideoRecording();
      debugPrint("✅ Видео сегмент сохранён: ${segment.path}");

      // 🕒 Подстраховка: ждём, чтобы система точно сохранила файл
      await Future.delayed(const Duration(milliseconds: 300));

      // 🧪 Проверка на существование и размер
      final exists = await File(segment.path).exists();
      final size = await File(segment.path).length();
      debugPrint("🧪 Проверка сегмента: существует=$exists, размер=$size байт");


      if (exists && size > 0) {
        videoSegments.add(segment); // ✅ добавляем последний сегмент
      } else {
        debugPrint("⚠️ Последний сегмент битый или пустой, не добавлен в склейку.");
      }

      _stopTimer();

setState(() {
  _isProcessingVideo = true;
});

      // 📤 Отправляем на склейку
      final mergedPaths = videoSegments.map((f) => f.path).toList();
      debugPrint("📤 Отправляем на склейку: $mergedPaths");

      try {
        final mergedPath = await CameraMergeChannel.mergeVideos(mergedPaths);

        if (mergedPath != null) {
          final cleanPath = mergedPath.replaceFirst('file://', '');
          debugPrint("🎬 Объединённое видео сохранено: $cleanPath");

          setState(() {
            _isRecording = false;
            _capturedFile = XFile(cleanPath);
            _isProcessingVideo = false; // ✅ скрываем индикатор
          });

          _initializeVideoPlayer(_capturedFile!);
        }
      } catch (e) {
        debugPrint("❌ Ошибка при объединении видео: $e");
      }

      videoSegments.clear(); // 🔄 очищаем список после склейки
    } catch (e) {
      debugPrint("❌ Ошибка при остановке видео: $e");
    }
    return;
  }

  try {
    if (_isVideoMode) {
      debugPrint("▶️ Начинаем запись видео...");
      await _controller.startVideoRecording();
      _startTimer();
      setState(() {
        _isRecording = true;
      });
    } else {
      debugPrint("📸 Делаем фото...");
      XFile file = await _controller.takePicture();
      debugPrint("✅ Фото сохранено: ${file.path}");

      setState(() {
        _capturedFile = file;
      });

      _initializeVideoPlayer(_capturedFile!);
    }
  } catch (e) {
    debugPrint("❌ Ошибка при записи: $e");
  }
}









void _initializeVideoPlayer(XFile file) {
  _videoController = VideoPlayerController.file(File(file.path))
    ..initialize().then((_) {
      _videoController!.setPlaybackSpeed(1.0); // Normal playback speed
      _videoController!.setLooping(true); // Loop video for smooth playback
      setState(() {}); // Update the UI
    });
}


  void _startTimer() {
    _recordingTime = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingTime++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

void _sendMedia() async {
  if (_capturedFile != null) {
    final mediaPath = _capturedFile!.path;
    debugPrint("Отправка медиафайла: $mediaPath");

    if (mounted) {
      widget.onMediaCaptured(XFile(mediaPath)); // ✅ Передаём файл

      setState(() {
        _isPreviewMode = false; // ✅ Теперь кнопки "Retake" и "Send" исчезнут
      });

      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          debugPrint(" Navigator.pop() пропущен, так как стек пуст.");
        }
      });
    }
  } else {
    debugPrint(" Captured file is null. Nothing to send.");
  }
}





void _closeAndReturnToChat() {
  setState(() {
    _dragOffset = 0.0; // ⬅ Сбрасываем свайп перед закрытием
    _capturedFile = null;
    _videoController?.dispose();
    _videoController = null;
  });

  // ✅ Анимация перед закрытием
  Future.delayed(const Duration(milliseconds: 200), () {
    if (mounted && Navigator.canPop(context)) { // ✅ Добавили mounted
      Navigator.pop(context);
    } else {
      debugPrint(" Navigator.pop() пропущен, так как экран уже закрыт.");
    }
  });
}










  void _retakeMedia() {
    setState(() {
      _capturedFile = null;
      _videoController?.dispose();
      _videoController = null;
    });
  }

 
@override
Widget build(BuildContext context) {
  final deviceSize = MediaQuery.of(context).size;

  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 8, 8, 8),
    body: Stack(
      children: [
        if (_isCameraInitialized && _capturedFile == null && !widget.isViewingSentMedia)
          Center(
            child: GestureDetector(
              onTapUp: _setFocusOnTap,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.67,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.previewSize!.height,
                          height: _controller.value.previewSize!.width,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: _isFrontCamera
                                ? (Matrix4.identity()..rotateY(math.pi))
                                : Matrix4.identity(),
                            child: CameraPreview(
                              _controller,
                              key: _cameraPreviewKey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_showFocusIndicator && _focusPoint != null)
                    Positioned(
                      left: _focusPoint!.dx - 25,
                      top: _focusPoint!.dy - 25,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _showFocusIndicator ? 1.0 : 0.0,
                        child: AnimatedScale(
                          scale: 1.2,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.yellow, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

        if (_capturedFile != null && !_isCapturedFileVideo())
          Positioned.fill(
            child: Center(
              child: Image.file(
                File(_capturedFile!.path),
                fit: BoxFit.cover,
                width: deviceSize.width,
                height: deviceSize.height * 0.7,
              ),
            ),
          ),

        if (_capturedFile != null && _isCapturedFileVideo())
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (_videoController != null && _videoController!.value.isInitialized) {
                  setState(() {
                    _videoController!.value.isPlaying
                        ? _videoController!.pause()
                        : _videoController!.play();
                  });
                }
              },
              onVerticalDragUpdate: (details) {
                setState(() {
                  _dragOffset += details.primaryDelta!;
                });
              },
              onVerticalDragEnd: (details) {
                if (_dragOffset > 150) {
                  _closeAndReturnToChat();
                } else {
                  setState(() {
                    _dragOffset = 0.0;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(0, _dragOffset, 0),
                child: Center(
                  child: ClipRect(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _videoController!.value.size.width,
                                height: _videoController!.value.size.height,
                                child: VideoPlayer(_videoController!),

                              ),
                            ),
                          ),
                        ),
                        if (_videoController != null && !_videoController!.value.isPlaying)
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                            child: Icon(
                              Icons.play_circle_fill,
                              size: 80,
                              color: Colors.white.withAlpha(204),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        if (_isPreviewMode && !widget.isViewingSentMedia)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: _capturedFile != null && _isCapturedFileVideo()
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _retakeMedia,
                        child: const Text("Retake"),
                      ),
                      ElevatedButton(
                        onPressed: _sendMedia,
                        child: const Text("Send"),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),

        Positioned(
          top: 50,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              if (_isRecording)
                Text(
                  '$_recordingTime s',
                  style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              IconButton(
                icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 28),
                onPressed: _switchCamera,
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: _capturedFile == null
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isVideoMode = false),
                          child: Text(
                            'Photo',
                            style: TextStyle(
                              color: !_isVideoMode ? Colors.white : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => setState(() => _isVideoMode = true),
                          child: Text(
                            'Video',
                            style: TextStyle(
                              color: _isVideoMode ? Colors.white : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _captureMedia,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: _isVideoMode ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _retakeMedia,
                      child: const Text("Retake"),
                    ),
                    ElevatedButton(
                      onPressed: _sendMedia,
                      child: const Text("Send"),
                    ),
                  ],
                ),
        ),

        // 🌀 СПИННЕР НА ВЕСЬ ЭКРАН ПРИ ОБРАБОТКЕ ВИДЕО
        if (_isProcessingVideo)
          Positioned.fill(
            child: Container(
              color: Color.fromRGBO(0, 0, 0, 0.5),

              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 4,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
}