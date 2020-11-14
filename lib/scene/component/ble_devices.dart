import 'dart:typed_data';

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
      service.init();
      return null;
    }, const []);

    disconnectAll() async {
      for (var device in devices.value) {
        var peripheral = device.peripheral;
        if (await peripheral.isConnected()) {
          service.disconnect(peripheral);
        }
      }
    }

    list() {
      var deviceList = devices.value;
      return ListView.builder(
        itemCount: deviceList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: ListTile(
              //디바이스 이름과 맥주소 그리고 신호 세기를 표시한다.
              title: Text('$index : ${deviceList[index].deviceName}'),
              subtitle: Text(deviceList[index].peripheral.identifier),
              trailing: Text("${deviceList[index].rssi}"),
            ),
            onTap: () {
              print('onTap: $index');
              service.connect(deviceList[index].peripheral);
            },
            onLongPress: () async {
              const String UART_SERVICE_UUID = "F85F0001-D185-4380-B71D-702B7013A77E";
              const String UART_RX_CHARACTERISTIC_UUID = "F85F0002-D185-4380-B71D-702B7013A77E";
              const String UART_TX_CHARACTERISTIC_UUID = "F85F0003-D185-4380-B71D-702B7013A77E";

              const String UUID_SERVICE = "0000ff01-0000-1000-8000-00805f9b34fb";
              const String C_UUID_READ = "0000ff06-0000-1000-8000-00805f9b34fb";
              const String C_UUID_WRITE = "0000ff05-0000-1000-8000-00805f9b34fb";

              List<int> v = List();
              v.add(0x02);
              v.add(0x01);
              v.add(0x10);
              v.add(0x11);
              Uint8List getVersion = Uint8List.fromList(v);
              print("send msg");
              try {
                await deviceList[index].peripheral.writeCharacteristic(UUID_SERVICE, C_UUID_WRITE, getVersion, false);
                deviceList[index].peripheral.s
              } catch (e) {
                print("error : $e");
              }

            },
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
              label: 'Do Scan',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => service.doScan()
          ),
          SpeedDialChild(
            child: Icon(Icons.bluetooth_disabled),
            backgroundColor: Colors.blue,
            label: 'Stop Scan',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => service.stopScan(),
          ),
          SpeedDialChild(
            child: Icon(Icons.keyboard_voice),
            backgroundColor: Colors.green,
            label: 'disconnect all',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => disconnectAll(),
          ),
        ],
      ),

    );
  }
}
