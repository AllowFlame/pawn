import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

typedef CheckPermission = Future<void> Function();

class BleService {
  BleManager _bleManager;
  Map<String, BleDeviceItem> _deviceList;
  CheckPermission _checkPermissions;
  ValueNotifier<bool> _isScanning;
  ValueNotifier<List<BleDeviceItem>> _devices;

  BleService(CheckPermission checkPermission, ValueNotifier<bool> isScanning, ValueNotifier<List<BleDeviceItem>> devices) {
    _bleManager = BleManager();
    _deviceList = Map();
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
  }

  void doScan() async {
    _deviceList.clear();
    _bleManager.startPeripheralScan().listen((ScanResult result) {
      var name = result.peripheral.name ?? result.advertisementData.localName ?? "Unknown";
      var identifier = result.peripheral.identifier;
      _deviceList.putIfAbsent(identifier, () => BleDeviceItem(name, result.rssi, result.peripheral, result.advertisementData));
      // var foundDevice = _deviceList.any((element) {
      //   if (element.peripheral.identifier == result.peripheral.identifier) {
      //     element.peripheral = result.peripheral;
      //     element.advertisementData = result.advertisementData;
      //     element.rssi = result.rssi;
      //     return true;
      //   }
      //   return false;
      // });
      //
      // if (!foundDevice) {
      //   _deviceList.add(BleDeviceItem(name, result.rssi, result.peripheral, result.advertisementData));
      // }
      _devices.value = _deviceList.entries.map((element) => element.value).toList(growable: false);
    });
    _isScanning.value = false;
  }

  void stopScan() async {
    _bleManager.stopPeripheralScan();
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
          print('connected');
        }
        break;
        case PeripheralConnectionState.connecting: {
          print('connecting');
        }
        break;
        case PeripheralConnectionState.disconnected: {
          print('disconnected');
        }
        break;
        case PeripheralConnectionState.disconnecting: {
          print('disconnecting');
        }
        break;
        default: {
          print('default');
        }
        break;
      }
    });

    try {
      if (await peripheral.isConnected()) {
        print('peripheral.isConnected');
        await peripheral.disconnectOrCancelConnection();
      }
      await peripheral.connect().then((_) {
        peripheral.discoverAllServicesAndCharacteristics().then((_) => peripheral.services())
            .then((services) async {
          print('services');
          for (var service in services) {
            print('service');
            List<Characteristic> characteristics = await service.characteristics();
            for (var characteristic in characteristics) {
              print('characteristic : $characteristic');
              Uint8List packet = await characteristic.read();
              print('packet : $packet');
            }
          }
        });
      });
    } on BleError catch (e) {
      print("BleError caught: ${e.errorCode.value} ${e.reason}");
    } catch (e) {
      if (e is Error) {
        debugPrintStack(stackTrace: e.stackTrace);
      }
      print("${e.runtimeType}: $e");
    }
  }

  void disconnect(Peripheral peripheral) async {
    await peripheral.disconnectOrCancelConnection();
  }

  List<BleDeviceItem> get devices {
    return _deviceList.entries.map((element) => element.value).toList(growable: false);
  }
}

class BleDeviceItem {
  String deviceName;
  Peripheral peripheral;
  int rssi;
  AdvertisementData advertisementData;
  BleDeviceItem(this.deviceName, this.rssi, this.peripheral, this.advertisementData);
}