import 'dart:io';
import 'package:app_v4/pages/constants.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class EventCreate extends StatefulWidget {
  @override
  _EventCreateState createState() => _EventCreateState();
}

class _EventCreateState extends State<EventCreate> {
  Map args;
  Event event;
  bool disabled;

  TextEditingController _addressController;
  TextEditingController _dateController;

  bool first = true;

  Size size;

  void _setUp(context) {
    size = MediaQuery.of(context).size;
    first = false;
    args = ModalRoute.of(context).settings.arguments;
    event = args['event'];

    _addressController = TextEditingController(text: event.address ?? '');
    _dateController = TextEditingController(
        text: event.timestamp == null
            ? ''
            : timestampFormat(event.timestamp, context));
  }

  Future<void> _pickImage() async {
    var imPick = ImagePicker();
    var selected = await imPick.getImage(
        source: ImageSource.gallery, maxHeight: 750, maxWidth: 750);

    if (selected == null) return;
    var selectedImage = File(selected.path);
    var cropped = await ImageCropper.cropImage(
      aspectRatio: CropAspectRatio(ratioX: widthToHeight, ratioY: 1),
      sourcePath: selectedImage.path,
    );
    if (cropped == null) return;
    setState(() => event.imageFile = cropped);
  }

  void _checkDisabled() {
    disabled = (event.imageFile == null && event.imageRef == null) ||
        event.timestamp == null ||
        event.geoPoint == null ||
        event.venue == '' ||
        event.venue == null ||
        event.address == '' ||
        event.address == null ||
        event.organization == '' ||
        event.organization == null ||
        event.name == '' ||
        event.name == null ||
        event.summary == '' ||
        event.summary == null;
  }

  @override
  Widget build(BuildContext context) {
    if (first) _setUp(context);
    _checkDisabled();

    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${event.private ? 'Private' : 'Public'} Event',
                style: TextStyle(color: textColor, fontFamily: font2),
              ),
              Icon(event.private ? Icons.lock : Icons.lock_open),
            ],
          ),
          backgroundColor: Colors.grey[100],
          iconTheme: IconThemeData(color: textColor),
          elevation: 0,
          shape: Border(bottom: BorderSide(color: Colors.grey[400], width: 1)),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                margin: event.imageFile == null && event.imageRef == null
                    ? EdgeInsets.fromLTRB(10, 10, 10, 0)
                    : null,
                width: size.width,
                height: event.imageFile == null && event.imageRef == null
                    ? null
                    : size.width / widthToHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image: event.imageFile == null && event.imageRef == null
                      ? null
                      : DecorationImage(
                          image: event.imageFile == null
                              ? NetworkImage(event.imageRef)
                              : FileImage(event.imageFile),
                          fit: BoxFit.cover,
                        ),
                ),
                child: event.imageFile == null && event.imageRef == null
                    ? TextFormField(
                        textCapitalization: TextCapitalization.words,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Choose Header',
                          prefixIcon: Icon(
                            Icons.image,
                          ),
                        ),
                        onTap: _pickImage,
                      )
                    : Padding(
                        padding: const EdgeInsets.all(10),
                        child: Align(
                            alignment: Alignment.bottomRight,
                            child: RaisedButton(
                              shape: CircleBorder(),
                              color: Colors.grey[300],
                              onPressed: _pickImage,
                              child: Icon(
                                Icons.image,
                                color: Colors.grey[600],
                              ),
                            ))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 10),
                    TextFormField(
                      minLines: 1,
                      maxLines: 2,
                      style: TextStyle(fontSize: 20),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 50,
                      initialValue: event.name ?? '',
                      onChanged: (value) => setState(() {
                        event.name = value;
                      }),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(20),
                        counterText:
                            (event.name ?? '').length >= 40 ? null : '',
                        counterStyle: TextStyle(
                            color: (event.name ?? '').length == 50
                                ? Colors.red
                                : null),
                        hintText: 'Event Name',
                        prefixIcon: Icon(Icons.event_note),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      maxLength: 50,
                      initialValue: event.organization ?? '',
                      onChanged: (value) => setState(() {
                        event.organization = value;
                      }),
                      decoration: InputDecoration(
                        hintText: 'Sponsoring Organization',
                        counterText:
                            (event.organization ?? '').length >= 40 ? null : '',
                        counterStyle: TextStyle(
                            color: (event.organization ?? '').length == 50
                                ? Colors.red
                                : null),
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      color: Colors.grey[200],
                      child: TextFormField(
                        style: TextStyle(color: textColor),
                        controller: _dateController,
                        readOnly: true,
                        onTap: () async {
                          var nowDate = DateTime.now();
                          var nowTime = TimeOfDay.now();

                          var d = await showDatePicker(
                              context: context,
                              initialDate: event.timestamp == null
                                  ? nowDate
                                  : event.timestamp.toDate(),
                              firstDate: nowDate,
                              lastDate: nowDate.add(Duration(days: 365)));
                          if (d == null) return;
                          var t = await showTimePicker(
                            context: context,
                            initialTime: event.timestamp == null
                                ? nowTime
                                : TimeOfDay.fromDateTime(
                                    event.timestamp.toDate()),
                          );
                          if (t == null) return;
                          setState(() {
                            event.timestamp = Timestamp.fromDate(d.add(
                                Duration(hours: t.hour, minutes: t.minute)));
                            _dateController.text = timeFormat(d, t, context);
                          });
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Date & Time',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      maxLength: 50,
                      onChanged: (value) => setState(() {
                        event.venue = value;
                      }),
                      initialValue: event.venue ?? '',
                      decoration: InputDecoration(
                        hintText: 'Venue Name',
                        counterText:
                            (event.venue ?? '').length >= 40 ? null : '',
                        counterStyle: TextStyle(
                            color: (event.venue ?? '').length == 50
                                ? Colors.red
                                : null),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      color: Colors.grey[200],
                      child: TextFormField(
                        style: TextStyle(color: textColor),
                        minLines: 1,
                        maxLines: 3,
                        controller: _addressController,
                        readOnly: true,
                        onTap: () async {
                          var e = await Navigator.of(context).pushNamed(
                              '/location',
                              arguments: {'event': event});
                          setState(() {
                            event = e ?? event;
                            _addressController.text = event.address ?? '';
                          });
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Address',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      maxLengthEnforced: true,
                      maxLength: 150,
                      minLines: 3,
                      maxLines: 5,
                      initialValue: event.summary ?? '',
                      onChanged: (value) => setState(() {
                        event.summary = value;
                      }),
                      decoration: InputDecoration(
                        hintText: 'Event Summary',
                        counterText:
                            (event.summary ?? '').length >= 140 ? null : '',
                        counterStyle: TextStyle(
                            color: (event.summary ?? '').length == 150
                                ? Colors.red
                                : null),
                        prefixIcon: Icon(Icons.question_answer),
                      ),
                    ),
                    RaisedButton(
                        textColor: Colors.white,
                        color: primary,
                        child: Text('Next'),
                        disabledColor: Colors.grey[300],
                        disabledElevation: 0,
                        disabledTextColor: Colors.grey[200],
                        onPressed: disabled
                            ? null
                            : () => Navigator.pushNamed(
                                context,
                                event.private && event.id == null
                                    ? '/choose_friends'
                                    : '/preview',
                                arguments: {'event': event})),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
