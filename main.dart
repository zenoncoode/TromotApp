import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:io';

class Settings {
  String name;
  bool state;

  Settings({required this.name, required this.state});

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      name: json['name'],
      state: json['state'].toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'state': state.toString(),
    };
  }
}

class SettingsService {
  Future<List<Settings>> getSettings() async {
    final response =
        await rootBundle.loadString('lib/core/database/settings.json');
    final decoded = jsonDecode(response);
    final List<dynamic> settingsList = decoded['Settings'];
    return settingsList.map((json) => Settings.fromJson(json)).toList();
  }
}

class SettingsController {
  final settings = ValueNotifier<List<Settings>>([]);

  Future<void> fetchSettings() async {
    final service = SettingsService();
    final fetchedSettings = await service.getSettings();
    settings.value = fetchedSettings;
  }

  Future<void> updateSettings() async {
    final List<Map<String, dynamic>> updatedSettings =
        settings.value.map((setting) => setting.toJson()).toList();

    final Map<String, dynamic> jsonData = {'Settings': updatedSettings};

    final jsonString = jsonEncode(jsonData);

    await File('lib/core/database/settings.json').writeAsString(jsonString);
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tromot App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tromot',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.red,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('tromot_logo.jpg', height: 80),
                ],
              ),
            ),
            ListTile(
              title: const Text('Início'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Ajuda'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ... (unchanged code)

            SizedBox(
              height: 150,
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConducaoPersonalizadaScreen(),
                    ),
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: Text(
                      'Personalize Condução',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfortoPersonalizadoScreen(
                        settings: [
                          Settings(name: 'opcao1', state: false),
                          Settings(name: 'opcao2', state: false),
                        ],
                      ),
                    ),
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: Text(
                      'Personalize Conforto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConducaoPersonalizadaScreen extends StatefulWidget {
  const ConducaoPersonalizadaScreen({super.key});

  @override
  State<ConducaoPersonalizadaScreen> createState() =>
      _ConducaoPersonalizadaState();
}

class _ConducaoPersonalizadaState extends State<ConducaoPersonalizadaScreen> {
  final controller = SettingsController();

  @override
  void initState() {
    controller.fetchSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personalize Condução',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: ValueListenableBuilder(
        valueListenable: controller.settings,
        builder: (context, List<Settings> settings, child) {
          return ListView.builder(
            itemCount: settings.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(settings[index].name),
                trailing: Switch(
                  value: settings[index].state,
                  onChanged: (bool value) async {
                    setState(() {
                      settings[index].state = value;
                    });

                    await controller.updateSettings();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ConfortoPersonalizadoScreen extends StatelessWidget {
  final List<Settings> settings;

  const ConfortoPersonalizadoScreen({Key? key, required this.settings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personalize Conforto',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: SettingsPage(settings: settings),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final List<Settings> settings;

  const SettingsPage({required this.settings, Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: widget.settings.map((setting) {
        return ListTile(
          title: Text(setting.name),
          trailing: Switch(
            value: setting.state,
            onChanged: (bool value) async {
              setState(() {
                setting.state = value;
              });

              await SettingsController().updateSettings();
            },
          ),
        );
      }).toList(),
    );
  }
}
