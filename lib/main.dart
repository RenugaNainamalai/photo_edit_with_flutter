
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:album_saver/album_saver.dart';


void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImageCropper',
      theme: ThemeData.light().copyWith(primaryColor: Colors.blue),
      home: MyHomePage(),
    );
  }
}
class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _MyHomePageState extends State<MyHomePage> {
  AppState state;
  File imageFile;

  @override
  void initState() {
    super.initState();
    state = AppState.free;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: imageFile != null ? Image.file(imageFile) : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          if (state == AppState.free)
            _pickImage();
          else if (state == AppState.picked)
            _cropImage();
          else if (state == AppState.cropped) _save();
        },
        child: _buildButtonIcon(),
      ),
    );
  }

  Widget _buildButtonIcon() {
    if (state == AppState.free)
      return Icon(Icons.camera);
    else if (state == AppState.picked)
      return Icon(Icons.crop);
    else if (state == AppState.cropped)
      return Icon(Icons.save);
    else
      return Container();
  }

  Future<Null> _pickImage() async {
    imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 100);
    
    if (imageFile != null) {
      //final bytes = await imageFile.readAsBytes();
    final bytes = await imageFile.length();

    var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    double fileSizeInKB = bytes / 1024;
    print("Picked img Filesize $fileSizeInKB" + " KB");
    double fileSizeInMB = fileSizeInKB / 1024;
    print("Picked img Filesize $fileSizeInMB" + " MB");

    print(decodedImage.width);
    print(decodedImage.height);

    print("object  => $bytes");
      setState(() {
        state = AppState.picked;
      });
    }
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        compressQuality: 90,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile;
      print(croppedFile);
      final bytes = await imageFile.length();
      var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
      print(decodedImage.width);
      print(decodedImage.height);
      print("object  => $bytes");
      final fileSizeInKB = bytes / 1024;
      print("Cropped img Filesize $fileSizeInKB" + " KB");
      double fileSizeInMB = fileSizeInKB / 1024;
      print("Cropped img Filesize $fileSizeInMB" + " MB");
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  _save() async {
    AlbumSaver.createAlbum(albumName: "Images");
    AlbumSaver.saveToAlbum(filePath: imageFile.path, albumName: "Images");

    _clearImage();
  }

  void _clearImage() {
    imageFile = null;
    setState(() {
      state = AppState.free;
    });
  }
}
