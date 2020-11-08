import 'package:flutter/widgets.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

typedef CheckPermission = Future<void> Function();
// _checkPermissions() async {
//   if (Platform.isAndroid) {
//     if (await Permission.contacts.request().isGranted) {
//     }
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.location
//     ].request();
//     print(statuses[Permission.location]);
//   }
// }

class BleService {
  BleManager _bleManager;
  List<BleDeviceItem> _deviceList;
  CheckPermission _checkPermissions;
  ValueNotifier<bool> _isScanning;
  ValueNotifier<List<BleDeviceItem>> _devices;

  BleService(CheckPermission checkPermission, ValueNotifier<bool> isScanning, ValueNotifier<List<BleDeviceItem>> devices) {
    _bleManager = BleManager();
    _deviceList = [];
    _checkPermissions = checkPermission;
    _isScanning = isScanning;
    _devices = devices;
  }

  void init() async {
    await _bleManager.createClient(
        restoreStateIdentifier: "example-restore-state-identifier",
        restoreStateAction: (peripherals) {
          peripherals?.forEach((peripheral) {
            print("Restored peripheral: ${peripheral.name}");
          });
        })
        .catchError((e) => print("Couldn't create BLE client  $e"))
        .then((_) => _checkPermissions()) //BLE 생성 후 퍼미션 체크
        .catchError((e) => print("Permission check error $e"));
    //.then((_) => _waitForBluetoothPoweredOn())
  }

  void doScan() async {
    _deviceList.clear();
    _bleManager.startPeripheralScan().listen((ScanResult result) {
      var name = result.peripheral.name ?? result.advertisementData.localName ?? "Unknown";
      var foundDevice = _deviceList.any((element) {
        if (element.peripheral.identifier == result.peripheral.identifier) {
          element.peripheral = result.peripheral;
          element.advertisementData = result.advertisementData;
          element.rssi = result.rssi;
          return true;
        }
        return false;
      });

      if (!foundDevice) {
        _deviceList.add(BleDeviceItem(name,result.rssi, result.peripheral, result.advertisementData));
      }
      _devices.value = _deviceList;
    });
    _isScanning.value = false;
  }

  void connect(Peripheral peripheral) async {
    bool isConnected = await peripheral.isConnected();
    if(isConnected) {
      print('device is already connected');
      return;
    }

    peripheral.observeConnectionState(emitCurrentValue: true)
        .listen((PeripheralConnectionState connectionState) {
      switch (connectionState) {
        case PeripheralConnectionState.connected: {

        }
        break;
        case PeripheralConnectionState.connecting: {

        }
        break;
        case PeripheralConnectionState.disconnected: {

        }
        break;
        case PeripheralConnectionState.disconnecting: {

        }
        break;
        default: {

        }
        break;
      }
    });

    await peripheral.connect().then((_) {
      peripheral.discoverAllServicesAndCharacteristics().then((_) => peripheral.services())
          .then((services) async {
            for (var service in services) {
              List<Characteristic> characteristics = await service.characteristics();
              for (var caracteristic in characteristics) {

              }
            }
      });
    });
  }


  // _connect(index) async {
  //   // if(_connected) {  //이미 연결상태면 연결 해제후 종료
  //   //   await _curPeripheral?.disconnectOrCancelConnection();
  //   //   return;
  //   // }
  //
  //   //선택한 장치의 peripheral 값을 가져온다.
  //   Peripheral peripheral = _deviceList[index].peripheral;
  //
  //   //해당 장치와의 연결상태를 관촬하는 리스너 실행
  //   peripheral.observeConnectionState(emitCurrentValue: true)
  //       .listen((connectionState) {
  //     // 연결상태가 변경되면 해당 루틴을 탐.
  //     switch(connectionState) {
  //       case PeripheralConnectionState.connected: {  //연결됨
  //         _curPeripheral = peripheral;
  //         setBLEState('connected');
  //       }
  //       break;
  //       case PeripheralConnectionState.connecting: { setBLEState('connecting'); }//연결중
  //       break;
  //       case PeripheralConnectionState.disconnected: { //해제됨
  //         _connected=false;
  //         print("${peripheral.name} has DISCONNECTED");
  //         setBLEState('disconnected');
  //       }
  //       break;
  //       case PeripheralConnectionState.disconnecting: { setBLEState('disconnecting');}//해제중
  //       break;
  //       default:{//알수없음...
  //         print("unkown connection state is: \n $connectionState");
  //       }
  //       break;
  //     }
  //   });
//   await peripheral.connect().then((_) {
//   //연결이 되면 장치의 모든 서비스와 캐릭터리스틱을 검색한다.
//   peripheral.discoverAllServicesAndCharacteristics()
//       .then((_) => peripheral.services())
//       .then((services) async {
//   print("PRINTING SERVICES for ${peripheral.name}");
//   //각각의 서비스의 하위 캐릭터리스틱 정보를 디버깅창에 표시한다.
//   for(var service in services) {
//   print("Found service ${service.uuid}");
//   List<Characteristic> characteristics = await service.characteristics();
//   for( var characteristic in characteristics ) {
//   print("${characteristic.uuid}");
//   }
//   }
//   //모든 과정이 마무리되면 연결되었다고 표시
//   _connected = true;
//   print("${peripheral.name} has CONNECTED");
//   });
//   });
// });

  void stopScan() async {
    _bleManager.stopPeripheralScan();
  }

  List<BleDeviceItem> get devices {
    return _deviceList;
  }
}

class BleDeviceItem {
  String deviceName;
  Peripheral peripheral;
  int rssi;
  AdvertisementData advertisementData;
  BleDeviceItem(this.deviceName, this.rssi, this.peripheral, this.advertisementData);
}