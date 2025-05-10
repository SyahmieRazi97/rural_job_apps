import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Services/global_variables.dart';

class Persistent
{
  static List<String> jobCategoryList = [
    'Manufacturing and Production',
    'Transportation',
    'Food Services',
    'Marketing',
    'Healthcare and Medical',
    'Automotive and Mechanical Service',
    'Agriculture and Farming',
  ];

  void getMyData() async
  {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

      name = userDoc.get('name');
      location = userDoc.get('location');
  }
}