import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

class StorageManagement {
  static Future<String> makeDirectory({required String dirName}) async {
    final Directory? directory = await getExternalStorageDirectory();

    final _formattedDirName = '/$dirName/';

    final Directory _newDir =
        await Directory(directory!.path + _formattedDirName).create();

    return _newDir.path;
  }

  static get getAudioDir async =>
      await makeDirectory(dirName: 'microphonerecordings');

  static String createRecordAudioPath(
          {required String dirPath, required String fileName}) =>
      """$dirPath${fileName.substring(0, min(fileName.length, 100))}_${DateTime.now()}.aac""";
}
// class StorageManagement {
//   static Future<String> makeDirectory({required String dirName}) async {
//     final Directory? directory = await getExternalStorageDirectory();
//
//     final _formattedDirName = '/$dirName/';
//
//     final Directory _newDir =
//         await Directory(directory!.path + _formattedDirName).create();
//
//     return _newDir.path;
//   }
//
//   static Future<String> get getAudioDir async {
//     final String _appDirectory =
//         (await getApplicationDocumentsDirectory()).path;
//     const String _audioDirectory = 'finalmicrophone';
//     final Directory _audioDir = Directory('$_appDirectory/$_audioDirectory');
//     if (!await _audioDir.exists()) {
//       await _audioDir.create(recursive: true);
//     }
//     return _audioDir.path;
//   }
//
//   static String createRecordAudioPath(
//           {required String dirPath, required String fileName}) =>
//       "$dirPath${fileName.substring(0, fileName.length < 100 ? fileName.length : 100)}_${DateTime.now().toString().replaceAll(' ', '').replaceAll(':', '').replaceAll('.', '')}.aac";
// }
