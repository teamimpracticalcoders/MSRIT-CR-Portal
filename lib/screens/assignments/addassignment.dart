import 'package:crportal/components/uploadbutton.dart';
import 'package:crportal/services/newassignmentbloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class AddAssignment extends StatefulWidget {
  final String classcode;
  AddAssignment({Key key, this.classcode}) : super(key: key);

  @override
  _AddAssignmentState createState() => _AddAssignmentState();
}

class _AddAssignmentState extends State<AddAssignment> {
  bool isLoading = false;
  bool showLoading = true;
  TextEditingController _titlecontroller,
      _descriptioncontroller,
      _subjectcodecontroller,
      _moredetailslinkcontroller,
      _submissionlinkcontroller;
  final _formKey = GlobalKey<FormState>();
  TimeOfDay time;

  DateTime pickeddate;
  DateTime dayandtime;

  void callDatePicker() async {
    var order = await getDate();
    if (order != null)
      setState(() {
        pickeddate = order;
      });
  }

  Future<DateTime> getDate() {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2025),
      initialEntryMode: DatePickerEntryMode.calendar,
    );
  }

  String _formatDate(DateTime date) {
    final format = DateFormat.Hm('en_US').add_MMMMEEEEd();
    return format.format(date);
  }

  @override
  void initState() {
    super.initState();
    this.time = TimeOfDay.now();
    this.pickeddate = DateTime.now();
    this._titlecontroller = new TextEditingController();
    this._descriptioncontroller = new TextEditingController();
    this._moredetailslinkcontroller = new TextEditingController();
    this._subjectcodecontroller = new TextEditingController();
    this._submissionlinkcontroller = new TextEditingController();
  }

  onPressRegister() {
    if (!_formKey.currentState.validate()) {
    } else {
      setState(() {
        this.isLoading = true;

        this.dayandtime = new DateTime(
            this.pickeddate.year,
            this.pickeddate.month,
            this.pickeddate.day,
            this.time.hour,
            this.time.minute);
      });
      addAssignmentToDB(
              _titlecontroller?.text ?? "Untitled",
              _subjectcodecontroller?.text ?? "NESC",
              _descriptioncontroller?.text ?? "Description",
              dayandtime ?? DateTime.now(),
              _submissionlinkcontroller?.text ?? "submissionlink",
              _moredetailslinkcontroller?.text ?? "more details",
              widget.classcode ?? "NA")
          .then((statusCode) {
        setState(() {
          this.isLoading = false;
        });
        switch (statusCode) {
          case 1:
            print('Added');
            Fluttertoast.showToast(
                msg: "Assignment Added",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                textColor: Colors.white,
                fontSize: 16.0);
            Navigator.pop(context);
            break;
          case 2:
            print('check your internet connection');
            Fluttertoast.showToast(
                msg: "Check your Internet Connection",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                textColor: Colors.white,
                fontSize: 16.0);
            break;
          case 3:
            print('please try again later');
            Fluttertoast.showToast(
                msg: "Please try again later",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                textColor: Colors.white,
                fontSize: 16.0);
            break;
        }
      });
    }
  }

  Widget _entryField(String title,
      {TextEditingController controllervar, bool isRequired = true}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              validator: (value) {
                if (isRequired && value.isEmpty) {
                  return 'Please fill in this field';
                }
                return null;
              },
              // obscureText: isPassword,
              controller: controllervar,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  // fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _deadlineSelector() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Deadline ${(dayandtime == null) ? '' : ' - ${_formatDate(dayandtime)} '}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  _pickTime() async {
    TimeOfDay t = await showTimePicker(context: context, initialTime: time);
    if (t != null)
      setState(() {
        time = t;
      });
  }

  Widget _descriptionField(String title,
      {TextEditingController controllervar}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please fill in this field';
                }
                return null;
              },
              keyboardType: TextInputType.multiline,
              maxLines: 18,
              controller: controllervar,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  // fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _formfieldswidgets() {
    return Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            _entryField("Title", controllervar: _titlecontroller),
            _entryField("Subject Code",
                controllervar: _subjectcodecontroller, isRequired: false),
            _deadlineSelector(),
            ListTile(
              title: Text(
                  "${DateFormat.EEEE("en_US").add_yMMMMd().format(pickeddate)}"),
              trailing: Icon(Icons.calendar_today),
              onTap: callDatePicker,
            ),
            ListTile(
              title: Text("${time.format(context)}"),
              trailing: Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            _descriptionField("Description",
                controllervar: _descriptioncontroller),
            _entryField("Attachments URL",
                controllervar: _moredetailslinkcontroller, isRequired: false),
            UploadButton(attachmentController: _moredetailslinkcontroller,),
            _entryField("Submission Link",
                controllervar: _submissionlinkcontroller, isRequired: false),
          ],
          physics: BouncingScrollPhysics(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Assignment'),
        actions: <Widget>[
          FlatButton(
            child: isLoading
                ? CupertinoActivityIndicator()
                : Text(
                    'ADD',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
            onPressed: () {
              onPressRegister();
            },
          )
        ],
      ),
      body: Center(
        child:
            Padding(padding: EdgeInsets.all(10), child: _formfieldswidgets()),
      ),
    );
  }
}
