import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:rural_jobs_app/Widgets/widget_job.dart';

class RequestedJob extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.greenAccent, Colors.cyan],
          begin: Alignment.centerRight,
          end: Alignment.bottomLeft,
          stops: [0.2, 0.7],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Requested Jobs',
            style: TextStyle(fontFamily: 'Signatra', fontSize: 40,),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightGreenAccent, Colors.greenAccent],
                begin: Alignment.bottomLeft,
                end: Alignment.centerRight,
                stops: [0.2, 0.4],
              ),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collectionGroup('Apply_Job')
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(),);
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data?.docs.isNotEmpty == true) {
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final jobData = snapshot.data?.docs[index].data();
                    final requestId = snapshot.data?.docs[index].id;
                    final requestDocRef = snapshot.data?.docs[index].reference;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetJob(
                            jobTitle: jobData['jobTitle'] ?? '',
                            jobDescription: jobData['jobDescription'] ?? '',
                            jobId: jobData['jobId'] ?? '',
                            uploadedBy: jobData['uploadedBy'] ?? '',
                            name: jobData['seekerName'] ?? 'Anonymous',
                            recruitment: jobData['recruitment'] ?? false,
                            email: jobData['email'] ?? '',
                            location: jobData['location'] ?? '',
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () => acceptApplication(
                                  jobData['seekerId'] ?? '',
                                  jobData['jobTitle'] ?? '',
                                  jobData['jobDescription'] ?? '',
                                  jobData['seekerEmail'] ?? '',
                                  requestDocRef,
                                ),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green,),
                                child:  const Text('Accept', style: TextStyle(color: Colors.white),),
                              ),
                              ElevatedButton(
                                onPressed: () => rejectApplication(
                                  jobData['seekerId'] ?? '',
                                  jobData['jobTitle'] ?? '',
                                  jobData['seekerEmail'] ?? '',
                                  requestDocRef,
                                ),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red,),
                                child: const Text('Reject', style: TextStyle(color: Colors.white),),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: Text('There are no applications'),);
              }
            }
            return const Center(
              child: Text('Something went wrong',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            );
          },
        ),
      ),
    );
  }

  void acceptApplication(
      String seekerId,
      String jobTitle,
      String jobDescription,
      String seekerEmail,
      DocumentReference? requestDocRef) async {
    try {

      await FirebaseFirestore.instance
          .collection('users')
          .doc(seekerId)
          .collection('Job_History')
          .add({
        'jobTitle': jobTitle,
        'jobDescription': jobDescription,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      final Uri params = Uri(
        scheme: 'mailto',
        path: seekerEmail,
        query:
        'subject=Application Accepted&body=TAHNIAH! permohonan anda diterima untuk bekerja sebagai $jobTitle.',
      );
      final url = params.toString();
      await launchUrlString(url);

      if (requestDocRef != null) {
        await requestDocRef.delete();
      }

      Fluttertoast.showToast(msg: "Application accepted and email sent.");
    } catch (error) {
      Fluttertoast.showToast(msg: "Error accepting application: $error");
    }
  }

  void rejectApplication(String seekerId, String jobTitle, String seekerEmail,
      DocumentReference? requestDocRef) async {
    try {

      final Uri params = Uri(
        scheme: 'mailto',
        path: seekerEmail,
        query:
        'subject=Application Rejected&body=HARAP MAAF, permohonan anda tidak diterima untuk bekerja sebagai $jobTitle.',
      );
      final url = params.toString();
      await launchUrlString(url);

      if (requestDocRef != null) {
        await requestDocRef.delete();
      }
      Fluttertoast.showToast(msg: "Application rejected and email sent.");
    } catch (error) {Fluttertoast.showToast(msg: "Error rejecting application: $error");}
  }
}