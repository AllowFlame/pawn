import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:pawn/service/ble.dart';

class BleDevicesWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final isScanning = useState<bool>(false);

    _checkPermissions() async {
      if (Platform.isAndroid) {
        if (await Permission.contacts.request().isGranted) {
        }
        Map<Permission, PermissionStatus> statuses = await [
          Permission.location
        ].request();
        print(statuses[Permission.location]);
      }
    }

    BleService service;
    useEffect(() {
      service = BleService(_checkPermissions);
      service.init();

    }, const []);


    list() {
      var deviceList = service.devices;
      return ListView.builder(
        itemCount: deviceList.length,
        itemBuilder: (context, index) {
          return ListTile(
            //디바이스 이름과 맥주소 그리고 신호 세기를 표시한다.
            title: Text(deviceList[index].deviceName),
            subtitle: Text(deviceList[index].peripheral.identifier),
            trailing: Text("${deviceList[index].rssi}"),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ble scan'),
    ),
    body: Center(
    child: list(),
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: service.doScan,
        child: Icon(Icons.bluetooth_searching),
      ),
    );
  }
}
