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

  BleService(CheckPermission checkPermission) {
    _bleManager = BleManager();
    _deviceList = [];
    _checkPermissions = checkPermission;
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
    });
  }

  void stopScan() async {
    _bleManager.stopPeripheralScan();
  }

  
}

class BleDeviceItem {
  String deviceName;
  Peripheral peripheral;
  int rssi;
  AdvertisementData advertisementData;
  BleDeviceItem(this.deviceName, this.rssi, this.peripheral, this.advertisementData);
}