import 'dart:convert';
import 'dart:typed_data';

class ObdParser {
  String buffer = '';
  final Map<String, dynamic> pidDb;

  ObdParser(this.pidDb);

  void feed(Uint8List data) {
    String chunk = utf8.decode(data, allowMalformed: true);
    buffer += chunk;
    if (buffer.length > 2000) buffer = buffer.substring(buffer.length - 2000);
  }

  Map<String, dynamic> parse() {
    Map<String, dynamic> results = {};
    pidDb.forEach((key, val) {
      try {
        String mode = val['mode'];
        String pid = val['pid'];
        // Relaxed regex to find mode+pid with or without spaces
        RegExp r1 = RegExp(r'${mode}\\s*${pid}\\s*([0-9A-Fa-f]{2})\\s*([0-9A-Fa-f]{2})');
        RegExp r2 = RegExp(r'${mode}${pid}([0-9A-Fa-f]{4})');
        var m = r1.firstMatch(buffer);
        if (m != null) {
          int a = int.parse(m.group(1)!, radix:16);
          int b = int.parse(m.group(2)!, radix:16);
          int raw = (a*256)+b;
          results[key] = raw;
          return;
        }
        var m2 = r2.firstMatch(buffer);
        if (m2 != null) {
          int valInt = int.parse(m2.group(1)!, radix:16);
          results[key] = valInt;
        }
      } catch (e) {
        // ignore parse errors per PID
      }
    });

    // Mode22 specific parsing examples (soot mass 62 11 4F AA BB)
    var mSoot = RegExp(r'62\\s*11\\s*4F\\s*([0-9A-Fa-f]{2})\\s*([0-9A-Fa-f]{2})').firstMatch(buffer);
    if (mSoot != null) {
      int a = int.parse(mSoot.group(1)!, radix:16);
      int b = int.parse(mSoot.group(2)!, radix:16);
      int raw = a*256+b;
      results['soot_mass_calc_raw'] = raw;
    }
    var mRegen = RegExp(r'62\\s*F1\\s*90\\s*([0-9A-Fa-f]{2})').firstMatch(buffer);
    if (mRegen != null) {
      int flag = int.parse(mRegen.group(1)!, radix:16);
      results['regen_flag'] = (flag & 0x01) == 1 ? 1 : 0;
    }

    if (results.isNotEmpty) buffer = '';
    return results;
  }

  bool isRegenActive(Map<String, dynamic> parsedValues) {
    return parsedValues.containsKey('regen_flag') && parsedValues['regen_flag'] == 1
        || parsedValues.containsKey('soot_mass_calc_raw') && parsedValues['soot_mass_calc_raw'] > 2000;
  }
}
