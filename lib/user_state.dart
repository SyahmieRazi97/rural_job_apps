import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rural_jobs_app/Jobs/jobs_screen.dart';
import 'package:rural_jobs_app/Search_Jobs/search_jobs.dart';
import 'LoginPage/loginscreen.dart';

class UserState extends StatelessWidget {

  Future<String?> _getUserRole() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return userDoc.get('role') as String?;
    } catch (error) {
      print('Error fetching user role: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (userSnapshot.data == null) {
          print('User is not logged in yet');
          return Login();
        }

        if (userSnapshot.hasData) {
          print('User is already logged in');
          return FutureBuilder<String?>(
            future: _getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (roleSnapshot.hasError || !roleSnapshot.hasData) {
                return const Scaffold(
                  body: Center(
                    child: Text('Failed to determine user role. Try again later.'),
                  ),
                );
              }

              final String? role = roleSnapshot.data;

              if (role == 'Seeker') {
                return JobsScreen(); // Redirect to Seeker's JobsScreen
              } else if (role == 'Employer') {
                return AllJobs(); // Redirect to Employer's AllJobs screen
              } else {
                return const Scaffold(
                  body: Center(
                    child: Text('Unknown role. Contact support.'),
                  ),
                );
              }
            },
          );
        }

        if (userSnapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('An error has occurred. Try again later.'),
            ),
          );
        }

        return const Scaffold(
          body: Center(
            child: Text('Something went wrong.'),
          ),
        );
      },
    );
  }
}
