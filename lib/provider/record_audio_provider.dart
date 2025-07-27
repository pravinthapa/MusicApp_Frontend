import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:record/record.dart';
import 'package:finalmicrophone/services/storage_management.dart';
import 'package:finalmicrophone/services/permission_management.dart';
import 'package:finalmicrophone/services/toast_services.dart';
import 'package:file_picker/file_picker.dart';

enum IPLocation { mobileHotspot, riyanshWifi, NDMwifi }

class RecordAudioProvider extends ChangeNotifier {
  final BuildContext context;

  RecordAudioProvider(this.context);

  IPLocation _ipLocation = IPLocation.riyanshWifi;

  IPLocation get ipLocation => _ipLocation;
  String _ipaddress = 'http://192.168.0.103:90/upload-audio';
  get ipaddress => _ipaddress;

  mobilehotspot() {
    _ipLocation = IPLocation.mobileHotspot;
    _ipaddress = 'http://192.168.165.13:90/upload-audio';
    notifyListeners();
  }

  riyanshwifi() {
    _ipLocation = IPLocation.riyanshWifi;
    _ipaddress = 'http://192.168.0.103:90/upload-audio';
    notifyListeners();
  }

  NDMwifi() {
    _ipLocation = IPLocation.NDMwifi;
    _ipaddress = 'http://192.168.254.14:19/uPpload-audio';
    notifyListeners();
  }

  bool _connectionfail = false;
  bool _uploadStatus = false;
  get uploadStatus => _uploadStatus;

  get connectionfail => _connectionfail;
  Duration? _responseTime;
  bool _keepLoading = false;

  get keepLoading => _keepLoading;

  get responseTime => _responseTime;

  void toggleLoading() {
    _keepLoading = true;
  }

  Map<String, dynamic> _song = {
    'name': 'Example Song',
    'indices': '0000',
    'url': 'https://www.youtube.com/watch?v=example',
    'album_name': 'Some name',
    "genres": ["genre1", "genre2"],
    'artists': ["Jagadish Samal"],
    'image_url': 'https://example.com/image.png',
  };
  bool _received = false;

  get received => _received;

  void changeStatus() {
    _received = !_received;
    notifyListeners();
  }

  Map<String, dynamic> get song => _song;

  void setSong(String songName, Map<String, dynamic> newSong) async {
    _song = newSong;
    final prefs = await SharedPreferences.getInstance();
    final songJson = jsonEncode(newSong);
    prefs.setString(songName, songJson);
    notifyListeners();
  }

  final AudioRecorder _record = AudioRecorder();
  bool _isRecording = false;
  String _afterRecordingFilePath = '';

  bool get isRecording => _isRecording;

  String get recordedFilePath => _afterRecordingFilePath;

  onWillPop() {
    _received = false;
    _afterRecordingFilePath = '';
    notifyListeners();
  }

  clearOldData() {
    _afterRecordingFilePath = '';
    _received = false;
    _connectionfail = false;
    _uploadStatus = false;
    notifyListeners();
  }
  // Caches the song data to SharedPreferences

  static const _songIndexKey = 'songIndex'; // Key for SharedPreferences cache

  postRequest(String originalPath) async {
    //  could user ping discover network to know if a particular ip and port is available or not
    //so that we can quickly set connectionfail =true when we set ipaddress that's unavailable.
    //so, for now, I am only doing a simple work, just shifting the ip address whenever I shift.
    //won't click unavailable ip to avoid crashing or loading too much.
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_ipaddress),
      );
      final audioFileField =
          await http.MultipartFile.fromPath('file', originalPath!);
      request.files.add(audioFileField);
      _responseTime = null;
      DateTime startTime = DateTime.now();
      // Send the request and await the response
      final response = await request.send();
      // Handle the response
      if (response.statusCode == 200) {
        print('File uploaded successfully:');
        DateTime endTime = DateTime.now();
        _responseTime = endTime.difference(startTime);
        notifyListeners();
        var finalResponse = await response.stream.bytesToString();
        Map<String, dynamic> useResponse = jsonDecode(finalResponse);
        String songName = useResponse['name'];
        setSong(songName, useResponse);

        print(song);
        changeStatus();
      } else {
        print('Error while uploading file');
        _connectionfail = true;
        print('conenction fail is ' + _connectionfail.toString());

        notifyListeners();
      }
    } catch (e) {
      print('Error sending post request: $e');
      _connectionfail = true;
      print('connection fail is  ' +
          _connectionfail.toString() +
          'in catch block');

      notifyListeners();
    }
  }

  loadCachedSong(String songName) async {
    final prefs = await SharedPreferences.getInstance();
    final songJson = prefs.getString(songName);
    if (songJson != null) {
      _song = jsonDecode(songJson);
      print('song is printed here');
      print(song);
      notifyListeners();
    }
  }

  recordVoice() async {
    print("entered recordVoice");
    final _isPermitted = (await PermissionManagement.recordingPermission()) &&
        (await PermissionManagement.requestStoragePermission());

    if (!_isPermitted) return;

    if (!(await _record.hasPermission())) return;

    final _voiceDirPath = await StorageManagement.getAudioDir;
    final _voiceFilePath = StorageManagement.createRecordAudioPath(
        dirPath: _voiceDirPath, fileName: 'audio_message');

    await _record.start(
      const RecordConfig(
        numChannels: 1,
        bitRate: 128000,
        sampleRate: 8000,
      ),
      path: _voiceFilePath,
    );
    _isRecording = true;
    notifyListeners();

    showToast('Recording Started');
  }

  uploadAudio() async {
    final audioFile = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (audioFile == null) return;
    if (audioFile != null) {
      final filePath = audioFile.files.single.path;

      print('First Uploaded');
      _uploadStatus = true;
      notifyListeners();
      postRequest(filePath!);
      notifyListeners();
    }
  }

  stopRecording() async {
    String? _audioFilePath;

    if (await _record.isRecording()) {
      _audioFilePath = await _record.stop();
      showToast('Recording Stopped');
      // Assume audio file is saved as a File object
    }
    _isRecording = false;
    notifyListeners();
    _afterRecordingFilePath = _audioFilePath ?? '';

    final file = File(_audioFilePath!);
    postRequest(_audioFilePath!);
    notifyListeners();
  }
}
