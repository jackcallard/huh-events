import 'dart:io';
import 'package:app_v4/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageCapture extends StatefulWidget {
  ImageCapture({this.update, this.circle, this.text, this.initial});
  final String text;
  final bool circle;
  final Function update;
  final NetworkImage initial;
  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  File imageFile;
  ImageProvider<dynamic> image;
  int pressed = -1;
  bool showIcons = false;

  Future<void> _pickImage(ImageSource source) async {
    var imPick = ImagePicker();
    var selected =
        await imPick.getImage(source: source, maxHeight: 750, maxWidth: 750);

    if (selected == null) return;
    var selectedImage = File(selected.path);
    var cropped = await ImageCropper.cropImage(
        aspectRatio: widget.circle
            ? null
            : CropAspectRatio(ratioX: widthToHeight, ratioY: 1),
        sourcePath: selectedImage.path,
        cropStyle: widget.circle ? CropStyle.circle : null);
    if (cropped == null) return;
    setState(() {
      imageFile = cropped;
      image = FileImage(imageFile);
    });
    widget.update(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        (widget.circle
            ? CircleAvatar(
                backgroundImage: imageFile == null
                    ? (widget.initial ??
                        AssetImage('assets/default_icons/professor.png'))
                    : image,
                radius: 60,
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Image(
                  image: imageFile == null
                      ? AssetImage('assets/stock/landscape.png')
                      : FileImage(imageFile),
                ),
              )),
        InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.text,
                style: TextStyle(
                    color: Colors.grey[700], fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () => _pickImage(ImageSource.gallery))
      ],
    );
  }
}
