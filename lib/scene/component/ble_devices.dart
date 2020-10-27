import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:pawn/service/ble.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';


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
            title: Text('${index} : ${deviceList[index].deviceName}'),
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
      floatingActionButton: SpeedDial(
        // both default to 16
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        visible: true,
        // If true user is forced to close dial manually
        // by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.bluetooth_searching),
              backgroundColor: Colors.red,
              label: 'First',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => service.doScan()
          ),
          SpeedDialChild(
            child: Icon(Icons.bluetooth_disabled),
            backgroundColor: Colors.blue,
            label: 'Second',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => service.stopScan(),
          ),
          SpeedDialChild(
            child: Icon(Icons.keyboard_voice),
            backgroundColor: Colors.green,
            label: 'Third',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('THIRD CHILD'),
          ),
        ],
      ),

    );
  }
}
