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
  }
}