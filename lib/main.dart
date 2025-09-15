import 'package:flutter/material.dart';
import 'localization.dart';
import 'blinking_alert.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('cs')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomePage(onLocaleChange: setLocale),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  const HomePage({Key? key, required this.onLocaleChange}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool regenNotified = false;
  String log = 'App initialized.\\nMock mode active.';
  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('app_title'))),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButton<Locale>(
              value: Localizations.localeOf(context),
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('cs'), child: Text('Čeština')),
              ],
              onChanged: (loc) {
                if (loc != null) widget.onLocaleChange(loc);
              },
            ),
            SizedBox(height: 12),
            Text('${t.translate('bluetooth_state')}: MOCK'),
            SizedBox(height: 12),
            Text('${t.translate('rpm')}: 0'),
            SizedBox(height: 12),
            Expanded(child: SingleChildScrollView(child: Text(log))),
            SizedBox(height: 12),
            BlinkingAlert(active: regenNotified),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.play_arrow),
        onPressed: () {
          setState(() {
            regenNotified = !regenNotified;
            log += '\\nToggled regen: $regenNotified';
          });
        },
      ),
    );
  }
}
