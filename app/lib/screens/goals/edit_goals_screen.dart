import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_log_provider.dart';

class EditGoalsScreen extends StatefulWidget {
  const EditGoalsScreen({super.key});

  @override
  State<EditGoalsScreen> createState() => _EditGoalsScreenState();
}

class _EditGoalsScreenState extends State<EditGoalsScreen> {
  late TextEditingController _calorieController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<DailyLogProvider>(context, listen: false);
    _calorieController = TextEditingController(
      text: provider.calorieGoal.toInt().toString(),
    );
    _proteinController = TextEditingController(
      text: provider.proteinGoal.toInt().toString(),
    );
    _carbsController = TextEditingController(
      text: provider.carbsGoal.toInt().toString(),
    );
    _fatController = TextEditingController(
      text: provider.fatGoal.toInt().toString(),
    );
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  bool _saving = false;

  Future<void> _saveGoals() async {
    final provider = Provider.of<DailyLogProvider>(context, listen: false);

    final calorieGoal = double.tryParse(_calorieController.text) ?? 2000.0;
    final proteinGoal = double.tryParse(_proteinController.text) ?? 150.0;
    final carbsGoal   = double.tryParse(_carbsController.text)   ?? 250.0;
    final fatGoal     = double.tryParse(_fatController.text)     ?? 65.0;

    setState(() => _saving = true);
    final ok = await provider.updateGoals(
      calorieGoal: calorieGoal,
      proteinGoal: proteinGoal,
      carbsGoal:   carbsGoal,
      fatGoal:     fatGoal,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Goals updated successfully!'
            : 'Saved locally — check your connection to sync.'),
        backgroundColor: ok ? Colors.green : Colors.orange,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Goals'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _calorieController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calorie Goal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_fire_department),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _proteinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Protein Goal (g)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _carbsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Carbs Goal (g)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.grain),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fatController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fat Goal (g)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.opacity),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saving ? null : _saveGoals,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _saving ? 'Saving…' : 'Save Goals',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
