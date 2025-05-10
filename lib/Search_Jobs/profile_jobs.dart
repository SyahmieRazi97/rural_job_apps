import  'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:rural_jobs_app/user_state.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Jobs/requested_job.dart';
import '../Widgets/botttom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {

  final String userID;

  const ProfileScreen({required this.userID});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? name;
  String email = '';
  String phoneNumber = '';
  String joinedAt = '';
  String? role;
  bool _isLoading = false;
  bool _isSameUser = false;

  void getUserData() async
  {
    try
    {
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users')
          .doc(widget.userID)
          .get();
      if (userDoc != null) {
        setState(() {
          name = userDoc.get('name');
          email = userDoc.get('email');
          phoneNumber = userDoc.get('phoneNumber');
          Timestamp joinedAtTimeStamp = userDoc.get('createdAt');
          var joinedDate = joinedAtTimeStamp.toDate();
          joinedAt = '${joinedDate.year} - ${joinedDate.month} - ${joinedDate.day}';
          role = userDoc.get('role');
        });
        User? user = _auth.currentUser;
        final _uid = user!.uid;
        setState(() {_isSameUser = _uid == widget.userID;});
      }
    } catch (error) {} finally {_isLoading = false;}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  Widget userInfo({required IconData icon, required String content})
  {
    return Row(
      children: [
        Icon(icon, color: Colors.white,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(content, style: const TextStyle(color: Colors.white54),),
        ),
      ],
    );
  }

  Widget _contactBy
      ({required Color color, required Function fct, required IconData icon})
  {
    return CircleAvatar(backgroundColor: color, radius: 25,
      child: CircleAvatar(radius: 23, backgroundColor: Colors.white,
        child: IconButton(icon: Icon(icon, color: color,),
          onPressed: ()
          {fct();},
        ),
      ),
    );
  }

void _openWhatsAppChat() async
{
  var url = 'https://wa.me/$phoneNumber?text=HelloWorld';
  launchUrlString(url);
}

void _mainTo() async
{
  final Uri params = Uri(
    scheme: 'mailTo',
    path: email,
    query: 'subject=Please write subject at here,&body=Hello, please write details here',
  );
  final url = params.toString();launchUrlString(url);
}

  void _callPhoneNumber() async
  {
    var url = 'tel://$phoneNumber';launchUrlString(url);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
        bottomNavigationBar: BottomNavBar(indexNum: 3),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Profile Screen',
            style: TextStyle(fontFamily: 'Signatra', fontSize: 40,),),
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
        body: Center(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Stack(
                children: [
                  Card(color: Colors.white10, margin: const EdgeInsets.all(30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                    child: Padding(padding: const EdgeInsets.all(8.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(alignment: Alignment.center,
                            child: Column(
                              children: [
                                Text(name ?? 'Name here',
                                  style: const TextStyle(color: Colors.white, fontSize: 24.0),
                                ),
                                const SizedBox(height: 5),
                                Text(role ?? 'Role here',
                                  style: const TextStyle(color: Colors.white54, fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Show "RequestedJob" button only if current user is an employer
                          if (_isSameUser && role == 'Employer')
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => RequestedJob()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Text(
                                      'View Job Requests',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 15),
                          const Divider(thickness: 1, color: Colors.white,),
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('Contact :',
                              style: TextStyle(color: Colors.white54, fontSize: 22),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Padding(padding: const EdgeInsets.only(left: 10),
                            child: userInfo(icon: Icons.phone_android, content: phoneNumber),
                          ),
                          Padding(padding: const EdgeInsets.only(left: 10),
                            child: userInfo(icon: Icons.email, content: email),
                          ),
                          const SizedBox(height: 15),
                          const Divider(thickness: 1, color: Colors.white,),
                          const SizedBox(height: 15),
                          _isSameUser
                              ?
                          Container()
                              :
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _contactBy(color: Colors.green,
                                fct: () {_openWhatsAppChat();},
                                icon: FontAwesome.whatsapp,
                              ),
                              _contactBy(
                                color: Colors.redAccent,
                                fct: () {_mainTo();},
                                icon: Icons.mail_outline,
                              ),
                              _contactBy(
                                color: Colors.black,
                                fct: () {_callPhoneNumber();},
                                icon: Icons.call,
                              ),
                            ],
                          ),
                          !_isSameUser
                              ?
                          Container()
                              :
                          Center(
                            child: Padding(
                              padding:
                              const EdgeInsets.only(bottom: 30),
                              child: MaterialButton(
                                onPressed: () {
                                  _auth.signOut();
                                  Navigator.push(
                                      context,
                                    MaterialPageRoute(builder: (context) => UserState()));
                                },
                                color: Colors.redAccent,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(13),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text('Logout',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Paulfont',
                                          fontSize: 28,
                                        ),
                                      ),
                                      SizedBox(width: 8,),
                                      Icon(Icons.logout, color: Colors.white,),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}