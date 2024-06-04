import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smartlink_admin/config/providers.dart';
import 'package:smartlink_admin/models/place_model.dart';
import 'package:smartlink_admin/models/room_model.dart';

import "../utils/my_snack_bar.dart";

class CharacteristicTile extends ConsumerStatefulWidget {
  final PlaceModel place;
  final RoomModel room;
  final BluetoothCharacteristic characteristic;

  const CharacteristicTile(
      {super.key,
      required this.characteristic,
      required this.place,
      required this.room});

  @override
  CharacteristicTileState createState() => CharacteristicTileState();
}

class CharacteristicTileState extends ConsumerState<CharacteristicTile> {
  List<int> _value = [];

  late StreamSubscription<List<int>> _lastValueSubscription;
  late String uuid = '0x${widget.characteristic.uuid.str.toUpperCase()}';
  late bool write = widget.characteristic.properties.write;
  NFCTag? _tag;
  String? _result, _mifareResult;

  @override
  void initState() {
    if (uuid == "0xFF03") {
      writePlaceId();
    } else if (uuid == "0xFF04") {
      writeRoomId();
    }
    super.initState();
    _lastValueSubscription =
        widget.characteristic.lastValueStream.listen((value) {
      _value = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();
    super.dispose();
  }

  BluetoothCharacteristic get c => widget.characteristic;

  Future onWritePressed() async {
    _showMyDialog();
  }

  Widget buildUuid(BuildContext context) {
    return Text(
      uuid == "0xFF01"
          ? 'Wifi Name'
          : uuid == "0xFF02"
              ? "Wifi Password"
              : uuid == "0xFF03"
                  ? "Place Id":uuid == "0xFF04"
          ? "Room Id"
                  : "Tag Id",
    );
  }

  Widget buildValue(BuildContext context) {
    String data = utf8.decode(_value);
    return Text(data, style: const TextStyle(fontSize: 13, color: Colors.grey));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: write && uuid != "0xFF03" && uuid != "0xFF04"  && uuid != "0xFF05"
          ? IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await onWritePressed();
                if (mounted) {
                  setState(() {});
                }
              },
            )
          : write && uuid == "0xFF05"?         ElevatedButton(
        onPressed: () async {
          try {
            NFCTag tag = await FlutterNfcKit.poll();
            setState(() {
              _tag = tag;
            });
            await FlutterNfcKit.setIosAlertMessage(
                "Working on it...");
            _mifareResult = null;
            if (tag.standard == "ISO 14443-4 (Type B)") {
              String result1 =
              await FlutterNfcKit.transceive("00B0950000");
              String result2 = await FlutterNfcKit.transceive(
                  "00A4040009A00000000386980701");
              setState(() {
                _result = '1: $result1\n2: $result2\n';
              });
            } else if (tag.type == NFCTagType.iso18092) {
              String result1 =
              await FlutterNfcKit.transceive("060080080100");
              setState(() {
                _result = '1: $result1\n';
              });
            } else if (tag.ndefAvailable ?? false) {
              var ndefRecords = await FlutterNfcKit.readNDEFRecords();
              var ndefString = '';
              for (int i = 0; i < ndefRecords.length; i++) {
                ndefString += '${i + 1}: ${ndefRecords[i]}\n';
              }
              setState(() {
                _result = ndefString;
              });
            } else if (tag.type == NFCTagType.webusb) {
              var r = await FlutterNfcKit.transceive(
                  "00A4040006D27600012401");
              print(r);
            }
          } catch (e) {
            setState(() {
              _result = 'error: $e';
            });
          }

          // Pretend that we are working
          if (!kIsWeb) sleep(const Duration(seconds: 1));
          await FlutterNfcKit.finish(iosAlertMessage: "Finished!");
          writeTagId();
        },
        child: const Text('Start polling'),
      ) : null,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildUuid(context),
          buildValue(context),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }

  Future<void> _showMyDialog() async {
    TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              uuid == "0xFF01" ? 'Enter Wifi Name' : "Enter Wifi Password"),
          content: TextField(
            controller: controller,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('write'),
              onPressed: () async {
                try {
                  await c.write(utf8.encode(controller.text.trim()),
                      withoutResponse: c.properties.writeWithoutResponse);
                  MySnackBar.show(ABC.c, "Write: Success", success: true);
                  if (c.properties.read) {
                    await c.read();
                  }
                } catch (e) {
                  MySnackBar.show(ABC.c, prettyException("Write Error:", e),
                      success: false);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void writePlaceId() async {
    try {
      await c.write(utf8.encode(widget.place.id),
          withoutResponse: c.properties.writeWithoutResponse);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      MySnackBar.show(ABC.c, prettyException("Write Error:", e),
          success: false);
    }
  }

  void writeRoomId() async {
    try {
      await c.write(utf8.encode(widget.room.id),
          withoutResponse: c.properties.writeWithoutResponse);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      MySnackBar.show(ABC.c, prettyException("Write Error:", e),
          success: false);
    }
  }

  void writeTagId() async {
    if (_tag != null) {
      ref.read(tagIdProvider.notifier).state = _tag!.id;
      try {
        await c.write(utf8.encode(_tag!.id),
            withoutResponse: c.properties.writeWithoutResponse);
        if (c.properties.read) {
          await c.read();
        }
      } catch (e) {
        MySnackBar.show(ABC.c, prettyException("Write Error:", e),
            success: false);
      }
    }
  }


}
