import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rural_jobs_app/Jobs/job_details.dart';
import 'package:rural_jobs_app/Services/global_methods.dart';

class WidgetJob extends StatefulWidget {

  final String jobTitle;
  final String jobDescription;
  final String jobId;
  final String uploadedBy;
  final String name;
  final bool recruitment;
  final String email;
  final String location;

  const WidgetJob({
    required this.jobTitle,
    required this.jobDescription,
    required this.jobId,
    required this.uploadedBy,
    required this.name,
    required this.recruitment,
    required this.email,
    required this.location,
});

  @override
  State<WidgetJob> createState() => _WidgetJobState();
}

class _WidgetJobState extends State<WidgetJob> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  _deleteDialog() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final _uid = user.uid;

    // Fetch user role from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .get();

    String userRole = userDoc.get('role') ?? '';

    if (userRole != 'Employer') {
      GlobalMethods.showErrorDialog(error: 'Only Employers can delete jobs.', ctx: context);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this job?"),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    try {
                      if (widget.uploadedBy == _uid) {
                        await FirebaseFirestore.instance.collection('jobs')
                            .doc(widget.jobId)
                            .delete();

                        await Fluttertoast.showToast(
                          msg: 'Job has been deleted',
                          toastLength: Toast.LENGTH_LONG,
                          backgroundColor: Colors.grey,
                          fontSize: 18.0,
                        );

                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      } else {
                        GlobalMethods.showErrorDialog(error: 'You cannot perform this action', ctx: ctx);
                      }
                    } catch (error) {
                      GlobalMethods.showErrorDialog(error: 'This task cannot be deleted', ctx: ctx);
                    }
                  },
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx), // Close dialog
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white24,
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        onTap: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => JobDetailsScreen(
            uploadedBy: widget.uploadedBy,
            jobId: widget.jobId,
          )));
        },
        onLongPress: (){
          _deleteDialog();
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          height: 40, // Constrain the height
          width: 40,  // Constrain the width
          padding: const EdgeInsets.only(right: 12),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(width: 1),
            ),
          ),
          child: const Icon(
            Icons.work_outline, // Example: Add an icon or other widget here
            color: Colors.black,
          ),
        ),
        title: Text(
          widget.jobTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontFamily: 'GrotleyRegular',
            fontSize: 20,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
              ),
            ),
            const SizedBox(height: 8,),
            Text(
              widget.jobDescription,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17.5,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: Colors.black,
        ),
      ),
    );
  }
}
