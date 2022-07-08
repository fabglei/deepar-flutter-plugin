import 'dart:io';
import 'dart:math';
import 'package:deep_ar/deep_ar_platform_handler.dart';
import 'package:deep_ar/resolution_preset.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DeepArController {
  DeepArController() : super();
  final DeepArPlatformHandler _deepArPlatformHandler = DeepArPlatformHandler();
  int? textureId;
  double? height;
  double? width;
  double _aspectRatio = 1.0;
  late Resolution resolution;

  bool get isInitialized => textureId != null;
  bool isPermission = false;
  double get aspectRatio => _aspectRatio;

  Future<void> initialize(
      {required String licenseKey, required Resolution preset}) async {
    resolution = preset;
    isPermission = await _deepArPlatformHandler.checkAllPermission() ?? false;
    if (isPermission) {
      String? dimensions =
          await _deepArPlatformHandler.initialize(licenseKey, preset);
      if (dimensions != null) {
        width = double.parse(dimensions.split(" ")[0]);
        height = double.parse(dimensions.split(" ")[1]);
        _aspectRatio = width! / height!;
        textureId = await _deepArPlatformHandler.startCamera();
      }
    }
  }

  Widget buildPreview() {
    return Texture(textureId: textureId!);
  }

  Future<String?> switchEffect(int effect) {
    return _deepArPlatformHandler.switchEffect(effect);
  }

  Future<void> startVideoRecording() async {
    Directory dir = Directory('/storage/emulated/0/Download');
    var r = Random();

    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    // Radom filename for now
    String fileName =
        List.generate(5, (index) => _chars[r.nextInt(_chars.length)]).join();
    final File file = File('${dir.path}/$fileName.mp4');
    await file.create();
    _deepArPlatformHandler.startRecordingVideo(file.path);
  }

  void stopVideoRecording() {
    _deepArPlatformHandler.stopRecordingVideo();
  }

  Future<String?> checkVersion() {
    return _deepArPlatformHandler.checkVersion();
  }

  void createSurface() async {
    textureId = await _deepArPlatformHandler.createSurface();
    print("TEXTURE_ID : $textureId");
  }
}
