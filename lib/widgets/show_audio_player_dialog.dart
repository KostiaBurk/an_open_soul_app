import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:an_open_soul_app/widgets/audio_wave_visualizer.dart';

Future<void> showAudioPlayerDialog({
  required BuildContext context,
  required AudioPlayer audioPlayer,
  required String url,
}) async {
  if (!context.mounted) return;

  final navigator = Navigator.of(context);
  final mediaQuery = MediaQuery.of(context);

  bool isDialogOpen = true;

  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = false;

  StreamSubscription? positionSub;
  StreamSubscription? durationSub;
  StreamSubscription? completeSub;

  // Останавливаем и запускаем аудиоплеер
  await audioPlayer.stop();
  await audioPlayer.play(UrlSource(url));

  // Инициализируем duration и position на старте
  position = await audioPlayer.getCurrentPosition() ?? Duration.zero;
  duration = await audioPlayer.getDuration() ?? Duration.zero;

  // Устанавливаем isPlaying в true, потому что аудио начало воспроизводиться
  isPlaying = true;

  if (!context.mounted) return;

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Playing Audio',
    barrierColor: Colors.black.withAlpha(120),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return StatefulBuilder(
        builder: (context, setState) {
          positionSub ??= audioPlayer.onPositionChanged.listen((pos) {
            if (!isDialogOpen || !context.mounted) return;
            setState(() => position = pos);
          });

          durationSub ??= audioPlayer.onDurationChanged.listen((dur) {
            if (!isDialogOpen || !context.mounted) return;
            setState(() => duration = dur);
          });

          completeSub ??= audioPlayer.onPlayerComplete.listen((_) {
            if (!isDialogOpen || !context.mounted) return;
            setState(() {
              isPlaying = false;  // После завершения воспроизведения, меняем кнопку на Play
              position = duration; // Устанавливаем позицию на конец
            });
          });

          return Center(
            child: Container(
              width: mediaQuery.size.width * 0.85,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E24AA), Color(0xFFF3D9FF), Color(0xFF80DEEA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.25 * 255).toInt()),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Playing audio...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const AudioWaveVisualizer(),
                    const SizedBox(height: 20),
                    Slider(
                      activeColor: Colors.white,
                      inactiveColor: Colors.white54,
                      min: 0,
                      max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                      value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
                      onChanged: (value) {
                        final newPos = Duration(milliseconds: value.toInt());
                        audioPlayer.seek(newPos);
                      },
                    ),
                    // Изменили цвет текста на красный
                    Text(
                      "${_formatDuration(position)} / ${_formatDuration(duration)}",
                      style: const TextStyle(color: Colors.red),  // Меняем цвет текста на красный
                    ),
                    const SizedBox(height: 16),
                    IconButton(
                      iconSize: 40,
                      color: Colors.white,
                      icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
                      onPressed: () {
                        if (isPlaying) {
                          audioPlayer.pause();
                          setState(() {
                            isPlaying = false;  // При паузе кнопка должна быть Play
                          });
                        } else {
                          audioPlayer.resume();
                          setState(() {
                            isPlaying = true;  // При возобновлении кнопка должна быть Pause
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        isDialogOpen = false;
                        audioPlayer.stop(); // Останавливаем аудио перед закрытием диалога
                        navigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF8E24AA),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
    transitionBuilder: (context, animation, _, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
        child: child,
      );
    },
  );

  isDialogOpen = false;

  // Отмена подписок на события
  await positionSub?.cancel();
  await durationSub?.cancel();
  await completeSub?.cancel();
}

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}
