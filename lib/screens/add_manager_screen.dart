import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartlink_admin/models/manager_model.dart';
import 'package:smartlink_admin/models/place_model.dart';

import '../config/config.dart';
import '../config/my_colors.dart';
import '../widgets/loading.dart';

class AddManagerScreen extends StatefulWidget {
  final PlaceModel place;

  const AddManagerScreen({super.key, required this.place});

  @override
  State<AddManagerScreen> createState() => _AddManagerScreenState();
}

class _AddManagerScreenState extends State<AddManagerScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  bool public = false;
  bool status = false;

  bool uploading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new Manager"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: kToolbarHeight / 3,
                            ),
                            TextFormField(
                              controller: _usernameTextController,
                              decoration: InputDecoration(
                                label: const Text("Username"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: MyColors.border, width: 2.0),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "This field is required!";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: kToolbarHeight / 3,
                            ),
                            TextFormField(
                              controller: _passwordTextController,
                              decoration: InputDecoration(
                                label: const Text("Password"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: MyColors.border, width: 2.0),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "This field is required!";
                                }
                                return null;
                              },
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: Container(
                height: 50,
                padding: const EdgeInsets.all(8.0),
                width: size.width,
                child: uploading
                    ? const WhiteLoading()
                    : const Center(
                        child: Text(
                          "Submit",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              onPressed: () {
                if (!uploading) {
                  if (_formKey.currentState!.validate()) {
                    addInfo();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please fill all required Fields!")));
                  }
                }
              }),
        ],
      ),
    );
  }

  addInfo() async {
    setState(() {
      uploading = true;
    });

    saveInfo();
  }

  saveInfo() async {
    var passToBytes = utf8.encode(_passwordTextController.text.trim());
    var bytesToHash = sha256.convert(passToBytes);
    try {
      final itemRef = Config.fireStore.collection(Config.managerCollection);
      ManagerModel manager = ManagerModel(
          id: "id",
          username: _usernameTextController.text.trim(),
          password: bytesToHash.toString(),
          placeId: widget.place.id);
      itemRef.add(manager.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New manager added Successfully")));
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
