import 'package:crportal/components/uploadbutton.dart';
import 'package:crportal/services/newnotice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
class AddNotice extends StatefulWidget {
  final String classcode;
  AddNotice({Key key,this.classcode}) : super(key: key);

  @override
  _AddNoticeState createState() => _AddNoticeState();
}

class _AddNoticeState extends State<AddNotice> {
  bool isLoading = false;
  bool showLoading = true;
  TextEditingController _titlecontroller,
      _descriptioncontroller,
      // _subjectcodecontroller,
      _moredetailslinkcontroller;
      // _submissionlinkcontroller;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  var finaldate;

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
      lastDate: DateTime(2022),
      initialEntryMode: DatePickerEntryMode.input,
      builder: (BuildContext context, Widget child) {
        return child;
      },
    );
  }


  @override
  void initState() {
    super.initState();

    this._titlecontroller = new TextEditingController();
    this._descriptioncontroller = new TextEditingController();
    this._moredetailslinkcontroller = new TextEditingController();
    // this._subjectcodecontroller = new TextEditingController();
    // this._submissionlinkcontroller=new TextEditingController();
  }


    onPressRegister() {


              // _titlecontroller?.text ?? "Untitled",
              // _subjectcodecontroller?.text ?? "NESC",
              // _descriptioncontroller?.text ?? "Description",
              // finaldate??DateTime.now(),
              // _submissionlinkcontroller?.text ?? "submissionlink",
              // _moredetailslinkcontroller?.text??"more details",
              // widget.classcode??"NA"
    if (!_formKey.currentState.validate()) {
    } else {
      setState(() {
        this.isLoading = true;
      });

      addNoticeToDB(
        classcode:widget.classcode??"NA" , 
        date:finaldate??DateTime.now(),  
        description: _descriptioncontroller?.text ?? "",
        title:_titlecontroller?.text ?? "Untitled", 
        moreDetailsLink: _moredetailslinkcontroller?.text ?? "")
          .then((statusCode) {
        setState(() {
          this.isLoading = false;
        });
        switch (statusCode) {
          case 1:
            print('Added');
            Fluttertoast.showToast(
                msg: "Notice Added",
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


  Widget _entryField(String title, {TextEditingController controllervar,bool isRequired=true}) {
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
                if (isRequired&&value.isEmpty) {
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

  Widget _deadlineSelector(){
   return Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Deadline ${(finaldate == null) ? '' : ' - $finaldate '}',
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
  Widget _descriptionField(String title, {TextEditingController controllervar}) {
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
    return Form(key: _formKey,child: 
    ListView(
      children: <Widget>[
        _entryField("Title", controllervar: _titlecontroller),
        // _entryField("Subject Code", controllervar: _subjectcodecontroller,isRequired: false),
        // _deadlineSelector(),
        _descriptionField("Description", controllervar: _descriptioncontroller),
        
        _entryField("Attachments URL",
            controllervar: _moredetailslinkcontroller,isRequired: false),
        
        // _entryField("Submission Link",
            // controllervar: _submissionlinkcontroller,isRequired: false),
        UploadButton(attachmentController: _moredetailslinkcontroller,)
      ],
    physics: BouncingScrollPhysics(),));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Notice'),
        actions: <Widget>[
          FlatButton(
             child: isLoading
            ? CupertinoActivityIndicator()
            : Text(
                'ADD',
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),
              ),
            onPressed: () {onPressRegister();},
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