import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model untuk Aktivitas
class Activity {
  final String name;
  final String category;
  final int duration;
  bool isFavorite;
  bool isBlocked;

  Activity({
    required this.name,
    required this.category,
    required this.duration,
    this.isFavorite = false,
    this.isBlocked = false,
  });
}

// Main Screen (Home)
class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final bool isDarkMode;

  HomeScreen({required this.onThemeToggle, required this.isDarkMode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Activity> activities = [];
  bool _isStrictMode = false;

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _loadMode();
  }

  void _loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load activities from SharedPreferences or initialize empty
    });
  }

  void _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    // Save activities to SharedPreferences
  }

  void _toggleMode(bool value) async {
    setState(() {
      _isStrictMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isStrictMode', _isStrictMode);
  }

  void _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isStrictMode = prefs.getBool('isStrictMode') ?? false;
    });
  }

  Map<String, int> _generateStats() {
    Map<String, int> activityCount = {};
    for (var activity in activities) {
      activityCount[activity.name] = (activityCount[activity.name] ?? 0) + 1;
    }
    return activityCount;
  }

  void _addRandomInspiration() {
    List<String> inspirations = [
      'Jalan kaki 5 menit',
      'Meditasi singkat',
      'Minum air putih',
      'Stretching sederhana',
      'Menulis jurnal',
    ];
    final randomActivity =
        inspirations[activities.length % inspirations.length];

    setState(() {
      activities.add(Activity(
        name: randomActivity,
        category: 'Inspirasi',
        duration: 5,
      ));
    });
    _saveActivities();
  }

  // Method to add a new activity
  void _addActivity(Activity activity) {
    setState(() {
      activities.add(activity);
    });
    _saveActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RandomRoutine'),
        actions: [
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onThemeToggle,
            activeColor: Colors.yellow,
          ),
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              final stats = _generateStats();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StatsScreen(stats: stats),
                ),
              );
            },
          ),
        ],
      ),
      body: activities.isEmpty
          ? Center(
              child: Text('Belum ada aktivitas. Tambahkan aktivitas baru!'))
          : ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          activity.isFavorite ? Colors.red : Colors.blue,
                      child: Icon(
                        activity.isFavorite
                            ? Icons.favorite
                            : Icons.directions_run,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      activity.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${activity.duration} menit - ${activity.category}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            activity.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: activity.isFavorite ? Colors.red : null,
                          ),
                          onPressed: () {
                            setState(() {
                              activity.isFavorite = !activity.isFavorite;
                            });
                            _saveActivities();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            activity.isBlocked
                                ? Icons.block
                                : Icons.check_circle,
                            color:
                                activity.isBlocked ? Colors.grey : Colors.green,
                          ),
                          onPressed: () {
                            setState(() {
                              activity.isBlocked = !activity.isBlocked;
                            });
                            _saveActivities();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _addRandomInspiration,
            label: Text('Inspirasi'),
            icon: Icon(Icons.lightbulb_outline),
            heroTag: 'inspiration',
            backgroundColor: Colors.orange,
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AddActivityScreen(onAddActivity: _addActivity),
                ),
              );
            },
            label: Text('Tambah Aktivitas'),
            icon: Icon(Icons.add),
            heroTag: 'add',
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}

// Add Activity Screen
class AddActivityScreen extends StatefulWidget {
  final Function(Activity) onAddActivity;

  AddActivityScreen({required this.onAddActivity});

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  void _submit() {
    final name = _nameController.text;
    final category = _categoryController.text;
    final duration = int.tryParse(_durationController.text) ?? 30;

    if (name.isNotEmpty && category.isNotEmpty) {
      widget.onAddActivity(
          Activity(name: name, category: category, duration: duration));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Aktivitas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nama Aktivitas'),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Kategori'),
            ),
            TextField(
              controller: _durationController,
              decoration: InputDecoration(labelText: 'Durasi (menit)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Tambah Aktivitas'),
            ),
          ],
        ),
      ),
    );
  }
}

// Stats Screen
class StatsScreen extends StatelessWidget {
  final Map<String, int> stats;

  StatsScreen({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Statistik Aktivitas')),
      body: stats.isEmpty
          ? Center(child: Text('Belum ada data statistik.'))
          : ListView.builder(
              itemCount: stats.length,
              itemBuilder: (context, index) {
                String activity = stats.keys.elementAt(index);
                int count = stats[activity]!;
                return ListTile(
                  title: Text(activity),
                  trailing: Text('$count kali'),
                );
              },
            ),
    );
  }
}

// Main Application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(RandomRoutineApp(isDarkMode: isDarkMode));
}

class RandomRoutineApp extends StatefulWidget {
  final bool isDarkMode;

  RandomRoutineApp({required this.isDarkMode});

  @override
  _RandomRoutineAppState createState() => _RandomRoutineAppState();
}

class _RandomRoutineAppState extends State<RandomRoutineApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void _toggleTheme(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      home: HomeScreen(
        onThemeToggle: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }
}
