import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:smartlink_admin/config/config.dart';
import 'package:smartlink_admin/models/place_model.dart';

import '../config/my_colors.dart';
import '../widgets/loading.dart';
import '../widgets/photo_gallery.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<CroppedFile> files = [];
  List<String> imagesDownloadUrl = [];
  List images = [];
  final picker = ImagePicker();
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _addressTextController = TextEditingController();
  final TextEditingController _postCodeTextController = TextEditingController();
  final TextEditingController _cityTextController = TextEditingController();
  final TextEditingController _countryTextController = TextEditingController();
  final TextEditingController _phoneNumberTextController =
      TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _instagramTextController =
      TextEditingController();
  final TextEditingController _facebookTextController = TextEditingController();
  final TextEditingController _starsTextController = TextEditingController();
  final TextEditingController _websiteTextController = TextEditingController();
  final TextEditingController _englishDescriptionTextController =
      TextEditingController();
  final TextEditingController _deutschDescriptionTextController =
      TextEditingController();
  bool groupChatEnabled = false;
  bool newsEnabled = false;
  bool ticketSystemEnabled = false;
  bool showPublic = false;

  bool uploading = false;

  late String newsId;

  @override
  void initState() {
    newsId = DateTime.now().millisecondsSinceEpoch.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double sSize = size.width / 4;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new Place"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Images",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        )),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        for (int i = 0; i < images.length; i++)
                          Container(
                            margin: const EdgeInsets.all(4),
                            width: sSize,
                            height: sSize,
                            child: Stack(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PhotoGallery(
                                                  imagesUrl: [images[i]],
                                                  url: true,
                                                  index: 0,
                                                )));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            width: 2, color: MyColors.border),
                                        image: DecorationImage(
                                            image: NetworkImage(images[i]),
                                            fit: BoxFit.cover)),
                                  ),
                                ),
                                Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Opacity(
                                      opacity: 0.7,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            images.removeAt(i);
                                          });
                                        },
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: MyColors.border,
                                            borderRadius:
                                                BorderRadius.circular(500),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.close,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        for (int i = 0; i < files.length; i++)
                          Container(
                            margin: const EdgeInsets.all(4),
                            width: sSize,
                            height: sSize,
                            child: Stack(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PhotoGallery(
                                                    imagesUrl: [
                                                      File(files[i].path)
                                                    ],
                                                    url: false,
                                                    index: 0)));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            width: 2, color: MyColors.border),
                                        image: DecorationImage(
                                            image:
                                                FileImage(File(files[i].path)),
                                            fit: BoxFit.cover)),
                                  ),
                                ),
                                Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Opacity(
                                      opacity: 0.7,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            files.removeAt(i);
                                          });
                                        },
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: MyColors.border,
                                            borderRadius:
                                                BorderRadius.circular(500),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.close,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        for (int i = 0;
                            i < 6 - files.length - images.length;
                            i++)
                          InkWell(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              takeImage(context);
                            },
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              width: sSize,
                              height: sSize,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: MyColors.border, width: 2),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Icon(
                                    MdiIcons.cameraPlusOutline,
                                    size: sSize / 2.5,
                                  ),
                                  const Text("Add Photo")
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
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
                              controller: _addressTextController,
                              decoration: InputDecoration(
                                label: const Text("Address"),
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
                              controller: _postCodeTextController,
                              decoration: InputDecoration(
                                label: const Text("PostCode"),
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
                              controller: _cityTextController,
                              decoration: InputDecoration(
                                label: const Text("city"),
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
                              controller: _countryTextController,
                              decoration: InputDecoration(
                                label: const Text("country"),
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
                              controller: _phoneNumberTextController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                label: const Text("Phone Number"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: MyColors.border, width: 2.0),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: kToolbarHeight / 3,
                            ),
                            TextFormField(
                              controller: _emailTextController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                label: const Text("Email Address"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: MyColors.border, width: 2.0),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: kToolbarHeight / 3,
                            ),
                            TextFormField(
                              controller: _instagramTextController,
                              decoration: InputDecoration(
                                label: const Text("Instagram"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: MyColors.border, width: 2.0),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: kToolbarHeight / 3,
                            ),
                            TextFormField(
                              controller: _facebookTextController,
                              decoration: InputDecoration(
                                label: const Text("facebook"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: MyColors.border, width: 2.0),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: kToolbarHeight / 3,
                            ),
                            TextFormField(
                              controller: _starsTextController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                label: const Text("Stars"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: MyColors.border, width: 2.0),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: kToolbarHeight / 3,
                            ),
                            TextFormField(
                              controller: _websiteTextController,
                              keyboardType: TextInputType.url,
                              decoration: InputDecoration(
                                label: const Text("Website"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: MyColors.border, width: 2.0),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: kToolbarHeight / 3,
                            ),
                            TextFormField(
                              controller: _englishDescriptionTextController,
                              decoration: InputDecoration(
                                label: const Text("Description"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: MyColors.border, width: 2.0),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: kToolbarHeight / 3,
                            ),
                            TextFormField(
                              controller: _deutschDescriptionTextController,
                              decoration: InputDecoration(
                                label: const Text("Beschreibung"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: MyColors.border, width: 2.0),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: kToolbarHeight / 3,
                            ),
                            ListTile(
                              title: const Text("Enable news"),
                              onTap: () {
                                setState(() {
                                  newsEnabled = !newsEnabled;
                                });
                              },
                              trailing: Icon(newsEnabled
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank),
                            ),
                            ListTile(
                              title: const Text("Enable TicketSystem"),
                              onTap: () {
                                setState(() {
                                  ticketSystemEnabled = !ticketSystemEnabled;
                                });
                              },
                              trailing: Icon(ticketSystemEnabled
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank),
                            ),
                            ListTile(
                              title: const Text("Enable Group Chat"),
                              onTap: () {
                                setState(() {
                                  groupChatEnabled = !groupChatEnabled;
                                });
                              },
                              trailing: Icon(groupChatEnabled
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank),
                            ),
                            ListTile(
                              title: const Text("Enable show Public"),
                              onTap: () {
                                setState(() {
                                  showPublic = !showPublic;
                                });
                              },
                              trailing: Icon(showPublic
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

  takeImage(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text("Camera"),
                  onTap: () => {captureWithCamera()}),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Gallery"),
                onTap: () => {pickPhotoFromGallery()},
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text("return"),
                onTap: () => {Navigator.pop(context)},
              ),
            ],
          );
        });
  }

  captureWithCamera() async {
    Navigator.pop(context);
    final imageFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (imageFile != null) {
        _cropImage(imageFile);
      } else {
        if (kDebugMode) {
          print('No image selected.');
        }
      }
    });
  }

  pickPhotoFromGallery() async {
    Navigator.pop(context);
    final imageFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (imageFile != null) {
        _cropImage(imageFile);
      } else {
        if (kDebugMode) {
          print('No image selected.');
        }
      }
    });
  }

  Future<Null> _cropImage(imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: MyColors.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        IOSUiSettings(
          aspectRatioPickerButtonHidden: false,
          aspectRatioLockEnabled: true,
          aspectRatioLockDimensionSwapEnabled: true,
          title: '',
        )
      ],
    );
    if (croppedFile != null) {
      setState(() {
        files.add(croppedFile);
      });
    }
  }

  Future upload() async {
    for (int i = 0; i < images.length; i++) {
      imagesDownloadUrl.add(images[i]);
    }
    for (int i = 0; i < files.length; i++) {
      await uploadImage(File(files[i].path), "File${i + images.length}");
    }
  }

  uploadImage(fileImage, String fileName) async {
    try {
      await Config.firebaseStorage
          .ref()
          .child(
              "${Config.placesCollection}/$newsId/images/$newsId/image_${newsId}_$fileName.jpg")
          .putFile(fileImage);
      String downloadURL = await Config.firebaseStorage
          .ref(
              '${Config.placesCollection}/$newsId/images/$newsId/image_${newsId}_$fileName.jpg')
          .getDownloadURL();
      if (kDebugMode) {
        print(downloadURL);
      }
      imagesDownloadUrl.add(downloadURL);
    } catch (e) {
      if (kDebugMode) {

        print(e.toString());
      }
    }
  }

  addInfo() async {
    setState(() {
      uploading = true;
    });

    await upload().then((value){
      saveInfo();
    });
  }

  saveInfo() async {
    try {
      final itemRef = Config.fireStore.collection(Config.placesCollection);
      PlaceModel placeModel = PlaceModel(
          id: "id",
          name: _nameTextController.text.trim(),
          address: _addressTextController.text.trim(),
          city: _cityTextController.text.trim(),
          country: _countryTextController.text.trim(),
          description: _englishDescriptionTextController.text.trim(),
          descriptionDe: _deutschDescriptionTextController.text.trim(),
          groupChatEnabled: groupChatEnabled,
          newsEnabled: newsEnabled,
          ticketSystemEnabled: ticketSystemEnabled,
          images: imagesDownloadUrl,
          phoneNumbers: _phoneNumberTextController.text.split(","),
          email: _emailTextController.text.trim(),
          instagram: _instagramTextController.text.trim(),
          facebook: _facebookTextController.text.trim(),
          website: _websiteTextController.text.trim(),
          postCode: _postCodeTextController.text.trim(),
          showPublic: showPublic,
          stars: _starsTextController.text.trim().isEmpty? 0 : int.parse(_starsTextController.text.trim()));
      itemRef.add(placeModel.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New Place added Successfully")));
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        print("Errroororrororororo");
        print(e.toString());
      }
    }
  }
}
