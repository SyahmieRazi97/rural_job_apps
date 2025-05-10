import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rural_jobs_app/Jobs/jobs_screen.dart';
import 'package:rural_jobs_app/Jobs/upload_job.dart';
import 'package:rural_jobs_app/Search_Jobs/profile_jobs.dart';
import 'package:rural_jobs_app/Search_Jobs/search_jobs.dart';

class BottomNavBar extends StatelessWidget {
  final int indexNum;

  BottomNavBar({required this.indexNum});

  Future<String> _getUserRole() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    if (user == null) {
      return 'unknown';
    }
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return userDoc.get('role') ?? 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Text('Error loading role'),
          );
        }

        final String role = snapshot.data!;
        final bool isSeeker = role == 'Seeker';
        final bool isEmployer = role == 'Employer';

        // Define items for the bottom navigation bar
        List<Widget> items = [
          if (!isEmployer) const Icon(Icons.list, size: 19, color: Colors.black), // Only show JobsScreen for Seekers
          const Icon(Icons.search, size: 19, color: Colors.black),
          if (!isSeeker) const Icon(Icons.upload, size: 19, color: Colors.black), // Only show UploadJob for Employers
          const Icon(Icons.person_pin, size: 19, color: Colors.black),
        ];

        // Adjust the index for Seekers and Employers
        int adjustedIndex = indexNum;
        if (isSeeker && adjustedIndex >= 2) {
          adjustedIndex -= 1; // Skip Upload Job for Seeker
        } else if (isEmployer && adjustedIndex > 0) {
          adjustedIndex -= 1; // Skip JobsScreen for Employer
        }

        return CurvedNavigationBar(
          color: Colors.greenAccent.shade400,
          backgroundColor: Colors.cyan,
          buttonBackgroundColor: Colors.lightGreenAccent.shade400,
          height: 50,
          index: adjustedIndex, // Set the adjusted index
          items: items, // Dynamically adjust items based on role
          animationDuration: const Duration(milliseconds: 300),
          animationCurve: Curves.bounceInOut,
          onTap: (index) {
            if (isSeeker && index >= 2) {
              index += 1; // Adjust index if seeker role skips "Upload Job"
            }
            if (isEmployer) {
              index += 1; // Adjust index mapping for employers
            }

            // Skip index 0 for Employer and only show JobsScreen for Seeker
            if (index == 0 && !isEmployer) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => JobsScreen()));
            } else if (index == 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AllJobs()));
            } else if (index == 2 && !isSeeker) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UploadJob()));
            } else if (index == 3 || (isEmployer && index == 2)) {
              // For both roles, index 3 should navigate to ProfileScreen
              final FirebaseAuth _auth = FirebaseAuth.instance;
              final User? user = _auth.currentUser;
              final String uid = user!.uid;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen(userID: uid)));
            }
          },
        );
      },
    );
  }
}

