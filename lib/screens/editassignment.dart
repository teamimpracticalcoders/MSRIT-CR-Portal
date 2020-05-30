import 'package:crportal/models/assignment.dart';
import 'package:crportal/services/newassignmentbloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAssignment extends StatefulWidget {
  final String classcode;
  final String assignmentid;
  final Assignment assignment;
  EditAssignment({Key key, this.classcode, this.assignmentid, this.assignment})
      : super(key: key);

  @override
  _EditAssignmentState createState() => _EditAssignmentState();
}

class _EditAssignmentState extends State<EditAssignment> {
  bool isLoading = false;
  bool showLoading = true;
  TextEditingController _titlecontroller,
      _descriptioncontroller,
      _subjectcodecontroller,
      _moredetailslinkcontroller,
      _submissionlinkcontroller;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  var finaldate;

  String branch;

  String sec;

  String sem;

  String classcode;


  void callDatePicker() async {
    var order = await getDate();
    setState(() {
      finaldate = order;
    });
  }

  Future<DateTime> getDate() {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2025),
      initialEntryMode: DatePickerEntryMode.calendar,
      builder: (BuildContext context, Widget child) {
        return child;
      },
    );
  }

  String _formatDate(DateTime date) {
    final format = DateFormat.Hm('en_US').add_MMMMEEEEd();
    return format.format(date);
  }

  @override
  void initState() {
    super.initState();
  _loadClassDetails();
    this._titlecontroller =
        new TextEditingController(text: widget.assignment.title);
    this._descriptioncontroller =
        new TextEditingController(text: widget.assignment.description);
    this._moredetailslinkcontroller =
        new TextEditingController(text: widget.assignment.moreDetailsLink);
    this._subjectcodecontroller =
        new TextEditingController(text: widget.assignment.subjectCode);
    this._submissionlinkcontroller =
        new TextEditingController(text: widget.assignment.submitLink);
    setState(() {
      finaldate = widget.assignment.deadline.toDate();
    });
  }

  _loadClassDetails() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String branch = await pref.get("Branch");
    String sem = await pref.get("Sem");
    String sec = await pref.get("Sec");
      setState(() {
        this.branch = branch;
        this.sem=sem;
        this.sec=sec;
        this.classcode=branch+sem+sec;
      });
  }
  onPressSubmit() {
    if (!_formKey.currentState.validate()) {
    } else {
      setState(() {
        this.isLoading = true;
      });
      editAssignmentinDB(widget.assignmentid,
              classcode: widget.classcode,
              title: _titlecontroller.text,
              deadline: finaldate,
              description: _descriptioncontroller.text,
              subjcode: _subjectcodecontroller?.text ?? "NESC",
              moredetailsurl: _moredetailslinkcontroller?.text ?? '',
              submissionurl: _submissionlinkcontroller?.text ?? '')
          .then((statusCode) {
        setState(() {
          this.isLoading = false;
        });
        switch (statusCode) {
          case 1:
            print('Updated');
            Fluttertoast.showToast(
                msg: "Details updated",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                textColor: Colors.white,
                fontSize: 16.0);
            Navigator.pop(context);
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
            'Deadline ${(finaldate == null) ? '' : ' - ${_formatDate(finaldate)} '}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          new RaisedButton(
            onPressed: callDatePicker,
            child: new Text(
              '${(finaldate == null) ? 'Set Deadline' : 'Change'}',
            ),
          ),
        ],
      ),
    );
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
            _descriptionField("Description",
                controllervar: _descriptioncontroller),
            _entryField("Attachments URL",
                controllervar: _moredetailslinkcontroller, isRequired: false),
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
        title: Text('Edit Assignment'),
        actions: <Widget>[
          FlatButton(
            child: isLoading
                ? CupertinoActivityIndicator()
                : Text(
                    'Update',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
            onPressed: () {
              onPressSubmit();
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
