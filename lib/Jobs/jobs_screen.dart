import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Widgets/widget_job.dart';
import '../Widgets/botttom_nav_bar.dart';

class JobsScreen extends StatefulWidget {
  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> recommendedJobs = [];
  bool isLoading = true;

  // Function to fetch recommended jobs from the Python backend
  Future<void> fetchRecommendedJobs() async {

    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      setState(() {isLoading = false;});
      print("User not logged in");
      return;
    }

    final url = Uri.parse(
        'https://msyahmierazi.pythonanywhere.com/recommendations'); // Replace with actual backend URL
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          recommendedJobs =
              data.map((job) => Map<String, dynamic>.from(job)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load recommendations');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching recommendations: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecommendedJobs();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.greenAccent, Colors.cyan], begin: Alignment.centerRight, end: Alignment.bottomLeft, stops: [0.2, 0.7],),
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavBar(indexNum: 0),
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Recommended Jobs',
            style: TextStyle(fontFamily: 'Signatra', fontSize: 40,),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.lightGreenAccent, Colors.greenAccent], begin: Alignment.bottomLeft, end: Alignment.centerRight, stops: [0.2, 0.4],),
            ),
          ),
        ),
        body: isLoading
            ? const Center(
              child: CircularProgressIndicator(),
        )
            : recommendedJobs.isNotEmpty
            ? ListView.builder(
            itemCount: recommendedJobs.length,
            itemBuilder: (BuildContext context, int index) {
            final job = recommendedJobs[index];

              return Card(
              margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetJob(
                    jobTitle: job['jobTitle'] ?? 'No Title',
                    jobDescription:
                    job['jobDescription'] ?? 'No Description',
                    jobId: job['jobId'] ?? 'Unknown Job ID',
                    uploadedBy:
                    job['uploadedBy'] ?? 'Unknown Employer',
                    name: job['name'] ?? 'Anonymous',
                    recruitment: job['recruitment'] ?? false,
                    email: job['email'] ?? 'No Email',
                    location: job['location'] ?? 'Unknown Location',
                  ),
                ],
              ),
            );
          },
        )
            : const Center(
              child: Text('No recommendations available at the moment',
                style: TextStyle(fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }
}