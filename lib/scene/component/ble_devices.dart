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
    final devices = useState<List<BleDeviceItem>>([]);

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

    BleService service = BleService(_checkPermissions, isScanning, devices);
    useEffect(() {
      // service = BleService(_checkPermissions, isScanning);
      service.init();
      return null;
    }, const []);


    list() {
      var deviceList = devices.value;
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
