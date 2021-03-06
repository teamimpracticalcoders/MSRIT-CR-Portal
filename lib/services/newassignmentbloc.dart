import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

Future<int> addAssignmentToDB(String title,String subjcode,String description,DateTime deadline,String submissionurl,String moredetailsurl,String classcode) async{
   
  int statusCode =1;
  

  //create a new user
  Map<String,dynamic> assignmentDetails = new Map();
  

  var uuid = Uuid();
  var assignmentId = uuid.v1();
  assignmentDetails.addAll({
    'title':title,
    'description':description,
    'deadline':deadline,
    'moreDetailsLink':moredetailsurl,
    'submitLink':submissionurl,
    'subjectCode':subjcode,
    'assignmentID':assignmentId
  });
  
  await Firestore.instance.collection('classCodes').document(classcode).collection('assignments').document(assignmentId).setData(assignmentDetails).catchError((onError){statusCode =3;});

  return statusCode;
}

Future<int> editAssignmentinDB(String assignmentId,{String title,String subjcode,String description,DateTime deadline,String submissionurl,String moredetailsurl,String classcode}) async{
   
  int statusCode =1;
  
  

  
  Map<String,dynamic> assignmentDetails = new Map();
  

  
  
  assignmentDetails.addAll({
    'title':title,
    'description':description,
    'deadline':deadline,
    'moreDetailsLink':moredetailsurl,
    'submitLink':submissionurl,
    'subjectCode':subjcode,
  
  });
  
  await Firestore.instance.collection('classCodes').document(classcode).collection('assignments').document(assignmentId).updateData(assignmentDetails).catchError((onError){statusCode =3;print(onError);});

  return statusCode;
}

Future<int> deleteAssignmentfromDB(String assignmentId,{String classcode}) async{
   
  int statusCode =1;
  print(classcode);
  print("Attempting Delete");
  await Firestore.instance.collection('classCodes').document(classcode).collection('assignments').document(assignmentId).delete().catchError((onError){statusCode =3;print(onError);});

  return statusCode;
}

Future<FirebaseUser> getUser()async{
  return await FirebaseAuth.instance.currentUser();
}
