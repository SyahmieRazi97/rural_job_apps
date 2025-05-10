import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rural_jobs_app/LoginPage/loginscreen.dart';
import 'package:rural_jobs_app/Services/global_methods.dart';
import 'package:rural_jobs_app/Services/global_variables.dart';

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  final TextEditingController _fullNameController = TextEditingController(text: '');
  final TextEditingController _emailTextController = TextEditingController(text: '');
  final TextEditingController _passTextController = TextEditingController(text: '');
  final TextEditingController _phoneNumberController = TextEditingController(text: '');
  final TextEditingController _locationController = TextEditingController(text: '');

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _positionCPFocusNode = FocusNode();

  final _signUpFormKey = GlobalKey<FormState>();
  bool _obscureText = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String _selectedRole = 'Seeker'; // Default role

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _phoneNumberController.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _positionCPFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.linear)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((animationStatus) {
        if (animationStatus == AnimationStatus.completed) {
          _animationController.reset();
          _animationController.forward();
        }
      });
    _animationController.forward();
    super.initState();
  }

  void _submitFormOnSignUp() async {
    final isValid = _signUpFormKey.currentState!.validate();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailTextController.text.trim().toLowerCase(),
          password: _passTextController.text.trim(),
        );
        final User? user = _auth.currentUser;
        final _uid = user!.uid;
        FirebaseFirestore.instance.collection('users').doc(_uid).set({
          'id': _uid,
          'name': _fullNameController.text,
          'email': _emailTextController.text,
          'phoneNumber': _phoneNumberController.text,
          'location': _locationController.text,
          'role': _selectedRole,
          'createdAt': Timestamp.now(),
        });
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      } catch (error) {
        setState(() {_isLoading = false;});
        GlobalMethods.showErrorDialog(error: error.toString(), ctx: context);
      }
    }
    setState(() {_isLoading = false;});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          /*CachedNetworkImage(
            imageUrl: signUpUrlImage,
            placeholder: (context, url) => Image.asset(
              'assets/images/wallpaper.jpg',
              fit: BoxFit.fill),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value, 0),),*/
          Container(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: ListView(
                children: [
                  Form(
                    key: _signUpFormKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_emailFocusNode),
                          keyboardType: TextInputType.name,
                          controller: _fullNameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your name';
                            }
                            else {return null;}
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Full name / Company name',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),),
                            errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red),),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_passFocusNode),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailTextController,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'Please enter a valid Email address';
                            }
                            else {return null;}
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),),
                            errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red),),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_phoneNumberFocusNode),
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passTextController,
                          obscureText: !_obscureText,
                          validator: (value) {
                            if (value!.isEmpty || value.length < 7) {
                              return 'Please enter a valid password';
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {_obscureText = !_obscureText;});
                              },
                              child: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.white,),
                            ),
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.white),
                            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),),
                            errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red),),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_positionCPFocusNode),
                          keyboardType: TextInputType.phone,
                          controller: _phoneNumberController,
                          validator: (value) {
                            if (value!.isEmpty) {return 'Please enter your phone number';
                            }
                            else {return null;}
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Phone Number',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),),
                            errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red),),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_positionCPFocusNode),
                          keyboardType: TextInputType.text,
                          controller: _locationController,
                          validator: (value) {
                            if (value!.isEmpty) {return 'Please enter your job address';
                            }
                            else {return null;}
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Job Address / Your Address',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white),),
                            errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red),),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Role:',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,),
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: 'Seeker',
                                  groupValue: _selectedRole,
                                  onChanged: (String? value) {
                                    setState(() {_selectedRole = value!;});
                                  },
                                  activeColor: Colors.green,
                                ),
                                const Text('Seeker',
                                  style: TextStyle(color: Colors.white, fontSize: 16,),
                                ),
                                Radio(
                                  value: 'Employer',
                                  groupValue: _selectedRole,
                                  onChanged: (String? value) {
                                    setState(() {_selectedRole = value!;});
                                  },
                                  activeColor: Colors.green,
                                ),
                                const Text('Employer', style: TextStyle(color: Colors.white, fontSize: 16,),),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        _isLoading
                            ? Center(
                              child: Container(width: 70, height: 70,
                                child: const CircularProgressIndicator(),
                          ),
                        )
                            : MaterialButton(
                            onPressed: () {_submitFormOnSignUp();},
                            color: Colors.green,
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13),),
                              child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                  Text('SignUp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20,),)
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Center(child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Already have an account?',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16,),
                                ),
                                const TextSpan(text: '      '),
                                TextSpan(recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()),);
                                    },
                                  text: 'Login',
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16,),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}