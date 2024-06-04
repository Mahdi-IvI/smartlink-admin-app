import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smartlink_admin/config/config.dart';
import 'package:smartlink_admin/config/providers.dart';
import 'package:smartlink_admin/models/room_model.dart';

import '../config/my_colors.dart';
import '../models/place_model.dart';
import '../widgets/service_tile.dart';
import '../widgets/characteristic_tile.dart';
import '../utils/my_snack_bar.dart';
import '../utils/extra.dart';

class DeviceScreen extends ConsumerStatefulWidget {
  final BluetoothDevice device;
  final PlaceModel place;
  final RoomModel room;

  const DeviceScreen(
      {super.key,
      required this.device,
      required this.place,
      required this.room});

  @override
  DeviceScreenState createState() => DeviceScreenState();
}

class DeviceScreenState extends ConsumerState<DeviceScreen> {
  int? _rssi;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  List<BluetoothService> _services = [];
  bool _isDiscoveringServices = false;
  bool _isConnecting = false;
  bool _isDisconnecting = false;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.device.connectionState.listen((state) async {
      _connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        _services = []; // must rediscover services
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await widget.device.readRssi();
      }
      if (mounted) {
        setState(() {});
      }
    });

    _isConnectingSubscription = widget.device.isConnecting.listen((value) {
      _isConnecting = value;
      if (mounted) {
        setState(() {});
      }
    });

    _isDisconnectingSubscription =
        widget.device.isDisconnecting.listen((value) {
      _isDisconnecting = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Future onConnectPressed() async {
    try {
      await widget.device.connectAndUpdateStream();
      MySnackBar.show(ABC.c, "Connect: Success", success: true);
    } catch (e) {
      if (e is FlutterBluePlusException &&
          e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        MySnackBar.show(ABC.c, prettyException("Connect Error:", e),
            success: false);
      }
    }
  }

  Future onCancelPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream(queue: false);
      MySnackBar.show(ABC.c, "Cancel: Success", success: true);
    } catch (e) {
      MySnackBar.show(ABC.c, prettyException("Cancel Error:", e),
          success: false);
    }
  }

  Future onDisconnectPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream();
      MySnackBar.show(ABC.c, "Disconnect: Success", success: true);
    } catch (e) {
      MySnackBar.show(ABC.c, prettyException("Disconnect Error:", e),
          success: false);
    }
  }

  Future onDiscoverServicesPressed() async {
    if (mounted) {
      setState(() {
        _isDiscoveringServices = true;
      });
    }
    try {
      _services = await widget.device.discoverServices();
      MySnackBar.show(ABC.c, "Discover Services: Success", success: true);
    } catch (e) {
      MySnackBar.show(ABC.c, prettyException("Discover Services Error:", e),
          success: false);
    }
    if (mounted) {
      setState(() {
        _isDiscoveringServices = false;
      });
    }
  }

  List<Widget> _buildServiceTiles(BuildContext context, BluetoothDevice d) {
    return _services
        .where((s) => s.characteristics.first.properties.write)
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map((c) => _buildCharacteristicTile(c))
                .toList(),
          ),
        )
        .toList();
  }

  CharacteristicTile _buildCharacteristicTile(BluetoothCharacteristic c) {
    return CharacteristicTile(
      characteristic: c,
      place: widget.place,
      room: widget.room,
    );
  }

  Widget buildSpinner(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(14.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black12,
          color: Colors.black26,
        ),
      ),
    );
  }

  Widget buildRemoteId(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('${widget.device.remoteId}'),
    );
  }

  Widget buildRssiTile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isConnected
            ? const Icon(Icons.bluetooth_connected)
            : const Icon(Icons.bluetooth_disabled),
        Text(((isConnected && _rssi != null) ? '${_rssi!} dBm' : ''),
            style: Theme.of(context).textTheme.bodySmall)
      ],
    );
  }

  Widget buildGetServices(BuildContext context) {
    return IndexedStack(
      index: (_isDiscoveringServices) ? 1 : 0,
      children: <Widget>[
        TextButton(
          onPressed: onDiscoverServicesPressed,
          child: const Text("Get Services"),
        ),
        const IconButton(
          icon: SizedBox(
            width: 18.0,
            height: 18.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey),
            ),
          ),
          onPressed: null,
        )
      ],
    );
  }

  Widget buildConnectButton(BuildContext context) {
    return Row(children: [
      if (_isConnecting || _isDisconnecting) buildSpinner(context),
      TextButton(
          onPressed: _isConnecting
              ? onCancelPressed
              : (isConnected ? onDisconnectPressed : onConnectPressed),
          child: Text(
            _isConnecting ? "CANCEL" : (isConnected ? "DISCONNECT" : "CONNECT"),
          ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ScaffoldMessenger(
      key: MySnackBar.snackBarKeyC,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.device.platformName),
          actions: [buildConnectButton(context)],
        ),
        body: Column(
          children: <Widget>[
            buildRemoteId(context),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: buildRssiTile(context),
                    title: Text(
                        'Device is ${_connectionState.toString().split('.')[1]}.'),
                    trailing: buildGetServices(context),
                  ),

            ..._buildServiceTiles(context, widget.device),
    ],
    ),),
            if (widget.room.public != true)
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
                    child: const Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  onPressed: () {
                    String? tagId = ref.read(tagIdProvider);
                    if (tagId != null) {
                      Config.fireStore
                          .collection(Config.placesCollection)
                          .doc(widget.place.id)
                          .collection(Config.roomsCollection)
                          .where(Config.public, isEqualTo: true)
                          .get()
                          .then((QuerySnapshot snapshot) {
                        for (var doc in snapshot.docs) {
                          RoomModel publicRoom = RoomModel.fromDocument(doc);
                          Config.fireStore
                              .collection(Config.placesCollection)
                              .doc(widget.place.id)
                              .collection(Config.roomsCollection)
                              .doc(publicRoom.id)
                              .collection(Config.allowedTags)
                              .add({Config.tagId: tagId});
                        }
                        ref.read(tagIdProvider.notifier).state = null;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Door added Successfully!")));
                        Navigator.pop(context);
                      });
                    }
                  }),
          ],
        ),
      ),
    );
  }
}
