import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartlink_admin/models/place_model.dart';
import 'package:smartlink_admin/models/room_model.dart';

import '../config/config.dart';
import '../config/my_colors.dart';
import '../widgets/loading.dart';

class AddRoomScreen extends StatefulWidget {
  final PlaceModel place;
  const AddRoomScreen({super.key, required this.place});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen>  {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _locationTextController = TextEditingController();

  bool public = false;
  bool status = false;

  bool uploading = false;


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new Room"),
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
                              controller: _nameTextController,
                              decoration: InputDecoration(
                                label: const Text("Name"),
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
                              controller: _locationTextController,
                              decoration: InputDecoration(
                                label: const Text("Location"),
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
                            ListTile(
                              title: const Text("public"),
                              onTap: () {
                                setState(() {
                                  public = !public;
                                });
                              },
                              trailing: Icon(public
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank),
                            ),
                            ListTile(
                              title: const Text("Status"),
                              onTap: () {
                                setState(() {
                                  status = !status;
                                });
                              },
                              trailing: Icon(status
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank),
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
    try {
      final itemRef = Config.fireStore.collection(Config.placesCollection).doc(widget.place.id).collection(Config.roomsCollection);
      RoomModel roomModel = RoomModel(
          id: "id",
          name: _nameTextController.text.trim(),
          location: _locationTextController.text.trim(),
          public: public,
          status: status,
         );
      itemRef.add(roomModel.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New Place added Successfully")));
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
