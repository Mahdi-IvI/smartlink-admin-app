import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Config{
  static const String logoAddress = 'https://firebasestorage.googleapis.com/v0/b/smartlink-pro.appspot.com/o/logo.png?alt=media&token=a983ec96-3810-4b90-bbd2-510f1504dc20';

  static late FirebaseAuth auth;
  static late FirebaseFirestore fireStore;
  static late FirebaseApp firebaseApp;
  static late FirebaseStorage firebaseStorage;
  //static late SharedPreferences sharedPreferences;

  static String placesCollection = "places";
  static String name = "name";
  static String description = "description";
  static String descriptionDe = "descriptionDe";
  static String stars = "stars";
  static String images = "images";
  static String showPublic = "showPublic";
  static String address = "address";
  static String city = "city";
  static String postCode = "postCode";
  static String country = "country";
  static String groupChatEnabled = "groupChatEnabled";
  static String ticketSystemEnabled = "ticketSystemEnabled";
  static String newsEnabled = "newsEnabled";
  static String instagram = "instagram";
  static String facebook = "facebook";
  static String email = "email";
  static String website = "website";
  static String phoneNumbers = "phoneNumbers";

  static String roomsCollection = "rooms";
  static const String id = "id";
  static const String status = "status";
  static const String public = "public";
  static const String location = "location";


  static const String allowedTags = "allowedTags";
  static const String tagId = "tagId";

  static const String managerCollection = 'managers';
  static const String username = 'username';
  static const String password = 'password';
  static const String placeId = 'placeId';

  static String loginLogsCollection = "loginLogs";
  static String loginDate = "loginDate";
  static const String uid = 'uid';
}