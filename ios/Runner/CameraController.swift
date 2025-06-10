import AVFoundation
import UIKit

class CameraController: NSObject {

   func mergeVideos(from urls: [URL], completion: @escaping (URL?) -> Void) {
    let mixComposition = AVMutableComposition()
    var currentTime = CMTime.zero
    var instructions: [AVMutableVideoCompositionInstruction] = []
    var renderSize = CGSize(width: 1080, height: 1920) // Стандартный размер

    for url in urls {
        let asset = AVAsset(url: url)
        guard let assetVideoTrack = asset.tracks(withMediaType: .video).first else { continue }
        guard let assetAudioTrack = asset.tracks(withMediaType: .audio).first else { continue }

        // Создание дорожек
        guard let videoTrack = mixComposition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: kCMPersistentTrackID_Invalid
              ),
              let audioTrack = mixComposition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
              ) else { continue }

        do {
            // Вставка видеотрека
            try videoTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: asset.duration),
                of: assetVideoTrack,
                at: currentTime
            )

            // Вставка аудиотрека
            try audioTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: asset.duration),
                of: assetAudioTrack,
                at: currentTime
            )

            // Инструкции для корректного отображения сегмента
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: currentTime, duration: asset.duration)

            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)

            // Корректируем ориентацию (важно!)
            let transform = assetVideoTrack.preferredTransform
            layerInstruction.setTransform(transform, at: currentTime)

            instruction.layerInstructions = [layerInstruction]
            instructions.append(instruction)

            currentTime = CMTimeAdd(currentTime, asset.duration)

            // Устанавливаем размер из первого видео (самый правильный подход)
            if urls.first == url {
                renderSize = assetVideoTrack.naturalSize.applying(transform)
                renderSize = CGSize(width: abs(renderSize.width), height: abs(renderSize.height))
            }

        } catch {
            print("Ошибка вставки сегмента: \(error.localizedDescription)")
            completion(nil)
            return
        }
    }

    // Итоговая видеокомпозиция с правильной ориентацией и размерами
    let mainComposition = AVMutableVideoComposition()
    mainComposition.instructions = instructions
    mainComposition.frameDuration = CMTime(value: 1, timescale: 30) // 30 fps
    mainComposition.renderSize = renderSize

    // Экспорт видео
       guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetPassthrough) else {

        completion(nil)
        return
    }

    let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "mergedVideo.mp4")
    try? FileManager.default.removeItem(at: outputURL)

    exporter.outputURL = outputURL
    exporter.outputFileType = .mp4
    exporter.shouldOptimizeForNetworkUse = true
    exporter.videoComposition = mainComposition // ключевой момент!

    exporter.exportAsynchronously {
        DispatchQueue.main.async {
            if exporter.status == .completed {
                completion(outputURL)
            } else {
                print("Ошибка экспорта: \(exporter.error?.localizedDescription ?? "unknown error")")
                completion(nil)
            }
        }
    }
}


    enum VideoOrientation {
        case up, down, left, right, upMirrored, downMirrored, leftMirrored, rightMirrored
    }

    func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: VideoOrientation, isPortrait: Bool) {
        var assetOrientation = VideoOrientation.up
        var isPortrait = false

        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        }
        if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        }
        if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        }
        if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .upMirrored
        }
        if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .downMirrored
        }
        if transform.a == 0 && transform.b == -1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .leftMirrored
            isPortrait = true
        }
        if transform.a == 0 && transform.b == 1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .rightMirrored
            isPortrait = true
        }

        return (assetOrientation, isPortrait)
    }
}
