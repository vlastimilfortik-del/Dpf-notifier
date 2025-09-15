import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleUart {
  final FlutterBluePlus fb = FlutterBluePlus.instance;
  BluetoothDevice? device;
  BluetoothCharacteristic? tx;
  BluetoothCharacteristic? rx;

  static final Guid nusService = Guid('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');
  static final Guid nusRxChar = Guid('6E400002-B5A3-F393-E0A9-E50E24DCCA9E');
  static final Guid nusTxChar = Guid('6E400003-B5A3-F393-E0A9-E50E24DCCA9E');

  Future<bool> connectByName(String name) async {
    await fb.startScan(timeout: const Duration(seconds: 4));
    var subs = await fb.scanResults.first;
    var found = subs.firstWhere((r) => r.device.name == name, orElse: () => null);
    await fb.stopScan();
    if (found == null) return false;
    device = found.device;
    await device!.connect();
    var services = await device!.discoverServices();
    for (var s in services) {
      if (s.uuid == nusService) {
        for (var c in s.characteristics) {
          if (c.uuid == nusRxChar) tx = c;
          if (c.uuid == nusTxChar) rx = c;
        }
      }
    }
    if (rx != null) {
      await rx!.setNotifyValue(true);
      rx!.value.listen((d) => print("[BLE] ${utf8.decode(d)}"));
    }
    return true;
  }

  Future<void> write(String cmd) async {
    if (tx != null) {
      await tx!.write(utf8.encode(cmd + '\r'), withoutResponse: true);
    }
  }

  Future<void> disconnect() async {
    if (device != null) {
      await device!.disconnect();
      device = null; tx = null; rx = null;
    }
  }
}
