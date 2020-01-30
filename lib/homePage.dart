import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File _image;
  double _progress ;
  bool _isLoading = false;

progress(loading){
if (loading) {
  return Column(
    children: <Widget>[
      LinearProgressIndicator(
      
      value: _progress,
      backgroundColor: Colors.white,
    ),
              Text(
                    '${(_progress * 100).toStringAsFixed(2) } % '
                  ),
    ],
  );
          
} else {
  return Container(
    child: Text('data'),
  );
}
}
  getImageFile(ImageSource source) async {

     //Clicking or Picking from Gallery 

    var image = await ImagePicker.pickImage(
      source: source, 
      imageQuality: 100, 
      // maxHeight: 512, 
      // maxWidth: 512 
      );

    //Cropping the image

    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,

      // maxWidth: 512,
      // maxHeight: 512,
    );

    setState(() {
      _image = croppedFile;
      print(_image.lengthSync());
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_image?.lengthSync());
    return Scaffold(
      appBar: AppBar(
        title: Text("Click | Pick | Crop | Compress"),
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: _image == null
                ? Text("Image")
                : Image.file(
                    _image,
                    height: 200,
                    width: 200,
                  ),
          ),
          progress(_isLoading),
          
        ],
      ),
      
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton.extended(
            label: Text("Camera"),
            onPressed: () => getImageFile(ImageSource.camera),
            heroTag: UniqueKey(),
            icon: Icon(Icons.camera),
          ),
          SizedBox(
            width: 2,
          ),
          FloatingActionButton.extended(
            label: Text("Gallery"),
            onPressed: () => getImageFile(ImageSource.gallery),
            heroTag: UniqueKey(),
            icon: Icon(Icons.photo_library),
          ),
          SizedBox(
            width: 2,
          ),
          
          FloatingActionButton.extended(
            label: Text("Up"),
            onPressed: () async {
              final StorageReference firebaseStorageRef =
                  FirebaseStorage.instance.ref().child('myimage4.jpg');
              final StorageUploadTask task =
                  firebaseStorageRef.putFile(_image);
                  

                  //print(task.isSuccessful);
                  print(task.isInProgress);

                  print( await task.isComplete);
                  // print(task.isCanceled);
                  if(task.isSuccessful){
                    print('done');
                  }
                  task.events.listen((event){
                    setState(() {
                     _isLoading = true;
                     _progress = event.snapshot.bytesTransferred.toDouble() / event.snapshot.totalByteCount.toDouble();
                     print(_progress);
                    });
                  }).onError((error) {
                    print(error);
                  });

                  var dowurl = await (await task.onComplete).ref.getDownloadURL();
                  String url = dowurl.toString();
                  print(url);
            },
            heroTag: UniqueKey(),
            icon: Icon(Icons.cloud_upload),
          )
        ],
      ),
    );
  }
}