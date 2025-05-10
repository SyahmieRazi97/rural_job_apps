import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rural_jobs_app/Jobs/jobs_screen.dart';
import 'package:rural_jobs_app/Search_Jobs/search_jobs.dart';
import 'package:rural_jobs_app/Services/global_methods.dart';
import 'package:rural_jobs_app/Services/global_variables.dart';
import 'package:rural_jobs_app/Widgets/widget_comments.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

class JobDetailsScreen extends StatefulWidget {

  final String uploadedBy;
  final String jobId;

  const JobDetailsScreen({
    required this.uploadedBy,
    required this.jobId,
});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _commentController = TextEditingController();
  bool _isComment = false;
  String? authorName;
  String? name;
  String? jobCategory;
  String? jobDescription;
  String? jobTitle;
  bool? recruitment;
  Timestamp? postedDateTimeStamp;
  String? postedDate;
  String? locationJob = '';
  String? email;
  int applicants = 0;
  bool showComment = true;

  void getJobData() async
  {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users')
        .doc(widget.uploadedBy).get();

    if(userDoc == null)
      {
        return;
      } else
        {
        setState(() {authorName = userDoc.get('name');});
        }
    final DocumentSnapshot jobDatabase = await FirebaseFirestore.instance.collection('jobs')
        .doc(widget.jobId).get();
    if(jobDatabase == null)
      {
        return;
      } else
        {
        setState(() {
          jobTitle = jobDatabase.get('jobTitle');
          jobDescription = jobDatabase.get('jobDescription');
          recruitment = jobDatabase.get('recruitment');
          email = jobDatabase.get('email');
          locationJob = jobDatabase.get('location');
          applicants = jobDatabase.get('applicants');
          postedDateTimeStamp = jobDatabase.get('createdAt');
          var postDate = postedDateTimeStamp!.toDate();
          postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
        });
      }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getJobData();
  }

  Widget dividerWidget()
  {
    return const Column(
      children: [
        SizedBox(height: 10,),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        SizedBox(height: 10,),
      ],
    );
  }

  void applyJob() async {
    try {
      // Send an email to the employer
      final Uri params = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=Applying for $jobTitle&body=Sila hantar maklumat tentang diri atau file anda di sini',
      );
      final url = params.toString();
      launchUrlString(url);

      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        String userId = currentUser.uid;

        // Step 1: Fetch the current user's name from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          throw Exception("User document not found.");
        }

        // Fetch the seeker's name from Firestore
        String seekerName = userDoc.get('name');
        String seekerEmail = currentUser.email ?? 'No Email';

