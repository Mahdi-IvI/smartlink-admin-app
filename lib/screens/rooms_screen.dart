import 'package:flutter/material.dart';
import 'package:smartlink_admin/models/place_model.dart';
import 'package:smartlink_admin/scan_page.dart';

import '../config/config.dart';
import '../models/room_model.dart';
import '../widgets/loading.dart';
import '../widgets/my_text.dart';
import 'add_manager_screen.dart';
import 'add_room_screen.dart';

class RoomsScreen extends StatefulWidget {
  final PlaceModel place;

  const RoomsScreen({super.key, required this.place});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Places"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: StreamBuilder<List<RoomModel>>(
          stream: getRooms(),
          builder: (BuildContext context, roomsSnapshot) {
            if (roomsSnapshot.hasError) {
              return Center(child: Text(roomsSnapshot.error.toString()));
            }

            if (roomsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Loading());
            }

            return ListView.builder(
              itemCount: roomsSnapshot.data!.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ScanPage(
                                    place: widget.place,
                                    room: roomsSnapshot.data![index],
                                  )));
                    },
                    child: Card(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.meeting_room,
                              size: 40,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  H3Text(text: roomsSnapshot.data![index].name),
                                  Text(roomsSnapshot.data![index].location),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            const Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "tag 1",
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddManagerScreen(place: widget.place)));
            },
            child: const Icon(Icons.person_add_alt),
          ),
          const SizedBox(
            height: 15,
          ),
          FloatingActionButton(
            heroTag: "tag2",
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddRoomScreen(place: widget.place)));
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Stream<List<RoomModel>> getRooms() {
    return Config.fireStore
        .collection(Config.placesCollection)
        .doc(widget.place.id)
        .collection(Config.roomsCollection)
        .snapshots()
        .map((roomsSnapshot) {
      return roomsSnapshot.docs.map((room) {
        return RoomModel.fromDocument(room);
      }).toList();
    });
  }
}
