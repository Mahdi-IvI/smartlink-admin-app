import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartlink_admin/widgets/loading.dart';
import 'package:smartlink_admin/widgets/my_text.dart';

import 'config/config.dart';
import 'my_home_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneNumberTextEditingController =
      TextEditingController();
  final TextEditingController _usernameTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _smsCodeTextEditingController =
      TextEditingController();
  bool codeSent = false;
  String? _verificationId;
  String? placeId;
  String? managerId;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const H3Text(
          text: "Sign in",
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 26, horizontal: 36),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const H2Text(text: "Sign in"),
                    const SizedBox(
                      height: kToolbarHeight,
                    ),
                    if (codeSent)
                      TextFormField(
                        controller: _smsCodeTextEditingController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                            label: Text("code"),
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "this field is required!";
                          }
                          return null;
                        },
                      ),
                    if (!codeSent)
                      TextFormField(
                        controller: _phoneNumberTextEditingController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                            label: Text("Phone number"),
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 9) {
                            return "this field is required!";
                          }
                          return null;
                        },
                      ),
                    if (!codeSent)
                      const SizedBox(
                        height: kToolbarHeight / 2,
                      ),
                    if (!codeSent)
                      TextFormField(
                        controller: _usernameTextEditingController,
                        decoration: const InputDecoration(
                            label: Text("Username"),
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "this field is required!";
                          }
                          return null;
                        },
                      ),
                    if (!codeSent)
                      const SizedBox(
                        height: kToolbarHeight / 2,
                      ),
                    if (!codeSent)
                      TextFormField(
                        controller: _passwordTextEditingController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            label: Text("Password"),
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "this field is required!";
                          }
                          return null;
                        },
                      ),
                    const SizedBox(
                      height: kToolbarHeight,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // <-- Radius
                          ),
                        ),
                        onPressed: () {
                          if (!_loading &&
                              _formKey.currentState!.validate()) {
                            if (codeSent) {
                              signInWithCode();
                            } else {
                              signIn();
                            }
                          }
                        },
                        child: SizedBox(
                          height: kToolbarHeight,
                          width: size.width / 2 / 2,
                          child: _loading
                              ? const WhiteLoading()
                              : const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    H4Text(
                                      text: "sign in",
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void signIn() async {
    var passToBytes = utf8.encode(_passwordTextEditingController.text.trim());
    var bytesToHash = sha256.convert(passToBytes);
    print("//////////////****************+");
    print("password $bytesToHash");

    setState(() {
      _loading = true;
    });
    await Config.fireStore
        .collection(Config.managerCollection)
        .where(Config.username,
            isEqualTo: _usernameTextEditingController.text.trim())
        .where(Config.password, isEqualTo: bytesToHash.toString())
        .get()
        .then((QuerySnapshot snapshot) async {
      if (snapshot.size < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Incorrect Username or Password")));
        setState(() {
          _loading = false;
        });
      } else {
        await Config.auth.verifyPhoneNumber(
          phoneNumber: _phoneNumberTextEditingController.text.trim(),
          verificationCompleted: (PhoneAuthCredential credential) async {
            await Config.auth
                .signInWithCredential(credential)
                .then((value) async {
              await Config.fireStore
                  .collection(Config.managerCollection)
                  .doc(managerId)
                  .collection(Config.loginLogsCollection)
                  .add({
                Config.uid: Config.auth.currentUser!.uid,
                Config.loginDate: DateTime.now()
              }).whenComplete(() {
                setState(() {
                  _loading = false;
                });

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                    (route) => false);
              });
            });
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() {
              _loading = false;
            });
            if (kDebugMode) {
              print(e.code);
            }
            if (e.code == 'invalid-phone-number') {
              if (kDebugMode) {
                print("invalid phone number");
              }
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              codeSent = true;
              _loading = false;
              _verificationId = verificationId;
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    });
  }

  signInWithCode() async {
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _smsCodeTextEditingController.text.trim());

    // Sign the user in (or link) with the credential
    if (mounted) {
      await Config.auth.signInWithCredential(credential).then((value) async {
        if (kDebugMode) {
          print("result: $value");
        }
        await Config.fireStore
            .collection(Config.managerCollection)
            .doc(managerId)
            .collection(Config.loginLogsCollection)
            .add({
          Config.uid: Config.auth.currentUser!.uid,
          Config.loginDate: DateTime.now()
        }).whenComplete(() {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
              (route) => false);
        });
      });
    }
  }
}