        // Fetch job document to get employer's user ID (uploadedBy)
        DocumentSnapshot jobDoc = await FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.jobId)
            .get();

        if (!jobDoc.exists) {
          throw Exception("Job document not found.");
        }

        // Fetch necessary fields from job document
        String uploadedBy = jobDoc.get('uploadedBy');
        String jobId = widget.jobId;
        String jobTitle = jobDoc.get('jobTitle');
        String jobDescription = jobDoc.get('jobDescription');

        // Save application in employer's 'Apply_Job' collection
        CollectionReference applyJobCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(uploadedBy) // Employer's user document
            .collection('Apply_Job');

        await applyJobCollection.add({
          'seekerId': userId,
          'seekerEmail': seekerEmail,
          'seekerName': seekerName,
          'jobId': jobId,
          'jobTitle': jobTitle,
          'jobDescription': jobDescription,
          'appliedAt': FieldValue.serverTimestamp(),
        });

        // Optionally update the number of applicants in the job document
        await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
          'applicants': FieldValue.increment(1),
        });

        Fluttertoast.showToast(msg: "Job application submitted successfully.");
      } else {
        Fluttertoast.showToast(msg: "User not logged in.");
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Error applying for job: $error");
    }
  }

  void addNewApplicant() async
  {
    var docRef = FirebaseFirestore.instance.collection('jobs').doc(widget.jobId);

    docRef.update({
      'applicants': applicants + 1,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.greenAccent, Colors.cyan],
          begin: Alignment.centerRight,
          end: Alignment.bottomLeft,
          stops: [0.2,0.7],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightGreenAccent, Colors.greenAccent],
                begin: Alignment.bottomLeft,
                end: Alignment.centerRight,
                stops: [0.2,0.4],
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, size: 30,color: Colors.grey,),
            onPressed: ()
            {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AllJobs()));
            }
            ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black45,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            jobTitle == null
                                ?
                                ''
                                :
                                jobTitle!,
                            maxLines: 4,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20,),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authorName == null
                                  ?
                                  ''
                                  :
                                  authorName!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5,),
                            Text(locationJob!, style: const TextStyle(color: Colors.grey),),
                          ],
                        ),
                        ),
                        FirebaseAuth.instance.currentUser!.uid != widget.uploadedBy
                        ?
                        Container()
                        :
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            dividerWidget(),
                            const Text('Recruitment',
                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                            ),
                            const SizedBox(height: 5,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                    onPressed: (){
                                      User?user = _auth.currentUser;
                                      final _uid = user!.uid;
                                      if(_uid == widget.uploadedBy)
                                        {
                                          try
                                              {
                                                FirebaseFirestore.instance.collection('jobs')
                                                    .doc(widget.jobId)
                                                    .update({'recruitment': true});
                                              }
                                              catch(error)
                                              {
                                                GlobalMethods.showErrorDialog(error: 'Action cannot be performed', ctx: context,);
                                              }
                                        }
                                      else
                                        {
                                          GlobalMethods.showErrorDialog(error: 'You cannot perform this action', ctx: context,);
                                        }
                                      getJobData();
                                    },
                                    child: const Text('ON',
                                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey, fontSize: 18, fontWeight: FontWeight.normal,),
                                    ),
                                ),
                                Opacity(opacity: recruitment == true ? 1 : 0,
                                  child: const Icon(Icons.radio_button_checked, color: Colors.green,),
                                ),
                                const SizedBox(width: 40,),
                                TextButton(
                                  onPressed: (){
                                    User?user = _auth.currentUser;
                                    final _uid = user!.uid;
                                    if(_uid == widget.uploadedBy)
                                    {
                                      try
                                      {
                                        FirebaseFirestore.instance.collection('jobs')
                                            .doc(widget.jobId)
                                            .update({'recruitment': false});
                                      }
                                      catch(error)
                                      {
                                        GlobalMethods.showErrorDialog(
                                          error: 'Action cannot be performed',
                                          ctx: context,
                                        );
                                      }
                                    }
                                    else
                                    {
                                      GlobalMethods.showErrorDialog(
                                        error: 'You cannot perform this action',
                                        ctx: context,
                                      );
                                    }
                                    getJobData();
                                  },
                                  child: const Text('OFF',
                                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey, fontSize: 18, fontWeight: FontWeight.normal,),
                                  ),
                                ),
                                Opacity(opacity: recruitment == false ? 1 : 0, child: const Icon(Icons.radio_button_checked, color: Colors.red,),),
                              ],
                            )
                          ],
                        ),
                        dividerWidget(),
                        const Text('Job Description', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),),
                        const SizedBox(height: 10,),
                        Text(
                          jobDescription == null
                              ?
                              ''
                              :
                              jobDescription!,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 14, color: Colors.grey,),
                        ),
                        dividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              applicants.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 6,),
                            const Text('Applicants', style: TextStyle(color: Colors.grey),),
                            const SizedBox(width: 10,),
                            const Icon(Icons.how_to_reg_sharp, color: Colors.grey,),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.all(4.0),
                child: Card(color: Colors.black54,
                  child: Padding(padding: const EdgeInsets.all(8.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [const SizedBox(height: 6,),
                        Center(
                          child: InkWell(
                            onTap: () {applyJob();},
                            borderRadius: BorderRadius.circular(13), // Match border radius
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.greenAccent, Colors.cyan], // Gradient colors
                                  begin: Alignment.centerRight,
                                  end: Alignment.bottomLeft,
                                ),
                                borderRadius: BorderRadius.circular(13), // Rounded corners
                              ),
                            child: const Padding(padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(' Apply Now ',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14,),
                              ),
                            ),
                            ),
                          ),
                        ),
                        dividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Uploaded on:',
                              style: TextStyle(color: Colors.white,),
                            ),
                            Text(
                              postedDate == null
                                  ?
                                  ''
                                  :
                                  postedDate!,
                              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 15,),
                            )
                          ],
                        ),
                        dividerWidget(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.all(4.0),
                child: Card(color: Colors.black54,
                  child: Padding(padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 500,
                            ),
                          child: _isComment
                          ?
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                  flex: 3,
                                child: TextField(
                                  controller: _commentController,
                                  style: const TextStyle(color: Colors.white,),
                                  maxLength: 200,
                                  keyboardType: TextInputType.text,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),),
                                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.pink),),
                                  ),
                                ),
                              ),
                              Flexible(
                                  child: Column(
                                    children: [
                                      Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: MaterialButton(
                                          onPressed: () async{
                                            if(_commentController.text.length < 7)
                                            {
                                              GlobalMethods.showErrorDialog(
                                              error: 'Comment must be more than 7 characters',
                                                ctx: context,
                                              );
                                            }
                                            else
                                              {
                                                final _generatedId = const Uuid().v4();
                                                await FirebaseFirestore.instance.collection('jobs')
                                                    .doc(widget.jobId)
                                                    .update({
                                                      'jobComments':
                                                        FieldValue.arrayUnion([{
                                                          'userId': FirebaseAuth.instance.currentUser!.uid,
                                                          'commentId': _generatedId,
                                                          'name': name,
                                                          'commentBody': _commentController.text,
                                                          'time': Timestamp.now(),
                                                      }]),
                                                });
                                                await Fluttertoast.showToast(
                                                  msg: 'Your comment has been submitted',
                                                  toastLength: Toast.LENGTH_LONG,
                                                  backgroundColor: Colors.grey,
                                                  fontSize: 18.0,
                                                );
                                                _commentController.clear();
                                              }
                                            setState(() {showComment = true;});
                                          },
                                          color: Colors.cyan,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text('Post',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                          onPressed: (){
                                            setState(() {
                                              _isComment = !_isComment;
                                              showComment = true;
                                            });
                                          },
                                          child: const Text('Cancel', style: TextStyle(color: Colors.red,),),
                                      ),
                                    ],
                                  ),
                              ),
                            ],
                          )
                          :
                          Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: (){
                                  setState(() {_isComment = !_isComment;});
                                },
                                icon: const Icon(Icons.add_comment, color: Colors.cyan, size: 40,),
                              ),
                              const SizedBox(width: 10,),
                              IconButton(
                                onPressed: (){
                                  setState(() {showComment = true;});
                                },
                                icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.cyan, size: 40,),
                              ),
                            ],
                          ),
                        ),
                        showComment == false
                            ?
                        Container()
                            :
                            Padding(padding: const EdgeInsets.all(16.0),
                              child: FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('jobs')
                                    .doc(widget.jobId)
                                    .get(),
                                builder: (context, snapshot)
                                {
                                  if(snapshot.connectionState == ConnectionState.waiting)
                                    {
                                      return const Center(child: CircularProgressIndicator(),);
                                    }
                                  else
                                    {
                                      if(snapshot.data == null)
                                        {
                                          return const Center(child: Text('No Comment for this job'),);
                                        }
                                    }
                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index)
                                    {
                                      return WidgetComments(
                                        commentId: snapshot.data!['jobComments'] [index]['commentId'],
                                        commenterId: snapshot.data!['jobComments'] [index]['userId'],
                                        commenterName: snapshot.data!['jobComments'] [index]['name'],
                                        commentBody: snapshot.data!['jobComments'] [index]['commentBody'],
                                      );
                                    },
                                    separatorBuilder: (context, index)
                                    {
                                      return const Divider(thickness: 1, color: Colors.grey,);
                                    },
                                    itemCount: snapshot.data!['jobComments'].length,
                                  );
                                },
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
