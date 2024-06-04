import 'package:flutter/material.dart';
import 'package:smartlink_admin/config/config.dart';
import 'package:smartlink_admin/screens/add_place_screen.dart';
import 'package:smartlink_admin/screens/rooms_screen.dart';
import 'package:smartlink_admin/widgets/loading.dart';

import 'models/place_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: const Text("Places"),),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: StreamBuilder<List<PlaceModel>>(
          stream: getPlaces(),
          builder: (BuildContext context, placesSnapshot) {
            if (placesSnapshot.hasError) {
              return Center(
                  child: Text(placesSnapshot.error.toString()));
            }

            if (placesSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(child: Loading());
            }

            return ListView.builder(
              itemCount: placesSnapshot.data!.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RoomsScreen(
                                place: placesSnapshot.data![index])));
                  },
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        if(placesSnapshot.data![index].images.isNotEmpty)
                        Image.network(
                          placesSnapshot.data![index].images.first,
                          width: 120,
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                        Expanded(
                          child: Container(

                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  placesSnapshot.data![index].name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                Text(
                                  placesSnapshot
                                      .data![index].description,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>const AddPlaceScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Stream<List<PlaceModel>> getPlaces() {
    return Config.fireStore
        .collection(Config.placesCollection)
        .snapshots()
        .map((placesSnapshot) {
      return placesSnapshot.docs.map((place) {
        return PlaceModel.fromDocument(place);
      }).toList();
    });
  }
}
