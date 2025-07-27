import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionManagement {
  static Future<bool> requestStoragePermission() async {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;

    // Map<Permission, PermissionStatus> status =
    //     await [Permission.storage].request();
    var status = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;

    return status.isGranted;
  }

  static Future<bool> recordingPermission() async {
    var status = await Permission.microphone.status;

    if (status.isDenied || status.isRestricted) {
      status = await Permission.microphone.request();
    }

    if (status.isPermanentlyDenied) {
      // Optionally, open app settings
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }
}
