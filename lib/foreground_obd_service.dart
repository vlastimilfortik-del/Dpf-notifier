import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'ble_uart.dart';
import 'obd_parser.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ObdForegroundTaskHandler extends TaskHandler {
  final BleUart bleUart = BleUart();
  late ObdParser obdParser;
  final FlutterLocalNotificationsPlugin localNotifications;
  bool regenNotified = false;

  ObdForegroundTaskHandler(this.localNotifications, Map<String, dynamic> pidDb) {
    obdParser = ObdParser(pidDb);
  }

  @override
  Future<void> onStart(DateTime timestamp, Map<String, dynamic>? data) async {
    String deviceName = data?['device_name'] ?? '';
    if (deviceName.isNotEmpty) {
      await bleUart.connectByName(deviceName);
    }
  }

  @override
  Future<void> onEvent(DateTime timestamp, Map<String, dynamic>? data) async {
    if (bleUart.rx != null) {
      await bleUart.write('010C');
      await Future.delayed(Duration(milliseconds: 200));
    }
    Map<String,dynamic> vals = obdParser.parse();
    if (vals.isNotEmpty) {
      if (obdParser.isRegenActive(vals) && !regenNotified) {
        regenNotified = true;
        await _showNotification('DPF regenerace aktivní', 'Please continue driving');
      } else if (!obdParser.isRegenActive(vals) && regenNotified) {
        regenNotified = false;
        await _showNotification('DPF regenerace skončila', 'Regeneration
